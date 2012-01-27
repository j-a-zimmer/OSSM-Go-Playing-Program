functor
   import EmptyLobe ClusterTools LobeTools Browser
   export MakeEye
define
   class MakeEye from EmptyLobe.lobe
      meth formulateWeights(Board Col ?Lst)
         fun {Eyes Colors}
            case Colors of H|T then
               if {ClusterTools.hasTwoEyes Board {Board cluster( H.1 H.2 $)}} then
                   true
               else
                   {Eyes T}
               end
            else false end
         end
      in
         local Temp in
            Temp = {NewCell nil}
            for R in 1..Board.playSize do
               for C in 1..Board.playSize do
                  if {Board get(R C $)}==vacant then
                     local Colors TwoEyes in
                        Colors = {LobeTools.getColors Board R#C $}
                                              
                        if {And {List.length Colors.vacant}==1 {List.length Colors.(Col)}==3-{List.length Colors.border}} then
                           TwoEyes = {Eyes Colors.(Col)}
                           if TwoEyes == false then
                             local Vacancy Surround in
                                 Vacancy = (Colors.vacant).1
                                 Surround = {LobeTools.getColors Board Vacancy.1#Vacancy.2 $}
                                 
                                 if {Not {List.length Surround.(Col)}==3-{List.length Surround.border}} then
                                    Temp := ((Vacancy.1#Vacancy.2#Col)#1.0)|@Temp
                                 end
                              end
                           end
                        end
                     end
                  end
               end
            end
	     Lst = @Temp
         end
      end
   end
end

