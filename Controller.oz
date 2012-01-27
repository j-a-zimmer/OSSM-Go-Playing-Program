functor

import PlayBoard

export Run

define
   
   proc {Run Player1Type Player2Type Size Handicap}
      Player1   
      Player2
      Players = op(1:Player1 0:Player2)
   
      Board = {New PlayBoard.pBoard init(Size Handicap _)}
   
      proc {Recurs P M}
         Move = {Players.P decide(M $)}
      in
         case Move of pass
         then
            skip
         else
            {Board play(Move.1 Move.2 Move.3)}
         end
         {Recurs ((P+1) mod 2) Move}
      end  
   in
      Player1 = {New Player1Type init({Board cloneBoard($)} black)}
      Player2 = {New Player2Type init({Board cloneBoard($)} white)}
      {Recurs 1 pass}
   end
end
