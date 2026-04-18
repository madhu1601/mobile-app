class UserModel {
  final int id;
  final String name;
  final String? email;
  final String? mobile;

  const UserModel({
    required this.id,
    required this.name,
    this.email,
    this.mobile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id:     json['id'] as int,
        name:   json['name'] as String,
        email:  json['email'] as String?,
        mobile: json['mobile'] as String?,
      );
}
