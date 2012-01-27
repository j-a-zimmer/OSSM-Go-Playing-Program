functor
  import SmartBoard JAZTools 
  %System
define

   T = JAZTools

%   Pr = {T.setWriter System.showInfo}
   Assert = T.assert

   B1 = [ [&W &W &B & ]
          [&B &B &  &B]
          [&W &W &B & ]
          [&  &  &  & ] ]
   
   B2 = {T.bList2VList {T.vList2BList B1}}

   Board = {New SmartBoard.sBoard init(4 {T.vList2BList B1})}

   B3 = {T.board2VList Board}

in

   {Assert {T.equalListsD B1 B2} 'simple conversion failed'}
    
   {Assert {T.equalListsD B1 B3} 'conversion through board history failed'}

   {T.stop 0}

end

