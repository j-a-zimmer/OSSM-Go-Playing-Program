functor
   import EmptyBooleanLobe System
   export BorderSeal
define
   Opposite = opposite(white:black black:white)
     
   fun{AdjFriendlyInfl AdjInfl Board Col}
      {List.some AdjInfl fun{$ C#W} C==Col end}
   end
   fun{AdjEnemyInfl AdjInfl Board Col}
      {List.some AdjInfl fun{$ C#W} C==Opposite.(Col) end}
   end
   fun{AdjEnemyPiece AdjSpaces Board Col}
      {List.some AdjSpaces fun{$ R#C} {Board get(R C $)}==Opposite.(Col) end}
   end
   fun{NearbyFriendlyPiece NearbySpaces Board Col}
      {List.some NearbySpaces fun{$ R#C} {Board get(R C $)}==Col end}
   end 
	 
   class BorderSeal from EmptyBooleanLobe.booleanLobe
      %This lobe rates locations along the border of your pieces. It does this
      % with 5 different cases.
      feat V1 V2 V3 V4 V5
      meth init()
	     self.V1 = 0.0 %These variables are for each of the 5 cases.
 	     self.V2 = 0.5
         self.V3 = 1.0
         self.V4 = 0.0
         self.V5 = 1.0
      end
      
      meth check(Board R C Col ?Result)
         AdjInfl = [ {Board getInfluence(R (C-1) $)}
                     {Board getInfluence(R (C+1) $)}
                     {Board getInfluence((R-1) C $)}
                     {Board getInfluence((R+1) C $)} ]
       
         AdjSpaces = {Board getManhattan(R#C 1 $)} 
         NearbySpaces = {Board getManhattan(R#C 2 $)} 
      in 
	     Result = 
		    if {Board get(R C $)}==vacant then
               if {Not {AdjFriendlyInfl AdjInfl Board Col}} then
                  true#self.V1
               elseif {Not {AdjEnemyInfl AdjInfl Board Col}} then
                  true#self.V2
               elseif {Not {AdjEnemyPiece AdjSpaces Board Col}} then
                  true#self.V3
               elseif {Not {NearbyFriendlyPiece NearbySpaces Board Col}} then
                  true#self.V4
               else
                  true#self.V5
               end
			else
			   false#0.0
            end
      end
   end
end

