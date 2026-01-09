<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

$petId = $_GET['petId'] ?? '';

if (empty($petId)) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Pet ID required']);
}

$sql = "SELECT a.adoption_id, a.status, a.motivation, a.date_requested, 
               u.user_name, u.user_phone, u.user_email 
        FROM tbl_adoption a 
        JOIN tbl_users u ON a.adopted_by_id = u.user_id 
        WHERE a.pet_id = ? 
        ORDER BY a.date_requested DESC";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $petId);
$stmt->execute();
$result = $stmt->get_result();

$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

sendJsonResponse(['status' => 'success', 'data' => $data]);

function sendJsonResponse($response) {
    header('Content-Type: application/json');
    echo json_encode($response);
    exit();
}
?>