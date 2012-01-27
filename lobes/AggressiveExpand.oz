functor
   import EmptyLobe Browser
   export AggressiveExpand
define
   Opposite = opposite(white:black black:white)

   class AggressiveExpand from EmptyLobe.lobe
      % AggressiveExpand gives higher weights to positions with zero
      % influence that have enemy stones nearby
      meth formulateWeights(Board Col ?Lst) 
	  
         % Returns positions on the board that have zero influence
         proc{GetZeroInfl ?Lst}
            fun{Recurs R C LstBuild}
               if R>=Board.playSize-1 then
                  if C>=Board.playSize-1 then
                     LstBuild
                  else
                     if {Board getInfluence(R C $)}.2==0.0 then
                        {Recurs 2 C+1 (R#C)|LstBuild}
                     else
                        {Recurs 2 C+1 LstBuild}
                     end
                  end
               else
                  if {Board getInfluence(R C $)}.2==0.0 then
                     {Recurs R+1 C (R#C)|LstBuild}
                  else
                     {Recurs R+1 C LstBuild}
                  end
               end
            end
         in
            Lst={Recurs 2 2 nil}
         end
         
         % Whether list of R#C's contains a stone of the opposite color
         fun{HasOppClr ListIn}
            case ListIn of (R#C)|T then
               if {Board get(R C $)}==Opposite.Col then true
               else {HasOppClr T} end
            else
               false
            end
         end

         % Returns list of R#C's with zero influence that have enemies
         fun{YesEnemies ZeroList}
            case ZeroList of (R#C)|T then
               if {HasOppClr 
                     {Board getManhattan((R#C) 2 $)}
                  }
               then (R#C)|{YesEnemies T}
               else {YesEnemies T}
               end
            else
               nil
            end
         end
         
         % Glues list of not-influenced positions not near enemies with
         % its weight.
         fun{Glue ListIn}
            case ListIn of (R#C)|T
            then (R#C#Col)#1.0|{Glue T}
            else
               nil
            end
         end
      in
	     Lst = {Glue {YesEnemies {GetZeroInfl $}}}
      end

   end
end

