const { Markup } = require('telegraf');
const telegramClient = require('./telegramClient');
const telegramLinkService = require('./telegramLinkService');
const cargoListingService = require('./cargoListingService');

// The bot talks directly to Telegram, outside the Flutter app's i18n
// pipeline (X-App-Locale header), so it picks a locale straight from
// Telegram's own per-chat `language_code` — uz/ru if recognized,
// otherwise uz (the app's own default), never blank.
function localeOf(ctx) {
  const code = ctx.from?.language_code;
  return code === 'ru' ? 'ru' : code === 'en' ? 'en' : 'uz';
}

const STRINGS = {
  welcomeUnlinked: {
    uz: "Aligo botiga xush kelibsiz!\n\nHisobingizni bog'lash uchun ilovada Menyu → Telegram bo'limiga o'ting va kodni shu yerga yuboring: /link KOD",
    ru: 'Добро пожаловать в бот Aligo!\n\nЧтобы привязать аккаунт, откройте в приложении Меню → Telegram и отправьте сюда код: /link КОД',
    en: "Welcome to the Aligo bot!\n\nTo link your account, open Menu → Telegram in the app and send the code here: /link CODE",
  },
  welcomeLinked: {
    uz: (name) => `Qaytganingizdan xursandmiz, ${name}!`,
    ru: (name) => `С возвращением, ${name}!`,
    en: (name) => `Welcome back, ${name}!`,
  },
  linkUsageHint: {
    uz: "Kodni shunday yuboring: /link KOD",
    ru: 'Отправьте код так: /link КОД',
    en: 'Send the code like this: /link CODE',
  },
  linkInvalid: {
    uz: "Kod noto'g'ri yoki muddati tugagan. Ilovadan yangi kod oling.",
    ru: 'Код неверен или срок его действия истёк. Получите новый код в приложении.',
    en: 'That code is invalid or has expired. Get a new one from the app.',
  },
  linkSuccess: {
    uz: (name) => `✅ Hisobingiz bog'landi, ${name}! Endi shu yerdan bildirishnomalar olasiz.`,
    ru: (name) => `✅ Аккаунт привязан, ${name}! Теперь вы будете получать уведомления здесь.`,
    en: (name) => `✅ Account linked, ${name}! You'll now get notifications here.`,
  },
  unlinkSuccess: {
    uz: "Hisobingiz Telegram'dan uzildi.",
    ru: 'Ваш аккаунт отвязан от Telegram.',
    en: 'Your account has been unlinked from Telegram.',
  },
  notLinked: {
    uz: "Hisobingiz hali bog'lanmagan. Ilovada Menyu → Telegram bo'limidan kod oling va /link KOD yuboring.",
    ru: 'Ваш аккаунт ещё не привязан. Получите код в приложении (Меню → Telegram) и отправьте /link КОД.',
    en: 'Your account isn\'t linked yet. Get a code from the app (Menu → Telegram) and send /link CODE.',
  },
  wrongRole: {
    uz: 'Bu amal sizning rolingiz uchun mavjud emas.',
    ru: 'Это действие недоступно для вашей роли.',
    en: 'This action is not available for your role.',
  },
  unknownCommand: {
    uz: "Quyidagi menyudan birini tanlang:",
    ru: 'Выберите один из пунктов меню:',
    en: 'Please choose one of the menu options:',
  },
  openAppPrompt: {
    uz: "🧩 To'liq ilovani (yuk joylash, xarita va h.k.) shu yerdan oching:",
    ru: '🧩 Откройте полное приложение (размещение груза, карта и т.д.) отсюда:',
    en: "🧩 Open the full app (post loads, map, and more) from here:",
  },
  btnOpenApp: { uz: 'Ilovani ochish', ru: 'Открыть приложение', en: 'Open app' },
  btnMyShipments: { uz: '📦 Mening yuklarim', ru: '📦 Мои грузы', en: '📦 My shipments' },
  btnNearbyLoads: { uz: '🚚 Yaqin yuklar', ru: '🚚 Грузы рядом', en: '🚚 Nearby loads' },
  btnMyDeliveries: { uz: '🚛 Yetkazib berishlarim', ru: '🚛 Мои доставки', en: '🚛 My deliveries' },
  noOpenLoads: {
    uz: "Hozircha yaqin atrofda ochiq yuk yo'q.",
    ru: 'Пока нет открытых грузов поблизости.',
    en: 'No open loads nearby right now.',
  },
  noDeliveries: {
    uz: "Sizda faol yetkazib berishlar yo'q.",
    ru: 'У вас нет активных доставок.',
    en: 'You have no active deliveries.',
  },
  noShipments: {
    uz: "Siz hali yuk joylamagansiz.",
    ru: 'Вы пока не разместили ни одного груза.',
    en: "You haven't posted any shipments yet.",
  },
  actionAccept: { uz: '✅ Qabul qilish', ru: '✅ Принять', en: '✅ Accept' },
  actionPickup: { uz: '📦 Yuklab oldim', ru: '📦 Забрал груз', en: '📦 Picked up' },
  actionComplete: { uz: '🏁 Yetkazdim', ru: '🏁 Доставлено', en: '🏁 Delivered' },
  actionRelease: { uz: '🔓 Voz kechish', ru: '🔓 Отказаться', en: '🔓 Release' },
  actionCancel: { uz: '❌ Bekor qilish', ru: '❌ Отменить', en: '❌ Cancel' },
  acceptedOk: { uz: '✅ Yuk qabul qilindi!', ru: '✅ Груз принят!', en: '✅ Load accepted!' },
  pickupOk: { uz: "📦 Yuk olib ketildi deb belgilandi.", ru: '📦 Отмечено как забрано.', en: '📦 Marked as picked up.' },
  completeOk: { uz: '🏁 Yetkazildi deb belgilandi!', ru: '🏁 Отмечено как доставлено!', en: '🏁 Marked as delivered!' },
  releaseOk: { uz: "🔓 Yukdan voz kechdingiz.", ru: 'Вы отказались от груза.', en: 'You released this load.' },
  cancelOk: { uz: '❌ Yuk bekor qilindi.', ru: '❌ Груз отменён.', en: '❌ Shipment cancelled.' },
  actionFailed: {
    uz: "Bu amalni bajarib bo'lmadi — holat allaqachon o'zgargan bo'lishi mumkin.",
    ru: 'Не удалось выполнить действие — статус, возможно, уже изменился.',
    en: 'Could not perform that action — the status may have already changed.',
  },
};

