import 'dart:collection';

import 'package:flutter/foundation.dart';

typedef ValueCallback<T> = void Function(T);

class FbChangeNotifier<T> {
  final LinkedList<_ListenerEntry<T>> _listeners =
      LinkedList<_ListenerEntry<T>>();

  void notifyListeners(T value) {
    for (var item in _listeners) {
      try {
        if (item.list != null) item.listener(value);
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'toolset library',
          context: ErrorDescription(
              'while dispatching notifications for $runtimeType'),
          informationCollector: () sync* {
            yield DiagnosticsProperty<FbChangeNotifier<T>>(
              'The $runtimeType sending notification was',
              this,
              style: DiagnosticsTreeStyle.errorProperty,
            );
          },
        ));
      }
    }
  }

  void addListener(ValueCallback<T> listener) {
    _listeners.add(_ListenerEntry(listener));
  }

  void removeListener(ValueCallback<T> listener) {
    for (final _ListenerEntry<T> entry in _listeners) {
      if (entry.listener == listener) {
        entry.unlink();
        return;
      }
    }
  }

  @mustCallSuper
  void dispose() {
    _listeners.clear();
  }
}

class _ListenerEntry<T> extends LinkedListEntry<_ListenerEntry<T>> {
  _ListenerEntry(this.listener);
  final ValueCallback<T> listener;
}

class FbValueNotifier<T> extends FbChangeNotifier<T> {
  FbValueNotifier(this._value);
  T get value => _value;
  T _value;
  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notifyListeners(newValue);
  }
}
