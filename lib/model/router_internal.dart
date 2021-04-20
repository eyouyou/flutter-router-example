import 'package:flutter/widgets.dart';

import 'router.dart';

/// A [RouteTreeNote] type
enum RouteTreeNodeType {
  component,
  parameter,
}

/// A matched [RouteTreeNode]
class RouteTreeNodeMatch {
  // constructors
  RouteTreeNodeMatch(this.node);

  RouteTreeNodeMatch.fromMatch(RouteTreeNodeMatch match, this.node) {
    parameters = <String, List<String>>{};
    if (match != null) {
      parameters.addAll(match.parameters);
    }
  }

  // properties
  RouteTreeNode node;
  Map<String, List<String>> parameters = <String, List<String>>{};
}

class Component {
  final ComponentBuilder builder;
  final Map<String, List<String>> params;
  final AppRoute route;
  Component(this.builder, this.params, this.route);

  Widget build(BuildContext ctx) {
    return builder(ctx, route, params);
  }

  Component copyWith(
      {ComponentBuilder builder,
      Map<String, List<String>> params,
      AppRoute route}) {
    return Component(
        builder ?? this.builder, params ?? this.params, route ?? this.route);
  }

  /// 按照route和builder来判断是否相同
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Component &&
        this.route == other.route &&
        this.builder == other.builder;
  }

  /// 按照name来计算code
  @override
  int get hashCode => route.name.hashCode;

  bool equals(Component other) {
    if (identical(this, other)) {
      return true;
    }

    return this == other && params == other.params;
  }
}

/// A matched [AppRoute]
class AppRouteMatch {
  // constructors
  AppRouteMatch(this.routes, {bool isMatched = true}) : isMatched = isMatched;

  // properties
  final List<AppRoute> routes;
  final bool isMatched;
  AppRoute getRoute({String excludeName = ""}) {
    if (excludeName == null) {
      excludeName = "";
    }
    if (excludeName.isEmpty) {
      return routes[0];
    }
    var list = List.of(routes);
    list.removeWhere((element) => element.name == excludeName);
    if (list.isEmpty) {
      return null;
    }
    return list[0];
  }

  Map<String, List<String>> parameters = <String, List<String>>{};
}

/// A node on [RouteTree]
class RouteTreeNode {
  // constructors
  RouteTreeNode(this.part, this.type);

  // properties
  String part;
  RouteTreeNodeType type;
  List<AppRoute> routes = <AppRoute>[];
  List<RouteTreeNode> nodes = <RouteTreeNode>[];
  RouteTreeNode parent;

  bool isParameter() {
    return type == RouteTreeNodeType.parameter;
  }
}

class RouteTree {
  final List<RouteTreeNode> _nodes = <RouteTreeNode>[];

  void addRoute(AppRoute route) {
    String path = route.uri.path;
    // is root/default route, just add it
    // 空路由用来兜底
    if (path == Navigator.defaultRouteName || path.isEmpty) {
      RouteTreeNode node = _nodeForComponent(path, null);
      if (node == null) {
        var node = RouteTreeNode(path, RouteTreeNodeType.component);
        node.routes.add(route);
        _nodes.add(node);
      } else {
        node.routes.add(route);
      }
      return;
    }
    if (path.startsWith("/")) {
      path = path.substring(1);
    }
    List<String> pathComponents = path.split('/');
    RouteTreeNode parent;
    for (int i = 0; i < pathComponents.length; i++) {
      String component = pathComponents[i];
      RouteTreeNode node = _nodeForComponent(component, parent);
      if (node == null) {
        RouteTreeNodeType type = _typeForComponent(component);
        node = RouteTreeNode(component, type);
        node.parent = parent;
        if (parent == null) {
          _nodes.add(node);
        } else {
          parent.nodes.add(node);
        }
      }
      if (i == pathComponents.length - 1) {
        if (node.routes == null) {
          node.routes = [route];
        } else {
          node.routes.add(route);
        }
      }
      parent = node;
    }
  }

