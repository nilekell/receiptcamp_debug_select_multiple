// ignore_for_file: unused_field

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

  Package? _lifetimePackage;
  Package? _subscriptionPackage;

  bool _userIsPro = false;
  // bool get userIsPro => false, when testing to always show PayWall and payment flow
  bool get userIsPro => false;

  final String _revenueCatiOSApiKey = 'appl_FKvwuFnkweReYdMSvRjUCQqGZFs';
  final String _revenueCatAndroidApiKey = 'goog_iKvfzRIURBzwgXzXBRNnPkqPODo';

  final String _receiptCampProEntitlementId = 'ReceiptCamp Pro';
  final String _receiptCampProSubscriptionEntitlementId = '';

  // ios: receiptcamp_pro_purchase
  // android: receiptcamp_pro_v1
  final List<String> _productsList = ['receiptcamp_pro_purchase', 'receiptcamp_pro_v1'];

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

      _outputPurchaseServiceInfo();
      _outputLifetimePackageDetails();

      await checkCustomerPurchaseStatus();

    } on Exception catch (e) {
      print(e.toString());
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

  void _outputLifetimePackageDetails() {
    print('Lifeime Package details');
    print('identifier: ${_lifetimePackage!.identifier}');
    print('offering identifier: ${_lifetimePackage!.offeringIdentifier}');
    print('package type: ${_lifetimePackage!.packageType}');
  }

  Future<void> _fetchAvailableOfferings() async {
    try {
      // final List<StoreProduct> products = await Purchases.getProducts(['receiptcamp_pro_purchase', 'receiptcamp_pro_v1']);
      // print(products);
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        _proOffering = offerings.all['pro-offering'];
        _lifetimePackage = offerings.all['pro-offering']!.availablePackages[0];
        // add code to get __subscriptionPackage, when subscription is implemented
      }
    } on PlatformException catch (e) {
      print(e.toString());
      print('Failed to fetch products');
    }
  }

  Future<bool> makeProPurchase() async {
    try {
      CustomerInfo purchaserInfo =
          await Purchases.purchasePackage(_lifetimePackage!);
      EntitlementInfo? entitlement =
          purchaserInfo.entitlements.all[_receiptCampProEntitlementId];
      if (entitlement!.isActive) {
        return true;
      } else {
        return false;
      }
    } on PlatformException catch (e) {
      print('Purchase failed: $e');
      return false;
    }
  }

  void makeProSubscriptionPurchase() async {
    try {
      CustomerInfo purchaserInfo =
          await Purchases.purchasePackage(_subscriptionPackage!);
      EntitlementInfo? entitlement = purchaserInfo
          .entitlements.all[_receiptCampProSubscriptionEntitlementId];
      if (entitlement!.isActive) {
        // Handle successful purchase
      } else {
        // Handle failed purchase
      }
    } on PlatformException catch (e) {
      print('Purchase failed: $e');
    }
  }

  Future<void> checkCustomerPurchaseStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      // customerInfo.entitlements.all will be null when the user
      // has not purchased a product that’s attached to an entitlement yet, the EntitlementInfo object 
      print('customerInfo.allPurchasedProductIdentifiers: ${customerInfo.allPurchasedProductIdentifiers}');
      if (customerInfo.allPurchasedProductIdentifiers.isNotEmpty) {
        _userIsPro = true;
      } else {
        _userIsPro = false;
      }
    } on PlatformException catch (e) {
      print(e.toString());
      _userIsPro = false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      CustomerInfo restoredInfo = await Purchases.restorePurchases();
      // checking restored customerInfo to see if entitlement is now active
      if (restoredInfo.entitlements.all['ReceiptCamp Pro']!.isActive) {
        _userIsPro = true;
      } else {
        _userIsPro = false;
      }
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }
}
