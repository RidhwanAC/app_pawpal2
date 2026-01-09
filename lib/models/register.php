<?php
header('Access-Control-Allow-Origin: *');
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $name = $_POST['name'] ?? '';
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    $phone = $_POST['phone'] ?? '';
    $hashedpassword = sha1($password);

    // Check if email exists
    $stmt = $conn->prepare("SELECT user_email FROM tbl_users WHERE user_email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    if ($stmt->get_result()->num_rows > 0) {
        sendJsonResponse(['status' => 'failed', 'message' => 'Email already exists']);
    }

    // Check if username exists
    $stmt = $conn->prepare("SELECT user_name FROM tbl_users WHERE user_name = ?");
    $stmt->bind_param("s", $name);
    $stmt->execute();
    if ($stmt->get_result()->num_rows > 0) {
        sendJsonResponse(['status' => 'failed', 'message' => 'Username already exists']);
    }

    // Insert user
    $stmt = $conn->prepare("INSERT INTO tbl_users (user_name, user_email, user_password, user_phone) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("ssss", $name, $email, $hashedpassword, $phone);

    if ($stmt->execute()) {
        // Return user data immediately so Flutter can log them in
        $newId = $stmt->insert_id;
        $stmt = $conn->prepare("SELECT * FROM tbl_users WHERE user_id = ?");
        $stmt->bind_param("i", $newId);
        $stmt->execute();
        $userdata = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
        
        sendJsonResponse(['status' => 'success', 'message' => 'Registration successful', 'data' => $userdata]);
    } else {
        sendJsonResponse(['status' => 'failed', 'message' => 'Registration failed']);
    }
}

function sendJsonResponse($response) {
    header('Content-Type: application/json');
    echo json_encode($response);
    exit();
}
?>