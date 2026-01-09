import 'dart:convert';
import 'package:app_pawpal2/config/config.dart';
import 'package:app_pawpal2/models/pet.dart';
import 'package:app_pawpal2/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PetDetailsScreen extends StatelessWidget {
  final Pet pet;
  final User currentUser;

  const PetDetailsScreen({
    super.key,
    required this.pet,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    List<String> images = pet.imagePaths?.split(',') ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(pet.petName ?? "Pet Details")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              child: images.isNotEmpty
                  ? PageView.builder(
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          "${Config.baseUrl}/app_pawpal/assets/submissions/${images[index]}",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 100),
                        );
                      },
                    )
                  : const Center(child: Icon(Icons.pets, size: 100)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.petName ?? "No Name",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(label: Text(pet.petType ?? "Unknown")),
                      const SizedBox(width: 10),
                      Chip(label: Text(pet.category ?? "Unknown")),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow("Gender", pet.gender ?? "Unknown"),
                  _buildDetailRow("Age", pet.age ?? "Unknown"),
                  _buildDetailRow("Health", pet.health ?? "Unknown"),
                  _buildDetailRow("Posted By", pet.userName ?? "Unknown"),
                  const SizedBox(height: 16),
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(pet.description ?? "No description available."),
                  const SizedBox(height: 16),
                  const Text(
                    "Date Posted",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(pet.createdAt ?? "N/A"),
                  const SizedBox(height: 30),
                  if (pet.userId != currentUser.userId)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _showAdoptionDialog(context),
                        child: const Text("Request to Adopt"),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  void _showAdoptionDialog(BuildContext context) {
    TextEditingController motivationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Request to Adopt"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Please write a short motivation message:"),
              const SizedBox(height: 10),
              TextField(
                controller: motivationController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Why do you want to adopt this pet?",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (motivationController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a motivation message"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                _submitAdoptionRequest(context, motivationController.text);
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitAdoptionRequest(
    BuildContext context,
    String motivation,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${Config.baseUrl}/app_pawpal/api/request_adoption.php"),
        body: {
          'pet_id': pet.petId,
          'relinquisher_id': pet.userId,
          'adopted_by_id': currentUser.userId,
          'motivation': motivation,
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message']),
            backgroundColor: jsonResponse['status'] == 'success'
                ? Colors.green
                : Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }
}
