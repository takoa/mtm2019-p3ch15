/* REXX */                                                     
clrscn                                                         
                                                               
rc=isfcalls('ON')                                              
                                                               
isfsysid="s0w1"                                                
isfdate="mmddyyyy /"                                           
currday=date("C")                                              
currday=currday-2                                              
isflogstartdate=date("U",currday,"C")                          
isflogstarttime=time("N")                                      
isflogstopdate=date("U")                                       
isflogstoptime=time("N")                                       
                                                               
do forever                                                     
  say "Input ID of the user you want to get logon information."
  pull input                                                   
                                                               
  if pull /= "" then                                           
  do                                                           
    id = input                                                 
    leave                                                      
  end                                                          
end                                                            
                                                               
say "Getting logons of" id"..."                                
say ""                                                         
                                                               
isffind = substr(id, 1, 8) "ON TSOINRDR"                       
isffindlim = 9999999                                           
isfscrolltype = 'FINDNEXT'                                     
isflinelim = 1                                                 
                                                               
logons.0 = 0                                                   
                                                               
do until isfnextlinetoken=''                                   
  Address SDSF "ISFLOG READ TYPE(SYSLOG)"                      
                                                               
  if 4 < rc then                                                 
  do                                                             
    call msgrtn                                                  
    exit 20                                                      
  end                                                            
                                                                 
  dt = date("N", substr(isfline.1, 20, 5), "J")                  
  tm = substr(isfline.1, 26, 11)                                 
                                                                 
  logons.0 = logons.0 + 1                                        
  rc = value("logons."user"."logons.0, id)                       
  rc = value("logons.ldt."logons.0, dt)                          
  rc = value("logons.ltm."logons.0, tm)                          
                                                                 
  say "Found" id"'s logon at" dt "on" tm"."                      
                                                                 
  isfstartlinetoken = isfnextlinetoken                           
end                                                              
                                                                 
outs.1 = id"'s Logons"                                           
outs.2 = "Datetime"                                              
                                                                 
do i = 1 to logons.0                                             
  j = i + 2                                                      
  outs.j = value("logons.ldt."i)"  "value("logons.ltm."i)        
end                                                              
                                                                 
"allocate dataset(ch15.output(idlogon)) file(idlogonf) shr reuse"
"execio 0 diskw idlogonf (stem outs. open"                       
"execio * diskw idlogonf (finis stem outs."                      
"free file(idlogonf)"                                            
                                                                 
say ""                                                           
say "Saved" id"'s logons to ch15.output(idlogon)."               
                                                                 
rc=isfcalls("off")                                               
                                                                 
exit                                                             
                                        
msgrtn: procedure expose isfmsg isfmsg2.
  if isfmsg <> "" then                  
    say "isfmsg is:" isfmsg             
                                        
  do ix=1 to isfmsg2.0                  
    say "isfmsg2."ix "is:" isfmsg2.ix   
  end                                   
return                                  
