
import module namespace build = 'urn:quodatum:build1' at 'build.xqm';
declare variable $base:= file:resolve-path("../",static-base-uri())=>trace("base ");

declare variable $custom:= "/usr/local/basex/lib/custom/";

"
copy..
",
file:copy(file:resolve-path("dist/pdfbox-3.0.4.fat.jar",$base)=>trace("Source: ")
         ,$custom),
file:list($custom),
"
"
