BEGIN{ OFS=";";

   gsub("[[:alpha:]]|\\[|\\]|\\(|\\)|\\-|\\,|>|#|:"," ", END_LINE); 

   split( END_LINE, SPL, " "); 
   
   time = FILE_TIME - SPL[2];   
}
{

   match( $0,/memory/, arr1);
   match( $0,/OC#[0-9]+|YC#[0-9]+/, arr2);

   gsub("[[:alpha:]]|\\[|\\]|\\(|\\)|\\-|\\,|>|#|:"," ");

   if( 0 < length(arr1[0]) && 0 < length(arr2[0])){

        print arr2[0], strftime("%Y-%m-%d %H:%M:%S.000",time+$2), $4, $5, $6, $7;

   }
}
