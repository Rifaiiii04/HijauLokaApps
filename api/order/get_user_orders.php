<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

header('Content-Type: application/json; charset=utf-8');

// Check for required parameters
if (!isset($_GET['user_id'])) {
    echo json_encode(['success' => false, 'message' => 'User ID is required']);
    exit();
}

// Get parameters
$user_id = $_GET['user_id'];
$status = $_GET['status'] ?? '';
$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;
$offset = ($page - 1) * $limit;

// Database connection
$host = "103.247.11.220";
$db_name = "hijc7862_hijauloka";
$username = "hijc7862_admin";
$password = "wyn[=?alPV%.";

$conn = new mysqli($host, $username, $password, $db_name);

if ($conn->connect_error) {
    echo json_encode([
        'success' => false, 
        'message' => 'Database connection failed. Please try again later.'
    ]);
    exit;
}

try {
    // Build the query based on status parameter
    $statusCondition = '';
    if (!empty($status)) {
        $statusCondition = " AND o.stts_pemesanan = ?";
    }
    
    // Count total orders
    $countSql = "SELECT COUNT(*) as total FROM orders o WHERE o.id_user = ?$statusCondition";
    $countStmt = $conn->prepare($countSql);
    
    if (!empty($status)) {
        $countStmt->bind_param("is", $user_id, $status);
    } else {
        $countStmt->bind_param("i", $user_id);
    }
    
    $countStmt->execute();
    $totalResult = $countStmt->get_result();
    $totalRow = $totalResult->fetch_assoc();
    $totalOrders = $totalRow['total'];
    
    // Get orders with pagination - simplified query
    $sql = "SELECT 
                o.id_order,
                o.tgl_pemesanan,
                o.stts_pemesanan,
                o.total_harga,
                o.stts_pembayaran,
                o.metode_pembayaran,
                o.kurir,
                o.ongkir
            FROM orders o
            WHERE o.id_user = ?$statusCondition
            ORDER BY o.tgl_pemesanan DESC
            LIMIT ?, ?";
    
    $stmt = $conn->prepare($sql);
    
    if (!empty($status)) {
        $stmt->bind_param("isii", $user_id, $status, $offset, $limit);
    } else {
        $stmt->bind_param("iii", $user_id, $offset, $limit);
    }
    
    $stmt->execute();
    $result = $stmt->get_result();
    
    $orders = [];
    while ($row = $result->fetch_assoc()) {
        // Format date
        $orderDate = new DateTime($row['tgl_pemesanan']);
        $formattedDate = $orderDate->format('d M Y H:i');
        
        // Add order to array with minimal processing
        $orders[] = [
            'id_order' => (int)$row['id_order'],
            'tgl_pemesanan' => $row['tgl_pemesanan'],
            'formatted_date' => $formattedDate,
            'status' => $row['stts_pemesanan'],
            'total_harga' => (float)$row['total_harga'],
            'stts_pembayaran' => $row['stts_pembayaran'],
            'metode_pembayaran' => $row['metode_pembayaran'],
            'kurir' => $row['kurir'],
            'ongkir' => (float)$row['ongkir']
        ];
    }
    
    // Prepare pagination info
    $totalPages = ceil($totalOrders / $limit);
    
    // Prepare response
    $response = [
        'success' => true,
        'data' => $orders,
        'pagination' => [
            'total_orders' => (int)$totalOrders,
            'total_pages' => (int)$totalPages,
            'current_page' => (int)$page,
            'limit' => (int)$limit
        ]
    ];
    
    echo json_encode($response);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Error retrieving orders: ' . $e->getMessage()
    ]);
}

// Close the connection
$conn->close();
?>