BEGIN{ OFS="|"}
{
   match( $0,/-Xverbose:gc/, arr1);
   
   match( $0,/-XverboseTimeStamp/, arr2);
   
   match( $0,/-Xverbose[[:graph:]]*/, arr3);
   
   match( $0,/-Dweblogic.Name=[[:graph:]]*/, arr4);
   
   if( arr1[0] ) {print arr1[0],arr2[0],arr3[0];arr4[0]} 
}