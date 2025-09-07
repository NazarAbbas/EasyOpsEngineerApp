import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class NetworkExceptions {
  static String getDioException(error) {
    if (error is Exception) {
      try {
        var errorMessage = "";
        if (error is DioException) {
          switch (error.type) {
            case DioExceptionType.cancel:
              errorMessage = "Request Cancelled";
              break;
            case DioExceptionType.connectionTimeout:
              errorMessage = "Connection request timeout";
              break;
            case DioExceptionType.unknown:
              errorMessage = "Unknown error";
              break;
            case DioExceptionType.receiveTimeout:
              errorMessage = "Send timeout in connection with API server";
              break;
            case DioExceptionType.badResponse:
              switch (error.response?.statusCode) {
                case 400:
                  errorMessage = "Unauthorised request";
                  break;
                case 401:
                  errorMessage = "Unauthorised request";
                  break;
                case 403:
                  errorMessage = "Unauthorised request";
                  break;
                case 404:
                  errorMessage = "Not found";
                  break;
                case 409:
                  errorMessage = "Error due to a conflict";
                  break;
                case 408:
                  errorMessage = "Connection request timeout";
                  break;
                case 500:
                  errorMessage = "Internal Server Error";
                  break;
                case 503:
                  errorMessage = "Service unavailable";
                  break;
                default:
                  var responseCode = error.response?.statusCode;
                  errorMessage = "Received invalid status code: $responseCode";
              }
              break;
            case DioErrorType.sendTimeout:
              errorMessage = "Send timeout in connection with API server";
              break;
            case DioErrorType.badCertificate:
              errorMessage = "Request Cancelled";
              break;
            case DioErrorType.connectionError:
              errorMessage = "No internet connection";
              break;
          }
        } else if (error is SocketException) {
          errorMessage = "No internet connection";
        } else {
          errorMessage = "Unexpected error occurred";
        }
        return errorMessage;
      } on FormatException catch (e) {
        if (kDebugMode) {
          print(e);
        }
        // Helper.printError(e.toString());
        return "format  error occurred";
      } catch (_) {
        return "Unexpected error occurred";
      }
    } else {
      if (error.toString().contains("is not a subtype of")) {
        return "Unable to process the data";
      } else {
        return "Unexpected error occurred";
      }
    }
  }
}