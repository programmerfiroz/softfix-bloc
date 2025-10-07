import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorite_event.dart';
import 'favorite_state.dart';
import 'favorite_storage_helper.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  FavoriteBloc() : super(const FavoriteState()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(
      LoadFavoritesEvent event,
      Emitter<FavoriteState> emit,
      ) async {
    final favoriteIds = await FavoriteStorageHelper.getAllFavoriteIds();
    emit(state.copyWith(favoriteIds: favoriteIds));
  }

  Future<void> _onToggleFavorite(
      ToggleFavoriteEvent event,
      Emitter<FavoriteState> emit,
      ) async {
    final updatedFavorites = List<int>.from(state.favoriteIds);

    if (updatedFavorites.contains(event.userId)) {
      updatedFavorites.remove(event.userId);
    } else {
      updatedFavorites.add(event.userId);
    }

    emit(state.copyWith(favoriteIds: updatedFavorites));

    if (state.isFavorite(event.userId)) {
      await FavoriteStorageHelper.addFavorite(event.userId);
    } else {
      await FavoriteStorageHelper.removeFavorite(event.userId);
    }
  }
}
