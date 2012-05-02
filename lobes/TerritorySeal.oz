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
		 OpCol = if Col==white then
		            black
				 else 
				    white
				 end
	  in
	     for Clu in CLst do
		    if Clu.color==Col then
			   %Walking through all of my clusters
		       for (R#C) in (Clu.border) do
			      Up = {Board getArctanTerr(R C+1 $)}
	              Left = {Board getArctanTerr(R+1 C $)}
                  Down = {Board getArctanTerr(R C-1 $)}
                  Right = {Board getArctanTerr(R-1 C $)}
			   in
			      %Walking through the border of my cluster
			      if (Up == OpCol) orelse (Left == OpCol) orelse (Right == OpCol) orelse (Down == OpCol) then
			         Temp := (R#C#Col)#1.0|@Temp
				  else if (Up == vacant) orelse (Left == vacant) orelse (Right == vacant) orelse (Down == vacant) then
				          Temp := (R#C#Col)#0.5|@Temp
					   end
				  end
			   end
			end
		 end
		 Lst = @Temp
      end
   end
end

