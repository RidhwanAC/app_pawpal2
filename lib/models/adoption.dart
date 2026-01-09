class Adoption {
  String? adoptionId;
  String? petId;
  String? relinquisherId;
  String? adoptedById;
  String? status;
  String? motivation;
  String? dateRequested;
  String? userName; // Adopter's name
  String? userPhone; // Adopter's phone
  String? userEmail; // Adopter's email

  Adoption({
    this.adoptionId,
    this.petId,
    this.relinquisherId,
    this.adoptedById,
    this.status,
    this.motivation,
    this.dateRequested,
    this.userName,
    this.userPhone,
    this.userEmail,
  });

  Adoption.fromJson(Map<String, dynamic> json) {
    adoptionId = json['adoption_id'].toString();
    petId = json['pet_id'].toString();
    relinquisherId = json['relinquisher_id'].toString();
    adoptedById = json['adopted_by_id'].toString();
    status = json['status'];
    motivation = json['motivation'];
    dateRequested = json['date_requested'];
    userName = json['user_name'];
    userPhone = json['user_phone'];
    userEmail = json['user_email'];
  }
}
