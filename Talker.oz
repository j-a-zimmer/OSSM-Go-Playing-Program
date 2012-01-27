functor
   import Browser TalkerTools
   export Talker
define
   TalkerVersion = "1.0.0"
   KnownCommands = [
                     "protocol_version"#gCommand_ProtocolVersion
                     "name"#gCommand_Name
                     "version"#gCommand_Version
                     "known_command"#gCommand_KnownCommand
                     "list_commands"#gCommand_ListCommands
                     "quit"#gCommand_Quit
                     "boardsize"#gCommand_BoardSize
                     "clear_board"#gCommand_ClearBoard
                     "komi"#gCommand_Komi
                     "play"#gCommand_Play
                     "genmove"#gCommand_GenMove
                     "genetic"#gCommand_Genetic
                     "celebrate"#gCommand_Celebrate
                   ]
  
   % These commands are from the "Go Text Protocol", cf.
   %    http://www.lysator.liu.se/~gunnar/gtp/gtp2-spec-draft2/gtp2-spec.html
   % Talker is a client, the corresponding server is in Server.oz
      
   class Talker
      feat talkingTo controller procLock
      attr ProcessingQueue CommandStream
      
      meth init(TalkingTo)
         self.talkingTo = TalkingTo
         {TalkingTo introduceTalker(self)}
         
         thread {self processQueue()} end
         
         ProcessingQueue := false
         self.procLock = {NewLock}
         
         CommandStream := nil|_
      end
      
      meth setController(What)
         self.controller = What
      end
      
      meth processQueue()        
         proc {FindCommandAtom CommandString Table ?R}
            case Table
            of (TestCommandString#TestCommandAtom)|Tail then
               if (CommandString == TestCommandString) then
                  R = TestCommandAtom
               else
                  {FindCommandAtom CommandString Tail R}
               end
            else
               {Browser.browse             {VirtualString.toAtom 
                  'WARNING: Could not find command atom for "' #
                                                 CommandString #
                                                          '".'}}
               R = false
            end
         end
         
         NextCommand NextCommandAtom 
       in
         {Wait @CommandStream.2}
         
         lock (self.procLock) then
            NextCommand = @CommandStream.2.1
            CommandStream := @CommandStream.2
         end
         
         NextCommandAtom = {FindCommandAtom NextCommand.2 KnownCommands $}
         
         if (NextCommandAtom \= false) then
            Response
          in
            if {And (NextCommandAtom == gCommand_GenMove) 
                                  (self.talkingTo.human)} 
            then
               thread
                  Response = {self NextCommandAtom(NextCommand.3 $)}
                     
                  if {IsDet Response} then
                     {self sendResponse(NextCommand.1 Response.1 Response.2.1)}
                  end
               end
            else
               Response = {self NextCommandAtom(NextCommand.3 $)}
                  
               if {IsDet Response} then
                  {self sendResponse(NextCommand.1 Response.1 Response.2.1)}
               end
            end
         end
         
         {self processQueue()}
      end
      
      meth sendCommand(Command)
         {self.controller {VirtualString.toString Command#"\n"}}
      end
      
      meth sendResponse(ID ResponseStatus ResponseString) 
                   % All of these needs to be socketified
         if (ID == ~1) then
            {self.controller      {VirtualString.toString 
                     ResponseStatus#ResponseString#"\n"}}
         else
            {self.controller      {VirtualString.toString 
              ResponseStatus#ID#" "#ResponseString#"\n"}}
         end
      end
      
      meth receiveCommand(CommandString)      
         proc {ExplodeString CurString CurBuffer CurTable ?ReturnTable}
            case CurString
            of nil then
               ReturnTable = {Reverse CurTable} % Buffer should be nil because 
                                          % CommandString is terminated by &\n
            [] Head|Tail then
               if {Or (Head == & ) (Head == &\n)} then
                  { ExplodeString 
                      Tail 
                      "" 
                      {Reverse CurBuffer}|CurTable 
                      ReturnTable                  }
               else
                  { ExplodeString 
                      Tail 
                      Head|CurBuffer 
                      CurTable 
                      ReturnTable       }
               end
            end
         end
         
         proc {PutCommandToStream Array Cmd}
            case Array of Head|Tail then
               if {IsDet Tail} then
                  {PutCommandToStream Tail Cmd}
               else
                  Array.2 = Cmd|_
               end
            else 
               {Browser.browse "WARNING: Could not put command in stream."}
            end
         end
         
         ExplodedCommand = {ExplodeString CommandString "" nil $}
         CommandID CommandStart
       in
         try
            CommandID = {String.toInt ExplodedCommand.1}
            CommandStart = ExplodedCommand.2
         catch E then
            CommandID = ~1
            CommandStart = ExplodedCommand
         end
         
         lock (self.procLock) then
            {PutCommandToStream 
                @CommandStream CommandID#CommandStart.1#CommandStart.2}
         end
      end
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %%%%%%%%%% Received Commands %%%%%%%%%%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
      meth gCommand_ProtocolVersion(Arguments ?Response)
         Response = ['=' "2"]
      end
      
      meth gCommand_Name(Arguments ?Response) % Arguments: none
         Response = ['=' "JAZ"]
      end
      
      meth gCommand_Version(Arguments ?Response) % Arguments: none
         Response = ['=' TalkerVersion]
      end
      
      meth gCommand_KnownCommand(Arguments ?Response) % Arguments: CommandName
         proc {KnownCommandRecurse List}
            case List
            of (StringCommand#AtomCommand)|Tail then
               if (StringCommand == Arguments.1) then
                  Response = ['=' "true"]
               else
                  {KnownCommandRecurse Tail}
               end
            else Response = ['=' "false"] end
         end
       in
         {KnownCommandRecurse KnownCommands}
      end
      
      meth gCommand_ListCommands(Arguments ?Response) % Arguments: none
         proc {ListCommandsRecurse List CurString}
            case List
            of (StringCommand#AtomCommand)|Tail then
               {ListCommandsRecurse 
                    Tail 
                    {VirtualString.toString StringCommand#"\n"#CurString}  }
            else Response = ['=' CurString] end
         end
       in
         {ListCommandsRecurse KnownCommands ""}
      end
      
      meth gCommand_Quit(Arguments ?Response) % Arguments: none
         skip
      end
      
      meth gCommand_BoardSize(Arguments ?Response) % Arguments: Size
         {self.talkingTo setupBoard({String.toInt Arguments.1})}
      end
      
      meth gCommand_ClearBoard(Arguments ?Response) % Arguments: none
         {self.talkingTo clearBoard}
      end
      
      meth gCommand_Komi(Arguments ?Response) % Arguments: NewKomi
         skip
      end
      
      meth gCommand_Play(Arguments ?Response) % Arguments: Move
         TrueMove = {TalkerTools.coordinatesToMove Arguments.1 Arguments.2.1 $}
       in
         {self.talkingTo receivedMove(TrueMove)}
      end
      
      meth gCommand_GenMove(Arguments ?Response) % Arguements: Color
         DecidedMove Color

         proc {MakeResponse VS}
            Response = [ '=' {VirtualString.toString VS} ]
         end
       in
         DecidedMove = 
            { self.talkingTo 
                decide({TalkerTools.getColorAtom Arguments.1} $) }
         
         if (DecidedMove == pass) then
            {MakeResponse DecidedMove#' '#Arguments.1}
         else
            {MakeResponse (TalkerTools.coordinatesAlpha.(DecidedMove.1))#
                                                         (DecidedMove.2)#
                                                                     ' '#
                                                             Arguments.1}
         end
      end
      
      meth gCommand_FixedHandicap(Arguments ?Response) 
                           % Arguments: NumberOfStones
         skip
      end
      
      meth gCommand_PlaceFreeHandicap(Arguments ?Response) 
                               % Arguments: NumberOfStones
         skip
      end
      
      meth gCommand_SetFreeHandicap(Vertices ?Response)
         skip
      end
      
      meth gCommand_Genetic(Arguments ?Response)
         {self.talkingTo initializeGenetic(Arguments.1)}
      end
      
      meth gCommand_Celebrate(Arguments ?Response)
         if (self.talkingTo.human) then
            {self.talkingTo celebrate()}
         end
      end
   end
end
