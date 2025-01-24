
import module namespace build = 'urn:quodatum:build1' at 'build.xqm';

(: Main execution
Main-Class: org.basex.modules.Hello
 :)
let $config :=map { 
         "manifest-jar" : "pdfbox-3.0.3.jar", 
         "input-dir" :  "C:\Users\mrwhe\git\expkg-zone58\pdfbox\jars\", 
         "output" :  "../lib/pdfbox-3.0.3.fat.jar",
         "main-class": "org.expkg_zone58.Pdfbox3" 
         }

let $fat-jar := build:fatjar-from-folder($config?input-dir,$config?manifest-jar)

let $fat-jar:=build:update-manifest($fat-jar, $config?main-class)
let $name:=replace($config?main-class,"\.","/") || ".xqm"
let $content:=file:read-binary($config?input-dir || "Pdfbox3.xqm")
let $fat-jar:=archive:update($fat-jar, $name,$content)
let $output-file := file:resolve-path($config?output, $config?input-dir)
return (file:write-binary($output-file, $fat-jar),
        trace($output-file,"fat jar: "))
  