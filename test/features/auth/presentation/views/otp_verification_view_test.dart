import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:nwdapp/features/auth/presentation/views/otp_verification_view.dart';
import 'package:nwdapp/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class MockAuthViewModel extends Mock implements AuthViewModel {
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
  late MockAuthViewModel mockViewModel;
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  setUp(() {
    mockViewModel = MockAuthViewModel();
    controllers = List.generate(6, (_) => TextEditingController());
    focusNodes = List.generate(6, (_) => FocusNode());

    when(() => mockViewModel.isLoading).thenReturn(false);
    when(() => mockViewModel.errorMessage).thenReturn(null);
    when(() => mockViewModel.canResend).thenReturn(false);
    when(() => mockViewModel.secondsRemaining).thenReturn(60);
    when(() => mockViewModel.controllers).thenReturn(controllers);
    when(() => mockViewModel.focusNodes).thenReturn(focusNodes);
    when(() => mockViewModel.sendOtp(any())).thenAnswer((_) async {});
  });

  tearDown(() {
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (innerContext) => Center(
            child: ElevatedButton(
              key: const Key('show_otp_btn'),
              onPressed: () {
                showModalBottomSheet(
                  context: innerContext,
                  isScrollControlled: true,
                  builder: (_) => ChangeNotifierProvider<AuthViewModel>.value(
                    value: mockViewModel,
                    child: const OtpVerificationView(
                      email: 'test@example.com',
                      password: 'password123',
                      name: 'Test Name',
                      phoneNumber: '+1234567890',
                      country: 'Country',
                      city: 'City',
                      nationality: 'Nationality',
                      studyCountry: 'StudyCountry',
                    ),
                  ),
                );
              },
              child: const Text('Show OTP'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pumpAndShowOtp(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('show_otp_btn')));
    await tester.pumpAndSettle();
  }

  testWidgets('renders OTP view correctly and calls sendOtp on init', (WidgetTester tester) async {
    await pumpAndShowOtp(tester);

    expect(find.text("We've sent a 6-digit code to your number."), findsOneWidget);
    expect(find.text("Verify & Register"), findsOneWidget);
    
    // sendOtp should be called on postFrameCallback
    verify(() => mockViewModel.sendOtp('+1234567890')).called(1);
  });

  testWidgets('triggers verifyAndRegister on button tap', (WidgetTester tester) async {
    when(() => mockViewModel.verifyAndRegister(
      email: any(named: 'email'),
      password: any(named: 'password'),
      name: any(named: 'name'),
      phoneNumber: any(named: 'phoneNumber'),
      country: any(named: 'country'),
      city: any(named: 'city'),
      nationality: any(named: 'nationality'),
      studyCountry: any(named: 'studyCountry'),
    )).thenAnswer((_) async => false); // Don't redirect

    await pumpAndShowOtp(tester);

    final verifyBtn = find.text('Verify & Register');
    await tester.ensureVisible(verifyBtn);
    await tester.tap(verifyBtn);
    await tester.pumpAndSettle();

    verify(() => mockViewModel.verifyAndRegister(
      email: 'test@example.com',
      password: 'password123',
      name: 'Test Name',
      phoneNumber: '+1234567890',
      country: 'Country',
      city: 'City',
      nationality: 'Nationality',
      studyCountry: 'StudyCountry',
    )).called(1);
  });

  testWidgets('shows error message if provided by viewmodel', (WidgetTester tester) async {
    when(() => mockViewModel.errorMessage).thenReturn("Invalid OTP code");
    
    await pumpAndShowOtp(tester);

    expect(find.text("Invalid OTP code"), findsOneWidget);
  });
}
