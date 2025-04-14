import 'dart:isolate';
import 'package:app_usage/app_usage.dart';
import 'package:bloc/bloc.dart';
import 'package:control/features/service/show_app_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/app_info.dart';
import 'package:meta/meta.dart';

part 'get_app_event.dart';
part 'get_app_state.dart';

class GetAppBloc extends Bloc<GetAppEvent, GetAppState> {
  final ShowAppService _showAppService;

  GetAppBloc({required ShowAppService showAppService})
    : _showAppService = showAppService,
      super(GetAppInitial()) {
    on<GetAppEvent>((event, emit) {
      emit(GetAppLoading());
    });

    on<ListAppEvent>((event, emit) async {
      emit(GetAppLoading());

      // Capture the RootIsolateToken here
      final rootToken = RootIsolateToken.instance;

      // Pass token to the isolate
      final result = await compute<_AppRequestParams, List<List<dynamic>>>(
        _getApp,
        _AppRequestParams(_showAppService, rootToken!),
      );

      emit(
        GetAppLoaded(
          List<AppInfo>.from(result[0]),
          List<AppUsageInfo>.from(result[1]),
        ),
      );
    });
  }
}

Future<List<List<dynamic>>> _getApp(_AppRequestParams params) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(params.rootIsolateToken);

  final ShowAppService showAppService = params.showAppService;
  try {
    if (ShowAppService.appUsage.isNotEmpty && ShowAppService.apps.isNotEmpty) {
      return [ShowAppService.apps, ShowAppService.appUsage];
    }

    final data = await showAppService.getAppList();
    final appUsage = await showAppService.getAppUsage();
    final commonApps =
        appUsage
            .where(
              (usage) =>
                  data.any((app) => app.packageName == usage.packageName),
            )
            .toList();

    ShowAppService.appUsage = commonApps;
    ShowAppService.apps = data;
    return [data, commonApps];
  } catch (e) {
    debugPrint("Error: $e");
    return [[], []];
  }
}

class _AppRequestParams {
  final ShowAppService showAppService;
  final RootIsolateToken rootIsolateToken;

  _AppRequestParams(this.showAppService, this.rootIsolateToken);
}
