% Displays a board that helps test the SmartBoard class

% Alter the Early List and recompile to start with different
% configurations of black and white stones.

% Left click on a stone to see about a second's worth of display of
% stones in its String and liberties surrounding the String.

% Right click on a stone to kill its String

% Left click on a vacant position to put a black stone there

% Right click on a vacant position to put a white stone there

% Click the generic button to retract a move.
 
functor
  import GuiBoard SmartBoard 
  %System JAZTools
define

SBoard = SmartBoard.sBoard
%ShowStones = SmartBoard.showStones
%T = JAZTools
%Pr = {T.setWriter System.showInfo}

Early = [15#15#black 15#14#black 15#13#black 14#13#black 
         13#15#black 13#14#black 15#13#black 14#15#black
         14#14#white]

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
     Stones Liberties
     StonesTag LibertiesTag
  in 

     if Clr\=vacant then
        Stones = {List.map Clstr.stones fun {$ X} X#red end}
        Liberties = {List.map Clstr.liberties fun {$ X} X#blue end}
        StonesTag = {GB addMarks(Stones $) }
        LibertiesTag = {GB addMarks(Liberties $) } 
        {Delay 1500}
        {GB clearMarks(StonesTag)}
        {GB clearMarks(LibertiesTag)}
     else
        {SB play(R C black)}
     end
  end

  proc {LTwo R C}
     Clr = {SB get(R C $)}
     Clstr = {SB cluster(R C $)}
     Stones Enemies
     StonesTag EnemiesTag
  in
     if Clr\=vacant then
        Stones = {List.map Clstr.stones fun {$ X} X#red end}
        Enemies = {List.map Clstr.liberties fun {$ X} X#blue end}
        StonesTag = {GB addMarks(Stones $) }
        EnemiesTag = {GB addMarks(Enemies $) } 
        {Delay 1500}
        {GB clearMarks(StonesTag)}
        {GB clearMarks(EnemiesTag)}
     else
        {SB play(R C black)}
     end
  end

  proc {RClicker R C}
     Clr = {SB get(R C $)}
     Clstr = {SB cluster(R C $)}
  in
     if Clr\=vacant then
        {SB kill( Clstr.stones)}
     else
        {SB play(R C white)}
     end
  end

  proc {PutAction R C Clr}
    {GB put(R C Clr)}
  end

  GB = {New GuiBoard.gBoard init(19 30.0 LClicker RClicker GButton)}
  SB = {New SBoard init(19 Early PutAction)}

end

