import 'dart:isolate';

import 'package:app_usage/app_usage.dart';
import 'package:bloc/bloc.dart';
import 'package:control/features/service/show_app_service.dart';
import 'package:flutter/material.dart';
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
      try {
        emit(GetAppLoading());
        if (ShowAppService.appUsage.isNotEmpty &&
            ShowAppService.apps.isNotEmpty) {
          emit(GetAppLoaded(ShowAppService.apps, ShowAppService.appUsage));
          return;
        }
        final data = await _showAppService.getAppList();
        final appUsage = await _showAppService.getAppUsage();
        final commonApps =
            appUsage
                .where(
                  (usage) =>
                      data.any((app) => app.packageName == usage.packageName),
                )
                .toList();
        if (data == null) {
          emit(GetAppError("Failed to load apps"));
          return;
        }
        if (data.isEmpty) {
          emit(GetAppError("No apps found"));
          return;
        }
        emit(GetAppLoaded(data, commonApps));
        debugPrint("Apps loaded: ${data.length}");
      } catch (e) {
        debugPrint("Error: $e");
        emit(GetAppError("Failed to load apps"));
      }
    });
  }
}