const CARGO_TYPE_LABELS = {
  general: { uz: 'Umumiy yuk', ru: 'Обычный груз', en: 'General cargo' },
  furniture: { uz: 'Mebel', ru: 'Мебель', en: 'Furniture' },
  construction: { uz: 'Qurilish materiallari', ru: 'Стройматериалы', en: 'Construction materials' },
  perishable: { uz: 'Oziq-ovqat', ru: 'Продукты питания', en: 'Food / perishable' },
  equipment: { uz: 'Uskuna / texnika', ru: 'Оборудование / техника', en: 'Equipment / machinery' },
};

const STATUS_LABELS = {
  open: { uz: 'Ochiq', ru: 'Открыт', en: 'Open' },
  accepted: { uz: 'Qabul qilindi', ru: 'Принят', en: 'Accepted' },
  in_transit: { uz: "Yo'lda", ru: 'В пути', en: 'In transit' },
  completed: { uz: 'Yetkazildi', ru: 'Доставлен', en: 'Completed' },
  cancelled: { uz: 'Bekor qilindi', ru: 'Отменён', en: 'Cancelled' },
};

function S(key, locale, ...args) {
  const entry = STRINGS[key][locale] ?? STRINGS[key].uz;
  return typeof entry === 'function' ? entry(...args) : entry;
}

function cargoLabel(key, locale) {
  return CARGO_TYPE_LABELS[key]?.[locale] || key;
}

function statusLabel(status, locale) {
  return STATUS_LABELS[status]?.[locale] || status;
}

