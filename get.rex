/* REXX */                                                      
signal on halt                                                  
                                                                
isExiting = 0                                                   
                                                                
do until isExiting                                              
  call show_main_screen                                         
end                                                             
                                                                
signal off halt                                                 
                                                                
exit 0                                                          
                                                                
show_main_screen:                                               
  clrscn                                                        
                                                                
  say '   System Information Utility    '                       
  say ' '                                                       
  say '   Information requested:'                               
  say '   1. Report specific message identifier found in SYSLOG'
  say '   2. Report string found in SYSLOG'                     
  say '   3. Report TSO logons'                                 
  say '   4. Report specific ID successful TSO logon'           
  say '   5. Show realtime System Information, SYS'             
  say '   6. Report network bytes IN/OUT with NA'               
  say '   7. Exit'                                              
  say ' '                                                       
  say '   Enter report number'                                  
  pull answer                                                   
  answer = strip(answer)                                        
                                                                
  Select                                                        
    When answer = 1 then 'exec ch15(msgid)'                     
    When answer = 2 then 'exec ch15(strng)'                     
    When answer = 3 then 'exec ch15(logons)'                    
    When answer = 4 then 'exec ch15(idlogon)'                   
    When answer = 5 then 'exec ch15(si)'                        
    When answer = 6 then 'exec ch15(net)'                       
    When answer = 7 then isExiting = 1  
    When answer = "Q" then isExiting = 1
  End                                   
                                        
  if ¬isExiting then                    
  do                                    
    say "***"                           
    pull input                          
  end                                   
return                                  
                                        
halt:                                   
  call show_main_screen                 
exit                                    
