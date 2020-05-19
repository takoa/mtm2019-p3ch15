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
  say "It may take some time to complete the process. Do you want to",
      "show intermediate outputs to see if it's working? (Y/N)"       
  pull input                                                          
                                                                      
  if input = "Y" | input = "N" then                                   
  do                                                                  
    showsOutputs = input                                              
    leave                                                             
  end                                                                 
end                                                                   
                                                                      
say "Getting all logons (last logons) and failed attempts."           
say ""                                                                
                                                                      
isffind = "ON TSOINRDR"                                               
isffindlim = 9999999                                                  
isfscrolltype = 'FINDNEXT'                                            
isflinelim = 1                                                        
                                                                      
slogons.0 = 0                                                         
                                                                      
do until isfnextlinetoken=''                                          
  Address SDSF "ISFLOG READ TYPE(SYSLOG)"                             
                                                                     
  if 4 < rc then                                                     
  do                                                                 
    call msgrtn                                                      
    exit 20                                                          
  end                                                                
                                                                     
  id = substr(isfline.1, 66, 8)                                      
  dt = date("N", substr(isfline.1, 20, 5), "J")                      
  tm = substr(isfline.1, 26, 11)                                     
                                                                     
  if slogons.id /= 1 then                                            
  do                                                                 
    slogons.0 = slogons.0 + 1                                        
    slogons.id = 1                                                   
    rc = value(slogons"."slogons.0, id)                              
                                                                     
    if showsOutputs = "Y" then                                       
      say "Found" id "logged on at" dt "on" tm"."                    
  end                                                                
                                                                     
  rc = value(slogons"."remove_trailing_spaces(id)"."ldt, dt)         
  rc = value(slogons"."remove_trailing_spaces(id)"."ltm, tm)         
                                                                     
  isfstartlinetoken = isfnextlinetoken                               
end                                                                  
                                                                     
souts.1 = "User     Last Accessed"                                   
                                                                     
do i = 1 to slogons.0                                                
  j = i + 1                                                          
  souts.j = slogons.i,                                               
            value(slogons"."remove_trailing_spaces(slogons.i)"."ldt),
            "",                                                      
            value(slogons"."remove_trailing_spaces(slogons.i)"."ltm) 
end                                                                  
                                                                     
isffind = "ICH408I"                                                  
isffindlim = 9999999                                            
isfscrolltype = 'FINDNEXT'                                      
isflinelim = 1                                                  
                                                                
flogons.0 = 0                                                   
                                                                
do until isfnextlinetoken=''                                    
  Address SDSF "ISFLOG READ TYPE(SYSLOG)"                       
                                                                
  if 4 < rc then                                                
  do                                                            
    call msgrtn                                                 
    exit 20                                                     
  end                                                           
                                                                
  id = substr(isfline.1, 70, 8)                                 
  dt = date("N", substr(isfline.1, 20, 5), "J")                 
  tm = substr(isfline.1, 26, 11)                                
                                                                
  flogons.0 = flogons.0 + 1                                     
  rc = value("flogons."user"."flogons.0, id)                    
  rc = value("flogons.adt."flogons.0, dt)                       
  rc = value("flogons.atm."flogons.0, tm)                       
                                                                
  if showsOutputs = "Y" then                                    
    say "Found someone failed to logon as" id "at" dt "on" tm"."
                                                                
  isfstartlinetoken = isfnextlinetoken                          
end                                                             
                                                                
fouts.1 = "Target   Time"                                       
                                                                
do i = 1 to flogons.0                                           
  j = i + 1                                                     
  fouts.j = value("flogons."user"."i),                          
            value("flogons.adt."i)"  "value("flogons.atm."i)    
end                                                             
                                                                
"allocate dataset(ch15.output(slogons)) file(slogonsf) shr reuse"
"execio 0 diskw slogonsf (stem souts. open"                      
"execio * diskw slogonsf (finis stem souts."                     
"free file(slogonsf)"                                            
                                                                 
"allocate dataset(ch15.output(flogons)) file(flogonsf) shr reuse"
"execio 0 diskw flogonsf (stem fouts. open"                      
"execio * diskw flogonsf (finis stem fouts."                     
"free file(flogonsf)"                                            
                                                                 
say ""                                                           
say "Saved successful logons to ch15.output(slogons)."           
say "Saved failed logons to ch15.output(flogons)."               
                                                                 
rc=isfcalls("off")                                               
                                                                 
exit                                                             
                                                                 
remove_trailing_spaces: procedure                                
  parse arg str                                                  
                                                                 
  do i = length(str) by -1 to 1                                  
    if substr(str, i, 1) /= " " then                             
      leave                                                      
  end                                                            
                                                                 
  str = substr(str, 1, i)                                        
return str                                                       
                                                                 
msgrtn: procedure expose isfmsg isfmsg2.                         
  if isfmsg <> "" then                                           
    say "isfmsg is:" isfmsg                                      
                                                                 
  do ix=1 to isfmsg2.0                                           
    say "isfmsg2."ix "is:" isfmsg2.ix                            
  end                                                            
return                                                           
