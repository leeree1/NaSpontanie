function renderDetail(trip) {
    // 1. RENDEROWANIE OSI CZASU (TIMELINE)
    const timelineContainer = document.getElementById('timeline');
    if (timelineContainer && trip.timeline) {
        timelineContainer.innerHTML = ''; // Czyszczenie przed ponownym renderem
        
        trip.timeline.forEach((item, index) => {
            // Ustalamy kolor kropki na osi: pierwsza i ostatnia są pełne, reszta pusta w środku
            const isEdge = index === 0 || index === trip.timeline.length - 1;
            const dotClass = isEdge 
                ? 'bg-blue-500 border-blue-500' 
                : 'bg-white border-orange-500';

            timelineContainer.innerHTML += `
                <div class="flex gap-4 relative pb-6">
                    ${index !== trip.timeline.length - 1 ? '<div class="absolute left-[11px] top-6 bottom-0 w-0.5 bg-gray-100"></div>' : ''}
                    
                    <div class="w-6 h-6 rounded-full border-2 ${dotClass} z-10 flex-shrink-0 mt-0.5"></div>
                    
                    <div class="flex flex-col">
                        <span class="text-xs font-bold text-gray-400">${item.time}</span>
                        <span class="text-sm font-medium text-dark mt-0.5">${item.label}</span>
                    </div>
                </div>
            `;
        });
    }

    // 2. RENDEROWANIE KART ATRAKCJI
    const attractionsContainer = document.getElementById('attractions');
    if (attractionsContainer && trip.attractions) {
        attractionsContainer.innerHTML = '';
        
        trip.attractions.forEach(attraction => {
            attractionsContainer.innerHTML += `
                <div class="bg-white rounded-2xl border border-gray-100 overflow-hidden shadow-sm flex flex-col">
                    <div class="h-28 bg-slate-50 flex items-center justify-center border-b border-gray-50 text-slate-400">
                        <i data-lucide="${attraction.icon || 'map-pin'}" class="w-10 h-10"></i>
                    </div>
                    <div class="p-4 flex-1 flex flex-col justify-between">
                        <div>
                            <h3 class="font-bold text-sm text-dark mb-1">${attraction.title}</h3>
                            <p class="text-xs text-gray-500 leading-relaxed">${attraction.desc}</p>
                        </div>
                    </div>
                </div>
            `;
        });
    }

    // 3. RENDEROWANIE ROZPISKI BUDŻETU
    const budgetListContainer = document.getElementById('budgetList');
    if (budgetListContainer && trip.budget) {
        budgetListContainer.innerHTML = '';
        
        trip.budget.forEach(item => {
            budgetListContainer.innerHTML += `
                <div class="flex justify-between items-center text-sm mb-3 last:mb-0">
                    <div class="flex items-center gap-3">
                        <div class="w-8 h-8 rounded-full bg-gray-50 flex items-center justify-center text-gray-400">
                            <i data-lucide="${item.icon || 'circle'}" class="w-4 h-4"></i>
                        </div>
                        <span class="text-gray-700">${item.label}</span>
                    </div>
                    <span class="font-semibold text-dark">${item.amount}</span>
                </div>
            `;
        });
        
        // ZAKODOWANE WSTRZYKNIĘCIE SUMY ŁĄCZNEJ DO KOŃCOWEGO SPANA
        const totalBudgetEl = document.querySelector('.trip-total-budget');
        if (totalBudgetEl) {
            totalBudgetEl.innerText = trip.price; // Pobiera np. "90 zł" bezpośrednio z bazy danych wycieczki
        }
    }

    // 4. RENDEROWANIE INFORMACJI PRAKTYCZNYCH
    const practicalContainer = document.getElementById('practicalInfo');
    if (practicalContainer && trip.practical) {
        practicalContainer.innerHTML = '';
        
        trip.practical.forEach(info => {
            practicalContainer.innerHTML += `
                <div class="bg-white rounded-2xl border border-gray-100 p-4 flex gap-3 items-start">
                    <div class="w-8 h-8 rounded-full bg-slate-50 flex items-center justify-center text-slate-400 flex-shrink-0">
                        <i data-lucide="${info.icon || 'info'}" class="w-4 h-4"></i>
                    </div>
                    <div>
                        <span class="block text-[10px] font-bold text-gray-400 uppercase tracking-wider mb-0.5">${info.label}</span>
                        <p class="text-xs font-medium text-dark leading-relaxed">${info.value}</p>
                    </div>
                </div>
            `;
        });
    }

    // 5. PONOWNE UTWORZENIE IKON LUCIDE
    // Ponieważ dodaliśmy nowe elementy do drzewa DOM w locie, musimy odświeżyć ikony Lucide
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }
}