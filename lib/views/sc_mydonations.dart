import 'dart:convert';
import 'package:app_pawpal2/config/config.dart';
import 'package:app_pawpal2/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyDonationsScreen extends StatefulWidget {
  final User user;
  const MyDonationsScreen({super.key, required this.user});

  @override
  State<MyDonationsScreen> createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends State<MyDonationsScreen> {
  List<dynamic> adoptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdoptions();
  }

  Future<void> _loadAdoptions() async {
    final response = await http.get(
      Uri.parse(
        "${Config.baseUrl}/app_pawpal/api/get_my_adoptions.php?userId=${widget.user.userId}",
      ),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'success') {
        setState(() {
          adoptions = jsonResponse['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : adoptions.isEmpty
          ? const Center(child: Text("No adoption requests found."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: adoptions.length,
              itemBuilder: (context, index) {
                final item = adoptions[index];
                String imagePath = "";
                if (item['image_paths'] != null &&
                    item['image_paths'].toString().isNotEmpty) {
                  imagePath = item['image_paths'].split(',')[0];
                }

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: imagePath.isNotEmpty
                              ? NetworkImage(
                                  "${Config.baseUrl}/app_pawpal/assets/submissions/$imagePath",
                                )
                              : const AssetImage('assets/paw.png')
                                    as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(
                      item['pet_name'] ?? "Unknown Pet",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Type: ${item['pet_type']}"),
                        const SizedBox(height: 4),
                        Text(
                          "Status: ${item['adoption_status']}",
                          style: TextStyle(
                            color: _getStatusColor(item['adoption_status']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Date: ${item['date_requested']}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Adopted':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Waiting Response':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
