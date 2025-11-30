import '../core/api_error.dart';
import '../core/notification_service.dart';
import 'paged_provider.dart';

mixin PagedCrud<T, S> on PagedProvider<T, S> {
  Future<void> runCrud(
    Future<void> Function() action, {
    String? successMessage,
    String genericError = 'Došlo je do greške.',
    bool reloadAfter = true,
    bool rethrowOnError = false,
  }) async {
    try {
      await action();

      if (reloadAfter) {
        await load();
      }

      if (successMessage != null) {
        NotificationService.success('Notifikacija', successMessage);
      }
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
      if (rethrowOnError) rethrow;
    } catch (_) {
      NotificationService.error('Greška', genericError);
      if (rethrowOnError) rethrow;
    }
  }
}
