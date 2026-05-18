import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج بيانات المستخدم — الأسبوع التاسع
/// يُخزَّن في Firestore تحت collection: users/{uid}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    required this.createdAt,
  });

  // ─── من Firestore Document ────────────────────────────────────────────────
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ─── إلى Map لرفعه لـ Firestore ──────────────────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // ─── نسخة معدّلة (copyWith) ───────────────────────────────────────────────
  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
    );
  }

  @override
  String toString() =>
      'UserModel(uid: $uid, name: $name, email: $email)';
}
