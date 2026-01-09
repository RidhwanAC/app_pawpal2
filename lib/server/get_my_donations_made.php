<?php
/**
 * Purpose: Retrieves a list of donations made by a specific user.
 */
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

$userId = $_GET['userId'] ?? '';

// Query: Select donations made by the user, joined with pet details to show pet name
$sql = "SELECT d.*, p.pet_name FROM tbl_donations d 
        JOIN tbl_pets p ON d.pet_id = p.pet_id 
        WHERE d.donor_id = ? 
        ORDER BY d.donation_date DESC";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $userId);
$stmt->execute();
$result = $stmt->get_result();

$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

header('Content-Type: application/json');
echo json_encode(['status' => 'success', 'data' => $data]);
?>