functor
   import EmptyLobe Browser
   export Killer
define
   class Killer from EmptyLobe.lobe
      meth formulateWeights(Board Col ?Lst)
         Clusters = {Board getClusters($)}
      in % meth Killer
         Lst = {List.map
                 {List.filter Clusters fun {$ A} A.color\=Col andthen {List.length A.liberties}==1 end}
                 fun {$ A}
                    A.liberties.1#0.6366*{Atan {Int.toFloat {List.length A.stones}}}
                 end
	           }
      end
   end
end

