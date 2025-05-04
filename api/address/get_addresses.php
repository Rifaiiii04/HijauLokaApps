<?php
// Headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Include database
include_once '../config/database.php';

// Get database connection
$database = new Database();
$db = $database->getConnection();

// Check if user_id is provided
if (!isset($_GET['user_id'])) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "User ID is required"));
    exit();
}

$user_id = $_GET['user_id'];

// Get all shipping addresses for the user
$query = "SELECT * FROM shipping_addresses WHERE user_id = ? ORDER BY is_primary DESC, created_at DESC";
$stmt = $db->prepare($query);
$stmt->bindParam(1, $user_id);
$stmt->execute();

$addresses = array();

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $addresses[] = $row;
}

// Return the addresses
http_response_code(200);
echo json_encode(array("success" => true, "addresses" => $addresses));
?>