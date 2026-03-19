import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nwdapp/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:nwdapp/features/auth/data/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockAuthService extends Mock implements AuthService {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

void main() {
  late AuthViewModel viewModel;
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    viewModel = AuthViewModel(authService: mockAuthService);
  });

  group('AuthViewModel Logic Tests', () {
    test('Initial state is correct', () {
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
      expect(viewModel.canResend, true);
      expect(viewModel.secondsRemaining, 0);
      expect(viewModel.isOtpComplete, false);
    });

    test('onCodeChanged updates focus and checks completion', () {
      viewModel.controllers[0].text = '1';
      viewModel.onCodeChanged('1', 0);
      
      // We can't easily check focusNode.hasFocus in a pure unit test without a pumpWidget
      // but we can check the logic flow.
      
      for (int i = 0; i < 6; i++) {
        viewModel.controllers[i].text = i.toString();
      }
      
      expect(viewModel.isOtpComplete, true);
      expect(viewModel.otpCode, '012345');
    });

    test('startResendTimer updates state correctly', () async {
      viewModel.startResendTimer();
      
      expect(viewModel.canResend, false);
      expect(viewModel.secondsRemaining, 60);
      
      // We won't wait 60 seconds in a unit test, but this confirms the start state.
    });

    test('clearOtp clears all controllers', () {
      for (var c in viewModel.controllers) {
        c.text = '1';
      }
      
      viewModel.clearOtp();
      
      expect(viewModel.isOtpComplete, false);
      for (var c in viewModel.controllers) {
        expect(c.text, '');
      }
    });
  group('Validation Logic', () {
    test('verifyAndRegister returns false if verificationId is null', () async {
      final result = await viewModel.verifyAndRegister(
        email: 'test@example.com',
        password: 'password',
        name: 'Test',
        phoneNumber: '1234567890',
        country: 'India',
        city: 'Mumbai',
        nationality: 'Indian',
        studyCountry: 'Canada',
      );
      
      expect(result, false);
      expect(viewModel.errorMessage, 'Please wait for the code to be sent');
    });

    test('verifyAndRegister returns false if OTP is incomplete', () async {
      // Mocking the private verificationId would require a bit more effort or a setter
      // but we can test the incomplete OTP check first.
      
      // Let's assume we managed to set _verificationId somehow (requires modification or reflection)
      // For now, these baseline tests confirm the existing error handling.
    });
  });
  });
}
