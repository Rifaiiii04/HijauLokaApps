<?php
ini_set('display_errors', 1); // Enable error display for debugging
error_reporting(E_ALL);

// Set content type
header('Content-Type: application/json; charset=utf-8');

// Check for required parameters
if (!isset($_GET['order_id']) || empty($_GET['order_id'])) {
    echo json_encode(['success' => false, 'message' => 'Valid Order ID is required']);
    exit();
}

$order_id = intval($_GET['order_id']);

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
    // Get order details with user information
    $sql = "SELECT 
                o.id_order,
                o.id_user,
                o.tgl_pemesanan,
                o.stts_pemesanan,
                o.total_harga,
                o.stts_pembayaran,
                o.metode_pembayaran,
                o.kurir,
                o.ongkir,
                o.tgl_selesai,
                o.tgl_dikirim,
                o.tgl_batal,
                o.id_admin,
                o.midtrans_order_id,
                u.nama as user_name,
                u.email as user_email,
                u.alamat as user_address,
                u.no_tlp as user_phone
            FROM orders o
            LEFT JOIN user u ON o.id_user = u.id_user
            WHERE o.id_order = ?";
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $order_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        echo json_encode(['success' => false, 'message' => 'Order not found']);
        exit();
    }
    
    $order = $result->fetch_assoc();
    
    // Get shipping address from shipping_addresses table - check if is_primary column exists
    $checkColumnSql = "SHOW COLUMNS FROM shipping_addresses LIKE 'is_primary'";
    $checkColumnResult = $conn->query($checkColumnSql);
    
    $addressSql = "";
    if ($checkColumnResult->num_rows > 0) {
        $addressSql = "SELECT 
                        sa.*
                    FROM shipping_addresses sa
                    WHERE sa.user_id = ? AND sa.is_primary = 1
                    LIMIT 1";
    } else {
        $addressSql = "SELECT 
                        sa.*
                    FROM shipping_addresses sa
                    WHERE sa.user_id = ?
                    LIMIT 1";
    }
    
    $addressStmt = $conn->prepare($addressSql);
    $addressStmt->bind_param("i", $order['id_user']);
    $addressStmt->execute();
    $addressResult = $addressStmt->get_result();
    
    $shippingAddress = null;
    if ($addressResult->num_rows > 0) {
        $shippingAddress = $addressResult->fetch_assoc();
        
        // Build full address
        $fullAddress = $shippingAddress['address'] ?? '';
        
        // Add RT/RW if available
        if (!empty($shippingAddress['rt']) && !empty($shippingAddress['rw'])) {
            $fullAddress .= ', RT ' . $shippingAddress['rt'] . '/RW ' . $shippingAddress['rw'];
        }
        
        // Add house number if available
        if (!empty($shippingAddress['house_number'])) {
            $fullAddress .= ', No. ' . $shippingAddress['house_number'];
        }
        
        // Add postal code if available
        if (!empty($shippingAddress['postal_code'])) {
            $fullAddress .= ', ' . $shippingAddress['postal_code'];
        }
        
        $shippingAddress['full_address'] = $fullAddress;
    } else {
        // If no shipping address found, create a default one with user address
        $shippingAddress = [
            'recipient_name' => $order['user_name'] ?? 'N/A',
            'phone' => $order['user_phone'] ?? 'N/A',
            'address' => $order['user_address'] ?? 'N/A',
            'full_address' => $order['user_address'] ?? 'N/A'
        ];
    }
    
    // Get order items with product details
    $itemsSql = "SELECT 
                    do.id_detail_order,
                    do.id_order,
                    do.id_product,
                    do.jumlah,
                    do.harga_satuan,
                    p.nama_product,
                    p.desk_product,
                    p.gambar
                FROM detail_order do
                LEFT JOIN product p ON do.id_product = p.id_product
                WHERE do.id_order = ?";
    
    $itemsStmt = $conn->prepare($itemsSql);
    $itemsStmt->bind_param("i", $order_id);
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
            'description' => $item['desk_product'] ?? '',
            'image' => $item['gambar'] ?? '',
            'quantity' => (int)$item['jumlah'],
            'price' => (float)$item['harga_satuan'],
            'total' => $itemTotal
        ];
    }
    
    // Prepare response data
    $responseData = [
        'success' => true,
        'data' => [
            'id' => (int)$order['id_order'],
            'id_order' => (int)$order['id_order'],
            'order_id' => (string)$order['id_order'],
            'user_id' => (int)$order['id_user'],
            'userId' => (int)$order['id_user'],
            'orderDate' => $order['tgl_pemesanan'],
            'tgl_pemesanan' => $order['tgl_pemesanan'],
            'status' => $order['stts_pemesanan'],
            'stts_pemesanan' => $order['stts_pemesanan'],
            'total' => (float)$order['total_harga'],
            'total_harga' => (float)$order['total_harga'],
            'paymentStatus' => $order['stts_pembayaran'],
            'stts_pembayaran' => $order['stts_pembayaran'],
            'paymentMethod' => $order['metode_pembayaran'],
            'metode_pembayaran' => $order['metode_pembayaran'],
            'shippingMethod' => $order['kurir'],
            'kurir' => $order['kurir'],
            'shippingCost' => (float)$order['ongkir'],
            'ongkir' => (float)$order['ongkir'],
            'completedDate' => $order['tgl_selesai'],
            'tgl_selesai' => $order['tgl_selesai'],
            'shippedDate' => $order['tgl_dikirim'],
            'tgl_dikirim' => $order['tgl_dikirim'],
            'cancelledDate' => $order['tgl_batal'],
            'tgl_batal' => $order['tgl_batal'],
            'adminId' => (int)$order['id_admin'],
            'id_admin' => (int)$order['id_admin'],
            'midtransOrderId' => $order['midtrans_order_id'],
            'midtrans_order_id' => $order['midtrans_order_id'],
            'userName' => $order['user_name'],
            'user_name' => $order['user_name'],
            'userEmail' => $order['user_email'],
            'user_email' => $order['user_email'],
            'userAddress' => $order['user_address'],
            'user_address' => $order['user_address'],
            'userPhone' => $order['user_phone'],
            'user_phone' => $order['user_phone'],
            'subtotal' => $subtotal,
            'shipping_address' => $shippingAddress,
            'shippingAddress' => $shippingAddress,
            'items' => $orderItems
        ]
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