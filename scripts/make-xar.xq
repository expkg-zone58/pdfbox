(: build xar:)
import module namespace build = 'urn:quodatum:build1' at 'build.xqm';

let $xar:=build:xar-create()
let $output-file := build:xar-path()
return (build:write-binary($output-file, $xar),
        trace($output-file,"xar: "))
