class UserModel {
  final String name;
  final String propic;
  final String probanner;
  final String uid;
  final bool isAdmin;
  UserModel({
    required this.name,
    required this.propic,
    required this.probanner,
    required this.uid,
    required this.isAdmin,
  });

  UserModel copyWith({
    String? name,
    String? propic,
    String? probanner,
    String? uid,
    bool? isAdmin,
  }) {
    return UserModel(
      name: name ?? this.name,
      propic: propic ?? this.propic,
      probanner: probanner ?? this.probanner,
      uid: uid ?? this.uid,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'propic': propic,
      'probanner': probanner,
      'uid': uid,
      'isAdmin': isAdmin,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      propic: map['propic'] ?? '',
      probanner: map['probanner'] ?? '',
      uid: map['uid'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, propic: $propic, probanner: $probanner, uid: $uid, isAdmin: $isAdmin)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.name == name &&
        other.propic == propic &&
        other.probanner == probanner &&
        other.uid == uid &&
        other.isAdmin == isAdmin;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        propic.hashCode ^
        probanner.hashCode ^
        uid.hashCode ^
        isAdmin.hashCode;
  }
}