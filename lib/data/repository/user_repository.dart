import 'package:softfix_user/core/utils/logger.dart';

import '../../core/services/network/api_client.dart';
import '../../core/utils/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class UserRepositoryInterface {
  Future<List<dynamic>> getUsers();
}

class UserRepository implements UserRepositoryInterface {
  final ApiClient apiClient;

  UserRepository({required this.apiClient});

  @override
  Future<List<dynamic>> getUsers() async {
    final response = await apiClient.get(AppConstants.usersApiUrl);
    return response.data; // should be List<dynamic>
  }
}

abstract class UserServiceInterface {
  Future<List<UserModel>> getUsers();
}

class UserService implements UserServiceInterface {
  final UserRepository _userRepository;

  UserService(this._userRepository);

  @override
  Future<List<UserModel>> getUsers() async {
    Logger.d("Firoz Mohammad =>  1");
    final response = await _userRepository.getUsers();
    Logger.d("Firoz Mohammad =>  2");

    if (response.isNotEmpty) {
      return response.map((json) => UserModel.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}

