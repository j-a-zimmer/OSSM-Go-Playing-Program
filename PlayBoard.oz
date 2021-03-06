functor

import SimpleBoard SmartBoard JAZTools Browser
   System ArctanInfl PseudoTerritory

export PBoard History2Initializer

define

fun {History2Initializer Hist}
   {List.filter
      {List.map Hist
         fun {$ X} A#B#C#_=X in A#B#C end
      }
      fun {$ X} _#_#C=X in C\=vacant end
   }
end

%Pr = {JAZTools.setWriter System.showInfo}
Process4 = SmartBoard.process4

InfluenceRadius = 3

Opposite = opposite(white:black black:white)

class PBoard from SmartBoard.sBoard
   feat influenceCacheBoard influenceCacheList 
        arctanInfluenceCache
		manhatTerrCache
		arctanTerrCache

   meth init(Size InitialStones State<=_) 
      %For information about what State is, see the getState method
	  
	  SmartBoard.sBoard, init( Size InitialStones )
	  if {IsDet State} then
	     
		 %init if state is provided
		 
	     fun{ListToArray Low#High#Lst}
	        L = {NewCell Lst}
	        A = {NewArray Low High nil}
	     in
		    for I in Low..High do
		       {Array.put A Low (@L).1}
		  	   L := (@L).2
		    end
		    A
	     end
		 fun{ListToBoard Lst}
		    B = {New SimpleBoard.board init(self.playSize nil _)}
			L = {NewCell Lst}
		 in
		    for R in 1..{self size($)} do
			   for C in 1..{self size($)} do
			      {B setWeight(R C (@L).1)}
				  L := (@L).2
			   end
			end
			B
		 end
      in	  
	     % Set caching to values in State
	  
         self.influenceCacheBoard = cacheBoard(white:{NewCell {ListToBoard State.influenceCacheBoard.white}} 
	                                           black:{NewCell {ListToBoard State.influenceCacheBoard.black}}  )
											
         self.influenceCacheList = cacheList(white:{NewCell (State.influenceCacheList.white)} 
	                                         black:{NewCell (State.influenceCacheList.black)}  )
										  
	     self.arctanInfluenceCache = {NewCell (State.arctanInfluenceCache)}
	  
	     self.manhatTerrCache = cacheInfo1(array:{NewCell {ListToArray (State.manhatTerrCache.array)}}
	                                      clusterArray:{NewCell {ListToArray (State.manhatTerrCache.clusterArray)}}
	  								      clusters:{NewCell (State.manhatTerrCache.clusters)}  )
									   
	     self.arctanTerrCache = cacheInfo(array:{NewCell {ListToArray (State.arctanTerrCache.array)}}
	                                      clusterArray:{NewCell {ListToArray (State.arctanTerrCache.clusterArray)}}
								  	      clusters:{NewCell (State.arctanTerrCache.clusters)}  )
										  
	  else
	     
		 %Normal init
         self.influenceCacheBoard = cacheBoard(white:{NewCell _} black:{NewCell _})
         self.influenceCacheList = cacheList(white:{NewCell _} black:{NewCell _})
	     self.arctanInfluenceCache = {NewCell _}
	     self.manhatTerrCache = cacheInfo(array:{NewCell _} clusterArray:{NewCell _} clusters:{NewCell nil})
	     self.arctanTerrCache = cacheInfo(array:{NewCell _} clusterArray:{NewCell _} clusters:{NewCell nil})
		 
	  end
   end
   
   meth getState(State)
      % The State of a playBoard is everything that you need to construct the current playBoard in a stateless form.
	  % It contains:
	  %    -state.intialStones  =  information about all stones on the board
	  %    -state.size  =  size of the board
	  %    -state.influenceCacheBoard  =  the simpleBoard that contains manhat influence information. In state, it is
	  %                                     stored as a list.
	  %    -state.influenceCacheList   =  similar to CacheBoard already in list form
	  %    -state.arctanInfluenceCache  =  a list containing the arctanInfluence at each location
	  %    -state.manhatTerrCache  =  a bunch of information converted into three lists about manhat territory
	  %    -state.arctanTerrCache  =  a bunch of information converted into three lists about arctan territory
	  %
	  % The state should be used if information about the board needs to be sent across a network. Oz gives nice ways to
	  %  efficiently work with stateless data acrosss a network, so this is MUCH better than sending the stateful board object.
	  %
	  
      fun{ArrayToList A}
	     Low = {Array.low A}
		 High = {Array.high A}
		 fun{Recurs I}
		    if I>High then
			   nil
			else
			   {Array.get A I}|{Recurs I+1}
			end
		 end
	  in
	     Low#High#{Recurs Low}
	  end
	  
	  fun{BoardToList B}
	     Lst = {NewCell nil}
	  in
	     for R in 1..{self size($)} do
		    for C in 1..{self size($)} do
			   Lst := {B getWeight(R C $)}|(@Lst)
			end
         end
	     {List.reverse @Lst}
	  end
   
      InitialStones = {NewCell nil}
   in
	  for R in 1..{self size($)} do
	     for C in 1..{self size($)} do
		    Color = {self get(R C $)} 
		 in
		    if {Not Color==vacant} then
		       InitialStones := (R#C#Color)|@InitialStones
		    end
	     end
	  end
      State = state(initialStones: @InitialStones
					size: {self size($)}
	  
	                influenceCacheBoard: cacheBoard(white:{BoardToList @(self.influenceCacheBoard.white)}
					                                black:{BoardToList @(self.influenceCacheBoard.black)} )
                    influenceCacheList:  cacheBoard(white: @(self.influenceCacheList.white)
					                                black: @(self.influenceCacheList.black)  )
                    arctanInfluenceCache: @(self.arctanInfluenceCache)
					manhatTerrCache: cacheInfo(array: {ArrayToList @(self.manhatTerrCache.array)}
					                           clusterArray:{ArrayToList @(self.manhatTerrCache.clusterArray)}
											   clusters:@(self.manhatTerrCache.clusters)  )
                    arctanTerrCache: cacheInfo(array: {ArrayToList @(self.arctanTerrCache.array)}
					                           clusterArray:{ArrayToList @(self.arctanTerrCache.clusterArray)}
											   clusters:@(self.arctanTerrCache.clusters)  )
                    )
   end
   
   %% RetractMove method added by Irving Dai, Feb. 16
   %% Retracts history by one complete move (that is, goes up to
   %% and deletes most recent 'vacant-to-nonvacant' move).
   %% 
   meth retractMove
      History = {self history($)}
   in 
      if History\=nil then
         if (History.1).3==vacant then
            SimpleBoard.board, retract
            {self retractMove}
         else
            {self wipeCache}
            {self retract}
         end
      end
   end % RetractMove
   
   meth phase(?R)
      StonesPlayed = SmartBoard.sBoard,numStones($)
      TotalSpaces = {Int.toFloat (self.playSize * self.playSize)}
    in
      if (StonesPlayed >= {Float.toInt (TotalSpaces * 0.6)}) then
         R = late
      elseif (StonesPlayed >= {Float.toInt (TotalSpaces * 0.07)}) then
         R = middle
      else
         R = early
      end
   end

   %% IsDead function tests whether the cluster
   %% containing a given position is dead.
   %% 
   meth IsDead(R C ?Ret)
      Cluster = {self cluster(R C $)}
   in
      Ret = (Cluster.liberties==nil)
   end

   meth IsEmpty(R C ?Ret)
      Ret = ({self get(R C $)}==vacant)
   end
   
   meth IsSuicide(R C ?Ret)
      Cluster
      Helper = fun {$ BP}
		   {Not {self IsDead(BP.1 BP.2 $)}}
	   end
   in
      Cluster = {self cluster(R C $)}
      Ret = 
         {And Cluster.liberties==nil {List.all Cluster.enemies Helper}}
   end % IsSuicide

   meth IsDejaVu(R C ?Ret)
      HL = {self history($)}
      Index = {Array.new 1 {self size($)}*{self size($)} 0}
      Color = color(vacant:0 black:1 white:_)
      Temp = {NewCell 1}

      fun {Helper HL State}      
         case HL of nil then
            false
         [] H|T then
            case H of R#C#New#Old then
               NewState = 
                  State+(Index.(R+{self size($)}*(C-1))*(Color.New-Color.Old))
            in
               if NewState==0 then
                  true
               else
                  {Helper T NewState}
               end
            else
               raise
                   Helper#unexpected
               end
            end
         end
      end

   in % IsDejaVu

      for I in 1..{self size($)}*{self size($)} do
         {Array.put Index I @Temp}
         Temp := 2*(@Temp)
      end
      Color.white = @Temp
      Ret = {Helper HL 0}
            
   end % IsDejaVu

   meth analyze(R C Col ?Valid ?Killed)
      %% If Valid==false, Killed is meaningless.
      if {self IsEmpty(R C $)} then
	      {self externalShow(false)}
	      SmartBoard.sBoard,play(R C Col)
         if {self IsSuicide(R C $)} then
            Valid = false
         else
            {self gotKilled(R C Col Killed)}
            if {IsDet Killed} andthen {Length Killed}==1 then
               {self kill(Killed)}
               Valid = {Not {self IsDejaVu(R C $)}}
	         else
		         Valid = true
            end 
         end
         {self retractMove}
         {self externalShow(true)}
      else
         Valid = false
      end
   end % Analyze
  
   %% gotKilled method gets the enemy clusters surrounding a given 
   %% move and checks if the move kills any enemy clusters.
   %%
   meth gotKilled(R C Col ?Killed)
      Hostile Helper GetStones Lst
      Helper = fun {$ BP}
		  {self IsDead(BP.1 BP.2 $)}
	   end
   in
      {self getHostile(R C Col Hostile)}
      GetStones = fun {$ BP}
		   {self cluster(BP.1 BP.2 $)}.stones
		   end
      Lst = {List.map {List.filter Hostile Helper $} GetStones $}
      Killed = {JAZTools.removeDuplicates Lst $}
   end
   
   %% getHostile method gets the enemy stones surrounding
   %% a given stone.
   %% 
   meth getHostile(R C Col ?Ret)
      Cell = {NewCell nil}
      Helper = proc {$ R C}
		  if {self get(R C $)}==Opposite.Col then
		     Cell := (R#C)|@Cell
		  end
      end
   in 
      {Process4 R C Helper}
      Ret = @Cell
   end % GetHostile
	 
   meth play(R C Clr Played<='not needed')
      Valid Killed
   in
      {self wipeCache}
      
      {self analyze(R C Clr Valid Killed)}
      if Valid then
         SmartBoard.sBoard,play(R C Clr)
	      if {Length Killed}>0 then {self kill(Killed)} end
      end
      if {Not {IsDet Played}} then Played=Valid end
   end

   %% This auxilary function clones a board.
   %% I am Irving and I write nice little useful
   %% comments that are well-phrased and all.
   meth cloneBoard(?Ret)
      local Lst in
	      Lst = {NewCell nil}
	      for R in 1..{self size($)} do
	         for C in 1..{self size($)} do
	            local Color in
		            Color = {self get(R C $)} 
		            if {Not Color==vacant} then
		               Lst := (R#C#Color)|@Lst
		            end
	            end
	         end
	      end
	      Ret = {New PBoard init({self size($)} @Lst _)}
      end
   end
   %% If a position is on the board
   meth isValidPos(Pos ?B)

      if {Or {Or {Or Pos.1<1 Pos.2<1} Pos.1>=self.size-1}
         Pos.2>=self.size-1} 
      then B=false
      else B=true
      end
   end
   
   meth wipeCache
      ((self.influenceCacheBoard).white) := _
      ((self.influenceCacheBoard).black) := _
      ((self.influenceCacheList).black) := _
      ((self.influenceCacheList).white) := _
	  (self.arctanInfluenceCache) := _
	  ((self.arctanTerrCache).array) := _
	  ((self.arctanTerrCache).clusterArray) := _
	  ((self.arctanTerrCache).clusters) := nil
	  ((self.manhatTerrCache).array) := _
	  ((self.manhatTerrCache).clusterArray) := _
	  ((self.manhatTerrCache).clusters) := nil
   end
   
   meth fillCaches
   % This should be made better, along with the clean up of all the old nasty stuff below this.
   % It was made quickly to test the distributed lobes and should be improved upon. It just doesn't
   %    look clean... 
     {self wipeCache}
	  
	 %Refill the cache
      {self influence(white _)}
	  {self influence(black _)}
	  {self maybeFillArctanInfl}
	  {self maybeFillManhatTerrArray}
	  {self maybeFillManhatTerrClusters}
	  {self maybeFillArctanTerrArray}
	  {self maybeFillArctanTerrClusters}
   end
   
   %%%%  EVERYTHING BELOW HERE IS OLD CACHING STUFF THAT NEEDS TO BE UPDATED OR REMOVED  %%%%
   %%%% influence, getArctanTerrCluster, and getManhatTerrCluster methods are used above %%%%
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Manhat Influence%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
   
   %% Gets influenced positions due to a single stone
   meth getInfluencedPositions(R C Clr $)
     EClr = Opposite.Clr

     fun {GoodPositions R1#C1}
       Manhattan = {Number.abs R1-R} + {Number.abs C1-C}
      in
       {List.all 
           {self getManhattan(R1#C1 Manhattan $)}
           fun {$ R#C} {self get(R C $)}\=EClr end 
       }
     end % GoodPositions
   
   in % getInfluencedPostions
     {List.filter 
        {self getManhattan(R#C InfluenceRadius $)} 
        GoodPositions
        $
     }
    
   end
 
   meth influence(Color ?Lst)
      StoneList ClusterList
      SumBoard = {New SimpleBoard.board init(self.playSize nil _)}
      EndLst = {NewCell nil}
      
      proc {AddWeight R#C}
         X = {SumBoard getWeight(R C $)}+1.0 
      in
         {SumBoard setWeight( R C X)}
      end

      proc {AddWeights Board R C}  % Board ignored but needed so
                                     % process board can be used
        InfluenceList = {self getInfluencedPositions(R C Color $)}
      in
         if {self get(R C $)}==Color then 
            {List.forAll InfluenceList AddWeight} % alters SumBoard
         end
      end

      proc {FixCorners}
        
        EClr = Opposite.Color
        PS = self.playSize

        fun {CheckCorner R C HDelta VDelta}
           Color1 = {self get(R C+VDelta $)}
           Color2 = {self get(R+HDelta C $)}
        in
           EClr==Color1 andthen EClr==Color2 andthen 
                      {SumBoard getWeight(R C $)}==0
        end
        
      in
         if {CheckCorner 0 0 1 1}  then {AddWeight 0#0} end
         if {CheckCorner 0 PS 1 ~1}  then {AddWeight 0#PS} end
         if {CheckCorner PS 0 ~1 1}  then {AddWeight PS#0} end
         if {CheckCorner PS PS ~1 ~1}  then {AddWeight PS#PS} end
      end % FixCorners

    in % Influence 
      if {IsDet @((self.influenceCacheList).Color)} then
         Lst = @((self.influenceCacheList).Color)
      else
         {self processBoard(AddWeights)}
         
         for R in 1..self.playSize do 
            for C in 1..self.playSize do 
                EndLst := ((R#C#Color)#{SumBoard getWeight(R C $)})|@EndLst
            end
         end	 
         Lst = {List.filter @EndLst fun{$ _#X} X\=0.0 end}
         
         {FixCorners}
         ((self.influenceCacheBoard).Color) := SumBoard
         ((self.influenceCacheList).Color) := Lst
      end
   end %influence
   
   meth getInfluence(R C ?ClrInf)
      WhitesInfluence BlacksInfluence
   in
      if {Not {IsDet @((self.influenceCacheBoard).white)}} then 
         {self influence(white _)} 
      end
      if {Not {IsDet @((self.influenceCacheBoard).black)}} then 
         {self influence(black _)} 
      end
      
      WhitesInfluence = {@(self.(influenceCacheBoard).white) getWeight(R C $)}
      BlacksInfluence = {@(self.(influenceCacheBoard).black) getWeight(R C $)}      
      
      if {self isValidPos(R#C $)} then
         if WhitesInfluence==0.0 then
            if BlacksInfluence==0.0 then
               ClrInf = vacant#0.0
            else
               ClrInf = black#BlacksInfluence
            end
         else
            ClrInf = white#WhitesInfluence
         end
      else
         ClrInf = border#0.0 
      end
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%Arctan influence%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   meth maybeFillArctanInfl
      if {Not {IsDet @(self.arctanInfluenceCache)}} then 
         (self.arctanInfluenceCache) := {ArctanInfl.findInfl self}
      end
   end

   meth getArctanInfl(R C ?ClrInf)
      {self maybeFillArctanInfl}
	  ClrInf = {List.nth @(self.arctanInfluenceCache) R+(C-1)*{self size($)} }
   end

%%%%%%%%%%%%%%%%%%%%%%%%% PSEUDO TERRITORIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %   Following are 8 methods for finding pseudo territories:
   %      getManhatTerrArray
   %      getManhatTerrCluster
   %      getManhatTerrClusters
   %      getManhatTerr
   %      getArctanTerrArray
   %      getArctanTerrCluster
   %      getArctanTerrClusters
   %      getArctanTerr
   %
   %   It also contains methods to fill the caches involved if they aren't
   %     already filled:
   %       -maybeFillArctanTerrArray    -maybeFillManhatTerrArray
   %       -maybeFillArctanTerrClusers  -maybeFillManhatTerrClusters
   %
   %   They give an array of control over the entire board,
   %             a cluster of all spaces in a Psuedo Territory, 
   %             a list of all territory clusters on the board, and
   %             the color controlling a specific point
   %
   %   These 4 things are defined using Manhattan influence and Arctan Influence.
   %
   %   Arctan influence is generally more accurate towards the start of the game
   %      and manhattan better in late game.
   %
   %   The majority of the code implementng these is in PseudoTerritory.oz
   %
   %   The PlayBoard will maintain a cache of the array of control, which is cleared each turn
   %   It does not cache the clusters, but uses the cached array to find them
   
 %%%%%%%%%%%%%%%%%%%%% Manhat Territory%%%%%%%%%%%%%%%%%%%%%%%%%%
 
   meth maybeFillManhatTerrArray
      if {Not {IsDet @((self.manhatTerrCache).array)}} then 
         ((self.manhatTerrCache).array) := {PseudoTerritory.findTerritoryManhat self $}
      end
   end
   
   meth getManhatTerrArray(?Ary)
      {self maybeFillManhatTerrArray}
	  Ary = @((self.manhatTerrCache).array)
   end
   
   meth maybeFillManhatTerrClusters
      if {Not {IsDet @((self.manhatTerrCache).clusterArray)}} then
	     Ary = {self getManhatTerrArray($)}
	     Size = {self size($)}
	  in
	     ((self.manhatTerrCache).clusterArray) := {NewArray Size+1 (Size+1)*Size+1 nil}
		 ((self.manhatTerrCache).clusters) := nil
	     for R in 1..Size do
		    for C in 1..Size do
			   if {Get @((self.manhatTerrCache).clusterArray) R*Size+C}==nil then
			      Cluster = {PseudoTerritory.findTerritoryCluster self Ary R C}
			   in
			      ((self.manhatTerrCache).clusters) := Cluster | @((self.manhatTerrCache).clusters)
			      for (R1#C1) in Cluster.spaces do
				     {Put @((self.manhatTerrCache).clusterArray) R1*Size+C1 Cluster}
				  end
			   end
			end
		 end
	  end
   end
   
   meth getManhatTerrCluster(R C ?Clst)
      {self maybeFillManhatTerrClusters}
	  Clst = {Get @((self.manhatTerrCache).clusterArray) R*{self size($)}+C}
   end
   
   meth getManhatTerrClusters(?CLst)
      {self getManhatTerrCluster(1 1 _)}
	  CLst = @((self.manhatTerrCache).clusters)
   end
   
   meth getManhatTerr(R C ?Col)
      Ary = {self getManhatTerrArray($)}
   in
	  Col = {Get Ary R*{self size($)}+C}
   end
   
 %%%%%%%%%%%%%%%%%%%%%%%%%Arctan Territory%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
   meth maybeFillArctanTerrArray
      if {Not {IsDet @((self.arctanTerrCache).array)}} then 
         ((self.arctanTerrCache).array) := {PseudoTerritory.findTerritoryArctan self $}
      end
   end
   
   meth getArctanTerrArray(?Ary)
      {self maybeFillArctanTerrArray}
	  Ary = @((self.arctanTerrCache).array)
   end
   
   meth maybeFillArctanTerrClusters
      if {Not {IsDet @((self.arctanTerrCache).clusterArray)}} then
	     Ary = {self getArctanTerrArray($)}
	     Size = {self size($)}
	  in
	     ((self.arctanTerrCache).clusterArray) := {NewArray Size+1 (Size+1)*Size+1 nil}
		 ((self.arctanTerrCache).clusters) := nil
	     for R in 1..Size do
		    for C in 1..Size do
			   if {Get @((self.arctanTerrCache).clusterArray) R*Size+C}==nil then
			      Cluster = {PseudoTerritory.findTerritoryCluster self Ary R C}
			   in
			      ((self.arctanTerrCache).clusters) := Cluster|@((self.arctanTerrCache).clusters)
			      for (R1#C1) in Cluster.spaces do
				     {Put @((self.arctanTerrCache).clusterArray) R1*Size+C1 Cluster}
				  end
			   end
			end
		 end
	  end
   end
   
   meth getArctanTerrCluster(R C ?Clst)
      {self maybeFillArctanTerrClusters}
	  Clst = {Get @((self.arctanTerrCache).clusterArray) R*{self size($)}+C}
   end
   
   meth getArctanTerrClusters(?CLst)
      {self getArctanTerrCluster(1 1 _)}
	  CLst = @((self.arctanTerrCache).clusters)
   end
   
   meth getArctanTerr(R C ?Col)
   
      fun{IsOnTheBoard Board R C}
         L = {Board size($)}+1
      in
         {And {And R>0 C>0} {And R<L C<L}}
      end
	  
      Ary = {self getArctanTerrArray($)}
   in
      if {IsOnTheBoard self R C} then
	     Col = if {Get Ary R*{self size($)}+C}==1 then
	              black
			   elseif{Get Ary R*{self size($)}+C}==~1 then
			      white
			   else
			      vacant
			   end
	  else
	     Col = nil
      end
   end
   
end %PBoard

end
