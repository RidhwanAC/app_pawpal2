import 'dart:convert';
import 'package:app_pawpal2/config/config.dart';
import 'package:app_pawpal2/models/pet.dart';
import 'package:app_pawpal2/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PetDetailsScreen extends StatefulWidget {
  final Pet pet;
  final User currentUser;

  const PetDetailsScreen({
    super.key,
    required this.pet,
    required this.currentUser,
  });

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  bool hasApplied = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdoptionStatus();
  }

  Future<void> _checkAdoptionStatus() async {
    final response = await http.get(
      Uri.parse(
        "${Config.baseUrl}/app_pawpal/api/check_adoption.php?pet_id=${widget.pet.petId}&user_id=${widget.currentUser.userId}",
      ),
    );
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['status'] == 'success' && json['exists'] == true) {
        setState(() {
          hasApplied = true;
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> images = widget.pet.imagePaths?.split(',') ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(widget.pet.petName ?? "Pet Details")),
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
                    widget.pet.petName ?? "No Name",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(label: Text(widget.pet.petType ?? "Unknown")),
                      const SizedBox(width: 10),
                      Chip(label: Text(widget.pet.category ?? "Unknown")),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow("Gender", widget.pet.gender ?? "Unknown"),
                  _buildDetailRow("Age", widget.pet.age ?? "Unknown"),
                  _buildDetailRow("Health", widget.pet.health ?? "Unknown"),
                  _buildDetailRow(
                    "Posted By",
                    widget.pet.userName ?? "Unknown",
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.pet.description ?? "No description available."),
                  const SizedBox(height: 16),
                  const Text(
                    "Date Posted",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(widget.pet.createdAt ?? "N/A"),
                  const SizedBox(height: 30),
                  if (widget.pet.userId != widget.currentUser.userId)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _buildActionButton(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (widget.pet.category == 'Adoption') {
      if (hasApplied) {
        return ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          child: const Text("You already applied to adopt this pet"),
        );
      }
      return ElevatedButton(
        onPressed: isLoading ? null : () => _showAdoptionDialog(context),
        child: const Text("Request to Adopt"),
      );
    } else if (widget.pet.category == 'Donation') {
      return ElevatedButton(
        onPressed: () => _showDonationDialog(context),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        child: const Text("Donate"),
      );
    }
    // Default fallback
    return ElevatedButton(onPressed: () {}, child: const Text("Contact Owner"));
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
          'pet_id': widget.pet.petId,
          'relinquisher_id': widget.pet.userId,
          'adopted_by_id': widget.currentUser.userId,
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
        if (jsonResponse['status'] == 'success') {
          _checkAdoptionStatus();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _showDonationDialog(BuildContext context) {
    String selectedType = 'Money';
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Make a Donation"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedType,
                    isExpanded: true,
                    items: ['Money', 'Food', 'Medical'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedType = val!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  if (selectedType == 'Money')
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Amount (RM)",
                        border: OutlineInputBorder(),
                      ),
                    )
                  else
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Description (e.g. 2kg Kibbles)",
                        border: OutlineInputBorder(),
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
                    Navigator.pop(context);
                    _submitDonation(
                      selectedType,
                      amountController.text,
                      descController.text,
                    );
                  },
                  child: const Text("Donate"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitDonation(
    String type,
    String amount,
    String description,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${Config.baseUrl}/app_pawpal/api/submit_donation.php"),
        body: {
          'pet_id': widget.pet.petId,
          'donor_id': widget.currentUser.userId,
          'donation_type': type,
          'amount': amount,
          'description': description,
        },
      );
      var jsonResponse = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(jsonResponse['message']),
          backgroundColor: jsonResponse['status'] == 'success'
              ? Colors.green
              : Colors.red,
        ),
      );
    } catch (e) {
      print(e);
    }
  }
}
