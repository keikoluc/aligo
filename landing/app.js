// Aligo public landing page — a plain static site (no build step),
// following the same vanilla-JS/no-framework convention as
// backend/miniapp/app.js. Served from a different origin (aligoo.uz)
// than the API (api.aligoo.uz), so unlike the mini app it always uses
// an absolute API_BASE rather than relative fetch paths.
(function () {
  // Defensive cleanup: the Flutter app used to live at "/" and could have
  // left a service worker registered at this scope in a returning
  // visitor's browser (see flutter_service_worker.js in this same
  // folder, which is the primary fix — this just covers any other stale
  // registration at "/" too).
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.getRegistrations().then((regs) => {
      regs.forEach((reg) => reg.unregister());
    });
  }

  const API_BASE = ['localhost', '127.0.0.1'].includes(location.hostname)
    ? 'http://localhost:4000'
    : 'https://api.aligoo.uz';

  // Same public token already shipped in the Flutter app
  // (lib/core/config/app_config.dart) and the Telegram Mini App
  // (backend/miniapp/app.js) — safe for client-side use.
  const MAPBOX_TOKEN =
    'pk.eyJ1Ijoia2Vpa29sdWMiLCJhIjoiY21yNzNmcnN2MHlrMzJ5cXJsbzI5dG1ubSJ9.IUM29uRGwwPtb3m2jZKjoQ';

  const LANG_STORAGE_KEY = 'aligo_landing_lang';
  const THEME_STORAGE_KEY = 'aligo_landing_theme';

  function detectLocale() {
    const nav = (navigator.language || 'uz').slice(0, 2);
    return nav === 'ru' ? 'ru' : nav === 'en' ? 'en' : 'uz';
  }
  let LANG = localStorage.getItem(LANG_STORAGE_KEY) || detectLocale();

  const STR = {
    navAbout: { uz: 'Biz haqimizda', ru: 'О нас', en: 'About us' },
    navHow: { uz: 'Qanday ishlaydi', ru: 'Как это работает', en: 'How it works' },
    navCalculator: { uz: 'Narxni hisoblash', ru: 'Расчёт стоимости', en: 'Calculate price' },
    navContact: { uz: 'Aloqa', ru: 'Контакты', en: 'Contact' },
    downloadApk: { uz: 'APK yuklab olish', ru: 'Скачать APK', en: 'Download APK' },
    loginBtn: { uz: 'Kirish', ru: 'Войти', en: 'Sign in' },
    heroTitle: {
      uz: "O'zbekiston bo'ylab yuk tashish endi bir necha bosishda",
      ru: 'Перевозка грузов по Узбекистану — в несколько нажатий',
      en: 'Cargo shipping across Uzbekistan, in a few taps',
    },
    heroSubtitle: {
      uz: "Aligo yuk jo'natuvchilarni va haydovchilarni bitta platformada birlashtiradi: yukingizni joylang, mos haydovchi qabul qilsin, yetkazib berishni jonli kuzating.",
      ru: 'Aligo объединяет отправителей и водителей на одной платформе: разместите груз, подходящий водитель примет заказ, следите за доставкой в реальном времени.',
      en: "Aligo connects shippers and drivers on one platform: post your load, a matching driver accepts it, and you track the delivery live.",
    },
    heroCtaSecondary: { uz: 'Hisobga kirish', ru: 'Войти в аккаунт', en: 'Sign in' },
    aboutTitle: { uz: 'Biz haqimizda', ru: 'О нас', en: 'About us' },
    aboutSubtitle: {
      uz: "Aligo — jo'natuvchilar va haydovchilarni bog'laydigan yuk tashish platformasi.",
      ru: 'Aligo — платформа грузоперевозок, соединяющая отправителей и водителей.',
      en: 'Aligo is a cargo-shipping platform connecting shippers and drivers.',
    },
    feature1Title: { uz: 'Mos haydovchi tanlanadi', ru: 'Подходящий водитель', en: 'Matching drivers only' },
    feature1Body: {
      uz: "Yukni turi va manzillari bilan joylang — kerakli uskunaga (muzlatgich, tent, lift, bog'lash tasmalari) ega haydovchilargina uni qabul qila oladi.",
      ru: 'Разместите груз с типом и адресами — принять его смогут только водители с нужным оборудованием (холодильник, тент, лифт, стяжные ремни).',
      en: 'Post your load with its type and addresses — only drivers whose vehicle has the required equipment (refrigeration, tent, lift, tie-down straps) can accept it.',
    },
    feature2Title: { uz: 'Jonli kuzatuv', ru: 'Живое отслеживание', en: 'Live tracking' },
    feature2Body: {
      uz: "Yuklash va yetkazib berish davomida haydovchining joylashuvi real vaqtda xaritada ko'rsatiladi.",
      ru: 'Во время погрузки и доставки местоположение водителя показывается на карте в реальном времени.',
      en: "During pickup and delivery, the driver's location shows on the map in real time.",
    },
    feature3Title: { uz: 'Shaffof narxlash', ru: 'Прозрачные цены', en: 'Transparent pricing' },
    feature3Body: {
      uz: "Masofa va yuk turiga qarab taxminiy narx avtomatik hisoblanadi — qo'shimcha xizmatlar narxi ham oldindan ko'rinadi.",
      ru: 'Ориентировочная цена рассчитывается автоматически по расстоянию и типу груза — стоимость доп. услуг видна заранее.',
      en: 'An estimated price is calculated automatically from distance and cargo type — extra-service surcharges are shown upfront too.',
    },
    feature4Title: { uz: 'Baholash tizimi', ru: 'Система оценок', en: 'Ratings' },
    feature4Body: {
      uz: "Yetkazib berish tugagach, jo'natuvchi va haydovchi bir-birini baholaydi.",
      ru: 'После завершения доставки отправитель и водитель оценивают друг друга.',
      en: 'After delivery, the shipper and driver rate each other.',
    },
    howTitle: { uz: 'Qanday ishlaydi', ru: 'Как это работает', en: 'How it works' },
    step1Title: { uz: 'Yuk joylang', ru: 'Разместите груз', en: 'Post a load' },
    step1Body: {
      uz: 'Manzil, yuk turi va narxni kiriting.',
      ru: 'Укажите адрес, тип груза и цену.',
      en: 'Enter the addresses, cargo type, and price.',
    },
    step2Title: { uz: 'Haydovchi qabul qiladi', ru: 'Водитель принимает', en: 'A driver accepts' },
    step2Body: {
      uz: 'Mos transportga ega haydovchi yukni qabul qiladi.',
      ru: 'Водитель с подходящим транспортом принимает заказ.',
      en: 'A driver with a matching vehicle accepts the load.',
    },
    step3Title: { uz: 'Jonli kuzating', ru: 'Следите в реальном времени', en: 'Track it live' },
    step3Body: {
      uz: 'Yuklash va yetkazib berish jarayonini xaritada kuzating.',
      ru: 'Следите за погрузкой и доставкой на карте.',
      en: 'Watch pickup and delivery progress on the map.',
    },
    step4Title: { uz: 'Baholang', ru: 'Оцените', en: 'Rate it' },
    step4Body: {
      uz: 'Yetkazib berilgach, tajribangizni baholang.',
      ru: 'После доставки оцените свой опыт.',
      en: 'Once delivered, rate your experience.',
    },
    calcTitle: { uz: 'Narxni hisoblash', ru: 'Расчёт стоимости', en: 'Calculate price' },
    calcSubtitle: {
      uz: 'Taxminiy narxni bilish uchun manzillar va yuk turini tanlang.',
      ru: 'Выберите адреса и тип груза, чтобы узнать ориентировочную цену.',
      en: 'Pick the addresses and cargo type to see an estimated price.',
    },
    pickupLabel: { uz: 'Qayerdan', ru: 'Откуда', en: 'Pickup' },
    dropoffLabel: { uz: 'Qayerga', ru: 'Куда', en: 'Dropoff' },
    searchAddress: { uz: 'Manzil qidirish...', ru: 'Поиск адреса...', en: 'Search address...' },
    cargoType: { uz: 'Yuk turi', ru: 'Тип груза', en: 'Cargo type' },
    specialRequirements: { uz: "Qo'shimcha talablar", ru: 'Доп. требования', en: 'Special requirements' },
    calcButton: { uz: 'Hisoblash', ru: 'Рассчитать', en: 'Calculate' },
    calcDistance: { uz: 'Masofa', ru: 'Расстояние', en: 'Distance' },
    calcDuration: { uz: 'Taxminiy vaqt', ru: 'Ориент. время', en: 'Estimated time' },
    calcPrice: { uz: 'Taxminiy narx', ru: 'Ориент. цена', en: 'Estimated price' },
    calcNote: {
      uz: "Bu taxminiy narx. Ilovada yuk joylaganda narxni o'zingiz belgilashingiz mumkin.",
      ru: 'Это ориентировочная цена. При размещении груза в приложении вы можете указать свою цену.',
      en: 'This is only an estimate — you can still set your own price when posting the load in the app.',
    },
    calcFillFields: {
      uz: 'Ikkala manzilni ham tanlang.',
      ru: 'Выберите оба адреса.',
      en: 'Choose both addresses.',
    },
    calcGenericError: {
      uz: 'Narxni hisoblab bo\'lmadi. Birozdan so\'ng qayta urinib ko\'ring.',
      ru: 'Не удалось рассчитать цену. Повторите попытку позже.',
      en: 'Could not calculate a price. Please try again shortly.',
    },
    downloadTitle: { uz: 'Aligo ilovasini yuklab oling', ru: 'Скачайте приложение Aligo', en: 'Download the Aligo app' },
    downloadBody: {
      uz: 'Android uchun (arm64 qurilmalar, 2018-yildan keyingi deyarli barcha telefonlar).',
      ru: 'Для Android (устройства arm64 — почти все телефоны после 2018 года).',
      en: 'For Android (arm64 devices — nearly every phone since 2018).',
    },
    contactTitle: { uz: 'Aloqa', ru: 'Контакты', en: 'Contact' },
    allRightsReserved: {
      uz: 'Barcha huquqlar himoyalangan.',
      ru: 'Все права защищены.',
      en: 'All rights reserved.',
    },
    // Cargo types / features — kept identical to backend/miniapp/app.js
    // so the calculator matches what a shipper sees in the real app.
    cargoGeneral: { uz: 'Umumiy yuk', ru: 'Обычный груз', en: 'General cargo' },
    cargoFurniture: { uz: 'Mebel', ru: 'Мебель', en: 'Furniture' },
    cargoConstruction: { uz: 'Qurilish materiallari', ru: 'Стройматериалы', en: 'Construction materials' },
    cargoPerishable: { uz: 'Oziq-ovqat', ru: 'Продукты', en: 'Food / perishable' },
    cargoEquipment: { uz: 'Uskuna / texnika', ru: 'Оборудование', en: 'Equipment / machinery' },
    amenityRefrigerated: { uz: 'Muzlatgich', ru: 'Холодильник', en: 'Refrigerated' },
    amenitySideRearTent: { uz: 'Yon/orqa tent', ru: 'Боковой/задний тент', en: 'Side/rear tent' },
    amenityLift: { uz: 'Lift', ru: 'Лифт', en: 'Lift' },
    amenityTieDownStraps: { uz: "Bog'lash tasmalari", ru: 'Стяжные ремни', en: 'Tie-down straps' },
    // Login modal — mirrors lib/screens/auth/{login,otp}_screen.dart's
    // copy/tone so it feels consistent with the app.
    loginWelcomeTitle: { uz: "Aligo'ga xush kelibsiz", ru: 'Добро пожаловать в Aligo', en: 'Welcome to Aligo' },
    loginWelcomeSubtitle: {
      uz: 'Kirish uchun sizga bir martalik kod yuboramiz.',
      ru: 'Отправим вам одноразовый код для входа.',
      en: "We'll email you a one-time code to sign in.",
    },
    emailLabel: { uz: 'Email manzil', ru: 'Email адрес', en: 'Email address' },
    fullNameLabel: { uz: "To'liq ism (ixtiyoriy)", ru: 'Полное имя (необязательно)', en: 'Full name (optional)' },
    fullNamePlaceholder: { uz: 'Jasur Karimov', ru: 'Жасур Каримов', en: 'Jasur Karimov' },
    continueWithEmail: { uz: 'Email orqali davom etish', ru: 'Продолжить через email', en: 'Continue with email' },
    otpTitle: { uz: 'Emailingizni tasdiqlang', ru: 'Подтвердите email', en: 'Verify your email' },
    otpSubtitle: {
      uz: '{email} manziliga 6 xonali tasdiqlash kodi yuborildi.',
      ru: 'На {email} отправлен 6-значный код подтверждения.',
      en: 'We emailed a 6-digit verification code to {email}.',
    },
    codeLabel: { uz: 'Kod', ru: 'Код', en: 'Code' },
    verifyAndContinue: { uz: 'Tasdiqlash va davom etish', ru: 'Подтвердить и продолжить', en: 'Verify & continue' },
    resendCode: { uz: 'Kod kelmadimi? Qayta yuborish', ru: 'Не пришёл код? Отправить снова', en: "Didn't get a code? Resend" },
    resendSending: { uz: 'Yuborilmoqda...', ru: 'Отправка...', en: 'Sending...' },
    resendSent: { uz: 'Yangi kod yuborildi.', ru: 'Новый код отправлен.', en: 'A new code has been sent.' },
    loginSuccessTitle: { uz: 'Kirdingiz!', ru: 'Вы вошли!', en: "You're in!" },
    loginSuccessBody: {
      uz: 'Endi Aligo ilovasida davom eting.',
      ru: 'Теперь продолжите в приложении Aligo.',
      en: 'Now continue in the Aligo app.',
    },
    openAppButton: { uz: 'Ilovaga o\'tish', ru: 'Перейти в приложение', en: 'Open the app' },
    loginEmailRequired: {
      uz: "To'g'ri email manzil kiriting.",
      ru: 'Введите корректный email.',
      en: 'Enter a valid email address.',
    },
  };

  function t(key) {
    return (STR[key] && (STR[key][LANG] || STR[key].uz)) || key;
  }

  const CARGO_TYPES = [
    ['general', 'cargoGeneral'],
    ['furniture', 'cargoFurniture'],
    ['construction', 'cargoConstruction'],
    ['perishable', 'cargoPerishable'],
    ['equipment', 'cargoEquipment'],
  ];
  const FEATURES = [
    ['refrigerated', 'amenityRefrigerated', 15000],
    ['sideRearTent', 'amenitySideRearTent', 8000],
    ['lift', 'amenityLift', 10000],
    ['tieDownStraps', 'amenityTieDownStraps', 5000],
  ];

  function applyTranslations() {
    document.documentElement.lang = LANG;
    document.querySelectorAll('[data-i18n]').forEach((el) => {
      el.textContent = t(el.dataset.i18n);
    });
    document.querySelectorAll('[data-i18n-placeholder]').forEach((el) => {
      el.placeholder = t(el.dataset.i18nPlaceholder);
    });
    document.getElementById('lang-toggle').textContent = LANG.toUpperCase();
    renderCargoTypeOptions();
    renderFeatureCheckboxes();
    // otpSubtitle has a {email} placeholder the generic data-i18n loop
    // above can't fill in — re-render it with the email already in
    // progress, if the login modal is mid-flow when the language changes.
    if (typeof loginEmail !== 'undefined' && loginEmail) updateOtpSubtitle();
  }

  function renderCargoTypeOptions() {
    const select = document.getElementById('cargo-type');
    const previous = select.value;
    select.innerHTML = CARGO_TYPES.map(
      ([key, labelKey]) => `<option value="${key}">${t(labelKey)}</option>`
    ).join('');
    if (previous) select.value = previous;
  }

  function renderFeatureCheckboxes() {
    const container = document.getElementById('features');
    const checked = new Set(
      Array.from(container.querySelectorAll('input:checked')).map((el) => el.dataset.feature)
    );
    container.innerHTML = FEATURES.map(
      ([key, labelKey, surcharge]) => `
        <label class="checkbox-row">
          <input type="checkbox" data-feature="${key}" ${checked.has(key) ? 'checked' : ''} />
          <span>${t(labelKey)}</span>
          <span class="surcharge">+${surcharge.toLocaleString('uz-UZ')} so'm</span>
        </label>
      `
    ).join('');
  }

  // ---------- Language toggle ----------

  const LANG_CYCLE = ['uz', 'ru', 'en'];
  document.getElementById('lang-toggle').addEventListener('click', () => {
    const next = LANG_CYCLE[(LANG_CYCLE.indexOf(LANG) + 1) % LANG_CYCLE.length];
    LANG = next;
    localStorage.setItem(LANG_STORAGE_KEY, next);
    applyTranslations();
  });

  // ---------- Theme toggle ----------

  function applyThemeIcon() {
    const stored = localStorage.getItem(THEME_STORAGE_KEY);
    const isDark = stored
      ? stored === 'dark'
      : window.matchMedia('(prefers-color-scheme: dark)').matches;
    document.getElementById('theme-icon').textContent = isDark ? '☀️' : '🌙';
  }
  document.getElementById('theme-toggle').addEventListener('click', () => {
    const current = document.documentElement.dataset.theme
      || (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
    const next = current === 'dark' ? 'light' : 'dark';
    document.documentElement.dataset.theme = next;
    localStorage.setItem(THEME_STORAGE_KEY, next);
    applyThemeIcon();
  });
  (function initTheme() {
    const stored = localStorage.getItem(THEME_STORAGE_KEY);
    if (stored) document.documentElement.dataset.theme = stored;
    applyThemeIcon();
  })();

  // ---------- Mobile nav ----------

  document.getElementById('nav-burger').addEventListener('click', () => {
    document.getElementById('site-nav').classList.toggle('open');
  });
  document.getElementById('site-nav').addEventListener('click', (e) => {
    if (e.target.tagName === 'A') document.getElementById('site-nav').classList.remove('open');
  });

  // ---------- Address search (Mapbox Geocoding) ----------
  // Same pattern as backend/miniapp/app.js's setupAddressSearch.

  const points = { pickup: null, dropoff: null };

  function setupAddressSearch(inputId, suggestionsId, pointKey) {
    const input = document.getElementById(inputId);
    const suggestions = document.getElementById(suggestionsId);
    let debounceTimer;
    input.addEventListener('input', () => {
      clearTimeout(debounceTimer);
      const query = input.value.trim();
      if (query.length < 3) {
        suggestions.hidden = true;
        return;
      }
      debounceTimer = setTimeout(async () => {
        try {
          const res = await fetch(
            `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(query)}.json?access_token=${MAPBOX_TOKEN}&limit=5&country=uz`
          );
          const body = await res.json();
          const features = body.features || [];
          suggestions.innerHTML = features
            .map((f, i) => `<div class="suggestion-item" data-index="${i}">${f.place_name}</div>`)
            .join('');
          suggestions.hidden = features.length === 0;
          suggestions.dataset.features = JSON.stringify(
            features.map((f) => ({ label: f.place_name, lat: f.center[1], lng: f.center[0] }))
          );
        } catch {
          suggestions.hidden = true;
        }
      }, 350);
    });
    suggestions.addEventListener('click', (e) => {
      const item = e.target.closest('.suggestion-item');
      if (!item) return;
      const candidates = JSON.parse(suggestions.dataset.features || '[]');
      const candidate = candidates[Number(item.dataset.index)];
      if (!candidate) return;
      points[pointKey] = candidate;
      input.value = candidate.label;
      suggestions.hidden = true;
    });
    document.addEventListener('click', (e) => {
      if (!suggestions.contains(e.target) && e.target !== input) suggestions.hidden = true;
    });
  }
  setupAddressSearch('pickup-search', 'pickup-suggestions', 'pickup');
  setupAddressSearch('dropoff-search', 'dropoff-suggestions', 'dropoff');

  // ---------- Calculator ----------

  document.getElementById('calc-btn').addEventListener('click', async () => {
    const errorEl = document.getElementById('calc-error');
    const resultEl = document.getElementById('calc-result');
    errorEl.hidden = true;
    resultEl.hidden = true;

    if (!points.pickup || !points.dropoff) {
      errorEl.textContent = t('calcFillFields');
      errorEl.hidden = false;
      return;
    }

    const cargoType = document.getElementById('cargo-type').value;
    const requiredFeatures = Array.from(
      document.querySelectorAll('#features input:checked')
    ).map((el) => el.dataset.feature);

    const query = new URLSearchParams({
      cargoType,
      pickupLat: String(points.pickup.lat),
      pickupLng: String(points.pickup.lng),
      dropoffLat: String(points.dropoff.lat),
      dropoffLng: String(points.dropoff.lng),
    });
    for (const key of requiredFeatures) query.set(key, 'true');

    const btn = document.getElementById('calc-btn');
    btn.disabled = true;
    try {
      const res = await fetch(`${API_BASE}/api/cargo/public-estimate?${query.toString()}`, {
        headers: { 'X-App-Locale': LANG },
      });
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || t('calcGenericError'));

      document.getElementById('calc-distance').textContent = `${body.distanceKm.toFixed(1)} km`;
      document.getElementById('calc-duration').textContent = `${Math.round(body.durationMin)} min`;
      document.getElementById('calc-price').textContent =
        `${Math.round(body.suggestedPrice).toLocaleString('uz-UZ')} so'm`;
      resultEl.hidden = false;
    } catch (err) {
      errorEl.textContent = err.message || t('calcGenericError');
      errorEl.hidden = false;
    } finally {
      btn.disabled = false;
    }
  });

  // ---------- Login / register modal ----------
  // Single email(+optional name)-then-code flow, same as
  // POST /api/auth/otp/send + /verify already used by the Flutter app
  // and the Telegram Mini App — this modal is just a third client for
  // the same backend endpoints, not a separate auth system.

  const overlay = document.getElementById('login-overlay');
  const stepEmail = document.getElementById('step-email');
  const stepOtp = document.getElementById('step-otp');
  const stepSuccess = document.getElementById('step-success');
  let loginEmail = '';

  function showStep(step) {
    stepEmail.hidden = step !== 'email';
    stepOtp.hidden = step !== 'otp';
    stepSuccess.hidden = step !== 'success';
  }

  function updateOtpSubtitle() {
    document.getElementById('otp-subtitle').textContent = t('otpSubtitle').replace('{email}', loginEmail);
  }

  function openLoginModal() {
    overlay.hidden = false;
    showStep('email');
    document.getElementById('login-email-error').hidden = true;
    document.getElementById('login-otp-error').hidden = true;
  }
  function closeLoginModal() {
    overlay.hidden = true;
  }

  document.querySelectorAll('.js-login-trigger').forEach((btn) => {
    btn.addEventListener('click', openLoginModal);
  });
  document.getElementById('login-close').addEventListener('click', closeLoginModal);
  overlay.addEventListener('click', (e) => {
    if (e.target === overlay) closeLoginModal();
  });
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && !overlay.hidden) closeLoginModal();
  });

  async function sendOtp(email) {
    const res = await fetch(`${API_BASE}/api/auth/otp/send`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-App-Locale': LANG },
      body: JSON.stringify({ email }),
    });
    const body = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(body.error || t('calcGenericError'));
  }

  async function submitEmailStep() {
    const email = document.getElementById('login-email').value.trim();
    const errorEl = document.getElementById('login-email-error');
    errorEl.hidden = true;
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      errorEl.textContent = t('loginEmailRequired');
      errorEl.hidden = false;
      return;
    }
    const btn = document.getElementById('login-send-otp');
    btn.disabled = true;
    try {
      await sendOtp(email);
      loginEmail = email;
      updateOtpSubtitle();
      document.getElementById('login-code').value = '';
      showStep('otp');
    } catch (err) {
      errorEl.textContent = err.message;
      errorEl.hidden = false;
    } finally {
      btn.disabled = false;
    }
  }
  document.getElementById('login-send-otp').addEventListener('click', submitEmailStep);
  ['login-email', 'login-fullname'].forEach((id) => {
    document.getElementById(id).addEventListener('keydown', (e) => {
      if (e.key === 'Enter') submitEmailStep();
    });
  });

  async function submitOtpStep() {
    const code = document.getElementById('login-code').value.trim();
    const fullName = document.getElementById('login-fullname').value.trim();
    const errorEl = document.getElementById('login-otp-error');
    errorEl.hidden = true;
    const btn = document.getElementById('login-verify-otp');
    btn.disabled = true;
    try {
      const res = await fetch(`${API_BASE}/api/auth/otp/verify`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-App-Locale': LANG },
        body: JSON.stringify({ email: loginEmail, code, fullName: fullName || undefined }),
      });
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || t('calcGenericError'));

      const name = body.user && (body.user.fullName || body.user.email);
      document.getElementById('login-success-body').textContent = name
        ? `${t('loginSuccessBody')} (${name})`
        : t('loginSuccessBody');
      showStep('success');
    } catch (err) {
      errorEl.textContent = err.message;
      errorEl.hidden = false;
    } finally {
      btn.disabled = false;
    }
  }
  document.getElementById('login-verify-otp').addEventListener('click', submitOtpStep);
  document.getElementById('login-code').addEventListener('keydown', (e) => {
    if (e.key === 'Enter') submitOtpStep();
  });

  document.getElementById('login-resend').addEventListener('click', async (e) => {
    const link = e.currentTarget;
    link.disabled = true;
    link.textContent = t('resendSending');
    try {
      await sendOtp(loginEmail);
      link.textContent = t('resendSent');
    } catch {
      link.textContent = t('resendCode');
    } finally {
      link.disabled = false;
      setTimeout(() => {
        if (!overlay.hidden) link.textContent = t('resendCode');
      }, 2500);
    }
  });

  // ---------- Boot ----------

  document.getElementById('footer-year').textContent = String(new Date().getFullYear());
  applyTranslations();
})();
