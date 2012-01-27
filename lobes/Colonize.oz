functor
   import EmptyBooleanLobe ArctanInfl System
   export Colonize
define

   fun{DistanceToNearestStone Board R C}
      Ans={NewCell 100.0}
   in
      for R1 in 1..{Board size($)} do
	     for C1 in 1..{Board size($)} do
		    if {Board get(R1 C1 $)}\=vacant 
				  andthen (R1\=R orelse C1\=C) 
		 		  andthen {ArctanInfl.distance R C R1 C1}<@Ans then
		       Ans:={ArctanInfl.distance R C R1 C1}
	        end
	     end
	  end
 	  @Ans
   end  
	  
   class Colonize from EmptyBooleanLobe.booleanLobe
      meth check(Board R C Col ?Result)
         Dist = {DistanceToNearestStone Board R C}
	  in
		 if Dist>5.0 then
		    Result = true#0.6366*{Atan 0.1*Dist}
	     else
		    Result = false#0.0
		 end
	  end
   end  
end