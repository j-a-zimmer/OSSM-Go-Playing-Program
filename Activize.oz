functor
   
export Portal

define
   fun {Portal C}
      class $
         feat obj entry list
         
         meth init(...)=I
            self.obj = {New C I}
            {NewPort self.list self.entry}

            proc {Process L}
               H|T = L
            in
               {self.obj H}
               {Process T}
	    end

	 in

            thread {Process self.list} end
         end

         meth otherwise(A)
            {Send self.entry A}
         end
      end
   end
end
		
