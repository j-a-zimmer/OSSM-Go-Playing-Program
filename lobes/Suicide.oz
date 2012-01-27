functor
   import EmptyBooleanLobe System Browser
   export Suicide
define
   Opposite = opposite(white:black black:white)

   fun {IsSuicide Board R C Col}
      Up = {Board cluster(R C+1 $)}
	  Left = {Board cluster(R+1 C $)}
      Down = {Board cluster(R C-1 $)}
      Right = {Board cluster(R-1 C $)}
   in
      (Up==nil orelse (Up.color == Opposite.Col) orelse (Up.color == Col andthen {Length Up.liberties}==1 ))
        andthen (Left==nil orelse (Left.color == Opposite.Col) orelse (Left.color == Col andthen {Length Left.liberties}==1 ))
        andthen (Down==nil orelse (Down.color == Opposite.Col) orelse (Down.color == Col andthen {Length Down.liberties}==1 ))
        andthen (Right==nil orelse (Right.color == Opposite.Col) orelse (Right.color == Col andthen {Length Right.liberties}==1 ))
   end
   
   class Suicide from EmptyBooleanLobe.booleanLobe
      meth check(Board R C Col ?Result)
         if {Board get(R C $)}==vacant andthen {IsSuicide Board R C Col} then
		    Result = true#~1.0
	     else 
		    Result = false#0.0
         end 
      end 
   end
end

