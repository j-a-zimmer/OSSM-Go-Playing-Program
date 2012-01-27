functor
   import EmptyBooleanLobe LobeTools System ClusterTools Browser
   export LibertyIncrease
define
   Opposite = opposite(white:black black:white)

   fun {NoLibertyIncrease Board R C Col}
      Colors = {LobeTools.getColors Board R#C $}
      Cluster PlayWithBoard Cluster2
   in
      case Colors.(Col) of (Rstone#Cstone#_)|_ then
         Cluster = {Board cluster(Rstone Cstone $)}
         if {List.length Cluster.liberties} < 6 then 
            PlayWithBoard = {Board cloneBoard($)}
            {PlayWithBoard play(R C Col _)}
            Cluster2 = {PlayWithBoard cluster(R C $)}
            if (Cluster2.color == vacant) then 
			   false
            else
               {List.length Cluster.liberties} > {List.length Cluster2.liberties} 
            end
         else false
         end
      else
         false
      end
   end
   
   class LibertyIncrease from EmptyBooleanLobe.booleanLobe
      meth check(Board R C Col ?Result)
         if {Board get(R C $)}==vacant andthen {NoLibertyIncrease Board R C Col} then
            Result = true#~1.0
         else
		    Result = false#0.0
		 end
      end
   end
end
