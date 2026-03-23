import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:nwdapp/features/auth/presentation/views/login_view.dart';
import 'package:nwdapp/features/auth/presentation/viewmodels/login_viewmodel.dart';

class MockLoginViewModel extends Mock implements LoginViewModel {
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
  late MockLoginViewModel mockViewModel;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  setUp(() {
    mockViewModel = MockLoginViewModel();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    // Default stubbing
    when(() => mockViewModel.isLoading).thenReturn(false);
    when(() => mockViewModel.errorMessage).thenReturn(null);
    when(() => mockViewModel.showSuggestions).thenReturn(false);
    when(() => mockViewModel.obscurePassword).thenReturn(true);
    when(() => mockViewModel.emailController).thenReturn(emailController);
    when(() => mockViewModel.passwordController).thenReturn(passwordController);
    when(() => mockViewModel.formKey).thenReturn(GlobalKey<FormState>());
  });

  tearDown(() {
    emailController.dispose();
    passwordController.dispose();
  });

  Widget createTestWidget() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Builder(
              builder: (innerContext) => Center(
                child: ElevatedButton(
                  key: const Key('show_login_btn'),
                  onPressed: () {
                    showModalBottomSheet(
                      context: innerContext,
                      isScrollControlled: true,
                      builder: (_) => ChangeNotifierProvider<LoginViewModel>.value(
                        value: mockViewModel,
                        child: const LoginView(),
                      ),
                    );
                  },
                  child: const Text('Show Login'),
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('HomeView')),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  Future<void> pumpAndShowLogin(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('show_login_btn')));
    await tester.pumpAndSettle();
  }

  testWidgets('renders login view correctly', (WidgetTester tester) async {
    when(() => mockViewModel.validateEmail(any())).thenReturn(null);

    await pumpAndShowLogin(tester);

    // Verify UI elements are present
    expect(find.text('Your one-stop platform for all things study abroad'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Apple'), findsOneWidget);

    // Verify stats row
    expect(find.text('Google rating'), findsOneWidget);
    expect(find.text('Students counselled'), findsOneWidget);
    expect(find.text('Courses available'), findsOneWidget);
  });

  testWidgets('shows validation error when email is invalid', (WidgetTester tester) async {
    // Return an error when validateEmail is called
    when(() => mockViewModel.validateEmail(any())).thenReturn('Please enter a valid email');
    when(() => mockViewModel.validateForm()).thenReturn(false);

    await pumpAndShowLogin(tester);

    // Enter invalid text to trigger validation
    await tester.enterText(find.byType(TextFormField).first, 'invalid_email');
    await tester.pumpAndSettle();

    // Tap outside to unfocus or just tap the continue button to trigger validation
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email'), findsOneWidget);
  });

  testWidgets('calls checkEmailAndRedirect when Continue is tapped with valid email', (WidgetTester tester) async {
    when(() => mockViewModel.validateEmail(any())).thenReturn(null);
    when(() => mockViewModel.validateForm()).thenReturn(true);
    when(() => mockViewModel.checkEmailAndRedirect(
      onAccountExists: any(named: 'onAccountExists'),
      onNewUser: any(named: 'onNewUser'),
    )).thenAnswer((_) async {});

    await pumpAndShowLogin(tester);

    // Enter a valid email
    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.pumpAndSettle();

    final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Verify checkEmailAndRedirect was called
    verify(() => mockViewModel.checkEmailAndRedirect(
      onAccountExists: any(named: 'onAccountExists'),
      onNewUser: any(named: 'onNewUser'),
    )).called(1);
  });

  testWidgets('calls signInWithGoogle when Google button is tapped', (WidgetTester tester) async {
    when(() => mockViewModel.validateEmail(any())).thenReturn(null);
    when(() => mockViewModel.signInWithGoogle()).thenAnswer((_) async => true);

    await pumpAndShowLogin(tester);

    // Find and tap the Google button
    final googleButton = find.text('Continue with Google');
    expect(googleButton, findsOneWidget);
    
    await tester.ensureVisible(googleButton);
    await tester.tap(googleButton);
    await tester.pumpAndSettle();

    // Verify signInWithGoogle was called
    verify(() => mockViewModel.signInWithGoogle()).called(1);
  });
}
