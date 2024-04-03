(:~
 pdf
 :)
module namespace api = 'pdf/api';
import module namespace functx = "http://www.functx.com";
(:~ list slugs :)
declare
  %rest:path('/pdf/api/sources')
   %output:method("json")
  %output:json("format=xquery")
function api:apt()
{
  let $base:="C:/Users/mrwhe/git/expkg-zone58/pdfbox/data/"
  let $d:="1e/"
  let $f:=file:list($base || $d,true(),"*.pdf")[not(contains(.,"\outputs\"))]
  return map{ 
           "count": count($f),
          "items": array{$f!api:path-info(.)}
  }
};
declare function api:path-info($file as xs:string)
as map(*)
{
 map{
    "id": $file,
    "slug":functx:substring-before-last($file,"\"),
    "filename": file:name($file)
  }  
};
