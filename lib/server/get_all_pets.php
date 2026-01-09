<?php
/**
 * Purpose: Retrieves all active pet submissions for the Explore screen, optionally excluding the current user's pets.
 */
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

$userId = $_GET['userId'] ?? '';

// Query: Select active pets joined with user details, filtering out pets owned by the requesting user
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

/**
 * Function: Sends a JSON response and exits the script.
 */
function sendJsonResponse($response) {
    header('Content-Type: application/json');
    echo json_encode($response);
    exit();
}
?>