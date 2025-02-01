declare base-uri '../';
import module namespace build = 'urn:quodatum:build1' at 'build.xqm';

declare variable $custom:= "/usr/local/basex/lib/custom/";
declare $jar:=file:parent(static-base-uri())
"copy..",
file:copy("dist/pdfbox-3.0.4.fat.jar",$custom),
file:list($custom)
