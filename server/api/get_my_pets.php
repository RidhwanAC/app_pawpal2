<?php
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

include 'dbconnect.php';

function sendJsonResponse($arr)
{
    echo json_encode($arr);
    exit();
}

$userId = null;
if (isset($_GET['userId'])) {
    $userId = $_GET['userId'];
} elseif (isset($_POST['userId'])) {
    $userId = $_POST['userId'];
}

if (!$userId) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Missing userId', 'data' => []]);
}

try {
    $sql = "SELECT pet_id, pet_name , pet_type , category, description, image_paths , lat, lng, created_at FROM tbl_pets WHERE user_id = ? ORDER BY pet_id DESC";
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        throw new Exception(message: 'Prepare failed: ' . $conn->error);
    }
    $stmt->bind_param('s', $userId);
    if (!$stmt->execute()) {
        throw new Exception('Execute failed: ' . $stmt->error);
    }
    $result = $stmt->get_result();
    $pets = array();
    while ($row = $result->fetch_assoc()) {
        $pets[] = $row;
    }

    if (empty($pets)) {
        sendJsonResponse(['status' => 'success', 'message' => 'No records', 'data' => []]);
    }

    sendJsonResponse(['status' => 'success', 'message' => 'OK', 'data' => $pets]);

} catch (Exception $e) {
    http_response_code(500);
    sendJsonResponse(['status' => 'failed', 'message' => $e->getMessage(), 'data' => []]);
}

?>