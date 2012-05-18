The purpose of this document is to explain the structure and functions of
current version of the Go program (5/16/12). 


Table of Contents:

   1) Overview of program

   2) The Player
        -Related files
        -purpose of files
        -Pretty Picture
        -Communication

   3) The AI
        -Related files
        -purpose of files
        -Pretty Picture
        -Communication

   4) The Initiator/Manager
        -Related files
        -purpose of files
        -Pretty Picture
        -Communication

   5) Extras
        -Unused files




@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@ Overview @@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

The Go program is currently written completely in Oz/Mozart but we have
considered moving it into Python. Since the future language of the program
is undetermined, I will primarily focus on data units common to any 
language (e.g. objects, lists/arrays, functions).

The Go program has a few large components that interact:

    Player - The component that will display the board to a human and
               allow them to play against the AI

    AI - The component that when given a Go Board decides where the
          will make its move.

    Initiator/Manager - Sets up the connection between two contestants
                         (Contestants could be Players or AIs)
                        Could continue to run after the game and do
                         analysis of the game (Genetic Algorithm?)

     ________________        ____________        ________________
    |                |      |            |      |                |
    |   Contestant   |      | Initiator/ |      |   Contestant   |
    | (player or AI) | <==> |  Manager   | <==> | (player or AI) |
    |________________|      |____________|      |________________|




@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@ The Player @@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

Purpose: Recieve information from the Initiator/Manager about the board
                  (e.g. Board size, location of each stone, User's color).
         Display this information nicely to the User.

         Recieve information from the User about where they want to play
            or if they want to pass, reset the game, etc.
         Format this information and pass it on to the Initiator/Manager.



Related files: Player.oz
               GuiBoard.oz

  Player : Object that creates the GUI and will interface with the GUI
             to decide what move the user wants to make.
           Also able to process commands like "New Game", "Quit", etc.

  GuiBoard : Object that creates a user interface that displays the 
               current Board and lets the player decide where to play. 
             (The orange screen)



Picture of how the components of the Player are connected:
   __________________________________________________       ____________
  |   _________        __________        ________    |     |            |
  |  | The User|      | GUIBoard |      | Player |   |     | Initiator/ |
  |  |  (You)  | <==> |          | <==> | Object | <=====> |  Manager   |
  |  |_________|      |__________|      |________|   |     |            |
  |__________________________________________________|     |____________|


Player Object Communications:

 The Player Object will respond to method calls from a Talker in the
   Initiator/Manager by making a method on the GUI that updates the display

 The Player Object will respond to method calls from the GUI by formatting
   the information and passing it on to the Initiator/Manager


GUI Board Communications:

 The GUI Board will respond to the buttons on it being pressed by making
   the corresponding method call on the Player Object

 The GUI Board will respond to updates from the Player Object by adjusting
   the board image that it is displaying to the user.




@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@   The AI   @@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

Purpose:

Related files: Everything in the lobes Directory
               Brain.oz
               EmptyLobe.oz
               EmptyBooleanLobe.oz
               AIGui.oz
               ClusterTools.oz
               JAZTools.oz
               LobeTools.oz
               Territory.oz
               ArctanInfl.oz
               PseudoTerritory.oz
               SimpleBoard.oz
               SmartBoard.oz
               PlayBoard.oz

   EmptyLobe : Abstract class that all lobes are children of. Contains the
                 basic functions that every lobe needs and deals with all
                 concurrency involved in lobes.
               Does not implement any calculations (that's for sub-classes)
               Each lobe runs concurrently following this process:

                  1) wait for update from Brain
                  2) calculate values for the new update until done or the
                       lobe receives a new update
                  3) repeat


   EmptyBooleanLobe : Abstract class that extends the EmptyLobe.
                      This class will walk the board and apply a generic
                        method to every location asking for its ranking.

   All the Lobes : These are objects that extend either of the above classes
                   They define one method of analyzing the board and determine
                     a value [-1, 1] for each location.
                   They all run concurrently.

   ClusterTools : lots of utility functions/procedures used by lobes

   LobeTools : lots of utility functions/procedures used by lobes

   JAZTools : lots of utility functions/procedures used by lots of the program

   Brain : Object that will follow this general process:
              1) Receive Board update from Initiator/Manager
              2) Send Board information to the Lobe threads
              3) Wait for a few seconds
              4) Get result from all Lobe threads and reset any threads that
                   didn't finish
              5) Update AI GUI
              6) Return best move to Initiator/Manager

   SimpleBoard : Object that contains basic information about game history
                   and locations of stones.
                 it contains methods to "play" a stone on the board and it
                   will remove any stones killed as a result.

   SmartBoard : Object that extends SimpleBoard, it adds information about
                  every cluster of stones on the board.
                This information will be cached to prevent recalculating, and
                  each turn it uses the previous turn's information to shorten
                  its calculations.

   PlayBoard : Object that extends SmartBoard, it adds a lot of new information
                 to the caches and gives methods to get a stateless image of the
                 board and to initialize a board to a stateless image.
               The new information added to the cache relate to:
                 -Manhattan Influence (functions involved are defined in this file)
                 -Arctan Influence           (defined in ArctanInfl.oz)
                 -Manhattan Pseudo Territory (defined in PseudoTerritory.oz)
                 -Manhattan Pseudo Territory (defined in PseudoTerritory.oz)
                 -Complete Territory         (defined in Territroy.oz)

   Territory : utility functions/procedures that are find each player's
                 completely surrounded territory
 
   ArctanInfl : utility functions/procedures that are find each player's
                 Influence using the arctan method
  
   PseudoTerritory : utility functions that are find each player's pseudo 
                       territory using either manhattan or arctan methods

   AIGUI : Graphics screen that has no control over the AI but displays the
             rankings from each lobe, and the results from calculating
             Manahttan and arctan influence and pseudo territory.
           (The blue screen)



