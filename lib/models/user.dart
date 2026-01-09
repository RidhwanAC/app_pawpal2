class User {
  String? userId;
  String? name;
  String? email;
  String? password;
  String? phone;
  String? profileImage;
  String? regDate;

  User({
    this.userId,
    this.name,
    this.email,
    this.password,
    this.phone,
    this.profileImage,
    this.regDate,
  });

  User.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'].toString();
    name = json['user_name'];
    email = json['user_email'];
    password = json['user_password'];
    phone = json['user_phone'];
    profileImage = json['profile_image'];
    regDate = json['reg_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> user = <String, dynamic>{};
    user['user_id'] = userId;
    user['user_name'] = name;
    user['user_email'] = email;
    user['user_password'] = password;
    user['user_phone'] = phone;
    user['profile_image'] = profileImage;
    user['reg_date'] = regDate;
    return user;
  }
}
