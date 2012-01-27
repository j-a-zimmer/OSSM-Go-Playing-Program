functor
   import EmptyLobe LobeTools Browser
   export Field
define
   Opposite = opposite(white:black black:white)

   class Field from EmptyLobe.lobe
      meth formulateWeights(Board Col ?Lst)
         
         local PointField Temp

         in
        
            PointField = fun {$ R C FieldFunc}
               Weight = {NewCell 0.0}
            in % fun PointField
               for Row in 1..Board.playSize do
                  for Coll in 1..Board.playSize do
                     if {Board get(Row Coll $)}==Opposite.(Col) then
                        Weight := @Weight + {FieldFunc R#C Row#Coll} * 0.5
                     end
                  end
               end
               
               @Weight
            end % fun PointField
            
            Temp = {NewCell nil}
            for R in 1..Board.playSize do
               for C in 1..Board.playSize do
                  if {Board get(R C $)}==vacant then
                     PF = {PointField R C LobeTools.inverseSquare}
                  in
                     if PF<1.5 then
                        Temp := ((R#C#Col)#(PF/1.5))|@Temp
                     end
                  end
               end
            end
	        Lst = @Temp
         end        
      end
   end
end

