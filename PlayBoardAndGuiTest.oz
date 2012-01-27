% Displays a board that helps test the PlayBoard class

% Alter the Early List and recompile to start with different
% configurations of black and white stones.

% Left click on a stone to see about a second's worth of display of
% stones in its String and liberties surrounding the String.

% Right click on a stone to kill its String

% Left click on a vacant position to put a black stone there

% Right click on a vacant position to put a white stone there

% Click the generic button to retract a move.
 
functor
   import GuiBoard PlayBoard Browser
   %System Application JAZTools 

define

SBoard = PlayBoard.pBoard

%T = JAZTools
%Pr = {T.setWriter System.showInfo}

  Early =
   nil
%   [15#15#black 15#14#black 15#13#black 14#13#black 
%    13#15#black 13#14#black 15#13#black 14#15#black
%    14#14#white]

  LC = {NewCell LOne}
   
  proc {GButton}
    {SB retract} 
  end

  proc {LClicker R C}
     {@LC R C}
  end
	
  proc {LOne R C}
     Clr = {SB get(R C $)}
     Clstr = {SB cluster(R C $)}
  in 
     if Clr\=vacant then
        {GB showMarkers( Clstr.stones 1)}
        {GB showMarkers( Clstr.liberties 2)}
        {Delay 1500}
        {GB eraseMarkers(1)}
        {GB eraseMarkers(2)}
     else
        {SB play(R C black)}
     end
  end

  proc {LTwo R C}
     Clr = {SB get(R C $)}
     Clstr = {SB cluster(R C $)}
  in
     if Clr\=vacant then
        {GB showMarkers( Clstr.stones 1)}
        {GB showMarkers( Clstr.enemies 2)}
        {Delay 1500}
        {GB eraseMarkers(1)}
        {GB eraseMarkers(2)}
     else
        {SB play(R C black)}
     end
  end

  proc {RClicker R C}
%     Clr = {SB get(R C $)}
%     Clstr = {SB cluster(R C $)}
%  in
     {SB play(R C white)}
  end

  proc {PutAction R C Clr}
    {GB put(R C Clr)}
    {Browser.browse R#C#Clr}
  end

  GB = {New GuiBoard.gBoard init(_ 19 30.0 LClicker RClicker GButton)}
  SB = {New SBoard init(19 Early PutAction)}
   
  
end

