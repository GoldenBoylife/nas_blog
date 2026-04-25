import 'package:flutter/foundation.dart'; //ValueNotifier
/*login 상태 여부를 앱 전체에서 간단히 공유하려 고 만든 , 전역 상태 고나리자 */
class AdminGate{
  static final ValueNotifier<bool> is_admin = ValueNotifier<bool>(false);
  // 값이 1개 들고 있고, 값이 바뀌면 구독자에게 알려주는 아주 가벼운 상태 관리 도구
  // is_admin.value가 바뀌면, ValueListenableBuilder같은 위젯이 자동으로 다시 build됨.
  // 즉 전역 bool 하나(로그인 여부)를 UI랑 연결하기에 간단하고 가볍다.

  static void login() {
    // debugPrint('AdminGate.login before=${is_admin.value}');
     is_admin.value = true;
    //  debugPrint('AdminGate.login after=${is_admin.value}');
  }
  static void logout() => is_admin.value = false;

}

