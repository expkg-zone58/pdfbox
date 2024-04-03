xquery version '3.1';
(:~ 
pdfbox 3.0 https://pdfbox.apache.org/ BaseX 10.7+ interface library, 
requires pdfbox jar on classpath
3.02+ required tested with pdfbox-app-3.0.2.jar
@see https://repository.apache.org/content/groups/snapshots/org/apache/pdfbox/pdfbox-app/3.0.2-SNAPSHOT/
@javadoc https://javadoc.io/static/org.apache.pdfbox/pdfbox/3.0.0/

:)
module namespace pdfbox="urn:expkg-zone58:pdfbox3";

declare namespace Loader ="java:org.apache.pdfbox.Loader"; 
declare namespace PDFTextStripper = "java:org.apache.pdfbox.text.PDFTextStripper";

(:~ 
@see https://javadoc.io/static/org.apache.pdfbox/pdfbox/3.0.0/org/apache/pdfbox/pdmodel/PDDocument.html 
:)
declare namespace PDDocument ="java:org.apache.pdfbox.pdmodel.PDDocument";

declare namespace PDDocumentCatalog ="java:org.apache.pdfbox.pdmodel.PDDocumentCatalog";
declare namespace PDPageLabels ="java:org.apache.pdfbox.pdmodel.common.PDPageLabels";

(:~ 
@see https://javadoc.io/static/org.apache.pdfbox/pdfbox/3.0.0/org/apache/pdfbox/multipdf/PageExtractor.html 
:)
declare namespace PageExtractor ="java:org.apache.pdfbox.multipdf.PageExtractor";
 
(:~ 
 @see https://javadoc.io/static/org.apache.pdfbox/pdfbox/3.0.0/org/apache/pdfbox/pdmodel/PDPageTree.html
:)
declare namespace PDPageTree ="java:org.apache.pdfbox.pdmodel.PDPageTree";

(:~ 
@see https://javadoc.io/static/org.apache.pdfbox/pdfbox/3.0.0/org/apache/pdfbox/pdmodel/interactive/documentnavigation/outline/PDDocumentOutline.html 
:)
declare namespace PDDocumentOutline ="java:org.apache.pdfbox.pdmodel.interactive.documentnavigation.outline.PDDocumentOutline";


(:~ 
@see https://javadoc.io/static/org.apache.pdfbox/pdfbox/3.0.0/org/apache/pdfbox/pdmodel/interactive/documentnavigation/outline/PDOutlineItem.html 
:)
declare namespace PDOutlineItem="java:org.apache.pdfbox.pdmodel.interactive.documentnavigation.outline.PDOutlineItem";

declare namespace RandomAccessReadBufferedFile = "java:org.apache.pdfbox.io.RandomAccessReadBufferedFile";
declare namespace File ="java:java.io.File";

(:~ version of pdfbox:)
declare function pdfbox:version()
as xs:string{
  Q{java:org.apache.pdfbox.util.Version}getVersion()
};

(:~ open pdf, returns handle :)
declare function pdfbox:open($pdfpath as xs:string)
as item(){
  Loader:loadPDF( RandomAccessReadBufferedFile:new($pdfpath))
};

(:~ the PDF specification version this document conforms to.:)
declare function pdfbox:pdfVersion($doc as item())
as xs:float{
  PDDocument:getVersion($doc)
};

(:~ save pdf $doc to $savepath , returns $savepath :)
declare function pdfbox:save($doc as item(),$savepath as xs:string)
as xs:string{
   PDDocument:save($doc,File:new($savepath)),$savepath
};

declare function pdfbox:close($doc as item())
as empty-sequence(){
  (# db:wrapjava void #) {
     PDDocument:close($doc)
  }
};

declare function pdfbox:page-count($doc as item())
as xs:integer{
  PDDocument:getNumberOfPages($doc)
};


(:~ outline for $doc as map()* :)
declare function pdfbox:outline($doc as item())
as map(*)*{
  (# db:wrapjava some #) {
  let $bookmark:=
                PDDocument:getDocumentCatalog($doc)
                =>PDDocumentCatalog:getDocumentOutline()
                =>PDOutlineItem:getFirstChild()

  let $bk:=pdfbox:outline($doc,$bookmark) 
  return  $bk
  }
};

(: return bookmark info for children of $outlineItem as seq of maps :)
declare function pdfbox:outline($doc as item(),$outlineItem as item()?)
as map(*)*
{
  let $find:=hof:until(
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
  return $find?list
};

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

(: return bookmark info for children of $outlineItem :)
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

(:~ pageIndex of $page in $document :)
declare function pdfbox:pageIndex(
   $page as item()? (: as java:org.apache.pdfbox.pdmodel.PDPage :),
   $document)
as item()?
{
  if(exists($page))
  then PDDocument:getDocumentCatalog($document)
      =>PDDocumentCatalog:getPages()
      =>PDPageTree:indexOf($page)
};            



(:~ save new PDF doc from 1 based page range 
@return save path :)
declare function pdfbox:extract($doc as item(), 
             $start as xs:integer,$end as xs:integer,$target as xs:string)
as xs:string
{
    let $a:=PageExtractor:new($doc, $start, $end) =>PageExtractor:extract()
    return (pdfbox:save($a,$target),pdfbox:close($a)) 
};


(:~   pageLabel for every page
@see https://www.w3.org/TR/WCAG20-TECHS/PDF17.html#PDF17-examples
@see https://codereview.stackexchange.com/questions/286078/java-code-showing-page-labels-from-pdf-files
:)
declare function pdfbox:getPageLabels($doc as item())
as xs:string*
{
  PDDocument:getDocumentCatalog($doc)
  =>PDDocumentCatalog:getPageLabels()
  =>PDPageLabels:getLabelsByPageIndices()
};

(: text on $pageNo :)
declare function pdfbox:getText($doc as item(), $pageNo as xs:integer)
as xs:string{
  let $tStripper := (# db:wrapjava instance #) {
         PDFTextStripper:new()
         => PDFTextStripper:setStartPage($pageNo)
         => PDFTextStripper:setEndPage($pageNo)
       }
  return (# db:checkstrings #) {PDFTextStripper:getText($tStripper,$doc)}
};


