<?php
// Headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
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

// Get posted data
$data = json_decode(file_get_contents("php://input"));

// Check if id is provided
if (!isset($data->id)) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "Address ID is required"));
    exit();
}

// Check if the address exists and is not primary
$query = "SELECT is_primary FROM shipping_addresses WHERE id = ?";
$stmt = $db->prepare($query);
$stmt->bindParam(1, $data->id);
$stmt->execute();
$row = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$row) {
    http_response_code(404);
    echo json_encode(array("success" => false, "message" => "Address not found"));
    exit();
}

if ($row['is_primary'] == 1) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "Cannot delete primary address. Please set another address as primary first."));
    exit();
}

// Delete the address
$query = "DELETE FROM shipping_addresses WHERE id = ?";
$stmt = $db->prepare($query);
$stmt->bindParam(1, $data->id);

// Execute query
if ($stmt->execute()) {
    http_response_code(200);
    echo json_encode(array("success" => true, "message" => "Address deleted successfully"));
} else {
    http_response_code(503);
    echo json_encode(array("success" => false, "message" => "Unable to delete address"));
}
?>