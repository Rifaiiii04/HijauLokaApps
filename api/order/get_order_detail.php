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
                o.id_admin,
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
    $itemsStmt->bind_param("i", $order['id_order']);
    $itemsStmt->execute();
    $itemsResult = $itemsStmt->get_result();
    
    $items = [];
    $subtotal = 0;
    
    while ($item = $itemsResult->fetch_assoc()) {
        // Calculate item total
        $itemTotal = $item['jumlah'] * $item['harga_satuan'];
        $subtotal += $itemTotal;
        
        // Set image URL
        $imageUrl = 'https://admin.hijauloka.my.id/assets/images/products/' . $item['gambar'];
        
        $items[] = [
            'id' => $item['id_detail_order'],
            'order_id' => $item['id_order'],
            'product_id' => $item['id_product'],
            'quantity' => $item['jumlah'],
            'price' => $item['harga_satuan'],
            'total' => $itemTotal,
            'product_name' => $item['nama_product'],
            'product_image' => $imageUrl
        ];
    }
    
    // Format order date
    $orderDate = new DateTime($order['tgl_pemesanan']);
    $formattedDate = $orderDate->format('d M Y H:i');
    
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
    
    // Add payment URL if needed
    $paymentUrl = null;
    if ($order['metode_pembayaran'] === 'midtrans' && $order['stts_pembayaran'] === 'belum_dibayar') {
        $paymentUrl = 'https://admin.hijauloka.my.id/api/order/payment.php?order_id=' . $order['order_id'];
    }
    
    // Format order details for response
    $orderDetails = [
        'id' => $order['id_order'],
        'order_id' => $order['order_id'],
        'user_id' => $order['id_user'],
        'user_name' => $order['user_name'],
        'user_email' => $order['user_email'],
        'user_phone' => $order['user_phone'] ?? '',
        'admin_id' => $order['id_admin'],
        'admin_name' => $order['admin_name'] ?? 'Admin',
        'date' => $order['tgl_pemesanan'],
        'formatted_date' => $formattedDate,
        'status' => $order['status'],
        'status_text' => $statusText,
        'status_color' => $statusColor,
        'payment_status' => $order['stts_pembayaran'],
        'payment_method' => $order['metode_pembayaran'],
        'shipping_method' => $order['shipping_method'],
        'shipping_cost' => (float)$order['shipping_cost'],
        'subtotal' => $subtotal,
        'total' => (float)$order['total_harga'],
        'needs_payment' => ($order['stts_pembayaran'] === 'belum_dibayar'),
        'can_cancel' => ($order['status'] === 'pending' || $order['status'] === 'diproses'),
        'payment_url' => $paymentUrl,
        'items' => $items,
        'shipping_address' => [
            'id' => $order['shipping_address_id'],
            'recipient_name' => $order['recipient_name'],
            'phone' => $order['phone'],
            'address' => $order['address'],
            'postal_code' => $order['postal_code'],
            'rt' => $order['rt'] ?? '',
            'rw' => $order['rw'] ?? '',
            'house_number' => $order['house_number'] ?? '',
            'detail_address' => $order['detail_address'] ?? '',
            'full_address' => buildFullAddress($order)
        ]
    ];
    
    // Return order details
    echo json_encode([
        'success' => true,
        'message' => 'Order details retrieved successfully',
        'data' => $orderDetails
    ]);
    
} catch (Exception $e) {
    // Log the error
    file_put_contents('order_debug.log', date('Y-m-d H:i:s') . " - Error: " . $e->getMessage() . "\n", FILE_APPEND);
    
    echo json_encode([
        'success' => false,
        'message' => 'Error retrieving order details: ' . $e->getMessage()
    ]);
}

// Close connection
if (isset($conn) && $conn !== null) {
    $conn->close();
}
?>