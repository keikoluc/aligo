// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Aligo';

  @override
  String get couldNotReachServer =>
      'Could not reach the Aligo server. Check your connection.';

  @override
  String get somethingWentWrong => 'Something went wrong.';

  @override
  String get cancel => 'Cancel';

  @override
  String get submit => 'Submit';

  @override
  String get languagePickerTitle => 'Choose your language';

  @override
  String get languagePickerSubtitle =>
      'You can change this later from the menu.';

  @override
  String get continueButton => 'Continue';

  @override
  String get languageUzbek => 'O\'zbekcha';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String get loginWelcomeTitle => 'Welcome back to Aligo';

  @override
  String get loginWelcomeSubtitle =>
      'We\'ll email you a one-time code to sign in\nand track your cargo in real time.';

  @override
  String get emailAddressLabel => 'Email address';

  @override
  String get emailAddressHint => 'you@example.com';

  @override
  String get continueWithEmail => 'Continue with email';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get noAccountPrompt => 'Don\'t have an account? ';

  @override
  String get createOne => 'Create one';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String googleSignInFailed(String error) {
    return 'Google sign-in failed: $error';
  }

  @override
  String get createAccountTitle => 'Create your account';

  @override
  String get joinAligo => 'Join Aligo';

  @override
  String get signupSubtitle =>
      'We\'ll email you a verification code to confirm it\'s you.';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get fullNameHint => 'Jasur Karimov';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get sendVerificationCode => 'Send verification code';

  @override
  String get verifyEmailTitle => 'Verify your email';

  @override
  String get enterCodeTitle => 'Enter the code we sent';

  @override
  String otpSentTo(String email) {
    return 'We emailed a 6-digit verification code to $email.';
  }

  @override
  String get enterSixDigitCode => 'Enter the 6-digit code from your email';

  @override
  String get verifyAndContinue => 'Verify & continue';

  @override
  String get sending => 'Sending...';

  @override
  String get resendPrompt => 'Didn\'t get a code? Resend';

  @override
  String get newCodeSent => 'A new code has been sent.';

  @override
  String get roleSelectTitle => 'How will you use Aligo?';

  @override
  String get roleSelectSubtitle =>
      'Choose the option that fits you — you\'ll set up the matching details next.';

  @override
  String get driverRoleTitle => 'I drive cargo';

  @override
  String get driverRoleSubtitle =>
      'Register your vehicle and receive matching cargo requests.';

  @override
  String get shipperRoleTitle => 'I send cargo';

  @override
  String get shipperRoleSubtitle => 'Post shipments and find a driver nearby.';

  @override
  String get driverProfileTitle => 'Driver profile';

  @override
  String get shipperProfileTitle => 'Shipper profile';

  @override
  String get tellUsAboutYourself => 'Tell us about yourself';

  @override
  String get phoneNumberLabel => 'Phone number';

  @override
  String get enterPhoneNumber => 'Enter your phone number';

  @override
  String get homeAddressLabel => 'Home address';

  @override
  String get enterAddress => 'Enter your address';

  @override
  String get ageLabel => 'Age';

  @override
  String get enterValidAge => 'Enter a valid age';

  @override
  String get vehicleInfo => 'Vehicle info';

  @override
  String get brandModelLabel => 'Brand & model';

  @override
  String get enterBrandModel => 'Enter the vehicle brand/model';

  @override
  String get colorLabel => 'Color';

  @override
  String get colorHintExample => 'White';

  @override
  String get enterColor => 'Enter the vehicle color';

  @override
  String get plateNumberLabel => 'Plate number';

  @override
  String get enterPlateNumber => 'Enter the plate number';

  @override
  String get sizeCapacityLabel => 'Size / capacity';

  @override
  String get sizeCapacityHintExample => 'Up to 3 tons';

  @override
  String get enterVehicleSize => 'Enter the vehicle size';

  @override
  String get additionalAmenities => 'Additional amenities';

  @override
  String get saveAndContinue => 'Save and continue';

  @override
  String get whereToSendCargo => 'Where to send your cargo?';

  @override
  String get findNearbyLoads => 'Find nearby loads';

  @override
  String get premiumLogisticsAccount => 'Premium logistics account';

  @override
  String get aligoCargo => 'Aligo Cargo';

  @override
  String get myShipments => 'My Shipments';

  @override
  String get myDeliveries => 'My Deliveries';

  @override
  String get paymentsInvoices => 'Payments & Invoices';

  @override
  String get support => 'Support';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get postShipmentTitle => 'Post a shipment';

  @override
  String get whatAreYouSending => 'What are you sending?';

  @override
  String get cargoTypeLabel => 'Cargo type';

  @override
  String get chooseCargoType => 'Choose a cargo type';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get descriptionHint => 'Extra details for the driver';

  @override
  String get pickupLocationLabel => 'Pickup location';

  @override
  String get dropoffLocationLabel => 'Dropoff location';

  @override
  String get tapToSearchAddress => 'Tap to search an address';

  @override
  String get specialRequirements => 'Special requirements (optional)';

  @override
  String get priceLabel => 'Price you\'ll pay';

  @override
  String get priceHint => '500000';

  @override
  String get enterValidPrice => 'Enter a valid price';

  @override
  String get estimatingPrice => 'Calculating suggested price...';

  @override
  String priceEstimateSummary(String distance, String price, String currency) {
    return '$distance km • suggested: $price $currency';
  }

  @override
  String get currencyUzs => 'UZS';

  @override
  String get postShipmentButton => 'Post shipment';

  @override
  String get choosePickupDropoff => 'Choose a pickup and dropoff location';

  @override
  String get searchAddressHint => 'Search for an address';

  @override
  String get pickupAddressTitle => 'Pickup address';

  @override
  String get dropoffAddressTitle => 'Dropoff address';

  @override
  String surchargeAmount(String amount, String currency) {
    return '+$amount $currency';
  }

  @override
  String get cargoGeneral => 'General cargo';

  @override
  String get cargoFurniture => 'Furniture';

  @override
  String get cargoConstruction => 'Construction materials';

  @override
  String get cargoPerishable => 'Food / perishable';

  @override
  String get cargoEquipment => 'Equipment / machinery';

  @override
  String get amenityRefrigerated => 'Refrigerated';

  @override
  String get amenitySideRearTent => 'Side/rear opening tent';

  @override
  String get amenityLift => 'Lift';

  @override
  String get amenityTieDownStraps => 'Tie-down straps included';

  @override
  String get nearbyLoadsTitle => 'Nearby loads';

  @override
  String get loadAccepted => 'Load accepted!';

  @override
  String get alreadyTaken => 'Already taken by another driver.';

  @override
  String get noOpenLoads => 'No open loads nearby right now.';

  @override
  String kmAway(String km) {
    return '$km km away';
  }

  @override
  String get acceptButton => 'Accept';

  @override
  String get myShipmentsTitle => 'My shipments';

  @override
  String get postNewLoad => 'Post new load';

  @override
  String get noShipmentsYet => 'No shipments posted yet.';

  @override
  String get shipmentCancelled => 'Shipment cancelled.';

  @override
  String get thanksForRating => 'Thanks for rating!';

  @override
  String get rateDriverTitle => 'Rate the driver';

  @override
  String get cancelShipment => 'Cancel shipment';

  @override
  String ratedDriverStars(int stars) {
    return 'You rated the driver $stars★';
  }

  @override
  String get rateDriverButton => 'Rate driver';

  @override
  String get driverFallback => 'Driver';

  @override
  String get shipmentDetailsTitle => 'Shipment details';

  @override
  String get editShipmentTitle => 'Edit shipment';

  @override
  String get editButton => 'Edit';

  @override
  String get saveChangesButton => 'Save changes';

  @override
  String get shipmentUpdated => 'Shipment updated.';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get noDescriptionProvided => 'No description provided.';

  @override
  String get priceOnlyLabel => 'Price';

  @override
  String postedOnLabel(String date) {
    return 'Posted on $date';
  }

  @override
  String get trackShipmentButton => 'Track shipment';

  @override
  String get editLockedNotice =>
      'This shipment can no longer be edited — a driver has already accepted it.';

  @override
  String get myDeliveriesTitle => 'My deliveries';

  @override
  String get noDeliveriesYet => 'No accepted deliveries yet.';

  @override
  String get locationPermissionRequired =>
      'Location permission is required to share.';

  @override
  String get markedPickedUp => 'Marked as picked up.';

  @override
  String get markedDelivered => 'Marked as delivered!';

  @override
  String get deliveryReleased => 'Delivery released back to the pool.';

  @override
  String get rateShipperTitle => 'Rate the shipper';

  @override
  String get sharingLiveLocation => 'Sharing live location';

  @override
  String get shareMyLocation => 'Share my location';

  @override
  String get sharingStopsIfLeave => 'Sharing stops if you leave this screen.';

  @override
  String get pickedUpCargo => 'Picked up cargo';

  @override
  String get markAsDelivered => 'Mark as delivered';

  @override
  String get releaseThisDelivery => 'Release this delivery';

  @override
  String ratedShipperStars(int stars) {
    return 'You rated the shipper $stars★';
  }

  @override
  String get rateShipperButton => 'Rate shipper';

  @override
  String get shipperFallback => 'Shipper';

  @override
  String get waitingForDriverLocation => 'Waiting for driver\'s location...';

  @override
  String driverLastSeen(int seconds) {
    return 'Driver last seen ${seconds}s ago';
  }

  @override
  String get driverLabel => 'Driver';

  @override
  String get statusOpen => 'Open';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusInTransit => 'In transit';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get commentOptional => 'Comment (optional)';

  @override
  String get telegramTitle => 'Telegram';

  @override
  String get telegramIntro =>
      'Connect our Telegram bot to get instant notifications when your shipments change status, and to manage loads right from Telegram.';

  @override
  String get telegramLinked => '✅ Telegram is connected';

  @override
  String get telegramNotLinked => 'Telegram is not connected yet';

  @override
  String get telegramConnectButton => 'Connect Telegram';

  @override
  String get telegramUnlinkButton => 'Disconnect';

  @override
  String get telegramOpenBotButton => 'Open the bot';

  @override
  String get telegramCodeInstructions =>
      'Or send this code to the bot manually:';

  @override
  String telegramCodeExpiry(int minutes) {
    return 'This code expires in $minutes minutes.';
  }

  @override
  String get telegramUnlinkedMessage => 'Telegram disconnected.';

  @override
  String get telegramCouldNotOpenBot =>
      'Could not open the bot. Send the code manually instead.';

  @override
  String get telegramBotNotConfigured =>
      'The Telegram bot isn\'t set up yet — ask the team to add a bot token.';

  @override
  String get updateAvailableTitle => 'A new version is available';

  @override
  String updateAvailableBody(String version) {
    return 'Aligo $version is out. Download it to get the latest fixes.';
  }

  @override
  String get updateDownloadButton => 'Download';

  @override
  String get getAndroidApp => 'Get the Android app';
}
