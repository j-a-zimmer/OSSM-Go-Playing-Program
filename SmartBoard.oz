functor % SmartBoard

import SimpleBoard System
   %JAZTools
export SBoard Process4 ShowStones 

% This functor contains the SBoard class which extends the Go board in
% SimpleBoard adding with this accessor
%
%       cluster 
%
% These mutators are added
%
%       kill, play
%
% (Normally client classes should not use Simpleboard, put)
%
% These mutators are altered to handle clusters:
%
%      retract, reset
%
% Conceptually SBoard is partitioned into Clusters.  The cluster
% accessor returns an instance of the StringCluster class if invoked at
% a board position with a stone and the VacantCluster class if invoked
% at an empty (i.e. vacant) board position.  You can tell which one you
% have by looking at the color feature.

% All forms of the Cluster class have these features
%
%      color: black, white, or neutral
%      stones: a list of board positions of the given color 
%              containing the associated board position and such 
%              that between any two there is a path on the board 
%              consisting only of board positions in this list
%              that follows the lines on the go board
%


% The StringCluster class additionally has these features:
%      
%           enemies: a list of board positions of opposite color to
%                    and adjacent to this StringCluster object
%           liberties: a list of vacant board positions adjacent to
%                      this StringCluster object

% The VacantCluster subclass additionally has these features:
%
%           whiteStrings: a list of white StringCluster object that are
%                             are adjacent to this VacantCluster Object
%           blackStrings: a list of black StringCluster objects that are
%                             are adjacent to this VacantCluster Object
%
%
% All lists are without duplicates, in no particular order, and
% maximal in the sense that no other board position (or Cluster) could
% be added to them without violating their definitions.

define

%T = JAZTools 
%Pr = {T.setWriter System.showInfo}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Helper Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%

proc {Process4 R C Proc}
   {Proc R-1 C}
   {Proc R C-1}
   {Proc R+1 C}
   {Proc R C+1}
end

