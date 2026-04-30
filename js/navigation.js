function showLanding() {
    document.getElementById('detailPage').classList.add('hidden');
    document.getElementById('landingPage').classList.remove('hidden');
    window.scrollTo(0, 0);
}

function showDetail(tripId) {
    // 1. Pobierz dane miasta
    const trip = tripsData[tripId];
    if (!trip) return;

    // 2. dane globalne dla render.js
    timelineData = trip.timeline;
    attractionsData = trip.attractions;
    budgetItems = trip.budget;
    practicalData = trip.practical;

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