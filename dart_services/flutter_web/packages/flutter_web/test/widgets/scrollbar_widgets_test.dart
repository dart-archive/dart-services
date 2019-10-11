// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/src/physics/utils.dart' show nearEqual;
import 'package:flutter_web/widgets.dart';
import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:mockito/mockito.dart';

const Color _kScrollbarColor = Color(0xFF123456);
const double _kThickness = 2.5;
const double _kMinThumbExtent = 18.0;

CustomPainter _buildPainter({
  TextDirection textDirection = TextDirection.ltr,
  EdgeInsets padding = EdgeInsets.zero,
  Color color = _kScrollbarColor,
  double thickness = _kThickness,
  double mainAxisMargin = 0.0,
  double crossAxisMargin = 0.0,
  Radius radius,
  double minLength = _kMinThumbExtent,
  double minOverscrollLength,
  ScrollMetrics scrollMetrics,
}) {
  return ScrollbarPainter(
    color: color,
    textDirection: textDirection,
    thickness: thickness,
    padding: padding,
    mainAxisMargin: mainAxisMargin,
    crossAxisMargin: crossAxisMargin,
    radius: radius,
    minLength: minLength,
    minOverscrollLength: minOverscrollLength ?? minLength,
    fadeoutOpacityAnimation: kAlwaysCompleteAnimation,
  )..update(scrollMetrics, scrollMetrics.axisDirection);
}

class _DrawRectOnceCanvas extends Mock implements Canvas { }

