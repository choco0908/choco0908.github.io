(function () {
  'use strict';

  var counter = document.querySelector('[data-goatcounter-views]');
  var tracker = document.querySelector('script[data-goatcounter]');
  if (!counter || !tracker) return;

  // Use the same canonical path for collection and the public counter,
  // including Korean slugs and nested category paths.
  var canonical = document.querySelector('link[rel="canonical"]');
  var pageUrl = new URL(canonical ? canonical.href : location.href, location.href);
  var path = pageUrl.origin === location.origin ? pageUrl.pathname : location.pathname;
  var endpoint = new URL(tracker.getAttribute('data-goatcounter'));
  var countUrl = endpoint.origin + '/counter/' + encodeURIComponent(path) + '.json';

  fetch(countUrl, { credentials: 'omit' })
    .then(function (response) {
      if (!response.ok) throw new Error('Counter unavailable');
      return response.json();
    })
    .then(function (data) {
      if (typeof data.count !== 'string' && typeof data.count !== 'number') return;
      counter.querySelector('[data-goatcounter-count]').textContent = data.count;
      counter.hidden = false;
    })
    .catch(function () {
      // Keep the counter hidden when public counts are disabled, the post has
      // no recorded visits yet, or the service cannot be reached.
    });
}());
