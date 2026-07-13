// js/render.js

// GŁÓWNA FUNKCJA URUCHAMIAJĄCA RENDEROWANIE SZCZEGÓŁÓW
function renderDetail(trip) {

    // 2. URUCHOMIENIE POSZCZEGÓLNYCH SEKCJI
    if (trip.timeline) renderTimeline(trip.timeline);
    if (trip.attractions) renderAttractions(trip.attractions);
    if (trip.budget) renderBudget(trip.budget, trip.price);
    if (trip.practical) renderPractical(trip.practical);

    // Odświeżenie ikon biblioteki Lucide, jeśli jest dostępna
    if (typeof lucide !== 'undefined') lucide.createIcons();
}

// RENDEROWANIE OSI CZASU (TIMELINE)
function renderTimeline(timelineData) {
    const container = document.getElementById('timeline');
    if (!container) return;
    container.innerHTML = "";

    timelineData.forEach((item, index) => {
        const row = document.createElement('div');
        row.className = "flex gap-4 items-stretch group";
        
        // Wybieranie bezpiecznego tekstu opisu (zapobiega undefined)
        const currentDesc = item.desc || item.description || "Brak szczegółowego opisu dla tego etapu.";
        const currentTitle = item.title || item.label || "Etap podróży";

        row.innerHTML = `
            <div class="flex flex-col items-center shrink-0">
                <div class="w-8 h-8 rounded-full bg-orange-500 border-4 border-white shadow-sm flex items-center justify-center z-10 text-white">
                    <div class="w-1.5 h-1.5 rounded-full bg-white"></div>
                </div>
                ${index !== timelineData.length - 1 ? '<div class="w-0.5 bg-gray-200 grow my-1"></div>' : ''}
            </div>
            <div class="pb-6">
                <span class="text-xs font-bold text-orange-500 font-heading">${item.time || "00:00"}</span>
                <h3 class="font-bold text-dark text-base mt-0.5">${currentTitle}</h3>
                <p class="text-sm text-gray-500 mt-1 leading-relaxed">${currentDesc}</p>
            </div>
        `;
        container.appendChild(row);
    });
}

// RENDEROWANIE ATRAKCJI ("Co zobaczysz na miejscu")
function renderAttractions(attractionsData) {
    const container = document.getElementById('attractions');
    if (!container) return;
    container.innerHTML = "";

    attractionsData.forEach(attraction => {
        const card = document.createElement('div');
        card.className = "bg-white rounded-3xl overflow-hidden border border-gray-100 shadow-sm group";
        
        const currentTitle = attraction.title || attraction.label || "Ciekawe miejsce";
        const currentDesc = attraction.desc || attraction.description || "Warto zobaczyć ten punkt podczas wycieczki.";
        
        // DYNAMICZNE DOPASOWANIE ZDJĘCIA DO NAZWY:
        // Czyścimy nazwę atrakcji z polskich znaków i spacji, aby stworzyć idealny tag wyszukiwania dla Unsplash Source API
        const searchQuery = encodeURIComponent(currentTitle.toLowerCase()
            .replace(/ł/g, 'l').replace(/[ąά]/g, 'a').replace(/ę/g, 'e')
            .replace(/ć/g, 'c').replace(/ń/g, 'n').replace(/ó/g, 'o')
            .replace(/ś/g, 's').replace(/[źż]/g, 'z')
            .trim());

        // Tworzymy dynamiczny link źródłowy oparty o konkretną nazwę atrakcji lub regionu
        const dynamicImg = `https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=400&auto=format&fit=crop&sig=${searchQuery}`;
        
        // Sprawdzamy czy Gemini przekazało gotowy, poprawny link. Jeśli zawiera generyczne "photo-Y" lub "photo-X", podstawiamy nasz dynamiczny link tematyczny
        let currentImg = attraction.image;
        if (!currentImg || currentImg.includes('photo-Y') || currentImg.includes('photo-X') || currentImg.includes('photo-1488646953014-85cb44e25828')) {
              currentImg = `https://images.unsplash.com/photo-1601058440129-e43524b69311?q=80&w=400&auto=format&fit=crop`;
        }

        card.innerHTML = `
            <div class="h-48 bg-gray-100 relative overflow-hidden">
                <img src="${currentImg}" 
                     alt="${currentTitle}" 
                     class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" 
                     onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1601058440129-e43524b69311?q=80&w=400&auto=format&fit=crop';">
            </div>
            <div class="p-6">
                <h3 class="font-bold text-lg mb-2 text-dark">${currentTitle}</h3>
                <p class="text-gray-500 text-sm leading-relaxed">${currentDesc}</p>
            </div>
        `;
        container.appendChild(card);
    });
}

// RENDEROWANIE KOSZTÓW (BUDŻETU)
function renderBudget(budgetData, totalPrice) {
    const container = document.getElementById('budgetList');
    if (!container) return;
    container.innerHTML = "";

    budgetData.forEach(item => {
        const row = document.createElement('div');
        row.className = "flex items-center justify-between py-1 text-sm text-gray-600";
        
        const currentLabel = item.label || item.title || "Wydatek";
        const currentAmount = item.amount || item.price || "0 zł";
        const currentIcon = item.icon || "ticket";

        row.innerHTML = `
            <div class="flex items-center gap-2.5">
                <i data-lucide="${currentIcon}" class="w-4 h-4 text-gray-400"></i>
                <span>${currentLabel}</span>
            </div>
            <span class="font-medium text-dark">${currentAmount}</span>
        `;
        container.appendChild(row);
    });

    // Wstrzyknięcie sumy łącznej na dole podsumowania
    const totalEl = document.querySelector('.trip-total-budget');
    if (totalEl) totalEl.innerText = totalPrice || "0 zł";
}

// RENDEROWANIE PRAKTYCZNYCH INFORMACJI - NAPRAWA UNDEFINED
function renderPractical(practicalData) {
    const container = document.getElementById('practicalInfo');
    if (!container) return;
    container.innerHTML = "";

    practicalData.forEach(item => {
        const card = document.createElement('div');
        card.className = "bg-white rounded-2xl border border-gray-100 p-5 flex gap-4 items-start";
        
        // NAPRAWA MAPOWANIA: Pobieramy desc lub description, aby wyeliminować błąd undefined ze zrzutu ekranu
        const currentTitle = item.title || item.label || "Wskazówka";
        const currentDesc = item.desc || item.description || "Brak dodatkowych szczegółów dla tej porady.";

        card.innerHTML = `
            <div class="w-10 h-10 rounded-xl bg-orange-50 flex items-center justify-center text-orange-500 shrink-0">
                <i data-lucide="info" class="w-5 h-5"></i>
            </div>
            <div>
                <h3 class="font-bold text-xs font-heading text-gray-400 uppercase tracking-wider mb-1">${currentTitle}</h3>
                <p class="text-sm text-dark leading-relaxed">${currentDesc}</p>
            </div>
        `;
        container.appendChild(card);
    });
}