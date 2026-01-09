<?php
header('Access-Control-Allow-Origin: *');
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    sendJsonResponse(['status' => 'failed', 'message' => 'Method Not Allowed']);
}

$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';

if (empty($email) || empty($password)) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Incomplete data']);
}

$hashedpassword = sha1($password);

$stmt = $conn->prepare("SELECT * FROM `tbl_users` WHERE `user_email` = ? AND `user_password` = ?");
$stmt->bind_param("ss", $email, $hashedpassword);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $userdata = [];
    while ($row = $result->fetch_assoc()) {
        $userdata[] = $row;
    }
    sendJsonResponse(['status' => 'success', 'message' => 'Login successful', 'data' => $userdata]);
} else {
    sendJsonResponse(['status' => 'failed', 'message' => 'Invalid email or password']);
}

function sendJsonResponse($response) {
    header('Content-Type: application/json');
    echo json_encode($response);
    exit();
}
?>