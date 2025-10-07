import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<UserModel> users;
  final List<UserModel> filteredUsers;
  final String searchQuery;

  const UserLoaded({
    required this.users,
    required this.filteredUsers,
    this.searchQuery = '',
  });

  UserLoaded copyWith({
    List<UserModel>? users,
    List<UserModel>? filteredUsers,
    String? searchQuery,
  }) {
    return UserLoaded(
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [users, filteredUsers, searchQuery];
}

class UserEmpty extends UserState {}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}