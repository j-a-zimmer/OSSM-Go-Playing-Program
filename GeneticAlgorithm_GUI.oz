functor
   import QTk at 'x-oz://system/wp/QTk.ozf'
          GuiBoard
   export GeneticGUI
define
   class GeneticGUI from GuiBoard.gBoard
      feat browseKing label_Black label_White label_GameID browseBlack browseWhite label_Time
   
      meth init(Player
                Size<=19 
                Scale<=30.0
                BrowseKingProc
                BrowseBlackProc
                BrowseWhiteProc)
                
         proc {LClickAction R C} skip end
         proc {RClickAction R C} skip end
       in                            
         self.browseKing = BrowseKingProc
         self.browseBlack = BrowseBlackProc
         self.browseWhite = BrowseWhiteProc
       
         GuiBoard.gBoard,init(Player Size Scale LClickAction RClickAction  _ c(255 104 104))
      end
      
      meth setupGameLabel(GameID GenID GenRound BScore WScore)
         {self.label_GameID set(text:{VirtualString.toAtom 'Game ID: '#GameID#'\nGeneration ID: '#GenID#'\nGeneration Round: '#GenRound#'\n\nChallenge Score\n'#BScore#'     |     '#WScore#'\n'})}
      end
      
      meth setupBlackLabel(PID RID Gen)
         {self.label_Black set(text:{VirtualString.toAtom '-Black-\nPop ID: M'#PID#'\nReal ID: '#RID#'\nGeneration: '#Gen})}
      end
      
      meth setupWhiteLabel(PID RID Gen)
         {self.label_White set(text:{VirtualString.toAtom '-White-\nPop ID: M'#PID#'\nReal ID: '#RID#'\nGeneration: '#Gen})}
      end
      
      meth setupTimeLabel(TotalTime NumGames CurrentGameTime)
         proc {GetTimeAtom Time ?R}
            H = Time div 3600
            HS = H * 3600
            M = (Time - HS) div 60
            S = Time - HS - (M * 60)
            HAtom MAtom SAtom
          in
            if (H < 10) then HAtom = '0'#H else HAtom = H end
            if (M < 10) then MAtom = '0'#M else MAtom = M end
            if (S < 10) then SAtom = '0'#S else SAtom = S end
            R = HAtom#':'#MAtom#':'#SAtom
         end
         
         A
       in
         if (NumGames == 1) then A = 1 else A = NumGames - 1 end
         {self.label_Time set(text:{VirtualString.toAtom '\nTotal Time: '#{GetTimeAtom TotalTime}#
                                      '\nAverage Game Time: '#{GetTimeAtom ((TotalTime - CurrentGameTime) div A)}#
                                      '\nCurrent Game Time: '#{GetTimeAtom CurrentGameTime}})}
      end
      
      meth buildWindow(MainBoard MainButtons NumPixels ?Window)
         Spacer = label(text: '')
                      
         GameID = label(text: 'Game ID: 00001\nGeneration ID: 0001\nGeneration Round: 0000\n\nChallenge Score\n0     |     0\n' 
                      justify: 'center'
                      handle: self.label_GameID)
         BlackName = label(text: '-Black-\nPop ID: M1\nReal ID: 10000\nGeneration: 100' 
                      handle: self.label_Black
                      justify: 'center')
         WhiteName = label(text: '-White-\nPop ID: M1\nReal ID: 10000\nGeneration: 100' 
                      justify: 'center'
                      handle: self.label_White)
                      
         TimeLabel = label(text: '\nTotal Time: 00:00:00\nAverage Game Time: 00:00\nCurrent Game Time: 00:00' 
                      justify: 'center'
                      handle: self.label_Time)
                      
         BrowseKingButton = button(text:'Browse King' action:self.browseKing width:15)
         BrowseBlackButton = button(text:'Browse Black' action:self.browseBlack width:15)
         BrowseWhiteButton = button(text:'Browse White' action:self.browseWhite width:15)
       in
         Window = {QTk.build lr(MainBoard td(GameID lr(BlackName WhiteName) Spacer BrowseKingButton TimeLabel))}
      end
   end
end

