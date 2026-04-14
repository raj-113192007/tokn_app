// ignore_for_file: avoid_print, unused_local_variable, unused_element, use_build_context_synchronously, unused_field, file_names, constant_identifier_names, deprecated_member_use, unused_import
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

  final Map<String, VoidCallback> _listeners = {};

  void registerPageController(String pageId, ScrollController controller) {
    _pageControllers[pageId] = controller;
    
    void listener() {
      if (_currentPageId == pageId && controller.hasClients) {
        updateScrollPosition(controller.offset);
      }
    }
    
    _listeners[pageId] = listener;
    controller.addListener(listener);
  }

  void unregisterPageController(String pageId) {
    final controller = _pageControllers[pageId];
    final listener = _listeners[pageId];
    
    if (controller != null && listener != null) {
      controller.removeListener(listener);
    }
    
    _pageControllers.remove(pageId);
    _listeners.remove(pageId);
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
    notifyListeners();
  }

  @override
  void dispose() {

    for (var pageId in _pageControllers.keys.toList()) {
      unregisterPageController(pageId);
    }
    super.dispose();
  }

}

enum ScrollDirection { up, down, idle }
