import 'package:flutter_router_template/component/layout/grid_layout.dart';
import 'package:flutter_router_template/model/router.dart';
import 'package:flutter_router_template/store/auth_store.dart';
import 'package:flutter_router_template/view/404/index.dart';
import 'package:flutter_router_template/view/test/index.dart';

import 'store/router_store.dart';

class GlobalData {
  static final router = RoutesConfig.makeDefaultRouter();
  static final authority = AuthStore();
}

class RoutesConfig {
  //默认导航 TODO 后面直接增加兜底 保证输出
  //后续从后端获取
  static List<AppRoute> defaultRoutes = [
    AppRoute(
      "root",
      path: "/",
      routes: [
        //包装孩子
        AppRoute("global_layout", path: "/home", routes: [
          AppRoute("1", path: "/home/1"),
          AppRoute("2", path: "/home/2"),
          AppRoute("3", path: "/home/3"),
          AppRoute("4", path: "/home/4"),
        ]),

        // 兜底 这个可以去掉
        AppRoute("404", path: "/404"),
      ],
    ),
    // 兜底
    AppRoute("404"),
  ];

  //获取默认全局路由
  static RouterStore makeDefaultRouter() {
    var store = RouterStore();

    for (var item in _getRoutes(defaultRoutes)) {
      item.routeProperties = Components.getAppRoutePropertiesBuilder(item.name);
      store.addRoute(item);
    }

    return store;
  }

  //递归查找所有路由
  static Iterable<AppRoute> _getRoutes(List<AppRoute> routes) sync* {
    if (routes != null) {
      for (var item in routes) {
        yield item;
        if (item.routes != null && item.routes.length > 0) {
          for (var child in _getRoutes(item.routes)) {
            if (!child.uri.startsWith(item.uri)) throw ArgumentError("嵌套关系有问题");
            yield child;
          }
        }
      }
    }
  }
}

// 组件独立
class Components {
  static final Map<String, AppRouteProperties> _appRoutePropertiesBuilder = {
    "global_layout": AppRouteProperties(
        componentBuilder: (ctx, route, query) =>
            GridRouterLayout(route: route, query: query)),

    "1":
        AppRouteProperties(componentBuilder: (ctx, route, query) => TestPage()),
    "2":
        AppRouteProperties(componentBuilder: (ctx, route, query) => TestPage()),
    "3":
        AppRouteProperties(componentBuilder: (ctx, route, query) => TestPage()),
    "4": AppRouteProperties(
        componentBuilder: (ctx, route, query) => NotFoundPage()),

    /// 404
    "404": AppRouteProperties(
      componentBuilder: (ctx, route, query) => NotFoundPage(),
    )
  };

  //获取路由 相关配置 该配置必须写死在本地
  static AppRouteProperties getAppRoutePropertiesBuilder(String name) {
    if (_appRoutePropertiesBuilder.containsKey(name)) {
      return _appRoutePropertiesBuilder[name];
    }
    return null;
  }
}
