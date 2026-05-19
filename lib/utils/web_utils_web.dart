import 'dart:js' as js;

/// Web implementation that removes the HTML loading indicator.
void removeLoadingIndicator() {
  try {
    js.context.callMethod('eval', [
      "document.getElementById('loading-indicator')?.remove()"
    ]);
  } catch (_) {
    // Silently ignore if DOM manipulation fails
  }
}
