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
  bool get userIsPro => _userIsPro;

  final String _revenueCatiOSApiKey = 'appl_FKvwuFnkweReYdMSvRjUCQqGZFs';
  final String _revenueCatAndroidApiKey = 'goog_iKvfzRIURBzwgXzXBRNnPkqPODo';

  final String _receiptCampProEntitlementId = 'ReceiptCamp Pro';

  final String _receiptCampProSubscriptionEntitlementId = '';

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

      await _fetchAvailableProducts();

      _outputPurchaseServiceInfo();
      _outputLifetimePackageDetails();

      await _checkCustomerPurchaseStatus();

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

  Future<void> _fetchAvailableProducts() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        _lifetimePackage = offerings.all['pro-offering']!.availablePackages[0];
        _proOffering = offerings.all['pro-offering'];
      }
    } on PlatformException catch (e) {
      print(e.toString());
      print('Failed to fetch products');
    }
  }

  void makeProPurchase() async {
    try {
      CustomerInfo purchaserInfo =
          await Purchases.purchasePackage(_lifetimePackage!);
      EntitlementInfo? entitlement =
          purchaserInfo.entitlements.all[_receiptCampProEntitlementId];
      if (entitlement!.isActive) {
        // Handle successful purchase
      } else {
        // Handle failed purchase
      }
    } on PlatformException catch (e) {
      print('Purchase failed: $e');
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

  Future<void> _checkCustomerPurchaseStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      print(customerInfo.entitlements.all);
      if (customerInfo.entitlements.all['ReceiptCamp Pro']!.isActive) {
        _userIsPro = true;
      } else {
        _userIsPro = false;
      }
    } on PlatformException catch (e) {
      print(e.toString());
      _userIsPro = false;
    }
  }

  Future<List<String>> restorePurchases() async {
    try {
      CustomerInfo restoredInfo = await Purchases.restorePurchases();
      if (restoredInfo.entitlements.all['']!.isActive) {
        // ... check restored customerInfo to see if entitlement is now active
        return restoredInfo.allPurchasedProductIdentifiers;
      } else {
        return <String>[];
      }
    } on PlatformException catch (e) {
      print(e.toString());
      return <String>[];
    }
  }
}
