xquery version '3.1';
(:~ pdfbox 3.0 https://pdfbox.apache.org/ interface library, 
requires pdfbox jar on classpath
3.02 required tested with pdfbox-app-3.0.2-20240121.184204-66.jar
@see https://lists.apache.org/list?users@pdfbox.apache.org:lte=1M:loader
:)
module namespace pdfbox="urn:expkg-zone58:pdfbox:3";

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

declare namespace File ="java:java.io.File";
declare namespace RandomAccessReadBufferedFile = "java:org.apache.pdfbox.io.RandomAccessReadBufferedFile";

declare function pdfbox:open($pdfpath as xs:string){
  Loader:loadPDF( RandomAccessReadBufferedFile:new($pdfpath))
};

declare function pdfbox:save($doc,$savepath as xs:string)
as xs:string{
   PDDocument:save($doc,File:new($savepath)),$savepath
};

declare function pdfbox:close($doc){
  PDDocument:close($doc)
};

declare function pdfbox:page-count($doc as item())
as xs:integer{
  PDDocument:getNumberOfPages($doc)
};

(:~ @TODO 
  PDOutlineItem current = bookmark.getFirstChild();
    while (current != null) {
        PDPage currentPage = current.findDestinationPage(document);
        Integer pageNumber = document.getDocumentCatalog().getPages().indexOf(currentPage) + 1;
        System.out.println(current.getTitle() + "-------->" + pageNumber);
        getOutlines(document, current, indentation);
        current = current.getNextSibling();
    }
:)
declare function pdfbox:siblings($acc as item()*,$outlineItem ,$doc as item())
{
  (# db:wrapjava all #) {
  if(empty($outlineItem))
  then $acc
  else let $next:=  PDOutlineItem:getNextSibling($outlineItem)=>trace("next: ")
       return pdfbox:siblings($acc,pdfbox:bookmark($outlineItem ,$doc),
                      $next
                    )
   }
};

declare function pdfbox:outline($doc as item())
as item()*{
  let $bookmark:=(# db:wrapjava all #) {
                PDDocument:getDocumentCatalog($doc)
                =>PDDocumentCatalog:getDocumentOutline()
                =>PDOutlineItem:getFirstChild()=>trace("cur")
}
  (: return hof:until(empty#1,pdfbox:outx(?,$doc),()) :)
  let $bk:=pdfbox:siblings((),$bookmark ,$doc)
 
  return $bk
};

declare function pdfbox:bookmark($bookmark as item(),$doc as item())
as map(*){
  let $currentPage := PDOutlineItem:findDestinationPage($bookmark,$doc)
  (: return hof:until(empty#1,pdfbox:outx(?,$doc),()) :)
  return map{ 
  "index":  pdfbox:pageIndex($currentPage,$doc),
  "title": PDOutlineItem:getTitle($bookmark)
  }
};

declare function pdfbox:outx($page,$document){
  let $currentPage := PDOutlineItem:findDestinationPage($page,$document)
  let $pageNumber := pdfbox:pageIndex($currentPage,$document)
  return $pageNumber
};

(: pageIndex of $page in $document :)
declare function pdfbox:pageIndex(
   $page (: as java:org.apache.pdfbox.pdmodel.PDPage :),
   $document)
{
 PDDocument:getDocumentCatalog($document)
 =>PDDocumentCatalog:getPages()
 =>PDPageTree:indexOf($page)
};            



(:~ new PDF doc from 1 based page range :)
declare function pdfbox:extract($doc as item(),$target as xs:string, 
             $start as xs:integer,$end as xs:integer)
{
    let $a:=PageExtractor:new($doc, $start, $end) =>PageExtractor:extract()
    let $map:=pdfbox:save($a,$target)
    return pdfbox:close($a) 
};


(:~  @TODO 
@see https://codereview.stackexchange.com/questions/286078/java-code-showing-page-labels-from-pdf-files
:)
declare function pdfbox:getPageLabels($doc as item())
as item()*{
  PDDocument:getDocumentCatalog($doc)
  =>PDDocumentCatalog:getPageLabels()
  =>PDPageLabels:getLabelsByPageIndices()
};
(:~  @TODO 
@see https://codereview.stackexchange.com/questions/286078/java-code-showing-page-labels-from-pdf-files
:)

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


