functor
import ArctanInfl
   QTk at 'x-oz://system/wp/QTk.ozf'
   GuiBoard
   Browser System Territory
   %JAZTools System
export  AIGBoard

define

%T = JAZTools
%Pr = {T.setWriter System.showInfo} % Browser.browse}

Itgr = Float.toInt
Flt = Int.toFloat

InfluenceDrawClamp = 10.0

fun {Clamp X A B}
   if (X<A) then
      A
   elseif (X>B) then
      B
   else
      X
   end
end


class AIGBoard from GuiBoard.gBoard
   feat text gamePhaseText
   attr LastDrawTag Weights LastPress LastSelectionTag DrawID WeightListMemory LastPlayBoard InfluenceInfo ArcInflInfo
   
   meth init(Player
             Size<=19 
             Scale<=30.0)
             
      proc {LClickAction R C}
         LastPress := R#C
         {self drawInfo()}
      end
      
      DrawID := 0
    in                            
      GuiBoard.gBoard,init(Player Size Scale LClickAction proc{$ R C} skip end  _ c(104 215 255))
      
      {self wipeWeightMemory}
   end
   
   %%%%%%%%%% Weight Info %%%%%%%%%%
   meth wipeWeightMemory
      Weights := nil
   end
   
   meth passWeightInfo(MakerFun WeightList)
      if {Not (WeightList == nil)} then
         Weights := (MakerFun#WeightList)|@Weights
      end
   end
   
   meth pushWeightInfo
      if {IsDet @LastPress} then
         DString
         
         R = @LastPress.1
         C = @LastPress.2
         
         proc {FindWeightAtRC Weights ?Weight}
            case Weights
            of nil then
               Weight = 0.0
            [] ((Row#Column#Useless)#SpecificWeight)|Tail then
               if {And (Row==R) (Column==C)} then
                  Weight = SpecificWeight
                else
                  {FindWeightAtRC Tail Weight}
                end
            end
         end
         
         proc {ThrowWeight WeightInfo CountingTotalWeight WorkingString ?DispString}
            case WeightInfo
            of nil then
               DispString = {Append {Append "Total Weight: " {Float.toString CountingTotalWeight}} WorkingString}
            [] (FromFunc#CurWeights)|Tail then
               WeightAtRC = {FindWeightAtRC CurWeights $}
               NewStringPart
             in
               if (WeightAtRC == 0.0) then
                  NewStringPart = ""
               else
                  NewStringPart = {Append "\n" {Append {Append {VirtualString.toString {Value.toVirtualString FromFunc 1 1}} ": "} {Float.toString WeightAtRC}}}
               end
               
               {ThrowWeight Tail (CountingTotalWeight + WeightAtRC) {Append WorkingString NewStringPart} DispString}
            end
         end
       in
         if {IsDet @Weights} then            
            {ThrowWeight @Weights 0.0 "" DString}
            
            {self.text set(text:{String.toAtom DString})}
         end
      end
   end
   
   meth drawWeights(Tag)      
      fun {AddDraw Loc#Weight}
         BPerc = {Clamp {Itgr ({Float.'/' Weight 2.0}*255.0)} 0 255}
         RPerc = {Clamp {Itgr ({Float.'/' Weight ~10.0}*255.0)} 0 255}
       in
         Loc#c(RPerc 0 BPerc)
      end
    in
      if {IsDet @WeightListMemory} then
         {self addMarks({List.map @WeightListMemory AddDraw $} Tag)}
         {self pushWeightInfo}
      end
   end
   
   meth passWeights(WeightList)
      WeightListMemory := WeightList
   end
   
   %%%%%%%%%% Influence Info %%%%%%%%%%
   
   meth drawInfluence(Tag Cutoff<=0)
      WhiteInfluenceList = {@LastPlayBoard influence(white $)}
      BlackInfluenceList = {@LastPlayBoard influence(black $)}
      
      InfluenceInfo := WhiteInfluenceList#BlackInfluenceList
   
      proc {BuildDrawList InfluenceList ExtraSign WorkingList ?Ret}
         case InfluenceList
         of (R#C#ColorUseless)#Influence|Tail then
            Col Sign TCol AbsInf
          in
            if (Influence == 0.0) then
               {BuildDrawList Tail ExtraSign WorkingList Ret}
            elseif {Or (Influence >= Cutoff) (Influence =< (Cutoff * ~1.0))} then
               if (Influence < 0.0) then Sign = ~1.0 else Sign = 1.0 end
               AbsInf = Influence * Sign
               
               Col = {Clamp (127 + 127 * ExtraSign) 0 255}
            
               {BuildDrawList Tail ExtraSign ((R#C#useless)#c(Col Col Col))|WorkingList Ret}
            else
               {BuildDrawList Tail ExtraSign WorkingList Ret}
            end
         else
            Ret = WorkingList
         end
      end
            
      InfluenceList ExtraSign
    in
      {self addMarks({BuildDrawList BlackInfluenceList ~1 {BuildDrawList WhiteInfluenceList 1 nil $} $} Tag)}
   end
   
   meth pushInfluenceInfo
      if {IsDet @LastPress} then
         DString
         
         R = @LastPress.1
         C = @LastPress.2
         
         proc {FindInfluenceInfo InfluenceList ?Influence}
            case InfluenceList
            of nil then
               Influence = ~1
            [] ((Row#Column#Color)#(Inf))|Tail then
               if {And (Row==R) (Column==C)} then
                  Influence = Inf
                else
                  {FindInfluenceInfo Tail Influence}
               end
            end
         end
         
         proc {GetInfluenceString ?DispString}
            C1Inf = {FindInfluenceInfo (@InfluenceInfo).1 $}
            C2Inf = {FindInfluenceInfo (@InfluenceInfo).2 $}
          in
            if (C1Inf \= ~1) then
               DispString = {VirtualString.toAtom 'Influence: '#C1Inf}
            elseif (C2Inf \= ~1) then
               DispString = {VirtualString.toAtom 'Influence: '#C2Inf}
            else
               DispString = 'Influence: None'
            end
         end
       in
         if {IsDet @InfluenceInfo} then            
            {GetInfluenceString DString}
            
            {self.text set(text:DString)}
         end
      end
   end
   
   %%%%%%%%%% Arctan Influence %%%%%%%%%
   
   meth drawArctanInfl(Tag)
      fun {ProcessArctanInfl List}
         case List
         of nil then
            nil
         [] ((R#C#Useless)#Infl)|Tail then
            ((R#C#useless)# c(127-{FloatToInt 127.0*Infl} 
			                  127-{FloatToInt 127.0*Infl} 
							  127-{FloatToInt 127.0*Infl})) | {ProcessArctanInfl Tail}
         end
      end
      Infl
      DrawList
    in
      Infl = {ArctanInfl.findInfl @LastPlayBoard}
      ArcInflInfo := Infl
      DrawList = {ProcessArctanInfl Infl}
      {self addMarks(DrawList Tag)}
   end
   meth pushArcInfo
      fun{FindInfl R C Info}
	     case Info of (Row#Col#_)#Inf|Tail then
		    if Row==R andthen Col==C then
			   Inf
			else
			   {FindInfl R C Tail}
			end
	     end
      end     
      Infl = {FindInfl @LastPress.1 @LastPress.2 @ArcInflInfo}
      Text = {VirtualString.toAtom 'Influence: '#Infl}
   in
      {self.text set(text:Text)}
   end
   
   %%%%%%%%%% Territory %%%%%%%%%
   
   meth drawTerritory(Tag)
      proc {ProcessTerritoryList List Col WorkingList ?RetList}
         case List
         of nil then
            RetList = WorkingList
         [] (R#C#Useless)|Tail then
            {ProcessTerritoryList Tail Col ((R#C#useless)#Col)|WorkingList ?RetList}
         end
      end
      
      TerritoryList = {Territory.findTerritory @LastPlayBoard $}
      
      DrawList
    in
      DrawList = {ProcessTerritoryList TerritoryList.1 c(0 0 0) {ProcessTerritoryList TerritoryList.2 c(255 255 255) nil $} $}
      {self addMarks(DrawList Tag)}
   end
   
   %%%%%%%%%% Pseudo Territory %%%%%%%%%
   
   meth drawPseudoTerr(Tag)      
      Ary = {@LastPlayBoard getManhatTerrArray($)}
      Temp = {NewCell nil}
      DrawList
    in
	  for R in 1..{@LastPlayBoard size($)} do
	     for C in 1..{@LastPlayBoard size($)} do
		    if {Get Ary R*{@LastPlayBoard size($)}+C}==1 then
			   Temp := (R#C#useless)#c(0 0 0) | @Temp
			elseif {Get Ary R*{@LastPlayBoard size($)}+C}==~1 then
			   Temp := (R#C#useless)#c(255 255 255) | @Temp
			end
		 end
	  end
      DrawList = @Temp
      {self addMarks(DrawList Tag)}
   end
   
   %%%%%%%%%% Pseudo Arctan Territory %%%%%%%%%
   
   meth drawPseudoArcTerr(Tag)
      Ary = {@LastPlayBoard getArctanTerrArray($)}
      Temp = {NewCell nil}
      DrawList
    in
	  for R in 1..{@LastPlayBoard size($)} do
	     for C in 1..{@LastPlayBoard size($)} do
		    if {Get Ary R*{@LastPlayBoard size($)}+C}==1 then
			   Temp := (R#C#useless)#c(0 0 0) | @Temp
			elseif {Get Ary R*{@LastPlayBoard size($)}+C}==~1 then
			   Temp := (R#C#useless)#c(255 255 255) | @Temp
			end
		 end
	  end
      DrawList = @Temp
      {self addMarks(DrawList Tag)}
   end   
   
   %%%%%%%%%% Drawer %%%%%%%%%
   meth clearInfoTag
      if {IsDet @LastSelectionTag} then
         {self clearMarks(@LastSelectionTag)}
         LastSelectionTag := _
      end
   end
  
   meth clearDrawTag
      if {IsDet @LastDrawTag} then
         {self clearMarks(@LastDrawTag)}
         LastDrawTag := _
      end
   end
   
   meth drawInfo()
      NewTag
    in
      {self clearInfoTag()}
   
      {self addMarks([(@LastPress.1#@LastPress.2#unneeded)#c(0 255 0)] NewTag)}
      LastSelectionTag := NewTag
      
      if (@DrawID == 0) then
         {self pushWeightInfo()}
      elseif {Or (@DrawID == 1) (@DrawID == 3)} then
         {self pushInfluenceInfo()}
	  elseif (@DrawID == 4) then
	     {self pushArcInfo()}
      end
   end
   
   meth draw(PlayBoard)
      if {IsDet PlayBoard} then
         Phase = {PlayBoard phase($)}
         PhaseText
       in
         LastPlayBoard := PlayBoard
         
         if (Phase == early) then
            PhaseText = 'Game Phase: Early'
         elseif (Phase == middle) then
            PhaseText = 'Game Phase: Middle'
         else
            PhaseText = 'Game Phase: Late'
         end
         
         {self.gamePhaseText set(text:PhaseText)}
      end
      
      if {IsDet @LastPlayBoard} then
         {self clearDrawTag()}

         LastDrawTag := _
         
         if (@DrawID == 0) then
            LastDrawTag := {self drawWeights($)}
         elseif (@DrawID == 1) then skip
            LastDrawTag := {self drawInfluence($ 0.0)}
         elseif (@DrawID == 3) then skip
            LastDrawTag := {self drawInfluence($ 3.0)}
         elseif (@DrawID == 2) then
            LastDrawTag := {self drawTerritory($)}
	     elseif (@DrawID == 4) then
		    LastDrawTag := {self drawArctanInfl($)}
		 elseif (@DrawID == 5) then
		    LastDrawTag := {self drawPseudoTerr($)}
		 elseif (@DrawID == 6) then
		    LastDrawTag := {self drawPseudoArcTerr($)}
         end
         if {IsDet @LastPress} then
            {self drawInfo()}
         end
      end
   end
   
   meth SetDrawType(ID)
      if (@DrawID \= ID) then
         DrawID := ID
         {self draw(_)}
      end
   end
   
   meth buildWindow(Board Buttons NumPixels ?Window)
      UseText = message( text: 'Click an intersection to view specific weights.' 
                      aspect: NumPixels
                      handle: self.text)
                      
      PhaseText = message( text: 'Game Phase: Early' 
                      aspect: NumPixels
                      handle: self.gamePhaseText)
                      
      Buffer = message( text: '')
                      
      Weights = button(text: 'Show Weights' 
                     action: proc {$} {self SetDrawType(0)} end)
      Influence = button(text: 'Show Influence'      
                     action: proc {$} {self SetDrawType(1)} end)
      HInfluence = button(text: 'Show High Influence'      
                     action: proc {$} {self SetDrawType(3)} end)
      Territory = button(text: 'Show Complete Territory' 
                     action: proc {$} {self SetDrawType(2)} end)
	  ArctanInfl = button(text: 'Show Arctan Influence'
	                 action: proc {$} {self SetDrawType(4)} end)
	  PseudoTerr = button(text: 'Show Pseudo Territory' 
                     action: proc {$} {self SetDrawType(5)} end)
      PseudoArcTerr = button(text: 'Show Pseudo Arctan Territory' 
                     action: proc {$} {self SetDrawType(6)} end)
      None = button(text: 'None' 
                     action: proc {$} {self SetDrawType(7)} end)
    in
      Window = {QTk.build lr(td(PhaseText Buffer Weights Influence HInfluence ArctanInfl Territory PseudoTerr PseudoArcTerr None) td(Board Buttons) UseText)}
   end

    meth MouseToBoard(X Y ?BoardX BoardY) 
      XG YG
    in % X Y are relative to window's root
       % XG XG are relative to board/canvas's root
       % BoardY BoardY are row and col numbers
      {self.display canvasx(X XG)}
      {self.display canvasy(Y YG)}
      {self GuiToBoard( XG YG BoardX BoardY )}
    end
     
    meth GuiToBoard( GuiX GuiY ?BoardX ?BoardY ) 
      BoardX =  
        {Itgr ({Flt GuiY}-self.conversion_const)/self.scale + 1.0}
      BoardY =  
        {Itgr ({Flt GuiX}-self.conversion_const)/self.scale + 1.0}
    end
end % AIGBoard 

end

