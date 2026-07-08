// api/generate-trip.js

export default async function handler(req, res) {
  // Akceptujemy tylko żądania typu POST
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Only POST allowed' });
  }

  const { climate, budget, duration, transport, difficulty } = req.body;
  const apiKey = process.env.GEMINI_API_KEY;

  // Walidacja obecności klucza API
  if (!apiKey) {
    return res.status(500).json({ message: "Brak klucza GEMINI_API_KEY w konfiguracji Vercela!" });
  }

  try {
    // Dynamiczny prompt wejściowy z parametrami wybranymi przez użytkownika
    const userPrompt = `Wygeneruj jednodniową, kompletną wycieczkę w Polsce pasującą do tych filtrów:
    - Kategoria/Klimat miejsca: ${climate} (góry, miasto lub natura)
    - Maksymalny budżet na jedną osobę: ${budget} PLN (wszystkie koszty muszą się w tym zmieścić!)
    - Czas trwania: ${duration} (krótki, średni lub intensywny cały dzień)
    - Środek transportu: ${transport} (pociąg/transport publiczny lub samochód)
    - Poziom trudności fizycznej: ${difficulty} (lajtowy spacer, średni wysiłek lub dla silnych/całodniowy wycisk)
    
    Wybierz konkretne, pasujące miasto, miejscowość lub region w Polsce (np. Karkonosze, Kotlina Kłodzka, Toruń, Dolina Baryczy itp.). 
    Stwórz autentyczny plan podróży dostosowany pod te wymagania.`;

    // Wywołanie oficjalnego, darmowego API Gemini 2.5 Flash
    const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: userPrompt }] }],
        generationConfig: { 
          responseMimeType: "application/json" // Wymuszenie na Google zwrotu w standardzie JSON
        },
        // Instrukcja systemowa, która programuje zachowanie Agenta i definiuje sztywne reguły
        systemInstruction: {
          parts: [{
            text: `Jesteś elitarnym agentem turystycznym i logistycznym aplikacji "NaSpontanie". 
            Twoim jedynym zadaniem jest generowanie gotowych, kompletnych planów jednodniowych wycieczek w formacie JSON.
            
            KRYTERIA LOGISTYCZNE:
            1. Wszystkie opisy, tytuły i porady muszą być w języku polskim.
            2. Budżet musi być realistyczny. Podaj ceny biletów, jedzenia i biletów wstępu pasujące do roku 2026.
            3. Linki w "bgImage" oraz "image" muszą być PRAWDZIWYMI, bezpośrednimi i działającymi adresami URL do pięknych zdjęć krajobrazowych z serwisu Unsplash (używaj słów kluczowych w tagach Unsplash, np. poland-mountains, wroclaw, tatra-mountains).
            
            KRYTERIA RYSOWANIA MAPY (BARDZO WAŻNE):
            - Punkt startowy trasy znajduje się zawsze na współrzędnych (cx: 60, cy: 200).
            - Tablica "mapLabels" musi zawierać od 3 do 5 punktów pośrednich (atrakcji).
            - Pierwszy punkt w tablicy musi zaczynać się w okolicach cx: 150-200.
            - Ostatni punkt w tablicy musi kończyć się dokładnie na cx: 740.
            - Każdy kolejny punkt musi mieć wartość "cx" WIĘKSZĄ od poprzedniego (ruch od lewej do prawej), aby linia mapy nie cofała się ani nie zapętlała! Wartości "cy" mogą się wahać między 100 a 300.
            
            Wymagany format wyjściowy to wyłącznie czysty obiekt JSON o poniższej strukturze (zduplikowałem klucze title/label oraz desc/description, aby zapobiec błędom undefined na froncie):
            {
              "id": "unikalny_id_wycieczki_slug",
              "city": "Nazwa Miasta / Pasma Górskiego",
              "distance": "Np. Szlak na Śnieżkę z Karpacza | 14 km pieszo",
              "price": "Łączna kwota szacowana zł (np. 140 zł)",
              "duration": "Łączny czas trwania (np. 8h)",
              "transport": "Pociąg / Samochód / Autobus",
              "bgImage": "https://images.unsplash.com/photo-X?q=80&w=1200&auto=format&fit=crop",
              "mapLabels": [
                { "text": "Nazwa przystanku", "label": "Nazwa przystanku", "cx": 180, "cy": 160, "info": "Krótki opis ukryty w tooltipie po najechaniu myszką" }
              ],
              "timeline": [
                { "time": "08:30", "title": "Tytuł etapu", "label": "Tytuł etapu", "desc": "Pełny, szczegółowy opis co robimy", "description": "Pełny, szczegółowy opis co robimy" }
              ],
              "attractions": [
                { "title": "Nazwa atrakcji", "label": "Nazwa atrakcji", "desc": "Opis wizualny", "description": "Opis wizualny", "image": "https://images.unsplash.com/photo-Y?q=80&w=400&auto=format&fit=crop" }
              ],
              "budget": [
                { "label": "Opis wydatku", "title": "Opis wydatku", "amount": "30 zł", "price": "30 zł", "icon": "ticket" } 
              ],
              "practical": [
                { "title": "Porada", "label": "Porada", "desc": "Wskazówka praktyczna", "description": "Wskazówka praktyczna" }
              ]
            }
            Uwaga: W polu 'icon' w budżecie używaj wyłącznie nazw ikon z biblioteki Lucide, takich jak: 'ticket', 'train', 'coffee', 'bus', 'wallet', 'utensils'.`
          }]
        }
      })
    });

    const data = await response.json();
    
    // Zabezpieczenie przed uszkodzoną strukturą odpowiedzi Google
    if (!data.candidates || !data.candidates[0] || !data.candidates[0].content || !data.candidates[0].content.parts || !data.candidates[0].content.parts[0]) {
      console.error("Błąd struktury odpowiedzi API Gemini:", JSON.stringify(data));
      return res.status(500).json({ message: "Gemini zwróciło pustą lub nieprawidłową strukturę danych." });
    }

    let responseText = data.candidates[0].content.parts[0].text.trim();
    
    // Usuwanie tagów markdown (```json ... ```) jeśli model zapomniał o rygorze MIME
    if (responseText.startsWith("```")) {
      responseText = responseText.replace(/^```json/, "").replace(/^```/, "").replace(/```$/, "").trim();
    }

    // Parsujemy tekst do natywnego obiektu JavaScript i zwracamy do frontendu
    const tripData = JSON.parse(responseText);
    return res.status(200).json(tripData);

  } catch (error) {
    console.error("Krytyczny błąd przetwarzania Agenta AI:", error);
    return res.status(500).json({ message: "Agent napotkał problem przy kompilacji kodu wycieczki." });
  }
}