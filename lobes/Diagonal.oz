functor
   import EmptyLobe
   export Diagonal
define
   class Diagonal from EmptyLobe.lobe
      %This lobe encourages the making of diagnol connections if both of the
      % "crossing spaces" are vacant.
      % "Crossing spaces" are X's in:     X  B       B  X      W  X      X  W
      %                                   B  X   or  X  B  or  X  W  or  W  X
      meth formulateWeights(Board Col Lst)
         Temp = {NewCell nil}
         fun{AllVacant (R1#C1) (R2#C2) (R3#C3)}
            {Board get(R1 C1 $)}==vacant andthen {Board get(R2 C2 $)}==vacant andthen {Board get(R3 C3 $)}==vacant
         end
         proc{AddList R C V}
            if V==0.0 then
      	       skip
            else
               Temp:=(R#C#Col)#V|@Temp
            end
         end
         fun{Contains Lst R C}
            case Lst
            of (R1#C1#_)#_ |Tail then
               (R==R1 andthen C==C1) orelse {Contains Tail R C}
            else
               false
            end
         end
      in
         for R in 1..Board.playSize do
            for C in 1..Board.playSize do
               if {Board get(R C $)}==Col then  
                  if {AllVacant (R+1#C+1) (R+1#C) (R#C+1)} andthen
                       {Not {Contains @Temp R+1 C+1}} then
                     {AddList R+1 C+1 0.25}
                  end
                  if {AllVacant (R-1#C+1) (R-1#C) (R#C+1)} andthen
                       {Not {Contains @Temp R-1 C+1}} then
                     {AddList R-1 C+1 0.25}
                  end
                  if {AllVacant (R+1#C-1) (R+1#C) (R#C-1)} andthen
                       {Not {Contains @Temp R+1 C-1}} then
                     {AddList R+1 C-1 0.25}
                  end
                  if {AllVacant (R-1#C-1) (R-1#C) (R#C-1)} andthen
                       {Not {Contains @Temp R-1 C-1}} then
                     {AddList R-1 C-1 0.25}
                  end
               end
            end
         end
         Lst = @Temp
      end
   end
end

