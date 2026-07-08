
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

// ASYNCHRONICZNA OBSŁUGA AGENTA AI (GEMINI)
async function generateAiTrip() {
    const placeholder = document.getElementById('creator-placeholder');
    const loader = document.getElementById('creator-loader');

    // 1. Włączenie ekranu ładowania (Loader)
    if (placeholder) placeholder.classList.add('hidden');
    if (loader) loader.classList.remove('hidden');

    // 2. Pobranie aktualnie wybranych wartości z filtrów
    const climate = document.getElementById('filter-climate').value;
    const budget = document.getElementById('filter-budget').value;
    const duration = document.getElementById('filter-duration').value;
    const transport = document.getElementById('filter-transport').value;
    const difficulty = document.querySelector('input[name="difficulty"]:checked').value;

    try {
        // 3. Wysłanie filtrów do naszej funkcji serwerowej na Vercelu
        const response = await fetch('/api/generate-trip', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ climate, budget, duration, transport, difficulty })
        });

        if (!response.ok) throw new Error("Błąd podczas generowania przez Agenta");

        const generatedTrip = await response.json();

        // 4. Wstrzyknięcie dynamicznych danych do pamięci aplikacji i otwarcie podglądu
        tripsData[generatedTrip.id] = generatedTrip; 
        showDetail(generatedTrip.id);

    } catch (error) {
        console.error("Agent Gemini napotkał problem:", error);
        alert("Wystąpił problem z połączeniem z Agentem AI. Spróbuj ponownie!");
    } finally {
        // 5. Przywrócenie pierwotnego stanu filtrów po zakończeniu ładowania
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

    // 1. USTAWIANIE DYNAMICZNEGO OBRAZKA W TLE MAPY
    const mapContainer = document.getElementById('map-container');
    if (mapContainer && trip.bgImage) {
        mapContainer.style.backgroundImage = `url('${trip.bgImage}')`;
        mapContainer.style.backgroundSize = 'cover';
        mapContainer.style.backgroundPosition = 'center';
    }

    // 2. WYRESETOWANIE I UKRYCIE WSZYSTKICH 6 KROPEK NA SZABLONIE MAPY
    for (let i = 1; i <= 6; i++) {
        const el = document.getElementById(`map-point-${i}`);
        const dotEl = document.getElementById(`dot-${i}`);
        if (el) el.textContent = ""; 
        if (dotEl) dotEl.style.display = "none";
    }

    // 3. USTAWIENIE PUNKTU STARTOWEGO (WROCŁAW GŁÓWNY) NA SZTYWNO NA POCZĄTKU OSI
    const startDot = document.getElementById('start-dot');
    const startDotInner = document.getElementById('start-dot-inner');
    const startText = document.getElementById('start-text');
    
    if (startDot) startDot.setAttribute('cx', 60);
    if (startDot) startDot.setAttribute('cy', 200);
    if (startDotInner) startDotInner.setAttribute('cx', 60);
    if (startDotInner) startDotInner.setAttribute('cy', 200);
    if (startText) {
        startText.setAttribute('x', 60); 
        startText.setAttribute('y', 180); // Napis nad kropką startową
    }

    // 4. GENEROWANIE KRZYWEJ ŚCIEŻKI SVG NA PODSTAWIE KOORDYNATÓW OD GEMINI
    let pathD = "M 60 200"; // Start trasy w punkcie Wrocławia (60, 200)

    if (trip.mapLabels && trip.mapLabels.length > 0) {
        trip.mapLabels.forEach((label, index) => {
            const pointElement = document.getElementById(`map-point-${index + 1}`);
            const dotElement = document.getElementById(`dot-${index + 1}`);

            // Jeśli element istnieje w strukturze HTML, aktywujemy go i pozycjonujemy
            if (dotElement && pointElement) {
                dotElement.style.display = "block";
                dotElement.setAttribute('cx', label.cx);
                dotElement.setAttribute('cy', label.cy);
                
                // Ustawianie napisu nad wyznaczoną kropką
                pointElement.textContent = label.text || label.label;
                pointElement.setAttribute('x', label.cx);
                pointElement.setAttribute('y', label.cy - 16); 
                
                if (label.info) dotElement.setAttribute('data-info', label.info);

                // Matematyczne wyliczanie gładkich łuków (Cubic Bezier) pomiędzy punktami
                const prevX = index === 0 ? 60 : trip.mapLabels[index - 1].cx;
                const prevY = index === 0 ? 200 : trip.mapLabels[index - 1].cy;
                const cpX1 = prevX + (label.cx - prevX) / 2;
                const cpX2 = prevX + (label.cx - prevX) / 2;
                
                pathD += ` C ${cpX1} ${prevY}, ${cpX2} ${label.cy}, ${label.cx} ${label.cy}`;
            }
        });
    }

    // Wstrzyknięcie gotowego kodu rysującego gładką linię szlaku
    const mapPathElement = document.getElementById('map-path');
    if (mapPathElement) {
        mapPathElement.setAttribute('d', pathD);
    }

    // 5. PRZEKAZANIE DANYCH DO SYSTEMU RENDEROWANIA (js/render.js)
    timelineData = trip.timeline;
    attractionsData = trip.attractions;
    budgetItems = trip.budget;
    practicalData = trip.practical;

    // Podstawienie nagłówków tekstowych podstrony
    document.querySelector('#detailPage h1').innerText = trip.city;
    document.querySelector('#detailPage .text-gray-400').innerHTML = 
        `<i data-lucide="map-pin" class="w-3 h-3"></i> ${trip.distance}`;
    
    // Wstrzykiwanie statystyk głównych kafelków
    const priceEl = document.querySelector('#detailPage .trip-price-val');
    const durationEl = document.querySelector('#detailPage .trip-duration-val');
    const transportEl = document.querySelector('#detailPage .trip-transport-val');

    if (priceEl) priceEl.innerText = trip.price;
    if (durationEl) durationEl.innerText = trip.duration;
    if (transportEl) transportEl.innerText = trip.transport;

    // 6. URUCHOMIENIE RENDEROWANIA UKŁADU STRONY I PRZEŁĄCZENIE WIDOKU
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

// DRUKOWANIE / EKSPORT DO STRUKTURY PDF
function downloadTripPDF() {
    window.print();
}