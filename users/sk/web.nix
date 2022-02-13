{ pkgs, lib, config, ... }:
let
  vimiumCommon = {
    exclusionRules = [
      { pattern = "https?://mail.google.com/*"; passKeys = ""; }
      { pattern = "https?://app.amazingmarvin.com/*"; passKeys = "ao"; }
    ];
    keyMappings = ''
      # Navigating the current page:
      # ?         Show help
      # h         Scroll left
      # j, <c-e>  Scroll down
      # k, <c-y>  Scroll up
      # l         Scroll right
      # gg        Scroll to the top of the page
      # G         Scroll to the bottom of the page
      # d         Scroll a half page down
      # u         Scroll a half page up
      # f         Open a link in the current tab
      # F         Open a link in a new tab
      # r         Reload the page
      map R reload hard # Reload page, bypassing cache
      # gs        View page source
      # i         Enter insert mode
      # yy        Copy the current URL to the clipboard
      # yf        Copy a link URL to the clipboard
      # gf        Select the next frame on the page
      # gF        Select the page's main/top frame

      # Navigating to new pages:
      # o         Open URL, bookmark or history entry
      # O         Open URL, bookmark or history entry in a new tab
      # b         Open a bookmark
      # B         Open a bookmark in a new tab
      # p         Open the clipboard's URL in the current tab
      # P         Open the clipboard's URL in a new tab

      # Using find:
      # /         Enter find mode
      # n         Cycle forward to the next find match
      # N         Cycle backward to the previous find match

      # Navigating your history:
      # H         Go back in history
      # L         Go forward in history

      # Manipulating tabs:
      # J, gT     Go one tab left
      # K, gt     Go one tab right
      # g0        Go to the first tab
      # g$        Go to the last tab
      # <<        Move tab to the left
      # >>        Move tab to the right
      # t         Create new tab
      # ^         Go to previously-visited tab
      # yt        Duplicate current tab
      # x         Close current tab
      # X         Restore closed tab
      # T         Search through your open tabs
      # W         Move tab to new window
      # <a-p>     Pin or unpin current tab
      # <a-m>     Mute or unmute current tab
      map <a-M>   toggleMuteTab all # mute all tabs

      # Using marks:
      # m         Create a new mark (ma - set local mark "a", mA - set global mark "A")
      # `         Go to a mark (`` - jump back to the position before the prev jump)

      # Visual mode
      # v         Enter visual mode; use p/P to paste-and-go, use y to yank
      # V         Enter visual line mode
      # c         (in visual mode) enter caret mode
      # o         (in visual mode) swap anchor and the focus, move "other end"

      # Additional advanced browsing commands:
      # [[        Follow the link labeled previous or <
      # ]]        Follow the link labeled next or >
      # <a-f>     Open multiple links in a new tab
      # gi        Focus the first text input on the page
      # gu        Go up the URL hierarchy
      # gU        Go to root of current URL hierarchy
      # ge        Edit the current URL
      # gE        Edit the current URL and open in a new tab
      # zH        Scroll all the way to the left
      # zL        Scroll all the way to the right

      map <c-]> passNextKey # passthru next key
    '';
    searchEngines = ''
      d: https://duckduckgo.com/?q=%s DuckDuckGo

      g: https://google.com/search?q=%s Google
      gyear: https://google.com/search?hl=en&tbo=1&tbs=qdr:y&q=%s Google (last year only)
      gsite: javascript:location='https://www.google.com/search?num=100&q=site:'+escape(location.hostname)+'+%s' Google on this site
      gi: https://google.com/search?tbm=isch&q=%s Google Images
      gm: https://google.com/maps?q=%s Google maps
      gt: https://translate.google.com/?source=osdd#auto|auto|%s Google Translator
      yt: https://youtube.com/results?search_query=%s Youtube

      y: https://yandex.ru/search/?text=%s Yandex
      ym: https://yandex.ru/maps/?text=%s Yandex Maps

      b: https://www.bing.com/search?q=%s Bing

      w: https://www.wikipedia.org/w/index.php?title=Special:Search&search=%s Wikipedia
      wr: https://ru.wikipedia.org/w/index.php?title=Special:Search&search=%s Wikipedia (RU)

      gh: https://github.com/search?q=%s GitHub

      so: https://stackoverflow.com/search?q=%s StackOverflow

      wa: https://wolframalpha.com/input/?i=%s Wolfram|Alpha

      imdb: https://www.imdb.com/find?s=all&q=%s IMDB
    '';
    scrollStepSize = 60;
    linkHintNumbers = "0123456789";
    linkHintCharacters = "sadfjklewcmpgh";
    smoothScroll = true;
    grabBackFocus = false;
    hideHud = false;
    regexFindMode = true;
    ignoreKeyboardLayout = true;
    filterLinkHints = false;
    waitForEnterForFilteredHints = true;
    previousPatterns = "prev,previous,back,older,<,‹,←,«,≪,<<";
    nextPatterns = "next,more,newer,>,›,→,»,≫,>>";
    newTabUrl = "about:newtab";
    searchUrl = "https://duckduckgo.com/?q=";
    userDefinedLinkHintCss = ''
      /* linkhint boxes */
      div > .vimiumHintMarker {
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#FFF785), color-stop(100%,#FFC542));
        border: 1px solid #E3BE23;
      }

      /* linkhint text */
      div > .vimiumHintMarker span {
        color: black;
        font-weight: bold;
        font-size: 12px;
      }

      div > .vimiumHintMarker > .matchingCharacter {
      }
    '';
  };
  vimiumFF = vimiumCommon // {
    settingsVersion = "1.67.1";
  };
  vimiumC = vimiumCommon // {
    settingsVersion = "1.67";
  };
