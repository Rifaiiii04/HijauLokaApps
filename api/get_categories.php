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
    $query = "SELECT id_kategori, nama_kategori FROM category ORDER BY id_kategori ASC";
    $result = $conn->query($query);

    $categories = [];
    while ($row = $result->fetch_assoc()) {
        $categories[] = [
            'id_kategori' => $row['id_kategori'],
            'nama_kategori' => $row['nama_kategori']
        ];
    }

    echo json_encode([
        'success' => true,
        'data' => $categories
    ]);
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
} finally {
    $conn->close();
}
?>
