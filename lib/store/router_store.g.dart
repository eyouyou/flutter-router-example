// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$RouterStore on _RouterStore, Store {
  final _$routesAtom = Atom(name: '_RouterStore.routes');

  @override
  ObservableList<AppRoute> get routes {
    _$routesAtom.reportRead();
    return super.routes;
  }

  @override
  set routes(ObservableList<AppRoute> value) {
    _$routesAtom.reportWrite(value, super.routes, () {
      super.routes = value;
    });
  }

  final _$pathAtom = Atom(name: '_RouterStore.path');

  @override
  String get path {
    _$pathAtom.reportRead();
    return super.path;
  }

  @override
  set path(String value) {
    _$pathAtom.reportWrite(value, super.path, () {
      super.path = value;
    });
  }

  final _$_RouterStoreActionController = ActionController(name: '_RouterStore');

  @override
  void setPath(String val) {
    final _$actionInfo = _$_RouterStoreActionController.startAction(
        name: '_RouterStore.setPath');
    try {
      return super.setPath(val);
    } finally {
      _$_RouterStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRoutes(List<AppRoute> vals) {
    final _$actionInfo = _$_RouterStoreActionController.startAction(
        name: '_RouterStore.setRoutes');
    try {
      return super.setRoutes(vals);
    } finally {
      _$_RouterStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addRoute(AppRoute val) {
    final _$actionInfo = _$_RouterStoreActionController.startAction(
        name: '_RouterStore.addRoute');
    try {
      return super.addRoute(val);
    } finally {
      _$_RouterStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
routes: ${routes},
path: ${path}
    ''';
  }
}
