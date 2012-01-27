functor
   import EmptyBooleanLobe System Browser ArctanInfl
   export Connect
define
   Opposite = opposite(white:black black:white)
     
   fun {Connects Board R C Clr}
      Close = {Board getManhattan(R#C 2 $)}  
	  OpClr = Opposite.Clr 
      Clusters Threat
            
      proc {GetClusters MDList SClusters ?Clusters Threatyet ?Threat}
         case MDList of
         R1#C1|Rest  then 
            Clstr = {Board cluster(R1 C1 $)}
         in if Clstr.color==Clr then
               if (SClusters\=nil andthen {Member R1#C1#Clr SClusters.1.stones}) 
			             % I've already seen the cluster
						 
			      orelse ({ArctanInfl.distance R1 C1 R C}==2.0 andthen {Board get((R1+R) div 2 (C1+C) div 2 $)}==OpClr) 
					     % There is an enemy between me and this cluster (We're two apart)
						 
			      orelse ({ArctanInfl.distance R1 C1 R C}<1.5 andthen {ArctanInfl.distance R1 C1 R C}>1.4 
					           andthen ({Board get(R1 C $)}\=OpClr orelse {Board get(R C1 $)}\=OpClr))
						 % There are enemys between me and this cluster (We're diagonal)
			   then
                  {GetClusters Rest SClusters Clusters Threatyet Threat}
               else
                  {GetClusters Rest Clstr|SClusters Clusters Threatyet Threat}
               end 
            elseif Clstr.color==OpClr andthen {Abs R1-R}+{Abs C1-C}<2 then
               {GetClusters Rest SClusters Clusters true Threat}
            else
			   {GetClusters Rest SClusters Clusters Threatyet Threat}
            end 
         else % MDList is empty
            Clusters = SClusters
            Threat = Threatyet
         end  
      end                    
   in
      {GetClusters Close nil Clusters false Threat}
      {List.length Clusters}>1 andthen Threat
   end
	 
   class Connect from EmptyBooleanLobe.booleanLobe
      meth check(Board R C Clr ?Result)  
         Result = 
		    if {Board get(R C $)}==vacant andthen {Connects Board R C Clr} then
               true#1.0
            else
		       false#0.0
            end
      end
   end
end

