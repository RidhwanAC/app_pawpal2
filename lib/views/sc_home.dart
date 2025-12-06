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
  Widget build(BuildContext context) {
    User user = widget.user!;
    String name = user.name!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        _backButtonPressed(context, didPop);
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Welcome Home, $name')),

        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              pets.isEmpty
                  ? const Text('No submission yet.')
                  : Expanded(
                      child: ListView.builder(
                        itemCount: pets.length,
                        itemBuilder: (context, index) => SizedBox(
                          height: 100,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {},

                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              margin: const EdgeInsets.all(5),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                                titleAlignment: ListTileTitleAlignment.top,
                                leading: _buildThumbnail(
                                  pets[index].imagePaths,
                                ),
                                title: Text(
                                  pets[index].petName!,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${pets[index].petType} • ${pets[index].category}\n${pets[index].description ?? ''}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
              TextButton(onPressed: _refreshScreen, child: Text('Refresh')),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddSubmissionScreen(userId: user.userId!),
            ),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _refreshScreen() async {
    try {
      String? userId = widget.user!.userId!;
      final uri = Uri.parse(
        "http://10.144.131.161/app_pawpal/api/get_my_pets.php?userId=$userId",
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
    if (imagePaths == null || imagePaths.isEmpty) {
      return Container(
        width: 80,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[300],
        ),
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }
    // Extract first image from comma-separated list
    final images = imagePaths.split(',');
    final firstImage = images.isNotEmpty ? images[0].trim() : null;
    if (firstImage == null || firstImage.isEmpty) {
      return Container(
        width: 80,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[300],
        ),
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage(
            'http://10.144.131.161/app_pawpal/assets/submissions/$firstImage',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
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

void _backButtonPressed(BuildContext context, bool didPop) {
  if (didPop) {
    return;
  }
  _logoutDialog(context);
}
