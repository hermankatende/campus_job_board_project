// ignore_for_file: avoid_print

import 'package:cjb/services/api_client.dart';
import 'package:cjb/services/auth_service.dart';

/// Manages a student's job-category subscriptions (backend + FCM topics).
class SubscriptionsService {
  SubscriptionsService._();
  static final SubscriptionsService instance = SubscriptionsService._();

  final _api = ApiClient.instance;

  /// Returns the current subscribed categories from backend.
  Future<List<String>> getSubscriptions() async {
    try {
      final data = await _api.get('/api/users/subscriptions/');
      final cats = (data['subscribed_categories'] as List?) ?? [];
      return cats.map((e) => e.toString()).toList();
    } catch (e) {
      print('[SubscriptionsService] getSubscriptions error: $e');
      return [];
    }
  }

  /// Returns true if the user is subscribed to [category].
  Future<bool> isSubscribed(String category) async {
    final cats = await getSubscriptions();
    return cats.any((c) => c.toLowerCase() == category.toLowerCase());
  }

  /// Subscribes to [category]. Returns updated list.
  Future<List<String>> subscribe(String category) async {
    try {
      final data = await _api.post(
          '/api/users/subscriptions/', {'category': category});
      final cats = (data['subscribed_categories'] as List?) ?? [];
      final result = cats.map((e) => e.toString()).toList();
      // Keep local profile cache in sync
      final profile = AuthService.instance.currentProfile;
      if (profile != null) {
        AuthService.instance.updateProfile({
          'subscribed_categories': result,
        });
      }
      return result;
    } catch (e) {
      print('[SubscriptionsService] subscribe error: $e');
      rethrow;
    }
  }

  /// Unsubscribes from [category]. Returns updated list.
  Future<List<String>> unsubscribe(String category) async {
    try {
      final data = await _api.delete(
          '/api/users/subscriptions/', body: {'category': category});
      final cats = (data['subscribed_categories'] as List?) ?? [];
      final result = cats.map((e) => e.toString()).toList();
      final profile = AuthService.instance.currentProfile;
      if (profile != null) {
        AuthService.instance.updateProfile({
          'subscribed_categories': result,
        });
      }
      return result;
    } catch (e) {
      print('[SubscriptionsService] unsubscribe error: $e');
      rethrow;
    }
  }

  /// Toggles subscription for [category]. Returns (isNowSubscribed, updatedList).
  Future<(bool, List<String>)> toggle(String category) async {
    final subscribed = await isSubscribed(category);
    if (subscribed) {
      final updated = await unsubscribe(category);
      return (false, updated);
    } else {
      final updated = await subscribe(category);
      return (true, updated);
    }
  }
}
