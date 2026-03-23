import 'package:flutter/material.dart';

class ScrollNotifier extends ChangeNotifier {
  double _lastScrollPosition = 0;
  bool _isBarVisible = true;
  ScrollDirection _scrollDirection = ScrollDirection.idle;
  final Map<String, ScrollController> _pageControllers = {};
  String _currentPageId = '';
  final double _scrollThreshold = 50;

  bool get isBarVisible => _isBarVisible;
  ScrollDirection get scrollDirection => _scrollDirection;

  void registerPageController(String pageId, ScrollController controller) {
    _pageControllers[pageId] = controller;
    controller.addListener(() {
      if (_currentPageId == pageId) {
        // `offset` throws if the controller isn't attached to any scroll view yet.
        if (controller.hasClients) {
          updateScrollPosition(controller.offset);
        }
      }
    });
  }

  void unregisterPageController(String pageId) {
    _pageControllers.remove(pageId);
  }

  void setCurrentPage(String pageId) {
    _currentPageId = pageId;
    if (_pageControllers.containsKey(pageId)) {
      final controller = _pageControllers[pageId]!;
      // Avoid reading offset before the controller is attached.
      if (controller.hasClients) {
        _lastScrollPosition = controller.offset;
      }
    }
  }

  void updateScrollPosition(double position) {
    if (position > _lastScrollPosition + _scrollThreshold) {
      // Scrolling down - hide bar
      if (_isBarVisible) {
        _isBarVisible = false;
        _scrollDirection = ScrollDirection.down;
        notifyListeners();
      }
      _lastScrollPosition = position;
    } else if (position < _lastScrollPosition - _scrollThreshold) {
      // Scrolling up - show bar
      if (!_isBarVisible) {
        _isBarVisible = true;
        _scrollDirection = ScrollDirection.up;
        notifyListeners();
      }
      _lastScrollPosition = position;
    }
  }

  void reset() {
    _lastScrollPosition = 0;
    _isBarVisible = true;
    _scrollDirection = ScrollDirection.idle;
  }
}

enum ScrollDirection { up, down, idle }
