<?php
// Set headers
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');

// Check if ID is provided
if (!isset($_GET['id']) || empty($_GET['id'])) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Product ID is required'
    ]);
    exit;
}

$id = intval($_GET['id']);

try {
    // Database configuration directly in this file
    $host = "localhost";
    $db_name = "hijauloka";
    $username = "root";
    $password = "";
    
    // Create connection
    $conn = new PDO("mysql:host=" . $host . ";dbname=" . $db_name, $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $conn->exec("set names utf8");
    
    // Get product details with category information
    $query = "
        SELECT p.*, GROUP_CONCAT(k.nama_kategori SEPARATOR ', ') as kategori
        FROM product p
        LEFT JOIN product_category pc ON p.id_product = pc.id_product
        LEFT JOIN category k ON pc.id_kategori = k.id_kategori
        WHERE p.id_product = ?
        GROUP BY p.id_product
    ";
    
    $stmt = $conn->prepare($query);
    $stmt->bindParam(1, $id);
    $stmt->execute();
    
    if ($stmt->rowCount() === 0) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Product not found'
        ]);
        exit;
    }
    
    $product = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Get reviews for this product with user information
    $reviewQuery = "
        SELECT r.*, u.nama as username, u.profile_image
        FROM review_rating r
        JOIN user u ON r.id_user = u.id_user
        WHERE r.id_product = ? AND r.stts_review = 'disetujui'
        ORDER BY r.tgl_review DESC
    ";
    
    $reviewStmt = $conn->prepare($reviewQuery);
    $reviewStmt->bindParam(1, $id);
    $reviewStmt->execute();
    
    $reviews = [];
    while ($review = $reviewStmt->fetch(PDO::FETCH_ASSOC)) {
        $reviews[] = $review;
    }
    
    // Add reviews to product data
    $product['reviews'] = $reviews;
    
    echo json_encode([
        'status' => 'success',
        'data' => $product
    ], JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Database error: ' . $e->getMessage()
    ]);
}
?>