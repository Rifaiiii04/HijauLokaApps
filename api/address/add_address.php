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

// Check if required fields are provided
if (!isset($data->user_id) || !isset($data->recipient_name) || !isset($data->phone) || !isset($data->address)) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "Required fields are missing"));
    exit();
}

// Check if this is the first address for the user (should be primary)
$query = "SELECT COUNT(*) as count FROM shipping_addresses WHERE user_id = ?";
$stmt = $db->prepare($query);
$stmt->bindParam(1, $data->user_id);
$stmt->execute();
$row = $stmt->fetch(PDO::FETCH_ASSOC);

$is_primary = $row['count'] == 0 ? 1 : ($data->is_primary ?? 0);

// If setting as primary, update all other addresses to non-primary
if ($is_primary == 1) {
    $update_query = "UPDATE shipping_addresses SET is_primary = 0 WHERE user_id = ?";
    $update_stmt = $db->prepare($update_query);
    $update_stmt->bindParam(1, $data->user_id);
    $update_stmt->execute();
}

// Insert the new address
$query = "INSERT INTO shipping_addresses 
          (user_id, recipient_name, phone, address_label, address, rt, rw, house_number, postal_code, detail_address, is_primary) 
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

$stmt = $db->prepare($query);

// Bind parameters
$stmt->bindParam(1, $data->user_id);
$stmt->bindParam(2, $data->recipient_name);
$stmt->bindParam(3, $data->phone);
$stmt->bindParam(4, $data->address_label);
$stmt->bindParam(5, $data->address);
$stmt->bindParam(6, $data->rt);
$stmt->bindParam(7, $data->rw);
$stmt->bindParam(8, $data->house_number);
$stmt->bindParam(9, $data->postal_code);
$stmt->bindParam(10, $data->detail_address);
$stmt->bindParam(11, $is_primary);

// Execute query
if ($stmt->execute()) {
    http_response_code(201);
    echo json_encode(array("success" => true, "message" => "Address added successfully"));
} else {
    http_response_code(503);
    echo json_encode(array("success" => false, "message" => "Unable to add address"));
}
?>