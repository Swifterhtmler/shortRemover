// Check if the extension was just installed
browser.runtime.onInstalled.addListener(() => {
  browser.storage.local.set({ installDate: Date.now() });
});

// Function to show a notification
function showTipNotification() {
  browser.notifications.create({
    type: "basic",
    iconUrl: "images/icon-48.png",
    title: "Enjoying the Extension?",
    message: "If you find it useful, consider tipping to support development. Thank you!",
  });
}

// Check elapsed time and show notification after 7 days
function checkAndNotify() {
  browser.storage.local.get(['installDate', 'notificationShown'], (res) => {
    const installDate = res.installDate || Date.now();
    const now = Date.now();
    const oneWeek = 7 * 24 * 60 * 60 * 1000; // 7 days in milliseconds
    const elapsed = now - installDate;

    // Show notification after 7 days if not already shown
    if (elapsed >= oneWeek && !res.notificationShown) {
      showTipNotification();
      browser.storage.local.set({ notificationShown: true });
    }
  });
}

// Check every hour (or adjust as needed)
setInterval(checkAndNotify, 60 * 60 * 1000);
checkAndNotify(); // Run immediately on startup
