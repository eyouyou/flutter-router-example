import 'package:flutter/material.dart';
import 'package:flutter_router_template/model/router.dart';
import 'package:flutter_router_template/model/router_internal.dart';
import 'package:mobx/mobx.dart';

// 生成代码
part 'router_store.g.dart';

class RouterStore = _RouterStore with _$RouterStore;

abstract class _RouterStore with Store {
  //路由树
  RouteTree tree = RouteTree();

  @observable
  ObservableList<AppRoute> routes = ObservableList<AppRoute>.of([]);

  @observable
  String path = "/";

  @action
  void setPath(String val) {
    path = val;
  }

  @action
  void setRoutes(List<AppRoute> vals) {
    routes.clear();
    for (var item in vals) {
      tree.addRoute(item);
    }
    routes.addAll(vals);
  }

  @action
  void addRoute(AppRoute val) {
    tree.addRoute(val);
    routes.add(val);
  }

// 根据path生成对应的页面
  Route<dynamic> generator(RouteSettings routeSettings) {
    var path = routeSettings.name ?? "/";
    var component = tree.getComponent(path);
    if (component == null) {
      throw UnimplementedError("path not found");
    }
    var page = Navigator1.getPage(routeSettings, component);

    return page;
  }

  //通过path生成对应的路由
  Component generate(String path, {String excludeName}) {
    return tree.getComponent(path, excludeName: excludeName);
  }
}