Picture of how the components of the AI are connected:
   _________________________________
   |  ________      ____________    |     ____________
   | |        |    |            |   |    |            |
   | | Lobe 1 |<==>| Brain      |   |    | Initiator/ |
   | |________|    |  _________ | <====> |  Manager   |
   |     .         | |PlayBoard||   |    |            |
   |     .        /| |_________||   |    |____________|
   |     .       //|____________|   |
   |  ________  //        ||        |
   | |        |//      ________     |
   | | Lobe n |/      | AI GUI |    |
   | |________|       |________|    |
   |________________________________|


Brain Communications:
  
  The Brain will respond to requests for a new from the Initiator/Manager
    by following the process defined above for Brain.

  The Brain will update each lobe by sending it a stateless copy of its
    PlayBoard after it fills the caches in the PlayBoard.

  The Brain will get values from the Lobes by calling some "getter" 
    method that will return the list of rankings they have committed

  I don't know how the Brain communicates with the AI GUI :(


Lobe Communications:
  
  Lobes are active objects that react to method calls from the Brain.
  Detailed notes on how the lobes run can be found in EmptyLobe.oz


AI GUI Communications:

   I don't know how the Brain communicates with the AI GUI :(




@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@ Initiator/Manager @@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

Purpose:

Related Files: PlayGoKD.oz
               PlayGoAI.oz
               PlayGoDebug.oz
               PlayGoGenetic.oz
               Initiator.oz
               Genetic Algorithm Related Files
               Server.oz
               Talker.oz
               TalkerTools.oz

   PlayGo___ : Little files that start the program by giving the parameters
                 that determine board size, contestant types, etc. as a call
                 to the Initiator or some kind of Genetic Algorithm initiator

   Initiator : This file initiates both the contestants and will setup the
                 server and talkers between them.

   Genetic Algorithm Stuff : Runs a genetic algorithm managing the populations
                               and genomes. It will setup many servers to run
                               games between AIs and receives results back
                               about the games.

   Server : Manages a game between two contestants. It will send updates to
              each contestant and process there moves.
            After the game, it may send results back to whoever initated the
              game.

   Talker : Interface that formats the information from each contestant to 
              the form that is nicely given to the Server.
            If the program becomes distributed this may need to serve as a
              networking interface between the components.

   TalkerTools : lots of utility functions/procedures used by Talkers



Picture of how the components of the Initiator/Manager are connected:
                  ______________________________________
                 |              ___________             |
                 |             |           |            |
                 |             | PlayGo___ |            |
                 |             |           |            |
                 |             |___________|            |
                 |                  ||                  |
                 |              ___________             |
                 |             | Initiator/|            |
                 |             |  Genetic  |            |
                 |             |   Stuff   |            |
                 |             |___________|            |
                 |                  ||                  |
    __________   |   ______      ________      ______   |   __________
   |          |  |  |      |    |        |    |      |  |  |          |
   |Contestant|  |  |Talker|    | Server |    |Talker|  |  |Contestant|
   |          |<===>|      |<==>|        |<==>|      |<===>|          |
   |__________|  |  |______|    |________|    |______|  |  |__________|
                 |______________________________________|


Talker Communications: Object that will make method calls on the
                         contestant to receive its moves and give
                         the contestant updates.
                       Receives information from the Server through
                         method calls


Server Communications: Object created by Initiator/Some Genetic Thing
                         and it will return game results to its creator
                         when it finishes its game
                       Communicates with talkers by calling their methods


Initiator Communications: Creates a Server and both contestants. Then
                            it either terminates or waits until the game
                            finishes and does something form of
                            calculation (e.g. Genetic Algorthim)


PlayGo___ Communications: Just calls a function or something starting the
                            Initiator/Genetic Algorithm Stuff and then ends
                          Just servers to make an executable in Oz.




@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@ Extras @@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

Files that are unused as far as I know: Controller.oz
                                        SimpleBoard2.oz
                                        SimpleBoardOK.oz
                                        Activize.oz
                                        










