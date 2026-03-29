const SELECTORS = [
    // Desktop YouTube
      'ytd-rich-shelf-renderer[is-shorts]',
      'ytd-reel-shelf-renderer',
      'ytd-guide-entry-renderer a[href="/shorts"]',
      'ytd-mini-guide-entry-renderer a[href="/shorts"]',
      '[tab-identifier="FEshorts"]',
      'ytd-video-renderer:has(a[href*="/shorts/"])',
      'ytd-grid-video-renderer:has(a[href*="/shorts/"])',
      'ytGridShelfViewModelHost ytd-item-section-renderer ytGridShelfViewModelHostHasBottomButton',

      // Mobile/modern YouTube
      'div.ytGridShelfViewModelGridShelfRow',
      'ytm-shorts-lockup-view-model-v2',
      'ytm-reel-shelf-renderer',
      'yt-shelf-header-layout',
      'ytd-item-section-renderer ytGridShelfViewModelHostHasBottomButton',
      'ytm-pivot-bar-item-renderer:has(a[href="/shorts"])',
      'div.pivot-shorts',
      'ytm-pivot-bar-renderer a[href="/shorts"]',
];

let enabled = true;

// Load initial state
browser.storage.local.get('enabled', (res) => {
  enabled = res.enabled !== false;
  if (enabled) hide();
});

// Listen for toggle from popup
browser.runtime.onMessage.addListener((msg) => {
  enabled = msg.enabled;
  if (enabled) {
    hide();
  } else {
    show();
  }
});

function hide() {
  SELECTORS.forEach(sel => {
    document.querySelectorAll(sel).forEach(el => el.style.display = 'none');
  });
}

function show() {
  SELECTORS.forEach(sel => {
    document.querySelectorAll(sel).forEach(el => el.style.display = '');
  });
}

// Watch for dynamic content
const observer = new MutationObserver(() => { if (enabled) hide(); });
observer.observe(document.body, { childList: true, subtree: true });
