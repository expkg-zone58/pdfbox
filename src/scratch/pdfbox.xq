(: PDFBOX experiments
:)

import module namespace pdfbox="urn:expkg-zone58:pdfbox3" at "../lib/pdfbox3.xqm";


declare variable $samples:= map{
    "climate":  "data\drop-01d\set\2-6-1\A5579C_1\271989---Book_File-Web_PDF_9798400627484_486728.pdf",
    "women":    "data\drop-01d\set\2-6-1\A6229C_1\257334---Book_File-Web_PDF_9798216172628_486742.pdf",
    "genocide": "data\drop1-pdf\GR2967-TRD\272791---Book_File-Web_PDF_9798400640216_486366.pdf",
    "world":    "data\drop-01c\gpg-book\2-6\A3506C-TRD\256186---Book_File-Web_PDF_9798216038955_486148.pdf"
};
declare variable $base:= "C:\Users\mrwhe\git\bloomsbury\content-architecture\xquery\ABC-CLIO\data";
(:~ resolve :)
declare variable $PDF:= 
$samples?world=>file:resolve-path($base)
(: "C:\Users\mrwhe\git\expkg-zone58\pdfbox\samples.pdf\icelandic-dictionary.pdf" :)
;



let $doc:=pdfbox:open($PDF)

return pdfbox:information($doc)