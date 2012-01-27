functor
   import EmptyBooleanLobe System ArctanInfl
   export IncreaseArcInfl
define
   class IncreaseArcInfl from EmptyBooleanLobe.booleanLobe
      attr RawInfl ArcTotal
      meth setGlobals(Board Col)
		 RawInfl := {ArctanInfl.findInverseInfl Board}
	     ArcTotal := {FoldR {ArctanInfl.arctanify Board @RawInfl} fun{$ (A#V1) V2} V1+V2 end 0.0}
	  end
	  
	  meth check(Board R C Col ?Result)
		 if {Board get(R C $)}==vacant then
		    NewRawInfl={List.map @RawInfl
			                        fun{$ (R1#C1#Color)#V}
									    if R1==R andthen C1==C then
										   (R1#C1#Color)#V
										elseif Col==black then
										   (R1#C1#Color)#(V+{Number.pow {ArctanInfl.distance R C R1 C1} ~2.0})
										else
										   (R1#C1#Color)#(V-{Number.pow {ArctanInfl.distance R C R1 C1} ~2.0})
										end
								    end}
		    NewArcInfl = {ArctanInfl.arctanify Board NewRawInfl}
			NewArcTotal = {FoldR NewArcInfl fun{$ (A#V1) V2} V1+V2 end 0.0}
		 in
		    Result = true#(0.6366*{Atan 0.01*{Abs (NewArcTotal-@ArcTotal)}})
	     else
		    Result = false#0.0
		 end
      end
   end
end