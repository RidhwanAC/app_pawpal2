/// Purpose: Shows detailed information about a specific submission made by the user.
/// It allows managing adoption requests (accept/reject), viewing received donations, and deleting the submission.

import 'package:app_pawpal2/config/config.dart';
import 'package:app_pawpal2/config/app_theme.dart';
import 'package:app_pawpal2/models/adoption.dart';
import 'package:app_pawpal2/models/donation.dart';
import 'package:app_pawpal2/models/pet.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MySubmissionDetailsScreen extends StatefulWidget {
  final Pet pet;

  const MySubmissionDetailsScreen({super.key, required this.pet});

  @override
  State<MySubmissionDetailsScreen> createState() =>
      _MySubmissionDetailsScreenState();
}

class _MySubmissionDetailsScreenState extends State<MySubmissionDetailsScreen> {
  late Pet _pet;
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
  }

  @override
  Widget build(BuildContext context) {
    final imageList = (_pet.imagePaths != null && _pet.imagePaths!.isNotEmpty)
        ? _pet.imagePaths!.split(',')
        : [];

    return Scaffold(
      appBar: AppBar(
        title: Text(_pet.petName ?? 'Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textColorDark),
        titleTextStyle: const TextStyle(
          color: AppTheme.textColorDark,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDeleteDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Images
            if (imageList.isNotEmpty)
              SizedBox(
                height: 250,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: imageList.length,
                      onPageChanged: (index) {
                        setState(() {
                          _imageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            '${Config.baseUrl}/app_pawpal/assets/submissions/${imageList[index].trim()}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image),
                                ),
                          ),
                        );
                      },
                    ),
                    if (imageList.length > 1)
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${_imageIndex + 1}/${imageList.length}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Details
            _buildInfoRow("Type", _pet.petType),
            _buildInfoRow("Category", _pet.category),
            _buildInfoRow("Gender", _pet.gender),
            _buildInfoRow("Age", _pet.age),
            _buildInfoRow("Health", _pet.health),
            _buildInfoRow("Status", _pet.status),
            const SizedBox(height: 16),
            const Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(_pet.description ?? 'No description'),
            const SizedBox(height: 16),
            Text(
              "Posted on: ${_pet.createdAt}",
              style: const TextStyle(color: Colors.grey),
            ),

            // Adoption Requests
            if (_pet.category == 'Adoption') ...[
              const Divider(height: 40, thickness: 1),
              _buildAdoptionRequestsSection(),
            ],
            if (_pet.category == 'Donation') ...[
              const Divider(height: 40, thickness: 1),
              _buildDonationsReceivedSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value ?? "N/A"),
        ],
      ),
    );
  }

  Widget _buildAdoptionRequestsSection() {
    return FutureBuilder(
      future: http.get(
        Uri.parse(
          "${Config.baseUrl}/app_pawpal/api/get_adoption_requests.php?petId=${_pet.petId}",
        ),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        try {
          var jsonResponse = jsonDecode(snapshot.data!.body);
          List<Adoption> requests = (jsonResponse['data'] as List)
              .map((e) => Adoption.fromJson(e))
              .toList();

          if (requests.isEmpty) {
            return const Text("No adoption requests yet.");
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Adoption Requests",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              ...requests.map((req) => _buildRequestCard(req)),
            ],
          );
        } catch (e) {
          return const Text("Error parsing server response.");
        }
      },
    );
  }

  Widget _buildRequestCard(Adoption req) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${req.userName} (${req.userPhone})",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Email: ${req.userEmail}"),
            const SizedBox(height: 4),
            Text("Motivation: ${req.motivation ?? '-'}"),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Status: ${req.status}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: req.status == 'Adopted'
                        ? Colors.green
                        : (req.status == 'Rejected'
                              ? Colors.red
                              : Colors.orange),
                  ),
                ),
                if (req.status == 'Waiting Response')
                  Row(
                    children: [
                      TextButton(
                        onPressed: () =>
                            _updateAdoptionStatus(req.adoptionId!, 'Rejected'),
                        child: const Text(
                          "Reject",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            _updateAdoptionStatus(req.adoptionId!, 'Adopted'),
                        child: const Text(
                          "Accept",
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationsReceivedSection() {
    return FutureBuilder(
      future: http.get(
        Uri.parse(
          "${Config.baseUrl}/app_pawpal/api/get_pet_donations.php?petId=${_pet.petId}",
        ),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Text("Error loading donations.");
        }

        var jsonResponse = jsonDecode(snapshot.data!.body);
        List<Donation> donations = (jsonResponse['data'] as List)
            .map((e) => Donation.fromJson(e))
            .toList();

        if (donations.isEmpty) {
          return const Text("No donations received yet.");
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Donations Received",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            ...donations.map(
              (d) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text("From: ${d.donorName}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Type: ${d.donationType}"),
                      if (d.donationType == 'Money')
                        Text("Amount: RM ${d.amount}"),
                      if (d.donationType != 'Money')
                        Text("Desc: ${d.description}"),
                      Text(
                        "Date: ${d.donationDate}",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAdoptionStatus(String adoptionId, String status) async {
    await http.post(
      Uri.parse("${Config.baseUrl}/app_pawpal/api/update_adoption_status.php"),
      body: {'adoption_id': adoptionId, 'status': status, 'pet_id': _pet.petId},
    );
    setState(() {});
  }

  void _confirmDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Submission"),
        content: const Text("Are you sure? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePet();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePet() async {
    try {
      final response = await http.post(
        Uri.parse("${Config.baseUrl}/app_pawpal/api/delete_pet.php"),
        body: {'petId': _pet.petId},
      );
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          if (mounted) {
            Navigator.pop(context, true); // Return true to refresh
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Deleted successfully")),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Failed: ${jsonResponse['message']}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Error deleting pet")));
      }
    }
  }
}
