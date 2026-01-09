class Adoption {
  String? adoptionId;
  String? petId;
  String? relinquisherId; // id - user who relinquishes
  String? adoptedById; // id - user who adopts
  String? status;
  String? motivation;
  String? dateRequested;
  String? userName; // name - user who relinquishes
  String? userPhone; // phone - user who relinquishes
  String? userEmail; // email - user who relinquishes

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
