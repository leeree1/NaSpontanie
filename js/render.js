// Render trip cards (Główna lista na landing page)
function renderCards(tripsToRender) {
    const grid = document.getElementById('tripsGrid');
    if (!grid) return;

    grid.innerHTML = tripsToRender.map(t => `
        <div onclick="showDetail('${t.id}')" class="cursor-pointer bg-white rounded-3xl p-6 shadow-sm border border-gray-100 hover:shadow-md transition-all fade-up">
            <div class="h-40 rounded-2xl mb-4 flex items-center justify-center" style="background-color: ${t.color}">
                <i data-lucide="${t.icon}" class="w-10 h-10 text-gray-700"></i>
            </div>
            <div class="flex justify-between items-start mb-2">
                <div>
                    <h3 class="font-bold text-lg text-dark">${t.city}</h3>
                    <p class="text-gray-500 text-sm">${t.title}</p>
                </div>
            </div>
            <div class="flex gap-2 mt-4">
                <span class="bg-gray-100 text-xs px-3 py-1 rounded-full font-medium">do ${t.budget} zł</span>
                <span class="bg-gray-100 text-xs px-3 py-1 rounded-full font-medium">${t.hours}h</span>
            </div>
        </div>
    `).join('');
    
    lucide.createIcons();
}

// Render detail sections (Widok szczegółów wycieczki)
function renderDetail() {
    // 1. Stars/Rating (Z bezpiecznikiem)
    const sc = document.getElementById('starsContainer');
    if (sc) {
        sc.innerHTML = Array.from({length:5}, (_,i) => 
            `<i data-lucide="star" class="w-4 h-4 ${i<4?'star-filled':'star-empty'}" ${i<4?'fill="currentColor"':''}></i>`
        ).join('');
    }

    // 2. Timeline (Plan dnia)
    const timelineContainer = document.getElementById('timeline');
    if (timelineContainer) {
        const colors = { transport:'#2563EB', walk:'#10B981', sight:'#FB923C', food:'#FACC15' };
        timelineContainer.innerHTML = timelineData.map((t,i) => `
            <div class="flex gap-4 items-start">
                <div class="flex flex-col items-center">
                    <div class="timeline-dot border-2" style="border-color:${colors[t.type]};background:${i===0?colors[t.type]:'white'}"></div>
                    ${i < timelineData.length - 1 ? '<div class="w-px flex-1 bg-gray-200" style="min-height:32px"></div>' : ''}
                </div>
                <div class="pb-5">
                    <div class="text-xs font-bold text-gray-400 mb-0.5">${t.time}</div>
                    <div class="text-sm font-medium">${t.label}</div>
                </div>
            </div>
        `).join('');
    }

    // 3. Attractions (Karty atrakcji - dodany 5-ty kolor)
    const attractionsContainer = document.getElementById('attractions');
    if (attractionsContainer) {
        const attrColors = ['#dbeafe','#fef9c3','#fce7f3','#e0f2fe','#f0fdf4'];
        attractionsContainer.innerHTML = attractionsData.map((a,i) => `
            <div class="bg-white rounded-2xl border border-gray-100 overflow-hidden hover:shadow-md transition-shadow">
                <div class="h-24 flex items-center justify-center" style="background:${attrColors[i % attrColors.length]}">
                    <i data-lucide="${a.icon}" class="w-8 h-8 text-gray-400 opacity-40"></i>
                </div>
                <div class="p-3.5">
                    <div class="font-semibold text-sm mb-1">${a.title || a.name}</div>
                    <div class="text-xs text-gray-500 leading-relaxed">${a.desc}</div>
                </div>
            </div>
        `).join('');
    }

    // 4. Budget (Z bezpiecznikiem)
    const budgetContainer = document.getElementById('budgetList');
    if (budgetContainer) {
        budgetContainer.innerHTML = budgetItems.map(b => `
            <div class="flex items-center justify-between">
                <div class="flex items-center gap-3">
                    <div class="w-8 h-8 bg-gray-50 rounded-xl flex items-center justify-center">
                        <i data-lucide="${b.icon || 'circle'}" class="w-4 h-4 text-gray-400"></i>
                    </div>
                    <span class="text-sm">${b.label}</span>
                </div>
                <span class="text-sm font-semibold">${b.amount || b.value}</span>
            </div>
        `).join('');
    }

    // 5. Practical Info (Z bezpiecznikiem)
    const practicalContainer = document.getElementById('practicalInfo');
    if (practicalContainer) {
        practicalContainer.innerHTML = practicalData.map(p => `
            <div class="bg-white rounded-xl border border-gray-100 p-4 flex items-start gap-3">
                <div class="w-8 h-8 bg-gray-50 rounded-xl flex items-center justify-center flex-shrink-0">
                    <i data-lucide="${p.icon}" class="w-4 h-4 text-gray-400"></i>
                </div>
                <div>
                    <div class="text-xs text-gray-400 font-medium">${p.label || p.title}</div>
                    <div class="text-sm font-medium">${p.value || p.desc}</div>
                </div>
            </div>
        `).join('');
    }

    // 6. Reviews (Z bezpiecznikiem - możesz to bezpiecznie usunąć z HTML)
    const reviewsContainer = document.getElementById('reviews');
    if (reviewsContainer && typeof reviewsData !== 'undefined') {
        reviewsContainer.innerHTML = reviewsData.map(r => `
            <div class="bg-white rounded-2xl border border-gray-100 p-4">
                <div class="flex items-center justify-between mb-2">
                    <div class="flex items-center gap-2">
                        <div class="w-7 h-7 bg-primary/10 rounded-full flex items-center justify-center text-xs font-bold text-primary">${r.name[0]}</div>
                        <span class="text-sm font-semibold">${r.name}</span>
                    </div>
                    <span class="text-[10px] text-gray-400">${r.time}</span>
                </div>
                <div class="flex gap-0.5 mb-2">${Array.from({length:5},(_,i)=>`<i data-lucide="star" class="w-3 h-3 ${i<r.rating?'star-filled':'star-empty'}" ${i<r.rating?'fill="currentColor"':''}></i>`).join('')}</div>
                <p class="text-sm text-gray-600 leading-relaxed">${r.text}</p>
            </div>
        `).join('');
    }

    // Odświeżenie ikon na końcu
    lucide.createIcons();
}

// Obsługa animacji fade-up
const observer = new IntersectionObserver((entries) => {
  entries.forEach(e => { 
      if (e.isIntersecting) { 
          e.target.classList.add('visible'); 
          observer.unobserve(e.target); 
      }
  });
}, { threshold: 0.1 });

// Funkcja startowa
async function initApp() {
    // Sprawdzamy czy MockAPI istnieje (zależność od sdk.js)
    if (typeof MockAPI !== 'undefined') {
        const data = await MockAPI.fetchTrips();
        renderCards(data);
    }
    
    // Renderujemy detale (dane z data.js)
    renderDetail();
    
    // Odpalamy obserwatora animacji
    document.querySelectorAll('.fade-up').forEach(el => observer.observe(el));
}

// Uruchomienie przy starcie
window.onload = initApp;