import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nwdapp/features/auth/presentation/viewmodels/profile_viewmodel.dart';
import 'package:nwdapp/features/auth/data/auth_service.dart';
import 'package:nwdapp/features/auth/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockAuthService extends Mock implements AuthService {}
class FakeUserModel extends Fake implements UserModel {}
class MockUser extends Mock implements User {}

void main() {
  late ProfileViewModel viewModel;
  late MockAuthService mockAuthService;

  setUpAll(() {
    registerFallbackValue(FakeUserModel());
  });

  setUp(() {
    mockAuthService = MockAuthService();
    viewModel = ProfileViewModel(authService: mockAuthService);
  });

  group('ProfileViewModel Initialization', () {
    test('initial states are correctly setup', () {
      expect(viewModel.isLoading, false);
      expect(viewModel.isStudyLevelExpanded, false);
      expect(viewModel.isStartDateExpanded, false);
      expect(viewModel.selectedStartYear, isNotNull);
      expect(viewModel.selectedStudyLevel, isNull);
      expect(viewModel.selectedMonthRange, isNull);
    });

    test('has valid dropdown options', () {
      expect(viewModel.studyLevels.length, 4);
      expect(viewModel.years.length, 4);
      expect(viewModel.months.length, 4);
      expect(viewModel.years.first, DateTime.now().year.toString());
    });
  });

  group('ProfileViewModel Selection Logics', () {
    test('can set Study Level', () {
      viewModel.setStudyLevel('Undergraduate');
      expect(viewModel.selectedStudyLevel, 'Undergraduate');
    });

    test('can set Start Year and Month Range', () {
      viewModel.setStartYear('2026');
      expect(viewModel.selectedStartYear, '2026');

      viewModel.setMonthRange('Apr - June');
      expect(viewModel.selectedMonthRange, 'Apr - June');
    });

    test('toggling expanded states works', () {
      expect(viewModel.isStudyLevelExpanded, false);
      viewModel.toggleStudyLevelExpansion();
      expect(viewModel.isStudyLevelExpanded, true);

      expect(viewModel.isStartDateExpanded, false);
      viewModel.toggleStartDateExpansion();
      expect(viewModel.isStartDateExpanded, true);

      // Toggling opposite hides the other
      viewModel.toggleStudyLevelExpansion();
      // Should close Start Date and open Study Level
      expect(viewModel.isStudyLevelExpanded, true);
    });
  });

  group('ProfileViewModel Save Logic', () {
    test('saveProfile fails if selections are missing', () async {
      final success = await viewModel.saveProfile();

      expect(success, false);
      // ProfileViewModel handles missing selections with CustomSnackbar, returning false.
    });

    test('saveProfile succeeds and calls auth service when valid', () async {
      viewModel.setStudyLevel('Undergraduate');
      viewModel.setStartYear('2026');
      viewModel.setMonthRange('Apr - June');

      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('test-uid');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockAuthService.currentUser).thenReturn(mockUser);
      when(() => mockAuthService.getUserData(any())).thenAnswer((_) async => null);
      when(() => mockAuthService.saveUserData(any())).thenAnswer((_) async {});

      final success = await viewModel.saveProfile();

      expect(success, true);
      verify(() => mockAuthService.saveUserData(any())).called(1);
    });
  });
}
