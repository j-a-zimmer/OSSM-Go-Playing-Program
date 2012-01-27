functor
   import EmptyLobe Browser
   export DiagonalDelay
define
   class DiagonalDelay from EmptyLobe.lobe
      meth formulateWeights(Board Col ?Lst)
         Temp = {NewCell nil}
         
         proc {ListHasCoords R C TLst ?DoesIt}
            case TLst
            of Head|Tail then
               case Head
               of (CR#CC#_)#_ then
                  if {And (CR == R) (CC == C)} then
                     DoesIt = true
                  else
                     {ListHasCoords R C Tail ?DoesIt}
                  end
               else
                  {ListHasCoords R C Tail ?DoesIt}
               end
            else 
               DoesIt = false
            end
         end
         
         proc {TempListToWeightList TLst WLst ?RLst}
            case TLst
            of Head|Tail then
               case Head
               of R#C then
                  if {Not {ListHasCoords R C WLst $}} then
                     {TempListToWeightList Tail ((R#C#Col)#~1.0)|WLst RLst}
                  else
                     {TempListToWeightList Tail WLst RLst}
                  end
               else
                  {TempListToWeightList Tail WLst RLst}
               end
            else
               RLst = WLst
            end
         end

         proc {Check R C}
            NRNC = {Board get(R-1 C-1 $)}
            NRC = {Board get(R-1 C $)}
            NRPC = {Board get(R-1 C+1 $)}
            
            RNC = {Board get(R C-1 $)}
            RPC = {Board get(R C+1 $)}
            
            PRNC = {Board get(R+1 C-1 $)}
            PRC = {Board get(R+1 C $)}
            PRPC = {Board get(R+1 C+1 $)}
          in
            % NRNC  NRC   NRPC
            % RNC   RC    RPC
            % PRNC  PRC   PRPC
            
            if (NRNC == Col) andthen {And (NRC == vacant) (RNC == vacant)} then
               Temp := ((R-1)#C)|@Temp
               Temp := (R#(C-1))|@Temp
            end
             
            if (NRPC == Col) andthen {And (NRC == vacant) (RPC == vacant)} then
               Temp := ((R-1)#C)|@Temp
               Temp := (R#(C+1))|@Temp
            end
            
            if (PRPC == Col) andthen {And (PRC == vacant) (RPC == vacant)} then
               Temp := ((R+1)#C)|@Temp
               Temp := (R#(C+1))|@Temp
            end
            
            if (PRNC == Col) andthen {And (PRC == vacant) (RNC == vacant)} then
               Temp := ((R+1)#C)|@Temp
               Temp := (R#(C-1))|@Temp
            end
         end
      in
         for R in 1..Board.playSize do
            for C in 1..Board.playSize do
               if {Board get(R C $)}==Col then
                  {Check  R C}
               end
            end
         end
	     {TempListToWeightList @Temp nil Lst}
      end

   end
end

