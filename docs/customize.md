# Customize Edirom Online and content

- [Customize Edirom Online](#customize-edirom-online)
  * [Set annotation window layout](#set-annotation-window-layout)
  * [Add custom CSS](#add-custom-css)
  * [Inject custom JavaScript](#inject-custom-javascript)
  * [Set image server](#set-image-server)
  * [Customize topbar](#customize-topbar)
  * [Set a welcome window](#set-a-welcome-window)
- [Customize content](#customize-content)
  * [Table of content](#table-of-contents)
  * [SVG overlays](#svg-overlays)
  * [Windows](#windows)
- [Links](#links)
  * [Links to XML in the eXist-database](#links-to-xml-in-the-exist-database)
  * [Links from outside Edirom Online](#links-from-outside-edirom-online)
  * [JS](#js)


# Customize Edirom Online

## Set annotation window layout
Change the **layout** for annotations (3 are predefined), using predefined [preferences]
* `<entry key="annotation_layout" value="EdiromOnline.view.window.annotationLayouts.AnnotationLayout1"/>`

## Add custom CSS
Add a **custom CSS file**, using predefined edition preferences
* `<entry key="additional_css_path" value="xmldb:exist:///db/apps/edirom/edition-example/custom/style.css"/>`

For this to work, make sure that:
* the path to the edition's preferences file is correctly provided in your edition file - see an example for the [preferences file path in the EditionExample edition file](https://github.com/Edirom/EditionExample/blob/v0.2.0/content/ediromEditions/edirom_edition_example.xml#L8).
* the directory path for the edition (part after `xmldb:exist:///db/apps/`, in the example this is `/edirom/edition-example`) is correctly set in the [target info given in repo.xml](https://github.com/Edirom/EditionExample/blob/v0.2.0/repo.xml#L10)
* the relative path to the custom CSS file is correct (in the example above the last part of the URI: `custom/style.css`)

## Inject custom JavaScript
Add a **custom JS file**, using predefined edition preferences
* `<entry key="plugin_any-name" value="../path-to-edition-package/path-to-js-file/custom.js"/>`

For this to work, make sure that:
* the path to the JS file is relative to the edition's package directory, e.g. if your edition package is `db/apps/edirom/edition-example` and your JS file is located in `db/apps/edirom/edition-example/custom/custom.js`, the value of the preference should be `../custom/custom.js`
* an example can be seen in the [Bargheer edition preferences](https://github.com/Edirom/Bargheer-Edition/blob/851b5ede7407a7e20629d194876127bca6badae7/prefs.xml#L17)
* any number of JS files can be added, just make sure to use a unique name for the preference key, e.g. `plugin_custom1`, `plugin_custom2`, etc.

## Set image server 
**switch the image server** from digilib to openseadragon (IIIF), using predefined [preferences]
* `<entry key="image_server" value="openseadragon"/>`

## Customize topbar
change the **logo** of the edition
* edit [`app/view/desktop/TopBar.js`](https://github.com/Edirom/Edirom-Online/blob/f8abab67bd86cb055859be8fdb9965602477e854/app/view/desktop/TopBar.js#L72)
* then edit [`Edirom-Online/packages/eoTheme/sass/var/button/Button.scss`](https://github.com/Edirom/Edirom-Online/blob/f8abab67bd86cb055859be8fdb9965602477e854/packages/eoTheme/sass/var/button/Button.scss#L215)

de/activate **search**
* un/comment [`Edirom-Online/app/view/desktop/TopBar.js`](https://github.com/Edirom/Edirom-Online/blob/f8abab67bd86cb055859be8fdb9965602477e854/app/view/desktop/TopBar.js#L84)

de/activate **work switch**
* un/comment [`Edirom-Online/app/view/desktop/TopBar.js`](https://github.com/Edirom/Edirom-Online/blob/f8abab67bd86cb055859be8fdb9965602477e854/app/view/desktop/TopBar.js#L82)

## Set a welcome window
**define** a welcome window, using predefined [preferences]
* `<entry key="start_documents_uri" value="xmldb:exist:///db/apps/baudiData/editions/baudi-14-2b84beeb/edirom/introduction.xml"/>`

[preferences]: ../add/data/prefs/edirom-prefs.xml


# Customize content

## Table of content

On the right of an Edirom-Online you see the table of content, technically called "the Navigator". You can edit and fill this area in the `navigatorDefinition` Element of the edition-file in your data-package. An example is the [navigator](https://git.uni-paderborn.de/wega/klarinettenquintett-edirom/-/blob/main/edition/edition.xml?ref_type=heads#L13) of the clarinet quintet.

## SVG overlays
Edirom Online offers the possibility to add SVG overlays to source images that can be switched on and off dynamically. Defining such an overlay requires two steps.

**Add SVGs to facsimile**

You have to add the SVG to be displayed as overlay of a page to the respective mei:surface in the mei:facsimile tree, e.g.:

```
<music>
    <facsimile>
        <surface xml:id="edirom_surface_2fcc4e06-393d-4444-91e7-642b910773cd" n="1">
            <svg xmlns="http://www.w3.org/2000/svg" xml:id="overlay1_1" version="1.1" width="4911" height="1716" viewBox="0 0 4911 1716">
                <defs id="defs2989"/>
                <rect x="1057" y="40" width="100" height="100" rx="1093" ry="90" id="rect2995" style="opacity:0.3;fill:#ffe680" onclick="loadLink('xmldb:exist://db/contents/edition-74338556/texts/comment_sinfonia.xml',{})"/>
            </svg>
            ...
        </surface>
    </facsimile>
</music>
```

Please be aware, that Edirom does not provide a tool for generating theses SVGs, you have to use any appropriate image editing software, simple SVGs can easily be created in the XML directly, though. There are several issues that You should take care when creating the SVG.

1. The SVG element has to have an @xml:id in order to associate it with the layer definition. Otherwise it will not be displayed when the layer is being switched on in the Source-View.
2. The SVG should have the exact same proportions as the image file of the page on which it is to be displayed. The easiest way is to give it the exact same pixel dimensions, both in the @widht and @height attributes, and in the @viewbox attribute.
A feature currently under development is adding interactivity to SVG shapes. When ready this will allow to add the @onclick attribute to a shape that could trigger, e.g. loading some Ediron Online content in a new window (see above example).

**Define overlay**

In order to have the overlay displayed as option in a sources's View-Menu resp. Layers-Menu a mei:annot has to be defined in the mei:notesStmt, e.g.

```
<notesStmt>
    <annot type="overlay" xml:id="overlay1" plist="#overlay1_1 #overlay1_68">
        <title>Title to be shown in Menu</title>
    </annot>
</notesStmt>
```

The mei:annot has to be conform to the following issues:
1. @type="overlay"
2. @xml:id has to be present
3. @plist has to contain IDREFs to all SVG elements in the source that shall be associated with the corresponding entry in the View-Menu, i.e. the SVG elements of all facsimile surfaces that shall be displayed when the layer is set visible. Of course the overlay will only display the SVG associated with the source-page currently displayed.

## Windows

**dimensions of content windows**: when opened e.g. from the Navigator, window height is set to the max. desktop height, width is set to x% of the desktop's width. You can set the initial width of every content window by propagating it together with the calling link in the navigator in [edition].xml:
* `<navigatorItem xml:id="navItem-1" sortNo="1  targets="xmldb:exist:///db/contents/PathToYourSourcesFolder/source.xml[width:500]">
    <names>
        <name>Score</name>
    </names>
</navigatorItem>`
