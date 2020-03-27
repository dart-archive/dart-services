import 'dart:collection';
import 'dart:io';

class MockHttpSession extends MapBase implements HttpSession {
  final Map _data = {};

  @override
  String id;

  MockHttpSession({this.id});

  @override
  int get length => _data.length;

  @override
  operator [](Object key) => _data[key];

  @override
  void operator []=(key, value) {
    _data[key] = value;
  }

  @override
  void addAll(Map other) => _data.addAll(other);

  @override
  void clear() {
    _data.clear();
  }

  @override
  bool containsKey(Object key) => _data.containsKey(key);

  @override
  bool containsValue(Object value) => _data.containsValue(value);

  @override
  void destroy() {
    print('destroy() was called on a MockHttpSession, which does nothing.');
  }

  @override
  void forEach(void f(key, value)) {
    _data.forEach(f);
  }

  @override
  bool get isEmpty => _data.isEmpty;

  @override
  bool get isNew => true;

  @override
  bool get isNotEmpty => _data.isNotEmpty;

  @override
  Iterable get keys => _data.keys;

  @override
  putIfAbsent(key, ifAbsent()) => _data.putIfAbsent(key, ifAbsent);

  @override
  remove(Object key) => _data.remove(key);

  @override
  Iterable get values => _data.values;

  @override
  set onTimeout(void callback()) {
    print(
        'An onTimeout callback was set on a MockHttpSession, which will do nothing.');
  }
}
