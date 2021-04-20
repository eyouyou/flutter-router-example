import 'package:flutter/material.dart';
import 'package:flutter_router_template/component/index.dart';
import 'package:flutter_router_template/model/router.dart';

class NotFoundPage extends FbPage {
  @override
  Widget buildPage(BuildContext ctx) {
    return Container(
        child: Center(
            child: ElevatedButton(
      child: Text("未找到指定页面，返回"),
      onPressed: () => Viewer.of(ctx, path: "/home/1").switchRoute(),
    )));
  }
}
