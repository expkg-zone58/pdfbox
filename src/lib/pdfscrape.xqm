xquery version '3.1';
(:~ look for pagenos in pdf text
pdfscrape:page-report($doc )=>pdfscrape:inverted-map()
:)
module namespace pdfscrape = 'urn:pdfscrape';
import module namespace pdfbox="urn:expkg-zone58:pdfbox3" at "pdfbox3.xqm";

(: look for possible page number in first/last line of page text
@todo last line and roman
1=Number system ( D=decimal, R=Roman)
2=Side L=left,R=right
:)
declare variable $pdfscrape:pats:=map{
    "DL": "^([1-9][0-9]*).*",
    "DR": ".*[^0-9]([1-9][0-9]*)$",
    "RL": "^([ivxlc]+).*",
    "RR": ".*[^ivxlc]([ivxlc]+)$"
};

(: page-reports for all pages :)
declare function pdfscrape:page-report($doc as item())
as element(page)*{
  let $count:=pdfbox:page-count($doc)=>trace("Pages: ")
  return (1 to $count )!pdfscrape:page-report($doc,.)    
};

(: page-report for given page :)
declare function pdfscrape:page-report($doc as item(), $page as xs:integer)
as element(page){
  let $txt:=pdfbox:getText($doc,$page)
  let $line1:=substring-before($txt,file:line-separator())
  let $fn:=function($acc,$this){ $acc otherwise pdfscrape:line-report($this,$line1)}
  let $found:=map:keys($pdfscrape:pats)=>fold-left( (),$fn)
 
  return <page index="{ $page }">{ $found, $line1 }</page>
};

(: empty or attributes created by matching $style with $line1 :)
declare function pdfscrape:line-report($style as xs:string, $line1 as xs:string)
as attribute(*)*{
    if(matches($line1,$pdfscrape:pats?($style)))
    then (
          attribute {"style"} { substring($style,1,1) } ,(: 1st key:)
          attribute {"LR"} { substring($style,2,1) } ,(: 2nd key:)
          attribute {"number"} { replace($line1,$pdfscrape:pats?($style),"$1") }
        )                   
};

(:~ keys are parsed pageno values are pageindices where found:)
declare function pdfscrape:inverted-map($pages as element(page)*) 
as map(*) { 
  $pages[@number]!map:entry(string(@number),string(@index))
  =>map:merge(map{"duplicates":"combine"})
};
(:~ %match 
$l page labels
:)
declare function pdfscrape:score($l as xs:string*,$report as element(page)*)  
{ 
  let $s:=$report!(if(@number)then string(@number) else "")
 let $match:= for-each-pair($l,$s,function($l,$s){if($s eq "")then 0 else if ($s eq $l)then 1 else -1})
return round(sum($match) div count($l) *100,0) 
};

(:~ convert roman to integer, zero if invalid
@see https://joewiz.org/2021/05/30/converting-roman-numerals-with-xquery-xslt/
:)
declare function pdfscrape:decode-roman-numeral($roman-numeral as xs:string)  
as xs:integer{ 
    $roman-numeral => upper-case() =>  characters() 
    => for-each(map { "M": 1000, "D": 500, "C": 100, "L": 50, "X": 10, "V": 5, "I": 1 })
    => fold-right([0,0], function($number,$accumulator) { 
      if ($number lt $accumulator?2) 
      then [ $accumulator?1 - $number, $number ] 
      else [ $accumulator?1 + $number, $number ] } ) 
    => array:head() 
};

