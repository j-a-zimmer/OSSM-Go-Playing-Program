functor

import OS JAZTools AIGui PlayBoard Browser System Connection

         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % The lobes we are importing. %
         % Make sure you also add them %
         % into the initializing list  %
         % builder!                    %
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         Killer Background ClusterAttack
         ClusterDefend Diagonal Fork
         MakeEye Suicide TerritorySuicide BorderSeal
         Threaten Expand Connect DiagonalDelay LibertyCheck
         AggressiveExpand IncreaseArcInfl Colonize
		 LibertyIncrease DontFillInEyes
		 TerritorySeal ChangeNumTerritories
		 IncreaseTerritorySpace
         
export Brain

define
   
   class Brain
      
      feat size color pBoard gBoard 
	       talker human genetic
		   lobes lobeWeights
		   host1
		   workTime9: 3000
		   workTime13: 5000
		   workTime19: 7000
		   workTimeOddSize: 5000
      
      meth init()
	  
	  % The order of this list is semi-important. It needs to be the reverse of the list below.
      %    So I made it alphabetical, please keep it that way, or feel the wrath of Ben...               
	    %          Name of Lobe                        # Where to host it
		%         -------------------------------------#------------------
	     LobeInfo = [(AggressiveExpand.aggressiveExpand)#host1
				     (Background.background            )#here
					 (BorderSeal.borderSeal            )#host1
		 			 (ClusterAttack.clusterAttack      )#host1
                     (ClusterDefend.clusterDefend      )#host1
					 (Colonize.colonize                )#host1
					 (Connect.connect                  )#host1
			 		 (Diagonal.diagonal                )#host1
					 (DiagonalDelay.diagonalDelay      )#host1
					 (DontFillInEyes.dontFillInEyes    )#host1
					 (Expand.expand                    )#host1
					 (Fork.fork				           )#host1
                     (IncreaseArcInfl.increaseArcInfl  )#host1	
                     (Killer.killer                    )#host1
					 (LibertyCheck.libertyCheck        )#host1
					 (LibertyIncrease.libertyIncrease  )#host1
				 	 (MakeEye.makeEye                  )#host1
				 	 (Suicide.suicide                  )#host1
					 (TerritorySeal.territorySeal      )#host1
                     (TerritorySuicide.territorySuicide)#host1
					 (Threaten.threaten                )#host1
 					     ]
		 
         proc {LobeInitializer List WList ?R}
            case List
            of (Head#here)|Tail then   % make lobe on current CPU, local host
			   L = {New Head init}
			in
			   {L start}
               {LobeInitializer Tail L|WList R}
			   
			[] (Head#host1)|Tail then  % make lobe on first host
			   L = {self.host1 hostLobe(Head init $)}
			in
               {LobeInitializer Tail L|WList R}
			   
            else R = WList end
         end
       in
	     self.host1 = {Connection.take 'oz-ticket://127.0.0.1:9000/h14293812#0'}
         self.human = false
         
         % Form the lobes list.
         
         self.lobes = {LobeInitializer LobeInfo nil $}
						   
		 % This list needs to be in the reverse order of the list above
		 self.lobeWeights = 
		        [ threaten(early:0.1 middle:2.0 late:2.0 )
				  territorySuicide(early:0.0 middle:0.0 late:25.0 )
				  territorySeal(early:0.25 middle:0.5 late:1.0)
				  suicide(early:225.0 middle:225.0 late:225.0 )
				  makeEye(early:0.1 middle:0.25 late:0.5 )
				  libertyIncrease(early:10.0 middle:10.0 late:10.0)
				  libertyCheck(early:5.0 middle:5.0 late:5.0 )
				  killer(early:100.0 middle:100.0 late:100.0 )
				  increaseArcInfl(early:1.0 middle:0.5 late:0.0)
				  fork(early:0.0 middle:5.0 late:5.0 )
				  expand(early:1.0 middle:0.5 late:0.0 )
				  dontFillInEyes(early:100.0 middle:100.0 late:100.0) 
				  diagonalDelay(early:1.0 middle:0.5 late:0.0 )
				  diagonal(early:0.0 middle:0.2 late:0.2 )
				  connect(early:2.0 middle:2.0 late:2.0 )
				  colonize(early:2.0 middle:0.5 late:0.0)
				  clusterDefend(early:2.0 middle:3.0 late:5.0 )
				  clusterAttack(early:0.0 middle:6.0 late:8.0 )
				  borderSeal(early:1.0 middle:2.0 late:1.5 )
				  background(early:0.9 middle:0.1 late:0.1 )
			      aggressiveExpand(early:0.0 middle:1.0 late:0.5 ) 
				     ]
      end
      
      meth initializeGenetic(GeneticID)
         self.genetic = {String.toInt GeneticID}
      end
      
      meth clearBoard()
         if {IsDet self.pBoard} then
            {self.pBoard reset(_)}
         end
         
         if {IsDet self.gBoard} then
            {self.gBoard reset()}
         end
      end
      
      meth introduceTalker(Talker)
         self.talker = Talker
      end
      
      % Called from our Talker on command from the Server
      meth setupBoard(Size)
         proc {GuiPutAction R C V}
            {self.gBoard put(R C V)}
         end
         
         GeneticID
       in
         self.pBoard = {New PlayBoard.pBoard init(Size nil _)}
         self.size = Size
         
         if {Not {IsDet self.genetic}} then
            self.gBoard = 
                         {New AIGui.aIGBoard init(
                                self
                                self.size 
                                34.0 ) }
            {self.pBoard setPutAction(GuiPutAction)}
         end
      end
      
      % Called from our Talker on command from the Server
      meth receivedMove(Move)
         {self.pBoard play(Move.1 Move.2 Move.3)}
         
         if {IsDet self.gBoard} then
            {self.gBoard draw(self.pBoard)}
         end
      end
	   
      % Called from our Talker on command from the Server
      meth decide(Color ?Move)
         ImportanceLst
         FilterLst
         
         Legal = fun {$ WMove}
            {self.pBoard analyze(WMove.1.1 WMove.1.2 WMove.1.3 $ _)}
         end
         
         proc {GetSelectedMove FilterLst WeightNum ?R}
            if (WeightNum < 0) then
               R = pass
            elseif {List.length FilterLst} == 0 then
               R = pass
            elseif FilterLst.1.2<0.0 then
               R = pass
            else
               ForwardChoice = {GetSelectedMove FilterLst.2 (WeightNum-1) $}
             in
               if {Or (WeightNum == 0) (ForwardChoice == pass)} then
                  R = FilterLst.1.1
               else
                  R = ForwardChoice
               end
            end
         end
		 GameTime
      in % meth decide
         self.color = Color

         if {IsDet self.gBoard} then
            {self.gBoard wipeWeightMemory}
         end
         ImportanceLst = {self ImportanceList($)}
         FilterLst = {List.filter ImportanceLst Legal}
         
         if {IsDet self.genetic} then
            {GetSelectedMove FilterLst ({OS.rand} mod 3) Move}
         else
            {GetSelectedMove FilterLst 0 Move}
         end
         
         if Move \= pass then                      
            {self.pBoard play(Move.1 Move.2 self.color)} 
         end
         
         if {IsDet self.gBoard} then
            {self.gBoard passWeights(FilterLst)}
            {self.gBoard draw(self.pBoard)}
         end
      end % meth decide

      meth ImportanceList(?Lst)
	     GameTime = {self.pBoard phase($)}
		 
		 proc{UpdateAllLocalLobes Lobes Update}
		    fun{IsLocal L}
			   {IsObject L}
			end
		 in
		    case Lobes
			of L|T then
			   if {IsLocal L} then
			      {L update( Update )}
			   end
			   {UpdateAllLocalLobes T Update}
			else
			   skip
			end
		 end
		 
         fun{GetValues Lobes LobeWeights}
		    case Lobes#LobeWeights of (Lobe|LobeT)#(LobeWeight|LobeWeightT) then
			   Weight
			   AdjustedWeight
			in
			   if LobeWeight.GameTime \= 0.0 then
                  {Lobe getValues(Weight)}
				  if {Not {Lobe getDone($)}} then {System.show {Label LobeWeight}#' didnt finish in time. tisk tisk tisk'} end
                  AdjustedWeight = {List.map Weight fun{$ (A#B#C)#V} (A#B#C)#(V*LobeWeight.GameTime) end}
                  if {IsDet self.gBoard} then
                     {self.gBoard passWeightInfo(Lobe AdjustedWeight)}
                  end
			      AdjustedWeight|{GetValues LobeT LobeWeightT}
			   else 
			      {GetValues LobeT LobeWeightT}
			   end
			else
			   nil
			end
         end % fun GetValues
		 Update
      in
		 {self.pBoard fillCaches}
		 Update = updateInfo(color:self.color state:{self.pBoard getState($)})
		 {UpdateAllLocalLobes self.lobes Update }
		 {self.host1 updateLobes(Update)}
		 {self DelayBasedOnBoardSize}
         Lst = {JAZTools.weightedSort 
                   {JAZTools.compactList 
                       {List.flatten {GetValues self.lobes self.lobeWeights $}} 
                       self.size self.color}   
               }
      end

      meth Random(Board ?Lst)
         Lst = [ ( (({OS.rand} mod self.size)+1)#
                   (({OS.rand} mod self.size)+1)#
                                       self.color 
                 )#0.4 ]
      end % meth Random
	  
	  meth DelayBasedOnBoardSize
	     case {self.pBoard size($)}
		 of 9 then {Delay self.workTime9}
		 [] 13 then {Delay self.workTime13}
		 [] 19 then {Delay self.workTime19}
		 else {Delay self.workTimeOddSize} end
	  end
	  
   end % class Brain
end
