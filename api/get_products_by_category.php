<?php
header('Content-Type: application/json; charset=utf-8');

// Database connection
$host = "103.247.11.220";
$db_name = "hijc7862_hijauloka";
$username = "hijc7862_admin";
$password = "wyn[=?alPV%.";

// Create connection
$conn = new mysqli($host, $username, $password, $db_name);

// Check connection
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode([
        'success' => false, 
        'message' => 'Database connection failed: ' . $conn->connect_error
    ]);
    exit;
}

try {
    // Get category ID from query parameter
    $category_id = isset($_GET['category_id']) ? intval($_GET['category_id']) : 0;

    if ($category_id <= 0) {
        throw new Exception('Invalid category ID');
    }

    // Prepare and execute the query
    $query = "SELECT p.*, c.nama_kategori as category_name 
              FROM product p 
              INNER JOIN product_category pc ON p.id_product = pc.id_product 
              INNER JOIN category c ON pc.id_kategori = c.id_kategori 
              WHERE c.id_kategori = ? 
              ORDER BY p.id_product DESC";
              
    $stmt = $conn->prepare($query);
    if (!$stmt) {
        throw new Exception('Query preparation failed: ' . $conn->error);
    }

    $stmt->bind_param("i", $category_id);
    if (!$stmt->execute()) {
        throw new Exception('Query execution failed: ' . $stmt->error);
    }

    $result = $stmt->get_result();
    if (!$result) {
        throw new Exception('Failed to get result: ' . $stmt->error);
    }

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
            'created_at' => $row['created_at'] ?? null,
            'updated_at' => $row['updated_at'] ?? null
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
} finally {
    // Close the database connection
    if (isset($stmt)) {
        $stmt->close();
    }
    if (isset($conn)) {
        $conn->close();
    }
}
?> 