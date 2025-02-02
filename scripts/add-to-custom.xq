
import module namespace build = 'urn:quodatum:build1' at 'build.xqm';
declare variable $base:= file:parent(db:system()/globaloptions/dbpath/string());



"
copy..
",
file:copy(
    "dist/pdfbox-3.0.4.fat.jar"=>trace("Source: "),
    file:resolve-path("lib/custom",$base)=>trace("Dest: ")
    ),
file:list(file:resolve-path("lib/custom",$base)),
"
"
