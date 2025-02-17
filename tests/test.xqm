(:~ tests for pdfbox3

 :)
module namespace test="urn:expkg-zone58:pdfbox3:tests";
import module namespace pdfbox="org.expkg_zone58.Pdfbox3";

declare variable $test:base:=file:base-dir()=>file:parent();

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
function test:extract(){
 let $pdf:=test:open("samples.pdf/BaseX100.pdf")
 let $dest:=file:create-temp-file("test",".pdf")=>trace("DEST: ")
 let $bin:=pdfbox:extract($pdf,2,12)
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

(:~ get PDF from url :)
declare %unit:test
function test:with-url(){
 let $url:="https://files.basex.org/publications/Gath%20et%20al.%20%5b2009%5d,%20INEX%20Efficiency%20Track%20meets%20XQuery%20Full%20Text%20in%20BaseX.pdf"

 let $count:=pdfbox:with-pdf($url,pdfbox:page-count#1)
 return unit:assert-equals($count,6)
};

(:~ password missing  :)
declare %unit:test("expected", "pdfbox:open")
function test:password-bad(){
 let $pdf:=test:open("samples.pdf/page-numbers-password.pdf")
 return unit:assert(true())
};

(:~password good  :)
declare %unit:test
function test:password-good(){
 let $pdf:=test:open("samples.pdf/page-numbers-password.pdf",map{"password":"password"})
 return unit:assert(true())
};

(:~ Test for pdfbox:binary function :)
declare %unit:test
function test:binary(){
    let $pdf:=test:open("samples.pdf/BaseX100.pdf")
    let $binary:=pdfbox:binary($pdf)
    return unit:assert(exists($binary))
};

(:~ Test for pdfbox:save function :)
declare %unit:test
function test:save(){
    let $pdf:=test:open("samples.pdf/BaseX100.pdf")
    let $dest:=file:create-temp-file("test-save",".pdf")
    let $savedPath:=pdfbox:save($pdf, $dest)
    return unit:assert-equals($savedPath, $dest)
};

(:~ Test for pdfbox:property function :)
declare %unit:test
function test:property(){
    let $pdf:=test:open("samples.pdf/BaseX100.pdf")
    let $pages:=pdfbox:property($pdf, "pageCount")
    return unit:assert(true())
};

(:~ Test for pdfbox:property function :)
declare %unit:test("expected", "pdfbox:property")
function test:property-bad(){
    let $pdf:=test:open("samples.pdf/BaseX100.pdf")
    let $title:=pdfbox:property($pdf, "totle")
    return unit:assert(exists($title))
};
(:~ Test for pdfbox:defined-properties function :)
declare %unit:test
function test:defined-properties(){
    let $properties:=pdfbox:defined-properties()
    return unit:assert(exists($properties))
};

(:~ Test for pdfbox:report function :)
declare %unit:test
function test:report(){
    let $pdfPaths:=("samples.pdf/BaseX100.pdf", "samples.pdf/icelandic-dictionary.pdf")
                  !test:resolve(.)
    let $report:=pdfbox:report($pdfPaths)
    return unit:assert(exists($report?names) and exists($report?records))
};

(:~ Test for pdfbox:hasOutline function :)
declare %unit:test
function test:hasOutline(){
    let $pdf:=test:open("samples.pdf/BaseX100.pdf")
    let $hasOutline:=pdfbox:hasOutline($pdf)
    return unit:assert(not($hasOutline))
};

(:~ Test for pdfbox:hasLabels function :)
declare %unit:test
function test:hasLabels(){
    let $pdf:=test:open("samples.pdf/BaseX100.pdf")
    let $hasLabels:=pdfbox:hasLabels($pdf)
    return unit:assert($hasLabels)
};



(:---------------------------------------:)
declare function test:open($file as xs:string,$opts as map(*))
as item(){
    test:resolve($file)=>pdfbox:open($opts)
};

declare function test:open($file as xs:string)
as item(){
    test:open($file,map{})
};
declare function test:resolve($file as xs:string)
as item(){
    file:resolve-path($file,$test:base)
};