const toggle = document.getElementById('toggle');
const status = document.getElementById('status');

// Load saved state
browser.storage.local.get('enabled', (res) => {
  const enabled = res.enabled !== false; // default ON
  setState(enabled);
});

toggle.addEventListener('click', () => {
  const isOn = toggle.classList.contains('on');
  const next = !isOn;
  browser.storage.local.set({ enabled: next });
  setState(next);

  // Tell the active tab to update immediately
  browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
    browser.tabs.sendMessage(tabs[0].id, { enabled: next });
  });
});

function setState(enabled) {
  toggle.classList.toggle('on', enabled);
  status.textContent = enabled ? 'Shorts out of sight' : 'Shorts visible';
}
