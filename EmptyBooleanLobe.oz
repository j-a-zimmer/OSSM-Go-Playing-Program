functor
   import Browser EmptyLobe System
   export BooleanLobe
define
   
class BooleanLobe from EmptyLobe.lobe
   meth check(Board R C Col ?Result)
      % This method will be apllied on every combination of R and C
	  % It returns a tuple with (Boolean)#(Float)
	  % If the boolean is true hen the location is rated with the Float
      Result = false#0.0
   end
   
   meth setGlobals
      %Can be used to set global variables before any locations are checked
      skip
   end

   meth formulateWeights
	  fun{Recurs R C}
	     Result = {self check(@(self.board) R C @(self.col) $)}
		 Size = {@(self.board) size($)}
		 Col = @(self.col)
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
      {self setGlobals()}
      (self.values) := {Recurs 1 1}
   end
end

end