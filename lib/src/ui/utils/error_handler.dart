import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

/// Error categories for better error classification and handling.
enum ErrorCategory {
  /// Validation errors (invalid input, missing required fields, etc.)
  validation,

  /// Network errors (connection issues, timeouts, etc.)
  network,

  /// Storage errors (file I/O, database, shared preferences, etc.)
  storage,

  /// Authentication errors (login failures, token expiry, etc.)
  authentication,

  /// Business logic errors (invalid game state, rule violations, etc.)
  businessLogic,

  /// Unknown or unexpected errors
  unknown,
}

/// User-friendly error messages for different error categories.
class ErrorMessages {
  ErrorMessages._();

  /// Generic error message for validation errors.
  static const String validationError =
      'Please check your input and try again.';

  /// Generic error message for network errors.
  static const String networkError =
      'Unable to connect. Please check your internet connection.';

  /// Generic error message for storage errors.
  static const String storageError =
      'Unable to save data. Please try again later.';

  /// Generic error message for authentication errors.
  static const String authenticationError =
      'Authentication failed. Please try logging in again.';

  /// Generic error message for business logic errors.
  static const String businessLogicError =
      'An error occurred. Please try again.';

  /// Generic error message for unknown errors.
  static const String unknownError = 'Something went wrong. Please try again.';

  /// Returns a user-friendly error message based on the error category.
  static String getMessage(ErrorCategory category) {
    switch (category) {
      case ErrorCategory.validation:
        return validationError;
      case ErrorCategory.network:
        return networkError;
      case ErrorCategory.storage:
        return storageError;
      case ErrorCategory.authentication:
        return authenticationError;
      case ErrorCategory.businessLogic:
        return businessLogicError;
      case ErrorCategory.unknown:
        return unknownError;
    }
  }

  /// Returns a detailed error message including the error details.
  static String getDetailedMessage(
    ErrorCategory category, {
    String? details,
    String? fallbackMessage,
  }) {
    final baseMessage = getMessage(category);
    final message = details != null ? '$baseMessage $details' : baseMessage;
    return fallbackMessage ?? message;
  }
}

/// Centralized error logging utility for the Poker Dice game.
///
/// Provides consistent error logging and user-friendly error message generation.
/// All errors should be logged through this utility for better debugging
/// and error tracking.
class ErrorHandler {
  ErrorHandler._();

  /// The tag used for logging errors.
  static const String _logTag = 'PokerDiceError';

  /// Logs an error with the specified category and details.
  ///
  /// [error] is the error object to log.
  /// [category] is the error category.
  /// [details] is optional additional context.
  /// [stackTrace] is the stack trace if available.
  static void logError(
    Object error, {
    required ErrorCategory category,
    String? details,
    StackTrace? stackTrace,
  }) {
    final message = _buildErrorMessage(error, category, details);
    developer.log(
      message,
      name: _logTag,
      level: _getLogLevel(category),
      error: error,
      stackTrace: stackTrace,
    );

    if (kDebugMode) {
      developer.log(
        'Category: $category\nDetails: $details',
        name: _logTag,
        level: _getLogLevel(category),
      );
    }
  }

  /// Logs a validation error.
  ///
  /// [error] is the error object to log.
  /// [details] is optional additional context.
  /// [stackTrace] is the stack trace if available.
  static void logValidationError(
    Object error, {
    String? details,
    StackTrace? stackTrace,
  }) {
    logError(
      error,
      category: ErrorCategory.validation,
      details: details,
      stackTrace: stackTrace,
    );
  }

  /// Logs a network error.
  ///
  /// [error] is the error object to log.
  /// [details] is optional additional context.
  /// [stackTrace] is the stack trace if available.
  static void logNetworkError(
    Object error, {
    String? details,
    StackTrace? stackTrace,
  }) {
    logError(
      error,
      category: ErrorCategory.network,
      details: details,
      stackTrace: stackTrace,
    );
  }

  /// Logs a storage error.
  ///
  /// [error] is the error object to log.
  /// [details] is optional additional context.
  /// [stackTrace] is the stack trace if available.
  static void logStorageError(
    Object error, {
    String? details,
    StackTrace? stackTrace,
  }) {
    logError(
      error,
      category: ErrorCategory.storage,
      details: details,
      stackTrace: stackTrace,
    );
  }

  /// Logs an authentication error.
  ///
  /// [error] is the error object to log.
  /// [details] is optional additional context.
  /// [stackTrace] is the stack trace if available.
  static void logAuthenticationError(
    Object error, {
    String? details,
    StackTrace? stackTrace,
  }) {
    logError(
      error,
      category: ErrorCategory.authentication,
      details: details,
      stackTrace: stackTrace,
    );
  }

  /// Logs a business logic error.
  ///
  /// [error] is the error object to log.
  /// [details] is optional additional context.
  /// [stackTrace] is the stack trace if available.
  static void logBusinessLogicError(
    Object error, {
    String? details,
    StackTrace? stackTrace,
  }) {
    logError(
      error,
      category: ErrorCategory.businessLogic,
      details: details,
      stackTrace: stackTrace,
    );
  }

  /// Logs an unknown error.
  ///
  /// [error] is the error object to log.
  /// [details] is optional additional context.
  /// [stackTrace] is the stack trace if available.
  static void logUnknownError(
    Object error, {
    String? details,
    StackTrace? stackTrace,
  }) {
    logError(
      error,
      category: ErrorCategory.unknown,
      details: details,
      stackTrace: stackTrace,
    );
  }

  /// Builds a formatted error message.
  static String _buildErrorMessage(
    Object error,
    ErrorCategory category,
    String? details,
  ) {
    final categoryStr = category.name.toUpperCase();
    final errorStr = error.toString();
    final detailsStr = details != null ? ' [$details]' : '';
    return '[$categoryStr] $errorStr$detailsStr';
  }

  /// Returns the appropriate log level based on error category.
  static int _getLogLevel(ErrorCategory category) {
    switch (category) {
      case ErrorCategory.network:
      case ErrorCategory.storage:
      case ErrorCategory.authentication:
        return 900; // Error level
      case ErrorCategory.validation:
      case ErrorCategory.businessLogic:
        return 800; // Warning level
      case ErrorCategory.unknown:
        return 900; // Error level
    }
  }

  /// Returns a user-friendly error message for display to the user.
  ///
  /// [error] is the error object.
  /// [category] is the error category.
  /// [details] is optional additional context.
  static String getUserMessage(
    Object error, {
    required ErrorCategory category,
    String? details,
  }) {
    return ErrorMessages.getDetailedMessage(category, details: details);
  }
}
