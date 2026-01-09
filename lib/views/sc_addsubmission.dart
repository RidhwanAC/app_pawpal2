import 'dart:io';
import 'package:app_pawpal2/config.dart';
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
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Dropdown values
  String? selectedPetType = 'Dog';
  String? selectedCategory = 'Adoption';

  final List<String> petTypes = ['Dog', 'Cat', 'Rabbit', 'Other'];
  final List<String> categories = ['Adoption', 'Donation', 'Rescue'];

  List<File?> images = [null, null, null];
  List<Uint8List?> webImages = [null, null, null];
  int currentIndex = 0;

  Position? currentPosition;

  @override
  void dispose() {
    petNameController.dispose();
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
    final imageWidth = scWidth * 0.8 - 20; // 20 for padding
    final imageHeight = imageWidth * 3 / 4; // 4:3 aspect ratio
    final bool canGoNext =
        currentIndex < images.length - 1 && _hasImageAt(currentIndex);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Text('Add Submission'),
            Spacer(),
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Left Arrow
                    Container(
                      width: scWidth * 0.1 - 10,
                      height: imageHeight,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: currentIndex > 0 ? _previousImage : null,
                        child: Icon(
                          Icons.arrow_left,
                          size: 30,
                          color: currentIndex > 0 ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                    // Image Container
                    GestureDetector(
                      onTap: _addMedia,
                      child: Container(
                        width: imageWidth,
                        height: imageHeight,
                        color: Colors.blue[200],
                        child: _buildImageWidget(),
                      ),
                    ),
                    // Right Arrow
                    Container(
                      width: scWidth * 0.1 - 10,
                      height: imageHeight,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: canGoNext ? _nextImage : null,
                        child: Icon(
                          Icons.arrow_right,
                          size: 30,
                          color: canGoNext ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Pet Name TextField
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Pet Name',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: TextField(
                    controller: petNameController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Enter pet name',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Pet Type and Submission Category Row
                Row(
                  children: [
                    Text(
                      'Pet Type:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: DropdownButton<String>(
                        value: selectedPetType,
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
                    Spacer(),
                    Text(
                      'Category:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: DropdownButton<String>(
                        value: selectedCategory,
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
                  ],
                ),
                const SizedBox(height: 20),
                // Description TextFormField
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Description',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: TextFormField(
                    controller: descriptionController,
                    maxLines: 4,
                    maxLength: 150,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText:
                          'Enter description (e.g., color, distinguishing features)',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Location/Address TextField
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Location/Address',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          enabled: false,
                          controller: addressController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () {
                          _getCurrentLocation();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Submit Button
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    final currentImage = images[currentIndex];
    final currentWebImage = webImages[currentIndex];

    if (currentImage == null && currentWebImage == null) {
      return const Icon(Icons.add_a_photo);
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
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }
    if (petNameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields')),
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
          const SnackBar(content: Text('No valid images to upload')),
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
            print(message);
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Upload failed: $message')));
            print(message);
          }
        }
      } else {
        // Non-200 or invalid JSON
        String errMsg = 'Upload failed: HTTP ${response.statusCode}';
        if (responseBody.isNotEmpty) errMsg += '\n$responseBody';
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errMsg)));
          print(errMsg);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        print('Error: $e');
      }
    }
  }
}
