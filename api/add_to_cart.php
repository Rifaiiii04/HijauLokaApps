<?php
// Set headers
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Database connection
$host = "localhost";
$username = "hijc7862_admin"; // Updated username
$password = "wyn[=?alPV%."; // Updated password
$database = "hijc7862_hijauloka"; // Updated database name

// Create connection
$conn = new mysqli($host, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    $response = [
        'success' => false,
        'message' => 'Database connection failed: ' . $conn->connect_error,
        'data' => null
    ];
    echo json_encode($response);
    exit();
}

// Set UTF-8 encoding
$conn->set_charset("utf8");

// Check if request method is POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $response = [
        'success' => false,
        'message' => 'Invalid request method. Only POST is allowed.',
        'data' => null
    ];
    echo json_encode($response);
    exit();
}

// Get POST data
$id_user = isset($_POST['id_user']) ? intval($_POST['id_user']) : 0;
$id_product = isset($_POST['id_product']) ? intval($_POST['id_product']) : 0;
$jumlah = isset($_POST['jumlah']) ? intval($_POST['jumlah']) : 1;

// Validate input
if ($id_product <= 0 || $jumlah <= 0) {
    $response = [
        'success' => false,
        'message' => 'Invalid input parameters.',
        'data' => null
    ];
    echo json_encode($response);
    exit();
}

// Check if product exists
$check_product = $conn->prepare("SELECT id_product, stok FROM product WHERE id_product = ?");
$check_product->bind_param("i", $id_product);
$check_product->execute();
$product_result = $check_product->get_result();

if ($product_result->num_rows === 0) {
    $response = [
        'success' => false,
        'message' => 'Product not found.',
        'data' => null
    ];
    echo json_encode($response);
    exit();
}

$product_data = $product_result->fetch_assoc();
$stock = $product_data['stok'];

// Check if there's enough stock
if ($stock < $jumlah) {
    $response = [
        'success' => false,
        'message' => 'Not enough stock available. Only ' . $stock . ' items left.',
        'data' => null
    ];
    echo json_encode($response);
    exit();
}

// Modified user check - if user doesn't exist, create a temporary one
$user_exists = false;
if ($id_user > 0) {
    $check_user = $conn->prepare("SELECT id_user FROM user WHERE id_user = ?");
    $check_user->bind_param("i", $id_user);
    $check_user->execute();
    $user_result = $check_user->get_result();
    
    if ($user_result->num_rows > 0) {
        $user_exists = true;
    } else {
        // Create a temporary user for testing
        $temp_name = "Temporary User";
        $temp_email = "temp_" . time() . "@example.com";
        $temp_password = password_hash("temppass", PASSWORD_DEFAULT);
        $temp_alamat = "Temporary Address"; // Add required alamat field
        $temp_no_tlp = "0000000000"; // Add required no_tlp field
        
        $insert_user = $conn->prepare("INSERT INTO user (nama, email, password, alamat, no_tlp) VALUES (?, ?, ?, ?, ?)");
        $insert_user->bind_param("sssss", $temp_name, $temp_email, $temp_password, $temp_alamat, $temp_no_tlp);
        
        if ($insert_user->execute()) {
            $id_user = $conn->insert_id;
            $user_exists = true;
            $insert_user->close();
        }
    }
    
    if (isset($check_user)) {
        $check_user->close();
    }
}

if (!$user_exists) {
    // If we still don't have a valid user, create a guest user
    $guest_name = "Guest User";
    $guest_email = "guest_" . time() . "@example.com";
    $guest_password = password_hash("guestpass", PASSWORD_DEFAULT);
    $guest_alamat = "Guest Address"; // Add required alamat field
    $guest_no_tlp = "0000000000"; // Add required no_tlp field
    
    $insert_guest = $conn->prepare("INSERT INTO user (nama, email, password, alamat, no_tlp) VALUES (?, ?, ?, ?, ?)");
    $insert_guest->bind_param("sssss", $guest_name, $guest_email, $guest_password, $guest_alamat, $guest_no_tlp);
    
    if ($insert_guest->execute()) {
        $id_user = $conn->insert_id;
        $insert_guest->close();
    } else {
        $response = [
            'success' => false,
            'message' => 'Failed to create guest user: ' . $conn->error,
            'data' => null
        ];
        echo json_encode($response);
        exit();
    }
}

// Check if item already exists in cart
$check_cart = $conn->prepare("SELECT id_cart, jumlah FROM cart WHERE id_user = ? AND id_product = ?");
$check_cart->bind_param("ii", $id_user, $id_product);
$check_cart->execute();
$cart_result = $check_cart->get_result();

if ($cart_result->num_rows > 0) {
    // Update existing cart item
    $cart_data = $cart_result->fetch_assoc();
    $new_quantity = $cart_data['jumlah'] + $jumlah;
    
    // Check if new quantity exceeds stock
    if ($new_quantity > $stock) {
        $response = [
            'success' => false,
            'message' => 'Cannot add more items. Stock limit reached.',
            'data' => null
        ];
        echo json_encode($response);
        exit();
    }
    
    $update_cart = $conn->prepare("UPDATE cart SET jumlah = ? WHERE id_cart = ?");
    $update_cart->bind_param("ii", $new_quantity, $cart_data['id_cart']);
    
    if ($update_cart->execute()) {
        $response = [
            'success' => true,
            'message' => 'Cart updated successfully.',
            'data' => [
                'id_cart' => $cart_data['id_cart'],
                'id_user' => $id_user,
                'id_product' => $id_product,
                'jumlah' => $new_quantity
            ]
        ];
    } else {
        $response = [
            'success' => false,
            'message' => 'Failed to update cart: ' . $conn->error,
            'data' => null
        ];
    }
} else {
    // Add new cart item
    $insert_cart = $conn->prepare("INSERT INTO cart (id_user, id_product, jumlah) VALUES (?, ?, ?)");
    $insert_cart->bind_param("iii", $id_user, $id_product, $jumlah);
    
    if ($insert_cart->execute()) {
        $cart_id = $conn->insert_id;
        $response = [
            'success' => true,
            'message' => 'Product added to cart successfully.',
            'data' => [
                'id_cart' => $cart_id,
                'id_user' => $id_user,
                'id_product' => $id_product,
                'jumlah' => $jumlah
            ]
        ];
    } else {
        $response = [
            'success' => false,
            'message' => 'Failed to add product to cart: ' . $conn->error,
            'data' => null
        ];
    }
}

// Close prepared statements
$check_product->close();
$check_cart->close();

// Close connection
$conn->close();

// Return response
echo json_encode($response);
?>