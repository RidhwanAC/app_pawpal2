<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    sendJsonResponse(['status' => 'failed', 'message' => 'Method Not Allowed']);
}

$adoptionId = $_POST['adoption_id'] ?? '';
$status = $_POST['status'] ?? '';
$petId = $_POST['pet_id'] ?? '';

if (empty($adoptionId) || empty($status) || empty($petId)) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Missing required fields']);
}

$conn->begin_transaction();

try {
    // Update adoption status
    $stmt = $conn->prepare("UPDATE tbl_adoption SET status = ? WHERE adoption_id = ?");
    $stmt->bind_param("si", $status, $adoptionId);
    $stmt->execute();

    // If adopted, update pet status to inactive
    if ($status === 'Adopted') {
        $stmtPet = $conn->prepare("UPDATE tbl_pets SET status = 'inactive' WHERE pet_id = ?");
        $stmtPet->bind_param("i", $petId);
        $stmtPet->execute();
    }

    $conn->commit();
    sendJsonResponse(['status' => 'success', 'message' => 'Status updated successfully']);
} catch (Exception $e) {
    $conn->rollback();
    sendJsonResponse(['status' => 'failed', 'message' => 'Database error: ' . $e->getMessage()]);
}

function sendJsonResponse($response) {
    header('Content-Type: application/json');
    echo json_encode($response);
    exit();
}
?>