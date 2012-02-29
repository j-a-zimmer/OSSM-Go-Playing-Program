functor
   import EmptyLobe Browser JAZTools SimpleBoard System
   export InfluenceConflict
   
define
   %Not in use
   class InfluenceConflict from EmptyLobe.lobe
      meth formulateWeights(Board Col ?Lst)

         proc {Influence Board Color ?Lst}
            StoneList ClusterList
            SumBoard = {New SimpleBoard.board init(Board.playSize nil _)}
            Temp = {NewCell nil}
            proc {AddWeight R#C}
               X = {SumBoard getWeight(R C $)}+1.0 
            in
               {SumBoard setWeight( R C X)}
                
            end

            proc {S R#C#Clr}
              InfluenceList = {Board getInfluencedPositions(R C Clr $)}
            in     
               {List.forAll InfluenceList AddWeight} % alters SumBoard
            end

          in % Influence ???
            
            ClusterList = {Board getClusters($ [Color])}
            for J in 1..({List.length ClusterList}-1) do

               {List.forAll {List.nth ClusterList J}.stones S}
             end     
             for R in 1..Board.playSize do 
                for C in 1..Board.playSize do 
                    Temp := ((R#C#Color)#{SumBoard getWeight(R C $)})|@Temp
                end
             end	 
             Lst = @Temp
         end %influence

         WhiteInfluenceList = {Influence Board white $}
         BlackInfluenceList = {Influence Board black $}

         
         proc {FindInfluenceDifference 
                 R C Color 
                 WhiteInfluenceList BlackInfluenceList 
                 ?InDifference ?TheirInf ?OurInf}
            (PosR#PosC#_)#WhiteInfluence|WhiteTail = WhiteInfluenceList
            (_#_#_)#BlackInfluence|BlackTail = BlackInfluenceList
          in
            if {And (PosR == R) (PosC == C)} then
               if (Color == black) then
                  InDifference = WhiteInfluence - BlackInfluence
                  OurInf = WhiteInfluence
                  TheirInf = BlackInfluence
               else
                  OurInf = BlackInfluence
                  TheirInf = WhiteInfluence
                  InDifference = BlackInfluence - WhiteInfluence
               end
            else
               {FindInfluenceDifference 
                      R C Color 
                      WhiteTail BlackTail 
                      InDifference TheirInf OurInf}
            end
         end
      
         proc {ProcessStoneList StoneList WeightListTemp ?WeightList}
            case StoneList
            of (R#C)|Tail then
               InfluenceDifference TheirInf OurInf
             in
               if {And {And (R>0) (R<Board.playSize)} {And (C>0) (C<Board.playSize)}} then
                  {FindInfluenceDifference R C Col WhiteInfluenceList BlackInfluenceList InfluenceDifference TheirInf OurInf}
                in
                  if {And {And (InfluenceDifference >= ~10.0) (InfluenceDifference =< 10.0)} {Not {Or (TheirInf == 0.0) (OurInf == 0.0)}}} then
                     WeightedInfluence = (InfluenceDifference + 20.0) * 0.04
                   in
                     {ProcessStoneList Tail ((R#C#vacant)#WeightedInfluence)|WeightListTemp WeightList}
                  else
                     {ProcessStoneList Tail WeightListTemp WeightList}
                  end
               else
                  {ProcessStoneList Tail WeightListTemp WeightList}
               end
            else
               WeightList = WeightListTemp
            end
         end
      
         proc {ProcessClusterStoneList StoneList WeightListTemp ?WeightList}
            case StoneList
            of (R#C#Color)|Tail then
               {ProcessClusterStoneList Tail {JAZTools.fancyAppend
               {ProcessStoneList {Board getManhattan(R#C 2 $)} nil $} WeightListTemp} WeightList}
            else
               WeightList = WeightListTemp
            end
         end
      
         proc {ProcessClusterList ClusterList WeightListTemp ?WeightList}
            case ClusterList
            of Cluster|Tail then
               {ProcessClusterList Tail {JAZTools.fancyAppend {ProcessClusterStoneList Cluster.stones nil $} WeightListTemp} WeightList}
            else
               WeightList = WeightListTemp
            end
         end
      
         Clusters = {Board getClusters($ [Col])}
      in 
	     {ProcessClusterList Clusters nil Lst}
      end
   end
end

