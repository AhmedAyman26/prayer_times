import 'package:dio/dio.dart';
import 'package:prayer_times/core/utils/app_strings.dart';

abstract class Failure {
  final String errMessage;

  const Failure(this.errMessage);
}

class ServerFailure extends Failure {
  ServerFailure(super.errMessage);

  factory ServerFailure.fromDioError(DioError dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure(AppStrings.connectionTimeOutError);

      case DioExceptionType.sendTimeout:
        return ServerFailure(AppStrings.sendTimeOutError);

      case DioExceptionType.receiveTimeout:
        return ServerFailure(AppStrings.receiveTimeOutError);

      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
            dioError.response!.statusCode, dioError.response!.data);
      case DioExceptionType.cancel:
        return ServerFailure(AppStrings.cancelError);

      case DioExceptionType.unknown:
        if (dioError.message!.contains('SocketException')) {
          return ServerFailure(AppStrings.noInternetError);
        }
        return ServerFailure(AppStrings.unexpectedError);
      default:
        return ServerFailure(AppStrings.unexpectedError);
    }
  }

  factory ServerFailure.fromResponse(int? statusCode, dynamic response) {
    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      return ServerFailure(response['message']);
    } else if (statusCode == 404) {
      return ServerFailure(AppStrings.notFoundError);
    } else if (statusCode == 500) {
      return ServerFailure(AppStrings.internalServerError);
    } else {
      return ServerFailure(AppStrings.unexpectedError);
    }
  }
}