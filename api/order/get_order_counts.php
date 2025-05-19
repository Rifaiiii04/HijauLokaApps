<?php
ini_set('display_errors', 1); // Enable error display for debugging
error_reporting(E_ALL);

// Set content type
header('Content-Type: application/json; charset=utf-8');

// Check if request method is GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    echo json_encode(['success' => false, 'message' => 'Only GET method is allowed']);
    exit();
}

// Check for required parameters
if (!isset($_GET['user_id']) || empty($_GET['user_id'])) {
    echo json_encode(['success' => false, 'message' => 'Valid User ID is required']);
    exit();
}

// Ensure user_id is an integer
$user_id = intval($_GET['user_id']);

// Database connection
$host = "103.247.11.220";
$db_name = "hijc7862_hijauloka";
$username = "hijc7862_admin";
$password = "wyn[=?alPV%.";

// Create connection
$conn = new mysqli($host, $username, $password, $db_name);

// Check connection
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode([
        'success' => false, 
        'message' => 'Database connection failed: ' . $conn->connect_error
    ]);
    exit;
}

try {
    // Get counts for each order status
    $sql = "SELECT 
                stts_pemesanan as status,
                COUNT(*) as count
            FROM orders
            WHERE id_user = ?
            GROUP BY stts_pemesanan";
    
    $stmt = $conn->prepare($sql);
    
    // Make sure we're binding an integer
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    // Initialize counts with zeros
    $counts = [
        'pending' => 0,
        'diproses' => 0,
        'dikirim' => 0,
        'selesai' => 0,
        'dibatalkan' => 0,
        'total' => 0
    ];
    
    // Fill in actual counts
    $total = 0;
    while ($row = $result->fetch_assoc()) {
        $status = $row['status'];
        $count = (int)$row['count'];
        
        if (isset($counts[$status])) {
            $counts[$status] = $count;
        }
        
        $total += $count;
    }
    
    // Set total count
    $counts['total'] = $total;
    
    // Prepare response
    $responseData = [
        'success' => true,
        'data' => $counts
    ];
    
    echo json_encode($responseData);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Error: ' . $e->getMessage()
    ]);
}

// Close the connection
$conn->close();
?>