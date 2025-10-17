import 'package:dio/dio.dart';

/// Abstract base class for HTTP API interactions
/// Provides a comprehensive networking solution with:
/// - All HTTP methods (GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS)
/// - Custom interceptors support
/// - Default headers management
/// - Generic JSON response decoding
/// - Download and upload support
abstract class JetApiService {
  late final Dio _dio;

  /// Base URL for all API requests
  String get baseUrl;

  /// Default headers that will be added to all requests
  Map<String, dynamic> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Timeout configuration
  Duration get connectTimeout => const Duration(seconds: 30);
  Duration get receiveTimeout => const Duration(seconds: 30);
  Duration get sendTimeout => const Duration(seconds: 30);

  /// Custom interceptors to be added to the Dio instance
  List<Interceptor> get interceptors => [];

  /// HTTP client adapter (can be overridden for HTTP/2, etc.)
  HttpClientAdapter? get httpClientAdapter => null;

  JetApiService() {
    _initializeDio();
  }

  /// Initialize Dio with configuration
  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: defaultHeaders,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        responseType: ResponseType.json,
      ),
    );

    // Set custom HTTP client adapter if provided
    if (httpClientAdapter != null) {
      _dio.httpClientAdapter = httpClientAdapter!;
    }

    // Add custom interceptors
    _dio.interceptors.addAll(interceptors);
  }

  /// GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
    required T Function(dynamic data) decoder,
  }) async {
    final response = await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? CancelToken(),
      onReceiveProgress: onReceiveProgress,
    );

    return decoder(response.data);
  }

  /// POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    required T Function(dynamic data) decoder,
  }) async {
    final response = await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? CancelToken(),
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return decoder(response.data);
  }

  /// PUT request
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    required T Function(dynamic data) decoder,
  }) async {
    final response = await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? CancelToken(),
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return decoder(response.data);
  }

  /// DELETE request
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    required T Function(dynamic data) decoder,
  }) async {
    final response = await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? CancelToken(),
    );

    return decoder(response.data);
  }

  /// PATCH request
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    required T Function(dynamic data) decoder,
  }) async {
    final response = await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? CancelToken(),
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return decoder(response.data);
  }

  /// HEAD request
  Future<Response> head(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.head(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? CancelToken(),
    );
  }

  /// OPTIONS request
  Future<Response> optionsRequest(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? requestOptions,
    CancelToken? cancelToken,
  }) async {
    return await _dio.request(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (requestOptions ?? Options()).copyWith(method: 'OPTIONS'),
      cancelToken: cancelToken ?? CancelToken(),
    );
  }

  /// Download file
  Future<Response> download(
    String urlPath,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
  }) async {
    return await _dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      cancelToken: cancelToken ?? CancelToken(),
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      options: options,
    );
  }

  /// Upload files with multipart/form-data
  Future<T> upload<T>(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    required T Function(dynamic data) decoder,
  }) async {
    final response = await _dio.post(
      path,
      data: formData,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? CancelToken(),
      onSendProgress: onSendProgress,
    );
    return decoder(response.data);
  }

  /// Create a new cancel token
  CancelToken createCancelToken() => CancelToken();

  /// Add a header that will persist for all subsequent requests
  void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  /// Remove a header
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  /// Update multiple headers at once
  void updateHeaders(Map<String, String> headers) {
    _dio.options.headers.addAll(headers);
  }

  /// Clear all headers except default ones
  void clearHeaders() {
    _dio.options.headers.clear();
    _dio.options.headers.addAll(defaultHeaders);
  }

  /// Get current headers
  Map<String, dynamic> get currentHeaders => Map.from(_dio.options.headers);

  /// Add an interceptor at runtime
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// Remove an interceptor
  void removeInterceptor(Interceptor interceptor) {
    _dio.interceptors.remove(interceptor);
  }

  /// Access to the underlying Dio instance for advanced usage
  Dio get dio => _dio;
}
