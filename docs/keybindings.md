# Keyboard Bindings

Overview of all keyboard bindings implemented across the Edirom Online views, windows
and panels. The bindings live in the **Edirom-Online-Frontend** repository; file paths
below are relative to that repo's `app/` (and `ext-ux/`) directories.

Edirom Online uses three distinct mechanisms for keyboard input:

| Mechanism | Where used | Notes |
|---|---|---|
| `Ext.util.KeyMap` (`getKeyMap()` + `addBinding`) | Window-level shortcuts | Bindings reference the `Ext.event.Event.*` key constants. |
| `specialkey` event | Text fields | Fires for ENTER, ESC, TAB, arrows, etc.; handler inspects `e.getKey()`. |
| `keyup` listener | Grid filter inputs (ext-ux) | Handler inspects `e.getKey()`. |

In every `specialkey` / `keyup` handler, `e` is the event instance passed to the handler,
so the key constants are read as `e.ENTER`, `e.ESC`, `e.RETURN` (inherited from
`Ext.event.Event`).

---

## Source Viewer — "Go to" dialog

Class `EdiromOnline.view.window.source.GotoMsg`
([`app/view/window/source/SourceView.js`](../../Edirom-Online-Frontend/app/view/window/source/SourceView.js)),
a prompt for jumping to a measure / movement. Bindings registered in `initKeys()` via an
`Ext.util.KeyMap`:

| Key | Action |
|---|---|
| **Enter** | Submit the entered value — runs the goto `callback`, then closes the dialog (`gotoFn`). |
| **Esc** | Close the dialog without navigating (`close`). |

---

## Desktop — top search field

Controller `EdiromOnline.controller.desktop.Desktop`
([`app/controller/desktop/Desktop.js`](../../Edirom-Online-Frontend/app/controller/desktop/Desktop.js)).
Target component: `topbar #searchTextFieldTop`. Handler: `onSpecialKey`.

| Key | Action |
|---|---|
| **Enter** | Open the search window for the term currently in the field. |

---

## Search Window — search field

Controller `EdiromOnline.controller.window.search.SearchWindow`
([`app/controller/window/search/SearchWindow.js`](../../Edirom-Online-Frontend/app/controller/window/search/SearchWindow.js)).
Target component: `searchWindow #searchTextField`. Handler: `onSpecialKey`.

| Key | Action |
|---|---|
| **Enter** | Run the search (`doSearch`) with the field's value. |

---

## Concordance Navigator — item selection field

View `EdiromOnline.view.window.concordanceNavigator.ConcordanceNavigator`
([`app/view/window/concordanceNavigator/ConcordanceNavigator.js`](../../Edirom-Online-Frontend/app/view/window/concordanceNavigator/ConcordanceNavigator.js)).
Target: the item-selection text field. Handler: `specialKeyOnInput`.

| Key | Action |
|---|---|
| **Enter** | Apply the entered value to the slider; if it is invalid, reset the field to the slider's current value. Then blur the field and show the selected connection. |
| **Esc** | Reset the field to the slider's current value (discard the edit). |

---

## Grid filters (ext-ux)

Third-party grid-filter UX bundled under `ext-ux/`. Each filter input hides its menu when
the user confirms a valid value. Handler: `onInputKeyUp` (a `keyup` listener).

| Component | Key | Action |
|---|---|---|
| Range filter menu ([`ext-ux/grid/menu/RangeMenu.js`](../../Edirom-Online-Frontend/ext-ux/grid/menu/RangeMenu.js)) | **Enter** | If the field is valid: stop the event and hide the menu. |
| String filter ([`ext-ux/grid/filter/StringFilter.js`](../../Edirom-Online-Frontend/ext-ux/grid/filter/StringFilter.js)) | **Enter** | If the field is valid: stop the event and hide the menu (otherwise the update timer restarts). |
| Date filter ([`ext-ux/grid/filter/DateFilter.js`](../../Edirom-Online-Frontend/ext-ux/grid/filter/DateFilter.js)) | **Enter** | If the field is valid: stop the event and hide the menu. |

---

## Notes

- There are **no application-wide / global keyboard shortcuts**; every binding is scoped to
  the window, panel or input field listed above.
- Some viewers (e.g. the OpenSeaDragon image viewer) provide zoom / pan interaction through
  their own libraries rather than Ext key bindings, and are therefore not listed here.
