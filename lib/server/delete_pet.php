<?php
/**
 * Purpose: Deletes a pet submission and removes associated image files from the server.
 */
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    sendJsonResponse(['status' => 'failed', 'message' => 'Method Not Allowed']);
}

$petId = $_POST['petId'] ?? null;

if (!$petId) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Pet ID is required']);
}

// Query: Select image paths for the pet to delete files from the server
$stmt = $conn->prepare("SELECT image_paths FROM tbl_pets WHERE pet_id = ?");
$stmt->bind_param("i", $petId);
$stmt->execute();
$result = $stmt->get_result();

if ($row = $result->fetch_assoc()) {
    $imagePaths = $row['image_paths'];
    if ($imagePaths) {
        $images = explode(",", $imagePaths);
        foreach ($images as $image) {
            $filePath = "../assets/submissions/" . trim($image);
            if (file_exists($filePath)) {
                unlink($filePath);
            }
        }
    }
}

// Query: Delete the pet record from the database
$delStmt = $conn->prepare("DELETE FROM tbl_pets WHERE pet_id = ?");
$delStmt->bind_param("i", $petId);

if ($delStmt->execute()) {
    sendJsonResponse(['status' => 'success', 'message' => 'Pet deleted successfully']);
} else {
    sendJsonResponse(['status' => 'failed', 'message' => 'Failed to delete pet']);
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