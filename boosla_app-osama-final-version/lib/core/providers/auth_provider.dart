import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// حالات AuthProvider
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Auth Provider — الأسبوع التاسع
/// يُدير حالة تسجيل الدخول عبر كامل التطبيق

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  // ─── Getters ──────────────────────────────────────────────────────────────
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // ─── Constructor: يستمع لحالة Auth تلقائياً ──────────────────────────────
  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _user = null;
    } else {
      _status = AuthStatus.loading;
      notifyListeners();

      try {
        _user = await _authService.getCurrentUserData();
        // إذا رجع null من Firestore، نبني الموديل من Firebase Auth مباشرة
        _user ??= UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          phone: '',
          createdAt: DateTime.now(),
        );
        _status = AuthStatus.authenticated;
      } catch (_) {
        // fallback: uid دائماً موجود من Firebase Auth حتى لو Firestore فشل
        _user = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          phone: '',
          createdAt: DateTime.now(),
        );
        _status = AuthStatus.authenticated;
      }
    }
    notifyListeners();
  }

  // ─── تسجيل الدخول ────────────────────────────────────────────────────────
  Future<bool> login({required String email, required String password}) async {
    _setLoading();
    try {
      _user = await _authService.login(email: email, password: password);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(AuthService.getErrorMessage(e));
      return false;
    } on FirebaseException catch (e) {
      _setError('خطأ في قاعدة البيانات: ${e.message ?? e.code}');
      return false;
    } catch (e) {
      _setError('خطأ غير متوقع: $e');
      return false;
    }
  }

  // ─── إنشاء حساب ──────────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    _setLoading();
    try {
      _user = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(AuthService.getErrorMessage(e));
      return false;
    } on FirebaseException catch (e) {
      _setError('خطأ في قاعدة البيانات: ${e.message ?? e.code}');
      return false;
    } catch (e) {
      _setError('خطأ غير متوقع: $e');
      return false;
    }
  }

  // ─── تسجيل الخروج ────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ─── إعادة تعيين كلمة المرور ─────────────────────────────────────────────
  Future<bool> resetPassword(String email) async {
    _setLoading();
    try {
      await _authService.resetPassword(email);
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(AuthService.getErrorMessage(e));
      return false;
    }
  }

  // ─── تحديث الملف الشخصي ──────────────────────────────────────────────────
  Future<bool> updateProfile({
    required String name,
    required String phone,
  }) async {
    if (_user == null) return false;
    try {
      await _authService.updateProfile(
        uid: _user!.uid,
        name: name,
        phone: phone,
      );
      _user = _user!.copyWith(name: name, phone: phone);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}