const CURRENCY = { uz: "so'm", ru: 'сум', en: 'UZS' };

function listingSummary(row, locale) {
  const lines = [
    `📦 ${cargoLabel(row.cargo_type, locale)}  ·  ${statusLabel(row.status, locale)}`,
    `${row.pickup_label} → ${row.dropoff_label}`,
    `💰 ${row.price} ${CURRENCY[locale] || CURRENCY.uz}`,
  ];
  if (typeof row.distanceKm === 'number') {
    lines.push(`📍 ${row.distanceKm.toFixed(1)} km`);
  }
  return lines.join('\n');
}

function openAppKeyboard(locale) {
  const url = telegramClient.getMiniAppUrl();
  if (!url) return undefined;
  return Markup.inlineKeyboard([[Markup.button.webApp(S('btnOpenApp', locale), url)]]);
}

function menuFor(user, locale) {
  if (user.role === 'shipper') {
    return Markup.keyboard([[S('btnMyShipments', locale)]]).resize();
  }
  if (user.role === 'driver') {
    return Markup.keyboard([
      [S('btnNearbyLoads', locale)],
      [S('btnMyDeliveries', locale)],
    ]).resize();
  }
  return Markup.removeKeyboard();
}

function matchesButton(text, key) {
  return Object.values(STRINGS[key]).includes(text);
}

async function requireLinkedRole(ctx, role, locale) {
  const user = await telegramLinkService.findByChatId(ctx.chat.id);
  if (!user) {
    await ctx.reply(S('notLinked', locale));
    return null;
  }
  if (user.role !== role) {
    await ctx.reply(S('wrongRole', locale));
    return null;
  }
  return user;
}

async function sendNearbyLoads(ctx, user, locale) {
  const result = await cargoListingService.listNearby(user.id);
  const listings = result.ok ? result.listings : [];
  if (listings.length === 0) {
    await ctx.reply(S('noOpenLoads', locale));
    return;
  }
  for (const row of listings.slice(0, 10)) {
    await ctx.reply(
      listingSummary(row, locale),
      Markup.inlineKeyboard([
        [Markup.button.callback(S('actionAccept', locale), `accept:${row.id}`)],
      ])
    );
  }
}

async function sendMyDeliveries(ctx, user, locale) {
  const rows = await cargoListingService.listMineAsDriver(user.id);
  const active = rows.filter((r) => r.status === 'accepted' || r.status === 'in_transit');
  if (active.length === 0) {
    await ctx.reply(S('noDeliveries', locale));
    return;
  }
  for (const row of active.slice(0, 10)) {
    const buttons = [];
    if (row.status === 'accepted') {
      buttons.push(Markup.button.callback(S('actionPickup', locale), `pickup:${row.id}`));
    }
    if (row.status === 'in_transit') {
      buttons.push(Markup.button.callback(S('actionComplete', locale), `complete:${row.id}`));
    }
    buttons.push(Markup.button.callback(S('actionRelease', locale), `release:${row.id}`));
    await ctx.reply(listingSummary(row, locale), Markup.inlineKeyboard([buttons]));
  }
}

async function sendMyShipments(ctx, user, locale) {
  const rows = await cargoListingService.listMine(user.id);
  if (rows.length === 0) {
    await ctx.reply(S('noShipments', locale));
    return;
  }
  for (const row of rows.slice(0, 10)) {
    const markup =
      row.status === 'open'
        ? Markup.inlineKeyboard([
            [Markup.button.callback(S('actionCancel', locale), `cancel:${row.id}`)],
          ])
        : undefined;
    await ctx.reply(listingSummary(row, locale), markup);
  }
}

async function handleLink(ctx, code, locale) {
  const result = await telegramLinkService.consumeLinkCode(code, ctx.chat.id);
  if (!result.ok) {
    await ctx.reply(S('linkInvalid', locale));
    return;
  }
  await ctx.reply(
    S('linkSuccess', locale, result.user.full_name || ''),
    menuFor(result.user, locale)
  );
  const appKeyboard = openAppKeyboard(locale);
  if (appKeyboard) {
    await ctx.reply(S('openAppPrompt', locale), appKeyboard);
  }
}

