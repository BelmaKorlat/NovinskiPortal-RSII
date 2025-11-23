import 'package:novinskiportal_desktop/core/notification_service.dart';
import '../models/article_models.dart';
import '../services/article_service.dart';
import '../providers/paged_provider.dart';
import '../core/paging.dart';
import '../core/api_error.dart';

class ArticleProvider extends PagedProvider<ArticleDto, ArticleSearch> {
  final _service = ArticleService();

  int? categoryId;
  int? subcategoryId;
  int? userId;
  String fts = '';

  @override
  ArticleSearch buildSearch() => ArticleSearch(
    fts: fts.trim().isEmpty ? null : fts.trim(),
    categoryId: categoryId,
    subcategoryId: subcategoryId,
    userId: userId,
    page: page,
    pageSize: pageSize,
    includeTotalCount: true,
    includeFuture: true,
  );

  @override
  Future<PagedResult<ArticleDto>> fetch(ArticleSearch s) {
    return _service.getPage(s);
  }

  Future<ArticleDetailDto> getDetail(int id) async {
    try {
      return await _service.getById(id);
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
      rethrow;
    } catch (_) {
      NotificationService.error('Greška', 'Greška pri učitavanju članka.');
      rethrow;
    }
  }

  Future<void> create(CreateArticleRequest r) async {
    try {
      await _service.create(r);
      await load();
      NotificationService.success('Notifikacija', 'Uspješno dodano!');
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
      rethrow;
    } catch (_) {
      NotificationService.error('Greška', 'Greška pri dodavanju članka.');
      rethrow;
    }
  }

  Future<void> update(int id, UpdateArticleRequest r) async {
    try {
      await _service.update(id, r);
      await load();
      NotificationService.success('Notifikacija', 'Uspješno ažurirano!');
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
      rethrow;
    } catch (_) {
      NotificationService.error('Greška', 'Greška pri ažuriranju članka.');
      rethrow;
    }
  }

  Future<void> toggle(int id) async {
    try {
      final fresh = await _service.toggleStatus(id);
      final i = items.indexWhere((x) => x.id == id);
      if (i != -1) {
        items[i] = fresh;
        notifyListeners();
      }
      final msg = fresh.active
          ? 'Uspješno aktivirano!'
          : 'Uspješno deaktivirano!';
      NotificationService.success('Notifikacija', msg);
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
    } catch (_) {
      NotificationService.error('Greška', 'Greška pri promjeni statusa.');
    }
  }

  Future<void> remove(int id) async {
    await _service.delete(id);
    items.removeWhere((x) => x.id == id);
    notifyListeners();
    NotificationService.success('Notifikacija', 'Uspješno izbrisano!');
  }
}
