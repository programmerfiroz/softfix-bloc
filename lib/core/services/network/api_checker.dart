import 'package:dio/dio.dart';
import 'package:softfix_user/core/services/translations/localization_extension.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/logger.dart';
import '../storage/shared_prefs.dart';
import '../storage/token_manger.dart';
import 'error_handler.dart';

class ApiChecker {
  static Response checkResponse(Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return response;
      case 401:
        _showErrorMessage(response, 'Unauthorized access. Please login again.'.trGlobal);
        _logout();
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Unauthorized',
        );
      case 403:
        _showErrorMessage(response, 'Access forbidden'.trGlobal);
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Forbidden',
        );
      case 404:
        _showErrorMessage(response, 'Resource not found'.trGlobal);
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Not Found',
        );
      case 408:
        _showErrorMessage(response, 'Request timeout. Please try again.'.trGlobal);
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Request Timeout',
        );
      case 422:
        _showValidationErrors(response);
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Validation Error',
        );
      case 429:
        _showErrorMessage(response, 'Too many requests. Please wait and try again.'.trGlobal);
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Too Many Requests',
        );
      case 500:
        _showErrorMessage(response, 'Server error. Please try again later.'.trGlobal);
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Server Error',
        );
      case 502:
        _showErrorMessage(response, 'Bad gateway. Server is temporarily unavailable.'.trGlobal);
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Bad Gateway',
        );
      case 503:
        _showErrorMessage(response, 'Service temporarily unavailable. Please try again.'.trGlobal);
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Service Unavailable',
        );
      default:
        _showErrorMessage(response, 'Something went wrong'.trGlobal);
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Something went wrong',
        );
    }
  }

  static Response handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          CustomSnackbar.showError('Connection timeout. Please check your internet and try again.'.trGlobal);
          break;
        case DioExceptionType.sendTimeout:
          CustomSnackbar.showError('Request timeout. Please try again.'.trGlobal);
          break;
        case DioExceptionType.receiveTimeout:
          CustomSnackbar.showError('Server is taking too long to respond. Please try again.'.trGlobal);
          break;
        case DioExceptionType.badCertificate:
          CustomSnackbar.showError('Security certificate error. Please contact support.'.trGlobal);
          break;
        case DioExceptionType.badResponse:
          if (error.response?.data != null) {
            try {
              ErrorResponse errorResponse = ErrorResponse.fromJson(error.response!.data);
              if (errorResponse.errors != null && errorResponse.errors!.isNotEmpty) {
                CustomSnackbar.showError(errorResponse.errors!.first.message?.trGlobal ?? 'Unknown error'.trGlobal);
              } else if (error.response?.data['msg'] != null) {
                CustomSnackbar.showError(error.response!.data['msg'].toString().trGlobal);
              } else {
                CustomSnackbar.showError('Something went wrong'.trGlobal);
              }
            } catch (e) {
              if (error.response?.data['msg'] != null) {
                CustomSnackbar.showError(error.response!.data['msg'].toString().trGlobal);
              } else {
                CustomSnackbar.showError('Something went wrong'.trGlobal);
              }
            }
          } else {
            CustomSnackbar.showError('Server error. Please try again.'.trGlobal);
          }
          break;
        case DioExceptionType.cancel:
          CustomSnackbar.showError('Request cancelled'.trGlobal);
          break;
        case DioExceptionType.connectionError:
          CustomSnackbar.showError('No internet connection. Please check your network and try again.'.trGlobal);
          break;
        case DioExceptionType.unknown:
          if (error.error.toString().contains('SocketException') ||
              error.error.toString().contains('Failed host lookup')) {
            CustomSnackbar.showError('Network error. Please check your internet connection.'.trGlobal);
          } else if (error.error.toString().contains('HttpException')) {
            CustomSnackbar.showError('Connection failed. Please try again.'.trGlobal);
          } else {
            CustomSnackbar.showError('Something went wrong. Please try again.'.trGlobal);
          }
          break;
      }

      Logger.e('DioError Type: ${error.type}');
      Logger.e('DioError Message: ${error.message}');
      Logger.e('DioError: ${error.error}');

      return Response(
        requestOptions: error.requestOptions,
        statusCode: error.response?.statusCode ?? 500,
        data: error.response?.data ?? {
          'res': 'error',
          'msg': _getErrorMessage(error).trGlobal,
        },
      );
    } else {
      Logger.e('Error: $error');
      CustomSnackbar.showError('Unexpected error occurred. Please try again.'.trGlobal);

      return Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 500,
        data: {'res': 'error', 'msg': 'Unexpected error occurred'.trGlobal},
      );
    }
  }

  static String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout'.trGlobal;
      case DioExceptionType.sendTimeout:
        return 'Request timeout'.trGlobal;
      case DioExceptionType.receiveTimeout:
        return 'Response timeout'.trGlobal;
      case DioExceptionType.connectionError:
        return 'No internet connection'.trGlobal;
      case DioExceptionType.badResponse:
        return error.response?.data['msg']?.toString().trGlobal ?? 'Server error'.trGlobal;
      default:
        return 'Something went wrong'.trGlobal;
    }
  }

  static void _showErrorMessage(Response response, [String? defaultMessage]) {
    String message = defaultMessage ?? 'Something went wrong'.trGlobal;

    if (response.data != null && response.data is Map) {
      message = response.data['msg']?.toString().trGlobal ??
          response.data['message']?.toString().trGlobal ??
          response.data['error']?.toString().trGlobal ??
          message;
    }

    CustomSnackbar.showError(message);
  }

  static void _showValidationErrors(Response response) {
    if (response.data != null) {
      try {
        ErrorResponse errorResponse = ErrorResponse.fromJson(response.data);
        if (errorResponse.errors != null && errorResponse.errors!.isNotEmpty) {
          String errorMsg = errorResponse.errors!
              .map((e) => e.message?.trGlobal ?? '')
              .where((msg) => msg.isNotEmpty)
              .join('\n');
          CustomSnackbar.showError(errorMsg.isNotEmpty ? errorMsg : 'Validation errors occurred'.trGlobal);
        } else {
          CustomSnackbar.showError('Validation Error'.trGlobal);
        }
      } catch (e) {
        String message = response.data['msg']?.toString().trGlobal ??
            response.data['message']?.toString().trGlobal ??
            'Validation Error'.trGlobal;
        CustomSnackbar.showError(message);
      }
    } else {
      CustomSnackbar.showError('Validation Error'.trGlobal);
    }
  }

  static void _logout() {
    SharedPrefs.remove(AppConstants.userData);
    SharedPrefs.setBool(AppConstants.isLoggedIn, false);
    TokenManager.clearToken();
    // Navigate to sign-in page and remove all previous routes
  }

  static void showResponseError(Response response) {
    if (response.data != null) {
      try {
        ErrorResponse errorResponse = ErrorResponse.fromJson(response.data);
        if (errorResponse.errors != null && errorResponse.errors!.isNotEmpty) {
          CustomSnackbar.showError(errorResponse.errors!.first.message?.trGlobal ?? 'An error occurred'.trGlobal);
          return;
        }
      } catch (e) {}

      CustomSnackbar.showError(
          response.data['msg']?.toString().trGlobal ??
              response.data['message']?.toString().trGlobal ??
              response.data['error']?.toString().trGlobal ??
              'Something went wrong'.trGlobal
      );
    } else {
      CustomSnackbar.showError('Something went wrong'.trGlobal);
    }
  }

  @Deprecated('Use showResponseError instead')
  static void checkApi(Response response, {bool showToaster = false}) {
    if (showToaster && response.statusCode != 200 && response.statusCode != 201) {
      showResponseError(response);
    }
  }
}
