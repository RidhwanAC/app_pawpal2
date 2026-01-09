/// Purpose: Displays a list of pet submissions created by the current user.
/// Allows refreshing the list and navigating to details or adding a new submission.

import 'package:app_pawpal2/config/config.dart';
import 'package:app_pawpal2/config/app_theme.dart';
import 'package:app_pawpal2/models/pet.dart';
import 'package:app_pawpal2/models/user.dart';
import 'package:app_pawpal2/views/sc_addsubmission.dart';
import 'package:app_pawpal2/views/sc_mysubmission_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MySubmissionScreen extends StatefulWidget {
  final User user;
  const MySubmissionScreen({super.key, required this.user});

  @override
  State<MySubmissionScreen> createState() => _MySubmissionScreenState();
}

class _MySubmissionScreenState extends State<MySubmissionScreen> {
  List<Pet> pets = [];

  @override
  void initState() {
    super.initState();
    _refreshScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Nested Scaffold allows us to use FAB specific to this screen
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton.icon(
                onPressed: _refreshScreen,
                icon: const Icon(Icons.refresh, color: AppTheme.textColorDark),
                label: const Text(
                  'Refresh List',
                  style: TextStyle(
                    color: AppTheme.textColorDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            pets.isEmpty
                ? Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.pets, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No submission yet.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: pets.length,
                      itemBuilder: (context, index) => Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: AppTheme.borderColor,
                            width: 1,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _navigateToDetails(pets[index]),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                _buildThumbnail(pets[index].imagePaths),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pets[index].petName ?? 'Unknown',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textColorDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: AppTheme.primaryColor
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                        child: Text(
                                          '${pets[index].petType} • ${pets[index].category}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textColorDark,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        pets[index].description ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.textColorLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddSubmissionScreen(userId: widget.user.userId!),
            ),
          );
          _refreshScreen();
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _refreshScreen() async {
    try {
      String? userId = widget.user.userId!;
      final uri = Uri.parse(
        "${Config.baseUrl}/app_pawpal/api/get_my_pets.php?userId=$userId",
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['status'] == 'success') {
          final List<dynamic> data = body['data'] ?? [];
          setState(() {
            pets = data
                .map((e) => Pet.fromJson(e as Map<String, dynamic>))
                .toList();
          });
        } else {
          setState(() {
            pets = [];
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Widget _buildThumbnail(String? imagePaths) {
    Widget imageWidget;
    if (imagePaths == null || imagePaths.isEmpty) {
      imageWidget = Container(
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.image, color: Colors.grey)),
      );
    } else {
      final images = imagePaths.split(',');
      final firstImage = images.isNotEmpty ? images[0].trim() : null;
      if (firstImage == null || firstImage.isEmpty) {
        imageWidget = Container(
          color: Colors.grey[300],
          child: const Center(child: Icon(Icons.image, color: Colors.grey)),
        );
      } else {
        imageWidget = Image.network(
          '${Config.baseUrl}/app_pawpal/assets/submissions/$firstImage',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
            );
          },
        );
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: imageWidget,
        ),
      ),
    );
  }

  Future<void> _navigateToDetails(Pet pet) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MySubmissionDetailsScreen(pet: pet),
      ),
    );
    if (result == true) {
      _refreshScreen();
    }
  }
}
