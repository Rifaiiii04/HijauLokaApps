<?php
// CORS Headers
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

// Include database and user model
include_once '../config/database.php';
include_once '../models/user.php';

// Get database connection
$database = new Database();
$db = $database->getConnection();

// Create user object
$user = new User($db);

// Get posted data
$data = json_decode(file_get_contents("php://input"));

// Make sure data is not empty
if(
    !empty($data->nama) &&
    !empty($data->email) &&
    !empty($data->password) &&
    !empty($data->alamat) &&
    !empty($data->no_tlp)
) {
    // Set user property values
    $user->nama = $data->nama;
    $user->email = $data->email;
    $user->password = $data->password;
    $user->alamat = $data->alamat;
    $user->no_tlp = $data->no_tlp;

    // Check if email already exists
    if($user->emailExists()) {
        // Response code
        http_response_code(400);
        
        // Tell the user
        echo json_encode(array("message" => "Email already exists."));
    } else {
        // Create the user
        if($user->create()) {
            // Response code
            http_response_code(201);
            
            // Tell the user
            echo json_encode(array("message" => "User was created."));
        } else {
            // Response code
            http_response_code(503);
            
            // Tell the user
            echo json_encode(array("message" => "Unable to create user."));
        }
    }
} else {
    // Response code
    http_response_code(400);
    
    // Tell the user
    echo json_encode(array("message" => "Unable to create user. Data is incomplete."));
}
?>