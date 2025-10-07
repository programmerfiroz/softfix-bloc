import 'package:equatable/equatable.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object?> get props => [];
}

class ToggleFavoriteEvent extends FavoriteEvent {
  final int userId;

  const ToggleFavoriteEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadFavoritesEvent extends FavoriteEvent {}