import 'package:bloc/bloc.dart';
import 'package:control/features/service/lock_app_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

part 'lock_event.dart';
part 'lock_state.dart';

class LockBloc extends Bloc<LockEvent, LockState> {
  static const platform = MethodChannel('lock_app_service');

  LockBloc() : super(LockInitial()) {
    on<LockEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<LockAppEvent>((event, emit) async {
      // TODO: implement event handler
      emit(LockLoading());
      final List<String> value = await LockAppService.instance.lockApp(
        event.packageName,
      );
      emit(LockLoaded(value));
    });
    on<TempLockAppEvent>((event, emit) async {
      // TODO: implement event handler
      emit(LockLoading());

      if (event.tempPackages.contains(event.packageName)) {
        event.tempPackages.remove(event.packageName);
      } else {
        event.tempPackages.add(event.packageName);
      }
      debugPrint("Result ${event.tempPackages}");
      emit(LockLoaded(event.tempPackages));
    });
    on<LockTimerEvent>((event, emit) async {
      // TODO: implement event handler
      emit(LockLoading());
      LockAppService.instance.lockAppTimer(event.packageName, event.duration);
      debugPrint("Done");
      emit(LockLoaded([]));
    });
  }
}
