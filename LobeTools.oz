functor

export onLine:OnLine inverseSquare:InverseSquare getColors:GetColors heaviside:Heaviside

define
   fun {OnLine Size N R C}
      {Or
       {And {Or R==(N+1) R==(Size-N)} {And C>N C<(Size-N+1)}}
       {And {Or C==(N+1) C==(Size-N)} {And R>N R<(Size-N+1)}}
      }
   end % fun OnLine
   
   fun {InverseSquare A#B X#Y}
      P = {Int.toFloat A}
      Q = {Int.toFloat B}
      R = {Int.toFloat X}
      C = {Int.toFloat Y}
   in % fun InverseSquare
      {Float.'/' 0.5 (P-R)*(P-R)+(Q-C)*(Q-C) $}
   end % fun InverseSquare

   proc {GetColors Board BP ?Ret}
      local Colors A B C D W X Y Z in
         Colors = rec(white:{NewCell nil} black:{NewCell nil} vacant:{NewCell nil} border:{NewCell nil})
         A = (BP.1-1)#(BP.2)#{Board get(BP.1-1 BP.2 $)}
         B = (BP.1+1)#(BP.2)#{Board get(BP.1+1 BP.2 $)}
         C = (BP.1)#(BP.2-1)#{Board get(BP.1 BP.2-1 $)}
         D = (BP.1)#(BP.2+1)#{Board get(BP.1 BP.2+1 $)}
         W = Colors.(A.3)
         W := A|@W
         X = Colors.(B.3)
         X := B|@X
         Y = Colors.(C.3)
         Y := C|@Y
         Z = Colors.(D.3)
         Z := D|@Z
         Ret = colors(white:@(Colors.white) black:@(Colors.black) vacant:@(Colors.vacant) border:@(Colors.border))
      end
   end % proc GetColors

   fun {Heaviside N}
      if N>0 then
         1.0
      else
         0.0
      end
   end % fun Heaviside
end
