/// Purpose: A form screen for users to create a new pet submission.
/// It handles image picking/cropping, location fetching, and submitting data to the server.

import 'dart:io';
import 'package:app_pawpal2/config/config.dart';
import 'package:app_pawpal2/config/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class AddSubmissionScreen extends StatefulWidget {
  const AddSubmissionScreen({super.key, required this.userId});

  final String userId;

  @override
  State<AddSubmissionScreen> createState() => _AddSubmissionScreenState();
}

class _AddSubmissionScreenState extends State<AddSubmissionScreen> {
  // Form field controllers
  final TextEditingController petNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController healthController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Dropdown values
  String? selectedPetType = 'Dog';
  String? selectedCategory = 'Adoption';
  String? selectedGender = 'Male';

  final List<String> petTypes = ['Dog', 'Cat', 'Rabbit', 'Other'];
  final List<String> categories = ['Adoption', 'Donation'];
  final List<String> genders = ['Male', 'Female', 'Unknown'];

  List<File?> images = [null, null, null];
  List<Uint8List?> webImages = [null, null, null];
  int currentIndex = 0;

  Position? currentPosition;

  @override
  void dispose() {
    petNameController.dispose();
    ageController.dispose();
    healthController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final scWidth = MediaQuery.of(context).size.width;
    final bool canGoNext =
        currentIndex < images.length - 1 && _hasImageAt(currentIndex);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Submission',
          style: TextStyle(
            color: AppTheme.textColorDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppTheme.textColorDark),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Picker Section
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          color: currentIndex > 0
                              ? AppTheme.primaryColor
                              : Colors.grey,
                          onPressed: currentIndex > 0 ? _previousImage : null,
                        ),
                        GestureDetector(
                          onTap: _addMedia,
                          child: Container(
                            width: scWidth * 0.6,
                            height: (scWidth * 0.6) * 0.75,
                            decoration: BoxDecoration(
                              color: AppTheme.scaffoldColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildImageWidget(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          color: canGoNext
                              ? AppTheme.primaryColor
                              : Colors.grey,
                          onPressed: canGoNext ? _nextImage : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Image ${currentIndex + 1} of 3",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Text(
                      "Tap image to add/change",
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Form Fields
            _buildLabel("Pet Name"),
            TextField(
              controller: petNameController,
              decoration: _inputDecoration("Enter pet name"),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Type"),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: _boxDecoration(),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedPetType,
                            isExpanded: true,
                            items: petTypes.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedPetType = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Category"),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: _boxDecoration(),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategory,
                            isExpanded: true,
                            items: categories.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCategory = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Gender"),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: _boxDecoration(),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedGender,
                            isExpanded: true,
                            items: genders.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedGender = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Age"),
                      TextField(
                        controller: ageController,
                        decoration: _inputDecoration("e.g. 2 years"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildLabel("Health Condition"),
            TextField(
              controller: healthController,
              decoration: _inputDecoration("e.g. Vaccinated, Spayed"),
            ),
            const SizedBox(height: 16),

            _buildLabel("Description"),
            TextFormField(
              controller: descriptionController,
              maxLines: 3,
              maxLength: 150,
              decoration: _inputDecoration("Describe the pet..."),
            ),
            const SizedBox(height: 16),

            _buildLabel("Location"),
            TextField(
              controller: addressController,
              readOnly: true,
              maxLines: 2,
              decoration: _inputDecoration("Address").copyWith(
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.my_location,
                    color: AppTheme.primaryColor,
                  ),
                  onPressed: _getCurrentLocation,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Submit Listing",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.borderColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.borderColor.withOpacity(0.5)),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.textColorDark,
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    final currentImage = images[currentIndex];
    final currentWebImage = webImages[currentIndex];

    if (currentImage == null && currentWebImage == null) {
      return const Center(
        child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
      );
    }

    if (kIsWeb) {
      return Image.memory(
        currentWebImage!,
        fit: BoxFit.cover,
        width: 400,
        height: 300,
      );
    } else {
      return Image.file(
        currentImage!,
        fit: BoxFit.cover,
        width: 400,
        height: 300,
      );
    }
  }

  void _previousImage() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  void _nextImage() {
    if (currentIndex < 2) {
      setState(() {
        currentIndex++;
      });
    }
  }

  bool _hasImageAt(int idx) {
    if (idx < 0 || idx >= images.length) return false;
    return images[idx] != null || webImages[idx] != null;
  }

  void _addMedia() {
    if (kIsWeb) {
      _openGallery();
    } else {
      _pickImageDialog();
    }
  }

  Future<void> _pickImageDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text('Choose Image from:'),
          actions: [
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _openCamera();
                  },
                  icon: const Icon(Icons.camera_alt),
                ),
                const Text('Camera'),
              ],
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _openGallery();
                  },
                  icon: const Icon(Icons.image),
                ),
                const Text('Gallery'),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _openCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedImage != null) {
      final croppedImage = await _cropImage(pickedImage.path);
      if (croppedImage != null) {
        setState(() {
          images[currentIndex] = croppedImage;
        });
      }
    }
  }

  Future<void> _openGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        final Uint8List? bytes = await _cropImageWeb(pickedFile.path);
        if (bytes != null) {
          setState(() {
            webImages[currentIndex] = bytes;
          });
        }
      } else {
        final croppedImage = await _cropImage(pickedFile.path);
        if (croppedImage != null) {
          setState(() {
            images[currentIndex] = croppedImage;
          });
        }
      }
    }
  }

  Future<File?> _cropImage(String path) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.ratio4x3,
          aspectRatioPresets: [CropAspectRatioPreset.ratio4x3],
          cropStyle: CropStyle.rectangle,
          cropFrameColor: Colors.blue,
          lockAspectRatio: true,
        ),
        WebUiSettings(
          context: context,
          dragMode: WebDragMode.move,
          scalable: true,
          initialAspectRatio: 4 / 3,
          size: const CropperSize(height: 300, width: 400),
          movable: true,
          cropBoxMovable: true,
          cropBoxResizable: false,
        ),
      ],
    );

    if (croppedFile == null) return null;
    return File(croppedFile.path);
  }

  Future<Uint8List?> _cropImageWeb(String path) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.ratio4x3,
          aspectRatioPresets: [CropAspectRatioPreset.ratio4x3],
          cropStyle: CropStyle.rectangle,
          cropFrameColor: Colors.blue,
          lockAspectRatio: true,
        ),
        WebUiSettings(
          context: context,
          dragMode: WebDragMode.move,
          scalable: true,
          initialAspectRatio: 4 / 3,
          size: const CropperSize(height: 300, width: 400),
          movable: true,
          cropBoxMovable: true,
          cropBoxResizable: false,
        ),
      ],
    );

    if (croppedFile == null) return null;
    return await croppedFile.readAsBytes();
  }

  void _getCurrentLocation() async {
    addressController.clear();

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition()
        .then((Position position) {
          setState(() {
            _getAddress(position);
          });
        })
        .catchError((e) {
          Future.error(e);
        });
  }

  void _getAddress(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    Placemark place = placemarks[0];
    setState(() {
      currentPosition = position;
      addressController.text =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    });
  }

  void _submitForm() {
    if (images[0] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (petNameController.text.isEmpty ||
        ageController.text.isEmpty ||
        healthController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all the fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit?'),
        content: const Text('Are you sure you want to submit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _addSubmission();
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _addSubmission() async {
    String? userId = widget.userId;
    String petName = petNameController.text.trim();
    String petType = selectedPetType!;
    String category = selectedCategory!;
    String gender = selectedGender!;
    String age = ageController.text.trim();
    String health = healthController.text.trim();
    String description = descriptionController.text.trim();
    String lat = currentPosition!.latitude.toString();
    String lng = currentPosition!.longitude.toString();

    // Filter out null images and collect valid ones
    List<File?> validNativeImages = [];
    List<Uint8List?> validWebImages = [];

    for (int i = 0; i < images.length; i++) {
      if (images[i] != null) {
        validNativeImages.add(images[i]);
      } else if (webImages[i] != null) {
        validWebImages.add(webImages[i]);
      }
    }

    if (validNativeImages.isEmpty && validWebImages.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No valid images to upload'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Config.baseUrl}/app_pawpal/api/submit_pet.php'),
      );

      // Add form fields
      request.fields['userId'] = userId;
      request.fields['petName'] = petName;
      request.fields['petType'] = petType;
      request.fields['category'] = category;
      request.fields['gender'] = gender;
      request.fields['age'] = age;
      request.fields['health'] = health;
      request.fields['description'] = description;
      request.fields['lat'] = lat;
      request.fields['lng'] = lng;

      // Add native images with gap-filled numbering (pet_1.jpg, pet_2.jpg, etc.)
      int petNumber = 1;
      for (var imgFile in validNativeImages) {
        if (imgFile != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'pet_$petNumber',
              imgFile.path,
              filename: 'pet_$petNumber.jpg',
            ),
          );
          petNumber++;
        }
      }

      // Add web images
      for (var imgBytes in validWebImages) {
        if (imgBytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'pet_$petNumber',
              imgBytes,
              filename: 'pet_$petNumber.jpg',
            ),
          );
          petNumber++;
        }
      }

      // Send request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      // Parse JSON response from server (submit_pet.php)
      Map<String, dynamic>? jsonResp;
      try {
        jsonResp = json.decode(responseBody) as Map<String, dynamic>?;
      } catch (e) {
        jsonResp = null;
      }

      if (response.statusCode == 200 && jsonResp != null) {
        final status = jsonResp['status'] ?? '';
        final message = jsonResp['message'] ?? 'No message from server';
        if (status.toString().toLowerCase() == 'success') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.green),
            );
            print(message);
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Upload failed: status: $status, message: $message',
                ),
                backgroundColor: Colors.red,
              ),
            );
            print(message);
          }
        }
      } else {
        // Non-200 or invalid JSON
        String errMsg = 'Upload failed: HTTP ${response.statusCode}';
        if (responseBody.isNotEmpty) errMsg += '\n$responseBody';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errMsg), backgroundColor: Colors.red),
          );
          print(errMsg);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        print('Error: $e');
      }
    }
  }
}
