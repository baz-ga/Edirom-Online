xquery version "3.1";
(:
 : For LICENSE-Details please refer to the LICENSE file in the root directory of this repository.
 :)

(: IMPORTS ================================================================= :)

import module namespace functx = "http://www.functx.com";

import module namespace eutil = "http://www.edirom.de/xquery/eutil" at "/db/apps/Edirom-Online/data/xqm/eutil.xqm";

(: NAMESPACE DECLARATIONS ================================================== :)

declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";

(: OPTION DECLARATIONS ===================================================== :)

declare option output:method "json";
declare option output:media-type "application/json";

(: FUNCTION DECLARATIONS =================================================== :)

declare function local:getMeasures($meiUri as xs:anyURI, $mdivID as xs:ID) as array(*)* {
    
    let $mdiv := doc($meiUri)/id($mdivID)
    
    let $mdivMeasureLabels := distinct-values($mdiv//mei:measure/@label)
    
    let $measureNs :=
        if ($mdivMeasureLabels != ()) then (
            for $label in $mdivMeasureLabels
            let $labelsAnalyzed :=
                if (contains($label, '–')) then (
                    (:substring-before($label, '–'):)
                    let $first := substring-before($label, '–')
                    let $last := substring-after($label, '–')
                    let $steps := xs:integer(number($last) - number($first) + number(1))
                    for $i in 1 to $steps
                    return
                        string(number($first) + $i - 1)
                ) else
                    ($label)
            return
                $labelsAnalyzed
        ) else
            distinct-values($mdiv//mei:measure/@n)
    
    let $measureNs := eutil:sort-as-numeric-alpha($measureNs)
    
    return array {
        if($mdiv//mei:parts) then (
            (: process encoded parts :)
            
            for $measureN in $measureNs
            
            let $measureNNumber := number($measureN)
            
            let $measures :=
                if ($mdivMeasureLabels != ()) then
                    ($mdiv//mei:measure[.//mei:multiRest][number(substring-before(@label, '–')) <= $measureNNumber][.//mei:multiRest/number(@num) gt ($measureNNumber - number(substring-before(@label, '–')))])
                else
                    ($mdiv//mei:measure[.//mei:multiRest][number(@n) lt $measureNNumber][.//mei:multiRest/number(@num) gt ($measureNNumber - number(@n))])
            
            let $measures :=
                for $part in $mdiv//mei:part
                
                let $partMeasures :=
                    if ($mdivMeasureLabels != ()) then
                        ($part//mei:measure[@label = $measureN][1])
                    else
                        ($part//mei:measure[@n = $measureN][1])
                
                for $measure in $partMeasures | $measures[ancestor::mei:part = $part]
                
                let $voiceRef := $part//mei:staffDef/string(@decls)
                
                return
                    map {
                        "id": $measure/string(@xml:id),
                        "voice": $voiceRef,
                        "partLabel": eutil:getPartLabel($measure, 'measure')
                    }
            
            return
                map {
                    "id": 'measure_' || $mdiv/@xml:id || '_' || $measureN,
                    "measures": $measures,
                    "mdivs": array { $mdiv/string(@xml:id) },
                    "name": $measureN
                }
        
        ) else (
            (: process an mei:score :)
            if ($mdivMeasureLabels != ()) then (
                for $measureN in $mdivMeasureLabels
                
                (: multiple measure with the same label can occur if the measure breaks a system, getting all of them :)
                let $measures := $mdiv//mei:measure[@label = $measureN]
                
                let $measure := $measures[1]
                
                return
                    map {
                        "id": $measure/string(@xml:id),
                        "measures": array { map { "id": $measure/string(@xml:id), "voice": "score"} },
                        "mdivs": array { $measure/ancestor::mei:mdiv[1]/string(@xml:id) }, (: TODO :)
                        "name": $measureN (: Hier Unterscheiden wg. Auftakt. :)
                    }
            
            ) else (
                for $measureN in $mdiv//mei:measure/data(@n)
                
                (: multiple measure with the same label can occur if the measure breaks a system, getting all of them  :)
                let $measures := $mdiv//mei:measure[@n = $measureN]
                
                let $measure := $measures[1]
                
                return
                    map {
                        "id": $measure/string(@xml:id),
                        "measures": array { map { "id": $measure/string(@xml:id), "voice": "score"} },
                        "mdivs": array { $measure/ancestor::mei:mdiv[1]/string(@xml:id) }, (: TODO :)
                        "name": $measureN (: Hier Unterscheiden wg. Auftakt. :)
                    }
            )
        )
    }
};

(: QUERY BODY ============================================================== :)

let $meiUri := request:get-parameter('uri', '')
let $mdivID := request:get-parameter('mdiv', '')

return
    local:getMeasures($meiUri, $mdivID)
