
import module namespace build = 'urn:quodatum:build1' at 'build.xqm';

let $output-file := build:xar-path()
return (
        repo:install($output-file),
        trace($output-file,"repo: ")
        )
