import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repository/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService userService;

  UserBloc({required this.userService}) : super(UserInitial()) {
    on<FetchUsersEvent>(_onFetchUsers);
    on<SearchUsersEvent>(_onSearchUsers);
    on<RefreshUsersEvent>(_onRefreshUsers);
  }

  Future<void> _onFetchUsers(
      FetchUsersEvent event,
      Emitter<UserState> emit,
      ) async {
    emit(UserLoading());
    try {
      final List<UserModel> users = await userService.getUsers();
      if (users.isEmpty) {
        emit(UserEmpty());
      } else {
        emit(UserLoaded(users: users, filteredUsers: users));
      }
    } catch (e) {
      emit(const UserError(AppConstants.errorMessage));
    }
  }

  void _onSearchUsers(
      SearchUsersEvent event,
      Emitter<UserState> emit,
      ) {
    if (state is UserLoaded) {
      final currentState = state as UserLoaded;
      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        emit(currentState.copyWith(
          filteredUsers: currentState.users,
          searchQuery: query,
        ));
      } else {
        final filtered = currentState.users.where((user) {
          return user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query) ||
              user.username.toLowerCase().contains(query);
        }).toList();

        emit(currentState.copyWith(
          filteredUsers: filtered,
          searchQuery: query,
        ));
      }
    }
  }

  Future<void> _onRefreshUsers(
      RefreshUsersEvent event,
      Emitter<UserState> emit,
      ) async {
    try {
      final users = await userService.getUsers();
      if (users.isEmpty) {
        emit(UserEmpty());
      } else {
        final currentState = state is UserLoaded ? state as UserLoaded : null;
        final searchQuery = currentState?.searchQuery ?? '';

        if (searchQuery.isEmpty) {
          emit(UserLoaded(users: users, filteredUsers: users));
        } else {
          final filtered = users.where((user) {
            return user.name.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();
          emit(UserLoaded(
            users: users,
            filteredUsers: filtered,
            searchQuery: searchQuery,
          ));
        }
      }
    } catch (e) {
      emit(const UserError(AppConstants.errorMessage));
    }
  }
}
