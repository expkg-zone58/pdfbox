(:~  maven access
 :
 ::)
module namespace mvn = 'urn:quodatum:maven:1';


declare variable $mvn:example := <dependency>
  <groupId>org.ccil.cowan.tagsoup</groupId>
  <artifactId>tagsoup</artifactId>
  <version>1.2.1</version>
</dependency>;

declare function mvn:url($dep as element(dependency),$ext as xs:string)
as xs:string { 

    string-join(
        ("https://repo.maven.apache.org/maven2/",
          replace($dep/groupId,'.',"/"),
          "/",$dep/artifactId, "-", $dep/version, ".",$ext
          ))
 };

