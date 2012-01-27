functor

   import GuiBoard PlayBoard
   export Player
   
define

class Player
      
   feat size gBoard pBoard talker human
   attr Turn MoveStreamTail Color
      
   meth init()
      MoveStreamTail := nil|_
      self.human = true
   end
   
   meth introduceTalker(Talker)
      self.talker = Talker
   end
   
   meth clearBoard()
      if {IsDet self.pBoard} then
         {self.pBoard reset(_)}
      end
      
      if {IsDet self.gBoard} then
         {self.gBoard reset()}
      end
      
      {self.gBoard startCelebrate(false)}
   end
   
   meth celebrate()
      {self.gBoard startCelebrate(true)}
      thread {self.gBoard celebrate()} end
   end
   
   meth setupBoard(Size)
      proc {LClickProc R C}
         Played
      in
         if @Turn==true then
            {self.pBoard play(R C @Color Played)}
            if Played then 
               (@MoveStreamTail).2 = (R#C#@Color)|_
               Turn:=false
            end
         end
      end

      proc {PassProc}
         if @Turn==true then
            @MoveStreamTail.2 = pass|_
            Turn:=false
         end
      end
   
      proc {GuiPutAction R C V}
         {self.gBoard put(R C V)}
      end
    in
      self.size = Size
      
      self.gBoard = 
             {New GuiBoard.gBoard init(
                             self
                             self.size 
                             34.0 
                             LClickProc 
                             proc{$ R C} skip end 
                             PassProc)      }
      
      self.pBoard = {New PlayBoard.pBoard init(Size nil _)}
      {self.pBoard setPutAction(GuiPutAction)}
   end
   
   meth receivedMove(Move)
      {self.pBoard play(Move.1 Move.2 Move.3)}
   end
	   
   meth decide(DColor ?Move)
      Color := DColor
	   Turn := true
	   {Wait @MoveStreamTail.2}
	   Move = @MoveStreamTail.2.1
      MoveStreamTail := @MoveStreamTail.2
   end
      
end

end
