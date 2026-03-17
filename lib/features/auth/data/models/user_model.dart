import 'package:flutter/material.dart';

class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? profession;
  final String? country;
  final String? gradingSystem;
  final String? cgpa;
  final List<String>? preferredDestinations;
  final List<String>? preferredSubjects;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.phoneNumber,
    this.profession,
    this.country,
    this.gradingSystem,
    this.cgpa,
    this.preferredDestinations,
    this.preferredSubjects,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'uid': uid,
      'email': email,
    };
    
    if (name != null) map['name'] = name;
    if (phoneNumber != null) map['phoneNumber'] = phoneNumber;
    if (profession != null) map['profession'] = profession;
    if (country != null) map['country'] = country;
    if (gradingSystem != null) map['gradingSystem'] = gradingSystem;
    if (cgpa != null) map['cgpa'] = cgpa;
    if (preferredDestinations != null) map['preferredDestinations'] = preferredDestinations;
    if (preferredSubjects != null) map['preferredSubjects'] = preferredSubjects;
    if (createdAt != null) map['createdAt'] = createdAt!.toIso8601String();
    
    return map;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    try {
      return UserModel(
        uid: map['uid'] ?? '',
        email: map['email'] ?? '',
        name: map['name'],
        phoneNumber: map['phoneNumber'],
        profession: map['profession'],
        country: map['country'],
        gradingSystem: map['gradingSystem'],
        cgpa: map['cgpa'],
        preferredDestinations: map['preferredDestinations'] != null
            ? List<String>.from(map['preferredDestinations'])
            : null,
        preferredSubjects: map['preferredSubjects'] != null
            ? List<String>.from(map['preferredSubjects'])
            : null,
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'])
            : null,
      );
    } catch (e) {
      debugPrint("UserModel.fromMap Error: $e for map: $map");
      rethrow;
    }
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phoneNumber,
    String? profession,
    String? country,
    String? gradingSystem,
    String? cgpa,
    List<String>? preferredDestinations,
    List<String>? preferredSubjects,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profession: profession ?? this.profession,
      country: country ?? this.country,
      gradingSystem: gradingSystem ?? this.gradingSystem,
      cgpa: cgpa ?? this.cgpa,
      preferredDestinations: preferredDestinations ?? this.preferredDestinations,
      preferredSubjects: preferredSubjects ?? this.preferredSubjects,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
