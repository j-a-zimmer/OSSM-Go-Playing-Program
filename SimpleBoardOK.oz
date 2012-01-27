functor
   
   import Browser System JAZTools
   export Board

define

Pr = {JAZTools.setWriter System.showInfo}

class Board 
   feat size board weights playSize
   attr History ExternalShow ExternalPutAction
   %% History List is stored as Row#Col#NewClr#OldClr

   meth init(Size InitialStones PutAction<=_ )
         proc {PutBorders}

            proc {Pc R C} 
               {Array.put self.board (R*self.size+C) border}
            end 

            L = self.size-1

         in % PutBorders
           {For 0 L 1  proc {$ I} {Pc I 0} {Pc I L} end}
           {For 1 (L-1) 1 proc {$ I} {Pc 0 I} {Pc L I} end}
         end % PutBorders
     in % in

     ExternalShow := true
     
     self.playSize = Size
     self.size = Size+2
     self.weights = {Array.new 0 ((self.size)*(self.size)-1) 0.0}
     self.board = {Array.new 0 ((self.size)*(self.size)-1) vacant}
     ExternalPutAction := PutAction
     {PutBorders}
     Board, reset(InitialStones)
   end
   
   meth getWeight(R C ?Z)
      if R*(self.size)+C<0 then
         {Browser.browse 'INVALID GET WEIGHT SBOARD: '#R#C}
         {Delay 100000}
      end
      
     {Array.get self.weights (R*(self.size)+C) Z} 
   end
   
   meth setWeight(R C W)
      if R*(self.size)+C<0 then
         {Browser.browse 'INVALID SET WEIGHT SBOARD: '#R#C}
         {Delay 100000}
      end
      
     {Array.put self.weights (R*(self.size)+C) W} 
   end
   
   meth clearWeights
      Board, processBoard(
                 proc {$ SB R C} 
                    {Array.put SB.weights (R*SB.size+C) 0} 
                 end
      )
   end

   meth reset(StoneList)
      proc {Initialize StoneList}
         if StoneList\=nil then 
           (R#C#Clr)|Tail = StoneList 
         in
           {self put(R C Clr)}
           {Initialize Tail} 
         end
      end
   in
      History := nil
      Board, processBoard(
                 proc {$ SB R C} 
                    {Array.put SB.board (R*SB.size+C) vacant} 
                 end
      )
      if {IsDet StoneList} then { Initialize StoneList } end
   end

   meth get(R C ?Z)
      if R*(self.size)+C<0 then
         {Browser.browse 'INVALID GET SBOARD: '#R#C}
         {Delay 100000}
      end
      
     {Array.get self.board (R*(self.size)+C) Z} 
   end

   meth put(R C NewClr)
     OldClr = Board, get(R C $)
   in % put
     {Pr 'put:'#R#','#C#' ('#NewClr#')'}
     if {Not {List.member NewClr [vacant black white]}} then
        {Raise 'expecting board position: vacant, black, or white'}
     end
     if {Not {self isOnTheBoard(R C $)}} then 
        {Raise 'attempt to put a stone off the board at'#R#C}
     end
     {Array.put self.board (R*self.size+C) NewClr}  % actual put her
     History :=  R#C#NewClr#OldClr | @History  
     {self EPut(R C NewClr)}
   end % put

   meth history(?Z)
      Z = @History
   end
   
   meth clearHistory(ResetHistory<=nil)
      History := ResetHistory
   end

   meth whichMove(?Z)
      Z = {List.length @History}
   end

   meth processBoard(Proc)
     UpB = self.size-2
   in
      {For 1 UpB 1 proc {$ I} 
         {For 1 UpB 1 proc {$ J}
            {Proc self I J} 
         end} 
      end}
   end

  meth getSameColorList(R C ?Z)

      Color = {self get(R C $)}
      MyList = {NewCell nil}
      
      proc {Recurs R C}  % R#C assumed to be on board
         
         MyColor = {self get(R C $)}
         
         fun {OK X Y}
           {self isOnTheBoard(X Y $)} andthen MyColor==Color
         end

       in
         if {OK R C} then
           MyList := R#C | @MyList
           {Array.put self.board R*self.size+C mark}
           {Recurs R-1 C} 
           {Recurs R C-1}
           {Recurs R+1 C}
           {Recurs R C+1}
         end
      end % Recurs
      
    in % getSameColorList
      {Recurs R C}
      {List.forAll @MyList proc {$ R#C} 
         {Array.put self.board R*self.size+C Color}
       end}
      Z=  @MyList
   end % getSameColorList

   meth isOnTheBoard(R C ?Z)
      L = self.size-1
   in
      Z = {And {And R>0 C>0} {And R<L C<L}}
   end

   meth isOnEdge(R C ?Z)  % edge of playable area
      L = self.size-2
   in
      Z = {Or {Or R==1 C==1} {Or R==L C==L}}
   end

   meth EPut(R C X)
      if {And {IsDet @ExternalPutAction} @ExternalShow} then
         {@ExternalPutAction R C X}
      end
   end

   meth retract
      NewHistory R C Clr
   in
      {Pr retract}
      if @History\=nil then
         @History = R#C#_#Clr | NewHistory
         History := NewHistory
         {Array.put self.board (R*self.size+C) Clr}
         {self EPut(R C Clr)}
      end
   end

   meth externalShow(Boo)
     ExternalShow := Boo
   end

   %% Returns *actual* board size. Inserted by Irving Dai, April 25, 2010.
   meth size(?Ret)
      Ret = self.size-2
   end

   meth setPutAction(GPA)
      ExternalPutAction:=GPA
   end

   % gets a list of all R#C Positions within a Manhattan-distance radius
   meth getManhattan(Pos Radius ?StonesWithinDistance) 
      R#C = Pos

      fun{Glue List1 C}
         case List1
         of R|T then 
           if {self isOnTheBoard(R C $)}
              then R#C|{Glue T C}
              else     {Glue T C}
           end
         else
            {Col C+1}
         end
      end

      fun{Row S Stop}
         if S==Stop+1 then
            nil
         else
            S|{Row S+1 Stop}
         end
      end

      fun{Col S}
         if S==C+Radius+1 then
            nil
         else
            {Glue 
               {Row 
                  R-(Radius-{Number.abs (S-C) $})
                  R+(Radius-{Number.abs (S-C) $})
               }
               S
            }
         end
      end
      in %Glue Row Col
       StonesWithinDistance = {Col C-Radius}
   end


end % class Board

end


