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

})();
