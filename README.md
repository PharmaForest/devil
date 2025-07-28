# devil (latest version 0.0.4 on 25July2025)
Welcome to **DEVIL (Developer's Ideas Library)!**  

<img src="https://github.com/PharmaForest/devil/blob/main/devil_logo.png?raw=true" alt="logo" width="300"/>

**Share your devils (any ideas at any stage)** for trial, inspiring, showing-off, recruiting members for further development by showing POC, or even joking(for fun). You can see in description.sas of devil package that author is "Any Developers". Devil package is completely different from the other packages in PharmaForest **with its highly collaborative nature to welcome any ideas from anyone** regardless of usefulness(we would rather prefer playful ones😁). First devils are provided in advance for reference. Knock the door of devil.  

*Devil package is said to be an ancient SAS package that has existed for 400 years. Within it dwell unseen devils, ready to threaten the world. It is said to have the power to summon them—or even lock up your own devils. (Just kidding!)*  

## 1. %chatDMS() :  
Chat application in SAS DMS(Display Manager System) for those who cannot afford Viya Copilot😂  
This is available only for DMS. You need your API key for openAI or google to use the app.  

Sample code:
~~~sas
%chatDMS(
  provider=google,           /* AI provider(only openAI and Google available) */
  model=gemini-1.5-flash,    /* Model information */
  apikey=xxxxxxxxxxxxxxx,    /* API key */
  max_tokens=512)            /* Max token */
~~~  
Author: Ryo Nakaya  
Date: 2025-07-21  
Version: 0.1  

## 2. text2morse() : Function 
text2morse is a function that converts text to Morse code.  
<img src="https://github.com/PharmaForest/devil/blob/main/sub_logo/text2morse_mini.png?raw=true" alt="logo" width="150"/>  
Sample code:
~~~sas
data test;
length x $200.;
x = "I M  WITH YOU ";output;/*Captain America: The First Avenger*/
x = "STAY";output; /*Interstellar*/
x = "SO HOPING";output; /*Parasite*/
run;

data a;
set test;
y = text2morse(x);
run;
~~~
<img width="465" height="55" alt="Image" src="https://github.com/user-attachments/assets/2133addd-9188-461f-b201-73fabc368883" />  

Author: Yutaka Morioka  
Date: 2025-07-22  
Version: 0.1  

## 3. %life_game() :  
<img src="https://github.com/PharmaForest/devil/blob/main/sub_logo/life_game.png?raw=true" alt="logo" width="150"/>  
If you're tired of work, watch Life Game and reevaluate your life.  

![Image](https://github.com/user-attachments/assets/c15206ef-7240-4229-8505-4955297f1b86)  
Simulates Conway's Game of Life in SAS and generates an animated GIF output. Uses a grid of cells initialized randomly or from an input dataset, applies the life game rules iteratively, and visualizes the process as a heatmap animation.

 Parameters  :  
 ~~~text
   outpath       - File path to save the output GIF.
   outfilename   - Name of the output GIF file (default: lifegame).
   seed          - Random seed for initial cell generation (default: 777).
   loop          - Number of iterations (animation frames) to simulate (default: 50).
   xwide         - Width of the grid (default: 50).
   ywide         - Height of the grid (default: 50).
   ds            - Optional input dataset to use as the initial grid. If not provided,
                   a random grid will be generated.
~~~

Sample code:
 ~~~sas
   %life_game(outpath=D:\Users\Example\Output, outfilename=mygame, loop=100, xwide=60, ywide=60);
~~~
Author: Yutaka Morioka  
Date: 2025-07-23  
Version: 0.1 

## 4. %sudoku_solver()

Sudoku solver is finally in SAS!  

Parameters :
~~~text
  puzzle=     : the Sudoku puzzle converted into a SAS dataset (Refer to the following 'prerequisites' section!)  
  outputpath= : the directory where the results are output (LOG file or RTF file when rtfYN=Y)  
  rtfYN=      : Default is N. If you change this parameter to Y, an RTF output will be created in 'outputpath'.  
~~~

Sample code :  
~~~sas
%sudoku_solver(
    puzzle=__sudoku__,  
    outputpath=/home/XXXXX/sudoku/, 
    rtfYN=Y
   )
/*example data*/
data sudoku1;
 input c1-c9 8.;
 cards;
0 0 2 3 0 0 5 0 0
4 0 0 0 8 0 0 1 0
0 0 9 0 0 4 0 0 6
0 2 0 0 7 0 1 0 8
6 0 0 5 0 9 0 0 3
1 0 3 0 4 0 0 7 0
9 0 0 8 0 0 2 0 0
0 8 0 0 6 0 0 0 9
0 0 7 0 0 1 3 0 0
;
~~~

<img src="https://github.com/PharmaForest/devil/blob/main/sudoku.png?raw=true" alt="sudoku" width="300"/>

### Other
 - "Sudoku" is a registered trademark of Nikoli. (https://www.nikoli.co.jp/ja/puzzles/sudoku/)
 - The maximum number of backtracks is set to 50,000. 
 - This is because most Sudoku puzzles can be solved within 50,000 backtracks.
 - If there is a request to specify the number of backtracks in the macro parameter, I will consider it:)
 
Author:      Miyuki Aso  
Date:        2025-07-25  
Version:     0.1


## Version history  
0.0.4(25July2025) : Added %sudoku_solver()  
0.0.3(23July2025)	: Added %life_game()  
0.0.2(22July2025)	: Added text2morse function  
0.0.1(21July2025)	: Initial version

## What is SAS Packages?
The package is built on top of **SAS Packages framework(SPF)** developed by Bartosz Jablonski.  
For more information about SAS Packages framework, see [SAS_PACKAGES](https://github.com/yabwon/SAS_PACKAGES).  
You can also find more SAS Packages(SASPACs) in [SASPAC](https://github.com/SASPAC).

## How to use SAS Packages? (quick start)
### 1. Set-up SPF(SAS Packages Framework)
Firstly, create directory for your packages and assign a fileref to it.
~~~sas      
filename packages "\path\to\your\packages";
~~~
Secondly, enable the SAS Packages Framework.  
(If you don't have SAS Packages Framework installed, follow the instruction in [SPF documentation](https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation) to install SAS Packages Framework.)  
~~~sas      
%include packages(SPFinit.sas)
~~~  
### 2. Install SAS package  
Install SAS package you want to use using %installPackage() in SPFinit.sas.
~~~sas      
%installPackage(packagename, sourcePath=\github\path\for\packagename)
~~~
(e.g. %installPackage(ABC, sourcePath=https://github.com/XXXXX/ABC/raw/main/))  
### 3. Load SAS package  
Load SAS package you want to use using %loadPackage() in SPFinit.sas.
~~~sas      
%loadPackage(packagename)
~~~
### Enjoy😁
---

