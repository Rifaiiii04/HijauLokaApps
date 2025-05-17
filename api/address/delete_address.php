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
if (!isset($data->id) || !isset($data->user_id)) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "Address ID and User ID are required"));
    exit();
}

// Check if address exists and belongs to the user
$query = "SELECT * FROM shipping_addresses WHERE id = ? AND user_id = ?";
$stmt = $db->prepare($query);
$stmt->bindParam(1, $data->id);
$stmt->bindParam(2, $data->user_id);
$stmt->execute();

if ($stmt->rowCount() == 0) {
    http_response_code(404);
    echo json_encode(array("success" => false, "message" => "Address not found or does not belong to the user"));
    exit();
}

// Get the address to check if it's primary
$address = $stmt->fetch(PDO::FETCH_ASSOC);
$is_primary = $address['is_primary'];

// Begin transaction
$db->beginTransaction();

try {
    // Delete the address
    $query = "DELETE FROM shipping_addresses WHERE id = ?";
    $stmt = $db->prepare($query);
    $stmt->bindParam(1, $data->id);
    
    if (!$stmt->execute()) {
        throw new Exception("Failed to delete address");
    }
    
    // If the deleted address was primary, set another address as primary
    if ($is_primary == 1) {
        // Find another address for this user
        $query = "SELECT id FROM shipping_addresses WHERE user_id = ? LIMIT 1";
        $stmt = $db->prepare($query);
        $stmt->bindParam(1, $data->user_id);
        $stmt->execute();
        
        if ($stmt->rowCount() > 0) {
            $new_primary = $stmt->fetch(PDO::FETCH_ASSOC);
            
            // Set as primary
            $query = "UPDATE shipping_addresses SET is_primary = 1 WHERE id = ?";
            $stmt = $db->prepare($query);
            $stmt->bindParam(1, $new_primary['id']);
            
            if (!$stmt->execute()) {
                throw new Exception("Failed to set new primary address");
            }
        }
    }
    
    // Commit transaction
    $db->commit();
    
    http_response_code(200);
    echo json_encode(array("success" => true, "message" => "Address deleted successfully"));
} catch (Exception $e) {
    // Rollback transaction
    $db->rollBack();
    
    http_response_code(503);
    echo json_encode(array("success" => false, "message" => $e->getMessage()));
}
?>