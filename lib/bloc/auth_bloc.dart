import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/totp_generator.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;

  const LoginEvent(this.username, this.password);

  @override
  List<Object?> get props => [username, password];
}

class LogoutEvent extends AuthEvent {}

class ClearSecretEvent extends AuthEvent {}

class RecoverSecretEvent extends AuthEvent {
  final String recoveryCode;

  const RecoverSecretEvent(this.recoveryCode);

  @override
  List<Object?> get props => [recoveryCode];
}

class CheckSecretEvent extends AuthEvent {}

// Estados do AuthBloc
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthNeedsSecret extends AuthState {}

class AuthSecretRecovered extends AuthState {}

class AuthLoggedOut extends AuthState {}

// AuthBloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final String baseUrl = 'http://10.0.2.2:5000';

  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<RecoverSecretEvent>(_onRecoverSecret);
    on<CheckSecretEvent>(_onCheckSecret);
    on<ClearSecretEvent>(_onClearSecret);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final secret = await _getSecret();
      if (secret == null) {
        emit(AuthNeedsSecret());
      } else {
        String totpCode = await _generateTOTP(secret);

        final success = await _login(event.username, event.password, totpCode);
        if (success) {
          emit(AuthSuccess());
        } else {
          emit(const AuthFailure("Credenciais inválidas"));
        }
      }
    } catch (e) {
      emit(AuthFailure("Login failed: $e"));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    print("AuthBloc: Received LogoutEvent");

    try {
      emit(AuthLoggedOut());
    } catch (e) {
      emit(AuthFailure("Logout failed: $e"));
    }
  }

  Future<void> _onClearSecret(
      ClearSecretEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('totp_secret');
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure("Failed to clear secret: $e"));
    }
  }

  Future<void> _onRecoverSecret(
      RecoverSecretEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final secret = await _recoverSecret(event.recoveryCode);
      if (secret != null) {
        await _saveSecret(secret);

        emit(AuthSecretRecovered());
      } else {
        emit(const AuthFailure("Código inválido"));
      }
    } catch (e) {
      emit(AuthFailure("Recovery failed: $e"));
    }
  }

  Future<void> _onCheckSecret(
      CheckSecretEvent event, Emitter<AuthState> emit) async {
    final secret = await _getSecret();
    if (secret == null) {
      emit(AuthNeedsSecret());
    } else {
      emit(AuthSuccess());
    }
  }

  Future<bool> _login(String username, String password, String totpCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
        'totp_code': totpCode,
      }),
    );
    return response.statusCode == 200;
  }

  Future<String?> _recoverSecret(String recoveryCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/recovery-secret'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{
        'username': 'admin',
        'password': 'password123',
        'code': recoveryCode,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['totp_secret'];
    }
    return null;
  }

  Future<String> _generateTOTP(String secret) async {
    final totpGenerator = TOTPGenerator(
      secret: secret,
      interval: 30,
      digits: 6,
      algorithm: 'SHA1',
    );

    String totpCode = await totpGenerator.now();

    return totpCode;
  }

  Future<String?> _getSecret() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('totp_secret');
  }

  Future<void> _saveSecret(String secret) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('totp_secret', secret);
  }
}
