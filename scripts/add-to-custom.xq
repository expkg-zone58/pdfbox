
import module namespace build = 'urn:quodatum:build1' at 'build.xqm';

declare variable $custom:= "/usr/local/basex/lib/custom/";
declare variable $base:=file:parent(db:system()/globaloptions/dbpath/string());
"
copy..
",
file:copy(file:resolve-path("dist/pdfbox-3.0.4.fat.jar",$base)=>trace("Source: ")
         ,$custom),
file:list($custom),
"
"