async function runAction(ctx, { role, run, okKey }) {
  const locale = localeOf(ctx);
  const user = await requireLinkedRole(ctx, role, locale);
  await ctx.answerCbQuery().catch(() => {});
  if (!user) return;

  const listingId = Number(ctx.match[1]);
  const result = await run(user.id, listingId);
  if (!result.ok) {
    await ctx.reply(S('actionFailed', locale));
    return;
  }
  await ctx.editMessageReplyMarkup(undefined).catch(() => {});
  await ctx.reply(S(okKey, locale));
}

function registerHandlers() {
  const bot = telegramClient.getBot();
  if (!bot) return;

  bot.start(async (ctx) => {
    const locale = localeOf(ctx);
    const payload = ctx.startPayload || '';
    if (payload.startsWith('link_')) {
      await handleLink(ctx, payload.slice(5), locale);
      return;
    }
    const user = await telegramLinkService.findByChatId(ctx.chat.id);
    if (user) {
      await ctx.reply(S('welcomeLinked', locale, user.full_name || ''), menuFor(user, locale));
    } else {
      await ctx.reply(S('welcomeUnlinked', locale));
    }
    const appKeyboard = openAppKeyboard(locale);
    if (appKeyboard) {
      await ctx.reply(S('openAppPrompt', locale), appKeyboard);
    }
  });

  bot.command('link', async (ctx) => {
    const locale = localeOf(ctx);
    const code = ctx.message.text.split(/\s+/).slice(1)[0];
    if (!code) {
      await ctx.reply(S('linkUsageHint', locale));
      return;
    }
    await handleLink(ctx, code, locale);
  });

  bot.command('unlink', async (ctx) => {
    const locale = localeOf(ctx);
    const user = await telegramLinkService.findByChatId(ctx.chat.id);
    if (!user) {
      await ctx.reply(S('notLinked', locale));
      return;
    }
    await telegramLinkService.unlink(user.id);
    await ctx.reply(S('unlinkSuccess', locale), Markup.removeKeyboard());
  });

  bot.action(/^accept:(\d+)$/, (ctx) =>
    runAction(ctx, { role: 'driver', run: cargoListingService.acceptListing, okKey: 'acceptedOk' })
  );
  bot.action(/^pickup:(\d+)$/, (ctx) =>
    runAction(ctx, { role: 'driver', run: cargoListingService.pickupListing, okKey: 'pickupOk' })
  );
  bot.action(/^complete:(\d+)$/, (ctx) =>
    runAction(ctx, { role: 'driver', run: cargoListingService.completeListing, okKey: 'completeOk' })
  );
  bot.action(/^release:(\d+)$/, (ctx) =>
    runAction(ctx, { role: 'driver', run: cargoListingService.releaseListing, okKey: 'releaseOk' })
  );
  bot.action(/^cancel:(\d+)$/, (ctx) =>
    runAction(ctx, { role: 'shipper', run: cargoListingService.cancelListing, okKey: 'cancelOk' })
  );

  bot.on('text', async (ctx) => {
    const text = ctx.message.text;
    if (text.startsWith('/')) return;

    const locale = localeOf(ctx);
    const user = await telegramLinkService.findByChatId(ctx.chat.id);
    if (!user) {
      await ctx.reply(S('notLinked', locale));
      return;
    }
    if (matchesButton(text, 'btnMyShipments') && user.role === 'shipper') {
      await sendMyShipments(ctx, user, locale);
      return;
    }
    if (matchesButton(text, 'btnNearbyLoads') && user.role === 'driver') {
      await sendNearbyLoads(ctx, user, locale);
      return;
    }
    if (matchesButton(text, 'btnMyDeliveries') && user.role === 'driver') {
      await sendMyDeliveries(ctx, user, locale);
      return;
    }
    await ctx.reply(S('unknownCommand', locale), menuFor(user, locale));
  });
}

module.exports = { registerHandlers };
