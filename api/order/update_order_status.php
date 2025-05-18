<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

header('Content-Type: application/json; charset=utf-8');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Check if the request method is POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'message' => 'Only POST method is allowed']);
    exit();
}

// Get POST data
$rawInput = file_get_contents('php://input');
$data = json_decode($rawInput, true);

// Check required fields
if (!isset($data['order_id']) || !isset($data['status'])) {
    echo json_encode(['success' => false, 'message' => 'Order ID and status are required']);
    exit();
}

// Direct database connection
$host = "103.247.11.220";
$db_name = "hijc7862_hijauloka";
$username = "hijc7862_admin";
$password = "wyn[=?alPV%.";

// Create connection
$conn = new mysqli($host, $username, $password, $db_name);

// Check connection
if ($conn->connect_error) {
    // Log the error
    file_put_contents('order_debug.log', date('Y-m-d H:i:s') . " - Database connection failed: " . $conn->connect_error . "\n", FILE_APPEND);
    
    http_response_code(500);
    echo json_encode([
        'success' => false, 
        'message' => 'Database connection failed. Please try again later.'
    ]);
    exit;
}

try {
    // Prepare update statement
    $sql = "UPDATE orders SET stts_pemesanan = ? WHERE order_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ss", $data['status'], $data['order_id']);
    
    // Execute the update
    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode([
                'success' => true,
                'message' => 'Order status updated successfully'
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Order not found or status already up to date'
            ]);
        }
    } else {
        throw new Exception($stmt->error);
    }
} catch (Exception $e) {
    // Log the error
    file_put_contents('order_debug.log', date('Y-m-d H:i:s') . " - Error updating order status: " . $e->getMessage() . "\n", FILE_APPEND);
    
    echo json_encode([
        'success' => false,
        'message' => 'Error updating order status: ' . $e->getMessage()
    ]);
}

// Close connection
$conn->close();
?> 