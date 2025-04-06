import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';

class LockAppService {
  LockAppService._();

  static final LockAppService instance = LockAppService._();
  MethodChannel channel = const MethodChannel('lock_app_service');
  Future lockApp(String appList) async {
    try {
      final bool? isLocked = await channel.invokeMethod<bool?>(
        "toggleAppLock",
        {"targetPackage": appList},
      );
      debugPrint("isLocked: $isLocked");
      if (isLocked == null) {
        debugPrint("isLocked is null");
        return false;
      }
      if (isLocked) {
        final box = Hive.box("cacheBox");
        if (box.values.contains(appList)) {
          final data = box.values.where((e) => !(e == appList)).toList();
          await box.clear();
          box.addAll(data);
          return isLocked;
        } else
          box.add(appList);
        debugPrint("App is locked");
      } else {
        debugPrint("App is unlocked");
      }
      return isLocked;
    } catch (e) {
      debugPrint("Error $e");
      throw Error();
    }
  }
}
