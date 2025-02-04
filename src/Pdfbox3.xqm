xquery version '3.1';
(:~ 
pdfbox 3.0 https://pdfbox.apache.org/ BaseX 10.7+ interface library, 
requires pdfbox jar on classpath, tested with pdfbox-app-3.0.4.jar
@see download https://pdfbox.apache.org/download.cgi
@javadoc https://javadoc.io/static/org.apache.pdfbox/pdfbox/3.0.4/

:)
module namespace pdfbox="org.expkg_zone58.Pdfbox3";

declare namespace Loader ="java:org.apache.pdfbox.Loader"; 
declare namespace PDFTextStripper = "java:org.apache.pdfbox.text.PDFTextStripper";
declare namespace PDDocument ="java:org.apache.pdfbox.pdmodel.PDDocument";

declare namespace PDDocumentCatalog ="java:org.apache.pdfbox.pdmodel.PDDocumentCatalog";
declare namespace PDPageLabels ="java:org.apache.pdfbox.pdmodel.common.PDPageLabels";

declare namespace PageExtractor ="java:org.apache.pdfbox.multipdf.PageExtractor";
 
declare namespace PDPageTree ="java:org.apache.pdfbox.pdmodel.PDPageTree";

declare namespace PDDocumentOutline ="java:org.apache.pdfbox.pdmodel.interactive.documentnavigation.outline.PDDocumentOutline";

declare namespace PDDocumentInformation ="java:org.apache.pdfbox.pdmodel.PDDocumentInformation";

declare namespace PDOutlineItem="java:org.apache.pdfbox.pdmodel.interactive.documentnavigation.outline.PDOutlineItem";
declare namespace PDFRenderer="java:org.apache.pdfbox.rendering.PDFRenderer";
declare namespace RandomAccessReadBufferedFile = "java:org.apache.pdfbox.io.RandomAccessReadBufferedFile";
declare namespace File ="java:java.io.File";

(:~ SemVer version of this package 
with build metadata for Apacke Pdfbox in use  e.g. "0.1.0+pdfbox3.0.4"
:)
declare function pdfbox:version()
as xs:string{
  "0.1.0+pdfbox" || Q{java:org.apache.pdfbox.util.Version}getVersion()
};

(: open pdf,apply function, close pdf
with-document pattern, creates local pdfobject and ensures it is closed
e.g "path..." => pdfbox:with-pdf("path...",pdfbox:page-text(?,5))
:)
declare function pdfbox:with-pdf($src as xs:string,$fn as function(*)*)
as item()*{
 "@TODO"
};

(:~ open pdf, returns pdf object :)
declare function pdfbox:open($pdfpath as xs:string)
as item(){
  try{
    Loader:loadPDF( RandomAccessReadBufferedFile:new($pdfpath))
} catch *{
    error(xs:QName("pdfbox:open"),"Failed to open: " || $pdfpath)
}
};

(:~ the version of the PDF specification used by $pdf  e.g "1.4"
returned as string to avoid float rounding issues
 :)
declare function pdfbox:specification($pdf as item())
as xs:string{
 PDDocument:getVersion($pdf)=>xs:decimal()=>round(4)=>string()
};

(:~ save pdf $pdf to $savepath , returns $savepath :)
declare function pdfbox:save($pdf as item(),$savepath as xs:string)
as xs:string{
   PDDocument:save($pdf, File:new($savepath)),$savepath
};

(: release references to $pdf:)
declare function pdfbox:close($pdf as item())
as empty-sequence(){
  (# db:wrapjava void #) {
     PDDocument:close($pdf)
  }
};

(:~ number of pages in PDF:)
declare function pdfbox:page-count($pdf as item())
as xs:integer{
  PDDocument:getNumberOfPages($pdf)
};

