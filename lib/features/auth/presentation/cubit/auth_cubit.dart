import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../data/models/user_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final Box? _authBox;
  final Box? _usersBox;

  AuthCubit({Box? authBox, Box? usersBox})
      : _authBox = authBox,
        _usersBox = usersBox,
        super(const Unauthenticated()) {
    checkSavedSession();
  }

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  /// Check if user has a persistent login session
  void checkSavedSession() {
    if (_authBox != null) {
      final savedData = _authBox.get('current_user');
      if (savedData != null && savedData is Map) {
        try {
          _currentUser = UserModel.fromJson(savedData);
          emit(Authenticated(_currentUser!));
          return;
        } catch (_) {
          _authBox.delete('current_user');
        }
      }
    }
  }

  /// Sign In with locally persisted accounts or demo account
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 600));

    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty || cleanPassword.isEmpty) {
      emit(const Unauthenticated(
          errorMessage: 'Please enter both email and password'));
      return false;
    }

    // 1. Check local registered users in Hive
    if (_usersBox != null && _usersBox.containsKey(cleanEmail)) {
      final record = _usersBox.get(cleanEmail);
      if (record is Map) {
        final savedPassword = record['password']?.toString() ?? '';
        if (savedPassword == cleanPassword) {
          final userMap = record['user'] as Map?;
          _currentUser = userMap != null
              ? UserModel.fromJson(userMap)
              : UserModel(
                  id: 'USR_${DateTime.now().millisecondsSinceEpoch % 10000}',
                  name: cleanEmail.split('@').first,
                  email: cleanEmail,
                  phone: '+91 98765 43210',
                );

          // Save session
          await _authBox?.put('current_user', _currentUser!.toJson());
          emit(Authenticated(_currentUser!));
          return true;
        } else {
          emit(const Unauthenticated(
              errorMessage: 'Incorrect password. Please try again.'));
          return false;
        }
      }
    }

    // 2. Demo fallback account
    if (cleanEmail == 'alex.johnson@example.com' || cleanEmail == 'demo@example.com') {
      _currentUser = UserModel.demo;
      await _authBox?.put('current_user', _currentUser!.toJson());
      emit(Authenticated(_currentUser!));
      return true;
    }

    // 3. User not found locally
    emit(const Unauthenticated(
      errorMessage: 'No account found with this email. Please register first.',
    ));
    return false;
  }

  /// Register new user and persist to Hive
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 600));

    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();
    final cleanPhone = phone.trim();

    if (cleanName.isEmpty || cleanEmail.isEmpty || password.length < 6) {
      emit(const Unauthenticated(
        errorMessage: 'Please fill all fields properly (Password >= 6 chars)',
      ));
      return false;
    }

    // Check if email already registered
    if (_usersBox != null && _usersBox.containsKey(cleanEmail)) {
      emit(const Unauthenticated(
        errorMessage: 'An account with this email already exists. Please log in.',
      ));
      return false;
    }

    _currentUser = UserModel(
      id: 'USR_${DateTime.now().millisecondsSinceEpoch % 10000}',
      name: cleanName,
      email: cleanEmail,
      phone: cleanPhone,
    );

    // Save user credentials & profile locally
    await _usersBox?.put(cleanEmail, {
      'user': _currentUser!.toJson(),
      'password': password.trim(),
      'registeredAt': DateTime.now().toIso8601String(),
    });

    // Save active session
    await _authBox?.put('current_user', _currentUser!.toJson());

    emit(Authenticated(_currentUser!));
    return true;
  }

  void loginAsGuest() async {
    _currentUser = UserModel.demo;
    await _authBox?.put('current_user', UserModel.demo.toJson());
    emit(const Authenticated(UserModel.demo));
  }

  Future<void> logout() async {
    _currentUser = null;
    await _authBox?.delete('current_user');
    emit(const Unauthenticated());
  }
}
