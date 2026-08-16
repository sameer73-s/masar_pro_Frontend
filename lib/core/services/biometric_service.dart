import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

sealed class BiometricAvailability extends Equatable {
  const BiometricAvailability();
  @override
  List<Object?> get props => [];
}

class BiometricAvailable extends BiometricAvailability {
  const BiometricAvailable();
}

class BiometricNoHardware extends BiometricAvailability {
  const BiometricNoHardware();
}

class BiometricNotEnrolled extends BiometricAvailability {
  const BiometricNotEnrolled();
}

sealed class BiometricAuthResult extends Equatable {
  const BiometricAuthResult();
  @override
  List<Object?> get props => [];
}

class BiometricSuccess extends BiometricAuthResult {
  const BiometricSuccess();
}

class BiometricUserCanceled extends BiometricAuthResult {
  const BiometricUserCanceled();
}

class BiometricLockedOut extends BiometricAuthResult {
  const BiometricLockedOut();
}

class BiometricFailure extends BiometricAuthResult {
  const BiometricFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class BiometricService {
  Future<BiometricAvailability> canAuthenticate() async {
    return const BiometricNoHardware();
  }

  Future<BiometricAuthResult> authenticate({required String reason}) async {
    return const BiometricFailure('Stubbed');
  }
}
