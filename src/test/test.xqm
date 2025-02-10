(:~ tests for pdfbox3

 :)
module namespace test="urn:expkg-zone58:pdfbox3:tests";
import module namespace pdfbox="org.expkg_zone58.Pdfbox3";

declare variable $test:base:=file:base-dir()=>file:parent()=>file:parent();


declare %unit:test
function test:pdfbox-version(){
    let $v:= pdfbox:version()=>trace("VER: ")
    return unit:assert-equals($v,"3.0.4")
};

declare %unit:test
function test:specification(){
    let $pdf:=test:open("samples.pdf/BaseX100.pdf")
    let $spec:=pdfbox:specification($pdf)
    return unit:assert-equals($spec,"1.4")
};

declare %unit:test
function test:page-count(){
    let $pdf:=test:open("samples.pdf/BaseX100.pdf")
    let $pages:=pdfbox:page-count($pdf)
    return unit:assert-equals($pages,521)
};

declare %unit:test
function test:outline-none(){
let $pdf:=test:open("samples.pdf/BaseX100.pdf")
 let $outline:=pdfbox:outline($pdf)
 return unit:assert(empty($outline))
};

declare %unit:test
function test:outline-present(){
 let $pdf:=test:open("samples.pdf/icelandic-dictionary.pdf")
 let $outline:=pdfbox:outline($pdf)
 return unit:assert(exists($outline))
};

declare %unit:test
function test:outline-xml(){
 let $pdf:=test:open("samples.pdf/icelandic-dictionary.pdf")
 let $outline:=pdfbox:outline-xml($pdf)
 return unit:assert-equals(count($outline/bookmark),31)
};

declare %unit:test
function test:labels(){
  let $pdf:=test:open("samples.pdf/BaseX100.pdf")

 let $labels:=pdfbox:labels($pdf) 
 return (
   unit:assert-equals(count($labels),pdfbox:page-count($pdf)),
   unit:assert($labels[1]="i") ,
   unit:assert($labels[27]="1")
 )
};

declare %unit:test
function test:extract-save(){
 let $pdf:=test:open("samples.pdf/BaseX100.pdf")
 let $dest:=file:create-temp-file("test",".pdf")=>trace("DEST: ")
 let $outline:=pdfbox:extract($pdf,2,12,$dest)
 return unit:assert(true())
};

declare %unit:test
function test:page-text(){
let $pdf:=test:open("samples.pdf/BaseX100.pdf")
 let $text:=pdfbox:page-text($pdf,1)
 return unit:assert(starts-with($text,"BaseX Documentation"))
};

declare %unit:test
function test:page-image(){
 let $pdf:=test:open("samples.pdf/BaseX100.pdf")
 let $image:=pdfbox:page-image($pdf,0,map{})
 return unit:assert(true())
};

declare %unit:test
function test:with-pdf(){
 let $path:=test:resolve("samples.pdf/BaseX100.pdf")
 let $txt:=pdfbox:with-pdf($path,pdfbox:page-text(?,101))
 return unit:assert(starts-with($txt,"Options"))
};

declare function test:open($file as xs:string)
as item(){
    test:resolve($file)=>pdfbox:open()
};

declare function test:resolve($file as xs:string)
as item(){
    file:resolve-path($file,$test:base)
};