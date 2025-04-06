import 'package:bloc/bloc.dart';
import 'package:control/features/service/lock_app_service.dart';
import 'package:meta/meta.dart';

part 'lock_event.dart';
part 'lock_state.dart';

class LockBloc extends Bloc<LockEvent, LockState> {
  LockBloc() : super(LockInitial()) {
    on<LockEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<LockAppEvent>((event, emit) async {
      // TODO: implement event handler
      emit(LockLoading());
      final value = await LockAppService.instance.lockApp(event.packageName);
      if (value == null) {
        emit(LockError("Failed to lock app"));
        return;
      }

      emit(LockLoaded(value));
    });
  }
}
