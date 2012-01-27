functor 
   import Initiator Brain Browser OS Pickle GeneticAlgorithm_GUI
define   
   %% WARNING: CHANGING THE BELOW WILL CAUSE A RESET OF GENERATION INFO %%
   Const_SaveVersion = 7
   Const_SaveFile = 'generations/current'
   Const_IndividualsPerSex = 40
   Const_BoardSize = 9
   
   %% Constants %%
   Const_MaxGamesPerChallenge = 5
   Const_NumOffspringProduced = {Float.toInt {Float.ceil {Int.toFloat Const_IndividualsPerSex} / 8.0}}
   Const_SessionStart = {NewCell {OS.time}}
   Const_RoundsPerGeneration = 5
   
   %% Structure of Genome %%
   Const_InitializingGenome = genome(
                                 connect:chromosome(eMax:0 mMax:0 lMax:0)
                                 background:chromosome(eMax:0.3 mMax:0.3 lMax:0.3)
                                 diagonal:chromosome(eMax:0.2 mMax:0.2 lMax:0.2)
                                 field:chromosome(eMax:1.0 mMax:1.0 lMax:1.0)
                                 fork:chromosome(eMax:5.0 mMax:5.0 lMax:5.0)
                                 killer:chromosome(eMax:800.0 mMax:800.0 lMax:800.0)
                                 makeEye:chromosome(eMax:0.5 mMax:0.5 lMax:0.5)
                                 suicide:chromosome(eMax:15.0 mMax:15.0 lMax:15.0)
                                 territorySuicide:chromosome(eMax:0.0 mMax:0.0 lMax:5.0)
                                 threaten:chromosome(eMax:1.0 mMax:1.0 lMax:1.0)
                                 clusterAttack:chromosome(eMax:160.0 mMax:160.0 lMax:160.0)
                                 clusterDefend:chromosome(eMax:300.0 mMax:300.0 lMax:300.0)
                                 borderSeal:chromosome(eMax:10.0 mMax:10.0 lMax:10.0)
                                 expand:chromosome(eMax:10.0 mMax:10.0 lMax:10.0)
                               )

   %% Variables %%
   GeneticGUI
   Population_Female
   Population_Male
   ChallengerID = {NewCell 0}
   CurrentGeneration = {NewCell 0}
   LastOffspringID = {NewCell 0}
   CurrentGame = {NewCell 0}
   ChallengeScore_W = {NewCell 0}
   ChallengeScore_B = {NewCell 0}
   TotalTimeElapsed = {NewCell 0}
   GenerationRound = {NewCell 0}
   Irradiations = {NewCell 0}
   
   %% Helpers %%
   % Not tell recursive for a reason - we don't want to reverse the list.
   proc {UnCellifyPop List}
      case List
      of Head|Tail then
         Pop = @Head
       in
         Head := pop(id:Pop.id generation:Pop.generation genome:Pop.genome playList:@(Pop.playList))
         {UnCellifyPop Tail}
      else skip end
   end
   
   % Not tell recursive for a reason - we don't want to reverse the list.
   proc {CellifyPop List}
      case List
      of Head|Tail then
         Pop = @Head
       in
         Head := pop(id:Pop.id generation:Pop.generation genome:Pop.genome playList:{NewCell Pop.playList})
         {CellifyPop Tail}
      else skip end
   end
   
   fun {RandomGene}
      {Int.toFloat {OS.rand} mod 3000} / 100.0
   end
      
   fun {RandomGenome}
      {Record.mapInd Const_InitializingGenome 
         fun {$ CName R}
            {Record.mapInd R 
               fun {$ MName A}
                  {RandomGene}
               end
            }
         end
      }
   end
   
   proc {PopsHavePlayed A B ?R}
      BID = B.id
      
      proc {SearchList Lst ?Ri}
         case Lst 
         of Head|Tail then
            if (Head == BID) then
               Ri = true
            else
               {SearchList Tail Ri}
            end
         else
            Ri = false
         end
      end
    in
      {SearchList @(A.playList) R}
   end
   
   fun {NewPop Genome}
      LastOffspringID := @LastOffspringID + 1
      pop(id:@LastOffspringID generation:@CurrentGeneration genome:Genome playList:{NewCell nil})
   end
   
   proc {GetListMember List ID ?R}
      if (ID < 0) then
         {Browser.browse 'WARNING: ~ ID ON GET LIST MEMBER'}
         {Wait _}
      else
         case List
         of H|T then
            if (ID == 0) then
               R = H
            else
               {GetListMember T (ID-1) R}
            end
         else
            {Browser.browse 'Could not get population ID'#ID}
            R=_
         end
      end
   end
   
   proc {RandomFemale ?R}
      FemaleID = {OS.rand} mod Const_IndividualsPerSex
    in
      {GetListMember Population_Female FemaleID R}
   end
  
   proc {MakeCellList List WorkingList ?R}
      case List
      of H|T then
         R = {NewCell H}|{MakeCellList T WorkingList $}
      else
         R = WorkingList
      end
   end
   
   proc {UnCellifyList List ?R}
      case List
      of H|T then
         R = (@H)|{UnCellifyList T $}
      else 
         R = nil
      end
   end
   
   fun {Shuffle InList}   
      proc {GetRandomMember List Length ?R}
         ChosenID = {OS.rand} mod Length
       in
         {GetListMember List ChosenID R}
      end
   
      proc {ShuffleRecurse List CurLength}
         case List
         of H|T then
            SpotA = H
            SpotAVal = @SpotA
            SpotB = {GetRandomMember List CurLength $}
            SpotBVal = @SpotB
          in
            SpotA := SpotBVal
            SpotB := SpotAVal
            
            {ShuffleRecurse T (CurLength - 1)}
         else skip end
      end
      
      CList = {MakeCellList InList nil $}
    in
      {ShuffleRecurse CList {List.length InList}}
      {UnCellifyList CList $}
   end
   
   proc {ApplyGenome Talker Genome}
      RealPlayer = Talker.talkingTo
      
      proc {ProccessLobeList List}
         case List 
         of Lobe|Tail then
            Record = Genome.(Lobe.geneticID)
          in
            {Lobe setMaxScore_Early(Record.eMax)}
            {Lobe setMaxScore_Middle(Record.mMax)}
            {Lobe setMaxScore_Late(Record.lMax)}
            
            {ProccessLobeList Tail}
         else skip end
      end
    in
      if (RealPlayer.human) then
         {Browser.browse 'Applied genome to a human player. What?'}
      else
         {ProccessLobeList RealPlayer.lobes}
      end
   end
   
   %% Initializers %%
   proc {InitializePopulations}
      proc {PushGenomes X WList ?R}
         if (X == 0) then R = WList else
            {PushGenomes (X-1) {NewCell {NewPop {RandomGenome}}}|WList R}
         end
      end
    in
      {PushGenomes Const_IndividualsPerSex nil Population_Female}
      {PushGenomes Const_IndividualsPerSex nil Population_Male}
   end
   
   proc {InitializeGUI}
      GeneticGUI = {New GeneticAlgorithm_GUI.geneticGUI init(_ Const_BoardSize 30.0 GUI_BrowseKing GUI_BrowseBlack GUI_BrowseWhite)}
   end
   
   proc {LoadInformation}
      % Adds new lobes to the genomes
      proc {VerifyPopulationGenomes List}
         case List
         of Head|Tail then
            Pop = @Head
            NewGenome = {Record.mapInd Const_InitializingGenome 
                        fun {$ CName R}
                           if {HasFeature Pop CName} then
                              Pop.CName
                           else
                              {Record.mapInd R 
                                 fun {$ MName A}
                                    {RandomGene}
                                 end
                              }
                           end
                        end
                     }
          in
            Head := pop(id:Pop.id generation:Pop.generation genome:NewGenome playList:Pop.playList)
            {VerifyPopulationGenomes Tail}
         else skip end
      end
    in
      try
         LoadRecord = {Pickle.load Const_SaveFile}
         
         proc {GrabInformation}
            Population_Female = {MakeCellList LoadRecord.pop_female nil $}
            Population_Male = {MakeCellList LoadRecord.pop_male nil $}
            ChallengerID := LoadRecord.challenger_id
            CurrentGeneration := LoadRecord.current_gen
            LastOffspringID := LoadRecord.last_offspring_id
            CurrentGame := LoadRecord.current_game
            ChallengeScore_W := LoadRecord.challengescore_w
            ChallengeScore_B := LoadRecord.challengescore_b
            TotalTimeElapsed := LoadRecord.elapsed_time
            
            if (LoadRecord.loadVersion > 6) then
               Irradiations := LoadRecord.irradiations
            end
            
            if (LoadRecord.loadVersion > 5) then
               GenerationRound := LoadRecord.generation_round
            end
         end
       in
         if {And (LoadRecord.board_size == Const_BoardSize) (LoadRecord.individuals_per_sex ==Const_IndividualsPerSex)} then
            {GrabInformation}
            
            {CellifyPop Population_Female}
            {CellifyPop Population_Male}
         else
            {InitializePopulations}
         end
      catch _ then
         {InitializePopulations}
      end
      
      {VerifyPopulationGenomes Population_Female}
      {VerifyPopulationGenomes Population_Male}
   end
   
   %% Generations %%
   proc {SaveInformation SaveTo}
      NewTime = {OS.time}
      
      TotalTimeElapsed := @TotalTimeElapsed + (NewTime - (@Const_SessionStart))
      Const_SessionStart := NewTime
      
      {UnCellifyPop Population_Female}
      {UnCellifyPop Population_Male}
   
      SaveRecord = save( loadVersion:Const_SaveVersion
                        pop_female:{UnCellifyList Population_Female $}
                        pop_male:{UnCellifyList Population_Male $}
                        challenger_id:@ChallengerID
                        current_gen:@CurrentGeneration
                        last_offspring_id:@LastOffspringID
                        current_game:@CurrentGame
                        challengescore_w:@ChallengeScore_W
                        challengescore_b:@ChallengeScore_B
                        board_size:Const_BoardSize
                        elapsed_time:@TotalTimeElapsed
                        individuals_per_sex:Const_IndividualsPerSex
                        generation_round:@GenerationRound
                        irradiations:@Irradiations
                     )
                     
      {CellifyPop Population_Female}
      {CellifyPop Population_Male}
    in
      {Pickle.save SaveRecord SaveTo}
   end
   
   fun {CrossGenomes G1 G2}
      {Record.mapInd Const_InitializingGenome 
         fun {$ CName R}
            {Record.mapInd R 
               proc {$ MName A R}
                  Which = {OS.rand} mod 2
                  ToReturn
                in
                  if (Which == 0) then
                     ToReturn = G1.CName.MName
                  else
                     ToReturn = G2.CName.MName
                  end
                  
                  R = ToReturn
               end
            }
         end
      }
   end
   
   proc {ConductReproduction}
      % Kill the oldest females and move up the youngins.
      MoveFemaleConst = Const_NumOffspringProduced * 7
      proc {MoveFemales ID}
         if (ID =< MoveFemaleConst) then
            FemaleOldSlot = {GetListMember Population_Female (MoveFemaleConst - ID)}
            FemaleNewSlot = {GetListMember Population_Female (Const_IndividualsPerSex - ID - 1)}
          in
            FemaleNewSlot := @FemaleOldSlot
            {MoveFemales ID+1}
         end
      end
      
      proc {MakeNewGeneration MaleID NumOffspring WorkingList ?R}
         NewOffspring1 NewOffspring2
         MaleGenome = (@{GetListMember Population_Male MaleID}).genome
       in
         if (NumOffspring > 1) then
            NewOffspring1 = {CrossGenomes (@{RandomFemale}).genome MaleGenome}
            
            if (NumOffspring > 2) then
               NewOffspring2 = {CrossGenomes (@{RandomFemale}).genome MaleGenome}
               
               {MakeNewGeneration (MaleID - 1) (NumOffspring - 2) NewOffspring1|(NewOffspring2|WorkingList) R}
            else
               R = NewOffspring1|WorkingList
            end
         else
            R = WorkingList
         end
      end
      
      proc {DistributeGeneration List GivenToMales GivenToFemales}
         case List
         of H|T then
            if (GivenToMales >= Const_NumOffspringProduced) then
               % Males have enough, give it a sex change and pass it to the females
               NewHome = {GetListMember Population_Female GivenToFemales $}
             in
               NewHome := {NewPop H}
               {DistributeGeneration T GivenToMales (GivenToFemales+1)}
            else
               % Give it to the males
               NewHome = {GetListMember Population_Male GivenToMales $}
             in
               NewHome := {NewPop H}
               {DistributeGeneration T (GivenToMales+1) GivenToFemales}
            end
         else skip end
      end
      
      NewGeneration
    in
      {SaveInformation {VirtualString.toAtom 'generations/gen'#@CurrentGeneration}}
      CurrentGeneration := @CurrentGeneration + 1
      NewGeneration = {Shuffle {MakeNewGeneration (Const_IndividualsPerSex - 1) (Const_NumOffspringProduced * 2) nil $}}
      {MoveFemales 0} % "Kills" the oldests 1/8 of the females
      {DistributeGeneration NewGeneration 0 0}
   end
   
   % JumpForward is used to skip repeated challenges. 
   % e.g. From [A B] A beats B, making the list [B A]
   %   Next generation, B wants to challenge A, which is useless.
   proc {JumpForward}
      if (@ChallengerID \= (Const_IndividualsPerSex - 1)) then
         NewBlack = @{GetListMember Population_Male @ChallengerID}
         NewWhite = @{GetListMember Population_Male (@ChallengerID+1)}
         HavePlayed = {PopsHavePlayed NewBlack NewWhite $}
       in
         if {Or (NewBlack.generation < NewWhite.generation) HavePlayed} then
            ChallengerID := @ChallengerID + 1
            {JumpForward}
         else skip end
      end
   end
   
   %% GUI %%
   proc {GUI_BrowseKing}
      {Browser.browse @{GetListMember Population_Male (Const_IndividualsPerSex - 1)}}
   end
   
   proc {GUI_BrowseBlack}
      skip
   end
   
   proc {GUI_BrowseWhite}
      skip
   end
   
   %% Callbacks %%
   proc {Callback_SetupGame BlackTalker WhiteTalker}
      BlackPop
      WhitePop
    in
      if (@ChallengerID == (Const_IndividualsPerSex - 1)) then
         % Everyone has challenged the next in line. 
         
         GenerationRound := @GenerationRound + 1
         if (@GenerationRound == Const_RoundsPerGeneration) then
            proc {CleanupPlayLists Lst}
               proc {GetRealList Lst CList ?R}
                  proc {LstContains ConLst A ?R3}
                     case ConLst 
                     of Head|Tail then
                        if (Head == A) then
                           R3 = true
                        else
                           {LstContains Tail A R3}
                        end
                     else
                        R3 = false
                     end
                  end
                in
                  case Lst 
                  of Head|Tail then
                     if {LstContains CList Head} then
                        R = Head|{GetRealList Tail CList $}
                     else
                        {GetRealList Tail CList R}
                     end
                  else
                     R = nil
                  end
               end
               
               proc {GetAlivePopulation ALst ?R}
                  case ALst
                  of Head|Tail then
                     R = (@Head).id|{GetAlivePopulation Tail $}
                  else
                     R = nil
                  end
               end
               
               AlivePop = {GetAlivePopulation Lst $}
             in
               case Lst 
               of Head|Tail then
                  (@Head.playList) := {GetRealList (@Head).playList AlivePop}
                  {CleanupPlayLists Tail}
               else skip end
            end
          in
            {ConductReproduction}
            GenerationRound := 0
            
            % Cleanup played list on males
            {CleanupPlayLists Population_Male}
         else
            {JumpForward}
         end
         
         ChallengerID := 0
      end
      
      BlackPop = @{GetListMember Population_Male @ChallengerID}
      WhitePop = @{GetListMember Population_Male (@ChallengerID+1)}
      
      CurrentGame := @CurrentGame + 1
      
      {ApplyGenome BlackTalker BlackPop.genome}
      {ApplyGenome WhiteTalker WhitePop.genome}
      
      {GeneticGUI setupGameLabel(@CurrentGame @CurrentGeneration (@GenerationRound+1) @ChallengeScore_B @ChallengeScore_W)}
      {GeneticGUI setupBlackLabel((Const_IndividualsPerSex - @ChallengerID) BlackPop.id BlackPop.generation)}
      {GeneticGUI setupWhiteLabel((Const_IndividualsPerSex - @ChallengerID - 1) WhitePop.id WhitePop.generation)}
   end
   
   proc {Callback_Results WhoWon NumMoves ?PlayAgain}
      GamesLeft = Const_MaxGamesPerChallenge - (@ChallengeScore_B + @ChallengeScore_W + 1)
      ChallengeIsOver
    in
      if (WhoWon == black) then
         ChallengeScore_B := @ChallengeScore_B + 1
      elseif (WhoWon == white) then
         ChallengeScore_W := @ChallengeScore_W + 1
      end
      
      if ({Abs (@ChallengeScore_B - @ChallengeScore_W)} == 2) then
         % Our challenge is over. We have a winner
         BlackPopSlot = {GetListMember Population_Male @ChallengerID}
         BlackPop = @BlackPopSlot
         WhitePopSlot = {GetListMember Population_Male (@ChallengerID+1)}
         WhitePop = @WhitePopSlot
       in
         if (@ChallengeScore_B > @ChallengeScore_W) then
            BlackPopSlot := WhitePop
            WhitePopSlot := BlackPop
         end
         
         % Add them to eachother's played list so we don't play again.
         (WhitePop.playList) := (BlackPop.id)|(@(WhitePop.playList))
         (BlackPop.playList) := (WhitePop.id)|(@(BlackPop.playList))
         
         ChallengeIsOver = true
      elseif ((@ChallengeScore_B + @ChallengeScore_W) == Const_MaxGamesPerChallenge) then
         % Challenge is over; no winner. Irradiate the lesser.
         BlackPopSlot = {GetListMember Population_Male @ChallengerID}
       in
         ChallengeIsOver = true
         
         BlackPopSlot := {NewPop {RandomGenome}}
      elseif {And ({Abs ((@ChallengeScore_B + GamesLeft) - @ChallengeScore_W)} < 2) ({Abs (@ChallengeScore_B - (@ChallengeScore_W + GamesLeft))} < 2)} then
         % Challenge can't possibly have a winner; end early. Irradiate the lesser.
         BlackPopSlot = {GetListMember Population_Male @ChallengerID}
       in
         ChallengeIsOver = true
         
         BlackPopSlot := {NewPop {RandomGenome}}     
      else
         ChallengeIsOver = false
      end
   
      if (ChallengeIsOver) then
         ChallengeScore_B := 0
         ChallengeScore_W := 0
         ChallengerID := @ChallengerID + 1
         {JumpForward}
      end
   
      PlayAgain = true
      {GeneticGUI reset()}
      {SaveInformation Const_SaveFile}
   end
   
   proc {Callback_Move R C Color}
      NewTime = {OS.time}
      TimeSinceGameStart = (NewTime - (@Const_SessionStart))
      RealTimeElapsed = @TotalTimeElapsed + TimeSinceGameStart
    in
      {GeneticGUI put(R C Color)}
      {GeneticGUI setupTimeLabel(RealTimeElapsed @CurrentGame TimeSinceGameStart)}
   end
   
   CallbackInfo = geneticCallback(newGame:Callback_SetupGame results:Callback_Results onMove:Callback_Move hideGenetic:false)
 in
   {OS.srand 0} % Seeds random to os time
   
   % Setup
   {InitializeGUI}
   {LoadInformation}
   
   % GO Setup
   {Initiator.run Brain.brain Brain.brain 9 nil false CallbackInfo}
end

