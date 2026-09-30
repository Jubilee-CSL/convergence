(function () {
  function resolveUrl(base, relative) {
    try {
      return new URL(relative, base).toString();
    } catch (e) {
      return relative;
    }
  }

  function normalizeMarkdownLinks(root, baseUrl) {
    if (!root || !baseUrl) return;

    root.querySelectorAll('a[href]').forEach(function (a) {
      var href = a.getAttribute('href') || '';
      if (!href || href.startsWith('#') || href.startsWith('mailto:') || href.startsWith('tel:')) return;
      a.setAttribute('href', resolveUrl(baseUrl, href));
      a.setAttribute('target', '_blank');
      a.setAttribute('rel', 'noopener');
    });

    root.querySelectorAll('img[src]').forEach(function (img) {
      var src = img.getAttribute('src') || '';
      if (!src || src.startsWith('data:')) return;
      img.setAttribute('src', resolveUrl(baseUrl, src));
      img.setAttribute('loading', 'lazy');
    });
  }

  function fetchText(url) {
    return fetch(url).then(function (res) {
      if (!res.ok) throw new Error('HTTP ' + res.status + ' for ' + url);
      return res.text();
    });
  }

  function getBaseFromReadmeUrl(readmeUrl) {
    try {
      var u = new URL(readmeUrl, window.location.href);
      return u.toString().replace(/[^/]*$/, '');
    } catch (e) {
      return '';
    }
  }

  function setStatus(message) {
    var status = document.getElementById('readme-status');
    if (status) status.textContent = message;
  }

  var container = document.getElementById('readme-content');
  if (!container) return;

  var sourceLink = document.getElementById('readme-source-link');
  var rawUrl = document.body.dataset.readmeRaw || '';
  var localPath = document.body.dataset.readmeLocal || '';

  if (!rawUrl && !localPath) {
    setStatus('No README source is configured for this page.');
    return;
  }

  var rendererReady = typeof marked !== 'undefined' && marked && typeof marked.parse === 'function';
  if (!rendererReady) {
    setStatus('Markdown renderer could not be loaded.');
    return;
  }

  var primary = rawUrl || localPath;
  var fallback = rawUrl && localPath ? localPath : '';

  var usedSource = primary;

  fetchText(primary)
    .catch(function () {
      if (!fallback) throw new Error('Primary README source unavailable.');
      usedSource = fallback;
      return fetchText(fallback);
    })
    .then(function (markdown) {
      container.innerHTML = marked.parse(markdown);
      var baseUrl = getBaseFromReadmeUrl(usedSource);
      normalizeMarkdownLinks(container, baseUrl);

      if (sourceLink) {
        sourceLink.href = rawUrl || localPath;
      }

      setStatus('README loaded directly from source.');
    })
    .catch(function () {
      container.innerHTML = '<p>Could not load this README right now.</p>';
      setStatus('Failed to load README source.');
    });
}());