functor
   import EmptyBooleanLobe LobeTools Browser System
   export Fork
define
   Opposite = opposite(white:black black:white)

   class Fork from EmptyBooleanLobe.booleanLobe
      meth check(Board R C Col ?Result)
         if {Board get(R C $)}==vacant then
            Colors = {LobeTools.getColors Board R#C $}
            Enemy = Colors.(Opposite.(Col))
                       
            Helper = fun {$ BP}
               {List.length ({Board cluster(BP.1 BP.2 $)}.liberties)}==2
            end % fun Helper
         in
            if {And {List.length Enemy}<3 {List.length Enemy}>1} andthen {List.all Enemy Helper} then
               Result = true#1.0
			else
			   Result = false#0.0
            end
		 else
		    Result = false#0.0
         end
      end
   end
end