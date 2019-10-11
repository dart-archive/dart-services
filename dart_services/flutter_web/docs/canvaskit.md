# Trying the CanvasKit/Skia Backend

## This is experimental!

Please note that this backend is **highly experimental** and incomplete. Expect
errors and rendering glitches if you attempt to use this backend.

## What is CanvasKit?

[CanvasKit](https://skia.org/user/modules/canvaskit) is a build of Skia for the
web. Skia is the rendering backend used by Flutter Mobile. Flutter for Web has
an experimental, alternative, rendering backend which uses CanvasKit to execute
Flutter drawing commands.

## How do I enable CanvasKit on my Flutter Web app?

There are two ways to enable CanvasKit in your Flutter Web app. You can either
modify `package:flutter_web_ui` to enable the flag manually, or you can pass a
variable to the compiler. The disadvantage of making a manual change to
`package:flutter_web_ui` is that you will no longer be using the `git:` version
of the package, and won't be updated to the latest version automatically. The
disadvantage of passing the variable to the compiler is that this will only
work in release mode.

### Option 1: Making a change to `package:flutter_web_ui`

First, you need to update your dependency of `package:flutter_web_ui` in your
project to point to the one you will be modifying. For the purposes of this
example we will assume you have checked out the `flutter_web` repository
into `/Users/me/flutter_web`.

If you are using a `pubspec.yaml` copied from the `README.md`, then you
will have the following in your `pubspec.yaml`:

```yaml
dependency_overrides:
  flutter_web:
    git:
      url: https://github.com/flutter/flutter_web
      path: packages/flutter_web
  flutter_web_ui:
    git:
      url: https://github.com/flutter/flutter_web
      path: packages/flutter_web_ui
```

In order to use the local version, you have to change it to:

```yaml
dependency_overrides:
  flutter_web:
    git:
      url: https://github.com/flutter/flutter_web
      path: packages/flutter_web
  flutter_web_ui:
    path: /Users/me/flutter_web/packages/flutter_web_ui
```

Next, in your local copy of `flutter_web`, you need to change a variable (you
probably want to create a new branch for this, or risk messing up your `master`
branch).

In your local copy of `flutter_web`, edit
`/Users/me/flutter_web/packages/flutter_web_ui/lib/src/engine/compositor/initialization.dart`.

In it, you should find some lines that say:

```dart
/// EXPERIMENTAL: Enable the Skia-based rendering backend.
const bool experimentalUseSkia =
    bool.fromEnvironment('FLUTTER_WEB_USE_SKIA', defaultValue: false);
```

Edit this so that the `defaultValue` is `true`. The line should look like this
now:

```dart
/// EXPERIMENTAL: Enable the Skia-based rendering backend.
const bool experimentalUseSkia =
    bool.fromEnvironment('FLUTTER_WEB_USE_SKIA', defaultValue: true);
```

### Option 2: Use an environment variable

This option only works in release mode.

For our purposes, let us assume you are using the `build.yaml` provided in the
`README.md`. It should look like this:

```yaml
targets:
  $default:
    builders:
      build_web_compilers|entrypoint:
        generate_for:
        - web/**.dart
        options:
          dart2js_args:
            - --no-source-maps
            - -O4
```

In order to enable the CanvasKit/Skia backend, you must add another flag to 
`dart2js_args`. Set the environment variable to `true` by adding
`-DFLUTTER_WEB_USE_SKIA=true` to the `dart2js_args`. After you make this
edit, it should look like this:

```yaml
targets:
  $default:
    builders:
      build_web_compilers|entrypoint:
        generate_for:
        - web/**.dart
        options:
          dart2js_args:
            - --no-source-maps
            - -O4
            - -DFLUTTER_WEB_USE_SKIA=true
```

Now, run your app in release mode by doing `webdev serve --release`
(or `webdev serve -r`) and you should be running in CanvasKit mode!

## How do I verify I'm using the CanvasKit backend?

A simple way to tell is to see if your app downloaded the CanvasKit
wasm file. Simply check for `canvaskit.wasm` in the `Network` tab
of your Developer Tools. If it was downloaded, then you're running
in CanvasKit mode.

## Please provide feedback

If you use the CanvasKit backend, please file issues if you encounter
bugs. Just keep in mind that this is experimental, so bugs in the
official backend will take precedence.

Thanks for trying the Skia backend!
