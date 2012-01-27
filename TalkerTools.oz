functor
   import Browser
   export CoordinatesAlpha GetColorAtom CoordinatesToMove GetColorString
define
   CoordinatesAlpha = "A"#"B"#"C"#"D"#"E"#"F"#"G"#"H"#"J"#"K"#"L"#"M"#"N"#"O"#"P"#"Q"#"R"#"S"#"T"#"U"#"V"#"W"#"X"#"Y"#"Z"

   proc {GetColorAtom ColorString ?ColorAtom}
      if {Or (ColorString == "White") {Or (ColorString == "W") {Or (ColorString == "w") (ColorString == "white")}}} then
         ColorAtom = white
      else
         ColorAtom = black
      end
   end
   
   proc {GetColorString ColorAtom ?ColorString}
      if (ColorAtom == black) then 
         ColorString = "Black"
      else
         ColorString = "White"
      end
   end
   
   proc {CoordinatesToMove Coordinates Color ?R}
      proc {FindAlphaCoordinate Letter CurSearch ?R}
         if (CoordinatesAlpha.CurSearch == Letter) then
            R = CurSearch
         else
            {FindAlphaCoordinate Letter (CurSearch + 1) R}
         end
      end
      
      AlphaCoordinate
      NumericCoordinate
    in
      AlphaCoordinate = {FindAlphaCoordinate [Coordinates.1] 1 $}
      NumericCoordinate = {String.toInt Coordinates.2}
      
      R = AlphaCoordinate#NumericCoordinate#{GetColorAtom Color $}
   end
end

