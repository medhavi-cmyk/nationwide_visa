import 'package:flutter_test/flutter_test.dart';
import 'package:nwdapp/features/auth/presentation/viewmodels/register_viewmodel.dart';

void main() {
  late RegisterViewModel viewModel;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    viewModel = RegisterViewModel();
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('RegisterViewModel Initialization', () {
    test('initial values are correct', () {
      expect(viewModel.isGoogleOnboarding, false);
      expect(viewModel.receiveUpdates, true);
      expect(viewModel.obscurePassword, true);
      expect(viewModel.agreedToTerms, false);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
    });

    test('prefillFromGoogle sets name and onboarding state', () {
      viewModel.setGoogleOnboarding(true);
      viewModel.prefillFromGoogle(name: 'Test Name');

      expect(viewModel.isGoogleOnboarding, true);
      expect(viewModel.nameController.text, 'Test Name');
    });

    test('toggle states flip their values correctly', () {
      viewModel.togglePasswordVisibility();
      expect(viewModel.obscurePassword, false);

      viewModel.toggleAgreedToTerms(true);
      expect(viewModel.agreedToTerms, true);
    });
  });

  group('RegisterViewModel Form Validations', () {
    test('validateRequired works properly', () {
      expect(viewModel.validateFullName(''), 'This Field is required to proceed');
      expect(viewModel.validateFullName(null), 'This Field is required to proceed');
      expect(viewModel.validateFullName('John Doe'), null);
    });

    test('validatePhone requires 10 digits', () {
      expect(viewModel.validatePhone(''), 'Phone number is required');
      expect(viewModel.validatePhone('123'), 'Please enter a valid 10-digit phone number');
      expect(viewModel.validatePhone('1234567890'), null);
      expect(viewModel.validatePhone('123 456 7890'), null); // Spaces are removed inside validatePhone
    });

    test('validatePassword ignores if Google Onboarding is active', () {
      viewModel.setGoogleOnboarding(true);
      expect(viewModel.validatePassword('weak'), null);
    });

    test('validatePassword enforces strong requirements', () {
      viewModel.setGoogleOnboarding(false);
      expect(viewModel.validatePassword('12345678'), 'Password must have 8 characters with a number, symbol, uppercase and lowercase');
      expect(viewModel.validatePassword('Password'), 'Password must have 8 characters with a number, symbol, uppercase and lowercase');
      expect(viewModel.validatePassword('Password123'), 'Password must have 8 characters with a number, symbol, uppercase and lowercase');
      expect(viewModel.validatePassword('StrongPass1!'), null);
    });
  });

  group('RegisterViewModel Country Logic', () {
    test('updateCountry maps data correctly and resets city', () {
      viewModel.cityController.text = 'Old City';
      
      viewModel.updateCountry({
        'name': 'United States',
        'id': 1,
        'iso2': 'US',
        'iso3': 'USA',
      });

      expect(viewModel.countryController.text, 'United States');
      expect(viewModel.cityController.text, '');
      expect(viewModel.isCountrySelected, true);
    });
  });
}
