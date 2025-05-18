<?php
// Set headers
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Database connection
$host = "localhost";
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

// Validate input
if ($id_cart <= 0) {
    $response = [
        'success' => false,
        'message' => 'Invalid cart ID.',
        'data' => null
    ];
    echo json_encode($response);
    exit();
}

// Check if cart item exists
$check_cart = $conn->prepare("SELECT id_cart FROM cart WHERE id_cart = ?");
$check_cart->bind_param("i", $id_cart);
$check_cart->execute();
$cart_result = $check_cart->get_result();

if ($cart_result->num_rows === 0) {
    $response = [
        'success' => false,
        'message' => 'Cart item not found.',
        'data' => null
    ];
    echo json_encode($response);
    exit();
}

// Delete cart item
$delete_cart = $conn->prepare("DELETE FROM cart WHERE id_cart = ?");
$delete_cart->bind_param("i", $id_cart);

if ($delete_cart->execute()) {
    $response = [
        'success' => true,
        'message' => 'Item removed from cart successfully.',
        'data' => null
    ];
} else {
    $response = [
        'success' => false,
        'message' => 'Failed to remove item from cart: ' . $conn->error,
        'data' => null
    ];
}

// Close prepared statements
$check_cart->close();
$delete_cart->close();

// Close connection
$conn->close();

// Return response
echo json_encode($response);
?>