in
{
  programs = {
    brave = {
      extensions = [
        { id = "dhdgffkkebhmkfjojejmpbldmpobfkfo"; } # tempermonkey
        {
          id = "dcpihecpambacapedldabdbpakmachpb";
          updateUrl = "https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/src/updates/updates.xml";
        }
        { id = "fihnjjcciajhdojfnbdddfaoknhalnja"; } # i don't care about cookies
        { id = "nibjojkomfdiaoajekhjakgkdhaomnch"; } # ipfs companion
        { id = "oldceeleldhonbafppcapldpdifcinji"; } # languagetool
        { id = "dneaehbmnbhcippjikoajpoabadpodje"; } # old reddit redirect
        { id = "dhhpefjklgkmgeafimnjhojgjamoafof"; } # save page we
        { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium

        { id = "nkbihfbeogaeaoehlefnkodbefgpgknn"; } # metamask
        { id = "mopnmbcafieddcagagdcbnhejhlodfdd"; } # polkadot-js
        { id = "lpilbniiabackdjcionkobglmddfbcjo"; } # waves keeper
        { id = "aiifbnbfobpmeekipheeijimdpnlpgpp"; } # terra station
        { id = "dmkamcknogkgcdfhhbddcghachkejeap"; } # keplr
        { id = "bfnaelmomeimhlpmgjnjophhpkkoljpa"; } # phantom
        { id = "fnnegphlobjdpkhecapkijjdkgcjhkib"; } # harmony wallet
        { id = "cfbfdhimifdmdehjmkdobpcjfefblkjm"; } # plug (icp)
        { id = "fhbohimaelbohpjbbldcngcnapndodjp"; } # binance wallet
      ];
    };

    firefox = {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        auto-tab-discard
        browserpass
        bypass-paywalls-clean
        i-dont-care-about-cookies
        ipfs-companion
        languagetool
        multi-account-containers
        no-pdf-download
        old-reddit-redirect
        react-devtools
        save-page-we
        ublock-origin
        vimium
        violentmonkey
      ];

      profiles.default.settings = { };
    };
  };
  xdg.configFile = {
    "vimium.ff.json".text = builtins.toJSON vimiumFF;
    "vimium.json".text = builtins.toJSON vimiumC;
  };
}
