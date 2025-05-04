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
if(!empty($data->email) && !empty($data->password)) {
    // Set user property values
    $user->email = $data->email;
    $user->password = $data->password;

    // Login user
    if($user->login()) {
        // Response code
        http_response_code(200);
        
        // Create user array
        $user_arr = array(
            "id_user" => $user->id_user,
            "nama" => $user->nama,
            "email" => $user->email,
            "alamat" => $user->alamat,
            "shipping_address" => $user->shipping_address,
            "no_tlp" => $user->no_tlp,
            "profile_image" => $user->profile_image
        );
        
        // Tell the user
        echo json_encode(array(
            "message" => "Login successful.",
            "user" => $user_arr
        ));
    } else {
        // Response code
        http_response_code(401);
        
        // Tell the user
        echo json_encode(array("message" => "Login failed. Invalid email or password."));
    }
} else {
    // Response code
    http_response_code(400);
    
    // Tell the user
    echo json_encode(array("message" => "Unable to login. Data is incomplete."));
}
?>