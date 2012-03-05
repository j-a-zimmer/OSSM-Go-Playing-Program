functor
   import Browser EmptyLobe System
   export BooleanLobe
define
   
class BooleanLobe from EmptyLobe.lobe

   % The purpose of this class is to offer a nice semi-written lobe that can be extended
   %   by lobes that follow the general outline:
   %
   %      for R#C in all board positions do
   %          if A then
   %             Values := (R#C#Col)#SomeNumber | (@Values)
   %          else
   %             skip
   %          end
   %     end
   %        In english, this lobe should be extended by any subclass that just walks the
   %           entire board and checks each location seperately coming up a value or nothing
   %           at each loacation.
   %
   % It works similarly to the outline above but goes recursively (i.e. more efficiently) and 
   %   uses no state or cells (Hooray)
   %
   % This lobe should be extended in up to two ways:
   %    check  -- this method is applied on every location an returns whether or not it has a
   %              value and what it is
   %    setGlobals  -- this method is called before the lobe will check any where and gives the
   %                   subclass a chance to set any global values it cares about and doesn't 
   %                   want to recalculate
   
   meth check(Board R C Col ?Result)
      % This method will be apllied on every combination of R and C
	  % It returns a tuple with (Boolean)#(Float)
	  % If the boolean is true hen the location is rated with the Float
      Result = false#0.0
   end
   
   meth setGlobals(Board Col)
      %Can be used to set global variables before any locations are checked
      skip
   end

   meth fillValues
      Board = {self getBoard($)}
	  Col = {self getCol($)}
	  fun{Recurs R C}
	     Result = {self check(Board R C Col $)}
		 Size = {Board size($)}
	  in
	     if Result.1 andthen Result.2\=0.0 then
	        if R==Size then
               if C==Size then
			      (R#C#Col)#Result.2|nil
			   else
			      (R#C#Col)#Result.2|{Recurs 1 C+1}
			   end
			else
	           (R#C#Col)#Result.2|{Recurs R+1 C}
		    end
		 else
			if R==Size then
			   if C==Size then
			      nil
		       else
		          {Recurs 1 C+1}
			   end
			else
			   {Recurs R+1 C}
		    end
	     end
	  end
   in 
      {self setGlobals(Board Col)}
      {self setValues( {Recurs 1 1} ) }
   end
end

end