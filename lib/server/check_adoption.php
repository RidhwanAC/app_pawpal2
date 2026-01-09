<?php
/**
 * Purpose: Checks if a user has already submitted an adoption request for a specific pet.
 */
error_reporting(0);
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

$petId = $_GET['pet_id'] ?? '';
$userId = $_GET['user_id'] ?? '';

if (empty($petId) || empty($userId)) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Missing parameters']);
}

// Query: Select adoption ID if a record exists for the given pet and user
$stmt = $conn->prepare("SELECT adoption_id FROM tbl_adoption WHERE pet_id = ? AND adopted_by_id = ?");
$stmt->bind_param("ii", $petId, $userId);
$stmt->execute();
$result = $stmt->get_result();

sendJsonResponse(['status' => 'success', 'exists' => $result->num_rows > 0]);

/**
 * Function: Sends a JSON response and exits the script.
 */
function sendJsonResponse($response) {
    header('Content-Type: application/json');
    echo json_encode($response);
    exit();
}
?>