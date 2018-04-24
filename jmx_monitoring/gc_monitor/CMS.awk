BEGIN{ OFS = ";"; print "INSTANCE;ACTION;DATA;BEFORE - GC;AFTER - GC;HEAP;TIME"; }
{
   match( $0,/Full GC|ParNew|concurrent mode failure|CMS[A-z\-]*:/, arr);

   gsub( "[[:alpha:]]|\\[|\\]|\\(|\\)|\\-|\\,|\\/|>|#|=| +:|: +" ," "); gsub( ":", "", arr[0]); gsub( "\\.", ",");
   
   
   if(arr[0] == "ParNew"){

        print  HOSTNAME, FILENAME, arr[0] " - YOUNG GC", $3"/"$2"/"$1" "$4, $8, $9, $10, $11;
        print  HOSTNAME, FILENAME, arr[0] " - TOTAL GC", $3"/"$2"/"$1" "$4, $12, $13, $14, $15;
        
   } else if(arr[0] == "Full GC"){

        print  HOSTNAME, FILENAME,arr[0] " - OLD GC", $3"/"$2"/"$1" "$4, $8, $9, $10, $11;
        print  HOSTNAME, FILENAME,arr[0] " - TOTAL GC", $3"/"$2"/"$1" "$4, $12, $13, $14, $18;
        print  HOSTNAME, FILENAME,arr[0] " - PERM GC", $3"/"$2"/"$1" "$4, $15, $16, $17;

    }else if( 0 < match(arr[0], "CMS-initial-mark")){

        print  HOSTNAME, FILENAME, arr[0] " - OLD   GC", $3"/"$2"/"$1" "$4, "", $8, $9;
        print  HOSTNAME, FILENAME, arr[0] " - TOTAL GC", $3"/"$2"/"$1" "$4, "", $10, $11, $12;

    }else if( 0 < match(arr[0], "CMS-concurrent")){

        print  HOSTNAME, FILENAME, arr[0], $3"/"$2"/"$1" "$4, "", "", "", $7;
 
   } else if( 0 < match(arr[0], "CMS-remark")){

        print  HOSTNAME, FILENAME, arr[0]" - YOUNG GC", $3"/"$2"/"$1" "$4, "", $7 , $8;
        print  HOSTNAME, FILENAME, arr[0]" - OLD   GC", $3"/"$2"/"$1" "$4, "", $14, $15;
        print  HOSTNAME, FILENAME, arr[0]" - TOTAL GC", $3"/"$2"/"$1" "$4, "", $16, $17, $18;

   } else if( 0 < match(arr[0], "concurrent mode failure")){
# Falta testar
        print  HOSTNAME, FILENAME, arr[0]" - OLD GC", $3"/"$2"/"$1" "$4, temp_data, $9, $10, $11, $13;
        print  HOSTNAME, FILENAME, arr[0]" - TOTAL GC", $3"/"$2"/"$1" "$4, temp_data, $13, $15, $16, $11;
        print  HOSTNAME, FILENAME, arr[0]" - PERM GC",  $3"/"$2"/"$1" "$4, temp_data, $17, $18, $10, $11;
   }
   temp_data = $9
}
