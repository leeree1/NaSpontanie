const defaultConfig = {
  hero_headline: 'Gdzie jedziesz jutro?',
  hero_subheadline: 'Znajdź tani, gotowy plan jednodniowej wycieczki',
  cta_text: 'Znajdź wycieczkę',
  trips_section_title: 'Gotowe pomysły',
  final_cta_text: 'Masz dzień wolny? To wystarczy.',
  background_color: '#FAFAFA',
  surface_color: '#FFFFFF',
  text_color: '#111827',
  primary_action_color: '#2563EB',
  secondary_action_color: '#FB923C',
  font_family: 'Fraunces',
  font_size: 16
};

function applyConfig(c) {
  const g = (k) => c[k] || defaultConfig[k];
  document.getElementById('heroHeadline').textContent = g('hero_headline');
  document.getElementById('heroSub').textContent = g('hero_subheadline');
  document.getElementById('ctaText').textContent = g('cta_text');
  document.getElementById('finalCtaBtnText').textContent = g('cta_text');
  document.getElementById('tripsTitle').textContent = g('trips_section_title');
  document.getElementById('finalCtaText').textContent = g('final_cta_text');

  document.body.style.background = g('background_color');
  document.querySelectorAll('.font-heading').forEach(el => el.style.fontFamily = `${g('font_family')}, serif`);

  const base = g('font_size');
  document.getElementById('heroHeadline').style.fontSize = `${base * 2.5}px`;
  document.getElementById('heroSub').style.fontSize = `${base * 1.15}px`;
}

if (window.elementSdk) window.elementSdk.init({
  defaultConfig,
  onConfigChange: async (config) => { applyConfig(config); },
  mapToCapabilities: (config) => ({
    recolorables: [
      { get: () => config.background_color || defaultConfig.background_color, set: (v) => { config.background_color = v; window.elementSdk.setConfig({ background_color: v }); } },
      { get: () => config.surface_color || defaultConfig.surface_color, set: (v) => { config.surface_color = v; window.elementSdk.setConfig({ surface_color: v }); } },
      { get: () => config.text_color || defaultConfig.text_color, set: (v) => { config.text_color = v; window.elementSdk.setConfig({ text_color: v }); } },
      { get: () => config.primary_action_color || defaultConfig.primary_action_color, set: (v) => { config.primary_action_color = v; window.elementSdk.setConfig({ primary_action_color: v }); } },
      { get: () => config.secondary_action_color || defaultConfig.secondary_action_color, set: (v) => { config.secondary_action_color = v; window.elementSdk.setConfig({ secondary_action_color: v }); } }
    ],
    borderables: [],
    fontEditable: { get: () => config.font_family || defaultConfig.font_family, set: (v) => { config.font_family = v; window.elementSdk.setConfig({ font_family: v }); } },
    fontSizeable: { get: () => config.font_size || defaultConfig.font_size, set: (v) => { config.font_size = v; window.elementSdk.setConfig({ font_size: v }); } }
  }),
  mapToEditPanelValues: (config) => new Map([
    ['hero_headline', config.hero_headline || defaultConfig.hero_headline],
    ['hero_subheadline', config.hero_subheadline || defaultConfig.hero_subheadline],
    ['cta_text', config.cta_text || defaultConfig.cta_text],
    ['trips_section_title', config.trips_section_title || defaultConfig.trips_section_title],
    ['final_cta_text', config.final_cta_text || defaultConfig.final_cta_text]
  ])
});