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

    for (let i = 1; i <= 7; i++) {
        const el = document.getElementById(`map-point-${i}`);
        const dotEl = document.getElementById(`dot-${i}`);
        if (el) el.textContent = ""; 
        if (dotEl) dotEl.style.display = "none"; // chowamy kropki, jeśli nie ma dla nich nazw

    }

    // 2. WYPEŁNIANIE MAPY NAZWAMI I POKAZYWANIE KROPEK
    if (trip.mapLabels) {
        trip.mapLabels.forEach((label, index) => {
            const el = document.getElementById(`map-point-${index + 1}`);
            const dotEl = document.getElementById(`dot-${index + 1}`);
            if (el) el.textContent = label;
            if (dotEl) dotEl.style.display = "block";
        });
    }

    // 2. dane globalne dla render.js
    timelineData = trip.timeline;
    attractionsData = trip.attractions;
    budgetItems = trip.budget;
    practicalData = trip.practical;

    // nazwy z mapLabels do punktów na mapie 
    if (trip.mapLabels) {
        trip.mapLabels.forEach((label, index) => {
            const pointElement = document.getElementById(`map-point-${index + 1}`);
            if (pointElement) {
                pointElement.textContent = label;
            }
        });
    }

    // 3. nagłówki w HTML bezpośrednio
    document.querySelector('#detailPage h1').innerText = trip.city;
    document.querySelector('#detailPage .text-gray-400').innerHTML = 
        `<i data-lucide="map-pin" class="w-3 h-3"></i> ${trip.distance}`;
    
    // Statystyki (120zł, 7h, transport)
    const stats = document.querySelectorAll('#detailPage .font-bold.text-primary, #detailPage .text-dark.font-heading');
    if(stats[0]) stats[0].innerText = trip.price;
    if(stats[1]) stats[1].innerText = trip.duration;

    // 4. Uruchom renderowanie i przełącz stronę
    renderDetail();
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