part of 'cache_bloc.dart';

@immutable
sealed class CacheState {}

final class CacheInitial extends CacheState {}

class CacheLoading extends CacheState {}

class CacheLoaded extends CacheState {
  final List<String> cacheList;

  CacheLoaded({required this.cacheList});
}

class CacheError extends CacheState {
  final String error;

  CacheError({required this.error});
}
