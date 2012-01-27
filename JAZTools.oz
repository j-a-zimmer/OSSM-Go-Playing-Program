functor
import System Application Set
export SetWriter Abort ListToAtom FixUnbounded EqualLists EqualListsD 
   Assert VList2BList BList2VList Board2VList Stop RemoveDuplicates
   CompactList WeightedSort FancyAppend ShowStones

define

   Pr = {NewCell System.showInfo}

   fun {Fix WriteMe}
      if {Not {IsDet WriteMe}} then
       '_'
      elseif {IsBool WriteMe} then
       if WriteMe then 'true' else 'false' end
      elseif {IsList WriteMe} then
       {ListToAtom WriteMe}
      elseif {IsString WriteMe} then
       {String.toAtom WriteMe}
      elseif {IsVirtualString WriteMe} then
       WriteMe
      else 
       raise 'Pr cannot digest something' end
      end
   end
      

   fun {SetWriter Writer}
      Pr :=  proc {$ WriteMe} {Writer {Fix WriteMe}} end
      @Pr
   end

   proc {Abort Msg}
      {@Pr Msg}
      {Application.exit 1}
   end % Abort

   fun {Insert Lst Obj}
      case Lst 
      of nil   then nil
      [] H|nil then H|nil
      [] H|T   then H|Obj|{Insert T Obj}
      end
   end

   fun {ListToAtom Lst}
      {VirtualString.toAtom {List.toTuple '#' {Insert Lst ','}}}
   end % ListToAtom

   fun {FixUnbounded V}
      if {IsDet V} then V else '_' end
   end % FixUnbounded

   fun {EqualLists A B}
      if {Set.minus A B}==nil andthen {Set.minus B A}==nil then true else
	 false end
   end

   proc {Assert What Msg}
      if {IsBool What} then
	 if {Not What} then {Abort Msg} end
      else
	 if {Not {What}} then {Abort Msg} end
      end
   end

   proc {VList2BList VList ?Ret} 
      proc {Helper VList R C ?BList}
       if VList==nil then
          BList = nil
       else
          if VList.1==nil then
             BList = {Helper VList.2 R+1 1 $}
          else
             local Color NewVList in
           if (VList.1).1==&W then
              Color = white
           elseif (VList.1).1==&B then
              Color = black
           else
              Color = vacant
           end
           NewVList = ((VList.1).2)|(VList.2)
           BList = (R#C#Color)|{Helper NewVList R C+1 $}
             end
          end
       end
      end
   in
      Ret = {Helper VList 1 1 $}
   end

   proc {PrintVList VList}
      if (VList==nil) then
          skip
      else
          {@Pr {String.toAtom VList.1}} 
          {PrintVList VList.2}
      end
   end

   fun {BList2VList BList}
%   Len = {Float.toInt {Float.sqrt {Int.toFloat {Length BList }}}}
      SortedList = {List.sort BList TupleOrder}
      Conversion = conv(black:&B white:&W vacant:& )
      Retval = {MakeDeep SortedList 1}
   in
      {Map Retval fun {$ X} {Map X fun {$ _#_#W} Conversion.W end} end }
   end

   fun {Board2VList Board}
      A={NewCell nil}
   in
      for R in 1..Board.size-2 do
	 for C in 1..Board.size-2 do
	    A:=(R#C#{Board get(R C $)})|@A
	 end
      end
      {BList2VList @A}
   end

   fun {MakeDeep L N}
      if L == nil then nil
      else
	 A C in
	 {List.takeDropWhile L fun {$ X} X.1 == N end A C}
	 A|{MakeDeep C N+1}
      end
   end

   fun {TupleOrder T1 T2}
      if T1.1 < T2.1 then true
      elseif T1.1 == T2.1 andthen T1.2 < T2.2 then true
      else false
      end
   end

   fun {EqualListsD A B}
   
      fun {Compare A B} 
	 case A#B 
	 of (AX|AY)#(BX|BY) then
	    if AX==BX then {Compare AY BY} else {Compare AX BX} end
	 [] (_|_)#_ then 
	    false 
	 [] _#(_|_) then 
	    true 
	 [] (A1#A2#_)#(B1#B2#_) then
	    {Value.'<' A1*19+A2 B1*19+B2}
	 [] AX#BX then 
	    {Value.'<' AX BX} 
	 else 
	    false 
	 end 
      end % Compare
   
      fun {Recurse A} 
	 case A 
	 of H|T then 
	    case H 
	    of _|_ then 
	       {Sort H}|{Recurse T} 
	    else 
	       H|{Recurse T} 
	    end 
	 else 
	    nil 
	 end 
      end % Recurse 

      fun {Sort A} 
	 {List.sort {Recurse A} Compare} 
      end

   in % EqualListsD
      {Sort A}=={Sort B} 
   end % EqualListsD

   proc {Stop N}
      {Application.exit N}
   end

   %% Removes duplicates from a list. Added by Irving Dai, April 23, 2010.
   proc {RemoveDuplicates Lst ?Ret}
      local Helper in
	 Helper = fun {$ L E}
		     case E of _|_ then
			{Set.union L E}
		     else
			{Set.union L [E]}
		     end
		  end
	 Ret = {List.foldL Lst Helper nil $}
      end
   end

   %% Takes a "weighted list": [(X1#W1) (X2#W2) ...] where Xi is a move 
   %% and Wi is its weight. Compresses the list by adding weights of equal elements;
   %% that is, if Xa==Xb, then we reduce (Xa#Wa) and (Xb#Wb) to a single entry
   %% (Xa#(Wa+Wb)). 
   fun {CompactList Lis Size Color}
      local Dic Helper Parse Unparse Output in
	 Dic = {Dictionary.new $}
	 Helper = proc {$ Lis}
		     case Lis of H|T then
			if {Dictionary.member Dic {Parse H.1}} then
			   {Dictionary.put Dic {Parse H.1} H.2+{Dictionary.get Dic {Parse H.1}}}
			else
			   {Dictionary.put Dic {Parse H.1} H.2}
			end
			{Helper T}
		     else
			skip
		     end
		  end
	 Parse = fun {$ Move}
      (Move.1-1)+Size*(Move.2-1)
		 end
	 Unparse = fun {$ Num}
		      ((Num mod Size)+1)#((Num div Size)+1)#Color
		   end
	 Output = fun {$ Move}
		     {Unparse Move.1}#Move.2
		  end
	 {Helper Lis}
	 {List.map {Dictionary.entries Dic} Output}
      end
   end

   %% Takes a "weighted list" (as above) and sorts it by order of priority (greatest to least).
   fun {WeightedSort Lst}
      local Sorter in
	 Sorter = fun {$ A B}
		     {Value.'>' A.2 B.2}
		  end
	 {List.sort Lst Sorter}
      end
   end
   
   fun {FancyAppend L1 L2}
      if (L1 == nil) then 
         L2
      elseif (L2 == nil) then
         L1
      else
         case L1
         of L1Head|L1Tail then
            L1Head|{FancyAppend L1Tail L2}
         else
            L1|L2
         end
      end
   end

   proc {ProcessManhattanDistance R#C Dist Proc}
      for IR in 1..(Dist+1)  do
         for IC in IR..(Dist+1) do  
            {Proc R+IR#C+IC}
         end
      end
   end

   proc {ShowStones Stones} 
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

 
end 
