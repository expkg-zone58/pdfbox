
import module namespace build = 'urn:quodatum:build1' at 'build.xqm';

declare variable $files := (
"https://repo1.maven.org/maven2/org/apache/pdfbox/pdfbox/3.0.4/pdfbox-3.0.4.jar",
"https://repo1.maven.org/maven2/org/apache/pdfbox/pdfbox-io/3.0.4/pdfbox-io-3.0.4.jar",
"https://repo1.maven.org/maven2/org/apache/pdfbox/fontbox/3.0.4/fontbox-3.0.4.jar",
"https://repo1.maven.org/maven2/commons-logging/commons-logging/1.3.4/commons-logging-1.3.4.jar"
);



let $base:= file:resolve-path("../",static-base-uri())
let $target:=file:resolve-path("jars/",$base)
for $f in $files
let $n:=replace($f,"^.*/","") =>trace("N")
return file:write-binary($target || $n, fetch:binary($f))