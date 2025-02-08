
import module namespace build = 'urn:quodatum:build1' at 'build.xqm';

let $_:=build:maven-download($build:PKG?quodatum?maven=>array:flatten(),$build:base || "jars/")
let $xar:=build:xar-create()
let $output-file := build:xar-path()
return (build:write-binary($output-file, $xar),
        trace($output-file,"xar: "))
