(:~ build utils for REPO packaging :)
module namespace build = 'urn:quodatum:build1';

(:~ create a flat fat jar from jars in $input-dir
keeping only META-INF from $manifest-jar 
:)
declare function build:fatjar-from-folder($input-dir as xs:string,$manifest-jar as xs:string)
as xs:base64Binary { 
    let $fold :=
function ($res as map (*), $jar as xs:string) { 
    let $bin :=file:read-binary($input-dir || $jar),
        $paths := archive:entries($bin)/string()
        [$jar eq $manifest-jar or not(starts-with( .,"META-INF/"))]
    return
        map { "name" : ($res? name, $paths), 
              "content" : ($res? content,archive:extract-binary($bin, $paths)) } 
}
let $res := file:list($input-dir, false(), "*.jar")
            =>fold-left( map { }, $fold)
return
    archive:create($res? name, $res? content,
                   map { "format" : "zip", "algorithm" : "deflate" }) 
};

(:~ create a fat jar with lib 
@remark 
:)
declare function build:fatjar-with-lib($input-dir as xs:string,$manifest-jar as xs:string)
 { 
 let $bin :=file:read-binary($input-dir || $manifest-jar)
  
 let $lib:=file:list($input-dir || "lib/", false(), "*.jar")!concat("lib/",.)
 let $name:= (archive:entries($bin)/string()
              ,$lib)
 let  $content:=(archive:extract-binary($bin,$name)
                ,$lib!file:read-binary($input-dir || .))
return  archive:create($name, $content,
                   map { "format" : "zip", "algorithm" : "deflate" }) 
};

(:~ update-manifest :)
declare function build:update-manifest($jar  as xs:base64Binary,$main-class as xs:string)
as xs:base64Binary{
(: let $mf:=archive:extract-text($jar,"META-INF/MANIFEST.MF") :)

let $mf2:=concat("Manifest-Version: 1.0&#xD;&#xA;Main-Class: ",
                 $main-class,
                 "&#xD;&#xA;&#xD;&#xA;")
return archive:update($jar,"META-INF/MANIFEST.MF",$mf2)
};

(:~ update-manifest :)
declare function build:update($jar as xs:base64Binary,$name  as xs:string,$file as xs:string)
as xs:base64Binary{
archive:update($jar,$name,$file)
}; 


(:~ download $files from $urls to  $destdir:)
declare variable $build:REPO as xs:string external :="https://repo1.maven.org/maven2/";
declare function build:maven-download($urls as xs:string*,$destdir as xs:string)
as empty-sequence(){
    file:create-dir($destdir),    
    for $f in $urls
    let $dest:=$destdir || replace($f,"^.*/","") 
    where not(file:exists($dest))
    return build:write-binary($dest, fetch:binary(resolve-uri($f,$build:REPO)
           =>trace("Download: ")))
};

declare function build:write-binary($dest as xs:string,$contents)
as empty-sequence(){
file:create-dir(file:parent($dest)),
file:write-binary($dest,$contents)
};