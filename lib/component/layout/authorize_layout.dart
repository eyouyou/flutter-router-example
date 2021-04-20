import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_router_template/component/index.dart';
import 'package:flutter_router_template/global.dart';
import 'package:flutter_router_template/model/router.dart';

class AuthorizeLayoutPage extends FbPage {
  final Widget child;
  const AuthorizeLayoutPage(
    this.child, {
    Key key,
    AppRoute route,
    Map<String, List<String>> query,
  }) : super(key: key, route: route, query: query);

  @override
  Widget buildPage(BuildContext ctx) {
    if (GlobalData.authority.currentUser == null) {
      Future.microtask(() => Navigator.of(ctx).pushReplacementNamed(
          "/login?redirect=${Uri.encodeComponent(route.uri.path)}"));
      return Scaffold(
          body: SafeArea(
              child: Row(children: <Widget>[Expanded(child: Text(""))])));
    }
    return child;
  }
}
