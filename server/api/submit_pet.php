<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    echo json_encode(array('status' => 'failed', 'message' => 'Method Not Allowed'));
    exit();
}

// Required fields
$userId     = isset($_POST['userId']) ? trim($_POST['userId']) : '';
$petName    = isset($_POST['petName']) ? addslashes(trim($_POST['petName'])) : '';
$petType    = isset($_POST['petType']) ? trim($_POST['petType']) : '';
$category   = isset($_POST['category']) ? trim($_POST['category']) : '';
$description = isset($_POST['description']) ? addslashes(trim($_POST['description'])) : '';
$lat   = isset($_POST['lat']) ? floatval($_POST['lat']) : null;
$lng  = isset($_POST['lng']) ? floatval($_POST['lng']) : null;

if (empty($userId) || empty($petName) || empty($petType) || empty($category) || empty($description)) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Missing required fields']);
    exit();
}

if ($lat === null || $lng === null) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Location data required']);
    exit();
}

// Directory for images
$submitDir = realpath(__DIR__ . '/../../app_pawpal/assets/submissions');
if (!$submitDir) {
    $submitDir = __DIR__ . '/../../app_pawpal/assets/submissions';
    if (!is_dir($submitDir)) {
        mkdir($submitDir, 0755, true);
    }
}

// Process uploaded images
$uploadedImages = [];

foreach ($_FILES as $key => $file) {
    if (strpos($key, 'pet_') === 0 && $file['error'] === UPLOAD_ERR_OK) {

        // Validate mime type
        $allowed = ['image/jpeg', 'image/png', 'image/gif'];
        $mime = mime_content_type($file['tmp_name']);

        if (!in_array($mime, $allowed)) {
            sendJsonResponse(['status' => 'failed', 'message' => "Invalid image type for $key"]);
            exit();
        }

        // Validate size (max 5MB)
        if ($file['size'] > 5 * 1024 * 1024) {
            sendJsonResponse(['status' => 'failed', 'message' => "$key exceeds 5MB"]);
            exit();
        }

        // Generate filename
        $filename = $key . ".jpg";
        $filePath = $submitDir . '/' . $filename;

        // Save using file_put_contents
        $content = file_get_contents($file['tmp_name']);
        if ($content === false || file_put_contents($filePath, $content) === false) {
            sendJsonResponse(['status' => 'failed', 'message' => "Failed to save $key"]);
            exit();
        }

        $uploadedImages[] = $filename;
    }
}

if (empty($uploadedImages)) {
    sendJsonResponse(['status' => 'failed', 'message' => 'No valid images uploaded']);
    exit();
}

$imagePaths = implode(",", $uploadedImages);

// Insert into database
$sql = "
INSERT INTO tbl_pets
(user_id, pet_name, pet_type, category, description, image_paths, lat, lng)
VALUES 
('$userId', '$petName', '$petType', '$category', '$description', '$imagePaths', '$lat', '$lng')
";

if ($conn->query($sql) === TRUE) {
    $response = array('status' => 'success', 'message' => 'Submission added successfully');
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'message' => 'Submission not added');
    sendJsonResponse($response);
}


// function to send json response
function sendJsonResponse($array)
{
    echo json_encode($array);
    exit();
}

?>
