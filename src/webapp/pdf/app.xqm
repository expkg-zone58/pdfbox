(:~
 : Common RESTXQ access points.
 :
 : @author Christian Grün, BaseX Team 2005-23, BSD License
 :)
module namespace pdf = 'pdf/common';



(:~
 : Redirects to the start page.
 : @return redirection
 :)
declare
  %rest:path('/pdf')
function pdf:home() as element() {
 web:forward('/pdf/static/index.html')
};
declare
  %rest:path('/pdf/{$file=.+}')
function pdf:spa($file)as element(){
pdf:home()
};
(:~ list slugs :)
declare
  %rest:path('/pdf/api/sources')
   %output:method("json")
  %output:json("format=xquery")
function pdf:apt()
{
  let $base:="C:/Users/mrwhe/git/expkg-zone58/pdfbox/data/"
  let $d:="1e/"
  let $f:=file:list($base || $d,true(),"*.pdf")[not(contains(.,"\outputs\"))]
  return map{ 
           "count": count($f),
          "items": array{$f!map{"id":position(),"name":.}}
  }
};

(:~
 : Returns a file.
 : @param  $file  file or unknown path
 : @return rest binary data
 :)
declare
  %rest:path('/pdf/static/{$file=.+}')
  %output:method('basex')
  %perm:allow('public')
function pdf:file(
  $file  as xs:string
) as item()+ {
  let $path := file:base-dir() || "static/" || $file
  return if(file:exists($path))
         then (
              web:response-header(
                map { 'media-type': web:content-type($path) },
                map { 'Cache-Control': 'max-age=3600,public', 'Content-Length': file:size($path) }
              ),
              file:read-binary($path)
         )else
         web:forward("/pdf/api/404")

};

(:~
 : Shows a 'page not found' error.
 : @param  $path  path to unknown page
 : @return page
 :)
declare
  %rest:path('/pdf/api/404')
  %output:method('html')
function pdf:unknown(
  $path  as xs:string
) as element(*) {
 
    <tr>
      <td>
        <h2>Page not found:</h2>
        <ul>
          <li>Page: dba/{ $path }</li>
          <li>Method: { request:method() }</li>
        </ul>
      </td>
    </tr>

};
