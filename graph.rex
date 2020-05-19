/* REXX */                                       
parse arg src, dst, ave                          
                                                 
call draw_graph                                  
call save_graph                                  
                                                 
exit 0                                           
                                                 
draw_graph:                                      
  bufferWidth = 78                               
  bufferHeight = 30                              
  graphX = 9                                     
  graphY = 6                                     
  graphWidth = 69                                
  graphHeight = 20                               
                                                 
  "allocate dataset("src") file(fin) shr reuse"  
  "execio * diskr fin (Finis stem lines."        
                                                 
  title = remove_trailing_spaces(lines.1)        
  xLabel = remove_trailing_spaces(lines.2)       
  yLabel = remove_trailing_spaces(lines.3)       
  xRangeMin = "1"                                
  graphData.0 = remove_trailing_spaces(lines.4)  
  xRangeMax = graphData.0                        
                                                 
  i = 5                                          
  do j = 1 to graphData.0                        
    graphData.j = remove_trailing_spaces(lines.i)
    i = i + 1                                    
  end                                            
                                                 
  do i = ave to graphData.0                      
    d = 0                                        
    do j = 0 to ave - 1                          
      index = i - j                              
      d = d + graphData.index                    
    end                                          
                                         
    graphData.index = d / ave        
  end                                
                                     
  graphData.0 = graphData.0 - ave + 1
  xRangeMax = graphData.0            
                                     
  call clrscn                        
  call create_buffer                 
  call align_data                    
  call adjust_data                   
                                     
  call set_labels                    
  call draw_frame                    
  call draw_graph_line               
  call draw_buffer                   
return                               
                                     
remove_trailing_spaces: procedure    
  parse arg str                      
                                     
  do i = length(str) by -1 to 1      
    if substr(str, i, 1) /= " " then 
      leave                          
  end                                
                                     
  str = substr(str, 1, i)            
return str                           
                                     
create_buffer:                       
  do x = 1 to bufferWidth            
    do y = 1 to bufferHeight         
      buffer.x.y = " "               
    end                              
  end                                
return                               
                                     
set_labels:                          
  titleX = trunc(graphX + graphWidth / 2 - length(title) / 2 - 1) 
                                                                  
  do i = 1 to length(title)                                       
    x = titleX + i - 1                                            
    j = graphY - 2                                                
    buffer.x.j = substr(title, i, 1)                              
  end                                                             
                                                                  
  xLabX = trunc(graphX + graphWidth / 2 - length(xLabel) / 2 - 1) 
  xLabY = graphY + graphHeight + 1                                
                                                                  
  do i = 1 to length(xLabel)                                      
    x = xLabX + i - 1                                             
    buffer.x.xLabY = substr(xLabel, i, 1)                         
  end                                                             
                                                                  
  yLabY = trunc(graphY + graphHeight / 2 - length(yLabel) / 2 - 1)
                                                                  
  do i = 1 to length(yLabel)                                      
    y = yLabY + i - 1                                             
    buffer.1.y = substr(yLabel, i, 1)                             
  end                                                             
return                                                            
                                                                  
draw_buffer:                                                      
  do y = 1 to bufferHeight                                        
    msg = ""                                                      
                                                                  
    do x = 1 to bufferWidth                                       
      msg = msg||buffer.x.y                                       
    end                                                           
                                                                  
    say msg                                                       
  end                                                             
return                                                            
                                                                  
