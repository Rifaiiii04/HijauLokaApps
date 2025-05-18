<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

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
              WHERE p.status = 'published'
              GROUP BY p.id
              ORDER BY p.created_at DESC";

    $stmt = $db->prepare($query);
    $stmt->execute();
    $posts = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Process tags
    foreach ($posts as &$post) {
        $post['tags'] = $post['tags'] ? explode(',', $post['tags']) : [];
    }

    http_response_code(200);
    echo json_encode($posts);
} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode(array("message" => "Error: " . $e->getMessage()));
}
?> 