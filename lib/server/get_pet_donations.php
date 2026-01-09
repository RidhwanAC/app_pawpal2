<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

$petId = $_GET['petId'] ?? '';

$sql = "SELECT d.*, u.user_name FROM tbl_donations d 
        JOIN tbl_users u ON d.donor_id = u.user_id 
        WHERE d.pet_id = ? 
        ORDER BY d.donation_date DESC";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $petId);
$stmt->execute();
$result = $stmt->get_result();

$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

header('Content-Type: application/json');
echo json_encode(['status' => 'success', 'data' => $data]);
?>