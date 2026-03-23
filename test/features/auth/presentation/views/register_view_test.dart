import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:nwdapp/features/auth/presentation/views/register_view.dart';
import 'package:nwdapp/features/auth/presentation/viewmodels/register_viewmodel.dart';

class MockRegisterViewModel extends Mock implements RegisterViewModel {
  @override
  void addListener(VoidCallback listener) {}
  @override
  void removeListener(VoidCallback listener) {}
  @override
  void dispose() {}
  @override
  bool get hasListeners => false;
  @override
  void notifyListeners() {}
}

void main() {
  late MockRegisterViewModel mockViewModel;
  late TextEditingController nameController;
  late TextEditingController countryController;
  late TextEditingController cityController;
  late TextEditingController nationalityController;
  late TextEditingController phoneController;
  late TextEditingController studyCountryController;
  late TextEditingController passwordController;

  setUp(() {
    mockViewModel = MockRegisterViewModel();
    nameController = TextEditingController();
    countryController = TextEditingController();
    cityController = TextEditingController();
    nationalityController = TextEditingController();
    phoneController = TextEditingController();
    studyCountryController = TextEditingController();
    passwordController = TextEditingController();

    when(() => mockViewModel.isLoading).thenReturn(false);
    when(() => mockViewModel.isGoogleOnboarding).thenReturn(false);
    when(() => mockViewModel.obscurePassword).thenReturn(true);
    when(() => mockViewModel.agreedToTerms).thenReturn(false);
    when(() => mockViewModel.isCountrySelected).thenReturn(false);

    when(() => mockViewModel.nameController).thenReturn(nameController);
    when(() => mockViewModel.countryController).thenReturn(countryController);
    when(() => mockViewModel.cityController).thenReturn(cityController);
    when(() => mockViewModel.nationalityController).thenReturn(nationalityController);
    when(() => mockViewModel.phoneController).thenReturn(phoneController);
    when(() => mockViewModel.studyCountryController).thenReturn(studyCountryController);
    when(() => mockViewModel.passwordController).thenReturn(passwordController);
    when(() => mockViewModel.formKey).thenReturn(GlobalKey<FormState>());
  });

  tearDown(() {
    nameController.dispose();
    countryController.dispose();
    cityController.dispose();
    nationalityController.dispose();
    phoneController.dispose();
    studyCountryController.dispose();
    passwordController.dispose();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (innerContext) => Center(
            child: ElevatedButton(
              key: const Key('show_register_btn'),
              onPressed: () {
                showModalBottomSheet(
                  context: innerContext,
                  isScrollControlled: true,
                  builder: (_) => ChangeNotifierProvider<RegisterViewModel>.value(
                    value: mockViewModel,
                    child: const RegisterView(email: 'test@example.com'),
                  ),
                );
              },
              child: const Text('Show Register'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pumpAndShowRegister(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('show_register_btn')));
    await tester.pumpAndSettle();
  }

  testWidgets('renders register view correctly', (WidgetTester tester) async {
    await pumpAndShowRegister(tester);

    expect(find.text("Choose from best country to work or study abroad"), findsOneWidget);
    expect(find.text("Full name"), findsOneWidget);
    expect(find.text("Country you live in"), findsOneWidget);
    expect(find.text("City you live in"), findsOneWidget);
    expect(find.text("Nationality"), findsOneWidget);
    expect(find.text("Phone number"), findsOneWidget);
    expect(find.text("Where do you wish to go?"), findsOneWidget);
    expect(find.text("Set your password"), findsOneWidget);
    expect(find.text("Continue"), findsOneWidget);
  });

  testWidgets('shows warning if terms are not accepted', (WidgetTester tester) async {
    when(() => mockViewModel.agreedToTerms).thenReturn(false);

    await pumpAndShowRegister(tester);

    final continueBtn = find.text('Continue');
    await tester.ensureVisible(continueBtn);
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    // CustomSnackbar is hard to mock easily without wrapping in a custom way,
    // but we can verify that validateForm is NEVER called because agreedToTerms is false
    verifyNever(() => mockViewModel.validateForm());
  });

  testWidgets('calls validateForm when terms accepted and continue is tapped', (WidgetTester tester) async {
    when(() => mockViewModel.agreedToTerms).thenReturn(true);
    when(() => mockViewModel.validateForm()).thenReturn(false); // don't redirect yet

    await pumpAndShowRegister(tester);

    final continueBtn = find.text('Continue');
    await tester.ensureVisible(continueBtn);
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    verify(() => mockViewModel.validateForm()).called(1);
  });
}
