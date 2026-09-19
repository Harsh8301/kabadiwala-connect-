import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/ministry_app.dart';
import 'package:kabadiwala_connect/ministry_controller.dart';
import 'package:kabadiwala_connect/models/workflow_models.dart';
import 'package:kabadiwala_connect/repositories/workflow_repositories.dart';

class WidgetMemoryRepository implements LocalRepository {
  CollectorProfile? profile;
  List<DigitalLot> lots = [];
  DateTime? lastSync;

  @override
  Future<void> clearProfile() async => profile = null;
  @override
  Future<DateTime?> loadLastSync() async => lastSync;
  @override
  Future<List<DigitalLot>> loadLots() async => [...lots];
  @override
  Future<CollectorProfile?> loadProfile() async => profile;
  @override
  Future<void> saveLastSync(DateTime value) async => lastSync = value;
  @override
  Future<void> saveLots(List<DigitalLot> value) async => lots = [...value];
  @override
  Future<void> saveProfile(CollectorProfile value) async => profile = value;
}

class WidgetRemoteRepository implements RemoteRepository {
  @override
  Future<void> uploadLot(DigitalLot lot) async {}
}

void main() {
  testWidgets('splash and landing logo are responsive and navigation runs once',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = MinistryController(
      localRepository: WidgetMemoryRepository(),
      remoteRepository: WidgetRemoteRepository(),
      enableTts: false,
      initialOnline: false,
      monitorConnectivity: false,
    )..setLanguage('en');
    addTearDown(controller.dispose);

    await tester.pumpWidget(MinistryApp(controller: controller));
    expect(find.bySemanticsLabel('Kabadiwala Connect logo'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();
    expect(find.text('Simple, safer scrap collection'), findsOneWidget);
    expect(find.bySemanticsLabel('Kabadiwala Connect logo'), findsOneWidget);
    expect(find.byTooltip('Language'), findsOneWidget);
    expect(find.text('Prototype / Demo Data'), findsNothing);
    expect(controller.screen, WorkflowScreen.onboarding);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(800, 1000);
    await tester.pump();
    expect(find.bySemanticsLabel('Kabadiwala Connect logo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('continue requires a name and a valid Kabadiwala number',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = MinistryController(
      localRepository: WidgetMemoryRepository(),
      remoteRepository: WidgetRemoteRepository(),
      enableTts: false,
      initialOnline: false,
      monitorConnectivity: false,
    )..setLanguage('en');
    addTearDown(controller.dispose);
    await tester.pumpWidget(MinistryApp(controller: controller));
    await tester.pumpAndSettle();

    FilledButton continueButton() => tester.widget<FilledButton>(find.ancestor(
        of: find.text('Continue'), matching: find.byType(FilledButton)));
    expect(continueButton().onPressed, isNull);
    await tester.enterText(
        find.widgetWithText(TextField, 'Kabadiwala number'), '1234');
    await tester.pump();
    expect(find.text('Enter a valid 5 to 10 digit Kabadiwala number.'),
        findsOneWidget);
    expect(continueButton().onPressed, isNull);
    await tester.enterText(
        find.widgetWithText(TextField, 'Kabadiwala number'), '55555');
    await tester.pump();
    expect(continueButton().onPressed, isNull);
    await tester.enterText(
        find.widgetWithText(TextField, 'Kabadiwala name'), 'Ramesh');
    await tester.pump();
    expect(continueButton().onPressed, isNotNull);
  });

  testWidgets('home profile supports language persistence and logout',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final local = WidgetMemoryRepository()
      ..profile = const CollectorProfile(
        collectorId: '55555',
        collectorName: 'Ramesh',
        language: 'en',
        operatingLocation: 'Pune',
      );
    final controller = MinistryController(
      localRepository: local,
      remoteRepository: WidgetRemoteRepository(),
      enableTts: false,
      initialOnline: true,
      monitorConnectivity: false,
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(MinistryApp(controller: controller));
    await tester.pumpAndSettle();
    expect(find.text('Ramesh'), findsOneWidget);
    expect(find.text('Start collection'), findsOneWidget);
    expect(find.text('Quick actions'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Language'));
    await tester.pumpAndSettle();
    expect(find.text('Choose language'), findsOneWidget);
    await tester.tap(find.text('मराठी'));
    await tester.pumpAndSettle();
    expect(controller.language, 'mr');
    expect(local.profile?.language, 'mr');
    expect(find.text(controller.t('start')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(controller.t('profile')));
    await tester.pumpAndSettle();
    expect(find.text('Ramesh'), findsWidgets);
    expect(find.text('55555'), findsOneWidget);
    expect(find.text('Pune'), findsOneWidget);
    final logoutLabel = controller.t('logout');
    await tester.tap(find.widgetWithText(OutlinedButton, logoutLabel));
    await tester.pumpAndSettle();
    expect(find.text(controller.t('logoutTitle')), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, logoutLabel));
    await tester.pumpAndSettle();
    expect(controller.screen, WorkflowScreen.onboarding);
    expect(controller.profile, isNull);
    expect(local.profile, isNull);
    expect(find.bySemanticsLabel('Kabadiwala Connect logo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('collector completes a manual batch and cash handover',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = MinistryController(
      localRepository: WidgetMemoryRepository(),
      remoteRepository: WidgetRemoteRepository(),
      enableTts: false,
      initialOnline: false,
      monitorConnectivity: false,
    )..setLanguage('en');
    addTearDown(controller.dispose);

    await tester.pumpWidget(MinistryApp(controller: controller));
    await tester.pumpAndSettle();
    Finder pageScrollable() => find
        .descendant(
            of: find.byType(ListView), matching: find.byType(Scrollable))
        .first;
    expect(find.text('Simple, safer scrap collection'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextField, 'Kabadiwala number'), '55555');
    await tester.enterText(
        find.widgetWithText(TextField, 'Kabadiwala name'), 'Ramesh');
    await tester.scrollUntilVisible(
        find.widgetWithText(TextField, 'Operating location'), 160,
        scrollable: pageScrollable());
    await tester.enterText(
        find.widgetWithText(TextField, 'Operating location'), 'Pune');
    await tester.scrollUntilVisible(find.text('Continue'), 200,
        scrollable: pageScrollable());
    await tester.drag(pageScrollable(), const Offset(0, -100));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Start collection'), findsOneWidget);
    expect(find.text('Ramesh'), findsOneWidget);
    expect(find.text('55555'), findsNothing);
    expect(tester.takeException(), isNull, reason: 'home layout');

    await tester.tap(find.text('Start collection'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quick batch collection'));
    await tester.pumpAndSettle();
    expect(find.text('Add material'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'capture layout');

    await tester.tap(find.text('Add material'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Circuit boards'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review materials'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'review layout');

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(2));
    await tester.enterText(fields.at(1), '3.5');
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Demo location'), 250,
        scrollable: pageScrollable());
    await tester.tap(find.text('Demo location'));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Create digital lot'), 250,
        scrollable: pageScrollable());
    await tester.tap(find.text('Create digital lot'));
    await tester.pumpAndSettle();
    expect(find.textContaining('KBC-'), findsWidgets);
    expect(tester.takeException(), isNull, reason: 'lot layout');

    await tester.scrollUntilVisible(find.text('Find recycler'), 250,
        scrollable: pageScrollable());
    await tester.tap(find.text('Find recycler'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Demo recycler'), findsWidgets);
    expect(tester.takeException(), isNull, reason: 'recycler layout');
    await tester.drag(pageScrollable(), const Offset(0, -520));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Select recycler').first);
    await tester.tap(find.text('Select recycler').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'handover layout');

    await tester.scrollUntilVisible(find.text('Confirm receipt'), 250,
        scrollable: pageScrollable());
    await tester.tap(find.text('Confirm receipt'));
    await tester.pumpAndSettle();
    expect(find.text('Payment'), findsWidgets);
    expect(tester.takeException(), isNull, reason: 'payment layout');

    await tester.tap(find.text('Paid'));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Save payment status'), 250,
        scrollable: pageScrollable());
    await tester.tap(find.text('Save payment status'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'ledger layout');
    expect(
        find.text('Persistent local lot and payment history.'), findsOneWidget);
    expect(controller.totalEarnings, greaterThan(0));
    expect(controller.selectedLot!.status, LotStatus.completed);

    await tester.tap(find.byTooltip('Home'));
    await tester.pumpAndSettle();
    expect(controller.screen, WorkflowScreen.home);
    expect(find.text('Start collection'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'direct home navigation');
  });
}
