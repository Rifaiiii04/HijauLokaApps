<?php
// Headers
// header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
// header("Access-Control-Allow-Methods: POST, OPTIONS");
// header("Access-Control-Max-Age: 3600");
// header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

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
if (!isset($data->id) || !isset($data->user_id)) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "Address ID and User ID are required"));
    exit();
}

// Begin transaction
$db->beginTransaction();

try {
    // Set all addresses for this user to non-primary
    $query = "UPDATE shipping_addresses SET is_primary = 0 WHERE user_id = ?";
    $stmt = $db->prepare($query);
    $stmt->bindParam(1, $data->user_id);
    $stmt->execute();

    // Set the selected address as primary
    $query = "UPDATE shipping_addresses SET is_primary = 1 WHERE id = ? AND user_id = ?";
    $stmt = $db->prepare($query);
    $stmt->bindParam(1, $data->id);
    $stmt->bindParam(2, $data->user_id);
    $stmt->execute();

    // Check if the address was updated
    if ($stmt->rowCount() == 0) {
        throw new Exception("Address not found or does not belong to the user");
    }

    // Commit transaction
    $db->commit();

    http_response_code(200);
    echo json_encode(array("success" => true, "message" => "Address set as primary successfully"));
} catch (Exception $e) {
    // Rollback transaction
    $db->rollBack();
    
    http_response_code(503);
    echo json_encode(array("success" => false, "message" => $e->getMessage()));
}
?>