void main() {
  final _DrawRectOnceCanvas testCanvas = _DrawRectOnceCanvas();
  ScrollbarPainter painter;
  Rect captureRect() => verify(testCanvas.drawRect(captureAny, any)).captured.single;

  tearDown(() => painter = null);

  final ScrollMetrics defaultMetrics = FixedScrollMetrics(
    minScrollExtent: 0,
    maxScrollExtent: 0,
    pixels: 0,
    viewportDimension: 100,
    axisDirection: AxisDirection.down
  );

  test(
    'Scrollbar is not smaller than minLength with large scroll views, '
    'if minLength is small ',
    () {
      const double minLen = 3.5;
      const Size size = Size(600, 10);
      final ScrollMetrics metrics = defaultMetrics.copyWith(
        maxScrollExtent: 100000,
        viewportDimension: size.height,
      );

      // When overscroll.
      painter = _buildPainter(
        minLength: minLen,
        minOverscrollLength: minLen,
        scrollMetrics: metrics,
      );

      painter.paint(testCanvas, size);

      final Rect rect0 = captureRect();
      expect(rect0.top, 0);
      expect(rect0.left, size.width - _kThickness);
      expect(rect0.width, _kThickness);
      expect(rect0.height >= minLen, true);

      // When scroll normally.
      const double newPixels = 1.0;

      painter.update(metrics.copyWith(pixels: newPixels), metrics.axisDirection);

      painter.paint(testCanvas, size);

      final Rect rect1 = captureRect();
      expect(rect1.left, size.width - _kThickness);
      expect(rect1.width, _kThickness);
      expect(rect1.height >= minLen, true);
    }
  );

  test(
    'When scrolling normally (no overscrolling), the size of the scrollbar stays the same, '
    'and it scrolls evenly',
    () {
      const double viewportDimension = 23;
      const double maxExtent = 100;
      final ScrollMetrics startingMetrics = defaultMetrics.copyWith(
        maxScrollExtent: maxExtent,
        viewportDimension: viewportDimension,
      );
      const Size size = Size(600, viewportDimension);
      const double minLen = 0;

      painter = _buildPainter(
        minLength: minLen,
        minOverscrollLength: minLen,
        scrollMetrics: defaultMetrics,
      );

      final List<ScrollMetrics> metricsList =
        <ScrollMetrics> [startingMetrics.copyWith(pixels: 0.01)]
        ..addAll(List<ScrollMetrics>.generate(
            (maxExtent/viewportDimension).round(),
            (int index) => startingMetrics.copyWith(pixels: (index + 1) * viewportDimension),
          ).where((ScrollMetrics metrics) => !metrics.outOfRange))
        ..add(startingMetrics.copyWith(pixels: maxExtent - 0.01));

      double lastCoefficient;
      for(ScrollMetrics metrics in metricsList) {
        painter.update(metrics, metrics.axisDirection);
        painter.paint(testCanvas, size);

        final Rect rect = captureRect();
        final double newCoefficient = metrics.pixels/rect.top;
        lastCoefficient ??= newCoefficient;

        expect(rect.top >= 0, true);
        expect(rect.bottom <= maxExtent, true);
        expect(rect.left, size.width - _kThickness);
        expect(rect.width, _kThickness);
        expect(nearEqual(rect.height, viewportDimension * viewportDimension / (viewportDimension + maxExtent), 0.001), true);
        expect(nearEqual(lastCoefficient, newCoefficient, 0.001), true);
      }
    }
  );

  test(
    'mainAxisMargin is respected',
    () {
      const double viewportDimension = 23;
      const double maxExtent = 100;
      final ScrollMetrics startingMetrics = defaultMetrics.copyWith(
        maxScrollExtent: maxExtent,
        viewportDimension: viewportDimension,
      );
      const Size size = Size(600, viewportDimension);
      const double minLen = 0;

      const List<double> margins = <double> [-10, 1, viewportDimension/2 - 0.01];
      for(double margin in margins) {
        painter = _buildPainter(
          mainAxisMargin: margin,
          minLength: minLen,
          scrollMetrics: defaultMetrics,
        );

        // Overscroll to double.negativeInfinity (top).
        painter.update(
          startingMetrics.copyWith(pixels: double.negativeInfinity),
          startingMetrics.axisDirection,
        );

        painter.paint(testCanvas, size);
        expect(captureRect().top, margin);

        // Overscroll to double.infinity (down).
        painter.update(
          startingMetrics.copyWith(pixels: double.infinity),
          startingMetrics.axisDirection,
        );

        painter.paint(testCanvas, size);
        expect(size.height - captureRect().bottom, margin);
      }
    }
  );

  test(
    'crossAxisMargin & text direction are respected',
    () {
      const double viewportDimension = 23;
      const double maxExtent = 100;
      final ScrollMetrics startingMetrics = defaultMetrics.copyWith(
        maxScrollExtent: maxExtent,
        viewportDimension: viewportDimension,
      );
      const Size size = Size(600, viewportDimension);
      const double margin = 4;

      for(TextDirection textDirection in TextDirection.values) {
        painter = _buildPainter(
          crossAxisMargin: margin,
          scrollMetrics: startingMetrics,
          textDirection: textDirection,
        );

        for(AxisDirection direction in AxisDirection.values) {
          painter.update(
            startingMetrics.copyWith(axisDirection: direction),
            direction,
          );

          painter.paint(testCanvas, size);
          final Rect rect = captureRect();

          switch (direction) {
            case AxisDirection.up:
            case AxisDirection.down:
              expect(
                margin,
                textDirection == TextDirection.ltr
                  ? size.width - rect.right
                  : rect.left
              );
              break;
            case AxisDirection.left:
            case AxisDirection.right:
              expect(margin, size.height - rect.bottom);
              break;
          }
        }
      }
    }
  );

  group('Padding works for all scroll directions', () {
    const EdgeInsets padding = EdgeInsets.fromLTRB(1, 2, 3, 4);
    const Size size = Size(60, 80);
    final ScrollMetrics metrics = defaultMetrics.copyWith(
      minScrollExtent: -100,
      maxScrollExtent: 240,
      axisDirection: AxisDirection.down,
    );

    final ScrollbarPainter p = _buildPainter(
      padding: padding,
      scrollMetrics: metrics,
    );

    testWidgets('down', (WidgetTester tester) async {
      p.update(
        metrics.copyWith(
          viewportDimension: size.height,
          pixels: double.negativeInfinity,
        ),
        AxisDirection.down,
      );

      // Top overscroll.
      p.paint(testCanvas, size);
      final Rect rect0 = captureRect();
      expect(rect0.top, padding.top);
      expect(size.width - rect0.right, padding.right);

      // Bottom overscroll.
      p.update(
        metrics.copyWith(
          viewportDimension: size.height,
          pixels: double.infinity,
        ),
        AxisDirection.down,
      );

      p.paint(testCanvas, size);
      final Rect rect1 = captureRect();
      expect(size.height - rect1.bottom, padding.bottom);
      expect(size.width - rect1.right, padding.right);
    });

    testWidgets('up', (WidgetTester tester) async {
      p.update(
        metrics.copyWith(
          viewportDimension: size.height,
          pixels: double.infinity,
          axisDirection: AxisDirection.up,
        ),
        AxisDirection.up,
      );

      // Top overscroll.
      p.paint(testCanvas, size);
      final Rect rect0 = captureRect();
      expect(rect0.top, padding.top);
      expect(size.width - rect0.right, padding.right);

      // Bottom overscroll.
      p.update(
        metrics.copyWith(
          viewportDimension: size.height,
          pixels: double.negativeInfinity,
          axisDirection: AxisDirection.up,
        ),
        AxisDirection.up,
      );

      p.paint(testCanvas, size);
      final Rect rect1 = captureRect();
      expect(size.height - rect1.bottom, padding.bottom);
      expect(size.width - rect1.right, padding.right);
    });

    testWidgets('left', (WidgetTester tester) async {
      p.update(
        metrics.copyWith(
          viewportDimension: size.width,
          pixels: double.negativeInfinity,
          axisDirection: AxisDirection.left,
        ),
        AxisDirection.left,
      );

      // Right overscroll.
      p.paint(testCanvas, size);
      final Rect rect0 = captureRect();
      expect(size.height - rect0.bottom, padding.bottom);
      expect(size.width - rect0.right, padding.right);

      // Left overscroll.
      p.update(
        metrics.copyWith(
          viewportDimension: size.width,
          pixels: double.infinity,
          axisDirection: AxisDirection.left,
        ),
        AxisDirection.left,
      );

      p.paint(testCanvas, size);
      final Rect rect1 = captureRect();
      expect(size.height - rect1.bottom, padding.bottom);
      expect(rect1.left, padding.left);
    });

    testWidgets('right', (WidgetTester tester) async {
      p.update(
        metrics.copyWith(
          viewportDimension: size.width,
          pixels: double.infinity,
          axisDirection: AxisDirection.right,
        ),
        AxisDirection.right,
      );

      // Right overscroll.
      p.paint(testCanvas, size);
      final Rect rect0 = captureRect();
      expect(size.height - rect0.bottom, padding.bottom);
      expect(size.width - rect0.right, padding.right);

      // Left overscroll.
      p.update(
        metrics.copyWith(
          viewportDimension: size.width,
          pixels: double.negativeInfinity,
          axisDirection: AxisDirection.right,
        ),
        AxisDirection.right,
      );

      p.paint(testCanvas, size);
      final Rect rect1 = captureRect();
      expect(size.height - rect1.bottom, padding.bottom);
      expect(rect1.left, padding.left);
    });
  });

  test('should scroll towards the right direction',
    () {
      const Size size = Size(60, 80);
      const double maxScrollExtent = 240;
      const double minScrollExtent = -100;
      final ScrollMetrics startingMetrics = defaultMetrics.copyWith(
        minScrollExtent: minScrollExtent,
        maxScrollExtent: maxScrollExtent,
        axisDirection: AxisDirection.down,
        viewportDimension: size.height,
      );

      for(double minLength in <double> [_kMinThumbExtent, double.infinity]) {
        // Disregard `minLength` and `minOverscrollLength` to keep
        // scroll direction correct, if needed
        painter = _buildPainter(
          minLength: minLength,
          minOverscrollLength: minLength,
          scrollMetrics: startingMetrics,
        );

        final Iterable<ScrollMetrics> metricsList = Iterable<ScrollMetrics>.generate(
          9999,
          (int index) => startingMetrics.copyWith(pixels: minScrollExtent + index * size.height / 3)
        )
        .takeWhile((ScrollMetrics metrics) => !metrics.outOfRange);

        Rect previousRect;

        for(ScrollMetrics metrics in metricsList) {
          painter.update(metrics, metrics.axisDirection);
          painter.paint(testCanvas, size);
          final Rect rect = captureRect();

          if (previousRect != null) {
            if (rect.height == size.height) {
              // Size of the scrollbar is too large for the view port
              expect(previousRect.top <= rect.top, true);
              expect(previousRect.bottom <= rect.bottom, true);
            } else {
              // The scrollbar can fit in the view port.
              expect(previousRect.top < rect.top, true);
              expect(previousRect.bottom < rect.bottom, true);
            }
          }

          previousRect = rect;
        }
      }
    }
  );
}
