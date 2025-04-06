part of 'get_app_bloc.dart';

@immutable
sealed class GetAppEvent {}

class ListAppEvent extends GetAppEvent {
  ListAppEvent();
}
