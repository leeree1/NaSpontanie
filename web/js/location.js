function showLocationBanner(text) {
  var old = document.getElementById('locationBanner');
  if (old) {
    old.remove();
  }

  var banner = document.createElement('div');
  banner.id = 'locationBanner';
  banner.style.position = 'fixed';
  banner.style.bottom = '16px';
  banner.style.left = '50%';
  banner.style.transform = 'translateX(-50%)';
  banner.style.zIndex = '9999';
  banner.style.maxWidth = '90%';
  banner.style.padding = '12px 16px';
  banner.style.borderRadius = '16px';
  banner.style.background = '#1f2937';
  banner.style.color = 'white';
  banner.style.fontSize = '14px';
  banner.style.fontWeight = '600';
  banner.style.boxShadow = '0 8px 24px rgba(0,0,0,0.2)';
  banner.textContent = text;
  document.body.appendChild(banner);

  setTimeout(function () {
    if (banner.parentNode) {
      banner.remove();
    }
  }, 8000);
}

async function showBrowserNotice(text) {
  if (!('Notification' in window)) {
    return;
  }

  var permission = Notification.permission;
  if (permission === 'default') {
    permission = await Notification.requestPermission();
  }

  if (permission === 'granted') {
    new Notification('NaSpontanie', { body: text });
  }
}

function startLocationOnOpen() {
  if (!navigator.geolocation) {
    showLocationBanner('Ta przeglądarka nie ma GPS.');
    return;
  }

  navigator.geolocation.getCurrentPosition(
    async function (pos) {
      var lat = pos.coords.latitude.toFixed(4);
      var lng = pos.coords.longitude.toFixed(4);
      var text = 'Twoja lokalizacja: ' + lat + ', ' + lng;
      showLocationBanner(text);
      await showBrowserNotice(text);
    },
    function (err) {
      if (err.code === 1) {
        showLocationBanner('Brak zgody na lokalizację.');
      } else if (err.code === 2) {
        showLocationBanner('Nie da się odczytać GPS (włącz lokalizację w systemie).');
      } else {
        showLocationBanner('GPS nie zdążył się złapać. Odśwież stronę.');
      }
    },
    { enableHighAccuracy: false, timeout: 20000, maximumAge: 60000 }
  );
}

document.addEventListener('DOMContentLoaded', startLocationOnOpen);
