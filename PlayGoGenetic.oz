functor 
import Initiator Brain Player Browser Pickle

define

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

   proc {LoadInformation ?AIGenome}
      try
         proc {GetTail Lst ?R}
            case Lst
            of Head|nil then
               R = Head
            [] Head|Tail then
               {GetTail Tail R}
            else skip end
         end
         
         LoadRecord = {Pickle.load 'generations/current'}
       in
         AIGenome = {GetTail LoadRecord.pop_male}
      catch _ then
         {Browser.browse 'Could not load genome data.'}
      end
   end
   
   proc {Callback_SetupGame BlackTalker WhiteTalker}
      {ApplyGenome WhiteTalker {LoadInformation $}.genome}
   end
   
   proc {Callback_Move R C Color}
      skip
   end
   
   proc {Callback_Results WhoWon NumMoves ?PlayAgain}
      PlayAgain = false
   end
   
   CallbackInfo = geneticCallback(newGame:Callback_SetupGame results:Callback_Results onMove:Callback_Move hideGenetic:true)
in

   {Initiator.run Player.player Brain.brain 9 nil false CallbackInfo}

end
