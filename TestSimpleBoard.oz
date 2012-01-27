functor 
   import SimpleBoard JAZTools System Application
  
define

Board = SimpleBoard.board
Z = JAZTools
Pr = {Z.setWriter System.showInfo}

proc {Assert Board Msg R C Clr}
  %  fetch "stone" at R#C position
  %  raise hell and print message if its color is not CLr
  if {Board get(R C $)}\=Clr then
    {Pr {VirtualString.toAtom Msg#', expecting '#Clr}}
    {Raise hell}
  end
end

proc {Test}
   
   % some declarations to test whether the external put action
   % is being called with the right values
      
      ExternallySet = {NewCell _}
      proc {ExternalAction R C V}
          ExternallySet:= R#C#V
      end
   
   % create 4x4 board with one stone which is black and at 2#2 position
   % (1st int is row, 2nd is col -- counting from 1, but not % borders)
   % while creating,  install the above declared external put action
       B = {New Board init(4 [2#2#black] ExternalAction) }

   % create 19x19 board with no stones 
   % and no external put action
       B2 = {New Board init(19 nil _)}
   
   % to check getSameColorList
       Lst Lst2
   
in  

   % check whether B board has just the one black stone at 2#2
      {Assert B 'Test, part A @ 1 1' 1 1 vacant}
      {Assert B 'Test, part A @ 2 2' 2 2 black}
      {Assert B 'Test, part A @ 1 2' 1 2 vacant}
      {Assert B 'Test, part A @ 2 1' 2 1 vacant}
      {Assert B 'Test, part A @ 2 3' 2 3 vacant}

   % create this stone pattern
   %     * w * *
   %     * w b *
   %     * * * *
   %     * * * *
   % wiping out the previous black at 2#2
      {B put(2 3 black)}
      {B put(2 2 white)}
      {B put(1 2 white)}

   % check whether pattern is that just created
      {Assert B 'Test, part B @ 1 2' 1 2 white}
      {Assert B 'Test, part B @ 2 1' 2 1 vacant}
      {Assert B 'Test, part B @ 2 2' 2 2 white}
      {Assert B 'Test, part B @ 2 3' 2 3 black}

   % does getSameColorList find all white stones from 2#2 position?
      Lst = {Z.listToAtom {B getSameColorList(2 2 $)}}
      if Lst\='12,22' then {Z.abort 'list test failed'} end

   % can we retract a move? 
      {B retract}
      {Assert B 'Test, part C @ 1 2' 1 2 vacant}
      {Assert B 'Test, part C @ 2 2' 2 2 white}
      {Assert B 'Test, part C @ 2 1' 2 3 black}
   
   % retract a 2nd time
      {B retract}
      {Assert B 'Test, D @ 2 2' 2 2 black}
      {Assert B 'Test, D @ 2 3' 2 3 black}
   
   % does put handle vacant "stones"?
      {B put(2 3 vacant)}
      {Assert B 'Test, E @ 2 3' 2 3 vacant}
   
   % check if ExternalPutAction was properly called with last put
      local 
          R#C#V = @ExternallySet
      in
          if R\=2 orelse C\=3 orelse V\=vacant then
             {Raise 'external action failed test'}
          end
      end
   
   % clear B
      {B reset(_)}
   
   % getSameColorList should return all the vacant positions
      Lst2 = {B2 getSameColorList(1 1 $)}
      if {List.length Lst2}\=361 then 
         {Z.abort '2nd list test failed'} 
      end
   % That's All Folks!
      {Application.exit 0 }

end % Test

{Test}


end

             
