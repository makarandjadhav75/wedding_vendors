// lib/Repositories/common_repo.dart
class CommonResponse<T> {
  final String message;
  final bool success;
  final T? data;
  final Map<String, String>? errors;

  CommonResponse({
    required this.message,
    required this.success,
    required this.data,
    this.errors,
  });

  /// fromJsonT: converter for the `data` field when it contains the expected object.
  factory CommonResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic) fromJsonT,
      ) {
    final message = json['message']?.toString() ?? '';
    // prefer explicit boolean 'success' when available, otherwise treat numeric status==200 as success
    final bool success = json.containsKey('success')
        ? (json['success'] == true)
        : (json['status'] == 200);

    final rawData = json['data'];

    // detect field-level errors: when data is a map of string values (e.g. {"email":"must not be blank"})
    Map<String, String>? fieldErrors;
    if (rawData is Map<String, dynamic>) {
      final allStrings = rawData.values.every((v) => v == null || v is String);
      final looksLikeErrors = allStrings && !rawData.containsKey('token');
      if (looksLikeErrors) {
        fieldErrors = rawData.map((k, v) => MapEntry(k, v?.toString() ?? ''));
      }
    }

    // Only try to parse typed data when success is true and rawData is not null
    T? typedData;
    if (success && rawData != null) {
      try {
        typedData = fromJsonT(rawData);
      } catch (e) {
        // Failed to parse to T — keep typedData null but log it
        print('CommonResponse.fromJson: failed to parse data -> $e');
        typedData = null;
      }
    }

    return CommonResponse<T>(
      message: message,
      success: success,
      data: typedData,
      errors: fieldErrors,
    );
  }
}
