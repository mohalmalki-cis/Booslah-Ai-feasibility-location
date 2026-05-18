import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// خدمة المصادقة — الأسبوع التاسع
/// تتعامل مع Firebase Auth وFirestore لإدارة المستخدمين

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Stream حالة تسجيل الدخول ─────────────────────────────────────────────
  /// يُصدر null إذا المستخدم غير مسجل، وكائن User إذا مسجّل
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// المستخدم الحالي (قد يكون null)
  User? get currentUser => _auth.currentUser;

  // ─── تسجيل حساب جديد ─────────────────────────────────────────────────────
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    // 1. إنشاء الحساب في Firebase Auth
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;

    // 2. تحديث الاسم في Firebase Auth
    await credential.user!.updateDisplayName(name.trim());

    // 3. حفظ بيانات المستخدم في Firestore
    final userModel = UserModel(
      uid: uid,
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      createdAt: DateTime.now(),
    );

    await _db
        .collection('users')
        .doc(uid)
        .set(userModel.toFirestore());

    return userModel;
  }

  // ─── تسجيل الدخول ────────────────────────────────────────────────────────
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;
    return await _getUserFromFirestore(uid);
  }

  // ─── تسجيل الخروج ────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ─── إعادة تعيين كلمة المرور ──────────────────────────────────────────────
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ─── جلب بيانات المستخدم من Firestore ────────────────────────────────────
  Future<UserModel> _getUserFromFirestore(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) {
      // بيانات احتياطية من Firebase Auth إذا لم توجد في Firestore
      final authUser = _auth.currentUser!;
      return UserModel(
        uid: uid,
        name: authUser.displayName ?? '',
        email: authUser.email ?? '',
        phone: '',
        createdAt: DateTime.now(),
      );
    }

    return UserModel.fromFirestore(doc);
  }

  /// جلب بيانات المستخدم الحالي من Firestore
  Future<UserModel?> getCurrentUserData() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    return await _getUserFromFirestore(uid);
  }

  // ─── تحديث الملف الشخصي ──────────────────────────────────────────────────
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String phone,
  }) async {
    await _db.collection('users').doc(uid).update({
      'name': name.trim(),
      'phone': phone.trim(),
    });

    // تحديث الاسم في Firebase Auth أيضاً
    await _auth.currentUser?.updateDisplayName(name.trim());
  }

  // ─── تحويل أخطاء Firebase إلى رسائل عربية ────────────────────────────────
  static String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'البريد الإلكتروني غير مسجّل';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'invalid-credential':
        return 'البريد أو كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مسجّل مسبقاً';
      case 'weak-password':
        return 'كلمة المرور ضعيفة، استخدم 6 أحرف على الأقل';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة';
      case 'too-many-requests':
        return 'محاولات كثيرة، يرجى المحاولة لاحقاً';
      case 'network-request-failed':
        return 'تحقق من اتصالك بالإنترنت';
      default:
        return 'حدث خطأ: ${e.message}';
    }
  }
}
