part of 'lock_bloc.dart';

@immutable
sealed class LockEvent {}

class LockAppEvent extends LockEvent {
  final String packageName; 
  LockAppEvent(this.packageName, );
}
