import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Aligo'**
  String get appTitle;

  /// No description provided for @couldNotReachServer.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the Aligo server. Check your connection.'**
  String get couldNotReachServer;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get somethingWentWrong;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @languagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languagePickerTitle;

  /// No description provided for @languagePickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change this later from the menu.'**
  String get languagePickerSubtitle;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @languageUzbek.
  ///
  /// In en, this message translates to:
  /// **'O\'zbekcha'**
  String get languageUzbek;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @loginWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to Aligo'**
  String get loginWelcomeTitle;

  /// No description provided for @loginWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll email you a one-time code to sign in\nand track your cargo in real time.'**
  String get loginWelcomeSubtitle;

  /// No description provided for @emailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddressLabel;

  /// No description provided for @emailAddressHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailAddressHint;

  /// No description provided for @continueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with email'**
  String get continueWithEmail;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccountPrompt;

  /// No description provided for @createOne.
  ///
  /// In en, this message translates to:
  /// **'Create one'**
  String get createOne;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed: {error}'**
  String googleSignInFailed(String error);

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createAccountTitle;

  /// No description provided for @joinAligo.
  ///
  /// In en, this message translates to:
  /// **'Join Aligo'**
  String get joinAligo;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll email you a verification code to confirm it\'s you.'**
  String get signupSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Jasur Karimov'**
  String get fullNameHint;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @sendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Send verification code'**
  String get sendVerificationCode;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmailTitle;

  /// No description provided for @enterCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code we sent'**
  String get enterCodeTitle;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'We emailed a 6-digit verification code to {email}.'**
  String otpSentTo(String email);

  /// No description provided for @enterSixDigitCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code from your email'**
  String get enterSixDigitCode;

  /// No description provided for @verifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify & continue'**
  String get verifyAndContinue;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @resendPrompt.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get a code? Resend'**
  String get resendPrompt;

  /// No description provided for @newCodeSent.
  ///
  /// In en, this message translates to:
  /// **'A new code has been sent.'**
  String get newCodeSent;

  /// No description provided for @roleSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'How will you use Aligo?'**
  String get roleSelectTitle;

  /// No description provided for @roleSelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the option that fits you — you\'ll set up the matching details next.'**
  String get roleSelectSubtitle;

  /// No description provided for @driverRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'I drive cargo'**
  String get driverRoleTitle;

  /// No description provided for @driverRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register your vehicle and receive matching cargo requests.'**
  String get driverRoleSubtitle;

  /// No description provided for @shipperRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'I send cargo'**
  String get shipperRoleTitle;

  /// No description provided for @shipperRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Post shipments and find a driver nearby.'**
  String get shipperRoleSubtitle;

  /// No description provided for @driverProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver profile'**
  String get driverProfileTitle;

  /// No description provided for @shipperProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipper profile'**
  String get shipperProfileTitle;

  /// No description provided for @tellUsAboutYourself.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get tellUsAboutYourself;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumberLabel;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @homeAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Home address'**
  String get homeAddressLabel;

  /// No description provided for @enterAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your address'**
  String get enterAddress;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @enterValidAge.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid age'**
  String get enterValidAge;

  /// No description provided for @vehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle info'**
  String get vehicleInfo;

  /// No description provided for @brandModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand & model'**
  String get brandModelLabel;

  /// No description provided for @enterBrandModel.
  ///
  /// In en, this message translates to:
  /// **'Enter the vehicle brand/model'**
  String get enterBrandModel;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @colorHintExample.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorHintExample;

  /// No description provided for @enterColor.
  ///
  /// In en, this message translates to:
  /// **'Enter the vehicle color'**
  String get enterColor;

  /// No description provided for @plateNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Plate number'**
  String get plateNumberLabel;

  /// No description provided for @enterPlateNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter the plate number'**
  String get enterPlateNumber;

  /// No description provided for @sizeCapacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Size / capacity'**
  String get sizeCapacityLabel;

  /// No description provided for @sizeCapacityHintExample.
  ///
  /// In en, this message translates to:
  /// **'Up to 3 tons'**
  String get sizeCapacityHintExample;

  /// No description provided for @enterVehicleSize.
  ///
  /// In en, this message translates to:
  /// **'Enter the vehicle size'**
  String get enterVehicleSize;

  /// No description provided for @additionalAmenities.
  ///
  /// In en, this message translates to:
  /// **'Additional amenities'**
  String get additionalAmenities;

  /// No description provided for @saveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get saveAndContinue;

  /// No description provided for @whereToSendCargo.
  ///
  /// In en, this message translates to:
  /// **'Where to send your cargo?'**
  String get whereToSendCargo;

  /// No description provided for @findNearbyLoads.
  ///
  /// In en, this message translates to:
  /// **'Find nearby loads'**
  String get findNearbyLoads;

  /// No description provided for @premiumLogisticsAccount.
  ///
  /// In en, this message translates to:
  /// **'Premium logistics account'**
  String get premiumLogisticsAccount;

  /// No description provided for @aligoCargo.
  ///
  /// In en, this message translates to:
  /// **'Aligo Cargo'**
  String get aligoCargo;

  /// No description provided for @myShipments.
  ///
  /// In en, this message translates to:
  /// **'My Shipments'**
  String get myShipments;

  /// No description provided for @myDeliveries.
  ///
  /// In en, this message translates to:
  /// **'My Deliveries'**
  String get myDeliveries;

  /// No description provided for @paymentsInvoices.
  ///
  /// In en, this message translates to:
  /// **'Payments & Invoices'**
  String get paymentsInvoices;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appearanceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSectionTitle;

  /// No description provided for @themeSystemLabel.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystemLabel;

  /// No description provided for @themeLightLabel.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLightLabel;

  /// No description provided for @themeDarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDarkLabel;

  /// No description provided for @postShipmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Post a shipment'**
  String get postShipmentTitle;

  /// No description provided for @whatAreYouSending.
  ///
  /// In en, this message translates to:
  /// **'What are you sending?'**
  String get whatAreYouSending;

  /// No description provided for @cargoTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Cargo type'**
  String get cargoTypeLabel;

  /// No description provided for @chooseCargoType.
  ///
  /// In en, this message translates to:
  /// **'Choose a cargo type'**
  String get chooseCargoType;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Extra details for the driver'**
  String get descriptionHint;

  /// No description provided for @pickupLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup location'**
  String get pickupLocationLabel;

  /// No description provided for @dropoffLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Dropoff location'**
  String get dropoffLocationLabel;

  /// No description provided for @tapToSearchAddress.
  ///
  /// In en, this message translates to:
  /// **'Tap to search an address'**
  String get tapToSearchAddress;

  /// No description provided for @specialRequirements.
  ///
  /// In en, this message translates to:
  /// **'Special requirements (optional)'**
  String get specialRequirements;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price you\'ll pay'**
  String get priceLabel;

  /// No description provided for @priceHint.
  ///
  /// In en, this message translates to:
  /// **'500000'**
  String get priceHint;

  /// No description provided for @enterValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price'**
  String get enterValidPrice;

  /// No description provided for @estimatingPrice.
  ///
  /// In en, this message translates to:
  /// **'Calculating suggested price...'**
  String get estimatingPrice;

  /// No description provided for @priceEstimateSummary.
  ///
  /// In en, this message translates to:
  /// **'{distance} km • suggested: {price} {currency}'**
  String priceEstimateSummary(String distance, String price, String currency);

  /// No description provided for @currencyUzs.
  ///
  /// In en, this message translates to:
  /// **'UZS'**
  String get currencyUzs;

  /// No description provided for @postShipmentButton.
  ///
  /// In en, this message translates to:
  /// **'Post shipment'**
  String get postShipmentButton;

  /// No description provided for @choosePickupDropoff.
  ///
  /// In en, this message translates to:
  /// **'Choose a pickup and dropoff location'**
  String get choosePickupDropoff;

  /// No description provided for @searchAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Search for an address'**
  String get searchAddressHint;

  /// No description provided for @pickupAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Pickup address'**
  String get pickupAddressTitle;

  /// No description provided for @dropoffAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Dropoff address'**
  String get dropoffAddressTitle;

  /// No description provided for @surchargeAmount.
  ///
  /// In en, this message translates to:
  /// **'+{amount} {currency}'**
  String surchargeAmount(String amount, String currency);

  /// No description provided for @cargoGeneral.
  ///
  /// In en, this message translates to:
  /// **'General cargo'**
  String get cargoGeneral;

  /// No description provided for @cargoFurniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get cargoFurniture;

  /// No description provided for @cargoConstruction.
  ///
  /// In en, this message translates to:
  /// **'Construction materials'**
  String get cargoConstruction;

  /// No description provided for @cargoPerishable.
  ///
  /// In en, this message translates to:
  /// **'Food / perishable'**
  String get cargoPerishable;

  /// No description provided for @cargoEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment / machinery'**
  String get cargoEquipment;

  /// No description provided for @amenityRefrigerated.
  ///
  /// In en, this message translates to:
  /// **'Refrigerated'**
  String get amenityRefrigerated;

  /// No description provided for @amenitySideRearTent.
  ///
  /// In en, this message translates to:
  /// **'Side/rear opening tent'**
  String get amenitySideRearTent;

  /// No description provided for @amenityLift.
  ///
  /// In en, this message translates to:
  /// **'Lift'**
  String get amenityLift;

  /// No description provided for @amenityTieDownStraps.
  ///
  /// In en, this message translates to:
  /// **'Tie-down straps included'**
  String get amenityTieDownStraps;

  /// No description provided for @nearbyLoadsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby loads'**
  String get nearbyLoadsTitle;

  /// No description provided for @loadAccepted.
  ///
  /// In en, this message translates to:
  /// **'Load accepted!'**
  String get loadAccepted;

  /// No description provided for @alreadyTaken.
  ///
  /// In en, this message translates to:
  /// **'Already taken by another driver.'**
  String get alreadyTaken;

  /// No description provided for @noOpenLoads.
  ///
  /// In en, this message translates to:
  /// **'No open loads nearby right now.'**
  String get noOpenLoads;

  /// No description provided for @kmAway.
  ///
  /// In en, this message translates to:
  /// **'{km} km away'**
  String kmAway(String km);

  /// No description provided for @acceptButton.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptButton;

  /// No description provided for @myShipmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'My shipments'**
  String get myShipmentsTitle;

  /// No description provided for @postNewLoad.
  ///
  /// In en, this message translates to:
  /// **'Post new load'**
  String get postNewLoad;

  /// No description provided for @noShipmentsYet.
  ///
  /// In en, this message translates to:
  /// **'No shipments posted yet.'**
  String get noShipmentsYet;

  /// No description provided for @shipmentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Shipment cancelled.'**
  String get shipmentCancelled;

  /// No description provided for @thanksForRating.
  ///
  /// In en, this message translates to:
  /// **'Thanks for rating!'**
  String get thanksForRating;

  /// No description provided for @rateDriverTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate the driver'**
  String get rateDriverTitle;

  /// No description provided for @cancelShipment.
  ///
  /// In en, this message translates to:
  /// **'Cancel shipment'**
  String get cancelShipment;

  /// No description provided for @ratedDriverStars.
  ///
  /// In en, this message translates to:
  /// **'You rated the driver {stars}★'**
  String ratedDriverStars(int stars);

  /// No description provided for @rateDriverButton.
  ///
  /// In en, this message translates to:
  /// **'Rate driver'**
  String get rateDriverButton;

  /// No description provided for @driverFallback.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverFallback;

  /// No description provided for @shipmentDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipment details'**
  String get shipmentDetailsTitle;

  /// No description provided for @editShipmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit shipment'**
  String get editShipmentTitle;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @saveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChangesButton;

  /// No description provided for @shipmentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Shipment updated.'**
  String get shipmentUpdated;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @noDescriptionProvided.
  ///
  /// In en, this message translates to:
  /// **'No description provided.'**
  String get noDescriptionProvided;

  /// No description provided for @priceOnlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceOnlyLabel;

  /// No description provided for @postedOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Posted on {date}'**
  String postedOnLabel(String date);

  /// No description provided for @trackShipmentButton.
  ///
  /// In en, this message translates to:
  /// **'Track shipment'**
  String get trackShipmentButton;

  /// No description provided for @editLockedNotice.
  ///
  /// In en, this message translates to:
  /// **'This shipment can no longer be edited — a driver has already accepted it.'**
  String get editLockedNotice;

  /// No description provided for @myDeliveriesTitle.
  ///
  /// In en, this message translates to:
  /// **'My deliveries'**
  String get myDeliveriesTitle;

  /// No description provided for @noDeliveriesYet.
  ///
  /// In en, this message translates to:
  /// **'No accepted deliveries yet.'**
  String get noDeliveriesYet;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to share.'**
  String get locationPermissionRequired;

  /// No description provided for @markedPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Marked as picked up.'**
  String get markedPickedUp;

  /// No description provided for @markedDelivered.
  ///
  /// In en, this message translates to:
  /// **'Marked as delivered!'**
  String get markedDelivered;

  /// No description provided for @deliveryReleased.
  ///
  /// In en, this message translates to:
  /// **'Delivery released back to the pool.'**
  String get deliveryReleased;

  /// No description provided for @rateShipperTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate the shipper'**
  String get rateShipperTitle;

  /// No description provided for @sharingLiveLocation.
  ///
  /// In en, this message translates to:
  /// **'Sharing live location'**
  String get sharingLiveLocation;

  /// No description provided for @shareMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Share my location'**
  String get shareMyLocation;

  /// No description provided for @sharingStopsIfLeave.
  ///
  /// In en, this message translates to:
  /// **'Sharing stops if you leave this screen.'**
  String get sharingStopsIfLeave;

  /// No description provided for @pickedUpCargo.
  ///
  /// In en, this message translates to:
  /// **'Picked up cargo'**
  String get pickedUpCargo;

  /// No description provided for @markAsDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark as delivered'**
  String get markAsDelivered;

  /// No description provided for @releaseThisDelivery.
  ///
  /// In en, this message translates to:
  /// **'Release this delivery'**
  String get releaseThisDelivery;

  /// No description provided for @ratedShipperStars.
  ///
  /// In en, this message translates to:
  /// **'You rated the shipper {stars}★'**
  String ratedShipperStars(int stars);

  /// No description provided for @rateShipperButton.
  ///
  /// In en, this message translates to:
  /// **'Rate shipper'**
  String get rateShipperButton;

  /// No description provided for @shipperFallback.
  ///
  /// In en, this message translates to:
  /// **'Shipper'**
  String get shipperFallback;

  /// No description provided for @waitingForDriverLocation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for driver\'s location...'**
  String get waitingForDriverLocation;

  /// No description provided for @driverLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Driver last seen {seconds}s ago'**
  String driverLastSeen(int seconds);

  /// No description provided for @driverLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverLabel;

  /// No description provided for @statusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get statusOpen;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get statusInTransit;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @commentOptional.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get commentOptional;

  /// No description provided for @telegramTitle.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get telegramTitle;

  /// No description provided for @telegramIntro.
  ///
  /// In en, this message translates to:
  /// **'Connect our Telegram bot to get instant notifications when your shipments change status, and to manage loads right from Telegram.'**
  String get telegramIntro;

  /// No description provided for @telegramLinked.
  ///
  /// In en, this message translates to:
  /// **'✅ Telegram is connected'**
  String get telegramLinked;

  /// No description provided for @telegramNotLinked.
  ///
  /// In en, this message translates to:
  /// **'Telegram is not connected yet'**
  String get telegramNotLinked;

  /// No description provided for @telegramConnectButton.
  ///
  /// In en, this message translates to:
  /// **'Connect Telegram'**
  String get telegramConnectButton;

  /// No description provided for @telegramUnlinkButton.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get telegramUnlinkButton;

  /// No description provided for @telegramOpenBotButton.
  ///
  /// In en, this message translates to:
  /// **'Open the bot'**
  String get telegramOpenBotButton;

  /// No description provided for @telegramCodeInstructions.
  ///
  /// In en, this message translates to:
  /// **'Or send this code to the bot manually:'**
  String get telegramCodeInstructions;

  /// No description provided for @telegramCodeExpiry.
  ///
  /// In en, this message translates to:
  /// **'This code expires in {minutes} minutes.'**
  String telegramCodeExpiry(int minutes);

  /// No description provided for @telegramUnlinkedMessage.
  ///
  /// In en, this message translates to:
  /// **'Telegram disconnected.'**
  String get telegramUnlinkedMessage;

  /// No description provided for @telegramCouldNotOpenBot.
  ///
  /// In en, this message translates to:
  /// **'Could not open the bot. Send the code manually instead.'**
  String get telegramCouldNotOpenBot;

  /// No description provided for @telegramBotNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'The Telegram bot isn\'t set up yet — ask the team to add a bot token.'**
  String get telegramBotNotConfigured;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'A new version is available'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'Aligo {version} is out. Download it to get the latest fixes.'**
  String updateAvailableBody(String version);

  /// No description provided for @updateDownloadButton.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get updateDownloadButton;

  /// No description provided for @getAndroidApp.
  ///
  /// In en, this message translates to:
  /// **'Get the Android app'**
  String get getAndroidApp;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @logoutConfirmText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmText;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
