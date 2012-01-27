functor
   import JAZTools Application

define

A = [  [  [ [1#2#white] [2#4#black] ]
          [3#9#vacant 6#2#black] 
       ] 
       2#3#vacant 
    ]
B = [  [  [6#2#black 3#9#vacant] 
          [ [1#2#white] [2#4#black] ] 
       ] 
       2#3#vacant
    ]

{JAZTools.assert {JAZTools.equalListsD A B}  'EqualListD has failed us'}
{Application.exit 0}
end

