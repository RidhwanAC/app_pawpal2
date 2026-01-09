<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

$userId = $_GET['userId'] ?? '';

if (empty($userId)) {
    sendJsonResponse(['status' => 'failed', 'message' => 'User ID required']);
}

$sql = "SELECT a.adoption_id, a.status as adoption_status, a.date_requested, 
               p.pet_name, p.pet_type, p.image_paths, p.pet_id, p.status as pet_status
        FROM tbl_adoption a 
        JOIN tbl_pets p ON a.pet_id = p.pet_id 
        WHERE a.adopted_by_id = ? 
        ORDER BY a.date_requested DESC";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $userId);
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