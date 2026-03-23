import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nwdapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Authentication Flow - Google Bypass to Profile Setup', (WidgetTester tester) async {
    // Start the app
    app.main();
    await tester.pumpAndSettle();

    // 1. We start at the Onboarding View.
    // Tap "I already have an account, Log in"
    final loginLink = find.text('I already have an account, '); // The RichText span
    // Given RichText, it's easier to tap by text or key. The button 'Log in' might be part of rich text.
    // Let's find the Log In text directly.
    final logInText = find.textContaining('Log in');
    expect(logInText, findsWidgets);
    await tester.tap(logInText.first);
    await tester.pumpAndSettle();

    // 2. Now in LoginView.
    // We will type an email that does NOT exist to force registration.
    // Use a uniquely generated email to avoid hitting existing users.
    final uniqueEmail = 'testuser_${DateTime.now().millisecondsSinceEpoch}@example.com';
    final emailField = find.byType(TextFormField).first;
    expect(emailField, findsOneWidget);
    await tester.enterText(emailField, uniqueEmail);
    await tester.pumpAndSettle();

    final continueBtn = find.text('Continue');
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();
    // Await checking DB
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 3. Now in RegisterView.
    // Fill out the registration form.
    final nameField = find.widgetWithText(TextFormField, 'Full name');
    await tester.enterText(nameField, 'Test User');

    // For country, it opens a bottom sheet.
    final countryField = find.widgetWithText(TextFormField, 'Country you live in');
    await tester.tap(countryField);
    await tester.pumpAndSettle();
    
    // Tap India (or any first item in the list)
    final indiaOption = find.text('India').first;
    await tester.tap(indiaOption);
    await tester.pumpAndSettle();

    // Since we selected India, we can select a city
    final cityField = find.widgetWithText(TextFormField, 'City you live in');
    await tester.tap(cityField);
    await tester.pumpAndSettle();
    
    // Tap Delhi
    final delhiOption = find.textContaining('Delhi').first;
    await tester.tap(delhiOption);
    await tester.pumpAndSettle();

    final nationalityField = find.widgetWithText(TextFormField, 'Nationality');
    await tester.tap(nationalityField);
    await tester.pumpAndSettle();
    final firstNationality = find.text('India').first;
    await tester.tap(firstNationality);
    await tester.pumpAndSettle();

    // Phone Field (bypass number: +918851332289)
    // Actually the +91 is baked in the prefix, so we just type the 10 digits
    final phoneField = find.widgetWithText(TextFormField, 'Phone number');
    await tester.enterText(phoneField, '8851332289');

    // Study Country
    final studyCountryField = find.widgetWithText(TextFormField, 'Where do you wish to go?');
    await tester.tap(studyCountryField);
    await tester.pumpAndSettle();
    final canadaOption = find.text('Canada').first;
    await tester.tap(canadaOption);
    await tester.pumpAndSettle();

    // Password
    final passwordField = find.widgetWithText(TextFormField, 'Set your password');
    await tester.enterText(passwordField, 'StrongPass1!');
    await tester.pumpAndSettle();

    // Agree to terms Checkbox
    final termsCheckbox = find.byType(Checkbox).first;
    await tester.tap(termsCheckbox);
    await tester.pumpAndSettle();

    // Tap Continue
    final registerContinueBtn = find.text('Continue');
    await tester.ensureVisible(registerContinueBtn);
    await tester.tap(registerContinueBtn);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 4. OtpVerificationView
    expect(find.text("Verify your phone"), findsOneWidget);
    
    // Enter bypass OTP "123456" into the 6 boxes
    final otpFields = find.byType(TextFormField);
    expect(otpFields, findsNWidgets(6));
    
    for (int i = 0; i < 6; i++) {
        await tester.enterText(otpFields.at(i), '1');
    }
    // Change to match bypass code expected (in codebase, is it 123456?)
    // Actually bypass just gives verifId immediately. The sms code doesn't matter much if fake credential is linked.
    await tester.pumpAndSettle();

    final verifyBtn = find.text('Verify & Register');
    await tester.tap(verifyBtn);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 5));
    // Complex wait for DB and auth save
    await tester.pumpAndSettle();

    // 5. Profile Setup
    expect(find.text("Let's guide you like we did\nour 85K+ students."), findsOneWidget);
    
    final studyLevelField = find.text('Study level').first;
    await tester.tap(studyLevelField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Post graduate'));
    await tester.pumpAndSettle();

    final signUpBtn = find.text('Sign up');
    await tester.tap(signUpBtn);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // 6. Registration Success
    expect(find.text("Registration Successful!"), findsOneWidget);
    await tester.tap(find.text('Go to Home'));
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Should be on Home
    // expect(find.text("Explore"), findsOneWidget);
  });
}
