import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';

class LockAppService {
  LockAppService._();

  static final LockAppService instance = LockAppService._();
  MethodChannel channel = const MethodChannel('lock_app_service');
  Future lockApp(String appList) async {
    try {
      final List packages =
          await channel.invokeMethod<List>("toggleAppLock", {
            "targetPackage": appList,
          }) ??
          [];

      if (packages == null) {
        debugPrint("isLocked is null");
        return [];
      }
      final data = packages.map<String>((e) => e.toString()).toList();
      final box = Hive.box("cacheBox");

      await box.clear();
      box.addAll(data);
      return data;
    } catch (e) {
      debugPrint("Error $e");
      throw Error();
    }
  }
}
