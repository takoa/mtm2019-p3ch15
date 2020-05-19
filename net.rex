/* REXX */                                                            
call clrscn                                                           
numeric digits 13                                                     
rc = isfcalls("ON")                                                   
                                                                      
address SDSF "ISFEXEC NA"                                             
                                                                      
if rc <> 0 then                                                       
  say "Failed to get network activities with the return code" rc"."   
                                                                      
do forever                                                            
  say "Input an address to show the network IN/OUT. Input h for help."
  pull input                                                          
                                                                      
  if input = "Q" | input = "QUIT" then                                
    exit 0                                                            
  else if input = "H" | input = "HELP" then                           
    call show_help                                                    
  else if input = "L" | input = "LIST-ADDRESSES" then                 
    call list_addresses                                               
  else if input = "R" | input = "LIST-RECENTLY-ACTIVE" then           
    call list_active_addresses                                        
  else if input = "A" | input = "ALL" then                            
  do                                                                  
    addr = "ALL"                                                      
    call collect_all_stats                                            
    call show_stats                                                   
    call save_stats                                                   
    call show_graphs                                                  
                                                                      
    leave                                                             
  end                                                                 
  else                                                                
  do                                                                  
    addr = input                                                      
    rowNo = get_row_no(addr)                                          
                                                                      
    if 0 < rowNo then                                                 
    do                                  
      call collect_stats                
      call show_stats                   
      call save_stats                   
                                        
      leave                             
    end                                 
  end                                   
end                                     
                                        
rc = isfcalls("OFF")                    
                                        
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
                                        
pad_with_zeros: procedure               
  parse arg num, len                    
  result = num                          
                                        
  do i = length(num) + 1 to len         
    result = "0"||result                
  end                                   
return result                           
                                        
date_to_str: procedure                  
  parse arg date                                               
                                                               
  result = date                                                
  result = replace(result, ".", "")                            
  result = replace(result, ":", "")                            
  result = replace(result, " ", "")                            
return result                                                  
                                                               
bubblesort: procedure expose array.                            
  parse arg length                                             
                                                               
  do i = 1 to length - 1                                       
    do j = 2 to length - i + 1                                 
      k = j - 1                                                
                                                               
      if array.k < array.j then                                
      do                                                       
        temp = array.j                                         
        array.j = array.k                                      
        array.k = temp                                         
      end                                                      
    end                                                        
  end                                                          
return                                                         
                                                               
show_help:                                                     
  say "(Q)uit                   Quit."                         
  say "(L)ist-address           List all addresses."           
  say "List-(R)ecently-Active   List all addresses sorted by", 
                               "the most recent"               
  say "                         activities."                   
  say "(A)LL                    Collect and show total IN/OUT."
  say "<IPv4 address>:<port>    Collect and show IN/OUT of",   
                               "the specified"                 
  say "                         IPv4 address."                 
  say "(<IPv6 address>):<port>  Collect and show IN/OUT of",   
                               "the specified"                 
  say "                         IPv6 address. Note that you",  
                               "need to enclose"                 
  say "                         the address in parenthesis."     
  say ""                                                         
return                                                           
                                                                 
get_address_str: procedure                                       
  parse arg addr, port                                           
                                                                 
  if pos(":", addr) then                                         
    result = "("addr"):"port                                     
  else                                                           
    result = addr":"port                                         
return result                                                    
                                                                 
list_addresses:                                                  
  address SDSF "ISFEXEC NA"                                      
                                                                 
  do i = 1 to isfrows                                            
    say get_address_str(IPADDR.i, PORT.i)                        
  end                                                            
return                                                           
                                                                 
