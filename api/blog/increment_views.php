<?php
// header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
// header("Access-Control-Allow-Methods: POST");
// header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(array("message" => "Method not allowed"));
    exit();
}

if (!isset($_POST['post_id'])) {
    http_response_code(400);
    echo json_encode(array("message" => "Post ID is required"));
    exit();
}

$postId = $_POST['post_id'];

try {
    $query = "UPDATE blog_posts SET views = views + 1 WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":id", $postId);
    
    if ($stmt->execute()) {
        http_response_code(200);
        echo json_encode(array("message" => "View count updated"));
    } else {
        http_response_code(500);
        echo json_encode(array("message" => "Failed to update view count"));
    }
} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode(array("message" => "Error: " . $e->getMessage()));
}
?> 