draw_frame:                                                       
  graphBottom = (graphY + graphHeight - 1)                        
                                                             
  do y = graphY to graphBottom                               
    if y = graphY then                                       
    do                                                       
      max = graphData.0                                      
                                                             
      do i = 2 to graphData.0                                
        if max < graphData.i then                            
          max = graphData.i                                  
      end                                                    
                                                             
      max = shorten_digit(max)                               
                                                             
      do i = 1 to length(max)                                
        j = graphX - 1 - i                                   
        buffer.j.graphY = substr(max, length(max) - i + 1, 1)
      end                                                    
    end                                                      
                                                             
    buffer.graphX.y = "|"                                    
                                                             
    if y = graphBottom then                                  
    do                                                       
      j = graphX - 2                                         
      buffer.j.y = 0                                         
      buffer.graphX.y = "+"                                  
                                                             
      do x = (graphX + 1) to (graphX + graphWidth - 1)       
        buffer.x.y = "-"                                     
      end                                                    
    end                                                      
  end                                                        
                                                             
  graphBottomP1 = graphBottom + 1                            
                                                             
  buffer.graphX.graphBottomP1 = "|"                          
  do i = 1 to length(xRangeMin)                              
    j = graphX + i                                           
    buffer.j.graphBottomP1 = substr(xRangeMin, i, 1)   
  end                                                  
                                                       
  do i = 1 to length(xRangeMax)                        
    j = graphX + graphWidth - 2 - length(xRangeMax) + i
    buffer.j.graphBottomP1 = substr(xRangeMax, i, 1)   
  end                                                  
  graphLast = graphX + graphWidth - 1                  
  buffer.graphLast.graphBottomP1 = "|"                 
  buffer.graphLast.graphBottom = "+"                   
return                                                 
                                                       
draw_graph_line:                                       
  i = 1                                                
  do x = graphX to (graphX + graphWidth - 1)           
    yZero = graphY + graphHeight- 1                    
    j = trunc(yZero - graphDots.i + 0.5)               
    buffer.x.j = "*"                                   
    i = i + 1                                          
  end                                                  
return                                                 
                                                       
align_data:                                            
  if (graphData.0 - 1) < graphWidth then               
  do                                                   
    do i = 0 to graphData.0                            
      temp.i = graphData.i                             
    end                                                
    m = trunc(graphWidth / graphData.0 + 1) * 3        
                                                       
    i = 1                                              
    do j = 1 to temp.0                                 
      do k = 1 to m                                    
        graphData.i = temp.j                           
        i = i + 1                                      
      end                                              
    end                                                
                                                       
    graphData.0 = temp.0 * m                                  
  end                                                         
                                                              
  step = (graphData.0 - 1) / graphWidth                       
                                                              
  do i = 0 to graphWidth - 1                                  
    startPos = i * step + 1                                   
    startIndex = trunc(startPos)                              
    endIndex = trunc(startPos + step)                         
                                                              
    do j = startIndex to endIndex                             
      if j = startIndex then                                  
        sum = graphData.j * (1 - (startPos - startIndex))     
      else if j = endIndex then                               
        sum = sum + graphData.j * (startPos + step - endIndex)
      else                                                    
        sum = sum + graphData.j                               
    end                                                       
                                                              
    index = i + 1                                             
    graphDots.index = sum / step                              
  end                                                         
return                                                        
                                                              
adjust_data:                                                  
  max = graphDots.1                                           
                                                              
  do i = 2 to graphWidth                                      
    if max < graphDots.i then                                 
      max = graphDots.i                                       
  end                                                         
                                                              
  do i = 1 to graphWidth                                      
    graphDots.i = graphDots.i / max * (graphHeight - 1)       
  end                                                         
return                                                        
                                                              
shorten_digit: procedure                                      
  parse arg n                                       
                                                    
  if 10000000000 <= n then                          
    result = trunc(n / 1000000000 + 0.5)||"G"       
  else if 10000000 <= n then                        
    result = trunc(n / 1000000 + 0.5)||"M"          
  else if 10000 <= n then                           
    result = trunc(n / 1000 + 0.5)||"K"             
  else                                              
    result = trunc(n)                               
return result                                       
                                                    
save_graph:                                         
  "allocate dataset("dst") file(graphout) shr reuse"
  "execio 0 diskw graphout (stem ls. open"          
                                                    
  do y = 1 to bufferHeight                          
    ls.y = ""                                       
                                                    
    do x = 1 to bufferWidth                         
      ls.y = ls.y||buffer.x.y                       
    end                                             
  end                                               
                                                    
  "execio * diskw graphout (Finis stem ls."         
  "free file(graphout)"                             
return                                              
