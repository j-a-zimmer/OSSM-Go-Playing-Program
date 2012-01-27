functor

import PlayBoard JAZTools System Application Browser ClusterTools

define

   T = JAZTools
   Assert = T.assert

   Pr = {T.setWriter System.showInfo}

   fun {Board SetUp}
      Size = {Length SetUp.1}
      Conv = JAZTools.vList2BList
   in
      {New PlayBoard.pBoard init(Size {Conv SetUp})}
   end

   B1 R1a R1b C1a C1b C1c
   B2 R2a R2b R2c R2d R2e R2f C2a C2b C2c

   FieldFunc K

in

%% Test Immortal:

   B1 = [ [&  &W &  &  &  &B &  &B]
   	  [&W &  &W &  &B &B &B &B]
   	  [&  &W &  &W &  &  &  & ]
   	  [&W &  &W &  &  &  &  & ]
   	  [&W &W &  &  &B &B &B & ]
   	  [&  &W &  &  &B &  &B & ]
   	  [&W &W &  &  &  &B &  &B]
   	  [&  &W &  &  &  &B &B &B] ]

   C1a = {{Board B1} cluster(5 1 $)}
   C1b = {{Board B1} cluster(5 5 $)}
   C1c = {{Board B1} cluster(7 6 $)}
   {ClusterTools.immortal {Board B1} R1a}
   R1b = {List.map R1a fun {$ X} X.stones end $}
   {Assert {List.member C1a.stones R1b $} 'first cluster immortal'}
   {Assert {List.member C1b.stones R1b $} 'second cluster immortal'}
   {Assert {List.member C1c.stones R1b $} 'third cluster immortal'}
   {Assert {List.length R1a $}==3 'no other clusters immortal'}

%% Test cluster equality:

   B2 = {Board [ [&B &  &  &  &  &  &  ]
		 [&B &B &  &  &  &B &  ]
		 [&B &  &  &B &B &B &B ]
		 [&B &  &  &  &  &  &  ]
		 [&  &  &  &  &  &  &  ]
		 [&  &  &  &B &  &  &  ]
		 [&  &B &B &B &B &  &  ] ]}

   C2a = {ClusterTools.list2Stones {B2 cluster(1 1 $)}.stones B2}
   C2b = {ClusterTools.list2Stones {B2 cluster(7 2 $)}.stones B2}
   C2c = {ClusterTools.list2Stones {B2 cluster(3 4 $)}.stones B2}
   {ClusterTools.equivalent C2b C2c B2 R2a R2b R2c}
   {Assert R2c 'clusters equivalent (1)'}
   {Assert R2b==0#0 'correct rotation and reflection (1)'}
   {Assert R2a==(~4)#2 'correct translation (1)'}
   {ClusterTools.equivalent C2b C2a B2 R2d R2e R2f}
   {Assert R2f 'clusters equivalent (2)'}
   {Assert R2e==2#1 'correct rotation and reflection (2)'}
   {Assert {ClusterTools.equal {ClusterTools.convert C2b R2d R2e B2 $} C2a B2 $} 're-conversion equal (2)'}

%  Test influence function
   K=25.0
   FieldFunc = fun {$ R1#C1 R2#C2}
		  {Float.'/' K {Int.toFloat ((R1-R2)*(R1-R2)+(C1-C2)*(C1-C2))}}
	       end
   {Assert {ClusterTools.influence B2 3#4#_ FieldFunc $}.(21)==1.25 'influence fails'}
   
   {Application.exit 0}

end
