import 'dart:convert';
import 'package:app_pawpal2/config/config.dart';
import 'package:app_pawpal2/models/pet.dart';
import 'package:app_pawpal2/models/user.dart';
import 'package:app_pawpal2/views/sc_pet_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ExploreScreen extends StatefulWidget {
  final User user;
  const ExploreScreen({super.key, required this.user});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Pet> pets = [];
  List<Pet> filteredPets = [];
  String searchQuery = "";
  String selectedType = "All";
  final List<String> petTypes = ["All", "Cat", "Dog", "Other"];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    final response = await http.get(
      Uri.parse(
        "${Config.baseUrl}/app_pawpal/api/get_all_pets.php?userId=${widget.user.userId}",
      ),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'success') {
        setState(() {
          pets = (jsonResponse['data'] as List)
              .map((data) => Pet.fromJson(data))
              .toList();
          _filterPets();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _filterPets() {
    setState(() {
      filteredPets = pets.where((pet) {
        bool matchesSearch = (pet.petName ?? "").toLowerCase().contains(
          searchQuery.toLowerCase(),
        );
        bool matchesType =
            selectedType == "All" || (pet.petType == selectedType);
        return matchesSearch && matchesType;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Search by Pet Name",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                searchQuery = value;
                _filterPets();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text("Filter by Type: ", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedType,
                  items: petTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      selectedType = newValue;
                      _filterPets();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredPets.isEmpty
                ? const Center(child: Text("No pets found."))
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: filteredPets.length,
                    itemBuilder: (context, index) {
                      final pet = filteredPets[index];
                      String firstImage =
                          (pet.imagePaths?.split(',').first) ?? "";
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PetDetailsScreen(
                                pet: pet,
                                currentUser: widget.user,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: firstImage.isNotEmpty
                                    ? Image.network(
                                        "${Config.baseUrl}/app_pawpal/assets/submissions/$firstImage",
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, stack) =>
                                            const Icon(Icons.pets, size: 50),
                                      )
                                    : const Icon(Icons.pets, size: 50),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pet.petName ?? "Unknown",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text("Type: ${pet.petType ?? "N/A"}"),
                                    Text("Category: ${pet.category ?? "N/A"}"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
