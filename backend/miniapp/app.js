// Aligo Telegram Mini App — a lightweight vanilla-JS client for the same
// REST API the Flutter app uses (see backend/src/routes/cargo.js). Auth
// works differently though: instead of email OTP, the Telegram Mini App
// exchanges its signed `initData` for a normal Aligo JWT (see
// /api/telegram-miniapp/auth and /link, backed by telegramAuthService.js).
(function () {
  const tg = window.Telegram && window.Telegram.WebApp;
  if (tg) {
    tg.ready();
    tg.expand();
  }

  // Same public token used by the Flutter app's GeocodingService — safe
  // for client-side use (Mapbox `pk.` tokens are meant to be public).
  const MAPBOX_TOKEN =
    'pk.eyJ1Ijoia2Vpa29sdWMiLCJhIjoiY21yNzNmcnN2MHlrMzJ5cXJsbzI5dG1ubSJ9.IUM29uRGwwPtb3m2jZKjoQ';

  const LOCALE = (tg && tg.initDataUnsafe && tg.initDataUnsafe.user && tg.initDataUnsafe.user.language_code) || 'uz';
  const LANG = LOCALE === 'ru' ? 'ru' : LOCALE === 'en' ? 'en' : 'uz';

  const STR = {
    linkTitle: { uz: "Aligo'ga xush kelibsiz", ru: 'Добро пожаловать в Aligo', en: 'Welcome to Aligo' },
    linkIntro: {
      uz: 'Hisobingizni ulash uchun Aligo ilovasida Menyu → Telegram bo\'limidan kod oling va shu yerga kiriting.',
      ru: 'Чтобы привязать аккаунт, получите код в приложении Aligo (Меню → Telegram) и введите его здесь.',
      en: 'To link your account, get a code from the Aligo app (Menu → Telegram) and enter it here.',
    },
    codeLabel: { uz: 'Kod', ru: 'Код', en: 'Code' },
    linkButton: { uz: 'Ulash', ru: 'Привязать', en: 'Link' },
    invalidCode: { uz: "Kod noto'g'ri yoki muddati tugagan.", ru: 'Код неверен или истёк.', en: 'Code is invalid or expired.' },
    connectionError: { uz: "Serverga ulanib bo'lmadi.", ru: 'Не удалось подключиться к серверу.', en: 'Could not reach the server.' },
    myShipments: { uz: 'Mening yuklarim', ru: 'Мои грузы', en: 'My shipments' },
    nearbyLoads: { uz: 'Yaqin yuklar', ru: 'Грузы рядом', en: 'Nearby loads' },
    myDeliveries: { uz: 'Yetkazib berishlarim', ru: 'Мои доставки', en: 'My deliveries' },
    noShipments: { uz: "Hali yuk joylanmagan.", ru: 'Пока нет грузов.', en: 'No shipments yet.' },
    noOpenLoads: { uz: "Yaqin atrofda ochiq yuk yo'q.", ru: 'Поблизости нет открытых грузов.', en: 'No open loads nearby.' },
    noDeliveries: { uz: "Faol yetkazib berish yo'q.", ru: 'Нет активных доставок.', en: 'No active deliveries.' },
    accept: { uz: 'Qabul qilish', ru: 'Принять', en: 'Accept' },
    pickup: { uz: 'Yuklab oldim', ru: 'Забрал', en: 'Picked up' },
    complete: { uz: 'Yetkazdim', ru: 'Доставлено', en: 'Delivered' },
    release: { uz: 'Voz kechish', ru: 'Отказаться', en: 'Release' },
    cancel: { uz: 'Bekor qilish', ru: 'Отменить', en: 'Cancel' },
    newLoad: { uz: 'Yangi yuk', ru: 'Новый груз', en: 'New load' },
    postLoadTitle: { uz: 'Yangi yuk joylash', ru: 'Разместить груз', en: 'Post a new load' },
    cargoType: { uz: 'Yuk turi', ru: 'Тип груза', en: 'Cargo type' },
    description: { uz: 'Tavsif (ixtiyoriy)', ru: 'Описание (необязательно)', en: 'Description (optional)' },
    pickupLabel: { uz: 'Qayerdan', ru: 'Откуда', en: 'Pickup' },
    dropoffLabel: { uz: 'Qayerga', ru: 'Куда', en: 'Dropoff' },
    searchAddress: { uz: 'Manzil qidirish...', ru: 'Поиск адреса...', en: 'Search address...' },
    priceLabel: { uz: "Narx (so'm)", ru: 'Цена (сум)', en: 'Price (UZS)' },
    specialRequirements: { uz: "Qo'shimcha talablar", ru: 'Доп. требования', en: 'Special requirements' },
    post: { uz: 'Joylash', ru: 'Разместить', en: 'Post' },
    back: { uz: '← Orqaga', ru: '← Назад', en: '← Back' },
    posted: { uz: 'Yuk joylandi!', ru: 'Груз размещён!', en: 'Load posted!' },
    genericError: { uz: 'Xatolik yuz berdi.', ru: 'Произошла ошибка.', en: 'Something went wrong.' },
    cargoGeneral: { uz: 'Umumiy yuk', ru: 'Обычный груз', en: 'General cargo' },
    cargoFurniture: { uz: 'Mebel', ru: 'Мебель', en: 'Furniture' },
    cargoConstruction: { uz: 'Qurilish materiallari', ru: 'Стройматериалы', en: 'Construction materials' },
    cargoPerishable: { uz: 'Oziq-ovqat', ru: 'Продукты', en: 'Food / perishable' },
    cargoEquipment: { uz: 'Uskuna / texnika', ru: 'Оборудование', en: 'Equipment / machinery' },
    amenityRefrigerated: { uz: 'Muzlatgich', ru: 'Холодильник', en: 'Refrigerated' },
    amenitySideRearTent: { uz: 'Yon/orqa tent', ru: 'Боковой/задний тент', en: 'Side/rear tent' },
    amenityLift: { uz: 'Lift', ru: 'Лифт', en: 'Lift' },
    amenityTieDownStraps: { uz: 'Bog\'lash tasmalari', ru: 'Стяжные ремни', en: 'Tie-down straps' },
    statusOpen: { uz: 'Ochiq', ru: 'Открыт', en: 'Open' },
    statusAccepted: { uz: 'Qabul qilindi', ru: 'Принят', en: 'Accepted' },
    statusInTransit: { uz: "Yo'lda", ru: 'В пути', en: 'In transit' },
    statusCompleted: { uz: 'Yetkazildi', ru: 'Доставлен', en: 'Completed' },
    statusCancelled: { uz: 'Bekor qilindi', ru: 'Отменён', en: 'Cancelled' },
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

  const root = document.getElementById('root');
  const state = { token: null, user: null, driverTab: 'nearby' };

  function toast(message) {
    const el = document.createElement('div');
    el.className = 'toast';
    el.textContent = message;
    document.body.appendChild(el);
    setTimeout(() => el.remove(), 2800);
  }

  async function api(path, options = {}) {
    const headers = Object.assign(
      { 'Content-Type': 'application/json', 'X-App-Locale': LANG },
      state.token ? { Authorization: `Bearer ${state.token}` } : {},
      options.headers || {}
    );
    let response;
    try {
      response = await fetch(path, Object.assign({}, options, { headers }));
    } catch {
      throw new Error(t('connectionError'));
    }
    const body = await response.json().catch(() => ({}));
    if (!response.ok) {
      throw new Error(body.error || t('genericError'));
    }
    return body;
  }

  function el(html) {
    const div = document.createElement('div');
    div.innerHTML = html.trim();
    return div.firstElementChild;
  }

  // ---------- Auth ----------

  async function boot() {
    const initData = tg ? tg.initData : '';
    try {
      const result = await api('/api/telegram-miniapp/auth', {
        method: 'POST',
        body: JSON.stringify({ initData }),
      });
      if (result.linked) {
        state.token = result.token;
        state.user = result.user;
        renderHome();
      } else {
        renderLinkScreen();
      }
    } catch (err) {
      renderLinkScreen(err.message);
    }
  }

  function renderLinkScreen(errorMessage) {
    root.innerHTML = '';
    const screen = el(`
      <div class="screen">
        <div class="header"><div class="logo-dot"></div><h1>Aligo</h1></div>
        <h2>${t('linkTitle')}</h2>
        <p>${t('linkIntro')}</p>
        <div class="field">
          <label>${t('codeLabel')}</label>
          <input id="code-input" type="text" maxlength="6" autocapitalize="characters" placeholder="ABC123" />
        </div>
        ${errorMessage ? `<p style="color: var(--error)">${errorMessage}</p>` : ''}
        <button class="btn btn-primary" id="link-btn">${t('linkButton')}</button>
      </div>
    `);
    root.appendChild(screen);

    screen.querySelector('#link-btn').addEventListener('click', async () => {
      const code = screen.querySelector('#code-input').value.trim();
      if (!code) return;
      const btn = screen.querySelector('#link-btn');
      btn.disabled = true;
      try {
        const result = await api('/api/telegram-miniapp/link', {
          method: 'POST',
          body: JSON.stringify({ initData: tg ? tg.initData : '', code }),
        });
        state.token = result.token;
        state.user = result.user;
        renderHome();
      } catch (err) {
        renderLinkScreen(err.message || t('invalidCode'));
      } finally {
        btn.disabled = false;
      }
    });
  }

  // ---------- Home ----------

  function renderHome() {
    if (state.user.role === 'shipper') {
      renderShipperHome();
    } else {
      renderDriverHome();
    }
  }

  function statusPill(status) {
    const key = 'status' + status.replace(/(^|_)([a-z])/g, (_, __, c) => c.toUpperCase());
    return `<span class="pill pill-${status}">${t(key)}</span>`;
  }

  function cargoTypeLabel(key) {
    const found = CARGO_TYPES.find((c) => c[0] === key);
    return found ? t(found[1]) : key;
  }

  function listingCard(listing, actionsHtml) {
    return `
      <div class="card" data-id="${listing.id}">
        <div class="card-row">
          <div class="card-title">${cargoTypeLabel(listing.cargoType)}</div>
          ${statusPill(listing.status)}
        </div>
        <div class="card-route">${listing.pickup.label} → ${listing.dropoff.label}</div>
        <div class="card-price">${Math.round(listing.price)} so'm</div>
        ${actionsHtml || ''}
      </div>
    `;
  }

  async function renderShipperHome() {
    root.innerHTML = '';
    const screen = el(`
      <div class="screen">
        <div class="header"><div class="logo-dot"></div><h1>${t('myShipments')}</h1></div>
        <div id="list-container"><div class="spinner"></div></div>
        <button class="fab" id="new-load-fab">+</button>
      </div>
    `);
    root.appendChild(screen);
    screen.querySelector('#new-load-fab').addEventListener('click', renderPostLoadScreen);

    try {
      const { listings } = await api('/api/cargo/mine');
      const container = screen.querySelector('#list-container');
      if (listings.length === 0) {
        container.innerHTML = `<div class="empty-state">${t('noShipments')}</div>`;
        return;
      }
      container.innerHTML = listings
        .map((l) =>
          listingCard(
            l,
            l.status === 'open'
              ? `<div class="card-actions"><button class="btn btn-danger btn-small" data-action="cancel" data-id="${l.id}">${t('cancel')}</button></div>`
              : ''
          )
        )
        .join('');
      container.addEventListener('click', async (e) => {
        const btn = e.target.closest('[data-action="cancel"]');
        if (!btn) return;
        btn.disabled = true;
        try {
          await api(`/api/cargo/${btn.dataset.id}/cancel`, { method: 'POST' });
          renderShipperHome();
        } catch (err) {
          toast(err.message);
          btn.disabled = false;
        }
      });
    } catch (err) {
      screen.querySelector('#list-container').innerHTML = `<div class="empty-state">${err.message}</div>`;
    }
  }

  async function renderDriverHome() {
    root.innerHTML = '';
    const screen = el(`
      <div class="screen">
        <div class="header"><div class="logo-dot"></div><h1>Aligo</h1></div>
        <div class="tabs">
          <div class="tab ${state.driverTab === 'nearby' ? 'active' : ''}" data-tab="nearby">${t('nearbyLoads')}</div>
          <div class="tab ${state.driverTab === 'deliveries' ? 'active' : ''}" data-tab="deliveries">${t('myDeliveries')}</div>
        </div>
        <div id="list-container"><div class="spinner"></div></div>
      </div>
    `);
    root.appendChild(screen);

    screen.querySelectorAll('.tab').forEach((tabEl) => {
      tabEl.addEventListener('click', () => {
        state.driverTab = tabEl.dataset.tab;
        renderDriverHome();
      });
    });

    const container = screen.querySelector('#list-container');
    try {
      if (state.driverTab === 'nearby') {
        const { listings } = await api('/api/cargo/nearby');
        if (listings.length === 0) {
          container.innerHTML = `<div class="empty-state">${t('noOpenLoads')}</div>`;
          return;
        }
        container.innerHTML = listings
          .map((l) =>
            listingCard(
              l,
              `<div class="card-actions"><button class="btn btn-primary btn-small" data-action="accept" data-id="${l.id}">${t('accept')}</button></div>`
            )
          )
          .join('');
      } else {
        const { listings } = await api('/api/cargo/deliveries');
        const active = listings.filter((l) => l.status === 'accepted' || l.status === 'in_transit');
        if (active.length === 0) {
          container.innerHTML = `<div class="empty-state">${t('noDeliveries')}</div>`;
          return;
        }
        container.innerHTML = active
          .map((l) => {
            const actions = [];
            if (l.status === 'accepted') {
              actions.push(`<button class="btn btn-primary btn-small" data-action="pickup" data-id="${l.id}">${t('pickup')}</button>`);
            }
            if (l.status === 'in_transit') {
              actions.push(`<button class="btn btn-primary btn-small" data-action="complete" data-id="${l.id}">${t('complete')}</button>`);
            }
            actions.push(`<button class="btn btn-outline btn-small" data-action="release" data-id="${l.id}">${t('release')}</button>`);
            return listingCard(l, `<div class="card-actions">${actions.join('')}</div>`);
          })
          .join('');
      }

      container.addEventListener('click', async (e) => {
        const btn = e.target.closest('button[data-action]');
        if (!btn) return;
        const action = btn.dataset.action;
        btn.disabled = true;
        try {
          await api(`/api/cargo/${btn.dataset.id}/${action}`, { method: 'POST' });
          renderDriverHome();
        } catch (err) {
          toast(err.message);
          btn.disabled = false;
        }
      });
    } catch (err) {
      container.innerHTML = `<div class="empty-state">${err.message}</div>`;
    }
  }

  // ---------- Post a new load (shipper) ----------

  function renderPostLoadScreen() {
    root.innerHTML = '';
    const points = { pickup: null, dropoff: null };
    const requiredFeatures = new Set();

    const screen = el(`
      <div class="screen">
        <div class="back-link" id="back-link">${t('back')}</div>
        <h2>${t('postLoadTitle')}</h2>
        <div class="field">
          <label>${t('cargoType')}</label>
          <select id="cargo-type">
            ${CARGO_TYPES.map(([key, labelKey]) => `<option value="${key}">${t(labelKey)}</option>`).join('')}
          </select>
        </div>
        <div class="field">
          <label>${t('description')}</label>
          <textarea id="description"></textarea>
        </div>
        <div class="field">
          <label>${t('pickupLabel')}</label>
          <input id="pickup-search" type="text" placeholder="${t('searchAddress')}" />
          <div class="suggestions" id="pickup-suggestions" style="display:none"></div>
        </div>
        <div class="field">
          <label>${t('dropoffLabel')}</label>
          <input id="dropoff-search" type="text" placeholder="${t('searchAddress')}" />
          <div class="suggestions" id="dropoff-suggestions" style="display:none"></div>
        </div>
        <h2>${t('specialRequirements')}</h2>
        <div id="features"></div>
        <div class="field">
          <label>${t('priceLabel')}</label>
          <input id="price" type="number" inputmode="numeric" />
        </div>
        <button class="btn btn-primary" id="submit-btn">${t('post')}</button>
      </div>
    `);
    root.appendChild(screen);

    screen.querySelector('#back-link').addEventListener('click', renderShipperHome);

    const featuresContainer = screen.querySelector('#features');
    featuresContainer.innerHTML = FEATURES.map(
      ([key, labelKey, surcharge]) => `
        <label class="checkbox-row">
          <input type="checkbox" data-feature="${key}" />
          <span>${t(labelKey)}</span>
          <span class="surcharge">+${surcharge} so'm</span>
        </label>
      `
    ).join('');
    featuresContainer.addEventListener('change', (e) => {
      const key = e.target.dataset.feature;
      if (!key) return;
      if (e.target.checked) requiredFeatures.add(key);
      else requiredFeatures.delete(key);
      maybeEstimate();
    });

    function setupAddressSearch(inputId, suggestionsId, pointKey) {
      const input = screen.querySelector(`#${inputId}`);
      const suggestions = screen.querySelector(`#${suggestionsId}`);
      let debounceTimer;
      input.addEventListener('input', () => {
        clearTimeout(debounceTimer);
        const query = input.value.trim();
        if (query.length < 3) {
          suggestions.style.display = 'none';
          return;
        }
        debounceTimer = setTimeout(async () => {
          try {
            const res = await fetch(
              `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(query)}.json?access_token=${MAPBOX_TOKEN}&limit=5`
            );
            const body = await res.json();
            const features = body.features || [];
            suggestions.innerHTML = features
              .map(
                (f, i) =>
                  `<div class="suggestion-item" data-index="${i}">${f.place_name}</div>`
              )
              .join('');
            suggestions.style.display = features.length ? 'block' : 'none';
            suggestions.dataset.features = JSON.stringify(
              features.map((f) => ({ label: f.place_name, lat: f.center[1], lng: f.center[0] }))
            );
          } catch {
            suggestions.style.display = 'none';
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
        suggestions.style.display = 'none';
        maybeEstimate();
      });
    }
    setupAddressSearch('pickup-search', 'pickup-suggestions', 'pickup');
    setupAddressSearch('dropoff-search', 'dropoff-suggestions', 'dropoff');

    screen.querySelector('#cargo-type').addEventListener('change', maybeEstimate);

    async function maybeEstimate() {
      if (!points.pickup || !points.dropoff) return;
      const cargoType = screen.querySelector('#cargo-type').value;
      const query = new URLSearchParams({
        cargoType,
        pickupLat: String(points.pickup.lat),
        pickupLng: String(points.pickup.lng),
        dropoffLat: String(points.dropoff.lat),
        dropoffLng: String(points.dropoff.lng),
      });
      for (const key of requiredFeatures) query.set(key, 'true');
      try {
        const result = await api(`/api/cargo/estimate?${query.toString()}`);
        screen.querySelector('#price').value = Math.round(result.suggestedPrice);
      } catch {
        // Non-fatal — the shipper can still enter a price manually.
      }
    }

    screen.querySelector('#submit-btn').addEventListener('click', async () => {
      if (!points.pickup || !points.dropoff) {
        toast(t('genericError'));
        return;
      }
      const price = Number(screen.querySelector('#price').value);
      if (!price || price <= 0) {
        toast(t('genericError'));
        return;
      }
      const btn = screen.querySelector('#submit-btn');
      btn.disabled = true;
      try {
        await api('/api/cargo', {
          method: 'POST',
          body: JSON.stringify({
            cargoType: screen.querySelector('#cargo-type').value,
            description: screen.querySelector('#description').value.trim() || null,
            pickup: points.pickup,
            dropoff: points.dropoff,
            price,
            requiredFeatures: Object.fromEntries(FEATURES.map(([key]) => [key, requiredFeatures.has(key)])),
          }),
        });
        toast(t('posted'));
        renderShipperHome();
      } catch (err) {
        toast(err.message);
        btn.disabled = false;
      }
    });
  }

  boot();
})();
