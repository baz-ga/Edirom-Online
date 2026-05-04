# Links

## Links to XML in the eXist-database

_Edirom Online_ generally uses xmldb-scheme URIs to open content.

**Link to source**
* opening default view: `xmldb:exist:///ABSOLUTE-PATH-TO-RESOURCE`, e.g. `xmldb:exist:///db/contents/edition-12345678/sources/source1.xml`

**Open a specified location in the source**
* `xmldb:exist:///ABSOLUTE-PATH-TO-RESOURCE#XML-ID`
  * e.g., a page `xmldb:exist:///db/contents/edition-12345678/sources/source1.xml#edirom_surface_87c87e5d-37bc-463d-9f13-6d2940472db2`
  * e.g., a measure `xmldb:exist:///db/apps/contents/musicSources/freidi-musicSource_A.xml#A_mov0_measure11`
  * to specify multiple resources, concatenate their xmldb URIs with `;`: `[xmldb-URI];[xmldb-URI]`

## Links from outside Edirom Online

**Link to Edirom Online**
* Depending on the domain of your deployment, the server setup, etc., in a standard local server environment, this might be: `http://localhost:8080/exist/apps/EdiromOnline/`
* Link to Edirom Online setting the active edition `http://localhost:8080/exist/apps/EdiromOnline?edition=[EDITION-ID]`
* Link to Edirom Online setting the active work `http://localhost:8080/exist/apps/EdiromOnline?work=[WORK-ID]`. This will automatically also set the `activeEdition`.

**Link to Edirom Online opening a specified window/object**
* In addition to the above ‘link to Edirom Online’, use the `uri` parameter to supply a xmldb-uri ([see above](#Links-to-xml-in-the-exist-database)) to the database content that should be opened in Edirom Online, e.g.: `http://localhost:8080/exist/apps/EdiromOnline/?uri=xmldb:exist:///db/apps/contents/audioSources/freidi-recording_Janowski1994.xml`
* Edirom Online will open the objects in their respective default view and window size.

**Link to Edirom Online opening multiple specified windows/objects**
* As the above plus append additional resource-links separated by `;`, e.g.: `http://localhost:8080/exist/apps/EdiromOnline/?uri=xmldb:exist:///db/apps/contents/audioSources/freidi-recording_Janowski1994.xml;xmldb:exist:///db/apps/contents/librettoSources/freidi-librettoSource_KA-tx4.xml`

## JS

The function-handling links in Edirom Online are defined by the [app/controller/LinkController.js](https://github.com/Edirom/Edirom-Online/blob/develop/app/controller/LinkController.js) as follows:
```js
loadLink: function(uri, cfg){ ... }
```

The two parameters given are:
* **uri** any URI; nevertheless, there are mechanisms for relative or absolute links and some special cases for certain URI-schemes such as `edirom` or `xmldb:exist`
* **cfg** is a JS object containing various options for defining things such as opening a link in a new _Edirom Online_ window or defining the width of the opened window.

***Examples***

* open **object window** in default view with default parameters
```js
loadLink('xmldb:exist:///db/apps/contents/audioSources/freidi-recording_Janowski1994.xml',{});
```
* open **target element** in its default view (e.g. open a specific measure of a music source in measureBasedView)
```js
loadLink('xmldb:exist:///db/apps/contents/musicSources/freidi-musicSource_A.xml#A_mov0_measure11',{});
```
* open object window in default view with **defined window width**
```js
loadLink('xmldb:exist:///db/apps/contents/audioSources/freidi-recording_Janowski1994.xml',{width:'600px'});
```
* **Update a window** that’s already displaying a resource
  * If the resource is not open in any window, a new window will be opened
  ```js
  window.parent.loadLink('xmldb:exist:///db/apps/contents/musicSources/freidi-musicSource_A.xml#A_mov0_measure11', {useExisting:true});
  ```
  * If the resource is not open in any window, ignore the link
  ```js
  window.parent.loadLink('xmldb:exist:///db/apps/contents/musicSources/freidi-musicSource_A.xml#A_mov0_measure11', {onlyExisting:true});
  ```
* Open **multiple resources**
```js
window.parent.loadLink('xmldb:exist:///db/apps/contents/audioSources/freidi-recording_Janowski1994.xml;xmldb:exist:///db/apps/contents/musicSources/freidi-musicSource_A.xml#A_mov0_measure11');
```
  * Additionally, sort the resources after they have been opened (at the moment, this option only supports the `sortGrid` option)
  ```js
  window.parent.loadLink('xmldb:exist:///db/apps/contents/audioSources/freidi-recording_Janowski1994.xml', {sort:’sortGrid'});
  ```
  * If at the same instance, windows that are already opened (an array of window-objects) should be included in the sort. This is  used with the “open all” Button in annotation windows to include the annotation window in the sort
  ```js
  window.parent.loadLink('xmldb:exist:///db/apps/contents/audioSources/freidi-recording_Janowski1994.xml', {sort:’sortGrid’,sortIncludes:[win1,win2]});
  ```