(:~ render of $pdf page to image
options.format="gif,"png" etc, options.scale= 1 is 72 dpi?? :)
declare function pdfbox:page-image($pdf as item(),$pageNo as xs:integer,$options as map(*))
as xs:base64Binary{
  let $options:=map:merge(($options,map{"format":"gif","scale":1}))
  let $bufferedImage:=PDFRenderer:new($pdf)=>PDFRenderer:renderImage($pageNo,$options?scale)
  let $bytes:=Q{java:java.io.ByteArrayOutputStream}new()
  let $_:=Q{java:javax.imageio.ImageIO}write($bufferedImage ,$options?format,  $bytes)
  return Q{java:java.io.ByteArrayOutputStream}toByteArray($bytes)
         =>convert:integers-to-base64()
 
};

(:~ map with document metadata :)
declare function pdfbox:information($pdf as item())
as map(*){
  let $info:=PDDocument:getDocumentInformation($pdf)
  return map{
    "title": PDDocumentInformation:getTitle($info),
    "creator": PDDocumentInformation:getCreator($info),
    "producer": PDDocumentInformation:getProducer($info),
    "subject": PDDocumentInformation:getSubject($info),
     "keywords": PDDocumentInformation:getKeywords($info),
     "creationdate": pdfbox:gregToISO(PDDocumentInformation:getCreationDate($info)),
    "author": PDDocumentInformation:getAuthor($info)
  }
};

 

(:~ outline for $pdf as map()* :)
declare function pdfbox:outline($pdf as item())
as map(*)*{
  (# db:wrapjava some #) {
  let $outline:=
                PDDocument:getDocumentCatalog($pdf)
                =>PDDocumentCatalog:getDocumentOutline()
 
  return  if(exists($outline))
          then pdfbox:outline($pdf,PDOutlineItem:getFirstChild($outline)) 
  }
};

(:~ return bookmark info for children of $outlineItem as seq of maps :)
declare function pdfbox:outline($pdf as item(),$outlineItem as item()?)

as map(*)*{
  let $find as map(*):=pdfbox:_outline($pdf ,$outlineItem)
  return map:get($find,"list")
};

(: BaseX bug 10.7? error if inlined in outline :)
declare %private function pdfbox:_outline($pdf as item(),$outlineItem as item()?)
as map(*){
  pdfbox:do-until(
    
     map{"list":(),"this":$outlineItem},

     function($input,$pos ) { 
                      let $bk:= pdfbox:bookmark($input?this,$pdf)
                      let $bk:= if($bk?hasChildren)
                                then let $kids:=pdfbox:outline($pdf,PDOutlineItem:getFirstChild($input?this))
                                     return map:merge(($bk,map:entry("children",$kids)))
                                else $bk 
                      return map{
                            "list": ($input?list, $bk),
                            "this":  PDOutlineItem:getNextSibling($input?this)}
                          },

     function($output,$pos) { empty($output?this) }                      
  )
};

(:~ outline as xml :)
declare function pdfbox:outline-xml($outline as map(*)*)
as element(outline){
 element outline { 
   $outline!pdfbox:bookmark-xml(.)
 }
};

declare function pdfbox:bookmark-xml($outline as map(*)*)
as element(bookmark)*
{
  $outline!
  <bookmark title="{?title}" index="{?index}">
    {?children!pdfbox:bookmark-xml(.)}
  </bookmark>
};

(:~ return bookmark info for children of $outlineItem 
@return map like{index:,title:,hasChildren:}
:)
declare function pdfbox:bookmark($bookmark as item(),$pdf as item())
as map(*)
{
 map{ 
  "index":  PDOutlineItem:findDestinationPage($bookmark,$pdf)=>pdfbox:page-index($pdf),
  "title":  (# db:checkstrings #) {PDOutlineItem:getTitle($bookmark)}
  (:=>translate("�",""), :),
  "hasChildren": PDOutlineItem:hasChildren($bookmark)
  }
};


(:~ pageIndex of $page in $pdf :)
declare function pdfbox:page-index(
   $page as item()? (: as java:org.apache.pdfbox.pdmodel.PDPage :),
   $pdf as item())
as item()?
{
  if(exists($page))
  then PDDocument:getDocumentCatalog($pdf)
      =>PDDocumentCatalog:getPages()
      =>PDPageTree:indexOf($page)
};            



(:~ save new PDF doc from 1 based page range 
@return save path :)
declare function pdfbox:extract($pdf as item(), 
             $start as xs:integer,$end as xs:integer,$target as xs:string)
as xs:string
{
    let $a:=PageExtractor:new($pdf, $start, $end) =>PageExtractor:extract()
    return (pdfbox:save($a,$target),pdfbox:close($a)) 
};


(:~   pageLabel for every page
@see https://www.w3.org/TR/WCAG20-TECHS/PDF17.html#PDF17-examples
@see https://codereview.stackexchange.com/questions/286078/java-code-showing-page-labels-from-pdf-files
:)
declare function pdfbox:labels($pdf as item())
as xs:string*
{
  PDDocument:getDocumentCatalog($pdf)
  =>PDDocumentCatalog:getPageLabels()
  =>PDPageLabels:getLabelsByPageIndices()
};

(:~ return text on $pageNo :)
declare function pdfbox:page-text($doc as item(), $pageNo as xs:integer)
as xs:string{
  let $tStripper := (# db:wrapjava instance #) {
         PDFTextStripper:new()
         => PDFTextStripper:setStartPage($pageNo)
         => PDFTextStripper:setEndPage($pageNo)
       }
  return (# db:checkstrings #) {PDFTextStripper:getText($tStripper,$doc)}
};

(:~ summary info as map for $pdfpath :)
declare function pdfbox:report($pdfpath as xs:string)
as map(*){
 let $doc:=pdfbox:open($pdfpath)
 return (map{
       "file":  $pdfpath,
       "pages": pdfbox:page-count($doc),
       "outline": pdfbox:outline($doc)=>count()
        },pdfbox:information($doc)
)=>map:merge()
};

(:~ convert date :)
declare %private
function pdfbox:gregToISO($item as item())
as xs:string{
 Q{java:java.util.GregorianCalendar}toZonedDateTime($item)=>string()
};

(:~ fn:do-until shim for BaseX 9+10 
if  fn:do-until not found use hof:until
:)
declare %private function pdfbox:do-until(
 $input 	as item()*, 	
 $action 	as function(item()*, xs:integer) as item()*, 	
 $predicate 	as function(item()*, xs:integer) as xs:boolean? 	
) as item()*
{
  let $fn:=function-lookup(QName('http://www.w3.org/2005/xpath-functions','do-until'), 3)
  return if(exists($fn))
         then $fn($input,$action,$predicate)
         else let $hof:=function-lookup(QName('http://basex.org/modules/hof','until'), 3)
              return if(exists($hof))
                      then $hof($predicate(?,0),$action(?,0),$input)
                      else error(xs:QName('pdfbox:do-until'),"No implementation found")

};
