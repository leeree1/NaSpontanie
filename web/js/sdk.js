function applyConfig(c) {
  const g = (k) => c[k] || defaultConfig[k];
  const setText = (id, value) => {
    const el = document.getElementById(id);
    if (el) el.textContent = value;   // nie rzuca błędu, gdy elementu nie ma
  };
  setText('heroHeadline', g('hero_headline'));
  setText('heroSub', g('hero_subheadline'));
  setText('ctaText', g('cta_text'));
  setText('finalCtaBtnText', g('cta_text'));
  setText('tripsTitle', g('trips_section_title'));
  setText('finalCtaText', g('final_cta_text'));

  document.body.style.background = g('background_color');
  document.querySelectorAll('.font-heading').forEach(el => el.style.fontFamily = `${g('font_family')}, serif`);
}