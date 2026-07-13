// js/navigation.js

// --- CACHE WYGENEROWANYCH WYCIECZEK ---
const TRIP_CACHE_KEY = 'naspontanie_trip_cache';
const CACHE_TTL_MS = 1000 * 60 * 60 * 24 * 7; // 7 dni ważności cache'a

// Prosty, deterministyczny hash stringa (wystarczający do kluczy cache, nie do kryptografii)
function hashFilters(filters) {
    const str = JSON.stringify(filters, Object.keys(filters).sort()); // sortujemy klucze, żeby kolejność pól nie zmieniała hasha
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
        hash = (hash << 5) - hash + str.charCodeAt(i);
        hash |= 0; // konwersja do 32-bit int
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

    // 1. SPRAWDZAMY CACHE PRZED WYWOŁANIEM API
    const cachedTrip = getCachedTrip(filters);
    if (cachedTrip) {
        // Krótkie opóźnienie kosmetyczne, żeby UX nie wyglądał na "zamrożony" (opcjonalne)
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

        // 2. ZAPISUJEMY WYNIK DO CACHE'A PO UDANYM WYGENEROWANIU
        setCachedTrip(filters, generatedTrip);

        tripsData[generatedTrip.id] = generatedTrip;
        showDetail(generatedTrip.id);

    } catch (error) {
        console.error("Agent Gemini napotkał problem:", error);
        alert("Wystąpił problem z połączeniem z Agentem AI. Spróbuj ponownie!");
    } finally {
        // BUG FIX: było placeholder.remove('hidden') — to USUWAŁO element ze strony!
        if (placeholder) placeholder.classList.remove('hidden');
        if (loader) loader.classList.add('hidden');
    }
}

// (reszta pliku — showDetail, tooltipy, downloadTripPDF — bez zmian)