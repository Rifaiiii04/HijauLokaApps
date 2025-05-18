<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

header('Content-Type: application/json; charset=utf-8');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Check if request method is GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    echo json_encode(['success' => false, 'message' => 'Only GET method is allowed']);
    exit();
}

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
    file_put_contents('orders_debug.log', date('Y-m-d H:i:s') . " - Database connection failed: " . $conn->connect_error . "\n", FILE_APPEND);
    
    http_response_code(500);
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
    
    // Get orders with pagination
    $sql = "SELECT 
                o.id_order,
                o.order_id,
                o.id_user,
                o.tgl_pemesanan,
                o.stts_pemesanan as status,
                o.total_harga,
                o.stts_pembayaran,
                o.metode_pembayaran,
                o.kurir as shipping_method,
                o.ongkir as shipping_cost,
                o.tgl_selesai,
                o.tgl_dikirim,
                o.id_admin,
                s.id as shipping_address_id,
                s.recipient_name,
                s.phone,
                s.address,
                s.postal_code,
                u.nama as user_name,
                u.email as user_email,
                u.no_tlp as user_phone,
                a.nama as admin_name
            FROM orders o
            LEFT JOIN shipping_addresses s ON o.shipping_address_id = s.id
            LEFT JOIN user u ON o.id_user = u.id_user
            LEFT JOIN admin a ON o.id_admin = a.id_admin
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
        // Get order items
        $itemsSql = "SELECT 
                        d.id_detail_order,
                        d.id_order,
                        d.id_product,
                        d.jumlah,
                        d.harga_satuan,
                        p.nama_product,
                        p.gambar
                    FROM detail_order d
                    LEFT JOIN product p ON d.id_product = p.id_product
                    WHERE d.id_order = ?";
        $itemsStmt = $conn->prepare($itemsSql);
        $itemsStmt->bind_param("i", $row['id_order']);
        $itemsStmt->execute();
        $itemsResult = $itemsStmt->get_result();
        
        $items = [];
        while ($item = $itemsResult->fetch_assoc()) {
            // Set image URL
            $imageUrl = 'https://admin.hijauloka.my.id/assets/images/products/' . $item['gambar'];
            
            $items[] = [
                'id' => $item['id_detail_order'],
                'order_id' => $item['id_order'],
                'product_id' => $item['id_product'],
                'quantity' => $item['jumlah'],
                'price' => $item['harga_satuan'],
                'product_name' => $item['nama_product'],
                'product_image' => $imageUrl
            ];
        }
        
        // Format order date
        $orderDate = new DateTime($row['tgl_pemesanan']);
        $formattedDate = $orderDate->format('d M Y H:i');
        
        // Determine status color and text
        $statusColor = '#28a745'; // Default green
        $statusText = 'Pesanan Dibuat';
        
        switch ($row['status']) {
            case 'pending':
                $statusColor = '#ffc107'; // Yellow
                $statusText = 'Menunggu Pembayaran';
                break;
            case 'diproses':
                $statusColor = '#17a2b8'; // Blue
                $statusText = 'Diproses';
                break;
            case 'dikirim':
                $statusColor = '#007bff'; // Primary Blue
                $statusText = 'Dikirim';
                break;
            case 'selesai':
                $statusColor = '#28a745'; // Green
                $statusText = 'Selesai';
                break;
            case 'dibatalkan':
                $statusColor = '#dc3545'; // Red
                $statusText = 'Dibatalkan';
                break;
        }
        
        // Add payment URL if needed
        $paymentUrl = null;
        if ($row['metode_pembayaran'] === 'midtrans' && $row['stts_pembayaran'] === 'belum_dibayar') {
            $paymentUrl = 'https://admin.hijauloka.my.id/api/order/payment.php?order_id=' . $row['order_id'];
        }
        
        $orders[] = [
            'id' => $row['id_order'],
            'order_id' => $row['order_id'],
            'user_id' => $row['id_user'],
            'user_name' => $row['user_name'] ?? '',
            'user_email' => $row['user_email'] ?? '',
            'user_phone' => $row['user_phone'] ?? '',
            'admin_id' => $row['id_admin'] ?? 1,
            'admin_name' => $row['admin_name'] ?? 'Admin',
            'date' => $row['tgl_pemesanan'],
            'formatted_date' => $formattedDate,
            'status' => $row['status'],
            'status_text' => $statusText,
            'status_color' => $statusColor,
            'payment_status' => $row['stts_pembayaran'],
            'payment_method' => $row['metode_pembayaran'],
            'shipping_method' => $row['shipping_method'],
            'shipping_cost' => $row['shipping_cost'],
            'total' => $row['total_harga'],
            'needs_payment' => ($row['stts_pembayaran'] === 'belum_dibayar'),
            'can_cancel' => ($row['status'] === 'pending' || $row['status'] === 'diproses'),
            'payment_url' => $paymentUrl,
            'items' => $items,
            'shipping_address' => [
                'id' => $row['shipping_address_id'],
                'recipient_name' => $row['recipient_name'],
                'phone' => $row['phone'],
                'address' => $row['address'],
                'postal_code' => $row['postal_code']
            ]
        ];
    }
    
    // Return orders
    echo json_encode([
        'success' => true,
        'message' => 'Orders retrieved successfully',
        'data' => [
            'orders' => $orders,
            'pagination' => [
                'total' => $totalOrders,
                'page' => $page,
                'limit' => $limit,
                'total_pages' => ceil($totalOrders / $limit)
            ]
        ]
    ]);
    
} catch (Exception $e) {
    // Log the error
    file_put_contents('orders_debug.log', date('Y-m-d H:i:s') . " - Error: " . $e->getMessage() . "\n", FILE_APPEND);
    
    echo json_encode([
        'success' => false,
        'message' => 'Error retrieving orders: ' . $e->getMessage()
    ]);
}

// Close connection
if (isset($conn) && $conn !== null) {
    $conn->close();
}
?> 