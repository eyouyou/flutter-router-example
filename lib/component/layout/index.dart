import 'package:flutter/material.dart';
import 'package:flutter_router_template/common/event.dart';
import 'package:flutter_router_template/global.dart';
import 'package:flutter_router_template/model/router.dart';
import 'package:flutter_router_template/model/router_internal.dart';

///! 给路由器使用 都需要一直存在
///! 每个路由器需要实现自己的切换逻辑
///! 需要在交互过程中 实时改变自己的路径 TODO 需要后续接口优化
abstract class FbViewerState<T extends Viewer> extends ViewerState<T>
    with AutomaticKeepAliveClientMixin {
  final FbValueNotifier<String> routerNotifier = FbValueNotifier<String>("");
  FbViewerState<T> parentState;
  void unRegisterRouterListener() {
    if (parentState != null) {
      parentState.routerNotifier.removeListener(_switchRouteListener);
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    switchRoute(getPath(widget.route, widget.query));
    // 每个路由器都必须向上注册节点切换事件
    routerNotifier.value = widget.route.uri.path;
    parentState = context.findAncestorStateOfType<FbViewerState<T>>();
    if (parentState != null) {
      parentState.routerNotifier.addListener(_switchRouteListener);
    }
  }

  void notifySubRouter(String path) {
    routerNotifier.value = path;
  }

  void _switchRouteListener(String newValue) {
    switchRoute(newValue);
  }

  /// 传递至子路由
  @override
  @mustCallSuper
  void switchRoute(String path) {
    notifySubRouter(path);
  }

  @override
  void dispose() {
    unRegisterRouterListener();
    super.dispose();
  }

  String getPath(AppRoute route, Map<String, List<String>> query) {
    var a = Uri(path: route.uri.path, queryParameters: query);
    var queryString = "";
    if (query.entries.length > 0) {
      StringBuffer queryStringBuffer = StringBuffer();
      query.forEach((key, value) {
        value.forEach((item) {
          queryStringBuffer.write("$key=$item&");
        });
      });
      queryString = queryStringBuffer.toString();
      var index = queryString.lastIndexOf("&");
      if (index > 0) {
        queryString = queryString.replaceRange(index, index + 1, "");
      }
    }

    if (queryString.isEmpty) {
      return "${route.uri.path}";
    } else {
      return "${route.uri.path}?$queryString";
    }
  }

  Component getComponent(AppRoute route, Map<String, List<String>> query) {
    final path = getPath(route, query);
    var component = GlobalData.router
        .generate(path ?? "/", excludeName: widget.route.name)
        .copyWith(route: route);
    return component;
  }

  Component tryGetComponentByPath(String path) {
    var component =
        GlobalData.router.generate(path ?? "/", excludeName: widget.route.name);

    // 包含则判定为在该路由之下
    if (component.route.uri.startsWith(widget.route.uri)) {
      return component;
    }

    return null;
  }

  // 包含则继续走
  bool isContains(Uri path) => path.startsWith(widget.route.uri);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Material(child: buildPage(context));
  }

  Widget buildPage(BuildContext ctx);
}
