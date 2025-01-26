(:~ describe book page numbering :)

import module namespace pdfbox="urn:expkg-zone58:pdfbox3" ;
import module namespace bookpages="urn:bookpages" at "../lib/bookpages.xqm";
import module namespace pdfscrape="urn:pdfscrape" at "../lib/pdfscrape.xqm";

declare variable $base:="C:\Users\mrwhe\Desktop\1e\";
declare variable $tests:=map{
  "simple":"20#C,R,7D",
  "set\2-6-2\A5267C": "1037#C,r,28D,520r:V2,526D@493",
  "gpg-book\2-3\A3581C-TRD": "848#C,r:Vol1:,28D,400r:Vol2:,438D@401"
};
let $pdf:=pdfbox:open("C:\Users\mrwhe\Desktop\1e\set\2-6-2\A5267C\257273---Book_File-Web_PDF_9798400612572_486638.pdf")
let $l:=pdfbox:getPageLabels($pdf)

let $index:=bookpages:expand($tests?"set\2-6-2\A5267C")
return pdfscrape:score($l,pdfscrape:page-report($pdf))



