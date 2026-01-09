class User {
  String? userId;
  String? name;
  String? email;
  String? password;
  String? phone;
  String? regDate;

  User({
    this.userId,
    this.name,
    this.email,
    this.password,
    this.phone,
    this.regDate,
  });

  User.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'].toString();
    name = json['name'];
    email = json['email'];
    password = json['password'];
    phone = json['phone'];
    regDate = json['reg_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> user = <String, dynamic>{};
    user['user_id'] = userId;
    user['name'] = name;
    user['email'] = email;
    user['password'] = password;
    user['phone'] = phone;
    user['reg_date'] = regDate;
    return user;
  }
}
