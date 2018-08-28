BEGIN{ arr_list[0,0]=0; iterator=0; length_arr_fields=5;

    split( "1|2|3|4|8"    , psyounggen_young_arr_fields, "|");
    split( "1|5|6|7|8"    , psyounggen_total_arr_fields, "|");

    split( "1|2|3|4|14"   , psoldgen_young_arr_fields, "|");
    split( "1|5|6|7|14"   , psoldgen_old_arr_fields, "|");
    split( "1|8|9|10|14"  , psoldgen_total_arr_fields, "|");
    split( "1|11|12|13|14", psoldgen_perm_arr_fields, "|");

}
{
   match( $0,/Full GC|GC/, arr);
   
   gsub("[[:alpha:]]|\\[|\\]|\\(|\\)|\\-|\\,|>|#|:"," ");
   
   if(arr[0] == "GC"){
        
        iterate( arr[0]"_Young",psyounggen_young_arr_fields);
        iterate( arr[0]"_Total",psyounggen_total_arr_fields);
        
   } else if(arr[0] == "Full GC"){
        
        iterate( arr[0]"_Young",psoldgen_young_arr_fields);
        iterate( arr[0]"_Old",psoldgen_old_arr_fields);
        iterate( arr[0]"_Total",psoldgen_total_arr_fields);
        iterate( arr[0]"_Perm",psoldgen_perm_arr_fields);
   }
}
END{
     creation_time = arr_list[iterator-1,1];
     
     while(iterator>0){
         iterator--;
         
         time = creation_time - arr_list[iterator,1];
         
         printf "%s;", strftime("%Y-%m-%d %H:%M:%S.000", FILE_TIME - time);
         
         for( i=0; i <= length_arr_fields; i++){
         
             printf "%s;", arr_list[iterator,i];
         }
         
         printf "\n";
     }
}
function iterate( def, arr_fields){
        arr_list[iterator,0] = def;
        
        for(i=1; i <= length_arr_fields; i++){ 

            arr_list[iterator,i] = $arr_fields[i];
        }
        iterator++;
}
