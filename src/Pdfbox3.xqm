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

(:~ @javadoc org/apache/pdfbox/pdmodel/PDDocument.html :)
declare namespace PDDocument ="java:org.apache.pdfbox.pdmodel.PDDocument";

declare namespace PDDocumentCatalog ="java:org.apache.pdfbox.pdmodel.PDDocumentCatalog";
declare namespace PDPageLabels ="java:org.apache.pdfbox.pdmodel.common.PDPageLabels";

(:~ @javadoc org/apache/pdfbox/multipdf/PageExtractor.html :)
declare namespace PageExtractor ="java:org.apache.pdfbox.multipdf.PageExtractor";
 
(:~ @javadoc org/apache/pdfbox/pdmodel/PDPageTree.html :)
declare namespace PDPageTree ="java:org.apache.pdfbox.pdmodel.PDPageTree";

(:~ 
@javadoc org/apache/pdfbox/pdmodel/interactive/documentnavigation/outline/PDDocumentOutline.html 
:)
declare namespace PDDocumentOutline ="java:org.apache.pdfbox.pdmodel.interactive.documentnavigation.outline.PDDocumentOutline";

declare namespace PDDocumentInformation ="java:org.apache.pdfbox.pdmodel.PDDocumentInformation";
(:~ 
@javadoc org/apache/pdfbox/pdmodel/interactive/documentnavigation/outline/PDOutlineItem.html 
:)
declare namespace PDOutlineItem="java:org.apache.pdfbox.pdmodel.interactive.documentnavigation.outline.PDOutlineItem";
declare namespace PDFRenderer="java:org.apache.pdfbox.rendering.PDFRenderer";
declare namespace RandomAccessReadBufferedFile = "java:org.apache.pdfbox.io.RandomAccessReadBufferedFile";
declare namespace File ="java:java.io.File";

(:~ version of Apacke Pdfbox in use :)
declare function pdfbox:version()
as xs:string{
  Q{java:org.apache.pdfbox.util.Version}getVersion()
};

(:~ open pdf, returns pdf object :)
declare function pdfbox:open($pdfpath as xs:string)
as item(){
  Loader:loadPDF( RandomAccessReadBufferedFile:new($pdfpath))
};

(:~ the version of the PDF specification used by $pdf :)
declare function pdfbox:pdfVersion($pdf as item())
as xs:float{
  PDDocument:getVersion($pdf)
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

(:~ map with document metadata :)
declare function pdfbox:information($doc as item())
as map(*){
  let $info:=PDDocument:getDocumentInformation($doc)
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

 (:~ convert date :)
declare %private
function pdfbox:gregToISO($item as item())
as xs:string{
 Q{java:java.util.GregorianCalendar}toZonedDateTime($item)=>string()
};

(:~ outline for $doc as map()* :)
declare function pdfbox:outline($doc as item())
as map(*)*{
  (# db:wrapjava some #) {
  let $outline:=
                PDDocument:getDocumentCatalog($doc)
                =>PDDocumentCatalog:getDocumentOutline()
 
  return  if(exists($outline))
          then pdfbox:outline($doc,PDOutlineItem:getFirstChild($outline)) 
  }
};

(:~ return bookmark info for children of $outlineItem as seq of maps :)
declare function pdfbox:outline($doc as item(),$outlineItem as item()?)

as map(*)*{
  let $find as map(*):=pdfbox:_outline($doc ,$outlineItem)
  return map:get($find,"list")
};

(: BaseX bug 10.7? error if inlined in outline :)
declare %private function pdfbox:_outline($doc as item(),$outlineItem as item()?)
as map(*){
 hof:until(
            function($output) { empty($output?this) },
            function($input ) { 
                      let $bk:= pdfbox:bookmark($input?this,$doc)
                      let $bk:= if($bk?hasChildren)
                                then let $kids:=pdfbox:outline($doc,PDOutlineItem:getFirstChild($input?this))
                                     return map:merge(($bk,map:entry("children",$kids)))
                                else $bk 
                      return map{
                            "list": ($input?list, $bk),
                            "this":  PDOutlineItem:getNextSibling($input?this)}
                          },
            map{"list":(),"this":$outlineItem}
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
declare function pdfbox:bookmark($bookmark as item(),$doc as item())
as map(*)
{
 map{ 
  "index":  PDOutlineItem:findDestinationPage($bookmark,$doc)=>pdfbox:pageIndex($doc),
  "title":  (# db:checkstrings #) {PDOutlineItem:getTitle($bookmark)}=>translate("�",""),
  "hasChildren": PDOutlineItem:hasChildren($bookmark)
  }
};

declare function pdfbox:outx($page ,$document)
{
  let $currentPage := PDOutlineItem:findDestinationPage($page,$document)
  let $pageNumber := pdfbox:pageIndex($currentPage,$document)
  return $pageNumber
};

(:~ pageIndex of $page in $pdf :)
declare function pdfbox:pageIndex(
   $page as item()? (: as java:org.apache.pdfbox.pdmodel.PDPage :),
   $pdf)
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


(:~   pageLabel info
@see https://www.w3.org/TR/WCAG20-TECHS/PDF17.html#PDF17-examples
@see https://codereview.stackexchange.com/questions/286078/java-code-showing-page-labels-from-pdf-files
:)
declare function pdfbox:getPageLabels($pdf as item())
as item()
{
  PDDocument:getDocumentCatalog($pdf)
  =>PDDocumentCatalog:getPageLabels()
};

(:~   pageLabel for every page:)
declare function pdfbox:pageLabels($doc as item())
as xs:string*
{
  PDDocument:getDocumentCatalog($doc)
  =>PDDocumentCatalog:getPageLabels()
  =>PDPageLabels:getLabelsByPageIndices()
};

(:~ return text on $pageNo :)
declare function pdfbox:getText($doc as item(), $pageNo as xs:integer)
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

(:~ java:bufferedImage for $pageNo using $scale times dpi= 72
@param $pageNo (ZERO based) 
@param $scale 1=72 dpi 
@return  Java java.awt.image.BufferedImage object
:)
declare function pdfbox:pageBufferedImage($doc as item(), $pageNo as xs:integer,$scale as xs:float)
as item(){
 PDFRenderer:new($doc)=>PDFRenderer:renderImage($pageNo,$scale)
};

(:~ save bufferedimage to $dest 
@param $type = "gif","png" etc:)
declare function pdfbox:imageSave($bufferedImage as item(),$dest as xs:string,$type as xs:string)
as xs:boolean{
  Q{java:javax.imageio.ImageIO}write($bufferedImage , $type,  File:new($dest))
};

(:~ return image 
@param $type = "gif","png" etc:)
declare function pdfbox:imageBinary($bufferedImage as item(),$type as xs:string)
as xs:base64Binary{
  let $bytes:=Q{java:java.io.ByteArrayOutputStream}new()
  let $_:=Q{java:javax.imageio.ImageIO}write($bufferedImage , $type,  $bytes)
  return Q{java:java.io.ByteArrayOutputStream}toByteArray($bytes)
         =>convert:integers-to-base64()
};