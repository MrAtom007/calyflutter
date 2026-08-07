import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'analytics_service.dart';

/// Monetizzazione reale tramite RevenueCat (Play Billing / StoreKit).
///
/// Progettato per un rollout a basso rischio dietro feature-flag:
/// - se non è impostata una API key (`--dart-define=RC_ANDROID_KEY=...` /
///   `RC_IOS_KEY=...`), il servizio resta **disattivato** e ogni metodo è no-op.
/// - in quel caso l'app continua a usare lo sblocco locale esistente
///   (ThemeProvider.unlock...), esattamente come oggi.
///
/// Quando la key è presente:
/// - `init()` configura l'SDK e carica lo stato "premium".
/// - `hasPremium` riflette l'entitlement `premium` di RevenueCat.
/// - `buyPremium()` avvia l'acquisto del pacchetto corrente.
/// - `restore()` ripristina gli acquisti su un nuovo dispositivo.
class MonetizationService {
  MonetizationService._();

  /// Identificatore dell'entitlement configurato nella dashboard RevenueCat.
  static const String kEntitlementId = 'premium';

  /// API key iniettate a build-time (nessun segreto nel repo):
  ///   flutter build appbundle --dart-define=RC_ANDROID_KEY=goog_xxx
  static const String _androidKey =
      String.fromEnvironment('RC_ANDROID_KEY', defaultValue: '');
  static const String _iosKey =
      String.fromEnvironment('RC_IOS_KEY', defaultValue: '');

  static bool _configured = false;
  static bool _hasPremium = false;

  /// Notifica i listener (es. ThemeProvider/StoreScreen) quando cambia lo stato.
  static final ValueNotifier<bool> premium = ValueNotifier<bool>(false);

  /// True solo se una API key è stata fornita: altrimenti tutto è no-op.
  static bool get isAvailable =>
      (defaultTargetPlatform == TargetPlatform.iOS ? _iosKey : _androidKey)
          .isNotEmpty;

  static bool get hasPremium => _hasPremium;

  static String get _apiKey =>
      defaultTargetPlatform == TargetPlatform.iOS ? _iosKey : _androidKey;

  /// Configura l'SDK. Sicura da chiamare sempre: se non c'è la key, esce subito.
  static Future<void> init({String? appUserId}) async {
    if (_configured || !isAvailable) return;
    try {
      await Purchases.setLogLevel(
          kReleaseMode ? LogLevel.error : LogLevel.debug);
      await Purchases.configure(
        PurchasesConfiguration(_apiKey)..appUserID = appUserId,
      );
      Purchases.addCustomerInfoUpdateListener(_apply);
      final info = await Purchases.getCustomerInfo();
      _apply(info);
      _configured = true;
    } catch (e, s) {
      AnalyticsService.recordError(e, s, reason: 'monetization_init');
    }
  }

  static void _apply(CustomerInfo info) {
    final active = info.entitlements.active.containsKey(kEntitlementId);
    _hasPremium = active;
    premium.value = active;
  }

  /// Allinea l'identità RevenueCat all'utente loggato (dopo login Google).
  static Future<void> identify(String uid) async {
    if (!_configured) return;
    try {
      final res = await Purchases.logIn(uid);
      _apply(res.customerInfo);
    } catch (_) {}
  }

  static Future<void> signOut() async {
    if (!_configured) return;
    try {
      final info = await Purchases.logOut();
      _apply(info);
    } catch (_) {}
  }

  /// Offerta corrente (pacchetti configurati su RevenueCat), o null.
  static Future<Offering?> currentOffering() async {
    if (!_configured) return null;
    try {
      return (await Purchases.getOfferings()).current;
    } catch (_) {
      return null;
    }
  }

  /// Avvia l'acquisto del primo pacchetto disponibile dell'offerta corrente.
  /// Restituisce true se l'entitlement premium risulta attivo dopo l'acquisto.
  static Future<bool> buyPremium() async {
    if (!_configured) return false;
    try {
      final offering = await currentOffering();
      final pkg = offering?.availablePackages.isNotEmpty == true
          ? offering!.availablePackages.first
          : null;
      if (pkg == null) return false;
      final info = await Purchases.purchasePackage(pkg);
      _apply(info);
      if (_hasPremium) {
        final p = pkg.storeProduct;
        AnalyticsService.purchase(p.identifier, p.price, p.currencyCode);
      }
      return _hasPremium;
    } on PurchasesErrorCode catch (_) {
      return false;
    } catch (e, s) {
      AnalyticsService.recordError(e, s, reason: 'buy_premium');
      return false;
    }
  }

  /// Ripristina acquisti precedenti (obbligatorio per policy store).
  static Future<bool> restore() async {
    if (!_configured) return false;
    try {
      final info = await Purchases.restorePurchases();
      _apply(info);
      return _hasPremium;
    } catch (_) {
      return false;
    }
  }
}
