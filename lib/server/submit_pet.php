<?php
/**
 * Purpose: Handles the submission of a new pet listing, including uploading images.
 */
header('Access-Control-Allow-Origin: *');
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    sendJsonResponse(['status' => 'failed', 'message' => 'Method Not Allowed']);
}

$userId = $_POST['userId'] ?? '';
$petName = $_POST['petName'] ?? '';
$petType = $_POST['petType'] ?? '';
$category = $_POST['category'] ?? '';
$gender = $_POST['gender'] ?? '';
$age = $_POST['age'] ?? '';
$health = $_POST['health'] ?? '';
$description = $_POST['description'] ?? '';
$lat = $_POST['lat'] ?? '';
$lng = $_POST['lng'] ?? '';

if (empty($userId) || empty($petName) || empty($description) || empty($gender) || empty($age) || empty($health)) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Missing required fields']);
}

// Directory to save images
$target_dir = "../assets/submissions/";
if (!file_exists($target_dir)) {
    mkdir($target_dir, 0777, true);
}

// Check if at least one image is uploaded before creating DB record
$has_image = false;
$error_message = 'At least one image is required';

if (empty($_FILES)) {
    $error_message = 'No files received. Check upload_max_filesize and post_max_size in php.ini';
} else {
    for ($i = 1; $i <= 3; $i++) {
        $key = "pet_" . $i;
        if (isset($_FILES[$key])) {
            if ($_FILES[$key]['error'] === UPLOAD_ERR_OK) {
                $has_image = true;
                break;
            } elseif ($_FILES[$key]['error'] !== UPLOAD_ERR_NO_FILE) {
                // Capture specific error to help debugging (e.g., Error 1 = File too large)
                $error_message = "Image $i upload error code: " . $_FILES[$key]['error'];
            }
        }
    }
}

if (!$has_image) {
    sendJsonResponse(['status' => 'failed', 'message' => $error_message]);
}

// Query: Insert new pet record into the database
$stmt = $conn->prepare("INSERT INTO tbl_pets (user_id, pet_name, pet_type, category, gender, age, health, description, lat, lng) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
$stmt->bind_param("isssssssss", $userId, $petName, $petType, $category, $gender, $age, $health, $description, $lat, $lng);

if ($stmt->execute()) {
    $petId = $stmt->insert_id;
    $saved_filenames = [];
    
    // Loop through possible keys pet_1, pet_2, pet_3
    for ($i = 1; $i <= 3; $i++) {
        $key = "pet_" . $i;
        if (isset($_FILES[$key]) && $_FILES[$key]['error'] == 0) {
            $original_name = $_FILES[$key]['name'];
            $ext = pathinfo($original_name, PATHINFO_EXTENSION);
            
            // New naming convention: pet_{userId}_{petId}_{i}.ext
            $new_filename = "pet_" . $userId . "_" . $petId . "_" . $i . "." . $ext;
            $target_file = $target_dir . $new_filename;
            
            if (move_uploaded_file($_FILES[$key]['tmp_name'], $target_file)) {
                $saved_filenames[] = $new_filename;
            }
        }
    }

    if (!empty($saved_filenames)) {
        $imagePaths = implode(",", $saved_filenames);
        // Query: Update the pet record with the paths of the uploaded images
        $updateStmt = $conn->prepare("UPDATE tbl_pets SET image_paths = ? WHERE pet_id = ?");
        $updateStmt->bind_param("si", $imagePaths, $petId);
        if ($updateStmt->execute()) {
             sendJsonResponse(['status' => 'success', 'message' => 'Submission successful']);
        } else {
             sendJsonResponse(['status' => 'failed', 'message' => 'Failed to update image paths']);
        }
    } else {
        sendJsonResponse(['status' => 'success', 'message' => 'Submission saved but images failed to save']);
    }
} else {
    sendJsonResponse(['status' => 'failed', 'message' => 'Database insertion failed']);
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