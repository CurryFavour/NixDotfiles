{ pkgs, config, ... }:

{
  programs.qutebrowser = {
    enable = true;
  };

  programs.firefox = {
    enable = true;

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudy = true;
      DisablePocket = true;
      DisableFirefoxAccounts = false;
      DisableProfileImport = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DontCheckDefaultBrowser = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      ExtensionSettings = {
        "*" = {
          installation_mode = "blocked";
        };
      };
    };

    profiles = {
      main-profile = {
        extensions = {
          packages = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            keepassxc-browser
            clearurls
            stylus # Pretty :3
          ];
          force = true;
        };

        search = {
          force = true;
          default = "ddg";
          order = [
            "ddg"
            "Nix Packages"
            "NixOS Wiki"
            "GitHub"
          ];
          engines = {
            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "NixOS Wiki" = {
              urls = [ { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; } ];
              iconUpdateURL = "https://wiki.nixos.org/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000;
              definedAliases = [ "@nw" ];
            };
            "GitHub" = {
              urls = [ { template = "https://github.com/search?q={searchTerms}&type=repositories"; } ];
              iconUpdateURL = "https://github.com/favicon.ico";
              updateInterval = 24 * 60 * 60 * 1000;
              definedAliases = [ "@gh" ];
            };
          };
        };

        bookmarks = {
          force = true;
          settings = [
            {
              name = "NixOS Search";
              keyword = "nix";
              url = "https://search.nixos.org/packages";
            }
            {
              name = "Home Manager Options";
              keyword = "hm";
              url = "https://nix-community.github.io/home-manager/options.xhtml";
            }
          ];
        };

        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

          "browser.aboutConfig.showWarning" = false;
          "browser.toolbars.bookmarks.visibility" = "never";
          "browser.startup.page" = 3;
          "browser.tabs.warnOnClose" = false;
          "browser.download.panel.shown" = true;
          "full-screen-api.warning.timeout" = 0;

          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
          "browser.urlbar.suggest.quicksuggest.sponsored" = false;

          "browser.ping-centre.telemetry" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.server" = "data:,";
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "network.prefetch-next" = false;
          "network.dns.disablePrefetch" = true;
          "network.predictor.enabled" = false;
          "browser.search.suggest.enabled" = false;
          "dom.security.https_only_mode" = true;
        };

        userChrome = ''
          :root {
            --s-base00: #${config.lib.stylix.colors.base00}; 
            --s-base01: #${config.lib.stylix.colors.base01}; 
            --s-base02: #${config.lib.stylix.colors.base02}; 
            --s-base03: #${config.lib.stylix.colors.base03}; 
            --s-base04: #${config.lib.stylix.colors.base04};
            --s-base05: #${config.lib.stylix.colors.base05};
            --s-base06: #${config.lib.stylix.colors.base06};
            --s-base07: #${config.lib.stylix.colors.base07};
            --s-base08: #${config.lib.stylix.colors.base08};
            --s-base09: #${config.lib.stylix.colors.base09};
            --s-base0A: #${config.lib.stylix.colors.base0A};
            --s-base0B: #${config.lib.stylix.colors.base0B};
            --s-base0C: #${config.lib.stylix.colors.base0C};
            --s-base0D: #${config.lib.stylix.colors.base0D};
            --s-base0E: #${config.lib.stylix.colors.base0E};
            --s-base0F: #${config.lib.stylix.colors.base0F};

            --toolbarbutton-border-radius: 0px !important;
            --tab-border-radius: 0px !important;
            --arrowpanel-border-radius: 0px !important;
            --urlbar-icon-border-radius: 0px !important;

            --toolbar-bgcolor: var(--s-base00) !important;
            --toolbar-field-background-color: var(--s-base01) !important;
            --toolbar-field-focus-background-color: var(--s-base01) !important;
            --lwt-toolbar-field-background-color: var(--s-base01) !important;
            --lwt-toolbar-field-focus: var(--s-base01) !important;
          }

          #navigator-toolbox {
            border-top: 6px solid transparent !important;
            border-image: linear-gradient(to right, 
                var(--s-base0B) 20%, 
                var(--s-base0D) 20% 40%, 
                var(--s-base0A) 40% 60%, 
                var(--s-base08) 60% 80%, 
                var(--s-base08) 80%) 1 !important;
          }

          #navigator-toolbox, 
          #titlebar,
          #nav-bar, 
          #TabsToolbar, 
          #PersonalToolbar {
            background-color: var(--s-base00) !important;
            background-image: none !important;
            border: none !important;
            box-shadow: none !important;
          }

          .tab-background {
            background-color: var(--s-base01) !important;
            border: 2px solid var(--s-base07) !important;
            border-radius: 0px !important;
            box-shadow: 2px 2px 0px var(--s-base07) !important;
            margin-block: 4px !important;
            margin-inline: 2px !important;
            transition: all 0.1s ease-in-out !important;
          }

          .tabbrowser-tab[selected="true"] .tab-background {
            background-color: var(--s-base0A) !important;
          }

          .tabbrowser-tab[selected="true"] .tab-label {
            color: var(--s-base07) !important;
            font-weight: bold !important;
          }

          .tabbrowser-tab:hover:not([selected="true"]) .tab-background {
            background-color: var(--s-base0D) !important;
          }

          .tabbrowser-tab::before, .tabbrowser-tab::after {
            display: none !important;
          }

          #urlbar-background {
            background-color: var(--s-base01) !important;
            border: 1px solid var(--s-base03) !important;
            border-radius: 4px !important;
          }

          .urlbarView-row:hover > .urlbarView-row-inner,
          .urlbarView-row[selected] > .urlbarView-row-inner {
            background-color: var(--s-base0D) !important;
            color: white !important;
          }

          .tabbrowser-tab:not(:hover) .tab-close-button {
            display: none !important;
          }

          #sidebar-splitter {
            border: none !important;
            border-right: 2px solid var(--s-base03) !important;
            background-color: var(--s-base03) !important;
          }
        '';

        userContent = ''
          @-moz-document url-prefix("chrome://devtools/content/") {
            :root {
              --s-base00: #${config.lib.stylix.colors.base00}; 
              --s-base01: #${config.lib.stylix.colors.base01}; 
              --s-base02: #${config.lib.stylix.colors.base02}; 
              --s-base03: #${config.lib.stylix.colors.base03}; 
              --s-base04: #${config.lib.stylix.colors.base04};
              --s-base05: #${config.lib.stylix.colors.base05};
              --s-base06: #${config.lib.stylix.colors.base06};
              --s-base07: #${config.lib.stylix.colors.base07};
              --s-base08: #${config.lib.stylix.colors.base08};
              --s-base09: #${config.lib.stylix.colors.base09};
              --s-base0A: #${config.lib.stylix.colors.base0A};
              --s-base0B: #${config.lib.stylix.colors.base0B};
              --s-base0C: #${config.lib.stylix.colors.base0C};
              --s-base0D: #${config.lib.stylix.colors.base0D};
              --s-base0E: #${config.lib.stylix.colors.base0E};
              --s-base0F: #${config.lib.stylix.colors.base0F};

              --theme-body-background: var(--s-base00) !important;
              --theme-sidebar-background: var(--s-base01) !important;
              --theme-toolbar-background: var(--s-base01) !important;
              --theme-tab-toolbar-background: var(--s-base01) !important;
              --theme-selection-background: var(--s-base04) !important;
              --theme-selection-color: #ffffff !important;
              --theme-splitter-color: var(--s-base07) !important;
              --theme-comment: var(--s-base04) !important;
            }

            .theme-body {
              border-top: 4px solid transparent !important;
              border-image: linear-gradient(to right, 
                  var(--s-base0B) 20%, 
                  var(--s-base04) 20% 40%, 
                  var(--s-base0A) 40% 60%, 
                  var(--s-base09) 60% 80%, 
                  var(--s-base08) 80%) 1 !important;
            }

            .jsterm-input-node {
              background-color: var(--s-base02) !important;
              border: 2px solid var(--s-base07) !important;
              border-radius: 4px !important;
              color: var(--s-base07) !important;
            }

            .theme-fg-color1 { color: var(--s-base08) !important; }
            .theme-fg-color3 { color: var(--s-base0B) !important; }
          }

          @-moz-document url("about:newtab"), url("about:home") {
            body { background-color: var(--s-base02) !important; }
            .search-wrapper .search-inner-wrapper {
              background-color: var(--s-base02) !important;
              border: 2px solid var(--s-base07) !important;
              box-shadow: 3px 3px 0px var(--s-base07) !important;
            }
          }
        '';

      };
    };
  };

  stylix.targets.firefox = {
    profileNames = [ "main-profile" ];
    colorTheme.enable = true;
  };
}
