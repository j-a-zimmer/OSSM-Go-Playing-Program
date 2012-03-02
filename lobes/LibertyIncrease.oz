functor
   import EmptyBooleanLobe LobeTools System ClusterTools Browser
   export LibertyIncrease
define
   Opposite = opposite(white:black black:white)
   
   class LibertyIncrease from EmptyBooleanLobe.booleanLobe
      meth check(Board R C Col ?Result)
	     fun {NoLibertyIncrease Board R C Col}
            Colors = {LobeTools.getColors Board R#C $}
            Cluster
         in
            case Colors.(Col) of (Rstone#Cstone#_)|_ then
               Cluster = {Board cluster(Rstone Cstone $)}
               if {List.length Cluster.liberties} < 6 then
			   
		          fun{LibDecrease R C Col Board}
			         Cluster2 = {Board cluster(R C $)}
				  in
                     if (Cluster2.color == vacant) then 
			            false
                     else
                        {List.length Cluster.liberties} > {List.length Cluster2.liberties} 
                     end
			      end
				  
		       in
                  {self lookAhead(R C LibDecrease $)}
               else false
               end
            else
               false
            end
         end
	  in
         if {Board get(R C $)}==vacant andthen {NoLibertyIncrease Board R C Col} then
            Result = true#~1.0
         else
		    Result = false#0.0
		 end
      end
   end
end
