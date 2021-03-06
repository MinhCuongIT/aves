import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/coordinate_format.dart';
import 'package:aves/model/settings/home_page.dart';
import 'package:aves/model/settings/screen_on.dart';
import 'package:aves/widgets/fullscreen/info/location_section.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../source/enums.dart';

final Settings settings = Settings._private();

typedef SettingsCallback = void Function(String key, dynamic oldValue, dynamic newValue);

class Settings extends ChangeNotifier {
  static SharedPreferences _prefs;

  Settings._private();

  // app
  static const hasAcceptedTermsKey = 'has_accepted_terms';
  static const isCrashlyticsEnabledKey = 'is_crashlytics_enabled';
  static const mustBackTwiceToExitKey = 'must_back_twice_to_exit';
  static const keepScreenOnKey = 'keep_screen_on';
  static const homePageKey = 'home_page';
  static const catalogTimeZoneKey = 'catalog_time_zone';
  static const tileExtentPrefixKey = 'tile_extent_';

  // collection
  static const collectionGroupFactorKey = 'collection_group_factor';
  static const collectionSortFactorKey = 'collection_sort_factor';
  static const showThumbnailLocationKey = 'show_thumbnail_location';
  static const showThumbnailRawKey = 'show_thumbnail_raw';
  static const showThumbnailVideoDurationKey = 'show_thumbnail_video_duration';

  // filter grids
  static const albumSortFactorKey = 'album_sort_factor';
  static const countrySortFactorKey = 'country_sort_factor';
  static const tagSortFactorKey = 'tag_sort_factor';
  static const pinnedFiltersKey = 'pinned_filters';

  // viewer
  static const showOverlayMinimapKey = 'show_overlay_minimap';
  static const showOverlayShootingDetailsKey = 'show_overlay_shooting_details';

  // info
  static const infoMapStyleKey = 'info_map_style';
  static const infoMapZoomKey = 'info_map_zoom';
  static const coordinateFormatKey = 'coordinates_format';

  // rendering
  static const svgBackgroundKey = 'svg_background';

  // search
  static const saveSearchHistoryKey = 'save_search_history';
  static const searchHistoryKey = 'search_history';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Crashlytics initialization is separated from the main settings initialization
  // to allow settings customization without Firebase context (e.g. before a Flutter Driver test)
  Future<void> initFirebase() async {
    await Firebase.app().setAutomaticDataCollectionEnabled(isCrashlyticsEnabled);
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(isCrashlyticsEnabled);
    await FirebaseAnalytics().setAnalyticsCollectionEnabled(isCrashlyticsEnabled);
    // enable analytics debug mode:
    // # %ANDROID_SDK%/platform-tools/adb shell setprop debug.firebase.analytics.app deckers.thibault.aves.debug
    // disable analytics debug mode:
    // # %ANDROID_SDK%/platform-tools/adb shell setprop debug.firebase.analytics.app .none.
  }

  Future<void> reset() {
    return _prefs.clear();
  }

  // app

  bool get hasAcceptedTerms => getBoolOrDefault(hasAcceptedTermsKey, false);

  set hasAcceptedTerms(bool newValue) => setAndNotify(hasAcceptedTermsKey, newValue);

  bool get isCrashlyticsEnabled => getBoolOrDefault(isCrashlyticsEnabledKey, true);

  set isCrashlyticsEnabled(bool newValue) {
    setAndNotify(isCrashlyticsEnabledKey, newValue);
    unawaited(initFirebase());
  }

  bool get mustBackTwiceToExit => getBoolOrDefault(mustBackTwiceToExitKey, true);

  set mustBackTwiceToExit(bool newValue) => setAndNotify(mustBackTwiceToExitKey, newValue);

  KeepScreenOn get keepScreenOn => getEnumOrDefault(keepScreenOnKey, KeepScreenOn.fullscreenOnly, KeepScreenOn.values);

  set keepScreenOn(KeepScreenOn newValue) {
    setAndNotify(keepScreenOnKey, newValue.toString());
    newValue.apply();
  }

  HomePageSetting get homePage => getEnumOrDefault(homePageKey, HomePageSetting.collection, HomePageSetting.values);

  set homePage(HomePageSetting newValue) => setAndNotify(homePageKey, newValue.toString());

  String get catalogTimeZone => _prefs.getString(catalogTimeZoneKey) ?? '';

  set catalogTimeZone(String newValue) => setAndNotify(catalogTimeZoneKey, newValue);

  double getTileExtent(String routeName) => _prefs.getDouble(tileExtentPrefixKey + routeName) ?? 0;

  // do not notify, as tile extents are only used internally by `TileExtentManager`
  // and should not trigger rebuilding by change notification
  void setTileExtent(String routeName, double newValue) => setAndNotify(tileExtentPrefixKey + routeName, newValue, notify: false);

  // collection

  EntryGroupFactor get collectionGroupFactor => getEnumOrDefault(collectionGroupFactorKey, EntryGroupFactor.month, EntryGroupFactor.values);

  set collectionGroupFactor(EntryGroupFactor newValue) => setAndNotify(collectionGroupFactorKey, newValue.toString());

  EntrySortFactor get collectionSortFactor => getEnumOrDefault(collectionSortFactorKey, EntrySortFactor.date, EntrySortFactor.values);

  set collectionSortFactor(EntrySortFactor newValue) => setAndNotify(collectionSortFactorKey, newValue.toString());

