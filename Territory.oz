functor

import PlayBoard JAZTools System Application Browser ClusterTools
export FindTerritory GetScore



define


  proc {FindTerritory Board ?Lst}
	   LiveBoard = {Live {Board cloneBoard($)} $}
      VacantClusters = {LiveBoard getClusters($ [vacant])}
   	Count = fun {$ ClusterList BlackTerr WhiteTerr}
	   	         case ClusterList of Cluster|Rest then
		   	         if {List.length Cluster.whiteNeighbors}==0 then
			   	         {Count Rest Cluster.stones|BlackTerr WhiteTerr}
			            elseif {List.length Cluster.blackNeighbors}==0 then
				            {Count Rest BlackTerr Cluster.stones|WhiteTerr}
			            else {Count Rest BlackTerr WhiteTerr}
   			         end
	   	         else {List.flatten BlackTerr $}#{List.flatten WhiteTerr $} 
                  end
		         end

   in
      Lst = {Count VacantClusters nil nil}
	end			


   proc {FindLive PlayWithBoard ClusterList Live ?LiveBoard}
	   Mortal = fun {$ Cluster}
		   {Not {List.member Cluster.stones.1 Live}}
	   end
	  
	   SortLiberties = fun {$ ClusterLst}
		   Sort = fun {$ A B}
			   {Value.'<' {List.length A.liberties} {List.length
            B.liberties}}
		   end
	   in
		   {List.sort ClusterLst Sort}
	   end
      SortedMortal MortalList
   in
    MortalList = {List.filter ClusterList Mortal}
      if {Not MortalList==nil} then 
         SortedMortal = {SortLiberties MortalList}
         if {List.length SortedMortal.1.liberties} < 5 then
            if ({ClusterTools.lookAhead {PlayWithBoard cloneBoard($)} SortedMortal.1 SortedMortal.1.color 3 5 $} < 5) 
            then 
               {PlayWithBoard kill(SortedMortal.1.stones)}
		         LiveBoard = {FindLive PlayWithBoard {PlayWithBoard
                           getClusters($)} Live}
            else 
               LiveBoard = {FindLive PlayWithBoard {PlayWithBoard
                        getClusters($)} {List.flatten
                        SortedMortal.1.stones|Live}}
            end
	      end
      end
      LiveBoard = PlayWithBoard
   end

   proc {Live Board ?Ret}
      Live = {ClusterTools.immortal Board}
      Stones = fun {$ List S}
                  case List of H|T then
                     {Stones T H.stones|S}
                  else
                     S
                  end
               end
      in
      
	   Ret = {FindLive Board {Board getClusters($)}
      {List.flatten {Stones Live nil}} $}
      
   end

   proc {CountStones Board ?Ret}
	   Count = fun {$ ClusterList Stones}
		         	case ClusterList of Cluster|Rest then
				         {Count Rest Stones+{List.length Cluster.stones}}
			         else Stones
			         end
		        end
	   Black White
      LiveBoard = {Live {Board cloneBoard($)} $}
   in

      {LiveBoard getClusters(Black [black])}
      {LiveBoard getClusters(White [white])}
	   Ret = {Count Black 0}#{Count White 0} 
   end

   proc {CountTerritory Board ?Ret}
      Terr = {FindTerritory Board}
      B W
   in
      case Terr of B#W then
         Ret = {List.length B}#{List.length W}
      else Ret = boo
      end
   end
   
   proc {GetScore Board ?Ret}
      Territory = {CountTerritory Board $}
      Stones = {CountStones Board $}
    in
      Ret = (Territory.1 + Stones.1)#(Territory.2 + Stones.2)
   end
end
