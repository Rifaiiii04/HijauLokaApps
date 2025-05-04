<?php
class User {
    private $conn;
    private $table_name = "user";

    public $id_user;
    public $nama;
    public $email;
    public $password;
    public $alamat;
    public $shipping_address;
    public $no_tlp;
    public $profile_image;

    public function __construct($db) {
        $this->conn = $db;
    }

    // Register user
    public function create() {
        $query = "INSERT INTO " . $this->table_name . "
                SET
                    nama = :nama,
                    email = :email,
                    password = :password,
                    alamat = :alamat,
                    no_tlp = :no_tlp";

        $stmt = $this->conn->prepare($query);

        // Sanitize input
        $this->nama = htmlspecialchars(strip_tags($this->nama));
        $this->email = htmlspecialchars(strip_tags($this->email));
        $this->password = htmlspecialchars(strip_tags($this->password));
        $this->alamat = htmlspecialchars(strip_tags($this->alamat));
        $this->no_tlp = htmlspecialchars(strip_tags($this->no_tlp));

        // Hash password
        $password_hash = password_hash($this->password, PASSWORD_BCRYPT);

        // Bind values
        $stmt->bindParam(":nama", $this->nama);
        $stmt->bindParam(":email", $this->email);
        $stmt->bindParam(":password", $password_hash);
        $stmt->bindParam(":alamat", $this->alamat);
        $stmt->bindParam(":no_tlp", $this->no_tlp);

        // Execute query
        if($stmt->execute()) {
            return true;
        }

        return false;
    }

    // Login user
    public function login() {
        $query = "SELECT id_user, nama, email, password, alamat, shipping_address, no_tlp, profile_image
                FROM " . $this->table_name . "
                WHERE email = ?
                LIMIT 0,1";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $this->email);
        $stmt->execute();

        $num = $stmt->rowCount();

        if($num > 0) {
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            
            $this->id_user = $row['id_user'];
            $this->nama = $row['nama'];
            $this->email = $row['email'];
            $this->alamat = $row['alamat'];
            $this->shipping_address = $row['shipping_address'];
            $this->no_tlp = $row['no_tlp'];
            $this->profile_image = $row['profile_image'];

            // Verify password
            if(password_verify($this->password, $row['password'])) {
                return true;
            }
        }

        return false;
    }

    // Check if email exists
    public function emailExists() {
        $query = "SELECT id_user, nama, email, password
                FROM " . $this->table_name . "
                WHERE email = ?
                LIMIT 0,1";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $this->email);
        $stmt->execute();

        $num = $stmt->rowCount();

        if($num > 0) {
            return true;
        }

        return false;
    }
}
?>