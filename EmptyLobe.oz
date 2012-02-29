functor
   import Browser PlayBoard
   export Lobe
define
   class Lobe
   
      % This is the general lobe class that all lobes need to extend
	  % The only method of this that should be extended is formulateWeights.
	  % This file also provides a universal lookAhead method that should not
	  %   be extended.
	  %
	  % A lobe is initialized and then spends its entire life in the cycle:
	  %       ___________          ___________         ________         _______________________
	  %      |           |        |  wait for |       | clear  |       |     Work some on      |
	  %      |initialized|  ====> |   update  | ====> | values | ====> |  Formulating Weights  | => \
	  %      |___________|        |___________|       |________|       |_______________________|   ||
	  %                                  /\               /\                     ||        /\      ||
	  %                                  ||               ||              _______\/____    ||      ||
	  %                                  ||               ||             |  Is there   |   No      \/
	  %                                  /\               \ <=== Yes <== |  an update? | => /      ||
	  %                                  ||                              |_____________|           ||
	  %                                  ||                                                        ||
	  %                                  \ <==== <==== <==== <==== <==== <==== <==== <==== <==== <= /
	  %
	  %                                              A Beautiful Diagram by Ben
	  %
	  % At any point durin this cycle the brain may come in and read values and/or give an update to
	  %  to the lobe. It is update to each lobe to decide whether to commit each value as soon as
	  %  as possible, or doing them all at once.
	  %
	  % If a child lobe is going to have some form of global memory, it needs to be setup in a way
	  %   that it is set at the start of formulateWeights because it may end prematurally if an
	  %   update arrives.
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
         catch error(thereIsAnUpdate) then 
		    skip 
         end
		 {self run}
	  end
	  
	  meth waitForUpdate
	     {Wait @Update}
		 Values := nil
		 Col := (@Update).color
	     Board := {New PlayBoard.pBoard init((@Update).state.size (@Update).state.initialStones (@Update).state)}
		 Update := _
	  end
	  
	  meth formulateWeights
	     %
	     % FormulateWeights is the only method that should be extended by child classes (lobes)
		 % This method needs to set the cell Values to whatever rankings the lobe gives.
		 %
		 % Preconditions:
		 %      -Values is set to nil
		 %      -Board is the board that rankings should be based on
		 %
		 % Postconditions:
		 %      -Values is set to the list of rankings
		 %            -it can be set as it this executes or at completetion
		 %            -There is no guarnantee on when the brain will ask for values. If they aren't
		 %              there or it is partial done, it will take the current value of Values.
		 %      -Leave Board in whatever condition you want, it will be wiped when an update comes
		 %
	     % Other stuff:
		 %      -This needs to always be in a state that problems will not be caused if its execution
		 %         is stopped by an external thread. This will happen when the lobe recieves an update
		 %         because it needs to start formulating weights for the new board and abandon the old
		 %         one.
		 
	     Values := nil   %it is already nil but I needed to put some body in this method
	  end
	  
	  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	  %% methods for use by the brain %%
	  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	  
	  meth getValues(Ret)
	     Ret = @Values
	  end
	  
	  meth update(TheUpdate)
	     % TheUpdate should be of the form:   someRecord(color:TheColorToRankFor  state:TheState)
		 {Thread.terminate @WorkingThread}
		 WorkingThread := _
		 Update := TheUpdate
	  end
	  
	  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	  %%Extras for child classes to use%%
	  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	  
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