// js/navigation.js

// --- CACHE WYGENEROWANYCH WYCIECZEK ---
const TRIP_CACHE_KEY = 'naspontanie_trip_cache';
const CACHE_TTL_MS = 1000 * 60 * 60 * 24 * 7; // 7 dni ważności cache'a

function hashFilters(filters) {
    const str = JSON.stringify(filters, Object.keys(filters).sort());
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
        hash = (hash << 5) - hash + str.charCodeAt(i);
        hash |= 0;
    }
    return 'trip_' + Math.abs(hash);
}

function loadCache() {
    try {
        const raw = localStorage.getItem(TRIP_CACHE_KEY);
        return raw ? JSON.parse(raw) : {};
    } catch (e) {
        console.warn('Nie udało się odczytać cache wycieczek:', e);
        return {};
    }
}

function saveCache(cache) {
    try {
        localStorage.setItem(TRIP_CACHE_KEY, JSON.stringify(cache));
    } catch (e) {
        console.warn('Nie udało się zapisać cache wycieczek (localStorage pełny?):', e);
    }
}

function getCachedTrip(filters) {
    const cache = loadCache();
    const key = hashFilters(filters);
    const entry = cache[key];
    if (!entry) return null;

    const isExpired = Date.now() - entry.timestamp > CACHE_TTL_MS;
    if (isExpired) {
        delete cache[key];
        saveCache(cache);
        return null;
    }
    return entry.trip;
}

function setCachedTrip(filters, trip) {
    const cache = loadCache();
    const key = hashFilters(filters);
    cache[key] = { trip, timestamp: Date.now() };
    saveCache(cache);
}

// POWRÓT NA STRONĘ GŁÓWNĄ (LANDING PAGE)
function showLanding() {
    document.getElementById('detailPage').classList.add('hidden');
    document.getElementById('landingPage').classList.remove('hidden');
    window.scrollTo(0, 0);
}

// ROZWIJANIE I ZWIJANIE PANELU KREATORA FILTRÓW
function toggleCreator() {
    const creatorSection = document.getElementById('creator-section');
    if (creatorSection) {
        creatorSection.classList.toggle('hidden');
        if (!creatorSection.classList.contains('hidden')) {
            creatorSection.scrollIntoView({ behavior: 'smooth' });
            if (typeof lucide !== 'undefined') lucide.createIcons();
        }
    }
}

// ASYNCHRONICZNA OBSŁUGA AGENTA AI (GEMINI) — Z CACHE'EM
async function generateAiTrip() {
    const placeholder = document.getElementById('creator-placeholder');
    const loader = document.getElementById('creator-loader');
    const loaderText = loader ? loader.querySelector('p') : null;

    if (placeholder) placeholder.classList.add('hidden');
    if (loader) loader.classList.remove('hidden');

    const filters = {
        climate: document.getElementById('filter-climate').value,
        budget: document.getElementById('filter-budget').value,
        duration: document.getElementById('filter-duration').value,
        transport: document.getElementById('filter-transport').value,
        difficulty: document.querySelector('input[name="difficulty"]:checked').value
    };

    const cachedTrip = getCachedTrip(filters);
    if (cachedTrip) {
        if (loaderText) loaderText.textContent = "Znaleziono zapisany plan pasujący do Twoich filtrów...";
        tripsData[cachedTrip.id] = cachedTrip;
        setTimeout(() => {
            showDetail(cachedTrip.id);
            if (placeholder) placeholder.classList.remove('hidden');
            if (loader) loader.classList.add('hidden');
        }, 300);
        return;
    }

    try {
        const response = await fetch('/api/generate-trip', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(filters)
        });

        if (!response.ok) throw new Error("Błąd podczas generowania przez Agenta");

        const generatedTrip = await response.json();

        setCachedTrip(filters, generatedTrip);

        tripsData[generatedTrip.id] = generatedTrip;
        showDetail(generatedTrip.id);

    } catch (error) {
        console.error("Agent Gemini napotkał problem:", error);
        alert("Wystąpił problem z połączeniem z Agentem AI. Spróbuj ponownie!");
    } finally {
        if (placeholder) placeholder.classList.remove('hidden');
        if (loader) loader.classList.add('hidden');
    }
}

