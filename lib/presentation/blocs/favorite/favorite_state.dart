import 'package:equatable/equatable.dart';

class FavoriteState extends Equatable {
  final List<int> favoriteIds;

  const FavoriteState({this.favoriteIds = const []});

  bool isFavorite(int userId) {
    return favoriteIds.contains(userId);
  }

  FavoriteState copyWith({List<int>? favoriteIds}) {
    return FavoriteState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
    );
  }

  @override
  List<Object?> get props => [favoriteIds];
}