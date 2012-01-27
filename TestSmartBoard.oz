functor
  import SmartBoard Application JAZTools
  %System

define

% some aliases
   SBoard = SmartBoard.sBoard 
   %ShowStones = SmartBoard.showStones 
   T = JAZTools 
   %Pr = {T.setWriter System.showInfo} 
   Assert = T.assert  %  {Assert Msg What} writes Msg and stops a program i
                      %  if What is not true
   EqualLists = T.equalLists 

% create a 9x9 empty board with no external put action
   SB = {New SBoard init(9 nil)} 
 
% defined below
  Liberties 
  C D 
  After_Retract_Stones After_Retract_Liberties After_Retract_Enemies 

in 

% play this pattern
% * * * * * * * * *
% * * * w w * * * *    
% * * b b w * * * *
% * * w * b * * * *
% * * * * * * * * *
% * * * * * * * * *
% * * * * * * * * *
% * * * * * * * * *
% * * * * * * * * *
   {SB play(3 3 black)} 
   {SB play(3 4 black)} 
   {SB play(4 5 black)} 
   {SB play(2 4 white)} 
   {SB play(2 5 white)} 
   {SB play(3 5 white)} 
   {SB play(4 3 white)} 

% fill in the 4#4 position with black to connect her stones
   {SB play(4 4 black)}

% get black's cluster two ways and see if they are same stones 
   C = {SB cluster(3 3 $)}.stones 
   D = {SB cluster(4 4 $)}.stones 
   {Assert {EqualLists C D}  
           'stones are not same in cluster'} 

% black's liberties should be
% * * * * * * * * *
% * * L w w * * * *    
% * L b b w * * * *
% * * w b b L * * *
% * * * L L * * * *
% * * * * * * * * *
% * * * * * * * * *
% * * * * * * * * *
% * * * * * * * * *
   Liberties = [3#2#vacant 2#3#vacant 5#4#vacant 5#5#vacant 4#6#vacant] 
   {Assert {EqualLists {SB cluster( 3 3 $)}.liberties Liberties} 
           'wrong liberties'}         

% after a retraction 
%    black's stones B from 3#3 should be
%    black's liberties L for this cluster should be
%    black's enemies W for this cluster should be
% * * * * * * * * *
% * * L W w * * * *    
% * L B B W * * * *
% * * W L b * * * *
% * * * * * * * * *
% * * * * * * * * *
% * * * * * * * * *
% * * * * * * * * *
% * * * * * * * * *
   After_Retract_Stones = [3#3#black 3#4#black] 
   After_Retract_Liberties = [2#3#vacant 3#2#vacant 4#4#vacant] 
   After_Retract_Enemies = [2#4#white 3#5#white 4#3#white] 
   {SB retract}
   {Assert {EqualLists 
               {SB cluster(3 3 $)}.stones 
               After_Retract_Stones} 
            'stones after retract are wrong'} 
   {Assert {EqualLists 
               {SB cluster(3 3 $)}.liberties 
               After_Retract_Liberties} 
            'liberties after retract are wrong'}
   {Assert {EqualLists 
               {SB cluster(3 3 $)}.enemies 
               After_Retract_Enemies} 
            'enemies after retract are wrong'}

% That's All Folks
   {Application.exit 0} 

end
