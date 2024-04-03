(:~
 pdf
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
         ()

};

