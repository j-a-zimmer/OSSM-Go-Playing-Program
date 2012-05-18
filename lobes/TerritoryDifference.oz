functor
   import EmptyBooleanLobe System ArctanInfl Browser
   export TerritoryDifference
define
   
   class TerritoryDifference from EmptyBooleanLobe.booleanLobe  
	  % This lobe has a similar idea behind it as BorderSeal. It aims
	  %  to help close off your territory when an enemy is threatening it.
	  % However, unlike BorderSeal, this lobe focuses on the use of Pseudo
	  %  Territories to find its border and identify threats.
	  
      meth check(Board R C Col ?Result)
         if (({Board getManhatTerr(R C $)}==Col) orelse ({Board getArctanTerr(R C $)}==Col))
 		      andthen {Not (({Board getManhatTerr(R C $)}==Col) andthen 
			                ({Board getArctanTerr(R C $)}==Col))} then
		    Result = true#1.0
		 else
		    Result = false#0.0
		 end
      end
   end
end

