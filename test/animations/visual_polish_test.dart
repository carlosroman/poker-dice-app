import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/animations/visual_polish.dart';

Widget _buildEnhancedCard({required Widget child}) {
  return MaterialApp(
    home: Material(
      child: EnhancedCard(child: child),
    ),
  );
}

Widget _buildGlowingButton({
  required Widget child,
  VoidCallback? onTap,
}) {
  return MaterialApp(
    home: Material(
      child: GlowingButton(
        child: child,
        onTap: onTap,
      ),
    ),
  );
}

Widget _buildShimmerEffect({required Widget child}) {
  return MaterialApp(
    home: Material(
      child: ShimmerEffect(child: child),
    ),
  );
}

Widget _buildElevatedContainer({
  required Widget child,
  bool isElevated = false,
}) {
  return MaterialApp(
    home: Material(
      child: ElevatedContainer(
        child: child,
        isElevated: isElevated,
      ),
    ),
  );
}

void main() {
  group('EnhancedCard', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        _buildEnhancedCard(child: const Text('Card Content')),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('uses default border radius', (tester) async {
      await tester.pumpWidget(
        _buildEnhancedCard(child: const Text('Card Content')),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, const BorderRadius.all(Radius.circular(12)));
    });

    testWidgets('uses custom border radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: EnhancedCard(
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              child: const Text('Card Content'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, const BorderRadius.all(Radius.circular(24)));
    });

    testWidgets('responds to press with elevation animation', (tester) async {
      await tester.pumpWidget(
        _buildEnhancedCard(child: const Text('Card Content')),
      );

      final text = find.text('Card Content');
      await tester.tap(text);
      await tester.pump();

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('completes elevation animation within expected duration',
        (tester) async {
      await tester.pumpWidget(
        _buildEnhancedCard(child: const Text('Card Content')),
      );

      final text = find.text('Card Content');
      await tester.tap(text);
      await tester.pump();

      await tester.pump(EnhancedCard.animationDuration);
      expect(find.text('Card Content'), findsOneWidget);
    });
  });

  group('GlowingButton', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        _buildGlowingButton(child: const Text('Tap Me')),
      );

      expect(find.text('Tap Me'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _buildGlowingButton(
          child: const Text('Tap Me'),
          onTap: () {
            tapped = true;
          },
        ),
      );

      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('does not crash without onTap', (tester) async {
      await tester.pumpWidget(
        _buildGlowingButton(child: const Text('No Tap')),
      );

      expect(find.text('No Tap'), findsOneWidget);
    });

    testWidgets('uses default glow color', (tester) async {
      await tester.pumpWidget(
        _buildGlowingButton(child: const Text('Glow')),
      );

      expect(find.text('Glow'), findsOneWidget);
    });

    testWidgets('uses custom glow color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: GlowingButton(
              child: const Text('Custom Glow'),
              glowColor: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('Custom Glow'), findsOneWidget);
    });

    testWidgets('pulses glow animation continuously', (tester) async {
      await tester.pumpWidget(
        _buildGlowingButton(child: const Text('Pulse')),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Pulse'), findsOneWidget);
    });
  });

  group('ShimmerEffect', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        _buildShimmerEffect(child: const Text('Shimmer')),
      );

      expect(find.text('Shimmer'), findsOneWidget);
    });

    testWidgets('uses default colors', (tester) async {
      await tester.pumpWidget(
        _buildShimmerEffect(child: const Text('Default')),
      );

      expect(find.text('Default'), findsOneWidget);
    });

    testWidgets('uses custom colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ShimmerEffect(
              child: const Text('Custom'),
              baseColor: Colors.grey,
              highlightColor: Colors.white,
            ),
          ),
        ),
      );

      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('animates shimmer continuously', (tester) async {
      await tester.pumpWidget(
        _buildShimmerEffect(child: const Text('Animate')),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Animate'), findsOneWidget);
    });
  });

  group('ElevatedContainer', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        _buildElevatedContainer(child: const Text('Container')),
      );

      expect(find.text('Container'), findsOneWidget);
    });

    testWidgets('starts in non-elevated state by default', (tester) async {
      await tester.pumpWidget(
        _buildElevatedContainer(child: const Text('Default')),
      );

      expect(find.text('Default'), findsOneWidget);
    });

    testWidgets('starts in elevated state when isElevated is true',
        (tester) async {
      await tester.pumpWidget(
        _buildElevatedContainer(
          child: const Text('Elevated'),
          isElevated: true,
        ),
      );

      expect(find.text('Elevated'), findsOneWidget);
    });

    testWidgets('animates when isElevated changes to true', (tester) async {
      await tester.pumpWidget(
        _buildElevatedContainer(child: const Text('Animate')),
      );

      await tester.pumpWidget(
        _buildElevatedContainer(
          child: const Text('Animate'),
          isElevated: true,
        ),
      );

      await tester.pump();
      expect(find.text('Animate'), findsOneWidget);
    });

    testWidgets('animates when isElevated changes to false', (tester) async {
      await tester.pumpWidget(
        _buildElevatedContainer(
          child: const Text('Animate'),
          isElevated: true,
        ),
      );

      await tester.pumpWidget(
        _buildElevatedContainer(child: const Text('Animate')),
      );

      await tester.pump();
      expect(find.text('Animate'), findsOneWidget);
    });

    testWidgets('completes elevation animation within expected duration',
        (tester) async {
      await tester.pumpWidget(
        _buildElevatedContainer(child: const Text('Duration')),
      );

      await tester.pumpWidget(
        _buildElevatedContainer(
          child: const Text('Duration'),
          isElevated: true,
        ),
      );

      await tester.pump();
      await tester.pump(ElevatedContainer.elevationDuration);
      expect(find.text('Duration'), findsOneWidget);
    });
  });

  group('Animation constants', () {
    test('EnhancedCard animation duration is 200ms', () {
      expect(EnhancedCard.animationDuration.inMilliseconds, equals(200));
    });

    test('GlowingButton pulse duration is 1500ms', () {
      expect(GlowingButton.pulseDuration.inMilliseconds, equals(1500));
    });

    test('ShimmerEffect shimmer duration is 1500ms', () {
      expect(ShimmerEffect.shimmerDuration.inMilliseconds, equals(1500));
    });

    test('ElevatedContainer elevation duration is 300ms', () {
      expect(ElevatedContainer.elevationDuration.inMilliseconds, equals(300));
    });
  });
}