  //树广度遍历
  AppRouteMatch matchRoute(String path) {
    String usePath = path;
    if (usePath.startsWith("/")) {
      usePath = path.substring(1);
    }
    List<String> components = usePath.split("/");
    if (path == Navigator.defaultRouteName) {
      components = ["/"];
    }

    Map<RouteTreeNode, RouteTreeNodeMatch> nodeMatches =
        <RouteTreeNode, RouteTreeNodeMatch>{};
    List<RouteTreeNode> nodesToCheck = _nodes;
    List<RouteTreeNode> nodesReveal = _nodes;

    for (String checkComponent in components) {
      Map<RouteTreeNode, RouteTreeNodeMatch> currentMatches =
          <RouteTreeNode, RouteTreeNodeMatch>{};
      List<RouteTreeNode> nextNodes = <RouteTreeNode>[];
      String pathPart = checkComponent;
      Map<String, List<String>> queryMap;
      if (checkComponent.contains("?")) {
        var splitParam = checkComponent.split("?");
        pathPart = splitParam[0];
        queryMap = parseQueryString(splitParam[1]);
      }
      for (RouteTreeNode node in nodesToCheck) {
        bool isMatch = (node.part == pathPart || node.isParameter());
        if (isMatch) {
          RouteTreeNodeMatch parentMatch = nodeMatches[node.parent];
          RouteTreeNodeMatch match =
              RouteTreeNodeMatch.fromMatch(parentMatch, node);
          if (node.isParameter()) {
            String paramKey = node.part.substring(1);
            match.parameters[paramKey] = [pathPart];
          }
          if (queryMap != null) {
            match.parameters.addAll(queryMap);
          }
//          print("matched: ${node.part}, isParam: ${node.isParameter()}, params: ${match.parameters}");
          currentMatches[node] = match;
          if (node.nodes != null && node.nodes.length > 0) {
            nextNodes.addAll(node.nodes);
          }
        }
      }
      nodeMatches = currentMatches;
      nodesToCheck = nextNodes;
      //没有匹配到 返回当前层
      if (currentMatches.values.length == 0) {
        if (nodesReveal.length > 0 && nodesReveal[0].routes.length > 0)
          return AppRouteMatch(nodesReveal[0].routes, isMatched: false);
        return null;
      }
      nodesReveal = nextNodes;
    }
    List<RouteTreeNodeMatch> matches = nodeMatches.values.toList();
    if (matches.length > 0) {
      RouteTreeNodeMatch match = matches.first;
      RouteTreeNode nodeToUse = match.node;
      if (nodeToUse != null &&
          nodeToUse.routes != null &&
          nodeToUse.routes.length > 0) {
        List<AppRoute> routes = nodeToUse.routes;
        AppRouteMatch routeMatch = AppRouteMatch(routes);
        routeMatch.parameters = match.parameters;
        return routeMatch;
      }
    }
    return null;
  }

  AppRoute _getFirstChildAppRoute(AppRoute route) {
    if (route.routes != null) {
      if (route.routes.first.routeProperties?.componentBuilder != null) {
        return route.routes.first;
      }
      return _getFirstChildAppRoute(route.routes.first);
    }
    return null;
  }

  /// 获取route下孩子的最后一个 当作兜底
  AppRoute _getLastRoute(AppRoute route) {
    if (route.routes.length > 0) {
      var lastRoute = route.routes.last;
      if (lastRoute.routeProperties?.componentBuilder != null) {
        return lastRoute;
      }
    }
    return null;
  }

  /// 获取 [excludeName] 排除的route
  Component getComponent(String path, {String excludeName}) {
    var match = matchRoute(path);
    // 排除当前route 之后
    var route = match.getRoute(excludeName: excludeName);

    if (!match.isMatched) {
      //如果没有 则获取当前层最后一个孩子
      var last = _getLastRoute(route);
      if (last != null) {
        return Component(
            last.routeProperties.componentBuilder, match.parameters, last);
      }

      // 根下第一个空的作为兜底
      for (var node in _nodes) {
        if (node.part.isEmpty && node.routes.length > 0) {
          for (var routeItem in node.routes) {
            if (routeItem.routeProperties?.componentBuilder != null) {
              return Component(routeItem.routeProperties.componentBuilder,
                  match.parameters, route);
            }
          }
        }
      }

      throw ArgumentError("路由需要一个兜底方案 可以加在当前路由树的最后一个");
    }

    // 匹配到但是被移除 -》 获取当前route的孩子
    AppRoute builderRoute;
    if (route == null) {
      route = match.getRoute();
      // 递归孩子去构造 找到能构造的孩子
      builderRoute = _getFirstChildAppRoute(route);
    }
    // 匹配到 且能构造 -》 直接构造
    else if (route.routeProperties?.componentBuilder != null) {
      builderRoute = route;
    }
    // 直接获取当前route孩子
    else {
      builderRoute = _getFirstChildAppRoute(route);
    }

    if (builderRoute?.routeProperties?.componentBuilder != null) {
      return Component(builderRoute.routeProperties.componentBuilder,
          match.parameters, builderRoute);
    }

    throw "error";
  }

  // 找到已存在的树节点
  // 继续往下追加
  RouteTreeNode _nodeForComponent(String component, RouteTreeNode parent) {
    List<RouteTreeNode> nodes = _nodes;
    if (parent != null) {
      // search parent for sub-node matches
      nodes = parent.nodes;
    }
    for (RouteTreeNode node in nodes) {
      if (node.part == component) {
        return node;
      }
    }
    return null;
  }

  RouteTreeNodeType _typeForComponent(String component) {
    RouteTreeNodeType type = RouteTreeNodeType.component;
    if (_isParameterComponent(component)) {
      type = RouteTreeNodeType.parameter;
    }
    return type;
  }

  /// Is the path component a parameter
  bool _isParameterComponent(String component) {
    return component.startsWith(":");
  }

  decode(String s) => Uri.decodeComponent(s.replaceAll('+', ' '));
  Map<String, List<String>> parseQueryString(String query) {
    var search = RegExp('([^&=]+)=?([^&]*)');
    var params = Map<String, List<String>>();
    if (query.startsWith('?')) query = query.substring(1);
    for (Match match in search.allMatches(query)) {
      var matchKey = match.group(1);
      var matchValue = match.group(2);
      if (matchKey != null && matchValue != null) {
        String key = decode(matchKey);
        String value = decode(matchValue);
        if (params.containsKey(key)) {
          params[key].add(value);
        } else {
          params[key] = [value];
        }
      }
    }
    return params;
  }
}
