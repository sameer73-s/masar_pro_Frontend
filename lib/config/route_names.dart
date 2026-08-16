/// Central route path constants (features register against these names).
abstract final class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const login = '/login';
  static const loginBiometric = '/login-biometric';
  static const home = '/home';
  static const register = '/register';
  static const pending = '/pending';
  static const requests = '/requests';
  static const fingerprintExemption = '/fingerprint-exemption';
  static const advanceRequest = '/advance-request';
  static const trustRequest = '/trust-request';
  static const visitorsRegistrationRequest = '/visitors-registration-request';
  static const customRequest = '/custom-request';
  static const permitRequest = '/permit-request';
  static const taskRequest = '/task-request';
  static const assignmentRequest = '/assignment-request';
  static const vacationRequest = '/vacation-request';
  static const reports = '/reports';
}
