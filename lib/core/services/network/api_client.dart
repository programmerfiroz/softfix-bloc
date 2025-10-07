import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/logger.dart';
import '../storage/token_manger.dart';
import 'api_checker.dart';
import 'multipart.dart';
import 'network_info.dart';

class ApiClient {
  final Dio _dio;
  final int _maxRetries = 3;
  final Duration _retryDelay = const Duration(seconds: 2);

  ApiClient() : _dio = Dio() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: 30000),
      receiveTimeout: const Duration(milliseconds: 30000),
      contentType: 'application/json',
      validateStatus: (status) => status! < 500,
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String token = await TokenManager.getToken() ?? "";
        options.headers["Authorization"] = "Bearer $token";
        options.headers["Content-Type"] = "application/json";
        return handler.next(options);
      },
    ));
  }

  /// Retry logic with exponential backoff
  Future<Response> _retryRequest(
      Future<Response> Function() request, {
        required String requestType,
        required String path,
      }) async {
    int attempt = 0;

    while (attempt < _maxRetries) {
      try {
        // Check internet connectivity before making request
        bool isConnected = await NetworkInfo.checkConnectivity();
        if (!isConnected) {
          Logger.w('No internet connection. Attempt ${attempt + 1}/$_maxRetries');
          throw DioException(
            requestOptions: RequestOptions(path: path),
            type: DioExceptionType.connectionError,
            error: 'No internet connection',
          );
        }

        // Make the request
        return await request();

      } catch (e) {
        attempt++;

        if (e is DioException) {
          // Check if error is retryable
          bool shouldRetry = _shouldRetryError(e);

          if (shouldRetry && attempt < _maxRetries) {
            Logger.w(
                '$requestType request failed (attempt $attempt/$_maxRetries): ${e.message}. Retrying in ${_retryDelay.inSeconds}s...'
            );

            // Wait before retrying with exponential backoff
            await Future.delayed(_retryDelay * attempt);
            continue;
          }
        }

        // If we've exhausted retries or error is not retryable, handle it
        Logger.e('$requestType request failed after $attempt attempts: $e');
        return ApiChecker.handleError(e);
      }
    }

    // This shouldn't be reached, but just in case
    return ApiChecker.handleError(
      DioException(
        requestOptions: RequestOptions(path: path),
        error: 'Max retries exceeded',
      ),
    );
  }

  /// Determine if the error should trigger a retry
  bool _shouldRetryError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;

      case DioExceptionType.badResponse:
      // Retry on 5xx server errors, 408 Request Timeout, 429 Too Many Requests
        final statusCode = error.response?.statusCode;
        return statusCode != null &&
            (statusCode >= 500 || statusCode == 408 || statusCode == 429);

      case DioExceptionType.unknown:
      // Retry on socket exceptions
        return error.error is SocketException ||
            error.error is HttpException;

      default:
        return false;
    }
  }

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onReceiveProgress,
        bool handleError = false,
        bool showToaster = false,
        bool enableRetry = true,
      }) async {
    Future<Response> makeRequest() async {
      Logger.d('ApiClient() => GET request: $path');
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      Logger.d('ApiClient() => GET response: ${response.data}');

      // Single check for response
      if (handleError) {
        return ApiChecker.checkResponse(response);
      }

      // If showToaster is true, show errors
      if (showToaster && response.statusCode != 200 && response.statusCode != 201) {
        ApiChecker.showResponseError(response);
      }

      return response;
    }

    if (enableRetry) {
      return _retryRequest(makeRequest, requestType: 'GET', path: path);
    } else {
      try {
        return await makeRequest();
      } catch (e) {
        return ApiChecker.handleError(e);
      }
    }
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
        bool handleError = false,
        bool showToaster = false,
        bool enableRetry = true,
      }) async {
    Future<Response> makeRequest() async {
      Logger.d('ApiClient() => POST request: $path, data: $data');
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      Logger.d('ApiClient() => POST response: ${response.data}');

      // Single check for response
      if (handleError) {
        return ApiChecker.checkResponse(response);
      }

      // If showToaster is true, show errors
      if (showToaster && response.statusCode != 200 && response.statusCode != 201) {
        ApiChecker.showResponseError(response);
      }

      return response;
    }

    if (enableRetry) {
      return _retryRequest(makeRequest, requestType: 'POST', path: path);
    } else {
      try {
        return await makeRequest();
      } catch (e) {
        return ApiChecker.handleError(e);
      }
    }
  }

  Future<Response> postMultipartData(
      String path,
      Map<String, String> body,
      List<MultipartBody> multipartBody,
      List<MultipartDocument> otherFile, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
        bool fromChat = false,
        bool handleError = false,
        bool showToaster = false,
        bool enableRetry = true,
      }) async {
    Future<Response> makeRequest() async {
      Logger.d('ApiClient() => POST Multipart request: $path');

      FormData formData = FormData();

      // Add text fields
      body.forEach((key, value) {
        formData.fields.add(MapEntry(key, value));
      });

      // Add images
      for (MultipartBody multipart in multipartBody) {
        if (multipart.file != null) {
          if (kIsWeb) {
            List<int> bytes = await multipart.file!.readAsBytes();
            formData.files.add(MapEntry(
              multipart.key,
              MultipartFile.fromBytes(
                bytes,
                filename: basename(multipart.file!.path),
                contentType: MediaType('image', 'jpg'),
              ),
            ));
          } else {
            File file = File(multipart.file!.path);
            formData.files.add(MapEntry(
              multipart.key,
              await MultipartFile.fromFile(
                file.path,
                filename: basename(file.path),
              ),
            ));
          }
        }
      }

      // Add documents
      if (otherFile.isNotEmpty) {
        for (MultipartDocument file in otherFile) {
          if (kIsWeb) {
            if (fromChat) {
              PlatformFile platformFile = file.file!.files.first;
              formData.files.add(MapEntry(
                'image[]',
                MultipartFile.fromBytes(
                  platformFile.bytes!,
                  filename: platformFile.name,
                ),
              ));
            } else {
              var fileBytes = file.file!.files.first.bytes!;
              formData.files.add(MapEntry(
                file.key,
                MultipartFile.fromBytes(
                  fileBytes,
                  filename: file.file!.files.first.name,
                ),
              ));
            }
          } else {
            File other = File(file.file!.files.single.path!);
            formData.files.add(MapEntry(
              file.key,
              await MultipartFile.fromFile(
                other.path,
                filename: basename(other.path),
              ),
            ));
          }
        }
      }

      final response = await _dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      Logger.d('ApiClient() => POST Multipart response: ${response.data}');

      // Single check for response
      if (handleError) {
        return ApiChecker.checkResponse(response);
      }

      // If showToaster is true, show errors
      if (showToaster && response.statusCode != 200 && response.statusCode != 201) {
        ApiChecker.showResponseError(response);
      }

      return response;
    }

    if (enableRetry) {
      return _retryRequest(makeRequest, requestType: 'POST_MULTIPART', path: path);
    } else {
      try {
        return await makeRequest();
      } catch (e) {
        return ApiChecker.handleError(e);
      }
    }
  }

  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
        bool handleError = false,
        bool showToaster = false,
        bool enableRetry = true,
      }) async {
    Future<Response> makeRequest() async {
      Logger.d('ApiClient() => PUT request: $path, data: $data');
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      Logger.d('ApiClient() => PUT response: ${response.data}');

      if (handleError) {
        return ApiChecker.checkResponse(response);
      } else {
        ApiChecker.checkApi(response, showToaster: showToaster);
        return response;
      }
    }

    if (enableRetry) {
      return _retryRequest(makeRequest, requestType: 'PUT', path: path);
    } else {
      try {
        return await makeRequest();
      } catch (e) {
        return ApiChecker.handleError(e);
      }
    }
  }

  Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        bool handleError = false,
        bool showToaster = false,
        bool enableRetry = true,
      }) async {
    Future<Response> makeRequest() async {
      Logger.d('ApiClient() => DELETE request: $path');
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      Logger.d('ApiClient() => DELETE response: ${response.data}');

      if (handleError) {
        return ApiChecker.checkResponse(response);
      } else {
        ApiChecker.checkApi(response, showToaster: showToaster);
        return response;
      }
    }

    if (enableRetry) {
      return _retryRequest(makeRequest, requestType: 'DELETE', path: path);
    } else {
      try {
        return await makeRequest();
      } catch (e) {
        return ApiChecker.handleError(e);
      }
    }
  }
}