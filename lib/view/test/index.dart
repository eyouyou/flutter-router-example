import 'package:flutter/material.dart';
import 'package:flutter_router_template/component/index.dart';
import 'package:flutter_router_template/model/router.dart';

class TestPage extends FbPage {
  @override
  Widget buildPage(BuildContext ctx) {
    return Container(
        child: Center(
            child: ElevatedButton(
      child: Text("Hello World! "),
      onPressed: () => Viewer.of(ctx, path: "/home").switchRoute(),
    )));
  }
}
