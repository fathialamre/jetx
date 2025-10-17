/// JetX Networking Module
///
/// Provides a lightweight wrapper around Dio for HTTP networking.
///
/// Usage:
/// ```dart
/// class MyApiService extends JetApiService {
///   @override
///   String get baseUrl => 'https://api.example.com';
///
///   @override
///   List<Interceptor> get interceptors => [
///     PrettyDioLogger(
///       requestHeader: true,
///       requestBody: true,
///       responseBody: true,
///     ),
///   ];
///
///   Future<User> getUser(int id) async {
///     return get<User>(
///       '/users/$id',
///       decoder: (data) => User.fromJson(data),
///     );
///   }
/// }
/// ```
library;

export 'jet_api_service.dart';
export 'package:dio/dio.dart';
export 'package:pretty_dio_logger/pretty_dio_logger.dart';