// WYŚWIETLANIE SZCZEGÓŁÓW WYCIECZKI I AUTORSKIE GENEROWANIE MAPY
function showDetail(tripId) {
    const trip = tripsData[tripId];
    if (!trip) {
        console.error("Nie znaleziono wycieczki o ID:", tripId);
        return;
    }

    const bgImageElement = document.getElementById('map-bg-image');
    if (bgImageElement) {
        const cityName = trip.city || "poland";

        const searchCityQuery = encodeURIComponent(cityName.toLowerCase()
            .replace(/ł/g, 'l').replace(/[ąά]/g, 'a').replace(/ę/g, 'e')
            .replace(/ć/g, 'c').replace(/ń/g, 'n').replace(/ó/g, 'o')
            .replace(/ś/g, 's').replace(/[źż]/g, 'z')
            .trim());

        let bgImgUrl = trip.bgImage;
        if (!bgImgUrl || bgImgUrl.includes('photo-X') || bgImgUrl.includes('photo-1506744038136-46273834b3fb')) {
            bgImgUrl = `https://images.unsplash.com/photo-1601058440129-e43524b69311?q=80&w=1200&auto=format&fit=crop&sig=${searchCityQuery}`;
        }

        bgImageElement.onerror = function() {
            this.onerror = null;
            this.src = 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=1200&auto=format&fit=crop';
        };

        bgImageElement.src = bgImgUrl;
    }

    for (let i = 1; i <= 6; i++) {
        const el = document.getElementById(`map-point-${i}`);
        const dotEl = document.getElementById(`dot-${i}`);
        if (el) el.textContent = "";
        if (dotEl) dotEl.style.display = "none";
    }

    const startDot = document.getElementById('start-dot');
    const startDotInner = document.getElementById('start-dot-inner');
    const startText = document.getElementById('start-text');

    if (startText) {
        startText.setAttribute('x', 60);
        startText.setAttribute('y', 180);

        const transportSelect = document.getElementById('filter-transport');
        const selectedFilterText = transportSelect.options[transportSelect.selectedIndex].text;
        const fallbackStart = selectedFilterText.includes(" ze ") ? selectedFilterText.split(" ze ")[1] : "Wrocław";

        startText.textContent = trip.startLocation || fallbackStart;
    }

    if (startDot) startDot.setAttribute('cx', 60);
    if (startDot) startDot.setAttribute('cy', 200);
    if (startDotInner) startDotInner.setAttribute('cx', 60);
    if (startDotInner) startDotInner.setAttribute('cy', 200);

    let pathD = "M 60 200";

    if (trip.mapLabels && trip.mapLabels.length > 0) {
        trip.mapLabels.forEach((label, index) => {
            const pointElement = document.getElementById(`map-point-${index + 1}`);
            const dotElement = document.getElementById(`dot-${index + 1}`);

            if (dotElement && pointElement) {
                dotElement.style.display = "block";
                dotElement.setAttribute('cx', label.cx);
                dotElement.setAttribute('cy', label.cy);

                pointElement.textContent = label.text || label.label;
                pointElement.setAttribute('x', label.cx);
                pointElement.setAttribute('y', label.cy - 16);

                if (label.info) dotElement.setAttribute('data-info', label.info);

                const prevX = index === 0 ? 60 : trip.mapLabels[index - 1].cx;
                const prevY = index === 0 ? 200 : trip.mapLabels[index - 1].cy;
                const cpX1 = prevX + (label.cx - prevX) / 2;
                const cpX2 = prevX + (label.cx - prevX) / 2;

                pathD += ` C ${cpX1} ${prevY}, ${cpX2} ${label.cy}, ${label.cx} ${label.cy}`;
            }
        });
    }

    const mapPathElement = document.getElementById('map-path');
    if (mapPathElement) {
        mapPathElement.setAttribute('d', pathD);
    }

    timelineData = trip.timeline;
    attractionsData = trip.attractions;
    budgetItems = trip.budget;
    practicalData = trip.practical;

    document.querySelector('#detailPage h1').innerText = trip.city;
    document.querySelector('#detailPage .text-gray-400').innerHTML =
        `<i data-lucide="map-pin" class="w-3 h-3"></i> ${trip.distance}`;

    const priceEl = document.querySelector('#detailPage .trip-price-val');
    const durationEl = document.querySelector('#detailPage .trip-duration-val');
    const transportEl = document.querySelector('#detailPage .trip-transport-val');

    if (priceEl) priceEl.innerText = trip.price;
    if (durationEl) durationEl.innerText = trip.duration;
    if (transportEl) transportEl.innerText = trip.transport;

    renderDetail(trip);
    document.getElementById('landingPage').classList.add('hidden');
    document.getElementById('detailPage').classList.remove('hidden');
    window.scrollTo(0, 0);
}

// --- SYSTEM OBSŁUGI AKTYWNYCH TOOLTIPÓW NA MAPIE ---
document.addEventListener('mouseover', (e) => {
    if (e.target.classList.contains('map-dot')) {
        const tooltip = document.getElementById('map-tooltip');
        const info = e.target.getAttribute('data-info');
        if (info) {
            tooltip.innerText = info;
            tooltip.classList.remove('hidden');
        }
    }
});

document.addEventListener('mousemove', (e) => {
    const tooltip = document.getElementById('map-tooltip');
    if (!tooltip.classList.contains('hidden')) {
        tooltip.style.left = (e.clientX + 15) + 'px';
        tooltip.style.top = (e.clientY + 15) + 'px';
    }
});

document.addEventListener('mouseout', (e) => {
    if (e.target.classList.contains('map-dot')) {
        document.getElementById('map-tooltip').classList.add('hidden');
    }
});

function downloadTripPDF() {
    window.print();
}