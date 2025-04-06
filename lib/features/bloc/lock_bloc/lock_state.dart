part of 'lock_bloc.dart';

@immutable
sealed class LockState {}

final class LockInitial extends LockState {}

class LockLoading extends LockState {}

final class LockLoaded extends LockState {
  final bool isLocked;

  LockLoaded(this.isLocked);
}

final class LockError extends LockState {
  final String error;

  LockError(this.error);
}
