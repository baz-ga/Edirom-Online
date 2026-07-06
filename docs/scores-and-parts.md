# Scores and Parts in _Edirom Online_

## Parts

In _measureBasedView_ several display options are available for musical parts. In
order to determine whether a source object has parts encoded the following criteria
have to be met:

1. There hast to be a definition of performance resources either with `mei:perfMedium` element somewhere in the file that encodes a `mei:perfRes`, or for older MEI an `mei:isntrumentation` with `mei:instVoice` for each part.
2. The above definitions of the performance resources must have `@label` and `@xml:id` encoded.
3. The parts have to be encoded using `mei:part`
4. The `mei:part` elements have to contain a `mei:staffDef` pointing to a `mei:perfRes` or `mei:instVoice` (older MEI) using `@decls`

---
facilitated 2026 by the Bernd Alois Zimmermann-Gesamtasugabe through Benjamin W. Bohl
