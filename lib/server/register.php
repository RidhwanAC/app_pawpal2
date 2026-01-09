<?php
/**
 * Purpose: Handles user registration by creating a new user account.
 */
header('Access-Control-Allow-Origin: *');
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    sendJsonResponse(['status' => 'failed', 'message' => 'Method Not Allowed']);
}

$name = $_POST['name'] ?? '';
$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';
$phone = $_POST['phone'] ?? '';

if (empty($name) || empty($email) || empty($password) || empty($phone)) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Incomplete data']);
}

$hashedpassword = sha1($password);

// Query: Check if the email address is already registered
$stmt = $conn->prepare("SELECT user_email FROM tbl_users WHERE user_email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
if ($stmt->get_result()->num_rows > 0) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Email already exists']);
}

// Query: Check if the username is already taken
$stmt = $conn->prepare("SELECT user_name FROM tbl_users WHERE user_name = ?");
$stmt->bind_param("s", $name);
$stmt->execute();
if ($stmt->get_result()->num_rows > 0) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Username already exists']);
}

// Query: Insert the new user record into the database
$stmt = $conn->prepare("INSERT INTO tbl_users (user_name, user_email, user_password, user_phone) VALUES (?, ?, ?, ?)");
$stmt->bind_param("ssss", $name, $email, $hashedpassword, $phone);

if ($stmt->execute()) {
    // Query: Fetch the newly created user data to return to the client
    $newId = $stmt->insert_id;
    $stmt = $conn->prepare("SELECT * FROM tbl_users WHERE user_id = ?");
    $stmt->bind_param("i", $newId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $userdata = [];
    while ($row = $result->fetch_assoc()) {
        $userdata[] = $row;
    }
    
    sendJsonResponse(['status' => 'success', 'message' => 'Registration successful', 'data' => $userdata]);
} else {
    sendJsonResponse(['status' => 'failed', 'message' => 'Registration failed']);
}

/**
 * Function: Sends a JSON response and exits the script.
 */
function sendJsonResponse($response) {
    header('Content-Type: application/json');
    echo json_encode($response);
    exit();
}
?>