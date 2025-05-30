(: WIP :)
import module namespace build = 'urn:quodatum:build1' at 'build.xqm';

declare variable $base:= file:resolve-path("../",static-base-uri())=>trace("base ");

        
let $jar-path:=$build:base || "jars/"=>trace("jar: ")
 let $_:=build:maven-download($build:PKG?expkg_zone58?maven2=>array:flatten(),
                              $build:base || "jars/")

let $fat-jar := build:fatjar-from-folder($jar-path,$build:PKG?expkg_zone58?manifest-jar)

let $fat-jar:=build:update-manifest($fat-jar, $build:PKG?expkg_zone58?main-class)
let $name:=replace($build:PKG?expkg_zone58?main-class,"\.","/") || ".xqm"
let $content:=file:read-binary($base || "src/Pdfbox3.xqm")
let $fat-jar:=archive:update($fat-jar, $name,$content)
let $output-file := file:resolve-path($build:PKG?expkg_zone58?output,$base)
return (build:write-binary($output-file, $fat-jar),
        trace($output-file,"fat jar: "))
  