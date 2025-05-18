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

// Log incoming data
$rawInput = file_get_contents('php://input');
file_put_contents('order_debug.log', date('Y-m-d H:i:s') . " - Received: " . $rawInput . "\n", FILE_APPEND);

// Check valid JSON
$data = json_decode($rawInput, true);
if (json_last_error() !== JSON_ERROR_NONE) {
    http_response_code(400);
    echo json_encode([
        'success' => false, 
        'message' => 'Invalid JSON data: ' . json_last_error_msg()
    ]);
    exit;
}

// Validate required fields
$requiredFields = ['user_id', 'shipping_address_id', 'items'];
foreach ($requiredFields as $field) {
    if (!isset($data[$field])) {
        http_response_code(400);
        echo json_encode([
            'success' => false, 
            'message' => "Missing required field: $field"
        ]);
        exit;
    }
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

// Enable error reporting for mysqli
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

// Log successful connection
file_put_contents('order_debug.log', date('Y-m-d H:i:s') . " - Database connection successful to {$host}\n", FILE_APPEND);

try {
    // Start transaction
    $conn->begin_transaction();
    
    // Generate order ID (format: HL-YYYYMMDD-XXXX)
    $order_prefix = 'HL-' . date('Ymd') . '-';
    
    // Generate a random 4-digit number padded with leading zeros
    $random_number = mt_rand(1, 9999);
    $order_id = $order_prefix . str_pad($random_number, 4, '0', STR_PAD_LEFT);
    
    // Log order ID generation
    file_put_contents('order_debug.log', date('Y-m-d H:i:s') . " - Generated order ID: {$order_id}\n", FILE_APPEND);

    // Store shipping address details separately as we don't have a shipping_address_id field in orders table
    $shipping_data = [];
    if (isset($data['shipping_address_id']) && !empty($data['shipping_address_id'])) {
        // Get shipping address details for later use but not for storing in orders
        $sql_address = "SELECT * FROM shipping_addresses WHERE id = ?";
        $stmt_address = $conn->prepare($sql_address);
        if ($stmt_address) {
            $stmt_address->bind_param("i", $data['shipping_address_id']);
            $stmt_address->execute();
            $address_result = $stmt_address->get_result();
            if ($address_result && $address_result->num_rows > 0) {
                $shipping_data = $address_result->fetch_assoc();
                // Log the shipping address
                file_put_contents('order_debug.log', date('Y-m-d H:i:s') . " - Shipping address found: " . json_encode($shipping_data) . "\n", FILE_APPEND);
            } else {
                file_put_contents('order_debug.log', date('Y-m-d H:i:s') . " - Warning: Shipping address not found for ID: " . $data['shipping_address_id'] . "\n", FILE_APPEND);
            }
            $stmt_address->close();
        }
    } else {
        file_put_contents('order_debug.log', date('Y-m-d H:i:s') . " - Warning: No shipping_address_id provided\n", FILE_APPEND);
    }
    
    // Get admin ID (default to 1 if not found)
    $admin_id = 1;
    $sql_admin = "SELECT id_admin FROM admin LIMIT 1";
    $admin_result = $conn->query($sql_admin);
    if ($admin_result && $admin_result->num_rows > 0) {
        $admin_row = $admin_result->fetch_assoc();
        $admin_id = $admin_row['id_admin'];
    }
    
    // Insert into orders table with all required fields for admin dashboard
    $sql_order = "INSERT INTO orders (
        id_user, 
        metode_pembayaran, 
        kurir, 
        ongkir, 
        total_harga, 
        stts_pemesanan, 
        stts_pembayaran, 
        tgl_pemesanan,
        id_admin
    ) VALUES (?, ?, ?, ?, ?, 'pending', 'belum_dibayar', NOW(), ?)";
    
    $stmt_order = $conn->prepare($sql_order);
    if ($stmt_order === false) {
        throw new Exception("Prepare failed for order insertion: (" . $conn->errno . ") " . $conn->error . " - SQL: " . $sql_order);
    }
    
    // Calculate total (subtotal + shipping)
    $total = $data['total']; 
    
    // Log field names and their types
    $types = "issddi"; // int, string, string, double, double, int
    $values = array(
        'id_user' => $data['user_id'], 
        'payment_method' => $data['payment_method'], 
        'shipping_method' => $data['shipping_method'], 
        'shipping_cost' => $data['shipping_cost'], 
        'total' => $total,
        'admin_id' => $admin_id
    );
    file_put_contents('order_debug.log', date('Y-m-d H:i:s') . " - Order data: " . json_encode($values) . " - Types: $types\n", FILE_APPEND);

    if (!$stmt_order->bind_param(
        $types, 
        $data['user_id'], 
        $data['payment_method'], 
        $data['shipping_method'], 
        $data['shipping_cost'], 
        $total,
        $admin_id
    )) {
        throw new Exception("Binding parameters failed for order insertion: (" . $stmt_order->errno . ") " . $stmt_order->error);
    }

    if (!$stmt_order->execute()) {
        throw new Exception("Execute failed for order insertion: (" . $stmt_order->errno . ") " . $stmt_order->error);
    }
    
    // Get the auto-incremented order ID
    $id_order = $stmt_order->insert_id;
    if ($id_order === 0) {
        throw new Exception("Failed to get insert ID after order creation");
    }
    
    // Close the statement
    $stmt_order->close();
    
    // Link the shipping address to the order if available
    if (!empty($shipping_data) && isset($shipping_data['id'])) {
        // Try to insert a relationship record in a potential order_shipping_address table
        try {
            $sql_link_address = "INSERT INTO order_shipping_address (order_id, shipping_address_id) VALUES (?, ?)";
            $stmt_link = $conn->prepare($sql_link_address);
            if ($stmt_link) {
                $stmt_link->bind_param("ii", $id_order, $shipping_data['id']);
                $stmt_link->execute();
                $stmt_link->close();
                file_put_contents('order_debug.log', date('Y-m-d H:i:s') . " - Successfully linked order {$id_order} with shipping address {$shipping_data['id']}\n", FILE_APPEND);
            }
        } catch (Exception $e) {
            // If this fails, it might be because the table doesn't exist - just log and continue
            file_put_contents('order_debug.log', date('Y-m-d H:i:s') . " - Note: Could not link order with shipping address: " . $e->getMessage() . "\n", FILE_APPEND);
        }
    }
    
    // Insert order items
    $sql_item = "INSERT INTO detail_order (id_order, id_product, jumlah, harga_satuan) 
                VALUES (?, ?, ?, ?)";
    $stmt_item = $conn->prepare($sql_item);
    if (!$stmt_item) {
        throw new Exception("Error preparing order items insertion: " . $conn->error);
    }

    foreach ($data['items'] as $item) {
        try {
            // Update product stock (subtract quantity)
            $update_stock = "UPDATE product SET stok = stok - ? WHERE id_product = ?";
            $stmt_stock = $conn->prepare($update_stock);
            if (!$stmt_stock) {
                throw new Exception("Error preparing stock update: " . $conn->error);
            }
            $stmt_stock->bind_param("ii", $item['quantity'], $item['product_id']);
            if (!$stmt_stock->execute()) {
                throw new Exception("Error updating stock for product {$item['product_id']}: " . $stmt_stock->error);
            }
            
            // Add to order details
            $stmt_item->bind_param(
                "iiid", 
                $id_order, 
                $item['product_id'], 
                $item['quantity'], 
                $item['price']
            );
            if (!$stmt_item->execute()) {
                throw new Exception("Error inserting order item for product {$item['product_id']}: " . $stmt_item->error);
            }
        } catch (Exception $e) {
            // Log the error for this item but continue with others
            file_put_contents('order_debug.log', date('Y-m-d H:i:s') . " - Error with item {$item['product_id']}: " . $e->getMessage() . "\n", FILE_APPEND);
        }
    }
    
    // Clear cart items for this user
    $sql_clear_cart = "DELETE FROM cart WHERE id_user = ?";
    $stmt_clear_cart = $conn->prepare($sql_clear_cart);
    if (!$stmt_clear_cart) {
        // Just log this error but don't fail the whole transaction
        file_put_contents('order_debug.log', date('Y-m-d H:i:s') . " - Warning: Error preparing cart clearing: " . $conn->error . "\n", FILE_APPEND);
    } else {
        $stmt_clear_cart->bind_param("i", $data['user_id']);
        if (!$stmt_clear_cart->execute()) {
            // Just log this error but don't fail the whole transaction
            file_put_contents('order_debug.log', date('Y-m-d H:i:s') . " - Warning: Error clearing cart: " . $stmt_clear_cart->error . "\n", FILE_APPEND);
        }
    }
    
    // Commit transaction
    $conn->commit();
    
    // Handle payment method specific logic
    $payment_url = null;
    if ($data['payment_method'] === 'midtrans') {
        // Check if Midtrans library is installed
        if (!file_exists('../vendor/autoload.php')) {
            error_log("Midtrans library not found. Using mock payment URL.");
            $payment_url = "https://admin.hijauloka.my.id/payment.php?order_id=" . $id_order;
        } else {
            // Integrate with Midtrans API
            require_once '../vendor/autoload.php';
            
            // Set your Midtrans server key
            \Midtrans\Config::$serverKey = 'SB-Mid-server-cHC4Z3JHh_Z8dHnQ8f4kK89x';
            // Set to Development/Sandbox Environment (default). Set to true for Production Environment (accept real transaction).
            \Midtrans\Config::$isProduction = false;
            // Set sanitization on (default)
            \Midtrans\Config::$isSanitized = true;
            // Set 3DS transaction for credit card to true
            \Midtrans\Config::$is3ds = true;
            
            // Get user details
            $sql_user = "SELECT * FROM user WHERE id_user = ?";
            $stmt_user = $conn->prepare($sql_user);
            $stmt_user->bind_param("i", $data['user_id']);
            $stmt_user->execute();
            $user_result = $stmt_user->get_result();
            $user = $user_result->fetch_assoc();
            
            if (!$user) {
                throw new Exception('User not found');
            }
            
            // Prepare shipping address for Midtrans
            $shipping_address = [
                'first_name' => $shipping_data['recipient_name'] ?? ($user['nama'] ?? 'Customer'),
                'phone' => $shipping_data['phone'] ?? ($user['no_tlp'] ?? ''),
                'address' => isset($shipping_data['address']) ? 
                    ($shipping_data['address'] . 
                     (isset($shipping_data['rt']) && !empty($shipping_data['rt']) ? ', RT ' . $shipping_data['rt'] : '') . 
                     (isset($shipping_data['rw']) && !empty($shipping_data['rw']) ? '/RW ' . $shipping_data['rw'] : '') . 
                     (isset($shipping_data['house_number']) && !empty($shipping_data['house_number']) ? ', No. ' . $shipping_data['house_number'] : '') .
                     (isset($shipping_data['detail_address']) && !empty($shipping_data['detail_address']) ? ' (' . $shipping_data['detail_address'] . ')' : '')) 
                    : ($user['alamat'] ?? 'No address provided'),
                'city' => 'Bandung', // Default city
                'postal_code' => isset($shipping_data['postal_code']) && !empty($shipping_data['postal_code']) ? $shipping_data['postal_code'] : '40000', // Default postal code
                'country_code' => 'IDN'
            ];
            
            // Prepare customer details
            $customer_details = [
                'first_name' => $user['nama'] ?? 'Customer',
                'email' => $user['email'] ?? '',
                'phone' => $shipping_data['phone'] ?? ($user['no_tlp'] ?? ''),
                'billing_address' => [
                    'first_name' => $shipping_data['recipient_name'] ?? ($user['nama'] ?? 'Customer'),
                    'phone' => $shipping_data['phone'] ?? ($user['no_tlp'] ?? ''),
                    'address' => isset($shipping_data['address']) ? 
                        ($shipping_data['address'] . 
                         (isset($shipping_data['rt']) && !empty($shipping_data['rt']) ? ', RT ' . $shipping_data['rt'] : '') . 
                         (isset($shipping_data['rw']) && !empty($shipping_data['rw']) ? '/RW ' . $shipping_data['rw'] : '') . 
                         (isset($shipping_data['house_number']) && !empty($shipping_data['house_number']) ? ', No. ' . $shipping_data['house_number'] : '') .
                         (isset($shipping_data['detail_address']) && !empty($shipping_data['detail_address']) ? ' (' . $shipping_data['detail_address'] . ')' : '')) 
                        : ($user['alamat'] ?? 'No address provided'),
                    'city' => 'Bandung', // Default city
                    'postal_code' => isset($shipping_data['postal_code']) && !empty($shipping_data['postal_code']) ? $shipping_data['postal_code'] : '40000', // Default postal code
                    'country_code' => 'IDN'
                ],
                'shipping_address' => $shipping_address
            ];
            
            // Prepare item details
            $item_details = [];
            foreach ($data['items'] as $item) {
                // Get product details
                $sql_product = "SELECT * FROM product WHERE id_product = ?";
                $stmt_product = $conn->prepare($sql_product);
                $stmt_product->bind_param("i", $item['product_id']);
                $stmt_product->execute();
                $product_result = $stmt_product->get_result();
                $product = $product_result->fetch_assoc();
                
                if ($product) {
                    $item_details[] = [
                        'id' => $item['product_id'],
                        'price' => (int)$item['price'],
                        'quantity' => (int)$item['quantity'],
                        'name' => $product['nama_product'] ?? 'Product #' . $item['product_id']
                    ];
                }
            }
            
            // Add shipping cost as an item
            $item_details[] = [
                'id' => 'SHIPPING',
                'price' => (int)$data['shipping_cost'],
                'quantity' => 1,
                'name' => 'Shipping Cost (' . $data['shipping_method'] . ')'
            ];
            
            // Create Midtrans transaction parameters
            $params = [
                'transaction_details' => [
                    'order_id' => $id_order,
                    'gross_amount' => (int)$data['total']
                ],
                'customer_details' => $customer_details,
                'item_details' => $item_details,
            ];
            
            try {
                // Create Snap transaction
                $snap_token = \Midtrans\Snap::getSnapToken($params);
                $payment_url = \Midtrans\Snap::getSnapUrl($params);
                
                // Update order with snap token
                $sql_update_order = "UPDATE orders SET midtrans_order_id = ? WHERE id_order = ?";
                $stmt_update = $conn->prepare($sql_update_order);
                $stmt_update->bind_param("si", $snap_token, $id_order);
                $stmt_update->execute();
                
            } catch (\Exception $e) {
                // If Midtrans integration fails, still return success but with a note
                error_log('Midtrans Error: ' . $e->getMessage());
                
                // For testing purposes, create a mock payment URL
                $payment_url = "https://admin.hijauloka.my.id/payment.php?order_id=" . $id_order;
            }
        }
    } elseif ($data['payment_method'] === 'cod') {
        // For COD, no payment URL is needed
        $payment_url = null;
    }
    
    // Log successful order creation
    file_put_contents('order_debug.log', date('Y-m-d H:i:s') . " - Order created successfully. id_order: {$id_order}\n", FILE_APPEND);

    // Return success response
    echo json_encode([
        'success' => true, 
        'message' => 'Order created successfully', 
        'order_id' => $id_order,
        'payment_url' => $payment_url
    ]);
    
} catch (Exception $e) {
    // Rollback transaction on error
    if (isset($conn) && $conn !== null) {
        $conn->rollback();
    }
    
    // Log the error with stacktrace
    $errorMessage = $e->getMessage();
    $stackTrace = $e->getTraceAsString();
    file_put_contents('order_debug.log', date('Y-m-d H:i:s') . " - Error creating order: {$errorMessage}\nStack trace: {$stackTrace}\n", FILE_APPEND);
    
    // Return error response with more details for debugging
    http_response_code(500);
    echo json_encode([
        'success' => false, 
        'message' => 'Error creating order: ' . $errorMessage,
        'error_code' => $e->getCode(),
        'debug_info' => 'Please check server logs for more details. Error occurred at ' . date('Y-m-d H:i:s')
    ]);
}

// Close connection
if (isset($conn) && $conn !== null) {
    $conn->close();
}
?>