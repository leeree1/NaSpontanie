function showLanding() {
    document.getElementById('detailPage').classList.add('hidden');
    document.getElementById('landingPage').classList.remove('hidden');
    window.scrollTo(0, 0);
}

function showDetail(tripId) {
    // 1. Pobierz dane miasta
    const trip = tripsData[tripId];
    if (!trip) {
        console.error("Nie znaleziono wycieczki o ID:", tripId);
        return;
    }

    // 1. DYNAMICZNE TŁO MAPY
    const mapContainer = document.getElementById('map-container');
    if (mapContainer && trip.bgImage) {
        mapContainer.style.backgroundImage = `url('${trip.bgImage}')`;
        mapContainer.style.backgroundSize = 'cover';
        mapContainer.style.backgroundPosition = 'center';
    }

    // Czyszczenie starych punktów i chowanie kropek na starcie (od 1 do 7)
    for (let i = 1; i <= 7; i++) {
        const el = document.getElementById(`map-point-${i}`);
        const dotEl = document.getElementById(`dot-${i}`);
        if (el) el.textContent = ""; 
        if (dotEl) dotEl.style.display = "none";
    }

    // DYNAMICZNA ZMIANA KSZTAŁTU ZIELONEJ OSI (LINII TRASY)
    const mapPathElement = document.getElementById('map-path');
    if (mapPathElement && trip.mapPath) {
        mapPathElement.setAttribute('d', trip.mapPath);
    }

    // DYNAMICZNE PRZESUWANIE PUNKTU STARTOWEGO WROCŁAWIA (NA NIEBO LUB DACHY)
    const startDot = document.getElementById('start-dot');
    const startDotInner = document.getElementById('start-dot-inner');
    const startText = document.getElementById('start-text');
    
    if (trip.startCy) {
        if (startDot) startDot.setAttribute('cy', trip.startCy);
        if (startDotInner) startDotInner.setAttribute('cy', trip.startCy);
        if (startText) {
            startText.setAttribute('x', 60); // Środek kropki startowej
            startText.setAttribute('y', trip.startCy - 15); // Napis 15px nad kropką startową
        }
    }

    // 2. WYPEŁNIANIE MAPY NAZWAMI, POZYCJAMI I OPISAMI (TOOLTIP)
    if (trip.mapLabels) {
        trip.mapLabels.forEach((label, index) => {
            const pointElement = document.getElementById(`map-point-${index + 1}`);
            const dotElement = document.getElementById(`dot-${index + 1}`);

            if (pointElement) {
                pointElement.textContent = label.text;
                pointElement.setAttribute('text-anchor', 'middle');
            }

            if (dotElement) {
                dotElement.style.display = "block";
                
                // Dynamiczne ustawianie pozycji kropki na mapie na podstawie cx i cy
                if (label.cx) dotElement.setAttribute('cx', label.cx);
                if (label.cy) {
                    dotElement.setAttribute('cy', label.cy);
                    
                    // Przesuwamy tekst razem z kropką, żeby nie został w starym miejscu
                    if (pointElement) {
                        pointElement.setAttribute('x', label.cx);
                        pointElement.setAttribute('y', label.cy - 16); // Napis 16px nad kropką
                    }
                }
                
                // DYNAMICZNA ZMIANA TEKSTU W TOOLTIPIE:
                if (label.info) {
                    dotElement.setAttribute('data-info', label.info);
                }
            }
        });
    }

    // Dane globalne dla render.js
    timelineData = trip.timeline;
    attractionsData = trip.attractions;
    budgetItems = trip.budget;
    practicalData = trip.practical;

    // 3. Nagłówki w HTML bezpośrednio
    document.querySelector('#detailPage h1').innerText = trip.city;
    document.querySelector('#detailPage .text-gray-400').innerHTML = 
        `<i data-lucide="map-pin" class="w-3 h-3"></i> ${trip.distance}`;
    
    // NAPRAWIONE STATYSTYKI: Precyzyjne wstrzykiwanie danych po nowych klasach
    const priceEl = document.querySelector('#detailPage .trip-price-val');
    const durationEl = document.querySelector('#detailPage .trip-duration-val');
    const transportEl = document.querySelector('#detailPage .trip-transport-val');

    if (priceEl) priceEl.innerText = trip.price;
    if (durationEl) durationEl.innerText = trip.duration;
    if (transportEl) transportEl.innerText = trip.transport;

    // 4. Uruchom renderowanie i przełącz stronę
    renderDetail(trip);
    document.getElementById('landingPage').classList.add('hidden');
    document.getElementById('detailPage').classList.remove('hidden');
    window.scrollTo(0, 0);
}

// --- OBSŁUGA MAŁEGO OKNA (TOOLTIP) ---
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

// --- OBSŁUGA TOOLTIPÓW ---
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