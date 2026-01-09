<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

$userId = $_GET['userId'] ?? '';

$sql = "SELECT p.*, u.user_name FROM tbl_pets p JOIN tbl_users u ON p.user_id = u.user_id WHERE p.status = 'active'";
if (!empty($userId)) {
    $sql .= " AND p.user_id != ?";
}
$sql .= " ORDER BY p.pet_id DESC";

$stmt = $conn->prepare($sql);
if (!empty($userId)) {
    $stmt->bind_param("i", $userId);
}
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