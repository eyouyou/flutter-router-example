import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'router_internal.dart';

/// mapping to [AppRouteItem]

/// 路由部分
typedef ComponentBuilder = Widget Function(
    BuildContext, AppRoute, Map<String, List<String>>);
typedef TextBuilder = String Function(BuildContext);

/// route model
/// 排除所有能用 keyvalue 代替的参数
class AppRoute {
  final String name;
  final Uri uri;
  final List<AppRoute> routes;
  final List<String> authority;
  AppRouteProperties routeProperties;
  set setRouteProperties(AppRouteProperties value) {
    routeProperties = value;
  }

  AppRoute(
    this.name, {
    String path = "",
    this.routes,
    this.authority,
  }) : uri = Uri(path: path);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AppRoute &&
        this.name == other.name &&
        this.uri == other.uri;
  }

  @override
  int get hashCode => uri.hashCode;
}

/// key 对应的属性
class AppRouteProperties {
  final IconData icon;
  final ComponentBuilder componentBuilder;

  final TextBuilder textBuilder;
  AppRouteProperties({this.textBuilder, this.componentBuilder, this.icon});
}

class RoutePath {
  final Uri path;
  Map<String, String> queryString;

  RoutePath(this.path);

  void match(List<AppRoute> routes) {}
}

typedef PageBuilder = Page Function(
    BuildContext, AppRoute, Map<String, List<String>>);

class RoutePage {
  final AppRoute route;
  final PageBuilder pageBuilder;

  RoutePage(
    this.route,
    this.pageBuilder,
  );
}

/// 完整路由方案
/// 通过该接口调用当前离他最近的 [routeLayout] 父级 ，
/// [routeLayout] 保存一个 [ViewerState] 状态
/// 各个不同的父类拥有不同的类型的状态 ，各自实现route切换
/// TODO 是否需要通过 [InheritedWidget] 存储数据 有待验证
/// 目前使用状态的父级递归
/// TODO 还需要从父级一层层传递至各个子级
abstract class Viewer extends StatefulWidget {
  final AppRoute route;
  final Map<String, List<String>> query;

  const Viewer({Key key, this.route, this.query}) : super(key: key);

  /// 往父级 [ViewerState] 路由 找到匹配的父级
  static ViewerStateEx of(BuildContext context,
      {String path = "", bool excludeSelf = false}) {
    ViewerState navigator;
    if (!excludeSelf &&
        context is StatefulElement &&
        context.state is ViewerState) {
      navigator = context.state as ViewerState;
    }
    navigator = navigator ?? context.findAncestorStateOfType<ViewerState>();
    var uri = Uri(path: path);

    /// 桥接flutter体系
    if (navigator == null) {
      Navigator.of(context).pushReplacementNamed(path);
      return ViewerStateEx(BadViewerState(), path);
    } else if (path.isNotEmpty && !uri.startsWith(navigator.widget.route.uri)) {
      return Viewer.of(navigator.context, path: path, excludeSelf: true);
    }
    assert(() {
      if (navigator == null) {
        throw FlutterError('路由方案调取失败');
      }
      return true;
    }());
    // navigator.currentPath = path ?? navigator.widget.route.path;
    return ViewerStateEx(navigator, path);
  }
}

class ViewerStateEx {
  final ViewerState state;
  final String path;

  ViewerStateEx(this.state, this.path);

  void switchRoute() {
    state.switchRoute(path);
  }
}

/// 浏览器
abstract class ViewerState<T extends Viewer> extends State<T> {
  /// 包含解析url逻辑
  void switchRoute(String path) {}
}

class BadViewerState extends ViewerState {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("123"),
    );
  }

  @override
  void switchRoute(String path) {}
}

extension UriExtension on Uri {
  // final String path;
  // final List<String> parts = [];
  // RoutePath(this.path) {
  //   String usePath = path;
  //   if (usePath.startsWith("/")) {
  //     usePath = path.substring(1);
  //   }
  //   List<String> components = usePath.split("/");
  //   if (path == Navigator.defaultRouteName) {
  //     components = ["/"];
  //   }

  //   parts.addAll(components);
  // }

  bool startsWith(Uri other) {
    if (other.pathSegments.length > pathSegments.length) {
      return false;
    }
    var i = 0;

    for (; i < other.pathSegments.length; i++) {
      if (pathSegments[i] != other.pathSegments[i]) {
        return false;
      }
    }
    return true;
  }
}

class Navigator1 {
  // nav 1.0
  static Route<dynamic> getPage(
      RouteSettings routeSettings, Component component) {
    var page = MaterialPageRoute<dynamic>(
        settings: routeSettings,
        fullscreenDialog: false,
        maintainState: true,
        builder: (BuildContext ctx) {
          return component.builder(ctx, component.route, component.params);
        });

    return page;
  }
}

class Navigator2 {
  static List<PageBuilder> getPages(String path) {
    throw UnimplementedError();
    // var match = tree.matchRoute(path);
    // if (match == null) {
    //   if (_nodes.length > 0) {
    //     match = AppRouteMatch(_nodes[_nodes.length - 1].routes);
    //   } else {
    //     throw "路由需要一个兜底方案";
    //   }
    // }
    // return _getPages(_nodes, match).toList();
  }
}
