functor
   import Browser PlayBoard System
   export Lobe
define
   class Lobe
	  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	  %  What this file contains  %
	  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	  % This is the generic Lobe class that all other lobes should extend.
	  %
	  % Methods that are part of the lobes life cycle:
	  %    run              -- outer shell of life cycle, runs forever
	  %    waitForUpdate    -- Holds execution until Update is set to a value then clears atrributes/updates Board
	  %    formulateWeights -- The actual work that a lobe does, a thread is made to run this that may be terminated
	  %                           if an update comes before this finishes executing.
	  % Methods for use by the brain:
	  %    getValues  -- getter for values
	  %    update     -- updates board and then clears the update cell
	  %
	  % Methods for use by subclasses:
	  %    lookAhead  -- plays a piece on the board, evaluates the board with some function and then resets to previous Board state
	  %    getBoard, getCol, setValues, getValues*
	  %
	  %                    *this was already listed as a method for the brain
	  %
	  %
	  %%%%%%%%%%%%%%%%%%%%%
	  %   How Lobes work  %
	  %%%%%%%%%%%%%%%%%%%%%
	  % A lobe is initialized and then spends its entire life in this cycle:
	  %       ___________          ___________         ________         ______________          ________________________
	  %      |           |        |  wait for |       | clear  |       |  Split into  |        |  Wait for update then  |
	  %      |initialized|  ====> |   update  | ====> | values | ====> |  Two Threads |  ====> |   kill other thread    |
	  %      |___________|        |___________|       |________|       |______________|        | if it didn't terminate |
	  %                                                   /\                   |               |________________________|
	  %                                                   |                    |                           |
	  %                                                   |               _____\/____                      \/
	  %                                                   |              | Formulate |                     |
	  %                                                   /\             |  Weights  |                     |
	  %                                                   |              |___________|                     \/
	  %                                                   |                                                |
	  %                                                   \ <==== <==== <==== <==== <==== <==== <==== <==== / 
	  %                                                                                                    
	  %
	  %                                              A Beautiful Diagram by Ben
	  %
	  % At any point durin this cycle the brain may come in and read values and/or give an update to
	  %  to the lobe. It is update to each lobe to decide whether to commit each value as soon as
	  %  as possible, or doing them all at once.
	  %
	  
	  
	  attr Board 
           Col
		   Values
		   Update
		   WorkingThread
		   
      meth init()
         thread {self run} end
      end
	  
	  meth run
	     {self waitForUpdate}
		 try
            thread	
			   WorkingThread := {Thread.this}
			   {self formulateWeights} 
            end
		 catch A then {System.show caughtErrorInEmptyLobe#A} 
		 finally {self run} end
	  end
	  
	  meth waitForUpdate
	     Upd = @Update
	  in
		 %Should wait here until @Update, namely Upd, is determined
		 {Wait Upd}
		 if {IsDet @WorkingThread} andthen {Thread.state @WorkingThread}\=terminated then {Thread.terminate @WorkingThread} end
		 WorkingThread := _
	     Board := {New PlayBoard.pBoard init(Upd.state.size Upd.state.initialStones Upd.state)}
		 Values := nil
		 Col := Upd.color
		 Update := _
	  end
	  
	  meth formulateWeights
	     %
	     % FormulateWeights is the only method that should be extended by child classes (lobes)
		 % This method needs to set the cell Values to whatever rankings the lobe gives.
		 %
		 % Preconditions:
		 %      -@Values is set to nil
		 %      -@Board is the board that rankings should be based on
		 %
		 % Postconditions:
		 %      -@Values is set to the list of rankings
		 %            -it can be set as it this executes or at completetion
		 %            -There is no guarnantee on when the brain will ask for values. If they aren't
		 %              there or it is partial done, it will take the current value of Values.
		 %      -Leave Board in whatever condition you want, it will be wiped when an update comes
		 %
	     % Other stuff:
		 %      -This needs to always be in a state that problems will not be caused if its execution
		 %         is stopped by an external thread. This will happen when the lobe recieves an update
		 %         before this finishes executing. Once we recieve an update, we dont care about the
		 %         result of this method.
		 
	     Values := nil   %it is already nil but I wanted to put some body in this method
	  end
	  
	  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	  %% methods for use by the brain %%
	  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	  
	  meth getValues(Ret)
	     R = @Values
	  in
	     if {IsDet R} then
		    Ret = R
		 else
		    {System.show self}
		    Ret = nil
		 end
	  end
	  
	  meth update(TheUpdate)
	     % TheUpdate should be of the form:   someRecord(color:TheColorToRankFor  state:TheState)
		 @Update = TheUpdate
		 Update := _ %This doesn;t ruin the data that it just put in this record because that lobe stores the
		             %  contents of the cell and waits for that, ':=' doesn't effect the content so the lobe
					 %  still have the update, this just prepares it to wait for the next one.
	  end
	  
	  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	  %%Extras for child classes to use%%
	  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	  meth getBoard(B)
	     B = @Board
	  end
	  meth getCol(C)
	     C = @Col
	  end
	  meth setValues(V)
	     Values := V
	  end
	  meth lookAhead(R C Fun Result)
	     State
	  in
		 State = {(@Board) getState($)}
         {(@Board) play(R C (@Col))}
         Result = {Fun R C (@Col) (@Board)}
		 Board := {New PlayBoard.pBoard init(State.size State.initialStones State)}
	  end
	  
   end
end