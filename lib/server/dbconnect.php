<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "pawpal_db";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(['status' => 'failed', 'message' => 'Database connection failed']));
}
?>