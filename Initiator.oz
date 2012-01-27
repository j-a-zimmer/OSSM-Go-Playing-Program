% Initiator  -- create players, set up communication between them, 
%            -- and start server

functor
   import Server Talker Browser OS
   export Run

define
   proc {Run Player1Type Player2Type Size Handicap DebugMode EndGameSendRes}
      Player1 = {New Player1Type init()}
      Player2 = {New Player2Type init()}
      
      Talkers = op(
                    0:{New Talker.talker init(Player1)} 
                    1:{New Talker.talker init(Player2)}
                  )
    in
      {OS.srand 0}
      {Server.start Size Handicap Talkers DebugMode EndGameSendRes}
   end
end

