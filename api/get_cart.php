<?php
// Set headers
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
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

// Check if request method is GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    $response = [
        'success' => false,
        'message' => 'Invalid request method. Only GET is allowed.',
        'data' => null
    ];
    echo json_encode($response);
    exit();
}

// Get user ID from query parameter
$id_user = isset($_GET['id_user']) ? intval($_GET['id_user']) : 0;

// Validate input
if ($id_user <= 0) {
    $response = [
        'success' => false,
        'message' => 'Invalid user ID.',
        'data' => null
    ];
    echo json_encode($response);
    exit();
}

// Check if user exists
$check_user = $conn->prepare("SELECT id_user FROM user WHERE id_user = ?");
$check_user->bind_param("i", $id_user);
$check_user->execute();
$user_result = $check_user->get_result();

if ($user_result->num_rows === 0) {
    $response = [
        'success' => false,
        'message' => 'User not found.',
        'data' => null
    ];
    echo json_encode($response);
    exit();
}

// Get cart items with product details
$get_cart = $conn->prepare("
    SELECT c.id_cart, c.id_user, c.id_product, c.jumlah, 
           p.nama_product, p.harga, p.stok, p.gambar, p.rating
    FROM cart c
    JOIN product p ON c.id_product = p.id_product
    WHERE c.id_user = ?
");
$get_cart->bind_param("i", $id_user);
$get_cart->execute();
$cart_result = $get_cart->get_result();

$cart_items = [];
while ($row = $cart_result->fetch_assoc()) {
    $cart_items[] = [
        'id_cart' => $row['id_cart'],
        'id_user' => $row['id_user'],
        'id_product' => $row['id_product'],
        'jumlah' => $row['jumlah'],
        'product' => [
            'id_product' => $row['id_product'],
            'nama_product' => $row['nama_product'],
            'harga' => $row['harga'],
            'stok' => $row['stok'],
            'gambar' => $row['gambar'],
            'rating' => $row['rating'],
            'image_url' => 'https://admin.hijauloka.my.id/uploads/' . $row['gambar']
        ]
    ];
}

// Close prepared statements
$check_user->close();
$get_cart->close();

// Close connection
$conn->close();

// Return response
$response = [
    'success' => true,
    'message' => 'Cart items retrieved successfully.',
    'data' => $cart_items
];
echo json_encode($response);
?>