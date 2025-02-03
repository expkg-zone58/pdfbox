
import module namespace build = 'urn:quodatum:build1' at 'build.xqm';

declare variable $base:= file:resolve-path("../",static-base-uri())=>trace("base ");

declare variable $maven-urls := (
"org/apache/pdfbox/pdfbox/3.0.4/pdfbox-3.0.4.jar",
"org/apache/pdfbox/pdfbox-io/3.0.4/pdfbox-io-3.0.4.jar",
"org/apache/pdfbox/fontbox/3.0.4/fontbox-3.0.4.jar",
"commons-logging/commons-logging/1.3.4/commons-logging-1.3.4.jar"
);
let $_:=build:maven-download($maven-urls,$base || "jars/")
let $xar:=build:xar-create($base)
let $output-file := file:resolve-path("dist/pdfbox.xar",$base)
return (build:write-binary($output-file, $xar),
        trace($output-file,"zar: "))
