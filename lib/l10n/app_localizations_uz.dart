// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'Aligo';

  @override
  String get couldNotReachServer =>
      'Aligo serveriga ulanib bo\'lmadi. Internet aloqasini tekshiring.';

  @override
  String get somethingWentWrong => 'Xatolik yuz berdi.';

  @override
  String get cancel => 'Bekor qilish';

  @override
  String get submit => 'Yuborish';

  @override
  String get languagePickerTitle => 'Tilni tanlang';

  @override
  String get languagePickerSubtitle =>
      'Buni keyinroq menyudan o\'zgartirishingiz mumkin.';

  @override
  String get continueButton => 'Davom etish';

  @override
  String get languageUzbek => 'O\'zbekcha';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String get loginWelcomeTitle => 'Aligo\'ga xush kelibsiz';

  @override
  String get loginWelcomeSubtitle =>
      'Kirish uchun sizga bir martalik kod yuboramiz\nva yukingizni real vaqtda kuzatasiz.';

  @override
  String get emailAddressLabel => 'Email manzil';

  @override
  String get emailAddressHint => 'siz@misol.com';

  @override
  String get continueWithEmail => 'Email orqali davom etish';

  @override
  String get orContinueWith => 'yoki davom eting';

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get noAccountPrompt => 'Hisobingiz yo\'qmi? ';

  @override
  String get createOne => 'Ro\'yxatdan o\'tish';

  @override
  String get invalidEmail => 'To\'g\'ri email manzilini kiriting';

  @override
  String googleSignInFailed(String error) {
    return 'Google orqali kirish muvaffaqiyatsiz: $error';
  }

  @override
  String get createAccountTitle => 'Hisob yaratish';

  @override
  String get joinAligo => 'Aligo\'ga qo\'shiling';

  @override
  String get signupSubtitle =>
      'Sizni tasdiqlash uchun email orqali tasdiqlash kodini yuboramiz.';

  @override
  String get fullNameLabel => 'To\'liq ism';

  @override
  String get fullNameHint => 'Jasur Karimov';

  @override
  String get enterFullName => 'To\'liq ismingizni kiriting';

  @override
  String get sendVerificationCode => 'Tasdiqlash kodini yuborish';

  @override
  String get verifyEmailTitle => 'Emailingizni tasdiqlang';

  @override
  String get enterCodeTitle => 'Yuborilgan kodni kiriting';

  @override
  String otpSentTo(String email) {
    return '$email manziliga 6 xonali tasdiqlash kodi yuborildi.';
  }

  @override
  String get enterSixDigitCode => 'Emailingizga kelgan 6 xonali kodni kiriting';

  @override
  String get verifyAndContinue => 'Tasdiqlash va davom etish';

  @override
  String get sending => 'Yuborilmoqda...';

  @override
  String get resendPrompt => 'Kod kelmadimi? Qayta yuborish';

  @override
  String get newCodeSent => 'Yangi kod yuborildi.';

  @override
  String get roleSelectTitle => 'Aligo\'dan qanday foydalanasiz?';

  @override
  String get roleSelectSubtitle =>
      'O\'zingizga mos variantni tanlang — keyingi qadamda tafsilotlarni to\'ldirasiz.';

  @override
  String get driverRoleTitle => 'Men yuk tashiyman';

  @override
  String get driverRoleSubtitle =>
      'Transport vositangizni ro\'yxatdan o\'tkazing va mos yuk so\'rovlarini oling.';

  @override
  String get shipperRoleTitle => 'Men yuk jo\'nataman';

  @override
  String get shipperRoleSubtitle =>
      'Yuk e\'lonini joylashtiring va yaqin atrofdan haydovchi toping.';

  @override
  String get driverProfileTitle => 'Haydovchi profili';

  @override
  String get shipperProfileTitle => 'Jo\'natuvchi profili';

  @override
  String get tellUsAboutYourself => 'O\'zingiz haqingizda ma\'lumot bering';

  @override
  String get phoneNumberLabel => 'Telefon raqami';

  @override
  String get enterPhoneNumber => 'Telefon raqamingizni kiriting';

  @override
  String get homeAddressLabel => 'Uy manzili';

  @override
  String get enterAddress => 'Manzilingizni kiriting';

  @override
  String get ageLabel => 'Yosh';

  @override
  String get enterValidAge => 'To\'g\'ri yoshni kiriting';

  @override
  String get vehicleInfo => 'Transport ma\'lumotlari';

  @override
  String get brandModelLabel => 'Marka va model';

  @override
  String get enterBrandModel => 'Transport marka/modelini kiriting';

  @override
  String get colorLabel => 'Rangi';

  @override
  String get colorHintExample => 'Oq';

  @override
  String get enterColor => 'Transport rangini kiriting';

  @override
  String get plateNumberLabel => 'Davlat raqami';

  @override
  String get enterPlateNumber => 'Davlat raqamini kiriting';

  @override
  String get sizeCapacityLabel => 'O\'lcham / sig\'im';

  @override
  String get sizeCapacityHintExample => '3 tonnagacha';

  @override
  String get enterVehicleSize => 'Transport o\'lchamini kiriting';

  @override
  String get additionalAmenities => 'Qo\'shimcha imkoniyatlar';

  @override
  String get saveAndContinue => 'Saqlash va davom etish';

  @override
  String get whereToSendCargo => 'Yukingizni qayerga yubormoqchisiz?';

  @override
  String get findNearbyLoads => 'Yaqin atrofdagi yuklarni toping';

  @override
  String get premiumLogisticsAccount => 'Premium logistika hisobi';

  @override
  String get aligoCargo => 'Aligo Cargo';

  @override
  String get myShipments => 'Mening jo\'natmalarim';

  @override
  String get myDeliveries => 'Mening yetkazib berishlarim';

  @override
  String get paymentsInvoices => 'To\'lovlar va hisob-fakturalar';

  @override
  String get support => 'Yordam';

  @override
  String get settings => 'Sozlamalar';

  @override
  String get language => 'Til';

  @override
  String get appearanceSectionTitle => 'Ko\'rinish';

  @override
  String get themeSystemLabel => 'Tizim standarti';

  @override
  String get themeLightLabel => 'Yorug\'';

  @override
  String get themeDarkLabel => 'Qorong\'u';

  @override
  String get postShipmentTitle => 'Yuk joylash';

  @override
  String get whatAreYouSending => 'Nima yubormoqchisiz?';

  @override
  String get cargoTypeLabel => 'Yuk turi';

  @override
  String get chooseCargoType => 'Yuk turini tanlang';

  @override
  String get descriptionOptional => 'Tavsif (ixtiyoriy)';

  @override
  String get descriptionHint => 'Haydovchi uchun qo\'shimcha ma\'lumot';

  @override
  String get pickupLocationLabel => 'Olib ketish manzili';

  @override
  String get dropoffLocationLabel => 'Yetkazish manzili';

  @override
  String get tapToSearchAddress => 'Manzil qidirish uchun bosing';

  @override
  String get specialRequirements => 'Maxsus talablar (ixtiyoriy)';

  @override
  String get priceLabel => 'To\'laydigan narxingiz';

  @override
  String get priceHint => '500000';

  @override
  String get enterValidPrice => 'To\'g\'ri narxni kiriting';

  @override
  String get estimatingPrice => 'Taklif qilingan narx hisoblanmoqda...';

  @override
  String priceEstimateSummary(String distance, String price, String currency) {
    return '$distance km • taklif: $price $currency';
  }

  @override
  String get currencyUzs => 'so\'m';

  @override
  String get postShipmentButton => 'Yukni joylash';

  @override
  String get choosePickupDropoff =>
      'Olib ketish va yetkazish manzilini tanlang';

  @override
  String get searchAddressHint => 'Manzilni qidiring';

  @override
  String get pickupAddressTitle => 'Olib ketish manzili';

  @override
  String get dropoffAddressTitle => 'Yetkazish manzili';

  @override
  String surchargeAmount(String amount, String currency) {
    return '+$amount $currency';
  }

  @override
  String get cargoGeneral => 'Umumiy yuk';

  @override
  String get cargoFurniture => 'Mebel';

  @override
  String get cargoConstruction => 'Qurilish materiallari';

  @override
  String get cargoPerishable => 'Oziq-ovqat / tez buziluvchi';

  @override
  String get cargoEquipment => 'Texnika / uskuna';

  @override
  String get amenityRefrigerated => 'Muzlatkichli';

  @override
  String get amenitySideRearTent => 'Yon/orqa ochiluvchi tent';

  @override
  String get amenityLift => 'Gidrobort (lift)';

  @override
  String get amenityTieDownStraps => 'Bog\'lash tasmalari mavjud';

  @override
  String get nearbyLoadsTitle => 'Yaqin atrofdagi yuklar';

  @override
  String get loadAccepted => 'Yuk qabul qilindi!';

  @override
  String get alreadyTaken =>
      'Boshqa haydovchi tomonidan allaqachon qabul qilingan.';

  @override
  String get noOpenLoads => 'Hozircha yaqin atrofda ochiq yuklar yo\'q.';

  @override
  String kmAway(String km) {
    return '$km km uzoqlikda';
  }

  @override
  String get acceptButton => 'Qabul qilish';

  @override
  String get myShipmentsTitle => 'Mening jo\'natmalarim';

  @override
  String get postNewLoad => 'Yangi yuk joylash';

  @override
  String get noShipmentsYet => 'Hali yuk joylanmagan.';

  @override
  String get shipmentCancelled => 'Jo\'natma bekor qilindi.';

  @override
  String get thanksForRating => 'Baho uchun rahmat!';

  @override
  String get rateDriverTitle => 'Haydovchini baholang';

  @override
  String get cancelShipment => 'Jo\'natmani bekor qilish';

  @override
  String ratedDriverStars(int stars) {
    return 'Siz haydovchini $stars★ baholadingiz';
  }

  @override
  String get rateDriverButton => 'Haydovchini baholash';

  @override
  String get driverFallback => 'Haydovchi';

  @override
  String get shipmentDetailsTitle => 'Jo\'natma tafsilotlari';

  @override
  String get editShipmentTitle => 'Jo\'natmani tahrirlash';

  @override
  String get editButton => 'Tahrirlash';

  @override
  String get saveChangesButton => 'O\'zgarishlarni saqlash';

  @override
  String get shipmentUpdated => 'Jo\'natma yangilandi.';

  @override
  String get descriptionLabel => 'Tavsif';

  @override
  String get noDescriptionProvided => 'Tavsif kiritilmagan.';

  @override
  String get priceOnlyLabel => 'Narx';

  @override
  String postedOnLabel(String date) {
    return '$date sanasida joylangan';
  }

  @override
  String get trackShipmentButton => 'Jo\'natmani kuzatish';

  @override
  String get editLockedNotice =>
      'Bu jo\'natmani endi tahrirlab bo\'lmaydi — haydovchi allaqachon qabul qilgan.';

  @override
  String get myDeliveriesTitle => 'Mening yetkazib berishlarim';

  @override
  String get noDeliveriesYet => 'Hali qabul qilingan yetkazib berish yo\'q.';

  @override
  String get locationPermissionRequired =>
      'Ulashish uchun joylashuv ruxsati kerak.';

  @override
  String get markedPickedUp => 'Olib ketildi deb belgilandi.';

  @override
  String get markedDelivered => 'Yetkazildi deb belgilandi!';

  @override
  String get deliveryReleased =>
      'Yetkazib berish yana ochiq ro\'yxatga qaytdi.';

  @override
  String get rateShipperTitle => 'Jo\'natuvchini baholang';

  @override
  String get sharingLiveLocation => 'Jonli joylashuv ulashilmoqda';

  @override
  String get shareMyLocation => 'Joylashuvimni ulashish';

  @override
  String get sharingStopsIfLeave => 'Ekrandan chiqsangiz, ulashish to\'xtaydi.';

  @override
  String get pickedUpCargo => 'Yuk olib ketildi';

  @override
  String get markAsDelivered => 'Yetkazildi deb belgilash';

  @override
  String get releaseThisDelivery => 'Bu yetkazib berishdan voz kechish';

  @override
  String ratedShipperStars(int stars) {
    return 'Siz jo\'natuvchini $stars★ baholadingiz';
  }

  @override
  String get rateShipperButton => 'Jo\'natuvchini baholash';

  @override
  String get shipperFallback => 'Jo\'natuvchi';

  @override
  String get waitingForDriverLocation => 'Haydovchi joylashuvi kutilmoqda...';

  @override
  String driverLastSeen(int seconds) {
    return 'Haydovchi ${seconds}s oldin ko\'rindi';
  }

  @override
  String get driverLabel => 'Haydovchi';

  @override
  String get statusOpen => 'Ochiq';

  @override
  String get statusAccepted => 'Qabul qilindi';

  @override
  String get statusInTransit => 'Yo\'lda';

  @override
  String get statusCompleted => 'Yetkazildi';

  @override
  String get statusCancelled => 'Bekor qilindi';

  @override
  String get commentOptional => 'Izoh (ixtiyoriy)';

  @override
  String get telegramTitle => 'Telegram';

  @override
  String get telegramIntro =>
      'Telegram botimizga ulaning — yuklaringiz holati o\'zgarganda darhol xabar oling va yuklarni to\'g\'ridan-to\'g\'ri Telegram orqali boshqaring.';

  @override
  String get telegramLinked => '✅ Telegram ulangan';

  @override
  String get telegramNotLinked => 'Telegram hali ulanmagan';

  @override
  String get telegramConnectButton => 'Telegramga ulanish';

  @override
  String get telegramUnlinkButton => 'Uzish';

  @override
  String get telegramOpenBotButton => 'Botni ochish';

  @override
  String get telegramCodeInstructions =>
      'Yoki botga qo\'lda shu kodni yuboring:';

  @override
  String telegramCodeExpiry(int minutes) {
    return 'Bu kod $minutes daqiqa amal qiladi.';
  }

  @override
  String get telegramUnlinkedMessage => 'Telegram uzildi.';

  @override
  String get telegramCouldNotOpenBot =>
      'Botni ochib bo\'lmadi. Kodni qo\'lda yuboring.';

  @override
  String get telegramBotNotConfigured =>
      'Telegram bot hali sozlanmagan — jamoadan bot tokeni qo\'shishni so\'rang.';

  @override
  String get updateAvailableTitle => 'Yangi versiya mavjud';

  @override
  String updateAvailableBody(String version) {
    return 'Aligo $version chiqdi. Eng so\'nggi tuzatishlar uchun yuklab oling.';
  }

  @override
  String get updateDownloadButton => 'Yuklab olish';

  @override
  String get getAndroidApp => 'Android ilovasini yuklab olish';

  @override
  String get logout => 'Chiqish';

  @override
  String get logoutConfirmText => 'Hisobdan chiqishni xohlaysizmi?';
}
