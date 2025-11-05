import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service for fetching and caching Chinese holiday data from external API
class ChineseHolidayService {
  /// Factory constructor for singleton
  factory ChineseHolidayService() => _instance;

  /// Private constructor for singleton
  ChineseHolidayService._internal();

  /// Multiple API sources for redundancy
  static const List<String> _apiUrls = [
    'https://cdn.jsdelivr.net/npm/chinese-days/dist/chinese-days.json',
    'https://unpkg.com/chinese-days/dist/chinese-days.json',
  ];

  static const String _cacheKey = 'chinese_holiday_data';
  static const String _etagKey = 'chinese_holiday_etag';
  static const String _lastUpdateKey = 'chinese_holiday_last_update';
  static const String _lastSuccessfulUrlKey = 'chinese_holiday_last_url';

  /// Duration after which to check for updates (24 hours)
  static const Duration _updateCheckInterval = Duration(hours: 24);

  /// Singleton instance
  static final ChineseHolidayService _instance =
      ChineseHolidayService._internal();

  /// Cached holiday data
  Map<String, dynamic>? _cachedData;

  /// Get holiday data with caching and update mechanism
  Future<Map<String, dynamic>?> getHolidayData() async {
    try {
      // Check if we have cached data
      if (_cachedData != null) {
        return _cachedData;
      }

      // Try to load from local storage first
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      final lastUpdate = prefs.getString(_lastUpdateKey);

      if (cachedJson != null) {
        _cachedData = jsonDecode(cachedJson) as Map<String, dynamic>;

        // Check if we need to update
        if (lastUpdate != null) {
          final lastUpdateTime = DateTime.parse(lastUpdate);
          final now = DateTime.now();

          if (now.difference(lastUpdateTime) < _updateCheckInterval) {
            // Data is fresh, return cached data
            return _cachedData;
          }
        }

        // Data might be stale, check for updates in background
        unawaited(_checkForUpdatesInBackground());
        return _cachedData;
      }

      // No cached data, fetch from API
      return await _fetchFromApi();
    } on Exception catch (e) {
      log('Error getting holiday data: $e');
      return _cachedData; // Return cached data if available
    }
  }

  /// Fetch data from API and cache it
  /// Tries multiple API sources for redundancy
  Future<Map<String, dynamic>?> _fetchFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSuccessfulUrl = prefs.getString(_lastSuccessfulUrlKey);

    // Try last successful URL first if available
    final urlsToTry = <String>[];
    if (lastSuccessfulUrl != null && _apiUrls.contains(lastSuccessfulUrl)) {
      urlsToTry
        ..add(lastSuccessfulUrl)
        ..addAll(_apiUrls.where((url) => url != lastSuccessfulUrl));
    } else {
      urlsToTry.addAll(_apiUrls);
    }

    // Try each URL until one succeeds
    for (final apiUrl in urlsToTry) {
      try {
        log('Attempting to fetch from: $apiUrl');
        final response = await http
            .get(
              Uri.parse(apiUrl),
              headers: {'Accept': 'application/json'},
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;

          // Validate data structure
          if (data.containsKey('holidays') && data.containsKey('workdays')) {
            await _cacheData(data, response.headers['etag'], apiUrl);
            _cachedData = data;
            log('Successfully fetched data from: $apiUrl');
            return data;
          } else {
            log('Invalid data structure from API: $apiUrl');
          }
        } else {
          log('API request failed with status ${response.statusCode}: $apiUrl');
        }
      } on Exception catch (e) {
        log('Error fetching from $apiUrl: $e');
        // Continue to next URL
      }
    }

    log('All API sources failed');
    return null;
  }

  /// Check for updates using ETag mechanism
  Future<void> _checkForUpdatesInBackground() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedEtag = prefs.getString(_etagKey);
      final lastSuccessfulUrl = prefs.getString(_lastSuccessfulUrlKey);

      // Use last successful URL or first URL
      final urlToCheck = lastSuccessfulUrl ?? _apiUrls.first;

      // Use HEAD request to check ETag without downloading full content
      final response = await http
          .head(
            Uri.parse(urlToCheck),
          )
          .timeout(const Duration(seconds: 5));

      final currentEtag = response.headers['etag'];

      if (currentEtag != null && currentEtag != cachedEtag) {
        // ETag changed, fetch new data
        log('ETag changed, fetching new data');
        await _fetchFromApi();
      } else {
        // No changes, update last check time
        await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
      }
    } on Exception catch (e) {
      log('Error checking for updates: $e');
    }
  }

  /// Cache data locally
  Future<void> _cacheData(
    Map<String, dynamic> data,
    String? etag,
    String successfulUrl,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(data));
      await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
      await prefs.setString(_lastSuccessfulUrlKey, successfulUrl);

      if (etag != null) {
        await prefs.setString(_etagKey, etag);
      }
    } on Exception catch (e) {
      log('Error caching data: $e');
    }
  }

  /// Check if a date is a holiday (休)
  bool isHoliday(String dateString) {
    try {
      if (_cachedData == null) return false;

      final holidays = _cachedData!['holidays'] as Map<String, dynamic>?;
      return holidays?.containsKey(dateString) ?? false;
    } on Exception catch (e) {
      log('Error checking holiday status: $e');
      return false;
    }
  }

  /// Check if a date is a workday (班)
  bool isWorkday(String dateString) {
    try {
      if (_cachedData == null) return false;

      final workdays = _cachedData!['workdays'] as Map<String, dynamic>?;
      return workdays?.containsKey(dateString) ?? false;
    } on Exception catch (e) {
      log('Error checking workday status: $e');
      return false;
    }
  }

  /// Get holiday info for a date
  String? getHolidayInfo(String dateString) {
    try {
      if (_cachedData == null) return null;

      final holidays = _cachedData!['holidays'] as Map<String, dynamic>?;
      final workdays = _cachedData!['workdays'] as Map<String, dynamic>?;

      if (holidays?.containsKey(dateString) ?? false) {
        return holidays![dateString] as String?;
      }

      if (workdays?.containsKey(dateString) ?? false) {
        return workdays![dateString] as String?;
      }

      return null;
    } on Exception catch (e) {
      log('Error getting holiday info: $e');
      return null;
    }
  }

  /// Clear cached data (for testing or manual refresh)
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_etagKey);
      await prefs.remove(_lastUpdateKey);
      _cachedData = null;
    } on Exception catch (e) {
      log('Error clearing cache: $e');
    }
  }

  /// Force refresh data from API
  Future<Map<String, dynamic>?> forceRefresh() async {
    await clearCache();
    return _fetchFromApi();
  }
}
