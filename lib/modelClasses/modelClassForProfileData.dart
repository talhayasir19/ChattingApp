// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ModelClassForProfileData {
  String? name;
  String? phNumber;
  String? imageUrl;
  String? token;

  ModelClassForProfileData({
    this.name,
    this.phNumber,
    this.imageUrl,
    this.token,
  });

  ModelClassForProfileData copyWith({
    String? name,
    String? phNumber,
    String? imageUrl,
    String? token,
  }) {
    return ModelClassForProfileData(
      name: name ?? this.name,
      phNumber: phNumber ?? this.phNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      token: token ?? this.token,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'phoneNumber': phNumber,
      'imageUrl': imageUrl,
      'token': token,
    };
  }

  factory ModelClassForProfileData.fromMap(Map<String, dynamic> map) {
    return ModelClassForProfileData(
      name: map['name'] != null ? map['name'] as String : null,
      phNumber: map['phoneNumber'] != null ? map['phoneNumber'] as String : null,
      imageUrl: map['imageUrl'] != null ? map['imageUrl'] as String : null,
      token: map['token'] != null ? map['token'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ModelClassForProfileData.fromJson(String source) =>
      ModelClassForProfileData.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ModelClassForProfileData(name: $name, phoneNumber: $phNumber, imageUrl: $imageUrl, token: $token)';
  }
}
