BEGIN{ OFS="|"}
{

    gsub( /$.*[^-Xverbose:gc[[:graph:]]*].*^/ , "" , $0);
   


   print 
}




echo 'blah <a href="http://some.site.tld/page1.html">blah blah</a>' | awk '{gsub(/^[^"]*"|"[^"]*$/,"");print}'


 awk '{gsub(/^[^-]*/,"");print}' ps.txt
 
 
 b(?!ar)|(?<!b)a|a(?!r)|(?<!ba)r|[^bar][[:graph:]]*