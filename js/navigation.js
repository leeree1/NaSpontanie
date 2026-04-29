function showLanding() {
  document.getElementById('landingPage').classList.remove('hidden');
  document.getElementById('detailPage').classList.add('hidden');
  document.getElementById('appRoot').scrollTop = 0;
}

function showDetail() {
  document.getElementById('landingPage').classList.add('hidden');
  document.getElementById('detailPage').classList.remove('hidden');
  document.getElementById('appRoot').scrollTop = 0;
  lucide.createIcons();
}