/// Riverpod provider for the [StorageService].
///
/// Exposes a [StorageService] instance that can be used to persist
/// and load game results.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_dice/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider that exposes the [StorageService].
///
/// Initializes [SharedPreferences] asynchronously and creates
/// a [StorageService] instance.
final storageServiceProvider = FutureProvider<StorageService>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return StorageService(prefs: prefs);
});
