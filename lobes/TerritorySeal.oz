functor
   import EmptyLobe System ArctanInfl Browser
   export TerritorySeal
define
   Opposite = opposite(white:black black:white)
   
   class TerritorySeal from EmptyLobe.lobe  
	  % This lobe has a similar idea behind it as BorderSeal. It aims
	  %  to help close off your territory when an enemy is threatening it.
	  % However, unlike BorderSeal, this lobe focuses on the use of Pseudo
	  %  Territories to find its border and identify threats.
	  
      meth formulateWeights(Board Col ?Lst)
	     Temp = {NewCell nil}
         CLst = {Board getArctanTerrClusters($)}
		 OpColNum = if Col==white then
		               1
					else 
					   ~1
					end
	  in
	     for Clu in CLst do
		    if Clu.color==Col then
			   %Walking through all of my clusters
		       for (R#C) in (Clu.border) do
			      %Walking through the border of my cluster
			   
			      NearbySpaces = {Board getManhattan(R#C 5 $)} 
				  AdjSpaces = {Board getManhattan(R#C 1 $)}
			   in
			      if  %Requires it to have some enemy influence nearby
					  {List.some NearbySpaces 
			                    fun{$ R1#C1} 
								   {Board getArctanTerr(R1 C1 $)}==OpColNum
								end } then
					 {Browser.browse territoryseal#R#C}
			         Temp := (R#C#Col)#1.0|@Temp
				  end
			   end
			end
		 end
		 Lst = @Temp
      end
   end
end

