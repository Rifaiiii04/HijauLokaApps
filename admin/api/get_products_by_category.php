<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type, Accept-Charset');

require_once 'config/database.php';

try {
    // Get category ID from query parameter
    $category_id = isset($_GET['category_id']) ? intval($_GET['category_id']) : 0;

    if ($category_id <= 0) {
        throw new Exception('Invalid category ID');
    }

    // Prepare and execute the query
    $query = "SELECT p.*, c.nama_kategori as category_name 
              FROM products p 
              LEFT JOIN kategori c ON p.id_kategori = c.id_kategori 
              WHERE p.id_kategori = ? AND p.is_active = 1 
              ORDER BY p.created_at DESC";
              
    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $category_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $products = array();
    while ($row = $result->fetch_assoc()) {
        // Format the product data
        $product = array(
            'id' => $row['id_product'],
            'name' => $row['nama_product'],
            'description' => $row['desk_product'],
            'price' => floatval($row['harga']),
            'stock' => intval($row['stok']),
            'image' => $row['gambar'],
            'category_id' => $row['id_kategori'],
            'category' => $row['category_name'],
            'rating' => floatval($row['rating'] ?? 0),
            'is_active' => (bool)$row['is_active'],
            'created_at' => $row['created_at'],
            'updated_at' => $row['updated_at']
        );
        $products[] = $product;
    }

    // Return success response
    echo json_encode([
        'success' => true,
        'data' => $products,
        'message' => 'Products retrieved successfully'
    ]);

} catch (Exception $e) {
    // Return error response
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}

// Close the database connection
$stmt->close();
$conn->close();
?> 