
import module namespace build = 'urn:quodatum:build1' at 'build.xqm';

let $output-file := file:resolve-path("dist/pdfbox-" || $build:PKG?version ||".xar",$build:base)
return (
        repo:install($output-file),
        trace($output-file,"repo: ")
        )
