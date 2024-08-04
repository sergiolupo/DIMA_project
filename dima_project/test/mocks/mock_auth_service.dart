import 'package:dima_project/services/auth_service.dart';
import 'package:mockito/mockito.dart';

class MockAuthService extends Mock implements AuthService {
  static String get uid => 'uid';
}
