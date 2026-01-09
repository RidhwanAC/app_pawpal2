import 'package:app_pawpal2/config/config.dart';
import 'package:app_pawpal2/config/app_theme.dart';
import 'package:app_pawpal2/models/pet.dart';
import 'package:app_pawpal2/models/user.dart';
import 'package:app_pawpal2/views/sc_addsubmission.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.user});

  final User? user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Pet> pets = [];

  @override
  void initState() {
    super.initState();
    _refreshScreen();
  }

  @override
  Widget build(BuildContext context) {
    User user = widget.user!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'PawPal',
            style: TextStyle(
              color: AppTheme.textColorDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppTheme.scaffoldColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: AppTheme.textColorDark),
              onPressed: () => _logoutDialog(context),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton.icon(
                  onPressed: _refreshScreen,
                  icon: const Icon(
                    Icons.refresh,
                    color: AppTheme.textColorDark,
                  ),
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
                            onTap: () => _showDetailsDialog(pets[index]),
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
                builder: (context) => AddSubmissionScreen(userId: user.userId!),
              ),
            );
            _refreshScreen();
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _refreshScreen() async {
    try {
      String? userId = widget.user!.userId!;
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
          // API returned failed or 'No records'
          setState(() {
            pets = [];
          });
          print('API message: ${body['message']}');
        }
      } else {
        print('HTTP error: ${response.statusCode}');
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
      // Extract first image from comma-separated list
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
          borderRadius: BorderRadius.circular(11), // Slightly less for inner
          child: imageWidget,
        ),
      ),
    );
  }

  void _showDetailsDialog(Pet pet) {
    final imageList = (pet.imagePaths != null && pet.imagePaths!.isNotEmpty)
        ? pet.imagePaths!.split(',')
        : [];

    showDialog(
      context: context,
      builder: (context) {
        int currentIndex = 0;
        return StatefulBuilder(
          builder: (context, setState) {
            final scWidth = MediaQuery.of(context).size.width;
            final imageWidth = scWidth * 0.42;
            final imageHeight = imageWidth * 0.69; // 4:3 Aspect Ratio

            return AlertDialog(
              title: Text(pet.petName ?? 'Unknown'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (imageList.isNotEmpty)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios),
                                onPressed: currentIndex > 0
                                    ? () => setState(() => currentIndex--)
                                    : null,
                              ),
                              Container(
                                width: imageWidth,
                                height: imageHeight,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    '${Config.baseUrl}/app_pawpal/assets/submissions/${imageList[currentIndex].trim()}',
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.broken_image,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios),
                                onPressed: currentIndex < imageList.length - 1
                                    ? () => setState(() => currentIndex++)
                                    : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Image ${currentIndex + 1} of ${imageList.length}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    Text("Type: ${pet.petType}"),
                    Text("Category: ${pet.category}"),
                    const SizedBox(height: 10),
                    const Text(
                      "Description:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(pet.description ?? 'No description'),
                    const SizedBox(height: 10),
                    const Text(
                      "Date:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(pet.createdAt ?? 'Unknown'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmDeleteDialog(pet.petId!);
                  },
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteDialog(String petId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Pet"),
          content: const Text("Are you sure you want to delete this listing?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deletePet(petId);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePet(String petId) async {
    try {
      final response = await http.post(
        Uri.parse("${Config.baseUrl}/app_pawpal/api/delete_pet.php"),
        body: {'petId': petId},
      );
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Pet deleted successfully"),
                backgroundColor: Colors.green,
              ),
            );
          }
          _refreshScreen();
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
      print(e);
    }
  }
}

void _logoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Logout'),
          ),
        ],
      );
    },
  );
}
