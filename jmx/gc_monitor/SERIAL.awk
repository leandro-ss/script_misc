BEGIN{ OFS=";";}
{

   match( $0,/OC#[0-9]+|YC#[0-9]+/, arr);

   gsub("Jan","01");    gsub("Feb","02");    gsub("Mar","03");    gsub("Apr","04");
   gsub("May","05");    gsub("Jun","06");    gsub("Jul","07");    gsub("Aug","08");
   gsub("Sep","09");    gsub("Oct","10");    gsub("Nov","11");    gsub("Dec","12");

   gsub("[[:alpha:]]|\\[|\\]|\\(|\\)|\\-|\\,|>|#"," ");

   if( 0 < length(arr[0])){

        print SYSTEM_ID, HOSTNAME, INSTANCE, arr[0], $2"/"$1"/"$4" "$3".000", $9, $10, $11, $12;
   }
}
