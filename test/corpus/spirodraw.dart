// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:math' as Math;

void main() {
  new Spirodraw().go();
}

class Spirodraw {
  static double PI2 = Math.PI * 2;
  Document doc;
  // Scale factor used to scale wheel radius from 1-10 to pixels
  int RUnits, rUnits, dUnits;
  // Fixed radius, wheel radius, pen distance in pixels
  double R, r, d;
  InputElement fixedRadiusSlider,
      wheelRadiusSlider,
      penRadiusSlider,
      penWidthSlider,
      speedSlider;
  SelectElement inOrOut;
  DivElement mainDiv;
  num lastX, lastY;
  int height, width, xc, yc;
  int maxTurns;
  CanvasElement frontCanvas, backCanvas;
  CanvasRenderingContext2D front, back;
  CanvasElement paletteElement;
  ColorPicker colorPicker;
  String penColor = "red";
  int penWidth;
  double rad = 0.0;
  double stepSize;
  bool animationEnabled = true;
  int numPoints;
  double speed;
  bool run;

  Spirodraw() {
    doc = window.document;
    inOrOut = doc.querySelector("#in_out");
    fixedRadiusSlider = doc.querySelector("#fixed_radius");
    wheelRadiusSlider = doc.querySelector("#wheel_radius");
    penRadiusSlider = doc.querySelector("#pen_radius");
    penWidthSlider = doc.querySelector("#pen_width");
    speedSlider = doc.querySelector("#speed");
    mainDiv = doc.querySelector("#main");
    frontCanvas = doc.querySelector("#canvas");
    front = frontCanvas.context2D;
    backCanvas = new Element.tag("canvas");
    back = backCanvas.context2D;
    paletteElement = doc.querySelector("#palette");
    initControlPanel();
  }

  void go() => _setupSize();

  void _setupSize() {
    height = window.innerHeight;
    width = window.innerWidth - 270;
    yc = height ~/ 2;
    xc = width ~/ 2;
    frontCanvas
      ..height = height
      ..width = width;
    backCanvas
      ..height = height
      ..width = width;
    clear();
  }

  void initControlPanel() {
    inOrOut.onChange.listen((_) => refresh());
    fixedRadiusSlider.onChange.listen((_) => refresh());
    wheelRadiusSlider.onChange.listen((_) => refresh());
    speedSlider.onChange.listen(onSpeedChange);
    penRadiusSlider.onChange.listen((_) => refresh());
    penWidthSlider.onChange.listen(onPenWidthChange);

    colorPicker = new ColorPicker(paletteElement);
    colorPicker.addListener((String color) => onColorChange(color));

    doc.querySelector("#start").onClick.listen((_) => start());
    doc.querySelector("#stop").onClick.listen((_) => stop());
    doc.querySelector("#clear").onClick.listen((_) => clear());
  }

  void onColorChange(String color) {
    penColor = color;
    drawFrame(rad);
  }

  void onSpeedChange(Event event) {
    speed = speedSlider.valueAsNumber;
    stepSize = calcStepSize();
  }

  void onPenWidthChange(Event event) {
    penWidth = penWidthSlider.valueAsNumber.toInt();
    drawFrame(rad);
  }

  void refresh() {
    stop();
    // Reset
    lastX = lastY = 0;
    // Compute fixed radius
    // based on starting diameter == min / 2, fixed radius == 10 units
    int min = Math.min(height, width);
    double pixelsPerUnit = min / 40;
    RUnits = fixedRadiusSlider.valueAsNumber.toInt();
    R = RUnits * pixelsPerUnit;
    // Scale inner radius and pen distance in units of fixed radius
    rUnits = wheelRadiusSlider.valueAsNumber.toInt();
    r = rUnits * R / RUnits * int.parse(inOrOut.value);
    dUnits = penRadiusSlider.valueAsNumber.toInt();
    d = dUnits * R / RUnits;
    numPoints = calcNumPoints();
    maxTurns = calcTurns();
    onSpeedChange(null);
    penWidth = penWidthSlider.valueAsNumber.toInt();
    drawFrame(0.0);
  }

  int calcNumPoints() {
    // Empirically, treat it like an oval.
    if (dUnits == 0 || rUnits == 0) return 2;

    int gcf_ = gcf(RUnits, rUnits);
    int n = RUnits ~/ gcf_;
    int d_ = rUnits ~/ gcf_;
    if (n % 2 == 1) return n;
    if (d_ % 2 == 1) return n;
    return n ~/ 2;
  }

  double calcStepSize() => speed / 100 * maxTurns / numPoints;

  void drawFrame(double theta) {
    if (animationEnabled) {
      front
        ..clearRect(0, 0, width, height)
        ..drawImage(backCanvas, 0, 0);
      drawFixed();
    }
    drawWheel(theta);
  }

  void animate(num time) {
    if (run && rad <= maxTurns * PI2) {
      rad += stepSize;
      drawFrame(rad);
      window.requestAnimationFrame(animate);
    } else {
      stop();
    }
  }

  void start() {
    refresh();
    rad = 0.0;
    run = true;
    window.requestAnimationFrame(animate);
  }

  int calcTurns() {
    // compute ratio of wheel radius to big R then find LCM
    if ((dUnits == 0) || (rUnits == 0)) return 1;
    int ru = rUnits.abs();
    int wrUnits = RUnits + rUnits;
    int g = gcf(wrUnits, ru);
    return ru ~/ g;
  }

  void stop() {
    run = false;
    // Show drawing only
    front
      ..clearRect(0, 0, width, height)
      ..drawImage(backCanvas, 0, 0);
    // Reset angle
    rad = 0.0;
  }

