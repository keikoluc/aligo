// Lightweight response-message i18n: routes translate error strings at
// the point they're sent, keyed by the exact English text (rather than
// threading a `locale` argument through every service function). New
// messages just need an entry here — no route/service signature changes.
const TRANSLATIONS = {
  'Only drivers can perform this action.': {
    uz: 'Bu amalni faqat haydovchilar bajara oladi.',
    ru: 'Это действие могут выполнять только водители.',
  },
  'Only shippers can perform this action.': {
    uz: 'Bu amalni faqat jo\'natuvchilar bajara oladi.',
    ru: 'Это действие могут выполнять только отправители.',
  },
  'Role must be "driver" or "shipper".': {
    uz: 'Rol "driver" yoki "shipper" bo\'lishi kerak.',
    ru: 'Роль должна быть "driver" или "shipper".',
  },
  'Full name is required.': {
    uz: "To'liq ism kerak.",
    ru: 'Требуется полное имя.',
  },
  'Phone number is required.': {
    uz: 'Telefon raqami kerak.',
    ru: 'Требуется номер телефона.',
  },
  'Address is required.': {
    uz: 'Manzil kerak.',
    ru: 'Требуется адрес.',
  },
  'A valid age is required.': {
    uz: "To'g'ri yosh kerak.",
    ru: 'Требуется корректный возраст.',
  },
  'Vehicle information is required for drivers.': {
    uz: 'Haydovchilar uchun transport ma\'lumotlari kerak.',
    ru: 'Для водителей требуется информация о транспорте.',
  },
  'Vehicle brandModel is required.': {
    uz: 'Transport marka/modeli kerak.',
    ru: 'Требуется марка/модель транспорта.',
  },
  'Vehicle color is required.': {
    uz: 'Transport rangi kerak.',
    ru: 'Требуется цвет транспорта.',
  },
  'Vehicle plateNumber is required.': {
    uz: 'Davlat raqami kerak.',
    ru: 'Требуется госномер.',
  },
  'Vehicle sizeLabel is required.': {
    uz: "Transport o'lchami kerak.",
    ru: 'Требуется размер транспорта.',
  },
  'Admin login is not configured.': {
    uz: 'Admin login sozlanmagan.',
    ru: 'Вход администратора не настроен.',
  },
  'Incorrect password.': {
    uz: "Parol noto'g'ri.",
    ru: 'Неверный пароль.',
  },
  'Invalid listing id.': {
    uz: "Noto'g'ri e'lon ID.",
    ru: 'Неверный ID объявления.',
  },
  'Listing not found or already completed.': {
    uz: "E'lon topilmadi yoki allaqachon yakunlangan.",
    ru: 'Объявление не найдено или уже завершено.',
  },
  'cargoType, pickup and dropoff coordinates are required.': {
    uz: "Yuk turi, olib ketish va yetkazish manzillari kerak.",
    ru: 'Требуются тип груза, координаты погрузки и доставки.',
  },
  'Could not estimate a price right now.': {
    uz: 'Hozircha narxni hisoblab bo\'lmadi.',
    ru: 'Не удалось рассчитать цену сейчас.',
  },
  'Listing not found.': {
    uz: "E'lon topilmadi.",
    ru: 'Объявление не найдено.',
  },
  'Your vehicle does not have a capability this load requires.': {
    uz: 'Sizning transportingizda bu yuk talab qiladigan xususiyat yo\'q.',
    ru: 'У вашего транспорта нет функции, требуемой этим грузом.',
  },
  'This load was already accepted by another driver.': {
    uz: 'Bu yukni boshqa haydovchi allaqachon qabul qilgan.',
    ru: 'Этот груз уже принят другим водителем.',
  },
  'This delivery is not currently assigned to you, or was already picked up.': {
    uz: "Bu yetkazib berish sizga tayinlanmagan yoki allaqachon olib ketilgan.",
    ru: 'Эта доставка не назначена вам или уже забрана.',
  },
  'This delivery is not currently assigned to you, or the cargo has not been picked up yet.': {
    uz: 'Bu yetkazib berish sizga tayinlanmagan yoki yuk hali olib ketilmagan.',
    ru: 'Эта доставка не назначена вам, или груз ещё не забран.',
  },
  'This listing can no longer be cancelled — a driver may have already accepted it.': {
    uz: "Bu e'lonni endi bekor qilib bo'lmaydi — haydovchi allaqachon qabul qilgan bo'lishi mumkin.",
    ru: 'Это объявление больше нельзя отменить — возможно, его уже принял водитель.',
  },
  'This listing can no longer be edited — a driver may have already accepted it.': {
    uz: "Bu e'lonni endi tahrirlab bo'lmaydi — haydovchi allaqachon qabul qilgan bo'lishi mumkin.",
    ru: 'Это объявление больше нельзя редактировать — возможно, его уже принял водитель.',
  },
  'This delivery is not currently assigned to you.': {
    uz: 'Bu yetkazib berish sizga tayinlanmagan.',
    ru: 'Эта доставка не назначена вам.',
  },
  'You can only rate a completed delivery.': {
    uz: 'Faqat yakunlangan yetkazib berishni baholash mumkin.',
    ru: 'Оценить можно только завершённую доставку.',
  },
  'You are not part of this listing.': {
    uz: "Siz bu e'lon ishtirokchisi emassiz.",
    ru: 'Вы не участвуете в этом объявлении.',
  },
  'lat and lng must be numbers.': {
    uz: "lat va lng son bo'lishi kerak.",
    ru: 'lat и lng должны быть числами.',
  },
  'This delivery is not currently assigned to you, or is not active.': {
    uz: 'Bu yetkazib berish sizga tayinlanmagan yoki faol emas.',
    ru: 'Эта доставка не назначена вам или неактивна.',
  },
  'You do not have access to this listing.': {
    uz: "Sizda bu e'longa kirish huquqi yo'q.",
    ru: 'У вас нет доступа к этому объявлению.',
  },
  'Complete your profile address to see nearby loads.': {
    uz: "Yaqin atrofdagi yuklarni ko'rish uchun profilingizdagi manzilni to'ldiring.",
    ru: 'Заполните адрес в профиле, чтобы видеть грузы поблизости.',
  },
  'Stars must be an integer between 1 and 5.': {
    uz: "Yulduzlar soni 1 dan 5 gacha butun son bo'lishi kerak.",
    ru: 'Количество звёзд должно быть целым числом от 1 до 5.',
  },
  'Cargo type is required.': {
    uz: 'Yuk turi kerak.',
    ru: 'Требуется тип груза.',
  },
  'A valid pickup location is required.': {
    uz: "To'g'ri olib ketish manzili kerak.",
    ru: 'Требуется корректный адрес погрузки.',
  },
  'A valid dropoff location is required.': {
    uz: "To'g'ri yetkazish manzili kerak.",
    ru: 'Требуется корректный адрес доставки.',
  },
  'Price must be a positive number.': {
    uz: "Narx musbat son bo'lishi kerak.",
    ru: 'Цена должна быть положительным числом.',
  },
  'A valid FCM token is required.': {
    uz: "To'g'ri FCM token kerak.",
    ru: 'Требуется корректный FCM-токен.',
  },
  'Too many code requests. Please try again later.': {
    uz: "Juda ko'p so'rov yuborildi. Keyinroq qayta urinib ko'ring.",
    ru: 'Слишком много запросов кода. Попробуйте позже.',
  },
  'Too many attempts. Please try again later.': {
    uz: "Juda ko'p urinish. Keyinroq qayta urinib ko'ring.",
    ru: 'Слишком много попыток. Попробуйте позже.',
  },
  'A valid email address is required.': {
    uz: "To'g'ri email manzil kerak.",
    ru: 'Требуется корректный email.',
  },
  'Could not send verification email.': {
    uz: "Tasdiqlash xatini yuborib bo'lmadi.",
    ru: 'Не удалось отправить письмо с подтверждением.',
  },
  'A valid 6-digit code is required.': {
    uz: "To'g'ri 6 xonali kod kerak.",
    ru: 'Требуется корректный 6-значный код.',
  },
  'No active code for this email. Request a new one.': {
    uz: 'Bu email uchun faol kod yo\'q. Yangisini so\'rang.',
    ru: 'Нет активного кода для этой почты. Запросите новый.',
  },
  'This code has expired. Request a new one.': {
    uz: "Bu kodning muddati tugagan. Yangisini so'rang.",
    ru: 'Срок действия кода истёк. Запросите новый.',
  },
  'Incorrect code.': {
    uz: "Kod noto'g'ri.",
    ru: 'Неверный код.',
  },
  'Too many incorrect attempts. Request a new code.': {
    uz: "Juda ko'p noto'g'ri urinish. Yangi kod so'rang.",
    ru: 'Слишком много неверных попыток. Запросите новый код.',
  },
  'Verification failed.': {
    uz: "Tasdiqlash amalga oshmadi.",
    ru: 'Проверка не удалась.',
  },
  'idToken is required.': {
    uz: 'idToken kerak.',
    ru: 'Требуется idToken.',
  },
  'Invalid Google credential.': {
    uz: "Google hisob ma'lumotlari noto'g'ri.",
    ru: 'Недействительные данные Google.',
  },
  'Google email is not verified.': {
    uz: "Google e-pochtangiz tasdiqlanmagan.",
    ru: 'Ваш email в Google не подтверждён.',
  },
  'Invalid Telegram session.': {
    uz: "Telegram sessiyasi noto'g'ri.",
    ru: 'Недействительная сессия Telegram.',
  },
  'This code is invalid or has expired.': {
    uz: "Bu kod noto'g'ri yoki muddati tugagan.",
    ru: 'Этот код недействителен или истёк.',
  },
  'Unsupported language.': {
    uz: "Qo'llab-quvvatlanmaydigan til.",
    ru: 'Неподдерживаемый язык.',
  },
};

const SUPPORTED_LOCALES = ['uz', 'ru', 'en'];

function localeFromRequest(req) {
  const header = req.headers['x-app-locale'];
  return SUPPORTED_LOCALES.includes(header) ? header : 'en';
}

function t(message, locale) {
  if (!locale || locale === 'en') return message;
  return TRANSLATIONS[message]?.[locale] || message;
}

module.exports = { t, localeFromRequest };
