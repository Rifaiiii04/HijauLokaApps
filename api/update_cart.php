<?php
// Set headers
header('Content-Type: application/json; charset=utf-8');
// header('Access-Control-Allow-Origin: *');
// header('Access-Control-Allow-Methods: POST');
// header('Access-Control-Allow-Headers: Content-Type');

// Database connection
$host = "103.247.11.220";
$username = "hijc7862_admin";
$password = "wyn[=?alPV%.";
$database = "hijc7862_hijauloka";

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
$id_cart = isset($_POST['id_cart']) ? intval($_POST['id_cart']) : 0;
$jumlah = isset($_POST['jumlah']) ? intval($_POST['jumlah']) : 0;

// Validate input
if ($id_cart <= 0 || $jumlah <= 0) {
    $response = [
        'success' => false,
        'message' => 'Invalid input parameters.',
        'data' => null
    ];
    echo json_encode($response);
    exit();
}

// Get cart item and product details
$get_cart = $conn->prepare("
    SELECT c.id_cart, c.id_user, c.id_product, p.stok 
    FROM cart c
    JOIN product p ON c.id_product = p.id_product
    WHERE c.id_cart = ?
");
$get_cart->bind_param("i", $id_cart);
$get_cart->execute();
$cart_result = $get_cart->get_result();

if ($cart_result->num_rows === 0) {
    $response = [
        'success' => false,
        'message' => 'Cart item not found.',
        'data' => null
    ];
    echo json_encode($response);
    exit();
}

$cart_data = $cart_result->fetch_assoc();
$stock = $cart_data['stok'];

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

// Update cart quantity
$update_cart = $conn->prepare("UPDATE cart SET jumlah = ? WHERE id_cart = ?");
$update_cart->bind_param("ii", $jumlah, $id_cart);

if ($update_cart->execute()) {
    $response = [
        'success' => true,
        'message' => 'Cart updated successfully.',
        'data' => [
            'id_cart' => $id_cart,
            'id_user' => $cart_data['id_user'],
            'id_product' => $cart_data['id_product'],
            'jumlah' => $jumlah
        ]
    ];
} else {
    $response = [
        'success' => false,
        'message' => 'Failed to update cart: ' . $conn->error,
        'data' => null
    ];
}

// Close prepared statements
$get_cart->close();
$update_cart->close();

// Close connection
$conn->close();

// Return response
echo json_encode($response);
?>