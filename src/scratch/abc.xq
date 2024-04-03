(: test use of pageIndex :)
import module namespace pdfbox="urn:expkg-zone58:pdfbox:3" at "../src/lib/pdfbox3.xqm";
import module namespace pagenos = 'urn:pageno' at "../src/lib/pageno.xqm";
declare variable $base:=file:base-dir();
declare function local:go($doc,$pdf as element(pdf)){
  let $range:=$pdf/@pages/tokenize(.,"–")
  let $start:=$range[1]
  let $end:=if(count($range) eq 1) then $range[1] else $range[2]

  return ``[ `{$start}` ;;; `{ $end }` ]``
};
let $src:="257107---Book_File-Web_PDF_9798400691218_486731.pdf"=>file:resolve-path($base)
let $doc:=pdfbox:open($src)
let $labels:= pdfbox:getPageLabels($doc)
let $pdfs:=doc("pdfs\chunks-docbook.xml")/chunks/pdf
for $pdf in $pdfs
let $range:=$pdf/@pages/tokenize(.,"–")
let $start:=$range[1]
let $end:=if(count($range) eq 1) then $range[1] else $range[2]
let $startIndex:=index-of($labels,$start)
let $endIndex:=index-of($labels,$end)
return if(exists($startIndex) and exists($endIndex))
       then $pdf/@pages || " " || $startIndex || ":" || $endIndex
       (: pdfbox:extract($doc,$startIndex,$endIndex,file:resolve-path($pdf/@fileref,$base)) :)
       else $pdf/@pages

