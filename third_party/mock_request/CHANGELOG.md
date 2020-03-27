# 1.0.7
* Prepare for upcoming Dart SDK change where `HttpHeaders` methods
  `add` and `set` take an additional optional parameter `preserveHeaderCase`.

# 1.0.6
* Prepare for upcoming Dart SDK change whereby `HttpRequest` implements
  `Stream<Uint8List>` rather than `Stream<List<int>>`.

# 1.0.5
* Add `toString` to `MockHttpHeaders`.

# 1.0.4
* Fix for `ifModifiedSince`

# 1.0.3
* Dart2 fixes
* Apparently fix hangs that break Angel tests
