/* REXX */                                                   
/*----------------------------------------------*/           
"allocate dataset(ch15.output(strng)) file(msgout) shr reuse"
"execio 0 diskw msgout (stem msg. open"                      
/*----------------------------------------------*/           
clrscn                                                       
say 'enter string'                                           
parse pull strng                                             
strng = strip(strng)                                         
/*----------------------------------------------*/           
rc=isfcalls('ON')                                            
isfsysid="s0w1"                                              
isfdate="mmddyyyy /"                                         
currday=date("C")                                            
currday=currday-2                                            
isflogstartdate=date("U",currday,"C")                        
isflogstarttime=time("N")                                    
isflogstopdate=date("U")                                     
isflogstoptime=time("N")                                     
/*----------------------------------------------*/           
isffind = strng                                              
isffindlim = 9999999                                         
isfscrolltype = 'FINDNEXT'                                   
isflinelim = 1                                               
/*----------------------------------------------*/           
do until isfnextlinetoken=''                                 
   Address SDSF "ISFLOG READ TYPE(SYSLOG)"                   
   lrc=rc                                                    
   if lrc>4 then                                             
     do                                                      
       call msgrtn                                           
       exit 20                                               
     end                                                     
/*----------------------------------------------*/           
/*-- Process the returned variables ------------*/           
/*----------------------------------------------*/           
   do ix=1 to isfline.0                                      
     call write_output                                       
   end                                            
/*----------------------------------------------*/
/* Continue reading SYSLOG where we left off    */
/*----------------------------------------------*/
   isfstartlinetoken = isfnextlinetoken           
end                                               
rc=isfcalls("off")                                
"execio 0 diskw msgout (Finis"                    
"free file(msgout)"                               
exit                                              
/*----------------------------------------------*/
/* Subroutine to list error messages */           
/*----------------------------------------------*/
msgrtn: procedure expose isfmsg isfmsg2.          
/*----------------------------------------------*/
/* The isfmsg variable contains a short message */
/*----------------------------------------------*/
if isfmsg <> "" then                              
  Say "isfmsg is:" isfmsg                         
/*----------------------------------------------*/
/* The isfmsg2 stem contains additional         */
/* descriptive error messages                   */
/*----------------------------------------------*/
do ix=1 to isfmsg2.0                              
  Say "isfmsg2."ix "is:" isfmsg2.ix               
end                                               
return                                            
/*----------------------------------------------*/
write_output:                                     
/*----------------------------------------------*/
say isfline.ix                                    
  msg.1 = isfline.ix                              
  "execio 1 diskw msgout (stem msg."              
return                                            
