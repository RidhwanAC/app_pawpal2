<?php
header('Access-Control-Allow-Origin: *');
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    sendJsonResponse(['status' => 'failed', 'message' => 'Method Not Allowed']);
}

$userId = $_POST['userid'] ?? '';
$name = $_POST['name'] ?? '';
$phone = $_POST['phone'] ?? '';

if (empty($userId) || empty($name) || empty($phone)) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Missing required fields']);
}

// Check if username exists for OTHER users
$stmt = $conn->prepare("SELECT user_id FROM tbl_users WHERE user_name = ? AND user_id != ?");
$stmt->bind_param("si", $name, $userId);
$stmt->execute();
if ($stmt->get_result()->num_rows > 0) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Username already taken']);
}

$imagePath = null;

// Handle Image Upload
if (isset($_FILES['image']) && $_FILES['image']['error'] == 0) {
    $target_dir = "../assets/profile/";
    if (!file_exists($target_dir)) {
        mkdir($target_dir, 0777, true);
    }
    
    $original_name = $_FILES['image']['name'];
    $ext = pathinfo($original_name, PATHINFO_EXTENSION);
    $new_filename = "profile_" . $userId . "_" . time() . "." . $ext;
    $target_file = $target_dir . $new_filename;
    
    if (move_uploaded_file($_FILES['image']['tmp_name'], $target_file)) {
        $imagePath = $new_filename;
    }
}

// Update Database
if ($imagePath) {
    $stmt = $conn->prepare("UPDATE tbl_users SET user_name = ?, user_phone = ?, profile_image = ? WHERE user_id = ?");
    $stmt->bind_param("sssi", $name, $phone, $imagePath, $userId);
} else {
    $stmt = $conn->prepare("UPDATE tbl_users SET user_name = ?, user_phone = ? WHERE user_id = ?");
    $stmt->bind_param("ssi", $name, $phone, $userId);
}

if ($stmt->execute()) {
    // Fetch updated user data
    $stmt = $conn->prepare("SELECT * FROM tbl_users WHERE user_id = ?");
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $userdata = [];
    while ($row = $result->fetch_assoc()) {
        $userdata[] = $row;
    }
    
    sendJsonResponse([
        'status' => 'success', 
        'message' => 'Profile updated successfully', 
        'data' => $userdata
    ]);
} else {
    sendJsonResponse(['status' => 'failed', 'message' => 'Database update failed']);
}

function sendJsonResponse($response) {
    header('Content-Type: application/json');
    echo json_encode($response);
    exit();
}
?>