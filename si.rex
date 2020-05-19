/* REXX */                                                   
signal on halt                                               
                                                             
call syscalls("ON")                                          
call isfcalls("ON")                                          
                                                             
address SDSF "ISFEXEC SYS"                                   
"exec ch15(sibase)"                                          
                                                             
exit 0                                                       
                                                             
halt:                                                        
  say ""                                                     
  say "Writing SYS outputs to ch15.output(top)..."           
  address SDSF "ISFEXEC SYS"                                 
                                                             
  "allocate dataset(ch15.output(top)) file(topout) shr reuse"
  "execio 0 diskw topout (stem line. open"                   
                                                             
  line.1 = date() time()                                     
  "execio 1 diskw topout (stem line."                        
                                                             
  do i = 1 to isfrows                                        
    line.1 = "Row" i                                         
    "execio 1 diskw topout (stem line."                      
                                                             
    do j = 1 to words(isfcols)                               
      col = word(isfcols, j)                                 
      line.j = col", "value(col"."i)                         
    end                                                      
                                                             
    "execio * diskw topout (Finis stem line."                
  end                                                        
                                                             
  "free file(topout)"                                        
                                                             
  say "Done"                                                 
  call syscalls("OFF")                                       
  call isfcalls("OFF")
exit                  
