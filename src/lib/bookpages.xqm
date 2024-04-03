xquery version '3.1';
(:~ describe book page numbers as sequence of ranges, similar to PDF pagelabels
@author quodatum
:)
module namespace bookpages = 'urn:bookpages';

(:~ Invisible-xml grammar to parse custom pagelabel representation  :)
declare variable $bookpages:grammar:="
book: pagecount,'#',range,(-',', range)*.
pagecount:['0'-'9']+.
range: s,from?,s,type,s,prefix?,s,offset?.
@from: ['0'-'9']+. { pageIndex }
@type: ['C'|'D'|'R'|'r'|'A'|'a'|'w'].
@prefix: -':',~[',']+.
@offset: -'@',['0'-'9']+.

-s: ([Zs]; #9; #a; #d)*. {Optional whitespace}  
";

(:~ 
page number range in given style 
:)
declare function bookpages:span($type as xs:string,$length as xs:integer,$first as xs:integer)
as xs:string*{
let $r:=$first to $first+$length
return switch ($type)
       case "D" return $r!format-integer(.,"1")
       case "r" return $r!format-integer(.,"i")
       case "R" return $r!format-integer(.,"I")
       case "C" return "Cover"
       default return $r!format-integer(.,$type)
};

(:~ pagelabels from text:)
declare function bookpages:expand($pages as xs:string)
as xs:string*{
  let $x:=bookpages:parse($pages)
  let $last:=head($x)=>xs:integer()
  return hof:until(
      function($m){ empty($m?ranges) or count($m?result)eq $last },  
      function($m){ 
          let $range:=head($m?ranges)=>trace("SS")
          let $start:=if($range/@offset)then xs:integer($range/@offset) else 1
          let $end:=($m?ranges[2]/xs:integer(@from)-1)  otherwise $last
          let $length:=$end -count($m?result)-1
          let $span:=bookpages:span($range/@type,$length,$start)
          let $span:=if($range/@prefix)then $span!concat($range/@prefix,.) else $span
          return map {
            'ranges': tail($m?ranges),
            'result': ($m?result, $span)
      }},
      
       (: initial input = grammar ranges :)
        map { 'ranges': tail($x) , 'result': () }
    )?result
};
 
(:~ parse pagenumber description to xml :)
declare function bookpages:parse($pages as xs:string)
as element(range)*{
  invisible-xml($bookpages:grammar)($pages)/*
};

