// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AppEvent {}

@immutable
class AppEventUploadImage implements AppEvent {
  final String filePathToUpload;
  const AppEventUploadImage({
    required this.filePathToUpload,
  });
}

@immutable
class AppEventDeleteAccount implements AppEvent {
  const AppEventDeleteAccount();
}

@immutable
class AppEventLogout implements AppEvent {
  const AppEventLogout();
}

@immutable
class AppEventInitialize implements AppEvent {
  const AppEventInitialize();
}

@immutable
class AppEventLogin implements AppEvent {
  final String email;
  final String password;
  const AppEventLogin({
    required this.email,
    required this.password,
  });
}

@immutable
class AppEventGoToRegistration implements AppEvent {
  const AppEventGoToRegistration();
}

@immutable
class AppEventGoToLogin implements AppEvent {
  const AppEventGoToLogin();
}

@immutable
class AppEventRegister implements AppEvent {
  final String email;
  final String password;
  const AppEventRegister({
    required this.email,
    required this.password,
  });
}
