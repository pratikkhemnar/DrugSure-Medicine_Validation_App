class UserModel{
  String name;
  String email;
  String address;
  String phone;

  UserModel({
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
  });
  factory UserModel.fromJson(Map<String,dynamic> jsonData){
    return UserModel(
        name: jsonData["name"] ?? "",
        email: jsonData["email"] ?? "",
        address: jsonData["address"] ?? "",
        phone: jsonData["phone"] ?? ""
    );
  }
}