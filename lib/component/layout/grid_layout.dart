import 'package:flutter/material.dart';
import 'package:flutter_router_template/component/layout/index.dart';
import 'package:flutter_router_template/component/layout/router_proxy.dart';
import 'package:flutter_router_template/model/router.dart';
import 'package:provider/provider.dart';

class GridRouterLayout extends Viewer {
  GridRouterLayout({
    Key key,
    AppRoute route,
    Map<String, List<String>> query,
  }) : super(key: key, route: route, query: query);
  @override
  State<StatefulWidget> createState() => _GridRouterLayoutState();
}

class _GridRouterLayoutState extends FbViewerState<GridRouterLayout> {
  RefreshableController refreshController = RefreshableController();
  CardsController cardsController = CardsController();
  @override
  Widget buildPage(BuildContext ctx) {
    return Row(children: [
      CardsWidget(
        children: widget.route.routes.map((e) => makeItem(e)).toList(),
      ),
      RouterProxyWidget(refreshController)
    ]);
  }

  Widget makeItem(AppRoute route) {
    var key = ValueKey(route.name);
    return InkWell(
      key: key,
      child: Text(route.name),
      onTap: () {
        refreshController.component = getComponent(route, widget.query);
        cardsController.selectedKey = key;
      },
    );
  }

  @override
  void switchRoute(String path) {
    if (!isContains(Uri(path: path))) {
      return;
    }

    /// 是否是该路由之下
    /// 控制啥path需要触发当前路由调度
    /// TODO 这个判断是否合理
    if ((cardsController.selectedKey != null &&
        path == widget.route.uri.toString())) {
      return;
    }

    final component = tryGetComponentByPath(path);

    if (component != null) {
      cardsController.selectedKey = ValueKey(component.route.name);
      refreshController.component = component;
      super.switchRoute(path);
    }
  }
}

// ignore: must_be_immutable
class CardsWidget extends StatefulWidget {
  final List<Widget> children;
  CardsController _controller;
  bool _shouldDispose = false;
  CardsWidget({Key key, @required this.children}) : super(key: key) {
    if (_controller == null) {
      _controller = CardsController();
      _shouldDispose = true;
    }
  }

  @override
  State<StatefulWidget> createState() => _CardsWidgetState();
}

class _CardsWidgetState extends State<CardsWidget> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CardsController>(
        create: (_) => widget._controller,
        builder: (context, _) {
          var controller = context.watch<CardsController>();
          return Wrap(
            children: widget.children
                .map((e) => Card(
                    child: e,
                    color: e.key == controller.selectedKey
                        ? Colors.black
                        : Colors.white))
                .toList(),
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    if (widget._shouldDispose) {
      widget._controller.dispose();
    }
  }
}

class CardsController extends ChangeNotifier {
  Key selectedKey;

  void setSelected(Key key) {
    if (selectedKey == key) {
      return;
    }
    selectedKey = key;
    notifyListeners();
  }
}
