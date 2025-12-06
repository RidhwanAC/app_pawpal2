class Pet {
  String? petId;
  String? petName;
  String? petType;
  String? category;
  String? description;
  String? imagePaths;
  String? lat;
  String? lng;
  String? createdAt;

  Pet({
    this.petId,
    this.petName,
    this.petType,
    this.category,
    this.description,
    this.imagePaths,
    this.lat,
    this.lng,
    this.createdAt,
  });

  Pet.fromJson(Map<String, dynamic> json) {
    petId = json['pet_id'].toString();
    petName = json['pet_name'];
    petType = json['pet_type'];
    category = json['category'];
    description = json['description'];
    imagePaths = json['image_paths'];
    lat = json['lat'].toString();
    lng = json['lng'].toString();
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> pet = <String, dynamic>{};
    pet['pet_id'] = petId;
    pet['pet_name'] = petName;
    pet['pet_type'] = petType;
    pet['category'] = category;
    pet['description'] = description;
    pet['image_paths'] = imagePaths;
    pet['lat'] = lat;
    pet['lng'] = lng;
    pet['created_at'] = createdAt;
    return pet;
  }
}
