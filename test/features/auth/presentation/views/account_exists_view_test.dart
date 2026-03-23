import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:nwdapp/features/auth/presentation/views/account_exists_view.dart';
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
  late TextEditingController passwordController;

  setUp(() {
    mockViewModel = MockLoginViewModel();
    passwordController = TextEditingController();

    when(() => mockViewModel.isLoading).thenReturn(false);
    when(() => mockViewModel.errorMessage).thenReturn(null);
    when(() => mockViewModel.obscurePassword).thenReturn(true);
    when(() => mockViewModel.passwordController).thenReturn(passwordController);
  });

  tearDown(() {
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
                        child: const AccountExistsView(email: 'test@example.com'),
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

  testWidgets('renders account exists correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text("Your account exists"), findsOneWidget);
    expect(find.text("test@example.com"), findsOneWidget);
    expect(find.text("Log In"), findsOneWidget);
    expect(find.text("Continue with Google"), findsOneWidget);
    expect(find.text("Forgot password?"), findsOneWidget);
  });

  testWidgets('calls signInWithEmail when Log In is tapped', (WidgetTester tester) async {
    when(() => mockViewModel.signInWithEmail(any())).thenAnswer((_) async => false);
    passwordController.text = "password123";

    await pumpAndShowLogin(tester);

    final loginBtn = find.widgetWithText(ElevatedButton, 'Log In');
    await tester.ensureVisible(loginBtn);
    await tester.tap(loginBtn);
    await tester.pumpAndSettle();

    verify(() => mockViewModel.signInWithEmail("password123")).called(1);
  });
}
