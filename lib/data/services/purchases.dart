// ignore_for_file: unused_field, unused_element

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchasesService {
  PurchasesService._getInstance();
  static final PurchasesService _instance = PurchasesService._getInstance();
  static PurchasesService get instance => _instance;

  Offering? _proOffering;
  Offering? get proOffering => _proOffering;

  Offering? _proSubscriptionOffering;
  Offering? get proSubscriptionoffering => _proSubscriptionOffering;

  Package? _subscriptionPackage;

  CustomerInfo? _customerInfo;

  bool _userIsPro = false;
  // bool get userIsPro => false, when testing to always show PayWall and payment flow
  bool get userIsPro => _userIsPro;

  final String _revenueCatiOSApiKey = 'appl_FKvwuFnkweReYdMSvRjUCQqGZFs';
  final String _revenueCatAndroidApiKey = 'goog_iKvfzRIURBzwgXzXBRNnPkqPODo';

  final String _receiptCampProEntitlementId = 'ReceiptCamp Pro';

  // ios: rcpro_499_1m
  // android: rcpro_499_1m:monthly-autorenewing
  final List<String> _productsList = ['rcpro_499_1m', 'rcpro_499_1m:monthly-autorenewing'];

  Future<void> initPlatformState() async {
    try {
      await Purchases.setLogLevel(LogLevel.debug);

      PurchasesConfiguration? configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_revenueCatAndroidApiKey);
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_revenueCatiOSApiKey);
      }

      if (configuration == null) {
        throw Exception(
            'PurchasesService: PurchasesConfiguration failed to initialise.');
      }

      await Purchases.configure(configuration);

      await _fetchAvailableOfferings();
      await checkCustomerPurchaseStatus();

      // _outputPurchaseServiceInfo();
      // _outputSubscriptionPackageDetails();
      _outputCustomerInfo();

      print('_userIsPro = $_userIsPro');

    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future<void> _fetchAvailableOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        _proOffering = offerings.current;
        _subscriptionPackage = _proOffering!.monthly;
      }
    } on PlatformException catch (e) {
      print(e.toString());
      print('Failed to fetch products');
    }
  }

   Future<void> checkCustomerPurchaseStatus() async {
    try {
      CustomerInfo latestCustomerInfo = await Purchases.getCustomerInfo();
      _customerInfo = latestCustomerInfo;
      // customerInfo.entitlements.all will be null when the user
      // has not purchased a product that’s attached to an entitlement yet, the EntitlementInfo object
      if (latestCustomerInfo.allPurchasedProductIdentifiers.isNotEmpty) {
        _userIsPro = true;
      } else {
        _userIsPro = false;
      }
    } on PlatformException catch (e) {
      print(e.toString());
      _userIsPro = false;
    }
  }

  // works on android only
  Future<bool> canMakePayments() async {
    try {
      if ((await Purchases.canMakePayments())) {
        return true;
      } else {
        return false;
      }
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> makeProSubscriptionPurchase() async {
    try {
      CustomerInfo purchaserInfo =
          await Purchases.purchasePackage(_subscriptionPackage!);
      EntitlementInfo? entitlement = purchaserInfo
          .entitlements.active[_receiptCampProEntitlementId];
      if (entitlement!.isActive) {
        _userIsPro = true;
        return true;
      } else {
        _userIsPro = false;
        return false;
      }
    } on PlatformException catch (e) {
      print('Purchase failed: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      CustomerInfo restoredInfo = await Purchases.restorePurchases();
      print(restoredInfo.activeSubscriptions);
      // checking restored customerInfo to see if entitlement is now active
      if (restoredInfo.entitlements.active[_receiptCampProEntitlementId]!.isActive) {
        _userIsPro = true;
      } else {
        _userIsPro = false;
      }
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

   void _outputCustomerInfo() {
    if (_customerInfo != null) {
      print('customerInfo.originalAppUserId: ${_customerInfo!.originalAppUserId}');
      print('customerInfo.activeSubscriptions: ${_customerInfo!.activeSubscriptions}');
      print('customerInfo.allPurchasedProductIdentifiers: ${_customerInfo!.allPurchasedProductIdentifiers}');
    } else {
      print('customer info is null');
    }
    
  }

  void _outputPurchaseServiceInfo() {
    print('Offering: ${proOffering!.identifier}');
    print('Server Description: ${proOffering!.serverDescription}');
    print('Available Packages:');
    for (var package in proOffering!.availablePackages) {
      print('Package Identifier: ${package.identifier}');
      print('Package Type: ${package.packageType}');
      StoreProduct product = package.storeProduct;
      print('Store Product Identifier: ${product.identifier}');
      print('Description: ${product.description}');
      print('Title: ${product.title}');
      print('Price: ${product.price}');
      print('Price String: ${product.priceString}');
      print('Currency Code: ${product.currencyCode}');
      // print('Introductory Price: ${product.introductoryPrice}');
      // print('Discounts: ${product.discounts}');
      print('Product Category: ${product.productCategory}');
    }
  }

  void _outputSubscriptionPackageDetails() {
    print('Subscription Package details');
    print('identifier: ${_subscriptionPackage!.identifier}');
    print('offering identifier: ${_subscriptionPackage!.offeringIdentifier}');
    print('package type: ${_subscriptionPackage!.packageType}');
  }
}
