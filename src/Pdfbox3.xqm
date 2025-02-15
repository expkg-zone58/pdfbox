xquery version '3.1';
(:~ 
pdfbox 3.0 https://pdfbox.apache.org/ BaseX 10.7+ interface library, 
requires pdfbox jars on classpath, i.e. in custom or xar
tested with pdfbox-app-3.0.4.jar
@see download https://pdfbox.apache.org/download.cgi
@javadoc https://javadoc.io/static/org.apache.pdfbox/pdfbox/3.0.4/
@author Andy Bunce 2025
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



(:~ with-document pattern: open pdf,apply function, close pdf
 creates a local pdfobject and ensures it is closed after use
e.g pdfbox:with-pdf("path...",pdfbox:page-text(?,5))
:)
declare function pdfbox:with-pdf($src as xs:string,
                                $fn as function(item())as item()*)
as item()*{
 let $pdf:=pdfbox:open-file($src)
 return try{
        $fn($pdf),pdfbox:close($pdf)
        } catch *{
          pdfbox:close($pdf),fn:error($err:code,$src || " " || $err:description)
        }

};

(:~ open pdf, returns pdf object :)
declare function pdfbox:open-file($pdfpath as xs:string)
as item(){
  try{
    Loader:loadPDF( RandomAccessReadBufferedFile:new($pdfpath))
} catch *{
    error(xs:QName("pdfbox:open-file"),"Failed to open: " || $pdfpath)
}
};

(:~ the version of the PDF specification used by $pdf  e.g "1.4"
returned as string to avoid float rounding issues
 :)
declare function pdfbox:specification($pdf as item())
as xs:string{
 PDDocument:getVersion($pdf)=>xs:decimal()=>round(4)=>string()
};

(:~ save pdf $pdf to filesystem at $savepath , returns $savepath :)
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

(:~ property access map
   keys are property names, 
   values are sequences of functions to get property from $pdf object
:)
declare %private variable $pdfbox:property-map:=map{
  "pages": pdfbox:page-count#1,

  "hasOutline": pdfbox:hasOutline#1,

  "hasLabels": pdfbox:hasLabels#1,

  "specification":pdfbox:specification#1,

  "title": (PDDocument:getDocumentInformation#1,
            PDDocumentInformation:getTitle#1) ,

  "author": (PDDocument:getDocumentInformation#1,
             PDDocumentInformation:getAuthor#1 ),

  "creator": (PDDocument:getDocumentInformation#1,
              PDDocumentInformation:getCreator#1),

  "producer": (PDDocument:getDocumentInformation#1,
               PDDocumentInformation:getProducer#1),

  "subject": (PDDocument:getDocumentInformation#1,
              PDDocumentInformation:getSubject#1),

  "keywords": (PDDocument:getDocumentInformation#1,
               PDDocumentInformation:getKeywords#1),

  "creationDate": (PDDocument:getDocumentInformation#1,
                   PDDocumentInformation:getCreationDate#1,
                   pdfbox:gregToISO#1),

  "modificationDate":  (PDDocument:getDocumentInformation#1,
                        PDDocumentInformation:getModificationDate#1,
                        pdfbox:gregToISO#1)
};

(:~ known property names sorted :)
declare function pdfbox:defined-properties() 
as xs:string*{
  $pdfbox:property-map=>map:keys()=>sort()
};

(:~  return value of $property for $pdf :)
declare function pdfbox:property($pdf as item(),$property as xs:string)
as item()*{
  let $fns:= $pdfbox:property-map($property)
  return if(exists($fns))
         then fold-left($fns, 
                        $pdf, 
                        function($result,$this as function(*)){$this($result)})
         else error(xs:QName('pdfbox:property'),concat("Property '",$property,"' not defined."))
};

(:~ summary CSV style info for all properties for $pdfpaths :)
declare function pdfbox:report($pdfpaths as xs:string*)
as map(*){
 pdfbox:report($pdfpaths,map:keys($pdfbox:property-map))
};

(:~ summary CSV style info for named properties for $pdfpaths :)
declare function pdfbox:report($pdfpaths as xs:string*, $properties as xs:string*)
as map(*){
  map{"names":   array{"path",$properties},
  
      "records": for $path in $pdfpaths
                 let $pdf:=pdfbox:open-file($path)
                 return fold-left($properties,
                                  array{$path},
                                  function($result as array(*),$prop as xs:string){
                                    array:append($result, string(pdfbox:property($pdf, $prop)))}
                 )
  }
};

(:~ true if $pdf has an outline :)
declare function pdfbox:hasOutline($pdf as item())
as xs:boolean{
  PDDocument:getDocumentCatalog($pdf)
  =>PDDocumentCatalog:getDocumentOutline()
  =>exists()
};

(:~ true if $pdf has Labels :)
declare function pdfbox:hasLabels($pdf as item())
as xs:boolean{
  PDDocument:getDocumentCatalog($pdf)
  =>PDDocumentCatalog:getPageLabels()
  =>exists()
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
declare function pdfbox:outline-xml($pdf as item())
as element(outline)?{
 let $outline:=pdfbox:outline($pdf)
  return if(exists($outline))
         then <outline>{$outline!pdfbox:bookmark-xml(.)}</outline>
         else ()
};

declare %private function pdfbox:bookmark-xml($outline as map(*)*)
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
declare %private function pdfbox:bookmark($bookmark as item(),$pdf as item())
as map(*)
{
 map{ 
  "index":  PDOutlineItem:findDestinationPage($bookmark,$pdf)=>pdfbox:find-page($pdf),
  "title":  (# db:checkstrings #) {PDOutlineItem:getTitle($bookmark)}
  (:=>translate("�",""), :),
  "hasChildren": PDOutlineItem:hasChildren($bookmark)
  }
};


(:~ pageIndex of $page in $pdf :)
declare function pdfbox:find-page(
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


(:~   pageLabel for every page or empty if none
@see https://www.w3.org/TR/WCAG20-TECHS/PDF17.html#PDF17-examples
@see https://codereview.stackexchange.com/questions/286078/java-code-showing-page-labels-from-pdf-files
:)
declare function pdfbox:labels($pdf as item())
as xs:string*
{
  let $pagelabels:=PDDocument:getDocumentCatalog($pdf)
                   =>PDDocumentCatalog:getPageLabels()
  return if(exists($pagelabels))
         then PDPageLabels:getLabelsByPageIndices($pagelabels)
         else ()
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

(:~  version of  Apache Pdfbox in use  e.g. "3.0.4" :)
declare function pdfbox:version()
as xs:string{
  Q{java:org.apache.pdfbox.util.Version}getVersion()
};

(:~ convert date :)
declare %private
function pdfbox:gregToISO($item as item()?)
as xs:string?{
 if(exists($item))
 then Q{java:java.util.GregorianCalendar}toZonedDateTime($item)=>string()
 else ()
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
                      else error(xs:QName('pdfbox:do-until'),"No implementation do-until found")

};
