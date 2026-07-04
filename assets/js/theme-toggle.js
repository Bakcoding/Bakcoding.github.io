(function() {
  var storageKey = "bakcoding-theme";
  var modes = ["auto", "light", "dark"];
  var labels = {
    auto: "색상 모드: 자동",
    light: "색상 모드: 라이트",
    dark: "색상 모드: 다크"
  };
  var themeColors = {
    light: "#fbfbf8",
    dark: "#151816"
  };

  function systemMode() {
    if (window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches) {
      return "dark";
    }
    return "light";
  }

  function selectedMode() {
    var value = document.documentElement.getAttribute("data-theme");
    return value === "light" || value === "dark" ? value : "auto";
  }

  function setThemeColor(mode) {
    var meta = document.querySelector('meta[name="theme-color"]');
    if (!meta) {
      return;
    }
    meta.setAttribute("content", themeColors[mode === "auto" ? systemMode() : mode]);
  }

  function updateButton(mode) {
    var button = document.querySelector(".theme-toggle");
    if (!button) {
      return;
    }
    button.setAttribute("aria-label", labels[mode]);
    button.setAttribute("title", labels[mode]);
  }

  function applyMode(mode) {
    if (mode === "auto") {
      document.documentElement.removeAttribute("data-theme");
      try {
        localStorage.removeItem(storageKey);
      } catch (error) {}
    } else {
      document.documentElement.setAttribute("data-theme", mode);
      try {
        localStorage.setItem(storageKey, mode);
      } catch (error) {}
    }
    updateButton(mode);
    setThemeColor(mode);
  }

  function nextMode(mode) {
    return modes[(modes.indexOf(mode) + 1) % modes.length];
  }

  document.addEventListener("DOMContentLoaded", function() {
    var button = document.querySelector(".theme-toggle");
    applyMode(selectedMode());

    if (button) {
      button.addEventListener("click", function() {
        applyMode(nextMode(selectedMode()));
      });
    }

    if (window.matchMedia) {
      var mediaQuery = window.matchMedia("(prefers-color-scheme: dark)");
      var onSystemModeChange = function() {
        if (selectedMode() === "auto") {
          setThemeColor("auto");
        }
      };
      if (mediaQuery.addEventListener) {
        mediaQuery.addEventListener("change", onSystemModeChange);
      } else if (mediaQuery.addListener) {
        mediaQuery.addListener(onSystemModeChange);
      }
    }
  });
})();
