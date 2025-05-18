<?php
// header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

if (!isset($_GET['slug'])) {
    http_response_code(400);
    echo json_encode(array("message" => "Slug parameter is required"));
    exit();
}

$slug = $_GET['slug'];

try {
    $query = "SELECT 
                p.*,
                c.name as category_name,
                u.nama as author_name,
                GROUP_CONCAT(t.name) as tags
              FROM blog_posts p
              LEFT JOIN blog_categories c ON p.category_id = c.id
              LEFT JOIN user u ON p.author_id = u.id_user
              LEFT JOIN blog_post_tags pt ON p.id = pt.post_id
              LEFT JOIN blog_tags t ON pt.tag_id = t.id
              WHERE p.slug = :slug AND p.status = 'published'
              GROUP BY p.id";

    $stmt = $db->prepare($query);
    $stmt->bindParam(":slug", $slug);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        $post = $stmt->fetch(PDO::FETCH_ASSOC);
        $post['tags'] = $post['tags'] ? explode(',', $post['tags']) : [];

        // Increment views
        $updateQuery = "UPDATE blog_posts SET views = views + 1 WHERE id = :id";
        $updateStmt = $db->prepare($updateQuery);
        $updateStmt->bindParam(":id", $post['id']);
        $updateStmt->execute();

        http_response_code(200);
        echo json_encode($post);
    } else {
        http_response_code(404);
        echo json_encode(array("message" => "Post not found"));
    }
} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode(array("message" => "Error: " . $e->getMessage()));
}
?> 