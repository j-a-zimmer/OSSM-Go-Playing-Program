functor
   import System
   export FindInfl FindInverseInfl Arctanify Distance GetLine
define
   fun{GetLine R C Size}
      fun{Minimum A B} if A>B then B else A end end
   in
      {Minimum {Minimum R C} {Minimum Size-R+1 Size-C+1}}
   end
   fun{FindInverseInfl Board}
      fun{SumAll R C}
	     if R == {Board size($)} then
		    if C == {Board size($)} then
			   ((R#C#useless)#{SumAt R C 1 1 0.0})|nil
			else
			   ((R#C#useless)#{SumAt R C 1 1 0.0})|{SumAll 1 C+1}
			end
	     else
		    ((R#C#useless)#{SumAt R C 1 1 0.0})|{SumAll R+1 C}
		 end
	  end
	  fun{SumAt R1 C1 R2 C2 RunningTotal}
	     NewTotal = if R1==R2 andthen C1==C2 then
		                     RunningTotal
  		                  elseif {Board get(R2 C2 $)}==black then
   	                         RunningTotal+{Number.pow {Distance R1 C1 R2 C2} ~1.5}
						  elseif {Board get(R2 C2 $)}==white then
			                 RunningTotal-{Number.pow {Distance R1 C1 R2 C2} ~1.5}
						  else 
						     RunningTotal
						  end
	  in
	     if R2 == {Board size($)} then
		    if C2 == {Board size($)} then
			   NewTotal
			else
			   {SumAt R1 C1 1 C2+1 NewTotal}
			end
	     else
		    {SumAt R1 C1 R2+1 C2 NewTotal}
		 end
	  end
   in
	  {SumAll 1 1}
   end
   
   fun{FindInfl Board}
      {Arctanify Board {FindInverseInfl Board}}
   end
   
   fun{Distance X1 Y1 X2 Y2}
	     {Sqrt ({IntToFloat (X1-X2)*(X1-X2)} + {IntToFloat (Y1-Y2)*(Y1-Y2)})}
   end
   
   fun{Arctanify Board Lst}
      {List.map Lst
	       fun{$ (R#C#Col)#Val}
		      (R#C#Col)#0.6366*{Atan Val*4.0 / {Number.pow {IntToFloat {GetLine R C {Board size($)}}}0.5}}
		   end }
   end
end