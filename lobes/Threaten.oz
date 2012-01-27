functor
   import EmptyLobe LobeTools Browser
   export Threaten
define
   Opposite = opposite(white:black black:white)

   class Threaten from EmptyLobe.lobe
      meth formulateWeights(Board Col ?Lst)
         Clusters = {Board getClusters($)}
         
         Threatened = fun {$ Cluster}
            {And {And Cluster.color==Opposite.(Col) {List.length Cluster.liberties}==2} {List.length Cluster.stones}>1}
		   end % fun Threatened
         
         ThreatenedClusters = {List.filter Clusters Threatened}
         Temp = {NewCell nil}
      in % meth Threatened
         for Cluster in ThreatenedClusters do
            for Lib in Cluster.liberties do
               local Colors in
                  Colors = {LobeTools.getColors Board Lib $}
                  if {List.length Colors.vacant}>1-{List.length Colors.border} then
                     Temp := ((Lib.1#Lib.2#Col)#1.0)|@Temp
                  end
               end
            end
         end  
	  Lst = @Temp
      end
   end
end