list_active_addresses:                                           
  do forever                                                     
    say "Excludes addresses which don't have bytes in/out? (Y/N)"
    pull input                                                   
                                                                 
    if input = "Y" | input = "N" then                            
      leave                                                      
  end                                                            
                                                                 
  address SDSF "ISFEXEC NA"                                      
                                                                 
  do i = 1 to isfrows                                            
    array.i = date_to_str(LASTTIME.i)||pad_with_zeros(i, 3)      
  end                                                            
                                                                 
  call bubblesort isfrows                                        
                                                         
  if input = "Y" then                                    
  do                                                     
    j = 0                                                
    do i = 1 to isfrows                                  
      row = format(substr(array.i, 14, 3))               
      in = value(BYTESIN"."row)                          
      out = value(BYTESOUT"."row)                        
                                                         
      if in = 0 | out = 0 then                           
        iterate                                          
      else                                               
      do                                                 
        j = j + 1                                        
        rows.j = row                                     
      end                                                
    end                                                  
                                                         
    rows.0 = j                                           
  end                                                    
  else                                                   
  do                                                     
    do i = 1 to isfrows                                  
      rows.i = format(substr(array.i, 14, 3))            
    end                                                  
                                                         
    rows.0 = isfrows                                     
  end                                                    
                                                         
  say "Last Active        Address"                       
                                                         
  do i = 1 to rows.0                                     
    a = value(IPADDR"."rows.i)                           
    p = value(PORT"."rows.i)                             
                                                         
    say value(LASTTIME"."rows.i)"  "get_address_str(a, p)
  end                                                    
return                                                   
                                                                 
get_row_no:                                                      
  do i = 1 to isfrows                                            
    str = get_address_str(IPADDR.i, PORT.i)                      
                                                                 
    if addr = str then                                           
      return i                                                   
  end                                                            
return 0                                                         
                                                                 
collect_all_stats:                                               
  do forever                                                     
    say "How long do you want to collect the statistics? (ticks)"
    say "1 tick is about a second, but sometimes a bit longer"   
    say "due to a slow execution time."                          
    pull input                                                   
                                                                 
    if 0 < input then                                            
    do                                                           
      ticks = input                                              
      leave                                                      
    end                                                          
                                                                 
    say ""                                                       
  end                                                            
                                                                 
  ins.0 = ticks                                                  
  outs.0 = ticks                                                 
  say "Collecting total bytes IN/OUT for" ticks "ticks..."       
                                                                 
  call syscalls("ON")                                            
  address SDSF "ISFEXEC NA"                                      
                                                                 
  previousIn = 0                                                 
  previousOut = 0                                                
                                                                 
  do i = 1 to isfrows                                            
    previousIn = previousIn + BYTESIN.i                          
    previousOut = previousOut + BYTESOUT.i                    
    a = replace(replace(IPADDR.i, ".", ""), ":", "")||PORT.i  
    rc = value(addrs"."i, a)                                  
    rc = value(addrs"."in"."a, BYTESIN.i)                     
    rc = value(addrs"."out"."a, BYTESOUT.i)                   
  end                                                         
                                                              
  addrs.0 = isfrows                                           
  address syscall "sleep" 1                                   
                                                              
  do i = 1 to ticks                                           
    totalIn = 0                                               
    totalOut = 0                                              
                                                              
    address SDSF "ISFEXEC NA"                                 
                                                              
    do j = 1 to isfrows                                       
      a = replace(replace(IPADDR.j, ".", ""), ":", "")||PORT.j
                                                              
      rc = value(addrs"."in"."a, BYTESIN.j)                   
      rc = value(addrs"."out"."a, BYTESOUT.j)                 
                                                              
      if rc = "addrs.out."||a then                            
      do                                                      
        say something                                         
        addrs.0 = addrs.0 + 1                                 
        rc = value(addrs"."addrs.0, a)                        
      end                                                     
    end                                                       
                                                              
    do j = 1 to addrs.0                                       
      a = addrs.j                                             
      totalIn = totalIn + value(addrs"."in"."a)               
      totalOut = totalOut + value(addrs"."out"."a)            
    end                                                       
                                                              
    ins.i = totalIn - previousIn                              
    outs.i = totalOut - previousOut                           
    previousIn = totalIn                                            
    previousOut = totalOut                                          
    address syscall "sleep" 1                                       
  end                                                               
                                                                    
  say "Collected."                                                  
  say ""                                                            
  call syscalls("OFF")                                              
return                                                              
                                                                    
