import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class ShowAppService {
  ShowAppService._();
  static List<AppInfo> apps = [];
  static List<AppUsageInfo> appUsage = [];

  static final instance = ShowAppService._();

  Future<List<AppInfo>> getAppList() async {
    try {
      List<AppInfo>? appList =
          (await InstalledApps.getInstalledApps(false, true)).where((e) {
            if (e.name == 'Mushin') return false;
            if (e.packageName.contains("youtube")) {
              return true;
            } else if (e.packageName.contains("android.")) {
              return false;
            } else if (e.packageName.contains("com.google.")) {
              return false;
            }

            return true;
          }).toList();
      debugPrint("$appList");
      appList.isNotEmpty
          ? appList.sort((a, b) => a.name.compareTo(b.name))
          : [];
      return appList;
    } catch (e) {
      throw Exception("Unable to get app list: $e");
    }
  }

  Future<List<AppUsageInfo>> getAppUsage() async {
    AppUsage appUsage = AppUsage();
    try {
      final DateTime now = DateTime.now();
      final DateTime startOfDay = now.subtract(Duration(days: 10));
      final List<AppUsageInfo> usageInfo = (await appUsage.getAppUsage(
        startOfDay,
        now,
      ));
      usageInfo.sort((a, b) => b.usage.inMinutes.compareTo(a.usage.inMinutes));
      debugPrint("Usage Info: ${usageInfo.length}");
      return usageInfo;
    } catch (e) {
      throw Exception("Unable to get app usage: $e");
    }
  }
}
