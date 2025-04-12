part of 'lock_bloc.dart';

@immutable
sealed class LockEvent {}

class LockAppEvent extends LockEvent {
  final String packageName;
  LockAppEvent(this.packageName);
}

class TempLockAppEvent extends LockEvent {
  final String packageName;
  final List<String> tempPackages;
  TempLockAppEvent(this.packageName, this.tempPackages);
}

class LockTimerEvent extends LockEvent {
  final DateTime duration;
  final String packageName;
  LockTimerEvent(this.packageName, this.duration);
}