  bool get showThumbnailLocation => getBoolOrDefault(showThumbnailLocationKey, true);

  set showThumbnailLocation(bool newValue) => setAndNotify(showThumbnailLocationKey, newValue);

  bool get showThumbnailRaw => getBoolOrDefault(showThumbnailRawKey, true);

  set showThumbnailRaw(bool newValue) => setAndNotify(showThumbnailRawKey, newValue);

  bool get showThumbnailVideoDuration => getBoolOrDefault(showThumbnailVideoDurationKey, true);

  set showThumbnailVideoDuration(bool newValue) => setAndNotify(showThumbnailVideoDurationKey, newValue);

  // filter grids

  ChipSortFactor get albumSortFactor => getEnumOrDefault(albumSortFactorKey, ChipSortFactor.name, ChipSortFactor.values);

  set albumSortFactor(ChipSortFactor newValue) => setAndNotify(albumSortFactorKey, newValue.toString());

  ChipSortFactor get countrySortFactor => getEnumOrDefault(countrySortFactorKey, ChipSortFactor.name, ChipSortFactor.values);

  set countrySortFactor(ChipSortFactor newValue) => setAndNotify(countrySortFactorKey, newValue.toString());

  ChipSortFactor get tagSortFactor => getEnumOrDefault(tagSortFactorKey, ChipSortFactor.name, ChipSortFactor.values);

  set tagSortFactor(ChipSortFactor newValue) => setAndNotify(tagSortFactorKey, newValue.toString());

  Set<CollectionFilter> get pinnedFilters => (_prefs.getStringList(pinnedFiltersKey) ?? []).map(CollectionFilter.fromJson).toSet();

  set pinnedFilters(Set<CollectionFilter> newValue) => setAndNotify(pinnedFiltersKey, newValue.map((filter) => filter.toJson()).toList());

  // viewer

  bool get showOverlayMinimap => getBoolOrDefault(showOverlayMinimapKey, false);

  set showOverlayMinimap(bool newValue) => setAndNotify(showOverlayMinimapKey, newValue);

  bool get showOverlayShootingDetails => getBoolOrDefault(showOverlayShootingDetailsKey, true);

  set showOverlayShootingDetails(bool newValue) => setAndNotify(showOverlayShootingDetailsKey, newValue);

  // info

  EntryMapStyle get infoMapStyle => getEnumOrDefault(infoMapStyleKey, EntryMapStyle.stamenWatercolor, EntryMapStyle.values);

  set infoMapStyle(EntryMapStyle newValue) => setAndNotify(infoMapStyleKey, newValue.toString());

  double get infoMapZoom => _prefs.getDouble(infoMapZoomKey) ?? 12;

  set infoMapZoom(double newValue) => setAndNotify(infoMapZoomKey, newValue);

  CoordinateFormat get coordinateFormat => getEnumOrDefault(coordinateFormatKey, CoordinateFormat.dms, CoordinateFormat.values);

  set coordinateFormat(CoordinateFormat newValue) => setAndNotify(coordinateFormatKey, newValue.toString());

  // rendering

  int get svgBackground => _prefs.getInt(svgBackgroundKey) ?? 0xFFFFFFFF;

  set svgBackground(int newValue) => setAndNotify(svgBackgroundKey, newValue);

  // search

  bool get saveSearchHistory => getBoolOrDefault(saveSearchHistoryKey, true);

  set saveSearchHistory(bool newValue) => setAndNotify(saveSearchHistoryKey, newValue);

  List<CollectionFilter> get searchHistory => (_prefs.getStringList(searchHistoryKey) ?? []).map(CollectionFilter.fromJson).toList();

  set searchHistory(List<CollectionFilter> newValue) => setAndNotify(searchHistoryKey, newValue.map((filter) => filter.toJson()).toList());

  // convenience methods

  // ignore: avoid_positional_boolean_parameters
  bool getBoolOrDefault(String key, bool defaultValue) => _prefs.getKeys().contains(key) ? _prefs.getBool(key) : defaultValue;

  T getEnumOrDefault<T>(String key, T defaultValue, Iterable<T> values) {
    final valueString = _prefs.getString(key);
    for (final element in values) {
      if (element.toString() == valueString) {
        return element;
      }
    }
    return defaultValue;
  }

  List<T> getEnumListOrDefault<T>(String key, List<T> defaultValue, Iterable<T> values) {
    return _prefs.getStringList(key)?.map((s) => values.firstWhere((el) => el.toString() == s, orElse: () => null))?.where((el) => el != null)?.toList() ?? defaultValue;
  }

  void setAndNotify(String key, dynamic newValue, {bool notify = true}) {
    var oldValue = _prefs.get(key);
    if (newValue == null) {
      _prefs.remove(key);
    } else if (newValue is String) {
      oldValue = _prefs.getString(key);
      _prefs.setString(key, newValue);
    } else if (newValue is List<String>) {
      oldValue = _prefs.getStringList(key);
      _prefs.setStringList(key, newValue);
    } else if (newValue is int) {
      oldValue = _prefs.getInt(key);
      _prefs.setInt(key, newValue);
    } else if (newValue is double) {
      oldValue = _prefs.getDouble(key);
      _prefs.setDouble(key, newValue);
    } else if (newValue is bool) {
      oldValue = _prefs.getBool(key);
      _prefs.setBool(key, newValue);
    }
    if (oldValue != newValue && notify) {
      notifyListeners();
    }
  }
}
