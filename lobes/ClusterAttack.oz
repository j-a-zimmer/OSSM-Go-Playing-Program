functor
   import EmptyLobe ClusterTools Browser
   export ClusterAttack
define
   Opposite = opposite(white:black black:white)

   class ClusterAttack from EmptyLobe.lobe
      meth formulateWeights(Board Col ?Lst)
         
         Clusters = {Board getClusters($)}
         
         ClusterInDanger = fun {$ Cluster}
			   {And Cluster.color==Opposite.(Col) {List.length Cluster.liberties}<4}
         end % fun ClusterInDanger
         
         Endangered = {List.filter Clusters ClusterInDanger}
         
         Attack = fun {$ Cluster}
            if {Not {ClusterTools.hasTwoEyes Board Cluster}} then
               local Weight in
                  Weight = fun {$ WMove}
                     if WMove.2==0 then
                        (WMove.1)#0.6366*{Atan{Int.toFloat {List.length Cluster.stones}}*2.0}
                     elseif WMove.2==1 then
                        (WMove.1)#0.6366*{Atan {Int.toFloat {List.length Cluster.stones}}}*0.25
                     else
                        (WMove.1)#0.0
                     end
                  end % fun Weight
		          {List.map {ClusterTools.attack Board Cluster 4 5 $} Weight}
               end
            else nil end
         end % fun Attack
      in % meth ClusterAttack
         Lst = {List.flatten {List.map Endangered Attack}}
      end
   end
end