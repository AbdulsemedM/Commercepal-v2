import 'package:bloc/bloc.dart';
import 'package:commercepal/core/storage/storage.dart';

enum HomeCatalogMode { retail, wholesale }

class HomeCatalogModeCubit extends Cubit<HomeCatalogMode> {
  HomeCatalogModeCubit({Storage? storage})
      : _storage = storage ?? Storage(),
        super(HomeCatalogMode.retail) {
    _loadSavedMode();
  }

  final Storage _storage;

  Future<void> _loadSavedMode() async {
    final saved = await _storage.getHomeCatalogMode();
    if (saved == HomeCatalogMode.wholesale.name) {
      emit(HomeCatalogMode.wholesale);
    }
  }

  Future<void> setMode(HomeCatalogMode mode) async {
    if (mode == state) return;
    emit(mode);
    await _storage.saveHomeCatalogMode(mode.name);
  }
}
