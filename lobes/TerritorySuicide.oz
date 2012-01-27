functor
   import EmptyLobe Territory Browser
   export TerritorySuicide
define
   class TerritorySuicide from EmptyLobe.lobe
      meth formulateWeights(Board Col ?Lst)
         TerritoryL = {Territory.findTerritory Board $}
         Clusters = {Board getClusters($ [white black])}
         
         proc {ProcessTerritoryList TerritoryList TempList ?RList}
            case TerritoryList
            of Stone|Tail then
               {ProcessTerritoryList Tail (Stone#~1.0)|TempList RList}
            else
               RList = TempList
            end
         end
      in
         if ({List.length Clusters} < 2) then 
            Lst = nil
         else
            {ProcessTerritoryList TerritoryL.2 {ProcessTerritoryList TerritoryL.1 nil $} Lst}
	     end
      end
   end
end

