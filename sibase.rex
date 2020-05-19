/* REXX */                                                    
address SDSF "ISFEXEC SYS"                                    
                                                              
do forever                                                    
  say "Input the row number you want to see the information ",
      "(0 < row <=" isfrows")."                               
  say "Input 0 if you want to choose by SYSNAME."             
  parse pull rowID                                            
  rowID = strip(rowID)                                        
                                                              
  if rowID = 0 then                                           
    do forever                                                
      say "Input SYSNAME to see (selections listed below)."   
                                                              
      do i = 1 to isfrows                                     
        say value(SYSNAME"."i)                                
      end                                                     
                                                              
      pull input                                              
      input = translate(input)                                
                                                              
      if input = "CANCEL" then                                
        leave                                                 
                                                              
      do i = 1 to isfrows                                     
        if input = value(SYSNAME"."i) then do                 
          rowID = i                                           
          leave                                               
        end                                                   
      end                                                     
                                                              
      if rowID \= 0 then                                      
        leave                                                 
      else                                                    
        say "SYSNAME not found."                              
    end                                                       
                                                              
  if rowID = 0 then                                           
    iterate                             
  else if rowID <= isfrows then         
    leave                               
  else                                  
    say "Invalid input."                
end                                     
                                        
call start_main_loop                    
                                        
exit 0                                  
                                        
replace: procedure                      
  parse arg str, old, new               
                                        
  i = pos(old, str)                     
                                        
  do while i \= 0                       
    if (0 < i) then                     
      str = left(str, i - 1) ||,        
            new ||,                     
            substr(str, i + length(old))
    i = pos(old, str)                   
  end                                   
return str                              
                                        
start_main_loop:                        
  do forever                            
    address SDSF "ISFEXEC SYS"          
    clrscn                              
    call display_sysinfo                
    address syscall "sleep" 5           
  end                                   
return                                  
                                        
format_columns: procedure               
  parse arg str, width                  
  whitespacePos = pos(" ", str)         
  str = str" |"                         
                                                             
  if whitespacePos \= 0 then                                 
    str = replace(str, " ", "*")                             
                                                             
  str = justify(str, width)                                  
  str = replace(str, "|", "")                                
  str = replace(str, "*", " ")                               
return str                                                   
                                                             
print_row:                                                   
  parse arg name1, column1, name2, column2                   
  say format_columns(name1||value(column1"."rowID), 20),     
      format_columns(name2||value(column2"."rowID), 54)      
return                                                       
                                                             
display_sysinfo:                                             
  say "  ######################## REALTIME SDSF SYS VIEWER", 
      "########################"                             
  say "  Hit the attention key and input HI to exit."        
  say "  "date() time()"  Selected Row:" rowID,              
      " Update Interval: 5sec"                               
  say ""                                                     
  say "Name 1   Value 1    Name 2   Value 2"                 
  call print_row "SYSNAME**", SYSNAME,  "SYSLEVEL*", SYSLEVEL
  call print_row "CPU%*****", CPUPR,    "SIO******", SIO     
  call print_row "Aux%*****", AUXPCT,   "CSA%*****", CSAPCT  
  call print_row "SQA%*****", SQAPCT,   "ECSA%****", ECSAPCT 
  call print_row "ESQAPCT**", ESQAPCT,  "UIC******", UIC     
  call print_row "CADS%****", CADSPCT,  "PageRate*", PAGERATE
  call print_row "Real*****", REAL,     "RealAFC**", REALAFC 
  call print_row "RealAFCB*", REALAFCB, "Fix%*****", FIXPCT  
  call print_row "FixB%****", FIXBPCT,  "MaxASID**", MAXASID 
  call print_row "FreeASID*", FREEASID, "BadASID**", BADASID 
  call print_row "STC******", STCNUM,   "TSU******", TSUNUM  
  call print_row "Job******", JOBNUM,   "WTOR*****", WTORNUM 
  call print_row "Sysplex**", SYSPLEX,  "LPAR*****", LPAR    
  call print_row "VMUser***", VMUSER,   "JES******", JESNAME 
  call print_row "JESNode**", JESNODE,  "SMF******", SMF     
  call print_row "IPLVol***", IPLVOL,   "IPLUnit**", IPLUNIT 
  call print_row "IPLType**", IPLTYPE,  "IPLDate**", IPLDATE 
  call print_row "IPLDays**", IPLDAYS,  "CVTVERID*", CVTVERID
  call print_row "LoadParm*", LOADPARM, "LoadDSN**", LOADDSN 
  call print_row "LoadUnit*", LOADUNIT, "IEASYS***", IEASYS  
  call print_row "GRS******", GRS,      "IEASYM***", IEASYM  
  call print_row "HWName***", HWNAME,   "CPC******", CPC     
  call print_row "MSU******", MSU,      "SysMSU***", SYSMSU  
  call print_row "AvgMSU***", AVGMSU,   "#CPU*****", CPUNUM  
  call print_row "#ZAAP****", ZAAPNUM,  "#ZIIP****", ZIIPNUM 
  call print_row "OSConfig*", OSCONFIG, "EDT******", EDT     
  call print_row "NUCLST***", NUCLST,   "IODFDSN**", IODFDSN 
  call print_row "IEANUC***", IEANUC,   "IODFDate*", IODFDATE
  call print_row "CatVol***", CATVOL,   "CATDSN***", CATDSN  
  call print_row "CatType**", CATTYPE,  "SSCP*****", SSCP    
  call print_row "NetID****", NETID,    "StatDate*", StatDate
  call print_row "IPLCurr**", IPLCUNIT, "IODFUnit*", IODFUNIT
  say format_columns("IODFCurr*"value(IODFCUNIT"."rowID), 20)
return                                                       
