<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');

// Set UTF-8 encoding for database connection
ini_set('default_charset', 'UTF-8');

// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database configuration
$host = 'localhost';
$dbname = 'hijc7862_hijauloka';
$username = 'hijc7862_admin';
$password = 'wyn[=?alPV%.';

// Log connection attempts
error_log("Attempting to connect to database: $host, $dbname, $username");

// Helper function to convert all strings to UTF-8
function utf8ize($mixed) {
    if (is_array($mixed)) {
        foreach ($mixed as $key => $value) {
            $mixed[$key] = utf8ize($value);
        }
    } else if (is_string($mixed)) {
        return mb_convert_encoding($mixed, 'UTF-8', 'UTF-8');
    }
    return $mixed;
}

try {
    // Create database connection
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Force connection to use UTF-8
    $conn->exec("SET NAMES 'utf8mb4'");

    error_log("Database connection successful");

    // Test product count
    $testStmt = $conn->query("SELECT COUNT(*) FROM product");
    $productCount = $testStmt->fetchColumn();
    error_log("Total products in database: " . $productCount);

    // Fetch data
    $stmt = $conn->prepare("
        SELECT 
            p.id_product,
            p.nama_product,
            p.desk_product,
            p.harga,
            p.stok,
            p.gambar,
            p.rating,
            c.nama_kategori,
            p.id_kategori
        FROM product p
        LEFT JOIN category c ON p.id_kategori = c.id_kategori
        ORDER BY p.id_product DESC
    ");
    $stmt->execute();
    $products = $stmt->fetchAll(PDO::FETCH_ASSOC);

    error_log("Number of products fetched: " . count($products));

    $base_img_url = "https://admin.hijauloka.my.id/uploads/";

    // Map and format data
    $formattedProducts = array_map(function($product) use ($base_img_url) {
        $gambar = $product['gambar'];
        if ($gambar && strpos($gambar, ',') !== false) {
            $gambar = explode(',', $gambar)[0];
        }
        $gambar = $gambar ? trim($gambar) : '';

        return array(
            'id' => $product['id_product'],
            'name' => $product['nama_product'],
            'description' => $product['desk_product'],
            'price' => floatval($product['harga']),
            'stock' => intval($product['stok']),
            'image' => $gambar,
            'rating' => floatval($product['rating'] ?? 0),
            'category' => $product['nama_kategori'] ?? 'Uncategorized',
            'category_id' => $product['id_kategori']
        );
    }, $products);

    // Convert to UTF-8-safe
    $utf8Products = utf8ize($formattedProducts);

    // Build final response
    $response = array(
        'success' => true,
        'data' => $utf8Products
    );

    $json_output = json_encode($response, JSON_PRETTY_PRINT);

    if ($json_output === false) {
        error_log("JSON encode error: " . json_last_error_msg());
        throw new Exception("Failed to encode JSON: " . json_last_error_msg());
    }

    echo $json_output;
    exit;

} catch(PDOException $e) {
    error_log("Database Error: " . $e->getMessage());
    $response = array(
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage(),
        'data' => null
    );
    http_response_code(500);
    echo json_encode($response);
    exit;
} catch(Exception $e) {
    error_log("General Error: " . $e->getMessage());
    $response = array(
        'success' => false,
        'message' => 'General error: ' . $e->getMessage(),
        'data' => null
    );
    http_response_code(500);
    echo json_encode($response);
    exit;
}
?>
