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

// Get order details
$sql = "SELECT * FROM orders WHERE order_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $order_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo "Order not found";
    exit();
}

$order = $result->fetch_assoc();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HijauLoka Payment</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            margin-bottom: 20px;
        }
        .header h1 {
            color: #4CAF50;
            margin-bottom: 5px;
        }
        .order-info {
            margin-bottom: 20px;
        }
        .payment-options {
            margin-bottom: 20px;
        }
        .payment-option {
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 15px;
            margin-bottom: 10px;
            cursor: pointer;
        }
        .payment-option:hover {
            background-color: #f9f9f9;
        }
        .payment-option.selected {
            border-color: #4CAF50;
            background-color: #f0f9f0;
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
            margin: 4px 2px;
            cursor: pointer;
            border-radius: 4px;
            width: 100%;
        }
        .button:hover {
            background-color: #45a049;
        }
        .footer {
            text-align: center;
            margin-top: 20px;
            color: #777;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>HijauLoka Payment</h1>
            <p>Complete your payment to process your order</p>
        </div>
        
        <div class="order-info">
            <h2>Order Details</h2>
            <p><strong>Order ID:</strong> <?php echo htmlspecialchars($order_id); ?></p>
            <p><strong>Total Amount:</strong> Rp <?php echo number_format($order['total'], 0, ',', '.'); ?></p>
        </div>
        
        <div class="payment-options">
            <h2>Select Payment Method</h2>
            <div class="payment-option selected" onclick="selectPayment(this, 'bank_transfer')">
                <h3>Bank Transfer</h3>
                <p>Pay via bank transfer to our account</p>
            </div>
            <div class="payment-option" onclick="selectPayment(this, 'qris')">
                <h3>QRIS</h3>
                <p>Scan QR code to pay with your e-wallet</p>
            </div>
            <div class="payment-option" onclick="selectPayment(this, 'credit_card')">
                <h3>Credit Card</h3>
                <p>Pay securely with your credit card</p>
            </div>
        </div>
        
        <button class="button" onclick="processPayment()">Pay Now</button>
        
        <div class="footer">
            <p>© 2023 HijauLoka. All rights reserved.</p>
        </div>
    </div>
    
    <script>
        let selectedPayment = 'bank_transfer';
        
        function selectPayment(element, method) {
            // Remove selected class from all options
            document.querySelectorAll('.payment-option').forEach(option => {
                option.classList.remove('selected');
            });
            
            // Add selected class to clicked option
            element.classList.add('selected');
            selectedPayment = method;
        }
        
        function processPayment() {
            // In a real implementation, this would redirect to the actual payment gateway
            // For this demo, we'll simulate a successful payment
            alert('Payment processing initiated for method: ' + selectedPayment);
            
            // Simulate payment processing
            setTimeout(() => {
                // Redirect to success page
                window.location.href = 'payment_success.php?order_id=<?php echo urlencode($order_id); ?>';
            }, 2000);
        }
    </script>
</body>
</html>