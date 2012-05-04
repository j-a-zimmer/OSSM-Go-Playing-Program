functor

   import Browser JAZTools Set System
export immortal:Immortal convert:Convert equivalent:Equivalent
equal:Equal list2Stones:List2Stones Defend Attack lookAhead:LookAhead
hasTwoEyes:HasTwoEyes isEye:IsEye

define

   %% ---
   %% This section is devoted to immortal clusters.
   %% ---
   
   %% HasTwoEyes must be applied on a String Cluster.
   proc {HasTwoEyes Board Cluster ?Ret}
      Eyes = {GetEyes Board Cluster $}
   in
      Ret = ({List.length Eyes $}>=2)
   end

   %% 
   proc {HasLargeEye Board Cluster ?Ret}
      Eyes = {GetEyes Board Cluster $}
   in
      if {List.length Eyes $}==1 then
         if Eyes.1 == nil then Ret = false
         else  
            Ret = ({List.length Eyes.1.stones $}>=3)
         end
      else Ret = false
      end
   end

   %% IsEye function tells if a given board position is an eye of a certain color.
   proc {IsEye Board BP Col ?Ret}
      Cluster = {Board cluster(BP.1 BP.2 $)}
   in
     if Cluster.color==vacant then
	 if Col == black then 
            Ret = {And {List.length Cluster.whiteNeighbors}==0 
                     {And {List.length Cluster.blackNeighbors} \=0
                        {List.all Cluster.blackNeighbors 
                          fun {$ R#C#Col} 
                             if {Board cluster(R C $)}.color==vacant then
						 	    {Browser.browse errorInClusterToolsLine45}
								false
							 else
							    {List.length {Board cluster(R C $)}.liberties}>1
						     end
                          end
                        }}}

	 else
            Ret = {And {List.length Cluster.blackNeighbors}==0 
                      {And {List.length Cluster.whiteNeighbors} \=0
                        {List.all Cluster.whiteNeighbors 
                          fun {$ R#C#Col} 
                             if {Board cluster(R C $)}.color==vacant then
						 	    {Browser.browse errorInClusterToolsLine45}
								false
							 else
							    {List.length {Board cluster(R C $)}.liberties}>1
						     end
                          end
                        }}}
	 end
      else
	 Ret = false
      end
   end

%%   proc {IsEye Board BP Col ?Ret}
%%      IsCol = proc {$ R C ?Ret}
%%		 Ret = {Or {Not {Board isOnTheBoard(R C $)}} ({Board get(R C $)}==Col)}
%%	      end
%%   in
%%      Ret = {And {Board get(BP.1 BP.2 $)}==vacant
%%	         {And {And {IsCol BP.1-1 BP.2 $} {IsCol BP.1 BP.2-1 $}}
%%	              {And {IsCol BP.1+1 BP.2 $} {IsCol BP.1 BP.2+1 $}}}}
%%   end

   %% GetEyes returns a list of the board positions which are (friendly) eyes
   %% surrounding Cluster.
   proc {GetEyes Board Cluster ?Ret}
      if (Cluster.color == vacant) then
         Ret = nil
      else
	 Helper = fun {$ C}
	    if {Board cluster(C.stones.1.1 C.stones.1.2 $)}.color \= vacant then
	       %{Browser.browse errorInClusterToolsLine90}
		   false
	    else
           {IsEye Board C.stones.1 Cluster.color $}
       end
    end

         Helper2 = fun { $ VC}
            
            {List.some Cluster.liberties
               fun {$ Lib} {List.member Lib VC.stones} end $}
         end 
         

         VacantClusters = {Board getClusters($ [vacant])}

         NeighboringVacants = {List.filter VacantClusters Helper2 $}
      in
         Ret = {List.filter NeighboringVacants Helper $}
      end
   end

   %% Immortalize takes a board and the list of clusters on the board. It
   %% eventually returns the list of clusters that cannot be killed, leaving
   %% PlayWithBoard in a state where all mortal clusters have been removed.
   proc {Immortalize PlayWithBoard ClusterList ?Ret}
      HasEyes = proc {$ Cluster ?Ret}
		   Ret = {Or {HasTwoEyes PlayWithBoard Cluster $} {HasLargeEye
         PlayWithBoard Cluster $}}
		end
      Kill = proc {$ Cluster}
		{PlayWithBoard kill(Cluster.stones)}
	     end
      NewClusterList Remove
   in
      {List.partition ClusterList HasEyes NewClusterList Remove}
      if Remove==nil then
	 Ret = ClusterList
      else
	 {List.forAll Remove Kill}
	 Ret = {Immortalize PlayWithBoard NewClusterList $}
      end
   end

   %% Immortal serves as the wrapper function for Immortalize; takes a board
   %% and returns the list of all immortal clusters on the board.
   proc {Immortal Board ?Ret}
      Ret = {Immortalize {Board cloneBoard($)} {Board getClusters($)} $}
   end

   %% ---
   %% This section is devoted to cluster equivalence.
   %% ---

   %% This function takes a list of stones that are non-associated with
   %% color and appends their color.
   proc {List2Stones Lst Board ?Ret}
      local Helper in
	 Helper = fun {$ BP}
		     BP.1#BP.2#({Board get(BP.1 BP.2 $)})
		  end
	 Ret = {List.map Lst Helper $}
      end
   end

   %% This function takes a list of stones and converts it to 'normal form';
   %% that is, the list of stones is sorted from 1#1 2#1 3#1 ... 1#2 ... N#N.
   %% Works with lists that do or do not have color.
   proc {Normalize Lst Board ?Ret}
      local Temp in
	 Temp = {List.make ({Board size($)})*({Board size($)}) $}
	 for Stone in Lst do
	    {List.nth Temp Stone.1+(({Board size($)})-1)*Stone.2 $} = Stone
	 end
	 Ret = {List.filter Temp IsDet $}
      end
   end

   %% Function tells if two lists of stones are equal (set-wise).
   proc {Equal Lst1 Lst2 Board ?Ret}
      Ret = {Normalize Lst1 Board $}=={Normalize Lst2 Board $}
   end
   
   %% TEquivalent tests whether two lists of stones are translationally equivalent.
   %% Delta is R#C, where R and C are the row and column displacements respectively.
   %% Note that we hold C1 fixed and determine C2's relation to it. If Ret==false,
   %% then Delta has no meaning.
   proc {TEquivalent Lst1 Lst2 Board ?Delta ?Ret}
      if {List.length Lst1 $}=={List.length Lst2 $} then
	 local L1 L2 Diff Lst Helper in
	    L1 = {Normalize Lst1 Board $}
	    L2 = {Normalize Lst2 Board $}
	    Diff = fun {$ S1 S2}
		      (S2.1-S1.1)#(S2.2-S1.2)
		   end
	    Lst = {List.zip L1 L2 Diff $}
	    Delta = Lst.1
	    Helper = fun {$ X}
			X==Delta
		     end
	    Ret = {List.all Lst Helper $}
	 end
      else
	 Ret = false
      end
   end

   %% SameColor takes two lists (with added color) and tests for color correspondence.
   proc {SameColor Lst1 Lst2 Board ?Ret}
      local Equal L1 L2 Lst Helper in
	 L1 = {Normalize Lst1 Board $}
	 L2 = {Normalize Lst2 Board $}
	 Equal = fun {$ S1 S2}
		    S1.3==S2.3
		 end
	 Lst = {List.zip L1 L2 Equal $}
	 Helper = fun {$ X}
		     X
		  end
	 Ret = {List.all Lst Helper $}
      end
   end 

   %% This function takes a list and rotates it as follows:
   %% N==0: No rotation (base).
   %% N==1: Rotate by 90 degrees clockwise.
   %% N==2: Rotate by 180 degrees clockwise.
   %% N==3: Rotate by 270 degrees clockwise.
   proc {Rotate Lst N Board ?Ret}
      local Helper Wrapper in
	 Helper = fun {$ BP S}
		     if S==0 then
			BP
		     else
			{Helper (BP.2)#(~BP.1+({Board size($)})+1)#(BP.3) S-1}
		     end
		  end
	 Wrapper = fun {$ BP}
		      {Helper BP N}
		   end
	 Ret = {List.map Lst Wrapper $}
      end
   end

   %% This function takes a list and reflects it as follows:
   %% N==0: No reflection (base).
   %% N==1: Reflect over the diagonal (odd reflection).
   proc {Reflect Lst N Board ?Ret}
      local Helper Wrapper in
	 Helper = fun {$ BP S}
		     if S==0 then
			BP
		     else
			{Helper (BP.2)#(BP.1)#(BP.3) S-1}
		     end
		  end
	 Wrapper = fun {$ BP}
		      {Helper BP N}
		   end
	 Ret = {List.map Lst Wrapper $}
      end
   end

   %% This function takes a list and a tuple, (L,R):RotationNumber#
   %% ReflectionNumber, and returns its conversion. NOTE THAT WE APPLY
   %% ROTATION FIRST AND -THEN- REFLECTION.
   proc {Rref Lst Dir Board ?Ret}
      Ret = {Reflect {Rotate Lst Dir.1 Board $} Dir.2 Board $}
   end

   %% This function takes a list and translates it by a Delta DR#DC.
   proc {Translate Lst Delta Board ?Ret}
      local Helper in
	 Helper = fun {$ BP}
		     (BP.1+Delta.1)#(BP.2+Delta.2)#BP.3
		  end
	 Ret = {List.map Lst Helper $}
      end
   end

   %% This function takes a colored list and applies Rref and then Translate
   %% in succession (Rref first and then Translate).
   proc {Convert Lst Delta Dir Board ?Ret}
      Ret = {Translate {Rref Lst Dir Board $} Delta Board $}
   end
   
   %% Equivalent function tests if two COLORED  lists are translationally,
   %% rotationally, or reflectionally equivalent (and color equivalent).
   %% Ret: Whether the two lists are equivalent. If Ret==false, neither
   %% Delta nor Dir makes sense.
   %% Delta: Essentially, "List2 - List1" (co-ordinate wise), when
   %% List1 is rotated/reflected appropriately.
   %% Dir: The rotation#reflection numbers that must be APPLIED TO
   %% LIST 1 TO OBTAIN LIST 2.
   %% INVARIANT: If(f) {Equivalent Lst1 Lst2 ...} yields Delta and Dir,
   %% then Lst2 == {Convert Lst1 Delta Dir ...} when both lists are suitably
   %% normalized.
   proc {Equivalent Lst1 Lst2 Board ?Delta ?Dir ?Ret}
      if {SameColor Lst1 Lst2 Board $} then
	 for Rot in 0..3 break:Break do
	    for Ref in 0..1 do
	       local Temp Is X in
		  Temp = {Rref Lst1 Rot#Ref Board $}
		  {TEquivalent Temp Lst2 Board X Is}
		  if Is then
		     Delta = X
		     Dir = Rot#Ref
		     Ret = true
		     {Break}
		  end
	       end
	    end
	 end
	 if {Not {IsDet Ret}} then
	    Ret = false
	 end
      else
	 Ret = false
      end
   end

   %% ---
   %% This section is devoted to cluster lookahead.
   %% ---

   Opposite = opposite(white:black black:white)
   
   proc {Maximum Lst ?Ret}
      if Lst.2==nil then
	 Ret = Lst.1
      else
	 local M in
	    M = {Maximum Lst.2 $}
	    if Lst.1>M then
	       Ret = Lst.1
	    else
	       Ret = M
	    end
	 end
      end
   end   
   
   proc {Minimum Lst ?Ret}
      if Lst.2==nil then
	 Ret = Lst.1
      else
	 local M in
	    M = {Minimum Lst.2 $}
	    if Lst.1<M then
	       Ret = Lst.1
	    else
	       Ret = M
	    end
	 end
      end
   end

   proc {Surrounding Board Cluster ?Lst}
      local Helper Positions Vacant in
	 Helper = fun {$ S}
		     [(S.1)#(S.2-2)
		      (S.1-1)#(S.2-1) (S.1)#(S.2-1) (S.1+1)#(S.2-1)
		      (S.1-2)#(S.2) (S.1-1)#(S.2) (S.1+1)#(S.2) (S.1+2)#(S.2)
		      (S.1-1)#(S.2+1) (S.1)#(S.2+1) (S.1+1)#(S.2+1)
		      (S.1)#(S.2+2)]
		  end
	 Positions = {JAZTools.removeDuplicates {List.map Cluster.stones Helper}}
	 Vacant = fun {$ S}
		     {Board isOnTheBoard(S.1 S.2 $)} andthen {Board get(S.1 S.2 $)}==vacant
		  end
	 Lst = {List.filter Positions Vacant}
      end
   end
   
   proc {LookAhead Board Cluster Color Depth LibCap ?Lib}      
      if Cluster.color==vacant then
         Lib = 0
      else
         if Depth==0 then
            Lib = {List.length Cluster.liberties}
         else
            Temp
          in
            Temp = {NewCell {List.length Cluster.liberties}|nil}
            
            for M in Cluster.liberties do
               {Board play(M.1 M.2 Color _)}
               local L NewCluster in
                  NewCluster = {Board cluster(Cluster.stones.1.1 Cluster.stones.1.2 $)}
		  if NewCluster.color\=vacant andthen {List.length NewCluster.liberties}>LibCap then
                     L = {List.length NewCluster.liberties}
		  elseif NewCluster.color\=vacant andthen {HasTwoEyes Board NewCluster} then
                     L = LibCap+1
		  else
                     L = {LookAhead Board NewCluster Opposite.Color Depth-1 LibCap $}
                  end
                  
                  Temp := L|@Temp
                  {Board retractMove}
               end
            end
            if Color==Cluster.color then
               Lib = {Maximum @Temp $}
            else
               Lib = {Minimum @Temp $}
            end
         end
      end
   end
   
   proc {Defend Board Cluster Depth LibCap ?Lst}
      Temp = {NewCell nil}
    in      
      for M in Cluster.liberties do
         {Board play(M.1 M.2 Cluster.color _)}
         
         local L NewCluster in
            NewCluster = {Board cluster(Cluster.stones.1.1 Cluster.stones.1.2 $)}
            
            if NewCluster.color\=vacant andthen {List.length NewCluster.liberties}>LibCap then
               L = {List.length NewCluster.liberties}
            elseif NewCluster.color\=vacant andthen {HasTwoEyes Board NewCluster} then
               L = LibCap+1
            else
               L = {LookAhead Board NewCluster Opposite.(Cluster.color) Depth-1 LibCap $}
            end
            
            Temp := ((M.1#M.2#(Cluster.color))#(L-{List.length Cluster.liberties}))|@Temp
            {Board retractMove}
         end
      end
      
      Lst = @Temp
   end

   proc {Attack Board Cluster Depth LibCap ?Lst}
      Temp = {NewCell nil}
    in
      for M in Cluster.liberties do
         {Board play(M.1 M.2 Opposite.(Cluster.color) _)}
         
         local L NewCluster in
            NewCluster = {Board cluster(Cluster.stones.1.1 Cluster.stones.1.2 $)}
            
            if NewCluster.color\=vacant andthen {List.length NewCluster.liberties}>LibCap then
               L = {List.length NewCluster.liberties}
             else
               L = {LookAhead Board NewCluster Cluster.color Depth-1 LibCap $}
            end
            
            Temp := ((M.1#M.2#Opposite.(Cluster.color))#L)|@Temp
            {Board retractMove}
         end
      end
      
      Lst = @Temp
   end
     
end
