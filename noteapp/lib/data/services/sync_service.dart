import 'package:noteapp/data/sources/local.dart';
import 'package:noteapp/data/sources/remote.dart';

class SyncService {
  final Local _local;
  final Remote _remote;

  SyncService(this._local, this._remote);

  Future<void> performSync(String currentUser) async {
    Map<String, dynamic> changes = await _local.offlineChanges(currentUser);
    final response = await _remote.syncData(changes);
    final pulledData = response.data['data'];

    // process pulledData to update local database
    _local.updateLastSynced(currentUser); // update last synced time

  }
}
