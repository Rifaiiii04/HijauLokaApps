<?php
ini_set('display_errors', 0); // Disable error display in production
error_reporting(E_ALL);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

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
if (!isset($_GET['order_id'])) {
    echo json_encode(['success' => false, 'message' => 'Order ID is required']);
    exit();
}

$order_id = $_GET['order_id'];

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

// Function to build full address string
function buildFullAddress($order) {
    $address = $order['address'] ?? '';
    
    // Add RT/RW if available
    if (!empty($order['rt']) && !empty($order['rw'])) {
        $address .= ', RT ' . $order['rt'] . '/RW ' . $order['rw'];
    }
    
    // Add house number if available
    if (!empty($order['house_number'])) {
        $address .= ', No. ' . $order['house_number'];
    }
    
    // Add postal code if available
    if (!empty($order['postal_code'])) {
        $address .= ', ' . $order['postal_code'];
    }
    
    // Add detail address if available
    if (!empty($order['detail_address'])) {
        $address .= ' (' . $order['detail_address'] . ')';
    }
    
    return $address;
}

try {
    // Get order details
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
                o.tgl_batal,
                o.id_admin,
                o.midtrans_order_id,
                u.nama as user_name,
                u.email as user_email,
                u.no_tlp as user_phone,
                a.nama as admin_name
            FROM orders o
            LEFT JOIN user u ON o.id_user = u.id_user
            LEFT JOIN admin a ON o.id_admin = a.id_admin
            WHERE o.order_id = ?";
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $order_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        echo json_encode(['success' => false, 'message' => 'Order not found']);
        exit();
    }
    
    $order = $result->fetch_assoc();
    
    // Get shipping address
    $addressSql = "SELECT 
                    sa.id_address,
                    sa.recipient_name,
                    sa.phone,
                    sa.address_label,
                    sa.address,
                    sa.rt,
                    sa.rw,
                    sa.house_number,
                    sa.postal_code,
                    sa.detail_address
                FROM shipping_address sa
                JOIN order_shipping_address osa ON sa.id_address = osa.id_address
                WHERE osa.id_order = ?";
    $addressStmt = $conn->prepare($addressSql);
    $addressStmt->bind_param("i", $order['id_order']);
    $addressStmt->execute();
    $addressResult = $addressStmt->get_result();
    
    $shippingAddress = null;
    if ($addressResult->num_rows > 0) {
        $shippingAddress = $addressResult->fetch_assoc();
        $shippingAddress['full_address'] = buildFullAddress($shippingAddress);
    }
    
    // Get order items
    $itemsSql = "SELECT 
                    do.id_detail_order,
                    do.id_order,
                    do.id_product,
                    do.jumlah,
                    do.harga_satuan,
                    p.nama_product,
                    p.deskripsi,
                    p.gambar_url
                FROM detail_order do
                LEFT JOIN product p ON do.id_product = p.id_product
                WHERE do.id_order = ?";
    $itemsStmt = $conn->prepare($itemsSql);
    $itemsStmt->bind_param("i", $order['id_order']);
    $itemsStmt->execute();
    $itemsResult = $itemsStmt->get_result();
    
    $orderItems = [];
    $subtotal = 0;
    
    while ($item = $itemsResult->fetch_assoc()) {
        $itemTotal = (float)$item['harga_satuan'] * (int)$item['jumlah'];
        $subtotal += $itemTotal;
        
        $orderItems[] = [
            'id' => $item['id_detail_order'],
            'product_id' => $item['id_product'],
            'product_name' => $item['nama_product'] ?? 'Unknown Product',
            'description' => $item['deskripsi'] ?? '',
            'image_url' => $item['gambar_url'] ?? '',
            'quantity' => (int)$item['jumlah'],
            'price' => (float)$item['harga_satuan'],
            'total' => $itemTotal
        ];
    }
    
    // Format dates
    $orderDate = new DateTime($order['tgl_pemesanan']);
    $formattedOrderDate = $orderDate->format('d M Y H:i');
    
    $completedDate = null;
    if (!empty($order['tgl_selesai'])) {
        $completedDate = new DateTime($order['tgl_selesai']);
        $completedDate = $completedDate->format('d M Y H:i');
    }
    
    $shippedDate = null;
    if (!empty($order['tgl_dikirim'])) {
        $shippedDate = new DateTime($order['tgl_dikirim']);
        $shippedDate = $shippedDate->format('d M Y H:i');
    }
    
    $cancelledDate = null;
    if (!empty($order['tgl_batal'])) {
        $cancelledDate = new DateTime($order['tgl_batal']);
        $cancelledDate = $cancelledDate->format('d M Y H:i');
    }
    
    // Determine if order can be cancelled
    $canCancel = ($order['status'] == 'pending' || $order['status'] == 'diproses');
    
    // Determine status color and text
    $statusColor = '#28a745'; // Default green
    $statusText = 'Pesanan Dibuat';
    
    switch ($order['status']) {
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
    
    // Prepare response data
    $responseData = [
        'success' => true,
        'data' => [
            'id' => $order['id_order'],
            'order_id' => $order['order_id'],
            'user_id' => $order['id_user'],
            'user_name' => $order['user_name'],
            'user_email' => $order['user_email'],
            'user_phone' => $order['user_phone'],
            'order_date' => $order['tgl_pemesanan'],
            'formatted_date' => $formattedOrderDate,
            'status' => $order['status'],
            'status_text' => $statusText,
            'status_color' => $statusColor,
            'payment_status' => $order['stts_pembayaran'],
            'payment_method' => $order['metode_pembayaran'],
            'shipping_method' => $order['shipping_method'],
            'shipping_cost' => (float)$order['shipping_cost'],
            'subtotal' => $subtotal,
            'total' => (float)$order['total_harga'],
            'completed_date' => $completedDate,
            'shipped_date' => $shippedDate,
            'cancelled_date' => $cancelledDate,
            'admin_id' => $order['id_admin'],
            'admin_name' => $order['admin_name'],
            'midtrans_order_id' => $order['midtrans_order_id'],
            'can_cancel' => $canCancel,
            'shipping_address' => $shippingAddress,
            'items' => $orderItems
        ]
    ];
    
    echo json_encode($responseData);
    
} catch (Exception $e) {
    // Log the error
    file_put_contents('order_debug.log', date('Y-m-d H:i:s') . " - Error: " . $e->getMessage() . "\n", FILE_APPEND);
    
    echo json_encode([
        'success' => false,
        'message' => 'An error occurred while processing your request',
        'error' => $e->getMessage()
    ]);
}

// Always close the connection
$conn->close();
?>