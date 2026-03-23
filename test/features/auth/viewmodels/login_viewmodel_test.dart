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
    // Inject the mocked service into the ViewModel
    viewModel = LoginViewModel(authService: mockAuthService);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('LoginViewModel Text Validation', () {
    test('validateEmail returns error for empty or invalid email', () {
      expect(viewModel.validateEmail(''), 'Please enter your email');
      expect(viewModel.validateEmail(null), 'Please enter your email');
      expect(viewModel.validateEmail('invalidemail'), 'Please enter a valid email');
      expect(viewModel.validateEmail('test@test'), 'Please enter a valid email'); // according to regex
      expect(viewModel.validateEmail('test@example.com'), null);
    });

    test('validatePassword returns error for short or empty password', () {
      expect(viewModel.validatePassword(''), 'Please enter your password');
      expect(viewModel.validatePassword(null), 'Please enter your password');
      expect(viewModel.validatePassword('12345'), 'Password must be at least 6 characters');
      expect(viewModel.validatePassword('123456'), null);
    });

    test('togglePasswordVisibility flips obscurePassword boolean', () {
      expect(viewModel.obscurePassword, true);
      viewModel.togglePasswordVisibility();
      expect(viewModel.obscurePassword, false);
      viewModel.togglePasswordVisibility();
      expect(viewModel.obscurePassword, true);
    });
  });

  group('LoginViewModel Actions', () {
    test('checkEmailAndRedirect calls onAccountExists when email exists', () async {
      when(() => mockAuthService.doesEmailExist('test@example.com')).thenAnswer((_) async => true);
      
      viewModel.emailController.text = 'test@example.com';
      bool existsCalled = false;
      bool newCalled = false;

      await viewModel.checkEmailAndRedirect(
        onAccountExists: (email) => existsCalled = true,
        onNewUser: (email) => newCalled = true,
      );

      expect(existsCalled, true);
      expect(newCalled, false);
    });

    test('checkEmailAndRedirect calls onNewUser when email does not exist', () async {
      when(() => mockAuthService.doesEmailExist('new@example.com')).thenAnswer((_) async => false);
      
      viewModel.emailController.text = 'new@example.com';
      bool existsCalled = false;
      bool newCalled = false;

      await viewModel.checkEmailAndRedirect(
        onAccountExists: (email) => existsCalled = true,
        onNewUser: (email) => newCalled = true,
      );

      expect(existsCalled, false);
      expect(newCalled, true);
    });

    test('signInWithGoogle returns false if user has no complete profile', () async {
      when(() => mockAuthService.signInWithGoogle()).thenAnswer((_) async => MockUserCredential());
      when(() => mockAuthService.isUserComplete(any())).thenAnswer((_) async => false);

      final result = await viewModel.signInWithGoogle();
      expect(result, false);
    });

    test('signInWithGoogle returns true if user has a complete profile', () async {
      when(() => mockAuthService.signInWithGoogle()).thenAnswer((_) async => MockUserCredential());
      when(() => mockAuthService.isUserComplete(any())).thenAnswer((_) async => true);

      final result = await viewModel.signInWithGoogle();
      expect(result, true);
    });
  });
}
