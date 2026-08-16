class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String image;
  final bool isBlocked;
  final String? token;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.image,
    required this.isBlocked,
    this.token,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'image': image,
    'isBlocked': isBlocked,
    'token': token,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    image: json['image'] ?? '',
    isBlocked: json['isBlocked'] ?? false,
    token: json['token'],
  );

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? image,
    bool? isBlocked,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      image: image ?? this.image,
      isBlocked: isBlocked ?? this.isBlocked,
      token: token ?? this.token,
    );
  }
}
