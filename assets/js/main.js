(function() {
  const body = document.body;

  // === Everything else (on DOM ready) ===
  document.addEventListener('DOMContentLoaded', function() {

    // Theme switch (toggle between light/dark via lamp button)
    if (document.getElementById('mode')) {
      const lamp = document.getElementById('mode');

      const toggleTheme = (state) => {
        const html = document.documentElement;
        html.classList.add('theme-switching');

        if (state === 'dark') {
          localStorage.setItem('theme', 'light');
          body.removeAttribute('data-theme');
        } else if (state === 'light') {
          localStorage.setItem('theme', 'dark');
          body.setAttribute('data-theme', 'dark');
        } else {
          var prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
          if (prefersDark) {
            body.setAttribute('data-theme', 'dark');
            localStorage.setItem('theme', 'dark');
          } else {
            body.removeAttribute('data-theme');
            localStorage.setItem('theme', 'light');
          }
        }

        setTimeout(() => html.classList.remove('theme-switching'), 400);
      };

      lamp.addEventListener('click', () =>
        toggleTheme(localStorage.getItem('theme'))
      );
    }

    // Mobile menu: blur content, prevent body scroll when open
    if (document.getElementById('menu-trigger')) {
      const cbox = document.getElementById('menu-trigger');

      cbox.addEventListener('change', function () {
        const area = document.querySelector('.wrapper');
        if (this.checked) {
          area.classList.add('blurry');
          document.body.style.overflow = 'hidden';
        } else {
          area.classList.remove('blurry');
          document.body.style.overflow = '';
        }
      });

      // Close menu when clicking overlay background
      const trigger = document.querySelector('.trigger');
      trigger.addEventListener('click', function (e) {
        if (e.target === this) {
          cbox.checked = false;
          document.querySelector('.wrapper').classList.remove('blurry');
          document.body.style.overflow = '';
        }
      });

      // Close menu when a menu link is clicked (uncheck before navigation)
      document.querySelectorAll('.menu-link').forEach(function (link) {
        link.addEventListener('click', function () {
          cbox.checked = false;
          document.querySelector('.wrapper').classList.remove('blurry');
          document.body.style.overflow = '';
        });
      });
    }

    // Back to top
    if (document.getElementById('back-to-top')) {
      const backToTop = document.getElementById('back-to-top');
      let ticking = false;

      const update = () => {
        backToTop.classList.toggle('visible', window.scrollY > 400);
        ticking = false;
      };

      window.addEventListener('scroll', () => {
        if (!ticking) {
          requestAnimationFrame(update);
          ticking = true;
        }
      }, { passive: true });

      backToTop.addEventListener('click', () => {
        window.scrollTo({ top: 0, behavior: 'smooth' });
        history.pushState(null, '', window.location.pathname);
      });
    }

    // Watermark — random position + rotation within .post-top area
    if (document.querySelector('.toc-watermark')) {
      (function() {
        var wm = document.querySelector('.toc-watermark');
        if (!wm) return;
        var container = wm.parentElement;
        if (!container || !container.classList.contains('post-top')) return;

        // Random position + rotation + scale on each load
        var topPos = 10 + Math.floor(Math.random() * 36);      // 10–45%
        var rightPos = Math.floor(Math.random() * 19);          // 0–18%
        var rotate = Math.floor(Math.random() * 360);           // 0–359°
        var scale = (85 + Math.floor(Math.random() * 31)) / 100; // 0.85–1.15
        wm.style.setProperty('top', topPos + '%', 'important');
        wm.style.setProperty('right', rightPos + '%', 'important');
        wm.style.setProperty('transform', 'rotate(' + rotate + 'deg) scale(' + scale + ')', 'important');
      })();
    }

    // TOC scroll + back-to-top
    if (document.getElementById('toc')) {
      (function() {
        var toc = document.getElementById('toc');
        if (!toc) return;

        // Scroll spy
        var tocList = document.getElementById('toc-list');
        if (tocList) {
          var headings = document.querySelectorAll('.post-body h2, .post-body h3, .post-body h4');
          var tocLinks = tocList.querySelectorAll('a');
          if (tocLinks.length > 0) {
            var observer = new IntersectionObserver(function(entries) {
              entries.forEach(function(entry) {
                var id = entry.target.getAttribute('id');
                var link = tocList.querySelector('a[href="#' + CSS.escape(id) + '"]');
                if (link) {
                  if (entry.isIntersecting) {
                    tocLinks.forEach(function(l) { l.classList.remove('active'); });
                    link.classList.add('active');
                  }
                }
              });
            }, { rootMargin: '-80px 0px -70% 0px' });
            headings.forEach(function(h) { observer.observe(h); });
          }
        }

        // Smooth scroll + back-to-top via title link
        toc.addEventListener('click', function(e) {
          var a = e.target.closest('a');
          if (!a) return;
          var href = a.getAttribute('href');
          if (href === '#') {
            e.preventDefault();
            window.scrollTo({ top: 0, behavior: 'smooth' });
            history.pushState(null, '', window.location.pathname);
            return;
          }
          e.preventDefault();
          var id = href.slice(1);
          var target = document.getElementById(id);
          if (target) {
            target.scrollIntoView({ behavior: 'smooth', block: 'start' });
            history.pushState(null, '', '#' + id);
          }
        });
      })();
    }

    // Archive category filter
    if (document.getElementById('archive-tags')) {
      (function() {
        var items = document.querySelectorAll('.timeline-item');
        var groups = document.querySelectorAll('.timeline-year-group');
        var emptyMsg = document.getElementById('archive-empty');

        var allBtn = document.querySelector('.archive-tag-all');
        var activeCat = 'all';

        function activate(btn, catVal) {
          document.querySelectorAll('.archive-tag-btn').forEach(function(b) {
            b.classList.remove('active');
          });
          btn.classList.add('active');
          activeCat = catVal;
          filter();
        }

        function filter() {
          var anyVisible = false;

          items.forEach(function(item) {
            var cat = item.getAttribute('data-category');
            var visible = activeCat === 'all' || cat === activeCat;
            item.style.display = visible ? '' : 'none';
            if (visible) anyVisible = true;
          });

          groups.forEach(function(group) {
            var hasVisible = false;
            group.querySelectorAll('.timeline-item').forEach(function(item) {
              if (item.style.display !== 'none') hasVisible = true;
            });
            group.style.display = hasVisible ? '' : 'none';
            var year = group.previousElementSibling;
            if (year && year.classList.contains('timeline-year')) {
              year.style.display = hasVisible ? '' : 'none';
            }
          });

          emptyMsg.style.display = anyVisible ? 'none' : '';
        }

        document.getElementById('archive-tags').addEventListener('click', function(e) {
          var btn = e.target.closest('.archive-tag-btn');
          if (!btn) return;
          var catVal = btn.getAttribute('data-cat');
          if (btn.classList.contains('active')) {
            activate(allBtn, 'all');
            return;
          }
          activate(btn, catVal);
        });
      })();
    }

    // Random quote — text ········ source with dotted leader
    if (document.getElementById('footer-quote')) {
      var dataScript = document.getElementById('footer-quotes-data');
      if (dataScript) {
        try {
          var quotes = JSON.parse(dataScript.textContent);
          var el = document.getElementById('footer-quote');
          if (quotes.length > 0) {
            var q = quotes[Math.floor(Math.random() * quotes.length)];
            el.querySelector('.navbar-quote-text').textContent = q.text;
            el.querySelector('.navbar-quote-source').textContent = q.source || '佚名';
            el.style.visibility = '';
          }
        } catch (e) {}
      }
    }

  });
})();
