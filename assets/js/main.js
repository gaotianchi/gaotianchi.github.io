(() => {
  // Theme switch
  const body = document.body;
  const lamp = document.getElementById("mode");

  const toggleTheme = (state) => {
    const html = document.documentElement;
    html.classList.add('theme-switching');

    if (state === "dark") {
      localStorage.setItem("theme", "light");
      body.removeAttribute("data-theme");
    } else if (state === "light") {
      localStorage.setItem("theme", "dark");
      body.setAttribute("data-theme", "dark");
    } else {
      initTheme(state);
    }

    setTimeout(() => html.classList.remove('theme-switching'), 400);
  };

  lamp.addEventListener("click", () =>
    toggleTheme(localStorage.getItem("theme"))
  );

  // Mobile menu: blur content, prevent body scroll when open
  const cbox = document.getElementById("menu-trigger");

  cbox.addEventListener("change", function () {
    const area = document.querySelector(".wrapper");
    if (this.checked) {
      area.classList.add("blurry");
      document.body.style.overflow = "hidden";
    } else {
      area.classList.remove("blurry");
      document.body.style.overflow = "";
    }
  });

  // Close menu when clicking overlay background
  const trigger = document.querySelector(".trigger");
  trigger.addEventListener("click", function (e) {
    if (e.target === this) {
      cbox.checked = false;
      document.querySelector(".wrapper").classList.remove("blurry");
      document.body.style.overflow = "";
    }
  });

  // Close menu when a menu link is clicked (uncheck before navigation)
  document.querySelectorAll(".menu-link").forEach(function (link) {
    link.addEventListener("click", function () {
      cbox.checked = false;
      document.querySelector(".wrapper").classList.remove("blurry");
      document.body.style.overflow = "";
    });
  });

  // Back to top
  const backToTop = document.getElementById("back-to-top");

  if (backToTop) {
    let ticking = false;

    const update = () => {
      backToTop.classList.toggle("visible", window.scrollY > 400);
      ticking = false;
    };

    window.addEventListener("scroll", () => {
      if (!ticking) {
        requestAnimationFrame(update);
        ticking = true;
      }
    }, { passive: true });

    backToTop.addEventListener("click", () => {
      window.scrollTo({ top: 0, behavior: "smooth" });
      history.pushState(null, "", window.location.pathname);
    });
  }

  // Like counter
  (function() {
    var buttons = document.querySelectorAll('.like-button');
    if (!buttons.length) return;

    var API = 'https://api.counterapi.dev/v1/gaotianchi.com/';
    var LIKED_KEY = 'liked_';
    var uid = 0;

    function jsonp(url, fn) {
      var id = 'capi_' + (uid++);
      window[id] = function(data) {
        fn(data);
        delete window[id];
        document.getElementById(id).remove();
      };
      var s = document.createElement('script');
      s.id = id;
      s.src = url + (url.indexOf('?') > -1 ? '&' : '?') + 'callback=' + id;
      document.head.appendChild(s);
    }

    buttons.forEach(function(btn) {
      var slug = btn.getAttribute('data-slug');
      if (!slug) return;
      var key = API + slug;
      var storageKey = LIKED_KEY + slug;
      var countEl = btn.querySelector('.like-count');

      // Fetch current count via JSONP
      jsonp(key, function(d) {
        countEl.textContent = d.count > 0 ? ' ' + d.count : '';
      });

      // Check if already liked
      if (localStorage.getItem(storageKey)) {
        btn.setAttribute('data-liked', 'true');
      }

      // Click handler
      btn.addEventListener('click', function() {
        if (btn.getAttribute('data-liked') === 'true') return;
        jsonp(key + '/up', function(d) {
          countEl.textContent = ' ' + d.count;
          btn.setAttribute('data-liked', 'true');
          localStorage.setItem(storageKey, '1');
        });
      });
    });
  })();
})();
