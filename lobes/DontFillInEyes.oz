functor
   import EmptyBooleanLobe System ClusterTools Browser
   export DontFillInEyes
define
   class DontFillInEyes from EmptyBooleanLobe.booleanLobe
      meth check(Board R C Col ?Result)
         if {Board get(R C $)}==vacant andthen {ClusterTools.isEye Board R#C Col $} then
            Result = true#~1.0
         else
		    Result = false#0.0
         end          
      end 
   end
end
