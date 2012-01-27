functor
   import EmptyBooleanLobe ClusterTools SimpleBoard Browser
   export LibertyCheck
define
   Opposite = opposite(white:black black:white)

   fun{Atari Board R C Col}
      Cup = {Board cluster(R C+1 $)}
	  Cleft = {Board cluster(R+1 C $)}
      Cdown = {Board cluster(R C-1 $)}
      Cright = {Board cluster(R-1 C $)}
      Up = Cup == nil orelse Cup.color == Opposite.Col orelse (Cup.color == Col andthen Cup.liberties==1)
	  Left = Cleft == nil orelse Cleft.color == Opposite.Col orelse (Cleft.color == Col andthen Cleft.liberties==1) 
      Down = Cdown == nil orelse Cdown.color == Opposite.Col orelse (Cdown.color == Col andthen Cdown.liberties==1)
      Right = Cright == nil orelse Cright.color == Opposite.Col orelse (Cright.color == Col andthen Cright.liberties==1)
   in
	 (Up andthen Left andthen Down)
        orelse (Up andthen Down andthen Right)
        orelse (Up andthen Left andthen Right)
        orelse (Left andthen Down andthen Right)
   end
   
   class LibertyCheck from EmptyBooleanLobe.booleanLobe      
      meth check(Board R C Col ?Result)
         if {Atari Board R C Col} then
            Result = true#~1.0
	     else
		    Result = false#0.0
         end
      end
   end
end

