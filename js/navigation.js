function showLanding() {
    document.getElementById('detailPage').classList.add('hidden');
    document.getElementById('landingPage').classList.remove('hidden');
    window.scrollTo(0, 0);
}

// ROZWIJANIE I ZWIJANIE KREATORA FILTRÓW
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

// ASYNCHRONICZNA OBSŁUGA AGENTA AI
async function generateAiTrip() {
    const placeholder = document.getElementById('creator-placeholder');
    const loader = document.getElementById('creator-loader');

    // 1. Włącz animację ładowania
    if (placeholder) placeholder.classList.add('hidden');
    if (loader) loader.classList.remove('hidden');

    // 2. Zbierz dane z filtrów, aby przekazać je Agentowi
    const climate = document.getElementById('filter-climate').value;
    const budget = document.getElementById('filter-budget').value;
    const duration = document.getElementById('filter-duration').value;
    const transport = document.getElementById('filter-transport').value;
    const difficulty = document.querySelector('input[name="difficulty"]:checked').value;

    try {
        // 3. Połączenie z darmową funkcją backendową Vercela (Serverless API)
        const response = await fetch('/api/generate-trip', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ climate, budget, duration, transport, difficulty })
        });

        if (!response.ok) throw new Error("Błąd podczas generowania przez Agenta");

        const generatedTrip = await response.json();

        // 4. Bezpośrednie wstrzyknięcie danych od Agenta do globalnego systemu i otwarcie podglądu!
        tripsData[generatedTrip.id] = generatedTrip; 
        showDetail(generatedTrip.id);

    } catch (error) {
        console.error("Agent AI napotkał problem:", error);
        alert("Wystąpił problem z połączeniem z Agentem AI. Spróbuj ponownie!");
    } finally {
        // 5. Przywróć stan wyjściowy boksu po zakończeniu pracy
        if (placeholder) placeholder.classList.remove('hidden');
        if (loader) loader.classList.add('hidden');
    }
}

function showDetail(tripId) {
    const trip = tripsData[tripId];
    if (!trip) {
        console.error("Nie znaleziono wycieczki o ID:", tripId);
        return;
    }

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
        if (dotEl) dotEl.style.display = "none";
    }

    const mapPathElement = document.getElementById('map-path');
    if (mapPathElement && trip.mapPath) {
        mapPathElement.setAttribute('d', trip.mapPath);
    }

    const startDot = document.getElementById('start-dot');
    const startDotInner = document.getElementById('start-dot-inner');
    const startText = document.getElementById('start-text');
    
    if (trip.startCy) {
        if (startDot) startDot.setAttribute('cy', trip.startCy);
        if (startDotInner) startDotInner.setAttribute('inner-cy', trip.startCy);
        if (startText) {
            startText.setAttribute('x', 60); 
            startText.setAttribute('y', trip.startCy - 15); 
        }
    }

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
                if (label.cx) dotElement.setAttribute('cx', label.cx);
                if (label.cy) {
                    dotElement.setAttribute('cy', label.cy);
                    if (pointElement) {
                        pointElement.setAttribute('x', label.cx);
                        pointElement.setAttribute('y', label.cy - 16); 
                    }
                }
                if (label.info) dotElement.setAttribute('data-info', label.info);
            }
        });
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

// TOOLTIPY
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