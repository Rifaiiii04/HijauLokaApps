<?php
// header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
// header("Access-Control-Allow-Methods: POST, OPTIONS");
// header("Access-Control-Max-Age: 3600");
// header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

$query = "
    SELECT 
        fp.id_featured,
        fp.position,
        p.id_product,
        p.nama_product,
        p.desk_product,
        p.harga,
        p.stok,
        p.id_kategori,
        p.gambar,
        p.rating,
        p.id_admin,
        p.cara_rawat_video
    FROM featured_products fp
    JOIN product p ON fp.id_product = p.id_product
    ORDER BY fp.position ASC
";

$stmt = $db->prepare($query);
$stmt->execute();

$base_img_url = "https://admin.hijauloka.my.id/uploads/";

$featured_products = [];
while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    // Ambil hanya satu nama file jika ada koma
    $gambar = $row['gambar'];
    if (strpos($gambar, ',') !== false) {
        $gambar = explode(',', $gambar)[0];
    }
    $row['gambar'] = $base_img_url . trim($gambar);
    $featured_products[] = $row;
}

echo json_encode([
    "success" => true,
    "data" => $featured_products
]);
?>
