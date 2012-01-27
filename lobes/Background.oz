functor
   import EmptyBooleanLobe LobeTools
   export Background
define
   class Background from EmptyBooleanLobe.booleanLobe
      %This lobe will rate locations based on which row of the board they are on.
      %Your Row# is the shortest Manhattan distance to any wall.
      %Currently wieghts rows 0-3 and then puts all others together.
	  
     feat Row0 Row1 Row2 Row3 RowOther
     meth init()
	    self.Row0 =~0.6
        self.Row1 =~0.3
        self.Row2 = 1.0
        self.Row3 = 0.7
        self.RowOther = 0.0
     end
      
     meth check(Board R C Col ?Result)
        Temp = {NewCell nil}
     in   
        Result = 
		   if {Board get(R C $)}==vacant then
              if {LobeTools.onLine Board.playSize 3 R C} then
                 true#self.Row3
              elseif {LobeTools.onLine Board.playSize 2 R C} then
                 true#self.Row2
              elseif {LobeTools.onLine Board.playSize 1 R C} then
                 true#self.Row1
              elseif {LobeTools.onLine Board.playSize 0 R C} then
                 true#self.Row0
              else
                 false#0.0
              end
           else
              false#0.0
           end		
     end
   end
end