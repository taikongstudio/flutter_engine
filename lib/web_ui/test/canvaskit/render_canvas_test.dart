// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/bootstrap/browser.dart';
import 'package:test/test.dart';
import 'package:ui/src/engine.dart';

import 'common.dart';

void main() {
  internalBootstrapBrowserTest(() => testMain);
}

void testMain() {
  group('CanvasKit', () {
    setUpCanvasKitTest();
    setUp(() async {
      window.debugOverrideDevicePixelRatio(1.0);
    });

    Future<DomImageBitmap> newBitmap(int width, int height) async {
      return (await createSizedImageBitmapFromImageData(
        createBlankDomImageData(width, height),
        0,
        0,
        width,
        height,
      ))!;
    }

    // Regression test for https://github.com/flutter/flutter/issues/75286
    test('updates canvas logical size when device-pixel ratio changes',
        () async {
      final RenderCanvas canvas = RenderCanvas();
      canvas.render(await newBitmap(10, 16));

      expect(canvas.canvasElement.width, 10);
      expect(canvas.canvasElement.height, 16);
      expect(canvas.canvasElement.style.width, '10px');
      expect(canvas.canvasElement.style.height, '16px');

      // Increase device-pixel ratio: this makes CSS pixels bigger, so we need
      // fewer of them to cover the browser window.
      window.debugOverrideDevicePixelRatio(2.0);
      canvas.render(await newBitmap(10, 16));
      expect(canvas.canvasElement.width, 10);
      expect(canvas.canvasElement.height, 16);
      expect(canvas.canvasElement.style.width, '5px');
      expect(canvas.canvasElement.style.height, '8px');

      // Decrease device-pixel ratio: this makes CSS pixels smaller, so we need
      // more of them to cover the browser window.
      window.debugOverrideDevicePixelRatio(0.5);
      canvas.render(await newBitmap(10, 16));
      expect(canvas.canvasElement.width, 10);
      expect(canvas.canvasElement.height, 16);
      expect(canvas.canvasElement.style.width, '20px');
      expect(canvas.canvasElement.style.height, '32px');
    });
  });
}