proc {ShowStones Stones} %% debug only
  if Stones==nil then
     {System.showInfo ""} 
  else
     (R#C)|T = Stones
   in
     {System.printInfo R#':'#C}
     if T\=nil then {System.printInfo ','} end
     {ShowStones T}
  end
end

proc {AddUnique LstCell Elt}
   if {Not {List.member Elt @LstCell}} then 
      LstCell := Elt|@LstCell 
   end
end

proc {Putc BoardClass R C Clstr}
    {Array.put BoardClass.clusters (R*BoardClass.size+C) Clstr}
end

fun {Getc BoardClass R C}
   {Array.get BoardClass.clusters (R*BoardClass.size+C)}
end

proc {MakeNeighborLists Board R C} 
    
      TheCluster = {Getc Board R C} 

      proc {UpdateTheCluster Rn Cn}
         RnCnClstr = {Getc Board Rn Cn}
      in
         if RnCnClstr.clusterNum\=TheCluster.clusterNum then
            case RnCnClstr.color
            of vacant then
              {AddUnique TheCluster.vacantNeighbors Rn#Cn#vacant}
            [] black then
              {AddUnique TheCluster.blackNeighbors Rn#Cn#black}
            [] white then
              {AddUnique TheCluster.whiteNeighbors Rn#Cn#white}
            [] border then
              skip
            else
              {Raise 'UpdateTheCluster: unexpected color'}
            end
         end
      end % UpdateTheCluster 

in % MakeNeighborLists
   if @(TheCluster.needsUpdating) then
      (TheCluster.whiteNeighbors):= nil
      (TheCluster.blackNeighbors):= nil
      (TheCluster.vacantNeighbors):= nil
      {List.forAll TheCluster.stones proc {$ R#C#_}
         {Process4 R C UpdateTheCluster}
      end}
      (TheCluster.needsUpdating) := false 
   end
end % MakeNeighborLists

%%%%%%%%%%%%%%%%%%%%%%%%%%% Global Varibles %%%%%%%%%%%%%%%%%%%%%%%%%%%%

ClusterNum = {NewCell 0}  % ClusterNum is the number of the
                          % next InternalCluster to be made
                          % ClusterNum increments by one each
                          % time an InternalCluster is made
                          % ClusterNum is shared by InternalCluster 
                          % and RebuildClusters 
Show = {NewName}
SimBoard = SimpleBoard.board


%%%%%%%%%%%%%%%% Cluster Classes Returned by cluster method %%%%%%%%%%%%%%%

class StringCluster 
   feat color stones liberties enemies
    
   meth init(Color Stones Liberties Enemies)
     self.color = Color
     self.stones = Stones
     self.enemies = Enemies
     self.liberties = Liberties
  end

end

class VacantCluster 
   feat color stones whiteNeighbors blackNeighbors
    
   meth init(Color Stones WhiteNeighbors BlackNeighbors)
     self.color = Color
     self.stones = Stones
     self.blackNeighbors = BlackNeighbors
     self.whiteNeighbors = WhiteNeighbors
   end

   meth processAll( Proc ) 
      {List.forAll self.blackNeighbors Proc}
      {List.forAll self.whiteNeighbors Proc}
   end

end


%%%%%%%%%%%%%%%%%%%%%%%%%% Helper Classes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% In actuality, each board position is assigned an InternalCluster
% object.  (The same object is assigned to contiguous board positions
% of the same color.)
%
% When SBoard, cluster is invoked, an InternalCluster object is
% transformed into a VacantCluster object or a StringCluster object
% and this latter (stateless) object is what is returned.
 
% Besides the features common to all Cluster classes the InternalCluster 
% class additionally has these features;
%
%      whiteNeighbors, blackNeighbors, vacantNeighbors, 

% At least one InternalCluster object must be replaced if any mutator 
% is executed.  The RebuildClusters class helps with this.

class RebuildClusters
   % two constructors whose side effect on their Board parameter
   % is their entire reason for existence

   feat rebuildNum

   meth reactToChange(BoardClass R C) 
      %% makes builds or rebuilds cluster at R C and updates
      %% clusters of neighboring positions as necessary
     
      proc {CheckingNeighbors R C}
%         NbrClstr = {Getc BoardClass R C}
%      in 
         {self MaybeInstallCluster(BoardClass R C)}
      end 
      
   in % reactToChange
      self.rebuildNum = @ClusterNum
      {self InstallCluster(BoardClass R C)}
      {Process4 R C CheckingNeighbors}
   end % reactToChange 

   meth initializeAll(BoardClass)
      %% installs a cluster at all board positions except edge
      %% board constructor installs at edge
      self.rebuildNum = @ClusterNum
      {BoardClass 
          processBoard( proc {$ BC R1 C1} 
                          {self MaybeInstallCluster(BC R1 C1)}
                        end ) }
   end

   meth MaybeInstallCluster(BoardClass R C)
      Clstr = {Getc BoardClass R C}
   in
      if Clstr==nil orelse Clstr.clusterNum<self.rebuildNum then
         {self InstallCluster(BoardClass R C)}
      end
   end

   meth InstallCluster(BoardClass R C)
      Color = {BoardClass get(R C $)}
      Stones = {List.map {BoardClass getSameColorList(R C $)} fun {$ A#B} A#B#Color end}
      NewClstr
   in
      NewClstr = {New InternalCluster init(Color Stones)}
      {List.forAll Stones 
                   proc {$ R#C#_}
                      {Putc BoardClass R C NewClstr}
                   end}
   end
      
end

class InternalCluster
  feat color stones clusterNum needsUpdating
       whiteNeighbors blackNeighbors vacantNeighbors

       % InternalClusters know their color and stones but not their
       %   vacantNeibhbors (list of adjacent vacant stones)
       %   whiteNeighbors (list of adjacent white stones)
       %   blackNeighbors (list of adjacent black stones)
       % These things are left to the subclasses StringCluster
       % and VacantCluster.  The subclass objects are 
       % created only when SBoard, cluster($) is invoked
       
       % When making new clusters around a recent Simboard,put 
       %   we only need update board positions where the cluster
       %   number is earlier than the number of the first cluster
       %   we make.

  meth init(Color Stones)
     self.color = Color
     self.stones = Stones
     self.needsUpdating = {NewCell true}
     ClusterNum := @ClusterNum + 1
     self.clusterNum= @ClusterNum
     self.whiteNeighbors= {NewCell nil}
     self.blackNeighbors= {NewCell nil}
     self.vacantNeighbors= {NewCell nil}
  end % init InternalCluster

  meth !Show(What)  %% debug only
     case What
     of stones then {ShowStones @(self.stones)}
     [] white  then {ShowStones @(self.whiteNeighbors)}
     [] black  then {ShowStones @(self.blackNeighbors)}
     [] vacant then {ShowStones @(self.vacantNeighbors)}
     end
  end

end % class InternalCluster


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% The SBoard Class %%%%%%%%%%%%%%%%%%%%%%%%%%

class SBoard from SimBoard
   feat clusters
       
   meth init(Size InitialStones PutAction<=_ State<=_)  % initialize a SmartBoard
      proc {PutBorders}
        %% the border is an extra layer of board positions outside
        %% the playable positions; InternalClusters there have the
        %% color: border

        L = self.size-1

        proc {Pc R C}
          {Putc self R C {New InternalCluster init(border nil)}}
        end
      
      in % PutBorders
        {For 0 L 1  proc {$ I} {Pc I 0} {Pc I L} end}
        {For 1 (L-1) 1 proc {$ I} {Pc 0 I} {Pc L I} end}
      end % PutBorders

   in % init   
      self.playSize = Size
     self.size = Size+2
     SimBoard,init(Size InitialStones PutAction)
     if {IsDet State} then
	    fun{ListToArray Low#High#Lst}
	        L = {NewCell Lst}
	        A = {NewArray Low High nil}
	     in
		    for I in Low..High do
		       {A.put Low (@Lst).1}
			   L := (@L).2
		    end
		    A
	     end
	 in
	    self.clusters = {ListToArray (State.clusters)}
	 else
	    self.clusters = {Array.new 0 self.size*self.size-1 nil}
	 end
     {PutBorders}
     {New RebuildClusters initializeAll(self) _}
   end % init
   
   meth play(R C Color)
      if Color\=vacant then
         SimBoard,put(R C Color)
         {New RebuildClusters reactToChange(self R C) _}
      end
   end % play

   meth retract
      R#C#_#_ | _ = {self history($)}
   in
      SimBoard,retract
      %{New RebuildClusters reactToChange(self R C) _}  -- probably was error
      {New RebuildClusters initializeAll(self) _}
   end

   meth kill( Lst ) 
      proc {KillOne P}
          R#C#_ = P
        in
         if(SimBoard,get(R C $)\= vacant) then
             SimBoard,put(R C vacant)
             {New RebuildClusters reactToChange(self R C) _}
         end
      end
   in % kill
      {List.forAll Lst KillOne}
   end % kill

   meth reset(StoneList)  % sets all board positions to vacant
                          % and loads the nonvacant positions
                          % of StoneList
      SimBoard,reset(StoneList)  
      {New RebuildClusters initializeAll(self) _}
   end
   
   meth cluster(R C ?Z)
      Clstr = {Getc self R C}
   in
      case Clstr.color
      of border then
         Z= nil 
      [] vacant then
         {MakeNeighborLists self R C}
         Z= { New VacantCluster
               init( vacant 
                     Clstr.stones
                     @(Clstr.whiteNeighbors)
                     @(Clstr.blackNeighbors)  ) }
      [] black then
         {MakeNeighborLists self R C}
         Z= { New StringCluster
                  init( Clstr.color
                        Clstr.stones
                        @(Clstr.vacantNeighbors)
                        @(Clstr.whiteNeighbors) )}
      [] white then
         {MakeNeighborLists self R C}
         Z= { New StringCluster
                  init( Clstr.color
                        Clstr.stones
                        @(Clstr.vacantNeighbors)
                        @(Clstr.blackNeighbors) )}
      else
         {Raise "Error (SBoard,cluster) unexpected cluster"}
      end

   end % cluster
   
   meth numStones(?R)
	   Count = fun {$ ClusterList Stones}
		         	case ClusterList of Cluster|Rest then
				         {Count Rest Stones+{List.length Cluster.stones}}
			         else Stones
			         end
		        end
   in
      R = {Count {self getClusters($ [black white])} 0}
   end

   meth getClusters(?R Colors<=[black white])
      D = {NewDictionary} % maps clusters to false
      
      proc {GetThem Board R C}
       Clstr = {Getc Board R C}
       Cp = 
          case Clstr.color
          of border then
             nil 
          [] vacant then
             {MakeNeighborLists self R C}
             { New VacantCluster
               init( vacant 
                           Clstr.stones
                @(Clstr.whiteNeighbors)
                @(Clstr.blackNeighbors)  ) }
          [] black then
             {MakeNeighborLists self R C}
             { New StringCluster
               init( Clstr.color
                Clstr.stones
                @(Clstr.vacantNeighbors)
                @(Clstr.whiteNeighbors) )}
          [] white then
             {MakeNeighborLists self R C}
             { New StringCluster
               init( Clstr.color
                Clstr.stones
                @(Clstr.vacantNeighbors)
                @(Clstr.blackNeighbors) )}
          else
             error
          end
	    DC = {Dictionary.condGet D Clstr.clusterNum missing}
      in % getThem
	     if DC==missing andthen 
           {List.member Clstr.color Colors} 
          then {Dictionary.put D Clstr.clusterNum Cp} end
      end % getThem
      
   in % getClusters
      {self processBoard(GetThem)}
      R = {Dictionary.items D}
   end % getClusters

end % class SBoard

   
end 