  void clear() {
    stop();
    back.clearRect(0, 0, width, height);
    refresh();
  }

  void drawFixed() {
    if (animationEnabled) {
      front
        ..beginPath()
        ..lineWidth = 2
        ..strokeStyle = "gray"
        ..arc(xc, yc, R, 0, PI2, true)
        ..closePath()
        ..stroke();
    }
  }

  /// Draw the wheel with its center at angle theta with respect to the fixed
  /// wheel
  void drawWheel(double theta) {
    double wx = xc + ((R + r) * Math.cos(theta));
    double wy = yc - ((R + r) * Math.sin(theta));
    if (animationEnabled) {
      if (rUnits > 0) {
        // Draw ring
        front
          ..beginPath()
          ..arc(wx, wy, r.abs(), 0, PI2, true)
          ..closePath()
          ..stroke();
        // Draw center
        front
          ..lineWidth = 1
          ..beginPath()
          ..arc(wx, wy, 3, 0, PI2, true)
          ..fillStyle = "black"
          ..fill()
          ..closePath()
          ..stroke();
      }
    }
    drawTip(wx, wy, theta);
  }

  /// Draw a rotating line that shows the wheel rolling and leaves the pen trace.
  ///
  /// [wx]    - X coordinate of wheel center
  /// [wy]    - Y coordinate of wheel center
  /// [theta] -  Angle of wheel center with respect to fixed circle
  void drawTip(double wx, double wy, double theta) {
    // Calc wheel rotation angle
    double rot = (r == 0) ? theta : theta * (R + r) / r;
    // Find tip of line
    double tx = wx + d * Math.cos(rot);
    double ty = wy - d * Math.sin(rot);
    if (animationEnabled) {
      front
        ..beginPath()
        ..fillStyle = penColor
        ..arc(tx, ty, penWidth / 2 + 2, 0, PI2, true)
        ..fill()
        ..moveTo(wx, wy)
        ..strokeStyle = "black"
        ..lineTo(tx, ty)
        ..closePath()
        ..stroke();
    }
    drawSegmentTo(tx, ty);
  }

  void drawSegmentTo(double tx, double ty) {
    if (lastX > 0) {
      back
        ..beginPath()
        ..strokeStyle = penColor
        ..lineWidth = penWidth
        ..moveTo(lastX, lastY)
        ..lineTo(tx, ty)
        ..closePath()
        ..stroke();
    }
    lastX = tx;
    lastY = ty;
  }
}

int gcf(int n, int d) {
  if (n == d) return n;
  int max = Math.max(n, d);

  for (int i = max ~/ 2; i > 1; i--) {
    if ((n % i == 0) && (d % i == 0)) return i;
  }

  return 1;
}

typedef void PickerListener(String selectedColor);

class ColorPicker {
  static const hexValues = const ['00', '33', '66', '99', 'CC', 'FF'];
  static const COLS = 18;
  // Block height, width, padding
  static const BH = 10;
  static const BW = 10;
  static const BP = 1;
  final List<PickerListener> _listeners;
  CanvasElement canvasElement;
  String _selectedColor = 'red';
  final height = 160;
  final width = 180;
  CanvasRenderingContext2D ctx;

  ColorPicker(this.canvasElement) : _listeners = [] {
    ctx = canvasElement.context2D;
    drawPalette();
    addHandlers();
    showSelected();
  }

  String get selectedColor => _selectedColor;

  void set selectedColor(String color) {
    _selectedColor = color;

    showSelected();
    fireSelected();
  }

  void onMouseMove(MouseEvent event) {
    int x = event.offset.x;
    int y = event.offset.y - 40;
    if ((y < 0) || (x >= width)) {
      return;
    }
    ctx.fillStyle = getHexString(getColorIndex(x, y));
    ctx.fillRect(0, 0, width / 2, 30);
  }

  void onMouseDown(MouseEvent event) {
    event.stopPropagation();
    int x = event.offset.x;
    int y = event.offset.y - 40;
    if ((y < 0) || (x >= width)) {
      return;
    }
    selectedColor = getHexString(getColorIndex(x, y));
  }

  /**
   * Adds a [PickerListener] to receive updates.
   */
  void addListener(PickerListener listener) {
    _listeners.add(listener);
  }

  void addHandlers() {
    canvasElement.onMouseMove.listen(onMouseMove);
    canvasElement.onMouseDown.listen(onMouseDown);
  }

  void drawPalette() {
    int i = 0;
    for (int r = 0; r < 256; r += 51) {
      for (int g = 0; g < 256; g += 51) {
        for (int b = 0; b < 256; b += 51) {
          String color = getHexString(i);
          ctx.fillStyle = color;
          int x = BW * (i % COLS);
          int y = BH * (i ~/ COLS) + 40;
          ctx.fillRect(x + BP, y + BP, BW - 2 * BP, BH - 2 * BP);
          i++;
        }
      }
    }
  }

  void fireSelected() {
    for (final listener in _listeners) {
      listener(_selectedColor);
    }
  }

  int getColorIndex(int x, int y) {
    // Get color index 0-215 using row, col
    int i = y ~/ BH * COLS + x ~/ BW;
    return i;
  }

  void showSelected() {
    ctx.fillStyle = _selectedColor;
    ctx.fillRect(width / 2, 0, width / 2, 30);
    ctx.fillStyle = "white";
    ctx.fillRect(0, 0, width / 2, 30);
  }

  String getHexString(num value) {
    int i = value.floor().toInt();

    int r = (i ~/ 36) % 6;
    int g = (i % 36) ~/ 6;
    int b = i % 6;

    return '#${hexValues[r]}${hexValues[g]}${hexValues[b]}';
  }
}
