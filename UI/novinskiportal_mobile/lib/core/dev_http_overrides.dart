import 'dart:io';

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);

    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
          return host == 'localhost' ||
              host == '127.0.0.1' ||
              host == '10.0.2.2' ||
              host.startsWith('192.168.');
        };

    return client;
  }
}
