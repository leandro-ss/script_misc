BEGIN{ arr_list[0,0]=0; iterator=0; length_arr_fields=5;
    split( "1|10|11|12|13"    , gnc_arr_fields, "|");
}
{
   match( $0,/memory/, arr1);
   match( $0,/OC#[0-9]+|YC#[0-9]+/, arr2);

   gsub("\\,",".");
   gsub("[[:alpha:]]|\\[|\\]|\\(|\\)|\\-|\\,|>|#|:"," ");
   
    if( 0 < length(arr1[0]) && 0 < length(arr2[0])){
        
        iterate( arr2[0],gnc_arr_fields);
        
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
