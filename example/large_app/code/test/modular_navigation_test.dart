import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:large_app_example/core/navigation/coordinator_provider.dart';
import 'package:large_app_example/features/biometric_validation/coordinator/biometric_coordinator.dart';
import 'package:large_app_example/features/identity_verification/args/identity_verification_args.dart';
import 'package:large_app_example/features/identity_verification/coordinator/identity_verification_coordinator.dart';
import 'package:large_app_example/features/identity_verification/coordinator/identity_verification_navigator.dart';

void main() {
  testWidgets('Enterprise modular navigation lifecycle test with Cubit States', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: IdentityVerificationNavigator(
          args: IdentityVerificationArgs(
            userId: 'USR-TEST',
            protocol: 'PROT-12345',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Module intro page rendered
    expect(find.text('Identity Verification'), findsOneWidget);
    expect(find.text('Service Protocol: PROT-12345'), findsOneWidget);

    final identityCoord =
        CoordinatorProvider.instance.get<IdentityVerificationCoordinator>();
    expect(identityCoord, isNotNull);

    // 2. Navigate to document step
    await tester.tap(find.text('Start Document Validation'));
    await tester.pumpAndSettle();

    expect(find.text('Step 1: Documentation'), findsOneWidget);

    // 3. Trigger submitDocument via UI button
    await tester.tap(find.text('Proceed to Biometrics Sub-Module'));
    await tester.pumpAndSettle();

    // Sub-module is now rendered!
    expect(find.text('Sub-Module: Facial Biometrics'), findsOneWidget);
    final bioCoord = CoordinatorProvider.instance.get<BiometricCoordinator>();
    expect(bioCoord, isNotNull);

    // 4. Advance inside sub-module
    await tester.tap(find.text('Proceed to Face Capture'));
    await tester.pumpAndSettle();

    expect(find.text('Facial Capture'), findsOneWidget);
    expect(find.text('Position Your Face in Frame'), findsOneWidget);

    // 5. Trigger captureFace via UI button
    await tester.tap(find.text('Capture & Validate Face'));
    await tester.pumpAndSettle();

    // Sub-flow finishes and pops back to parent
    expect(find.text('Facial Capture'), findsNothing);
  });
}
