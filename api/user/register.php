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
if (
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

    // Register user
    if ($user->create()) {
        // Response code
        http_response_code(201);

        // Create user array (optional, bisa dihilangkan jika tidak ingin mengirim data user)
        $user_arr = array(
            "id_user" => $user->id_user,
            "nama" => $user->nama,
            "email" => $user->email,
            "alamat" => $user->alamat,
            "no_tlp" => $user->no_tlp,
            "profile_image" => $user->profile_image
        );

        // Tell the user
        echo json_encode(array(
            "success" => true,
            "message" => "Registration successful.",
            "user" => $user_arr
        ));
    } else {
        // Response code
        http_response_code(400);

        // Tell the user
        echo json_encode(array(
            "success" => false,
            "message" => "Registration failed. Email may already be registered."
        ));
    }
} else {
    // Response code
    http_response_code(400);

    // Tell the user
    echo json_encode(array(
        "success" => false,
        "message" => "Unable to register. Data is incomplete."
    ));
}
?>