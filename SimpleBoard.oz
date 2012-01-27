functor
   
   import Browser System JAZTools
   export Board

define

Pr = {JAZTools.setWriter System.showInfo}

%% Among the features of a Board object is dists which is 2-D array indexed
%% by board positions such that cells are B#W pairs where B or W is nil or 
%%           row#col#distance#count#list
%% where row,col,distance represent a black (white) stone that is.
%% closest to the indexed position
%% and list is a list of 
%%           row#col#dist
%% showing the coordinates and distance from the indexed position of all  
%% black (white) stones within the influence radius of the indexed position 
%% and count is the length of list (kept to avoid the overhead of recalculating it).

fun {UpdateDistsPartForPutVacant
         VR VC        % position being made vacant
         OldDist}     % dists we want updated
         % note: do not expect stones to be removed very often
   NewR = {NewCell 134217726}
   NewC = {NewCell 134217726}
   NewDist = {NewCell 134217726}
    
   fun {Recurs Lst}
      if Lst==nil then
          nil
      else
          R#C#Dist|Rest = Lst
          in
             if VR#VC\=R#C then
                if Dist<@NewDist then  NewR:=R  NewC:=C  NewDist:=Dist  end
                R#C#Dist|{Recurs Rest}
             else
                {Recurs Rest}
             end
      end
   end
   
   in
      case OldDist 
      of R#C#Dist#_#List then
         NewList = {Recurs List}
         in
            @NewR#@NewC#@NewDist#{Length NewList}#NewList
      [] nil then
         nil
      end
end

fun {UpdateDistsPartForPutStone
         NR NC NDist            % the stone being played & distance to R#C
         OldDist}               % what we are updating
      case OldDist 
      of R#C#Dist#Length#List then
         if NDist<Dist then
            NR#NC#NDist#(Length+1)#((NR#NC#NDist)|List)
         else
            R#C#Dist#(Length+1)#((NR#NC#NDist)|List)
         end
      [] nil then
         NR#NC#NDist#1#((NR#NC#NDist)|nil)
      end
end

