/**
 * Shared navigation — edit this file to update the nav on every page.
 * To add/remove/rename a page, edit the `pages` array below.
 */
(function () {
  var pages = [
    { href: 'index.html',        label: 'Overview'     },
    { href: 'planning.html',     label: 'Planning'     },
    { href: 'speakers.html',     label: 'Speakers'     },
    { href: 'registration.html', label: 'Registration' },
    { href: 'resources.html',    label: 'Resources'    },
    { href: 'logistics.html',    label: 'Logistics'    },
    { href: 'contacts.html',     label: 'Contact'      },
  ];

  // Detect the current page from the URL
  var current = window.location.pathname.split('/').pop() || 'index.html';

  var items = pages.map(function (p) {
    var active = (p.href === current) ? ' class="active"' : '';
    return '<li><a href="' + p.href + '"' + active + '>' + p.label + '</a></li>';
  }).join('');

  var nav = document.createElement('nav');
  nav.className = 'site-nav';
  nav.setAttribute('aria-label', 'Main navigation');
  nav.innerHTML =
    '<div class="nav-inner">' +
      '<a class="nav-brand" href="index.html">Convergence</a>' +
      '<button class="nav-toggle" aria-label="Toggle menu" ' +
        'onclick="this.closest(\'nav\').querySelector(\'.nav-links\').classList.toggle(\'open\')">' +
        '<span></span><span></span><span></span>' +
      '</button>' +
      '<ul class="nav-links">' + items + '</ul>' +
    '</div>';

  // Insert synchronously, directly before this <script> tag
  document.currentScript.parentNode.insertBefore(nav, document.currentScript);
}());
