xquery version '3.1';
(:~ 
pdfbox 3.0 https://pdfbox.apache.org/ interface library, 
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

(:~ open pdf, returns handle :)
declare function pdfbox:open($pdfpath as xs:string){
  Loader:loadPDF( RandomAccessReadBufferedFile:new($pdfpath))
};
(:~ save pdf $doc to $savepath , returns $savepath :)
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


(:~ outline for $doc as map()* :)
declare function pdfbox:outline($doc as item())
as map(*)*{
  (# db:wrapjava some #) {
  let $bookmark:=
                PDDocument:getDocumentCatalog($doc)
                =>PDDocumentCatalog:getDocumentOutline()
                =>PDOutlineItem:getFirstChild()=>trace("cur")

  let $bk:=pdfbox:outline($bookmark ,$doc) 
  return  $bk
  }
};

(: return bookmark info for children of $outlineItem :)
declare function pdfbox:outline($outlineItem,$doc )
as map(*)*
{
  let $find:=hof:until(
            function($output) { empty($output?this) },
            function($input ) { 
                      let $bk:= pdfbox:bookmark($input?this,$doc)
                      let $bk:= if($bk?hasChildren)
                                then let $kids:=pdfbox:outline(PDOutlineItem:getFirstChild($input?this), $doc)
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

declare function pdfbox:outline-XML($outline as map(*)*)
as element(*){
 element outline { 
  for $bookmark in $outline
  return <bookmark title="{$bookmark?title}" index="{$bookmark?index}">
    {$bookmark?children!pdfbox:outline-XML(.)}
  </bookmark>
 }
};

(: return bookmark info for children of $outlineItem :)
declare function pdfbox:bookmark($bookmark as item(),$doc as item())
as map(*){
 map{ 
  "index":  PDOutlineItem:findDestinationPage($bookmark,$doc)=>pdfbox:pageIndex($doc),
  "title": PDOutlineItem:getTitle($bookmark),
  "hasChildren": PDOutlineItem:hasChildren($bookmark)
  }
};

declare function pdfbox:outx($page,$document){
  let $currentPage := PDOutlineItem:findDestinationPage($page,$document)
  let $pageNumber := pdfbox:pageIndex($currentPage,$document)
  return $pageNumber
};

(:~ pageIndex of $page in $document :)
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


