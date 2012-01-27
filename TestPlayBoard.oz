functor

import PlayBoard JAZTools Application
      System Browser
   
define

   T = JAZTools
   Assert = T.assert

%   Pr = {T.setWriter System.showInfo}

   fun {Board SetUp} 
     Size = {Length SetUp.1} 
     Conv = JAZTools.vList2BList
   in
     {New PlayBoard.pBoard init(Size {Conv SetUp})}
   end

   B1 R1a R1b R1c R1d
   B2 R2a %R2b R2c R2d
      K2a %K2b K2c K2d
   B3 %R3a R3b R3c R3d K3a K3b K3c K3d
   B4 %R4a R4b R4c R4d K4a K4b K4c K4d
   B5 Bd5 B6 Bd6 B7 Bd7 B8 Bd8 B9 Bd9 B10 Bd10 B11 Bd11 B12 Bd12

   Bd2 Bd3

   fun {RemoveZeroWeights (R#C#Clr)#Weight}
      Weight \= 0.0
   end

in

% test suicides

   B1 = [ [&  &B &  & ]
          [&B &  &B & ]
          [&B &W &B & ]
          [&  &B &  & ] ]

   {{Board B1} analyze(2 2 black R1a _)}
   {Assert R1a 'cannot fill with same color'}
   {{Board B1} analyze(2 2 white  R1b _)}
   {Assert {Not R1b} 'simple suicide allowed'}
   {{Board B1} analyze(1 1 black R1c _)}
   {Assert R1c 'cannot fill with same color'}
   {{Board B1} analyze(1 1 white  R1d _)}
   {Assert {Not R1b} 'simple suicide allowed'}
   
% test kill

   B2 = [ [&W &W &B & ]
          [&B &B &  &B]
          [&W &W &B & ]
          [&  &  &  & ] ] 
   B3 = [ [&W &W &B & ]
          [&  &  &W &B]
          [&W &W &B & ]
          [&  &  &  & ] ]
   Bd2 = {Board B2}
   {Bd2 analyze(2 3 white R2a K2a)}
   {Assert R2a 'was not allowed to kill when short on liberties'}
   {Assert {T.equalLists K2a [2#1#black 2#2#black]} 'B2: two stones not killed'}

   Bd3 = {Board B2}
   {Bd3 play(2 3 white _)}
   {Assert {T.equalListsD B3 {T.board2VList Bd3}}
           'after first killing board is not right'
   }

   B4 = [ [&  &  &W & ]
          [&  &  &B &W]
          [&W &B &B &W]
          [&  &W &W & ] ]


%% --------------------------------------------------------------------
%% getInfluencedPositions tests
%% warning: test only passes if PlayBoard.InfluenceRadius==3

% 1. very basic getInfluencedPositions test

   B5 = [ [&  &  &  &  & ]
          [&  &  &  &  & ]
          [&  &  &W &  &B]
          [&  &  &  &  & ] 
          [&  &  &  &  & ] ]
   Bd5 = {Board B5}
   {Assert {T.equalLists {Bd5 getInfluencedPositions(3 3 white $)} 
      [     1#2 1#3 
        2#1 2#2 2#3 
        3#1 3#2 3#3 
        4#1 4#2 4#3 
            5#2 5#3  ] }
   '1st getInfluencedPosition test failed. 
    fyi-test was made for InfluenceRadius=3'}

% 2. another simple getInfluencedPositions test

   B6 = [ [&  &  &  &  & ]
          [&  &  &  &  & ]
          [&  &B &  &  & ]
          [&  &  &  &  & ] 
          [&W &  &  &  & ] ]
   Bd6 = {Board B6}
   {Assert {T.equalLists {Bd6 getInfluencedPositions(5 1 white $)}
      [ 4#1 5#1 5#2 5#3 5#4 ] }
      '2nd getInfluencedPositions test failed. 
       fyi-test was made for InfluenceRadius=3'}

% 3. another simple getInfluencedPositions test with black as a parameter

   B7 = [ [&  &  &  &  & ]
          [&  &  &  &  & ]
          [&  &B &  &  & ]
          [&  &  &  &  & ] 
          [&W &  &  &  & ] ]   
   Bd7 = {Board B7}
   {Assert {T.equalLists {Bd7 getInfluencedPositions(3 2 black $)}
      [ 1#1 1#2 1#3
        2#1 2#2 2#3 2#4
        3#1 3#2 3#3 3#4 3#5
            4#2 4#3 4#4     ] }
      '3rd getInfluencedPositions test failed.
       fyi-test was made for InfluenceRadius=3'}

% 4. a more complex getIinfluence test

   B8 = [ [&  &B &  &  &  & ]
          [&  &  &  &  &W & ]
          [&B &  &  &W &  & ]
          [&  &  &B &W &  & ] 
          [&  &  &  &  &  & ] 
          [&  &  &  &  &  & ] ]
   Bd8 = {Board B8}
   {Assert {T.equalLists {Bd8 getInfluencedPositions(2 5 white $)}
      [     1#5 1#6 
        2#4 2#5 2#6 
            3#5 3#6 ] }
      '4th getInfluencedPositions test failed. 
       fyi-test was made for InfluenceRadius=3'}

%% --------------------------------------------------------------------
%% influence tests
%% warning: test only passes if PlayBoard.InfluenceRadius==3

% 1. very basic influence test

   B9 = [ [&  &  & ]
          [&  &  & ]
          [&  &  &W]]

   Bd9 = {Board B9}

     
   {Assert {T.equalLists 
      {List.filter {Bd9 influence(white $)} RemoveZeroWeights}
      [                 (1#2#white)#1.0 (1#3#white)#1.0
        (2#1#white)#1.0 (2#2#white)#1.0 (2#3#white)#1.0
        (3#1#white)#1.0 (3#2#white)#1.0 (3#3#white)#1.0 ] }
      '1st influence test failed.
       fyi-test was made for InfluenceRadius=3'}

% 2. a simple influence test

   B10 = [ [&  &  &  &  & ]
           [&  &  &  &  & ]
           [&  &  &W &  &B]
           [&  &  &  &  & ] 
           [&  &  &  &  & ] ]

   Bd10 = {Board B10}

   {Assert {T.equalLists 
      {List.filter {Bd10 influence(white $)} RemoveZeroWeights}
      [                 (1#2#white)#1.0 (1#3#white)#1.0
        (2#1#white)#1.0 (2#2#white)#1.0 (2#3#white)#1.0
        (3#1#white)#1.0 (3#2#white)#1.0 (3#3#white)#1.0
        (4#1#white)#1.0 (4#2#white)#1.0 (4#3#white)#1.0
                        (5#2#white)#1.0 (5#3#white)#1.0  ] }
      '2nd influence test failed.
       fyi-test was made for InfluenceRadius=3'}
      
% 3. another simple influence test

   B11 = [ [&  &  &B &  & ]
           [&  &  &  &  & ]
           [&  &  &W &  &B]
           [&  &  &  &  & ] 
           [&  &  &  &  & ] ]

   Bd11 = {Board B11}
   {Assert {T.equalLists 
      {List.filter {Bd11 influence(black $)} RemoveZeroWeights}
      [(1#5#black)#2.0
       (1#1#black)#1.0 (1#2#black)#1.0 (1#3#black)#1.0 (1#4#black)#1.0
       (2#5#black)#1.0 (3#5#black)#1.0 (4#5#black)#1.0 (5#5#black)#1.0 
                                                                      ] }
      '3rd influence test failed.
       fyi-test was made for InfluenceRadius=3'} 


%% getInfluence Test
   B12 = [ [&  &  &B &  & ]
           [&  &  &  &  & ]
           [&  &  &W &  &B]
           [&  &  &  &  & ] 
           [&  &  &  &  & ] ]
   Bd12 = {Board B12}
   {Assert {Bd12 getInfluence(1 5 $)}==(black#2.0)
      'getInfluence test failed.'
   }

   {Application.exit 0}

end


