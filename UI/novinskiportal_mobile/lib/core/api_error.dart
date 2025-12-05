class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final String? code;

  ApiException({this.statusCode, required this.message, this.code});

  @override
  String toString() => 'ApiException($statusCode, $code, $message)';
}

String humanMessage(int? code, Object? data, String fallback) {
  switch (code) {
    case 400:
    case 422:
      return 'Provjerite unesena polja.';
    case 401:
      return 'Sesija je istekla. Prijavite se ponovo.';
    case 403:
      return 'Nemate dozvolu za ovu radnju.';
    case 404:
      return 'Stavka nije pronađena.';
    case 409:
      return 'Sukob podataka. Osvježite i pokušajte ponovo.';
    case 500:
    case 502:
    case 503:
    case 504:
      return 'Greška na serveru. Pokušajte kasnije.';
    default:
      return fallback;
  }
}
