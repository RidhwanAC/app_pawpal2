# PawPal App

## Description

PawPal is a comprehensive Flutter-based mobile application designed to bridge the gap between pet owners, adopters, and donors. It serves as a platform for listing pets for adoption, donation, or rescue, allowing users to explore listings, request adoptions, and contribute donations to pets in need.

## Features

### 1. User Authentication

- **Registration & Login**: Secure account creation and login system.
- **Session Management**: "Remember Me" functionality using shared preferences to persist user sessions.

### 2. Pet Submission & Management

- **Add Listings**: Users can list pets under categories: Adoption, Donation, or Rescue.
- **Media Upload**: Support for uploading multiple images (up to 3) using camera or gallery, with image cropping capabilities.
- **Location Services**: Automatic detection of current location to tag the pet's location.
- **Management**: Users can view their submissions, check details, and delete listings.

### 3. Explore & Search

- **Public Feed**: Browse all active pet submissions from other users.
- **Search & Filter**: Search pets by name and filter results by pet type (e.g., Cat, Dog).
- **Pet Details**: View comprehensive details including health, age, gender, and description.

### 4. Adoption System

- **Request Adoption**: Users can submit adoption requests with a motivation message.
- **Status Tracking**: Track the status of requests (Waiting Response, Adopted, Rejected) in "My Adoptions".
- **Owner Controls**: Pet owners can review incoming requests and Accept or Reject them. Accepting a request marks the pet as inactive in the public feed.

### 5. Donation System

- **Make Donations**: Users can donate Money, Food, or Medical supplies to specific pets.
- **History**: View a history of donations made.
- **Received Donations**: Pet owners can track donations received for their listings.

### 6. Profile Management

- **Edit Profile**: Update user information such as name and phone number.
- **Profile Picture**: Upload and update profile images.

## System Flow

1.  **Authentication**: User logs in or registers.
2.  **Dashboard**: User lands on the main screen with a navigation drawer.
3.  **Listing**: A user submits a pet. The data is sent to the server and stored in the database.
4.  **Discovery**: Other users see the pet in the "Explore" tab.
5.  **Interaction**:
    - **Adoption**: A user requests to adopt. The owner receives the request in "My Submissions" details.
    - **Donation**: A user donates. The record is saved and visible to the owner.
6.  **Completion**: If an adoption is accepted, the pet status updates to 'inactive', removing it from the Explore feed.

## Project Setup

### Prerequisites

- Flutter SDK
- PHP Server (XAMPP, WAMP, or live server)
- MySQL Database

### Server Side

1.  Place the PHP files located in `lib/server/` into your server's public directory (e.g., `htdocs` for XAMPP).
2.  Ensure the following directory structure exists on the server for uploads:
    - `../assets/submissions/`
    - `../assets/profile/`
3.  Configure `dbconnect.php` with your database credentials.

### Database Setup

Create a database named `pawpal_db` and import the following tables:

- **tbl_users**: Stores user credentials and profile info.
- **tbl_pets**: Stores pet listings, location, and status.
- **tbl_adoption**: Links pets, relinquishers, and adopters with status.
- **tbl_donations**: Records donations linked to pets and donors.

### Client Side (Flutter)

1.  Clone the repository.
2.  Update the `Config.baseUrl` in your Flutter project to point to your server's IP address or domain.
3.  Run `flutter pub get` to install dependencies.
4.  Run `flutter run` to launch the app.

## Dependencies

The project relies on the following key packages from `pubspec.yaml`:

- `http`: For making API calls to the PHP backend.
- `shared_preferences`: For local storage of user sessions and settings.
- `geolocator`: For accessing device GPS location.
- `geocoding`: For converting coordinates into human-readable addresses.
- `image_picker`: For selecting images from the gallery or camera.
- `image_cropper`: For cropping and rotating selected images.

## API Usage

The app communicates with a PHP backend via RESTful API endpoints. Key endpoints include:

- **Auth**: `register.php`, `login.php`
- **Pets**:
  - `submit_pet.php`: Uploads pet data and images.
  - `get_all_pets.php`: Fetches active pets for the Explore feed.
  - `get_my_pets.php`: Fetches pets listed by the logged-in user.
  - `delete_pet.php`: Removes a pet listing.
- **Adoption**:
  - `request_adoption.php`: Submits an adoption request.
  - `get_adoption_requests.php`: Fetches requests for a specific pet (for owners).
  - `get_my_adoptions.php`: Fetches requests made by the user.
  - `update_adoption_status.php`: Updates status (Accept/Reject).
- **Donation**:
  - `submit_donation.php`: Records a donation.
  - `get_my_donations_made.php`: Fetches user's donation history.
  - `get_pet_donations.php`: Fetches donations received for a pet.
- **Profile**: `update_profile.php`

## Authorship Note

**Name: Mohamad Ridhwan Bin Mohamad Amin Chong**
**Matric Number: 294737**

“I confirm that this project represents my own original work in accordance with academic integrity policies. No part of the code was fully generated by AI tools such as ChatGPT or GitHub Copilot. I relied solely on lecture notes, class tutorials, and official Flutter documentation. I understand that my work may be scrutinized, and if it is found that I did not personally develop the code, marks may be deducted, or the submission may be disqualified.”

## Link to YouTube Demo

https://youtu.be/AF9uXFl8vUg
