xquery version '3.1';
(:~ look for pagenos in pdf text
pagenos:page-report($doc )=>pagenos:inverted-map()
:)
module namespace pagenos = 'urn:pageno';