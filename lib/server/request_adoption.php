<?php
header('Access-Control-Allow-Origin: *');
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    sendJsonResponse(['status' => 'failed', 'message' => 'Method Not Allowed']);
}

$petId = $_POST['pet_id'] ?? '';
$relinquisherId = $_POST['relinquisher_id'] ?? '';
$adoptedById = $_POST['adopted_by_id'] ?? '';
$motivation = $_POST['motivation'] ?? '';

$stmt = $conn->prepare("INSERT INTO tbl_adoption (pet_id, relinquisher_id, adopted_by_id, motivation) VALUES (?, ?, ?, ?)");
$stmt->bind_param("iiis", $petId, $relinquisherId, $adoptedById, $motivation);

if ($stmt->execute()) {
    sendJsonResponse(['status' => 'success', 'message' => 'Adoption request sent successfully']);
} else {
    sendJsonResponse(['status' => 'failed', 'message' => 'Failed to send request']);
}

function sendJsonResponse($response) {
    header('Content-Type: application/json');
    echo json_encode($response);
    exit();
}
?>