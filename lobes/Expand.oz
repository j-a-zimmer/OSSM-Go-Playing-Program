functor
   import EmptyLobe Browser System
   export Expand
define
   class Expand from EmptyLobe.lobe
      % Expand gives higher weights to positions with zero influence that have
      % stones nearby
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

         % Whether list of R#C's contains a stone
         fun{HasStone ListIn}
            case ListIn of (R#C)|T then
               if {Or {Board get(R C $)}==black
                      {Board get(R C $)}==white }
                  then true
               else {HasStone T} end
            else
               false
            end
         end


         % Returns list of R#C's with zero influence that have no
         % stones nearby
         fun{NoStones ZeroList}
            case ZeroList of (R#C)|T then
               if {HasStone
                      {Board getManhattan(R#C 3 $)}
                  }
               then {NoStones T}
               else (R#C)|{NoStones T}
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
	     {System.show {Board getInfluence(4 4 $)}}
	     Lst = {Glue {NoStones {GetZeroInfl $}}}
      end

   end
end
