import 'package:flutter/material.dart';
import 'package:flutter_router_template/model/router.dart';
import 'package:flutter_router_template/model/router_internal.dart';
import 'package:provider/provider.dart';

/// 动态加载 内存绑定 迫使state不释放
///
class RouterProxyWidget extends StatefulWidget {
  RouterProxyWidget(this.controller);
  final RefreshableController controller;
  @override
  State<StatefulWidget> createState() => _RouterProxyState();
}

class _RouterProxyState extends State<RouterProxyWidget> {
  Map<AppRoute, Widget> _widgets = Map<AppRoute, Widget>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RefreshableController>(
        create: (_) => widget.controller,
        builder: (c1, _) {
          var controller = c1.watch<RefreshableController>();
          var component = controller.currentComponent;
          _widgets[component.route] = component.build(c1);
          return ChangeNotifierProvider<IndexedStackController>(
              create: (_) => controller.indexStackController,
              builder: (c2, _) {
                var index = c2.watch<IndexedStackController>().currentIndex;

                // var length = _widgets.length;
                // print("当前index：$index");
                // print("当前长度：$length");
                return IndexedStack(
                    children: _widgets.values.toList(), index: index);
              });
          // return PageView(
          //   controller: widget.controller.pageController,
          //   children: _widgets.values.toList(),
          // );
        });
  }

  @override
  void dispose() {
    super.dispose();
    _widgets.clear();
  }
}

class RefreshableController extends ChangeNotifier {
  final PageController pageController = PageController(initialPage: 0);
  final IndexedStackController indexStackController =
      IndexedStackController(initialPage: 0);
  final Map<AppRoute, int> _routes = Map<AppRoute, int>();
  Component _current;
  Component get currentComponent => _current;

  set component(Component value) {
    if (value != null && !value.equals(_current)) {
      _current = value;
      if (_routes.containsKey(value.route)) {
        indexStackController.setCurrentIndex(_routes[value.route]);

        // var index = 0;
        // for (var item in _routes.entries) {
        //   if (item.key == value.route) {
        //     // pageController.jumpToPage(index);

        //     // pageController.animateToPage(index,
        //     //     duration: Duration(milliseconds: 500),
        //     //     curve: Curves.fastLinearToSlowEaseIn);
        //   }
        //   index++;
        // }
      } else {
        var index = _routes.length;
        _routes[value.route] = index;
        indexStackController.setCurrentIndex(index);

        // if (pageController.hasClients) {
        //   pageController.jumpToPage(_routes.length - 1);
        //   // pageController.animateToPage(_routes.length - 1,
        //   //     duration: Duration(milliseconds: 500),
        //   //     curve: Curves.fastLinearToSlowEaseIn);
        // }
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
    indexStackController.dispose();
  }
}

class IndexedStackController extends ChangeNotifier {
  final int initialPage;
  IndexedStackController({this.initialPage});

  int currentIndex = 0;

  void setCurrentIndex(int index) {
    if (index != currentIndex) {
      currentIndex = index;
      notifyListeners();
    }
  }
}