collect_stats:                                                      
  do forever                                                        
    say "How long would you like to collect the statistics? (ticks)"
    pull input                                                      
                                                                    
    if 0 < input then                                               
    do                                                              
      ticks = input                                                 
      leave                                                         
    end                                                             
                                                                    
    say ""                                                          
  end                                                               
                                                                    
  ins.0 = ticks                                                     
  outs.0 = ticks                                                    
  say "Collecting bytes IN/OUT for" time "seconds on" addr"..."     
                                                                    
  call syscalls("ON")                                               
  address SDSF "ISFEXEC NA"                                         
  rowNo = get_row_no(addr)                                          
  previousIn = BYTESIN.rowNo                                        
  previousOut = BYTESOUT.rowNo                                      
  address syscall "sleep" 1                                         
                                                                    
  do j = 1 to ticks                                                 
    address SDSF "ISFEXEC NA"                                       
                                                                    
    rowNo = get_row_no(addr)                                     
    ins.j = BYTESIN.rowNo - previousIn                           
    outs.j = BYTESOUT.rowNo - previousOut                        
    previousIn = BYTESIN.rowNo                                   
    previousOut = BYTESOUT.rowNo                                 
    address syscall "sleep" 1                                    
  end                                                            
                                                                 
  say "Collected."                                               
  say ""                                                         
  call syscalls("OFF")                                           
return                                                           
                                                                 
show_stats:                                                      
  totalIn = 0                                                    
  totalOut = 0                                                   
                                                                 
  do i = 1 to ins.0                                              
    totalIn = totalIn + ins.i                                    
    totalOut = totalOut + outs.i                                 
  end                                                            
                                                                 
  averageIn = totalIn / ticks                                    
  averageOut = totalOut / ticks                                  
                                                                 
  say "Total bytes IN   :" format(totalIn, 13, 0) "bytes"        
  say "Average bytes IN :" format(averageIn, 13, 0) "bytes/tick" 
  say "Total bytes OUT  :" format(totalOut, 13, 0) "bytes"       
  say "Average bytes OUT:" format(averageOut, 13, 0) "bytes/tick"
  say ""                                                         
return                                                           
                                                                 
save_stats:                                                      
  d = date()                                                     
  t = time()                                                     
                                                                 
  "allocate dataset(ch15.output(netin)) file(netinf) shr reuse"  
  "execio 0 diskw netinf (stem line. open"                       
                                                                      
  lines.1 = "Bytes IN ("addr"," d t")"                                
  lines.2 = "Ticks"                                                   
  lines.3 = "Bytes"                                                   
  lines.4 = ins.0                                                     
                                                                      
  do i = 1 to ins.0                                                   
    j = i + 4                                                         
    lines.j = ins.i                                                   
  end                                                                 
                                                                      
  "execio * diskw netinf (finis stem lines."                          
  "free file(netinf)"                                                 
                                                                      
  "allocate dataset(ch15.output(netout)) file(netoutf) shr reuse"     
  "execio 0 diskw netoutf (stem line. open"                           
                                                                      
  lines.1 = "Bytes OUT ("addr"," d t")"                               
  lines.2 = "Ticks"                                                   
  lines.3 = "Bytes"                                                   
  lines.4 = outs.0                                                    
                                                                      
  do i = 1 to outs.0                                                  
    j = i + 4                                                         
    lines.j = outs.i                                                  
  end                                                                 
                                                                      
  "execio * diskw netoutf (finis stem lines."                         
  "free file(netoutf)"                                                
return                                                                
                                                                      
show_graphs:                                                          
  do forever                                                          
    say "Do you want to show and save graphs of the statistics? (Y/N)"
    pull input                                                        
                                                                      
    if input = "Y" | input = "N" then                                 
      leave                                                           
 end                                                           
                                                               
 if input = "N" then                                           
   return                                                      
                                                               
 ave = ticks / 10                                              
                                                               
 say "The results will be averaged by" ave "elements."         
 say "***"                                                     
 pull input                                                    
 call graph "ch15.output(netin)", "ch15.output(ingraph)", ave  
 say "Saved the graph to ch15.output(ingraph)."                
 say "***"                                                     
 pull input                                                    
 call graph "ch15.output(netout)", "ch15.output(outgraph)", ave
 say "Saved the graph to ch15.output(outgraph)."               
return                                                         
