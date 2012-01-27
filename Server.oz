functor

import PlayBoard Browser TalkerTools Territory System JAZTools Pickle 
      QTk at 'x-oz://system/wp/QTk.ozf'
      Open at 'x-oz://system/Open.ozf'
      
      

export Start
define
   %%
   %% Oddities: The Player does not respect the Color arguments of GenMove
   %%

   Board Talkers Colors GeneticCallback
    
   LastStarted = {NewCell 1}
   
   Passes = {NewCell 0}
   WhoseTurn = {NewCell 1}
   ExpectedResponses = {NewCell nil}
   CurResponseNum = {NewCell 0}
   GameEnded = {NewCell false}
   
   CommandResponses = [
                        "protocol_version"#GetResponse_ProtocolVersion
                        "name"#GetResponse_Name
                        "version"#GetResponse_Version
                        "known_command"#GetResponse_KnownCommand
                        "list_commands"#GetResponse_ListCommands
                        "fixed_handicap"#GetResponse_FixedHandicap
                        "place_free_handicap"#GetResponse_PlaceFreeHandicap
                        "genmove"#GetResponse_GenMove
                      ]
   IncomingCommands = [
                        "new_game"#GetCommand_NewGame
                        "load_game"#GetCommand_LoadGame
                        "save_game"#GetCommand_SaveGame
                      ]
   
   % These commands are from the "Go Text Protocol", cf.
   %    http://www.lysator.liu.se/~gunnar/gtp/gtp2-spec-draft2/gtp2-spec.html
   % Server is the client side of this protocol; otherwise see Talker.oz.
   
   DebugMode
   
   fun {GetFileName Text}
      Ret
      Entry
      InputBox = entry(init:"saves/filename.sav"
                      handle:Entry
                      action: proc {$} skip end
                      width: 25)
       Continue = button(text: Text
                        action: proc {$} Ret = {Entry get($)} end)
       Cancel = button(text: 'Cancel'
                        action: proc {$} Ret = cancel end)
      Window = {QTk.build td(InputBox lr(Continue Cancel))}
    in
      {Window show}
      {Wait Ret}
      {Window close}
      Ret
   end
   
   proc {Start Size Handicap InTalkers DebugM EndGameSendRes}
      GeneticCallback = EndGameSendRes
      DebugMode = DebugM
      Board = {New PlayBoard.pBoard init(Size nil _)} % HANDICAP IS ALWAYS 
                   % 0 TEMPORARILY - NEED TO CHANGE ALL BOARD CONSTRUCTORS
      
      Talkers = InTalkers
      
      {Talkers.0 setController(GetResponse)} % will eventually be replaced 
      {Talkers.1 setController(GetResponse)} % will eventually be replaced 
                                                           % with sockets.
      
      if (GeneticCallback \= nil) andthen (GeneticCallback.hideGenetic == false) then
         {SendCommand Talkers.0 "genetic" "0"}
         {SendCommand Talkers.1 "genetic" "1"}
      end
      
      {SendCommand Talkers.0 "boardsize" {Int.toString Size}}
      {SendCommand Talkers.1 "boardsize" {Int.toString Size}}
      Colors = op(0:black 1:white)
      
      if (GeneticCallback \= nil) then
         proc {CallbackGuiPutAction R C V}
            {GeneticCallback.onMove R C V}
         end
       in
         {GeneticCallback.newGame Talkers.0 Talkers.1}
         {Board setPutAction(CallbackGuiPutAction)}
      end
      
      {AskForMove}
   end
   
   proc {AskForMove}
      WhoseTurn := (@WhoseTurn + 1) mod 2
      
      if DebugMode then
         {SendCommand Talkers.0 "genmove" {Atom.toString Colors.@WhoseTurn}}
      else
         {SendCommand Talkers.@WhoseTurn "genmove" 
               { Atom.toString Colors.@WhoseTurn}}
      end
   end
   
   proc {SendCommand ToWho Command ArgumentString}
      proc {RequiresResponse Table ?R}
         case Table
         of (CommandString#CommandProc)|Tail then
            if (Command == CommandString) then
               R = true
            else
               {RequiresResponse Tail R}
            end
         else R = false end
      end
      
      SendCommand
    in
      % will eventually be replaced with sockets
      if {RequiresResponse CommandResponses $} then
         CurResponseNum := @CurResponseNum + 1
         
         ExpectedResponses := (@CurResponseNum#Command)|@ExpectedResponses
         SendCommand = 
            {VirtualString.toString 
               @CurResponseNum#" "#Command#" "#ArgumentString#"\n"}
      else
         SendCommand = 
            {VirtualString.toString Command#" "#ArgumentString#"\n"}
      end
      
      {ToWho receiveCommand(SendCommand)}
   end
   
   proc {GetResponse Response}
      proc {ExplodeString CurString CurBuffer CurTable ?ReturnTable}
         case CurString
         of nil then
            ReturnTable = {Reverse CurTable} % Buffer should be nil 
                            % because Response is terminated by &\n
         [] Head|Tail then
            if {Or (Head == & ) (Head == &\n)} then
               {ExplodeString Tail "" {Reverse CurBuffer}|CurTable 
                                                      ReturnTable}
            else
               {ExplodeString Tail Head|CurBuffer CurTable ReturnTable}
            end
         end
      end
      
      proc {FindExpectedCommand Table ID ReconstructedTable ?C}
         case Table
         of (ExpectedID#ExpectedCommand)|Tail then
            if {And {Not {IsDet C}} (ID == ExpectedID)} then
               C = ExpectedCommand
               {FindExpectedCommand Tail ID ReconstructedTable C}
            else
               {FindExpectedCommand 
                   Tail 
                   ID 
                   (ExpectedID#ExpectedCommand)|ReconstructedTable C }
            end
         else 
            if {Not {IsDet C}} then  C = false  end
            ExpectedResponses := ReconstructedTable
         end
      end
      
      proc {GetCommandProc Command Table ?R}
         case Table
         of (CommandString#CommandVariable)|Tail then
            if (CommandString == Command) then
               R = CommandVariable
            else
               {GetCommandProc Command Tail R}
            end
         else R = false end
      end
      
      ExplodedCommand = {ExplodeString Response.2 "" nil $}
      CommandID 
    in
      try
         CommandID = {String.toInt ExplodedCommand.1}
      catch E then
         CommandID = ~1
      end
      
      if (CommandID == ~1) then
         CommandProc = {GetCommandProc ExplodedCommand.1 IncomingCommands $}
       in
         if (CommandProc == false) then
            {Browser.browse 
               {VirtualString.toAtom 
                  'WARNING: Cannot handle processing of command "'#
                                           ExplodedCommand.1#'".'}}
         else
            {CommandProc}
         end
      else
         ExpectedCommand = 
            {FindExpectedCommand @ExpectedResponses CommandID nil $}
       in
         if (ExpectedCommand == false) then
            {Browser.browse 
               {VirtualString.toAtom 
                  'WARNING: Got an unexpected response(ID#'#CommandID#').'}}
         else
            CommandProc = {GetCommandProc ExpectedCommand CommandResponses $}
          in
            if (CommandProc == false) then
               {Browser.browse 
                  {VirtualString.toAtom 
                     'WARNING: Cannot handle response of command "'#
                                              ExpectedCommand#'".'}}
            else
               {CommandProc ExplodedCommand.2}
            end
         end
      end
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%% Received Responses %%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   proc {GetResponse_ProtocolVersion Arguments}
      skip
   end
   
   proc {GetResponse_Name Arguments}
      skip
   end
   
   proc {GetResponse_Version Arguments}
      skip
   end

   proc {GetResponse_KnownCommand Arguments}
      skip
   end
   
   proc {GetResponse_ListCommands Arguments}
      skip
   end
   
   proc {GetResponse_FixedHandicap Arguments}
      skip
   end
   
   proc {GetResponse_PlaceFreeHandicap Arguments}
      skip
   end
   
   proc {GetResponse_GenMove Arguments}
      TrueMove
    in
      if (Arguments.1 == "pass") then
         Passes := @Passes + 1
         
         if (@Passes == 2) then
            Scores = {Territory.getScore Board $}
            WhoWon
          in               
            if (Scores.1 > Scores.2) then
               WhoWon = black
            elseif (Scores.2 > Scores.1) then
               WhoWon = white
            else
               WhoWon = draw
            end
            
            WhoseTurn := 1
            GameEnded := true
            
            if (GeneticCallback \= nil) then
               if {GeneticCallback.results WhoWon {Board numStones($)} $} then
                  {GetCommand_NewGame}
               end
            else
               {Browser.browse 
                  {VirtualString.toAtom 
                     'Score: White '#Scores.2#' | Black '#Scores.1}}
               
               if (WhoWon == black) then
                  {Browser.browse 'Black Wins'}
               elseif (WhoWon == white) then
                  {Browser.browse 'White Wins'}
               else
                  {Browser.browse 'Draw'}
               end
               
               {SendCommand Talkers.1 "celebrate" ""}
               {SendCommand Talkers.0 "celebrate" ""}
            end
         else {AskForMove} end
      else
         Passes := 0
      
         TrueMove = {TalkerTools.coordinatesToMove Arguments.1 Arguments.2.1 $}
         
         if (DebugMode) then
            {SendCommand 
                   Talkers.1 
                   "play" 
                   {VirtualString.toString Arguments.1#" "#Arguments.2.1}}
         else
            if (Colors.0 == TrueMove.3) then
               {SendCommand 
                  Talkers.1 
                  "play" 
                  {VirtualString.toString Arguments.1#" "#Arguments.2.1}}
             else
               {SendCommand 
                  Talkers.0 
                  "play" 
                  {VirtualString.toString Arguments.1#" "#Arguments.2.1}}
            end
         end
         
         {Board play(TrueMove.1 TrueMove.2 TrueMove.3)}
         
         {AskForMove}
      end
   end
   
   proc {GetCommand_SaveGame}
      FileName = {GetFileName 'Save'}
    in
      if (FileName \= cancel) then
         {Pickle.save {Board history($)} FileName}
      end
   end
   
   proc {GetCommand_LoadGame}
      FileName = {GetFileName 'Load'}
    in
      if (FileName \= cancel) then
         LoadInfo = {Pickle.load FileName}
         
         proc {ProcessLoadInfo LoadList}
            case LoadList
            of (R#C#NewColor#OldColor)|Tail then
               Command = 
                  {VirtualString.toString 
                     ((TalkerTools.coordinatesAlpha).R)#C#' '#
                        {TalkerTools.getColorString NewColor}}
             in
               {SendCommand Talkers.0 "play" Command}
               {SendCommand Talkers.1 "play" Command}
               {Board put(R C NewColor)}
               {ProcessLoadInfo Tail}
            else skip end
         end
       in
         {Board reset(_)}
         {SendCommand Talkers.0 "clear_board" ""}
         {SendCommand Talkers.1 "clear_board" ""}
         {ProcessLoadInfo {Reverse LoadInfo}}
         {Territory.getScore Board _}
      end
   end
   
   proc {GetCommand_NewGame}
      {Board clearHistory(nil)}
      {Board reset(_)}
      {SendCommand Talkers.0 "clear_board" ""}
      {SendCommand Talkers.1 "clear_board" ""}
      
      if (GeneticCallback \= nil) andthen (GeneticCallback.hideGenetic == false) then
         LastStarted := (@LastStarted + 1) mod 2
      
         WhoseTurn := @LastStarted
      
         {GeneticCallback.newGame Talkers.0 Talkers.1}
      end
      
      if (@GameEnded == true) then
         GameEnded := false
         {AskForMove}
      end
   end
end
