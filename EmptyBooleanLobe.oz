functor
   import Browser EmptyLobe System
   export BooleanLobe
define
   
class BooleanLobe from EmptyLobe.lobe
   % This class is ment to be extaneded by lobes that check every location individually.
   % This will set any Global variables needed, then recursively walk the board applying
   %   the check method, and adding the location to it its result list with the value
   %   in check's result.
   
   meth check(Board R C Col ?Result)
      % This method will be apllied on every combination of R and C
	  % It returns a tuple with (Boolean)#(Float)
	  % If the boolean is true then the location is rated with the Float
      Result = false#0.0
   end
   
   meth setGlobals(Board Col)
      %Can be used to set global variables before any locations are checked
      skip
   end
   
   meth formulateWeights(Board Col ?R)
	  fun{Recurs Board R C Col}
	     Result = {self check(Board R C Col $)}
	  in
	     if Result.1 andthen Result.2\=0.0 then
	        if R=={Board size($)} then
               if C=={Board size($)} then
			      (R#C#Col)#Result.2|nil
			   else
			      (R#C#Col)#Result.2|{Recurs Board 1 C+1 Col}
			   end
			else
	           (R#C#Col)#Result.2|{Recurs Board R+1 C Col}
		    end
		 else
			if R=={Board size($)} then
			   if C=={Board size($)} then
			      nil
		       else
		          {Recurs Board 1 C+1 Col}
			   end
			else
			   {Recurs Board R+1 C Col}
		    end
	     end
	  end
   in 
      {self setGlobals(Board Col)}
      R = {Recurs Board 1 1 Col}
   end
end

end