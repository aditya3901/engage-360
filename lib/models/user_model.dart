class UserModel {
  String? name;
  String? phone;
  String? image;
  String? faceId;

  UserModel({this.name, this.phone, this.image, this.faceId});

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    phone = json['phone'];
    image = json['image'];
    faceId = json['faceId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['phone'] = phone;
    data['image'] = image;
    data['faceId'] = faceId;
    return data;
  }
}
