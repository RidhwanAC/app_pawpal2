class Pet {
  String? petId;
  String? userId;
  String? userName;
  String? petName;
  String? petType;
  String? category;
  String? gender;
  String? age;
  String? health;
  String? description;
  String? imagePaths;
  String? lat;
  String? lng;
  String? createdAt;
  String? status;

  Pet({
    this.petId,
    this.userId,
    this.userName,
    this.petName,
    this.petType,
    this.category,
    this.gender,
    this.age,
    this.health,
    this.description,
    this.imagePaths,
    this.lat,
    this.lng,
    this.createdAt,
    this.status,
  });

  Pet.fromJson(Map<String, dynamic> json) {
    petId = json['pet_id'].toString();
    userId = json['user_id'].toString();
    userName = json['user_name'];
    petName = json['pet_name'];
    petType = json['pet_type'];
    category = json['category'];
    gender = json['gender'];
    age = json['age'];
    health = json['health'];
    description = json['description'];
    imagePaths = json['image_paths'];
    lat = json['lat'].toString();
    lng = json['lng'].toString();
    createdAt = json['created_at'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> pet = <String, dynamic>{};
    pet['pet_id'] = petId;
    pet['user_id'] = userId;
    pet['user_name'] = userName;
    pet['pet_name'] = petName;
    pet['pet_type'] = petType;
    pet['category'] = category;
    pet['gender'] = gender;
    pet['age'] = age;
    pet['health'] = health;
    pet['description'] = description;
    pet['image_paths'] = imagePaths;
    pet['lat'] = lat;
    pet['lng'] = lng;
    pet['created_at'] = createdAt;
    pet['status'] = status;
    return pet;
  }
}
