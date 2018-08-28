###### SCRIPT PARA COLETA DE GC SOB ALGORITMO CMS - TESTADO EM HOSTSPOT JDK6 ######
BEGIN{ OFS=";"; temp =0;}
{
   match( $0,/Full GC|ParNew|concurrent mode failure|CMS[A-z\-]*:/, arr);
   gsub( "[[:alpha:]]|\\[|\\]|\\(|\\)|\\-|\\,|>|#|:|=|\\/" ," ");
   gsub( ":", "", arr[0]);

   if(arr[0] == "ParNew"){

        print HOSTNAME, INSTANCE,arr[0] " - YOUNG GC", $1, $3, $4, $5, $6;

   } else if(arr[0] == "Full GC"){

        print HOSTNAME, INSTANCE,arr[0] " - OLD GC", $1, $3, $4, $5, $6;
        print HOSTNAME, INSTANCE,arr[0] " - TOTAL GC", $1, $7, $8, $9;
        print HOSTNAME, INSTANCE,arr[0] " - PERM GC", $1, $10, $11, $12, $13;

    }else if( 0 < match(arr[0], "CMS-initial-mark")){

        print HOSTNAME, INSTANCE, arr[0],$1, $4, $5, $6;

    }else if( 0 < match(arr[0], "CMS-concurrent")){

        print HOSTNAME, INSTANCE, arr[0],$1 ,"","","", $3;
 
   } else if( 0 < match(arr[0], "CMS-remark")){

        print HOSTNAME, INSTANCE, arr[0]" - YOUNG GC",$1, "", $2, $3, $5;
        print HOSTNAME, INSTANCE, arr[0]" - OLD GC", $1, "", $9, $10, $13;
        print HOSTNAME, INSTANCE, arr[0]" - TOTAL GC", $1, "", $11, $12;

   } else if( 0 < match(arr[0], "concurrent mode failure")){

        print HOSTNAME, INSTANCE, arr[0]" - OLD GC", temp_data, $1, $2, $3, $4;
        print HOSTNAME, INSTANCE, arr[0]" - TOTAL GC", temp_data, $5, $6, $7, $11;
        print HOSTNAME, INSTANCE, arr[0]" - PERM GC", temp_data, $8, $9, $10, $11;
   }
   temp_data = $1
}
