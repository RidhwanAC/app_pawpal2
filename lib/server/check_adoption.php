<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

$petId = $_GET['pet_id'] ?? '';
$userId = $_GET['user_id'] ?? '';

if (empty($petId) || empty($userId)) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Missing parameters']);
}

$stmt = $conn->prepare("SELECT adoption_id FROM tbl_adoption WHERE pet_id = ? AND adopted_by_id = ?");
$stmt->bind_param("ii", $petId, $userId);
$stmt->execute();
$result = $stmt->get_result();

sendJsonResponse(['status' => 'success', 'exists' => $result->num_rows > 0]);

function sendJsonResponse($response) {
    header('Content-Type: application/json');
    echo json_encode($response);
    exit();
}
?>