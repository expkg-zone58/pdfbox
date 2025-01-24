(:~ tests for pdfbox3

 :)
module namespace test="urn:expkg-zone58:pdfbox3:tests";
import module namespace pdfbox="org.expkg-zone58.Pdfbox3";

declare variable $test:base:=file:base-dir()=>file:parent()=>file:parent();

declare %unit:test
function test:pdfbox-version(){
  unit:assert(starts-with(pdfbox:version(),"3.0"))
};

declare %unit:test
function test:page-count(){
    let $PDF:="samples.pdf/BaseX100.pdf"=>test:resolve()
    let $pages:=pdfbox:open($PDF)=>pdfbox:page-count()
    return unit:assert-equals($pages,521)
};

declare %unit:test
function test:outline-none(){
 let $PDF:="samples.pdf/BaseX100.pdf"=>test:resolve()
 let $outline:=pdfbox:open($PDF)=>pdfbox:outline()
 return unit:assert(empty($outline))
};

declare %unit:test
function test:outline-present(){
 let $PDF:="samples.pdf/icelandic-dictionary.pdf"=>test:resolve()
 let $outline:=pdfbox:open($PDF)=>pdfbox:outline()
 return unit:assert(exists($outline))
};

declare %unit:test
function test:outline-xml(){
 let $PDF:="samples.pdf/icelandic-dictionary.pdf"=>test:resolve()
 let $outline:=pdfbox:open($PDF)=>pdfbox:outline()=>pdfbox:outline-xml()
 return unit:assert-equals(count($outline/bookmark),31)
};

declare %unit:test
function test:pagelabels(){
 let $PDF:="samples.pdf/BaseX100.pdf"=>test:resolve()
 let $labels:=pdfbox:open($PDF)=>pdfbox:pageLabels()
 return (
   unit:assert($labels[1]="i") ,
   unit:assert($labels[27]="1")
 )
};

declare %unit:test
function test:save(){
 let $dest:=file:create-temp-file("test",".pdf")=>trace("DEST: ")
 let $PDF:="samples.pdf/BaseX100.pdf"=>test:resolve()
 let $outline:=pdfbox:open($PDF)=>pdfbox:extract(2,12,$dest)
 return unit:assert(true())
};

declare %unit:test
function test:page-text(){
 let $PDF:="samples.pdf/BaseX100.pdf"=>test:resolve()
 let $text:=pdfbox:open($PDF)=>pdfbox:getText(1)
 return unit:assert(starts-with($text,"BaseX Documentation"))
};

declare function test:resolve($file as xs:string){
    file:resolve-path($file,$test:base)
};
