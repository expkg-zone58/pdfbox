xquery version '3.1';
(:~ look for pagenos in pdf text
pagenos:page-report($doc )=>pagenos:inverted-map()
:)
module namespace pagenos = 'urn:pageno';
import module namespace pdfbox="urn:expkg-zone58:pdfbox:3" at "pdfbox3.xqm";

(: look for possible page number in first/last line of page text
@todo last line and roman
1=Number system ( D=decimal, R=Roman)
2=Side L=left,R=right
:)
declare variable $pagenos:pats:=map{
    "DL": "^([1-9][0-9]*).*",
    "DR": ".*[^0-9]([1-9][0-9]*)$",
    "RL": "^([ivxlc]+).*",
    "RR": ".*[^ivxlc]([ivxlc]+)$"
};

(: page-reports for all pages :)
declare function pagenos:page-report($doc as item())
as element(page)*{
  let $count:=pdfbox:page-count($doc)=>trace("Pages: ")
  return (0 to $count -1)!pagenos:page-report($doc,.)    
};

(: page-report for given page :)
declare function pagenos:page-report($doc as item(), $page as xs:integer)
as element(page){
  let $txt:=pdfbox:getText($doc,$page)
  let $line1:=substring-before($txt,file:line-separator())
  let $fn:=function($acc,$this){ $acc otherwise pagenos:line-report($this,$line1)}
  let $found:=map:keys($pagenos:pats)=>fold-left( (),$fn)
 
  return <page index="{ $page }">{ $found, $line1 }</page>
};

(: empty or attributes created by matching $style with $line1 :)
declare function pagenos:line-report($style as xs:string, $line1 as xs:string)
as attribute(*)*{
    if(matches($line1,$pagenos:pats?($style)))
    then (
          attribute {"style"} { substring($style,1,1) } ,(: 1st key:)
          attribute {"LR"} { substring($style,2,1) } ,(: 2nd key:)
          attribute {"number"} { replace($line1,$pagenos:pats?($style),"$1") }
        )                   
};

(:~ keys are parsed pageno values are pageindices where found:)
declare function pagenos:inverted-map($pages as element(page)*) 
as map(*) { 
  $pages[@number]!map:entry(string(@number),string(@index))
  =>map:merge(map{"duplicates":"combine"})
};

(:~ convert roman to integer, zero if invalid
@see https://joewiz.org/2021/05/30/converting-roman-numerals-with-xquery-xslt/
:)
declare function pagenos:decode-roman-numeral($roman-numeral as xs:string)  
as xs:integer{ 
    $roman-numeral => upper-case() =>  pagenos:characters() 
    => for-each(map { "M": 1000, "D": 500, "C": 100, "L": 50, "X": 10, "V": 5, "I": 1 })
    => fold-right([0,0], function($number,$accumulator) { 
      if ($number lt $accumulator?2) 
      then [ $accumulator?1 - $number, $number ] 
      else [ $accumulator?1 + $number, $number ] } ) 
    => array:head() 
};

(:~ xpath 4:)
declare function pagenos:characters($value as xs:string?) 
as xs:string*{
  fn:string-to-codepoints($value) ! fn:codepoints-to-string(.)
};  