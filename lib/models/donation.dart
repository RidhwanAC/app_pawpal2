class Donation {
  String? donationId;
  String? petId;
  String? donorId; // id - user who donates
  String? donationType;
  String? amount;
  String? description;
  String? donationDate;
  String? petName;
  String? donorName; // name - user who donates

  Donation({
    this.donationId,
    this.petId,
    this.donorId,
    this.donationType,
    this.amount,
    this.description,
    this.donationDate,
    this.petName,
    this.donorName,
  });

  Donation.fromJson(Map<String, dynamic> json) {
    donationId = json['donation_id'].toString();
    petId = json['pet_id'].toString();
    donorId = json['donor_id'].toString();
    donationType = json['donation_type'];
    amount = json['amount']?.toString();
    description = json['description'];
    donationDate = json['donation_date'];
    petName = json['pet_name'];
    donorName =
        json['user_name']; // Assuming join with tbl_users aliased or selected as user_name
  }
}
