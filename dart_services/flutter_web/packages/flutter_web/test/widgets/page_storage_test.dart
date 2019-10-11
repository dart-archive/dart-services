// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/material.dart';

void main() {
  testWidgets('PageStorage read and write', (WidgetTester tester) async {
    const Key builderKey = const PageStorageKey<String>('builderKey');
    StateSetter setState;
    int storedValue = 0;

    await tester.pumpWidget(
      new Directionality(
        textDirection: TextDirection.ltr,
        child: new PageStorage(
            bucket: new PageStorageBucket(),
            child: new StatefulBuilder(
                key: builderKey,
                builder: (BuildContext context, StateSetter setter) {
                  PageStorage.of(context).writeState(context, storedValue);
                  setState = setter;
                  return new Center(
                      child: new Text('storedValue: $storedValue'));
                })),
      ),
    );

    final Element builderElement = tester.element(find.byKey(builderKey));
    expect(PageStorage.of(builderElement), isNotNull);
    expect(PageStorage.of(builderElement).readState(builderElement),
        equals(storedValue));

    setState(() {
      storedValue = 1;
    });
    await tester.pump();
    expect(PageStorage.of(builderElement).readState(builderElement),
        equals(storedValue));
  });

  testWidgets('PageStorage read and write by identifier',
      (WidgetTester tester) async {
    StateSetter setState;
    int storedValue = 0;

    Widget buildWidthKey(Key key) {
      return new Directionality(
        textDirection: TextDirection.ltr,
        child: new PageStorage(
          bucket: new PageStorageBucket(),
          child: new StatefulBuilder(
              key: key,
              builder: (BuildContext context, StateSetter setter) {
                PageStorage.of(context)
                    .writeState(context, storedValue, identifier: 123);
                setState = setter;
                return new Center(child: new Text('storedValue: $storedValue'));
              }),
        ),
      );
    }

    Key key = const Key('Key one');
    await tester.pumpWidget(buildWidthKey(key));
    Element builderElement = tester.element(find.byKey(key));
    expect(PageStorage.of(builderElement), isNotNull);
    expect(PageStorage.of(builderElement).readState(builderElement), isNull);
    expect(
        PageStorage.of(builderElement)
            .readState(builderElement, identifier: 123),
        equals(storedValue));

    // New StatefulBuilder widget - different key - but the same PageStorage
    // identifier.

    key = const Key('Key two');
    await tester.pumpWidget(buildWidthKey(key));
    builderElement = tester.element(find.byKey(key));
    expect(PageStorage.of(builderElement), isNotNull);
    expect(PageStorage.of(builderElement).readState(builderElement), isNull);
    expect(
        PageStorage.of(builderElement)
            .readState(builderElement, identifier: 123),
        equals(storedValue));

    setState(() {
      storedValue = 1;
    });
    await tester.pump();
    expect(
        PageStorage.of(builderElement)
            .readState(builderElement, identifier: 123),
        equals(storedValue));
  });
}
