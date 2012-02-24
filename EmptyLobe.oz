functor
   import Browser
   export Lobe
define
   class Lobe
	  feat lookAhead: fun{$ R C Col Board Fun}
	                     Retval
	                  in
	                     {Board play(R C Col)}
		                 Retval = {Fun R C Col Board}
						 {Board retractMove}
						 Retval
	                  end      
      meth init()
	     skip
      end
      meth formulateWeights(Board Col ?R)
         R = nil
      end
   end
end