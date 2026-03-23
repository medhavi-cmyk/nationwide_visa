import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:nwdapp/features/auth/presentation/views/profile_setup_view.dart';
import 'package:nwdapp/features/auth/presentation/viewmodels/profile_viewmodel.dart';

class MockProfileViewModel extends Mock implements ProfileViewModel {
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
  late MockProfileViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockProfileViewModel();

    when(() => mockViewModel.isLoading).thenReturn(false);
    when(() => mockViewModel.isAnyExpanded).thenReturn(false);
    when(() => mockViewModel.isStudyLevelExpanded).thenReturn(false);
    when(() => mockViewModel.isStartDateExpanded).thenReturn(false);
    
    when(() => mockViewModel.selectedStudyLevel).thenReturn(null);
    when(() => mockViewModel.selectedStartYear).thenReturn(null);
    when(() => mockViewModel.selectedMonthRange).thenReturn(null);
    
    when(() => mockViewModel.studyLevels).thenReturn(['Undergraduate', 'Post graduate']);
    when(() => mockViewModel.years).thenReturn(['2026', '2027']);
    when(() => mockViewModel.months).thenReturn(['Jan-Mar', 'Apr-Jun']);
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (innerContext) => Center(
            child: ElevatedButton(
              key: const Key('show_profile_btn'),
              onPressed: () {
                showModalBottomSheet(
                  context: innerContext,
                  isScrollControlled: true,
                  builder: (_) => ChangeNotifierProvider<ProfileViewModel>.value(
                    value: mockViewModel,
                    child: const ProfileSetupView(),
                  ),
                );
              },
              child: const Text('Show Profile'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pumpAndShowProfile(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('show_profile_btn')));
    await tester.pumpAndSettle();
  }

  testWidgets('renders profile setup view correctly', (WidgetTester tester) async {
    await pumpAndShowProfile(tester);

    expect(find.text("Let's guide you like we did\nour 85K+ students."), findsOneWidget);
    expect(find.text("Study level"), findsOneWidget);
    expect(find.text("Start date"), findsOneWidget);
    expect(find.text("Sign up"), findsOneWidget);
  });

  testWidgets('shows expanded options when tapped', (WidgetTester tester) async {
    // Override default to be expanded
    when(() => mockViewModel.isStudyLevelExpanded).thenReturn(true);
    when(() => mockViewModel.isAnyExpanded).thenReturn(true);

    await pumpAndShowProfile(tester);

    expect(find.text("Undergraduate"), findsOneWidget);
    expect(find.text("Post graduate"), findsOneWidget);
  });

  testWidgets('calls saveProfile when Sign up is tapped', (WidgetTester tester) async {
    when(() => mockViewModel.saveProfile()).thenAnswer((_) async => false);

    await pumpAndShowProfile(tester);

    final signUpBtn = find.widgetWithText(ElevatedButton, 'Sign up');
    await tester.ensureVisible(signUpBtn);
    await tester.tap(signUpBtn);
    await tester.pumpAndSettle();

    verify(() => mockViewModel.saveProfile()).called(1);
  });
}
