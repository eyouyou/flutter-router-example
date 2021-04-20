import 'package:flutter/material.dart';
import 'package:flutter_router_template/global.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: GlobalData.router.generator,
      initialRoute: GlobalData.router.path,
      theme: ThemeData.light(),
    );
  }
}
