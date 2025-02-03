
import module namespace build = 'urn:quodatum:build1' at 'build.xqm';

declare variable $base:= file:resolve-path("../",static-base-uri())=>trace("base ");
let $xar:=build:xar-create($base)
let $output-file := file:resolve-path("dist/pdfbox.xar",$base)
return (build:write-binary($output-file, $xar),
        trace($output-file,"zar: "))
