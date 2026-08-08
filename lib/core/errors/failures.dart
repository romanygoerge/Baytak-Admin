import 'package:equatable/equatable.dart';

/// Base failure class for error handling
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});

  factory AuthFailure.fromCode(String code) {
    switch (code) {
      case 'user-not-found':
        return const AuthFailure('المستخدم غير موجود', code: 'user-not-found');
      case 'wrong-password':
        return const AuthFailure('كلمة المرور غير صحيحة', code: 'wrong-password');
      case 'email-already-in-use':
        return const AuthFailure('البريد الإلكتروني مستخدم بالفعل', code: 'email-already-in-use');
      case 'invalid-email':
        return const AuthFailure('البريد الإلكتروني غير صالح', code: 'invalid-email');
      case 'weak-password':
        return const AuthFailure('كلمة المرور ضعيفة', code: 'weak-password');
      case 'too-many-requests':
        return const AuthFailure('محاولات كثيرة، حاول لاحقاً', code: 'too-many-requests');
      case 'user-disabled':
        return const AuthFailure('تم تعطيل الحساب', code: 'user-disabled');
      case 'invalid-verification-code':
        return const AuthFailure('رمز التحقق غير صحيح', code: 'invalid-verification-code');
      case 'invalid-verification-id':
        return const AuthFailure('جلسة التحقق منتهية', code: 'invalid-verification-id');
      default:
        return AuthFailure('خطأ في المصادقة: $code', code: code);
    }
  }
}

class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.code});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'ليس لديك صلاحية']);
}

/// Base exception classes
class ServerException implements Exception {
  final String message;
  final String? code;

  const ServerException(this.message, {this.code});
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}

class NetworkException implements Exception {
  const NetworkException();
}
