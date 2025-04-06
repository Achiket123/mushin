part of 'get_app_bloc.dart';

@immutable
sealed class GetAppState {}

final class GetAppInitial extends GetAppState {}

final class GetAppLoading extends GetAppState {}

final class GetAppLoaded extends GetAppState {
  final List<AppInfo> apps;
  final List<AppUsageInfo> appUsage;
  GetAppLoaded(this.apps, this.appUsage);
}

final class GetAppError extends GetAppState {
  final String error;

  GetAppError(this.error);
}
