<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

$userId = $_REQUEST['userId'] ?? null;

if (!$userId) {
    sendJsonResponse(['status' => 'failed', 'message' => 'User ID is required']);
}

$stmt = $conn->prepare("SELECT * FROM tbl_pets WHERE user_id = ? ORDER BY pet_id DESC");
$stmt->bind_param("i", $userId);
$stmt->execute();
$result = $stmt->get_result();

$pets = [];
while ($row = $result->fetch_assoc()) {
    $pets[] = $row;
}

sendJsonResponse([
    'status' => 'success',
    'message' => count($pets) > 0 ? 'Data retrieved' : 'No records found',
    'data' => $pets
]);

function sendJsonResponse($response) {
    header('Content-Type: application/json');
    echo json_encode($response);
    exit();
}
?>