import 'package:flutter_web/material.dart';

/// Provides an iterable that efficiently returns all the elements
/// rooted at the given element. See [CachingIterable] for details.
///
/// This method must be called again if the tree changes. You cannot
/// call this function once, then reuse the iterable after having
/// changed the state of the tree, because the iterable returned by
/// this function caches the results and only walks the tree once.
///
/// The same applies to any iterable obtained indirectly through this
/// one, for example the results of calling `where` on this iterable
/// are also cached.
Iterable<Element> collectAllElementsFrom(
  Element rootElement, {
  @required bool skipOffstage,
}) {
  return new CachingIterable<Element>(
      new _DepthFirstChildIterator(rootElement, skipOffstage));
}

class _DepthFirstChildIterator implements Iterator<Element> {
  _DepthFirstChildIterator(Element rootElement, this.skipOffstage)
      : _stack = _reverseChildrenOf(rootElement, skipOffstage).toList();

  final bool skipOffstage;

  Element _current;

  final List<Element> _stack;

  @override
  Element get current => _current;

  @override
  bool moveNext() {
    if (_stack.isEmpty) return false;

    _current = _stack.removeLast();
    // Stack children in reverse order to traverse first branch first
    _stack.addAll(_reverseChildrenOf(_current, skipOffstage));

    return true;
  }

  static Iterable<Element> _reverseChildrenOf(
      Element element, bool skipOffstage) {
    assert(element != null);
    final List<Element> children = <Element>[];
    if (skipOffstage) {
      element.debugVisitOnstageChildren(children.add);
    } else {
      element.visitChildren(children.add);
    }
    return children.reversed;
  }
}
