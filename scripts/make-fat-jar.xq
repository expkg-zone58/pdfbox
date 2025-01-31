
import module namespace build = 'urn:quodatum:build1' at 'build.xqm';

declare variable $maven-urls := (
"org/apache/pdfbox/pdfbox/3.0.4/pdfbox-3.0.4.jar",
"org/apache/pdfbox/pdfbox-io/3.0.4/pdfbox-io-3.0.4.jar",
"org/apache/pdfbox/fontbox/3.0.4/fontbox-3.0.4.jar",
"commons-logging/commons-logging/1.3.4/commons-logging-1.3.4.jar"
);

let $config :=map { 
         "base": file:resolve-path("../",static-base-uri()),
         "manifest-jar" : "pdfbox-3.0.4.jar", 
         "input-dir" :  "jars/", 
         "output" :  "dist/pdfbox-3.0.4.fat.jar",
         "main-class": "org.expkg_zone58.Pdfbox3" 
         }
let $jar-path:=file:resolve-path($config?input-dir,$config?base=>trace("base "))=>trace("jar: ")
let $_:=build:maven-download($maven-urls,$jar-path)
let $fat-jar := build:fatjar-from-folder($jar-path,$config?manifest-jar)

let $fat-jar:=build:update-manifest($fat-jar, $config?main-class)
let $name:=replace($config?main-class,"\.","/") || ".xqm"
let $content:=file:read-binary($config?base || "src/Pdfbox3.xqm")
let $fat-jar:=archive:update($fat-jar, $name,$content)
let $output-file := file:resolve-path($config?output,$config?base)
return (file:write-binary($output-file, $fat-jar),
        trace($output-file,"fat jar: "))
  