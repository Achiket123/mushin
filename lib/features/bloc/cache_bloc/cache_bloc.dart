import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'cache_event.dart';
part 'cache_state.dart';

class CacheBloc extends Bloc<CacheEvent, CacheState> {
  CacheBloc() : super(CacheInitial()) {
    on<CacheEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
