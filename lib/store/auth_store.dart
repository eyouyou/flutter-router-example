import 'package:flutter_router_template/model/user.dart';
import 'package:mobx/mobx.dart';

part "auth_store.g.dart";

class AuthStore = _AuthStore with _$AuthStore;

abstract class _AuthStore with Store {
  // 用户
  @observable
  User currentUser;

  @action
  void setCurrentUser(User info) {
    currentUser = info;
  }

  @action
  void logout() {
    setCurrentUser(null);
  }
}
