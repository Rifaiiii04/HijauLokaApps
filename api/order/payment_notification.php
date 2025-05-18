<?php
header('Content-Type: application/json; charset=utf-8');
// Direct database connection
$host = "103.247.11.220";
$db_name = "hijc7862_hijauloka";
$username = "hijc7862_admin";
$password = "wyn[=?alPV%.";

// Create connection
$conn = new mysqli($host, $username, $password, $db_name);

// Check connection
if ($conn->connect_error) {
    error_log("Database connection failed: " . $conn->connect_error);
    die("Database connection failed. Please try again later.");
}

// Check if Midtrans library is installed
if (!file_exists('../vendor/autoload.php')) {
    error_log("Midtrans library not found. Please run composer require midtrans/midtrans-php");
    die("Midtrans library not found");
}

require_once '../vendor/autoload.php';

// Set your Midtrans server key
\Midtrans\Config::$serverKey = 'SB-Mid-server-cHC4Z3JHh_Z8dHnQ8f4kK89x';
\Midtrans\Config::$isProduction = false;

try {
    // Get notification data from Midtrans
    $notification_body = file_get_contents('php://input');
    $notification = json_decode($notification_body);
    
    if (!$notification) {
        // Try to get from POST data if JSON parsing fails
        $notification = new \Midtrans\Notification();
    }
    
    // Get transaction status
    $transaction = $notification->transaction_status;
    $type = $notification->payment_type;
    $order_id = $notification->order_id;
    $fraud = $notification->fraud_status ?? null;
    
    // Log notification for debugging
    error_log("Midtrans Notification: " . $notification_body);
    
    // Handle transaction status
    if ($transaction == 'capture') {
        if ($type == 'credit_card') {
            if ($fraud == 'challenge') {
                // Transaction is challenged (manual review needed)
                $new_status = 'pending';
            } else {
                // Transaction is successful
                $new_status = 'processing';
            }
        } else {
            // Non-credit card transactions that are captured are successful
            $new_status = 'processing';
        }
    } else if ($transaction == 'settlement') {
        // Transaction is settled (successful)
        $new_status = 'processing';
    } else if ($transaction == 'pending') {
        // Transaction is pending
        $new_status = 'pending';
    } else if ($transaction == 'deny') {
        // Transaction is denied
        $new_status = 'cancelled';
    } else if ($transaction == 'expire') {
        // Transaction is expired
        $new_status = 'cancelled';
    } else if ($transaction == 'cancel') {
        // Transaction is cancelled
        $new_status = 'cancelled';
    }
    
    // Update order status in database
    $sql = "UPDATE orders SET status = ? WHERE order_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ss", $new_status, $order_id);
    $result = $stmt->execute();
    
    if (!$result) {
        throw new Exception("Failed to update order status: " . $conn->error);
    }
    
    // Return success response
    header('HTTP/1.1 200 OK');
    echo json_encode(['status' => 'success', 'message' => "Payment notification handled successfully"]);
    
} catch (Exception $e) {
    // Log error
    error_log("Error handling payment notification: " . $e->getMessage());
    
    // Return error response
    header('HTTP/1.1 500 Internal Server Error');
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}

// Close connection
$conn->close();
?>