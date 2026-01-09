import 'dart:convert';
import 'package:app_pawpal2/config/config.dart';
import 'package:app_pawpal2/models/donation.dart';
import 'package:app_pawpal2/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserDonationsScreen extends StatefulWidget {
  final User user;
  const UserDonationsScreen({super.key, required this.user});

  @override
  State<UserDonationsScreen> createState() => _UserDonationsScreenState();
}

class _UserDonationsScreenState extends State<UserDonationsScreen> {
  List<Donation> donations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    final response = await http.get(
      Uri.parse(
        "${Config.baseUrl}/app_pawpal/api/get_my_donations_made.php?userId=${widget.user.userId}",
      ),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'success') {
        setState(() {
          donations = (jsonResponse['data'] as List)
              .map((e) => Donation.fromJson(e))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : donations.isEmpty
          ? const Center(child: Text("You haven't made any donations yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: donations.length,
              itemBuilder: (context, index) {
                final d = donations[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(
                      Icons.volunteer_activism,
                      color: Colors.orange,
                    ),
                    title: Text("To: ${d.petName}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Type: ${d.donationType}"),
                        if (d.donationType == 'Money')
                          Text("Amount: RM ${d.amount}"),
                        if (d.donationType != 'Money')
                          Text("Desc: ${d.description}"),
                        Text("Date: ${d.donationDate}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
