import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nwdapp/features/auth/presentation/viewmodels/login_viewmodel.dart';
import 'package:nwdapp/features/auth/data/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockAuthService extends Mock implements AuthService {}
class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late LoginViewModel viewModel;
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    viewModel = LoginViewModel(authService: mockAuthService);
  });

  group('LoginViewModel Logic Tests', () {
    test('Initial state is correct', () {
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
      expect(viewModel.obscurePassword, true);
    });

    test('togglePasswordVisibility updates state', () {
      expect(viewModel.obscurePassword, true);
      viewModel.togglePasswordVisibility();
      expect(viewModel.obscurePassword, false);
    });

    test('validateEmail returns error for invalid email', () {
      expect(viewModel.validateEmail(''), 'Please enter your email');
      expect(viewModel.validateEmail('invalid'), 'Please enter a valid email');
      expect(viewModel.validateEmail('test@example.com'), null);
    });

    test('validatePassword returns error for invalid password', () {
      expect(viewModel.validatePassword(''), 'Please enter your password');
      expect(viewModel.validatePassword('12345'), 'Password must be at least 6 characters');
      expect(viewModel.validatePassword('123456'), null);
    });

    test('signInWithEmail sets error message on failure', () async {
      final Exception testException = Exception('Invalid password');
      when(() => mockAuthService.signInWithEmail(any(), any()))
          .thenThrow(testException);

      viewModel.emailController.text = 'test@example.com';
      final result = await viewModel.signInWithEmail('wrongpassword');

      expect(result, false);
      expect(viewModel.errorMessage, contains('Sign in failed: Exception: Invalid password'));
    });

    test('signInWithEmail returns true on success', () async {
      when(() => mockAuthService.signInWithEmail(any(), any()))
          .thenAnswer((_) async => MockUserCredential());

      viewModel.emailController.text = 'test@example.com';
      final result = await viewModel.signInWithEmail('correctpassword');

      expect(result, true);
      expect(viewModel.errorMessage, null);
    });
  });
}
