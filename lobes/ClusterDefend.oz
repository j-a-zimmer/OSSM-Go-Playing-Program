functor
   import EmptyLobe ClusterTools Browser
   export ClusterDefend
define
   Opposite = opposite(white:black black:white)

   class ClusterDefend from EmptyLobe.lobe
      meth formulateWeights(Board Col ?Lst)
         
         Clusters = {Board getClusters($)}
         
         ClusterInDanger = fun {$ Cluster}
			   {And Cluster.color==Col {List.length Cluster.liberties}<4}
			end % fun ClusterInDanger
         
         Endangered = {List.filter Clusters ClusterInDanger}
         Defend = fun {$ Cluster}
            if {Not {ClusterTools.hasTwoEyes Board Cluster}} then
               local Weight in
                  Weight = fun {$ WMove}
                     local Wt Lib Stones in
                        Lib = {List.length Cluster.liberties}
                        Stones = {List.length Cluster.stones}
                           
                        if (WMove.2)>0 then
                           if Lib==1 then
                              Wt = 0.6366*{Atan {Int.toFloat Stones}*4.0 + {Int.toFloat WMove.2}*0.5}
                           elseif Lib==2 then
                              Wt = 0.6366*{Atan {Int.toFloat Stones} + {Int.toFloat WMove.2}*0.5}
                           else
                              Wt = 0.6366*{Atan {Int.toFloat Stones}*0.25 + {Int.toFloat WMove.2}*0.5}
                           end
                        else
                           Wt = ~1.0
                        end
                           
                        WMove.1#Wt
                     end
                  end % fun Weight               
                  
                  {List.map {ClusterTools.defend Board Cluster 4 5 $} Weight}
               end 
            else nil end
         end % fun Defend
      in % meth ClusterDefend
         Lst = {List.flatten {List.map Endangered Defend}} 
      end
   end
end