class Board 
   feat size playSize size2 board
          % board is a 2-D array of black/white/vacant/border  
          % size measures board with its border
          % playSize measures board without border
          % size2 is size^2-1  (the size of a linear array holding board)
        influenceRadius
          % the distance a stone's influence is usually limited to
        weights              
          % board sized 2-D array of cells not used herein
          % available for other classes and procs -- thru getWeight/setWeight
        dists                
          % board sized 2-D array recording other board positions with
   attr History 
          % sequence of moves from beginning: row#col#new_color#old_color
        ExternalShow 
          % flag used to determine if external put action to be called
        ExternalPutAction
          % an action given to constructor and invoked with each put

   meth init(Size InitialStones PutAction<=_ InfluenceRadius<=3)
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
        ExternalPutAction := PutAction
        self.playSize = Size
        self.size = Size+2
        self.size2 = self.size*self.size-1
        self.influenceRadius = InfluenceRadius
        self.weights = {Array.new 0 self.size2 0.0}
        self.board = {Array.new 0 self.size2 vacant}
        self.dists = {Array.new 0 self.size2 nil#nil}
        {PutBorders}
        Board, reset(InitialStones)
   end
   
   meth arrayToListFilter(InArray ColorMatcher ArrayMatcher ?Out)
      OutList = {NewCell nil}
      
      proc {ProcessTile Board R C}
         Clr = {Array.get Board.board (R*(self.size)+C) $} 
         ARes = {Array.get InArray (R*(self.size)+C) $}
       in
         if {ColorMatcher Clr} andthen {ArrayMatcher ARes} then
            OutList := ((R#C#Clr)#ARes)|@OutList
         end
      end
    in
      {self processBoard(ProcessTile)}
      Out = @OutList
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
      %{Pr reset}
      History := nil
      Board, processBoard(
                 proc {$ SB R C} 
                    Pos = R*SB.size+C
                  in
                    {Array.put SB.board Pos vacant} 
                    {Array.put SB.dists Pos nil#nil}
                 end
      )
      if {IsDet StoneList} then { Initialize StoneList } end
   end

   meth get(R C ?Z)
      % if {Not {self isOnTheBoard(R C $)}} then
      %   {Raise 'attempt to see position off the board at '#R#C}
      % end
      {Array.get self.board (R*(self.size)+C) Z} 
   end

   meth put(R C NewClr)
     
     OldClr = Board, get(R C $)
     
     proc {FixDists IR IC Dist}
       Pos = IR*self.size+IC
       B#W = {Array.get self.dists Pos}
       NB NW
       in
          %{Pr 'FixDists:'#R#','#C#'('#Dist#')=>'#IR#','#IC}
          if NewClr==vacant then
             if OldClr==black then
               NB = {UpdateDistsPartForPutVacant R C B}
               NW = W
             else
               NB = B
               NW = {UpdateDistsPartForPutVacant R C W}
             end
          elseif NewClr==white then
               NB = B 
               NW = {UpdateDistsPartForPutStone R C Dist W}
          else  % BETTER BE black!!
               NB = {UpdateDistsPartForPutStone R C Dist B}
               NW = W
          end
          {Array.put self.dists Pos NB#NW}
     end % fixDistsPart

     Skip = if @History==nil then
               false
            else
               RH#CH#ClrH#_|_ = @History
              in
               %{Pr 'history '# RH #','# CH #','# ClrH}
               if R==RH andthen C==CH andthen NewClr==ClrH then true
               else                                             false
               end
            end

   in % put
      if {Not Skip} then
        %{Pr 'put ' # R #','# C #','# NewClr}
        if {Not {self isOnTheBoard(R C $)}} then 
           {Raise 'attempt to put off the board at'#R#C}
        end
        History :=  R#C#NewClr#OldClr | @History  
        {Array.put self.board (R*self.size+C) NewClr}     % actual put is here
        {self EPut(R C NewClr)}
        for I in 1..self.influenceRadius do  % reevaluate dists for everything
           {self processManhattanCircle(           %  within influenceRadius  
              R 
              C
              I
              proc {$ R1 C1}  {FixDists R1 C1 I} end 
           )}
        end
      end
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
      
      fun {OK R C}
         {And {self isOnTheBoard(R C $)} ({self get(R C $)}==Color) }
      end
    
    in
      {self getList(R C OK Z)}
    end
      
    meth getList(R C OK ?Z)
      %% returns a list of all board positions reachable over board 
      %% lines from R#C in which all positions satisfy the predicate 
      %% {OK BoardClass R C}
      %% if R#C itself doesn't satisfy the ok condition nil is returned

      MyList = {NewCell nil}
      Marks = {Array.new 0 self.size2 nil}
      
      proc {Recurs R C}  % R#C assumed to be on board
         Pos = R*self.size+C 
       in
         if {And {OK R C} {Array.get Marks Pos}==nil} then
           MyList := R#C | @MyList
           {Array.put Marks Pos mark}
           {Recurs R-1 C} 
           {Recurs R C-1}
           {Recurs R+1 C}
           {Recurs R C+1}
         end
      end % Recurs
      
    in % getList
      if {OK R C} then
         {Recurs R C}
         Z =  @MyList
      else
         Z = nil
      end
    end % getList

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
      %{Pr retract}
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

   meth getManhattan(Pos Radius ?WithinRadius) 
      %% this changes Aaron's version in that it pays no attention
      %% to enemy stones
   
      R#C = Pos
   
      List = {NewCell nil}
      List := Pos|@List 
   
      proc {AddToList R C}
        List := R#C| @List
      end
   
   in % getManhattan
      for I in 1..Radius do 
         {self processManhattanCircle(R C I AddToList)}
      end
      WithinRadius = @List
   end % getManhattan

   meth processManhattanCircle(R C Dist Proc)
      for Delta in ~Dist..0  do 
         local Delta_ = Dist+Delta in
            if {self isOnTheBoard(R+Delta C+Delta_ $)} then
               {Proc R+Delta C+Delta_}
            end
            if {self isOnTheBoard(R+Delta_ C+Delta $)} then
               {Proc R+Delta_ C+Delta}
            end
         end
      end
      for Delta in 1..Dist-1 do
         local Delta_ = Dist-Delta in
            if {self isOnTheBoard(R-Delta C-Delta_ $)} then
               {Proc R-Delta C-Delta_}
            end
            if {self isOnTheBoard(R+Delta_ C+Delta $)} then
               {Proc R+Delta_ C+Delta}
            end
         end
      end
   end

end % class Board

end


