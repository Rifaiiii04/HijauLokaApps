<?php
// Check if order_id is provided
if (!isset($_GET['order_id']) || empty($_GET['order_id'])) {
    echo "Order ID is required";
    exit();
}

$order_id = $_GET['order_id'];

// Direct database connection
$host = "103.247.11.220";
$db_name = "hijc7862_hijauloka";
$username = "hijc7862_admin";
$password = "wyn[=?alPV%.";

// Create connection
$conn = new mysqli($host, $username, $password, $db_name);

// Check connection
if ($conn->connect_error) {
    echo "Database connection failed: " . $conn->connect_error;
    exit();
}

// Update order status to processing
$sql = "UPDATE orders SET status = 'processing' WHERE order_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $order_id);
$stmt->execute();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Success - HijauLoka</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
            text-align: center;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .success-icon {
            color: #4CAF50;
            font-size: 80px;
            margin-bottom: 20px;
        }
        h1 {
            color: #4CAF50;
        }
        .button {
            background-color: #4CAF50;
            color: white;
            border: none;
            padding: 10px 20px;
            text-align: center;
            text-decoration: none;
            display: inline-block;
            font-size: 16px;
            margin: 20px 0;
            cursor: pointer;
            border-radius: 4px;
        }
        .button:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="success-icon">✓</div>
        <h1>Payment Successful!</h1>
        <p>Your payment for order <strong><?php echo htmlspecialchars($order_id); ?></strong> has been processed successfully.</p>
        <p>We'll start processing your order right away. You'll receive an email confirmation shortly.</p>
        
        <p>Thank you for shopping with HijauLoka!</p>
        
        <a href="https://hijauloka.my.id" class="button">Return to HijauLoka</a>
    </div>
</body>
</html>