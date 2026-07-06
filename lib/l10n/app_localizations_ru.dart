// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Aligo';

  @override
  String get couldNotReachServer =>
      'Не удалось подключиться к серверу Aligo. Проверьте соединение.';

  @override
  String get somethingWentWrong => 'Что-то пошло не так.';

  @override
  String get cancel => 'Отмена';

  @override
  String get submit => 'Отправить';

  @override
  String get languagePickerTitle => 'Выберите язык';

  @override
  String get languagePickerSubtitle => 'Вы можете изменить это позже в меню.';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get languageUzbek => 'O\'zbekcha';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String get loginWelcomeTitle => 'С возвращением в Aligo';

  @override
  String get loginWelcomeSubtitle =>
      'Мы отправим вам одноразовый код для входа\nи отслеживания груза в реальном времени.';

  @override
  String get emailAddressLabel => 'Электронная почта';

  @override
  String get emailAddressHint => 'you@example.com';

  @override
  String get continueWithEmail => 'Продолжить с почтой';

  @override
  String get orContinueWith => 'или продолжить с';

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get noAccountPrompt => 'Нет аккаунта? ';

  @override
  String get createOne => 'Создать';

  @override
  String get invalidEmail => 'Введите корректный email';

  @override
  String googleSignInFailed(String error) {
    return 'Не удалось войти через Google: $error';
  }

  @override
  String get createAccountTitle => 'Создать аккаунт';

  @override
  String get joinAligo => 'Присоединяйтесь к Aligo';

  @override
  String get signupSubtitle => 'Мы отправим вам код подтверждения на почту.';

  @override
  String get fullNameLabel => 'Полное имя';

  @override
  String get fullNameHint => 'Jasur Karimov';

  @override
  String get enterFullName => 'Введите ваше полное имя';

  @override
  String get sendVerificationCode => 'Отправить код подтверждения';

  @override
  String get verifyEmailTitle => 'Подтвердите email';

  @override
  String get enterCodeTitle => 'Введите полученный код';

  @override
  String otpSentTo(String email) {
    return 'Мы отправили 6-значный код подтверждения на $email.';
  }

  @override
  String get enterSixDigitCode => 'Введите 6-значный код из письма';

  @override
  String get verifyAndContinue => 'Подтвердить и продолжить';

  @override
  String get sending => 'Отправка...';

  @override
  String get resendPrompt => 'Не пришёл код? Отправить снова';

  @override
  String get newCodeSent => 'Новый код отправлен.';

  @override
  String get roleSelectTitle => 'Как вы будете использовать Aligo?';

  @override
  String get roleSelectSubtitle =>
      'Выберите подходящий вариант — далее укажете детали.';

  @override
  String get driverRoleTitle => 'Я перевожу грузы';

  @override
  String get driverRoleSubtitle =>
      'Зарегистрируйте свой транспорт и получайте подходящие заявки.';

  @override
  String get shipperRoleTitle => 'Я отправляю грузы';

  @override
  String get shipperRoleSubtitle =>
      'Разместите заявку и найдите водителя поблизости.';

  @override
  String get driverProfileTitle => 'Профиль водителя';

  @override
  String get shipperProfileTitle => 'Профиль отправителя';

  @override
  String get tellUsAboutYourself => 'Расскажите о себе';

  @override
  String get phoneNumberLabel => 'Номер телефона';

  @override
  String get enterPhoneNumber => 'Введите номер телефона';

  @override
  String get homeAddressLabel => 'Домашний адрес';

  @override
  String get enterAddress => 'Введите ваш адрес';

  @override
  String get ageLabel => 'Возраст';

  @override
  String get enterValidAge => 'Введите корректный возраст';

  @override
  String get vehicleInfo => 'Информация о транспорте';

  @override
  String get brandModelLabel => 'Марка и модель';

  @override
  String get enterBrandModel => 'Введите марку/модель транспорта';

  @override
  String get colorLabel => 'Цвет';

  @override
  String get colorHintExample => 'Белый';

  @override
  String get enterColor => 'Введите цвет транспорта';

  @override
  String get plateNumberLabel => 'Госномер';

  @override
  String get enterPlateNumber => 'Введите госномер';

  @override
  String get sizeCapacityLabel => 'Размер / грузоподъёмность';

  @override
  String get sizeCapacityHintExample => 'До 3 тонн';

  @override
  String get enterVehicleSize => 'Введите размер транспорта';

  @override
  String get additionalAmenities => 'Дополнительные возможности';

  @override
  String get saveAndContinue => 'Сохранить и продолжить';

  @override
  String get whereToSendCargo => 'Куда отправить груз?';

  @override
  String get findNearbyLoads => 'Найти грузы поблизости';

  @override
  String get premiumLogisticsAccount => 'Премиум логистический аккаунт';

  @override
  String get aligoCargo => 'Aligo Cargo';

  @override
  String get myShipments => 'Мои отправления';

  @override
  String get myDeliveries => 'Мои доставки';

  @override
  String get paymentsInvoices => 'Платежи и счета';

  @override
  String get support => 'Поддержка';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get postShipmentTitle => 'Разместить груз';

  @override
  String get whatAreYouSending => 'Что вы отправляете?';

  @override
  String get cargoTypeLabel => 'Тип груза';

  @override
  String get chooseCargoType => 'Выберите тип груза';

  @override
  String get descriptionOptional => 'Описание (необязательно)';

  @override
  String get descriptionHint => 'Дополнительные детали для водителя';

  @override
  String get pickupLocationLabel => 'Место погрузки';

  @override
  String get dropoffLocationLabel => 'Место доставки';

  @override
  String get tapToSearchAddress => 'Нажмите, чтобы найти адрес';

  @override
  String get specialRequirements => 'Особые требования (необязательно)';

  @override
  String get priceLabel => 'Цена, которую вы заплатите';

  @override
  String get priceHint => '500000';

  @override
  String get enterValidPrice => 'Введите корректную цену';

  @override
  String get estimatingPrice => 'Рассчитываем предлагаемую цену...';

  @override
  String priceEstimateSummary(String distance, String price, String currency) {
    return '$distance км • предложение: $price $currency';
  }

  @override
  String get currencyUzs => 'сум';

  @override
  String get postShipmentButton => 'Разместить груз';

  @override
  String get choosePickupDropoff => 'Выберите место погрузки и доставки';

  @override
  String get searchAddressHint => 'Поиск адреса';

  @override
  String get pickupAddressTitle => 'Адрес погрузки';

  @override
  String get dropoffAddressTitle => 'Адрес доставки';

  @override
  String surchargeAmount(String amount, String currency) {
    return '+$amount $currency';
  }

  @override
  String get cargoGeneral => 'Обычный груз';

  @override
  String get cargoFurniture => 'Мебель';

  @override
  String get cargoConstruction => 'Строительные материалы';

  @override
  String get cargoPerishable => 'Еда / скоропортящееся';

  @override
  String get cargoEquipment => 'Техника / оборудование';

  @override
  String get amenityRefrigerated => 'С холодильником';

  @override
  String get amenitySideRearTent => 'Боковой/задний тент';

  @override
  String get amenityLift => 'Гидроборт';

  @override
  String get amenityTieDownStraps => 'Есть стяжные ремни';

  @override
  String get nearbyLoadsTitle => 'Грузы поблизости';

  @override
  String get loadAccepted => 'Груз принят!';

  @override
  String get alreadyTaken => 'Уже принят другим водителем.';

  @override
  String get noOpenLoads => 'Поблизости пока нет доступных грузов.';

  @override
  String kmAway(String km) {
    return '$km км';
  }

  @override
  String get acceptButton => 'Принять';

  @override
  String get myShipmentsTitle => 'Мои отправления';

  @override
  String get postNewLoad => 'Разместить новый груз';

  @override
  String get noShipmentsYet => 'Пока нет размещённых грузов.';

  @override
  String get shipmentCancelled => 'Отправление отменено.';

  @override
  String get thanksForRating => 'Спасибо за оценку!';

  @override
  String get rateDriverTitle => 'Оценить водителя';

  @override
  String get cancelShipment => 'Отменить отправление';

  @override
  String ratedDriverStars(int stars) {
    return 'Вы оценили водителя на $stars★';
  }

  @override
  String get rateDriverButton => 'Оценить водителя';

  @override
  String get driverFallback => 'Водитель';

  @override
  String get shipmentDetailsTitle => 'Детали отправления';

  @override
  String get editShipmentTitle => 'Редактировать отправление';

  @override
  String get editButton => 'Редактировать';

  @override
  String get saveChangesButton => 'Сохранить изменения';

  @override
  String get shipmentUpdated => 'Отправление обновлено.';

  @override
  String get descriptionLabel => 'Описание';

  @override
  String get noDescriptionProvided => 'Описание не указано.';

  @override
  String get priceOnlyLabel => 'Цена';

  @override
  String postedOnLabel(String date) {
    return 'Размещено $date';
  }

  @override
  String get trackShipmentButton => 'Отследить отправление';

  @override
  String get editLockedNotice =>
      'Это отправление больше нельзя редактировать — его уже принял водитель.';

  @override
  String get myDeliveriesTitle => 'Мои доставки';

  @override
  String get noDeliveriesYet => 'Пока нет принятых доставок.';

  @override
  String get locationPermissionRequired =>
      'Для трансляции нужен доступ к геолокации.';

  @override
  String get markedPickedUp => 'Отмечено как забрано.';

  @override
  String get markedDelivered => 'Отмечено как доставлено!';

  @override
  String get deliveryReleased => 'Доставка возвращена в список доступных.';

  @override
  String get rateShipperTitle => 'Оценить отправителя';

  @override
  String get sharingLiveLocation => 'Трансляция геолокации включена';

  @override
  String get shareMyLocation => 'Транслировать геолокацию';

  @override
  String get sharingStopsIfLeave =>
      'Трансляция остановится, если вы покинете экран.';

  @override
  String get pickedUpCargo => 'Груз забран';

  @override
  String get markAsDelivered => 'Отметить как доставлено';

  @override
  String get releaseThisDelivery => 'Отказаться от доставки';

  @override
  String ratedShipperStars(int stars) {
    return 'Вы оценили отправителя на $stars★';
  }

  @override
  String get rateShipperButton => 'Оценить отправителя';

  @override
  String get shipperFallback => 'Отправитель';

  @override
  String get waitingForDriverLocation => 'Ожидание геолокации водителя...';

  @override
  String driverLastSeen(int seconds) {
    return 'Водитель был на связи $seconds с назад';
  }

  @override
  String get driverLabel => 'Водитель';

  @override
  String get statusOpen => 'Открыт';

  @override
  String get statusAccepted => 'Принят';

  @override
  String get statusInTransit => 'В пути';

  @override
  String get statusCompleted => 'Доставлен';

  @override
  String get statusCancelled => 'Отменён';

  @override
  String get commentOptional => 'Комментарий (необязательно)';

  @override
  String get telegramTitle => 'Telegram';

  @override
  String get telegramIntro =>
      'Подключите нашего Telegram-бота, чтобы мгновенно получать уведомления об изменении статуса груза и управлять грузами прямо в Telegram.';

  @override
  String get telegramLinked => '✅ Telegram подключён';

  @override
  String get telegramNotLinked => 'Telegram ещё не подключён';

  @override
  String get telegramConnectButton => 'Подключить Telegram';

  @override
  String get telegramUnlinkButton => 'Отключить';

  @override
  String get telegramOpenBotButton => 'Открыть бота';

  @override
  String get telegramCodeInstructions => 'Или отправьте боту этот код вручную:';

  @override
  String telegramCodeExpiry(int minutes) {
    return 'Код действителен $minutes минут.';
  }

  @override
  String get telegramUnlinkedMessage => 'Telegram отключён.';

  @override
  String get telegramCouldNotOpenBot =>
      'Не удалось открыть бота. Отправьте код вручную.';

  @override
  String get telegramBotNotConfigured =>
      'Telegram-бот ещё не настроен — попросите команду добавить токен бота.';

  @override
  String get updateAvailableTitle => 'Доступна новая версия';

  @override
  String updateAvailableBody(String version) {
    return 'Вышла версия Aligo $version. Скачайте, чтобы получить последние исправления.';
  }

  @override
  String get updateDownloadButton => 'Скачать';

  @override
  String get getAndroidApp => 'Скачать приложение для Android';
}
