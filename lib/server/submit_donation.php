<?php
/**
 * Purpose: Records a donation made by a user towards a specific pet.
 */
header('Access-Control-Allow-Origin: *');
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    sendJsonResponse(['status' => 'failed', 'message' => 'Method Not Allowed']);
}

$petId = $_POST['pet_id'] ?? '';
$donorId = $_POST['donor_id'] ?? '';
$type = $_POST['donation_type'] ?? '';
$amount = $_POST['amount'] ?? null;
$description = $_POST['description'] ?? null;

// Query: Insert a new donation record into tbl_donations
$stmt = $conn->prepare("INSERT INTO tbl_donations (pet_id, donor_id, donation_type, amount, description) VALUES (?, ?, ?, ?, ?)");
$stmt->bind_param("iisds", $petId, $donorId, $type, $amount, $description);

if ($stmt->execute()) {
    sendJsonResponse(['status' => 'success', 'message' => 'Donation submitted successfully']);
} else {
    sendJsonResponse(['status' => 'failed', 'message' => 'Failed to submit donation']);
}

/**
 * Function: Sends a JSON response and exits the script.
 */
function sendJsonResponse($response) {
    header('Content-Type: application/json');
    echo json_encode($response);
    exit();
}
?>