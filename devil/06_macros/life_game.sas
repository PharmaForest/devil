/*** HELP START ***//*

Program     : %life_game
 Description : Simulates Conway's Game of Life in SAS and generates an animated GIF output.
               Uses a grid of cells initialized randomly or from an input dataset, applies 
               the life game rules iteratively, and visualizes the process as a heatmap animation.

 Author      : Yutaka Morioka
  License : MIT 

 Parameters  :
   outpath       - File path to save the output GIF.
   outfilename   - Name of the output GIF file (default: lifegame).
   seed          - Random seed for initial cell generation (default: 777).
   loop          - Number of iterations (animation frames) to simulate (default: 50).
   xwide         - Width of the grid (default: 50).
   ywide         - Height of the grid (default: 50).
   ds            - Optional input dataset to use as the initial grid. If not provided,
                   a random grid will be generated.

 Output      :
   Animated GIF file showing the evolution of the Game of Life simulation.

 Notes       :
 - The initial grid is either randomly generated or taken from the specified dataset.
 - Each cell's state is updated based on the standard rules of Conway's Game of Life.
 - The macro uses SAS hash objects to efficiently access neighbor cells.
 - The animation is rendered using PROC SGPLOT with heatmap visualization.

 Usage Example:
   %life_game(outpath=D:\Users\Example\Output, outfilename=mygame, loop=100, xwide=60, ywide=60);

*//*** HELP END ***/

%macro life_game(outpath=,outfilename=lifegame,seed=1234,loop=50,xwide=50,ywide=50,ds=);
	data __wk1;
	call streaminit(&seed);
	do x=1 to &xwide.;
	 do y=1 to &ywide.;
	  if rand("uniform")<0.5 then v=1;
	  else v=0;
	  output;
	 end;
	end;
	run;
 %if %length(&ds) ne 0 %then %do;
    data __wk1;
        set &ds;
    run;
 %end;
	
	%macro calc;
	data __wk2;
	 set __wk2;
	  if _N_=1 then do;
	   call missing(of  cx cy cv);
	   declare hash h1(dataset:"__wk2(rename=(x=cx y=cy v=cv))");
	   h1.definekey("cx","cy");
	   h1.definedata("cv","cx","cy");
	   h1.definedone();
	  end;
	  if h1.find() ne 0  then call missing(of cx cy cv);
	
	  cx=x;
	  cy=y;
		
	  cx=x-1;
	  cy=y-1;
	  if h1.find() ne 0  then xm1ym1=0;
	  else xm1ym1=cv;
	
   cx=x;
	  cy=y-1;
	  if h1.find() ne 0  then x0ym1=0;
	  else x0ym1=cv;
	
	  cx=x+1;
	  cy=y-1;
	  if h1.find() ne 0  then xp1ym1=0;
	  else xp1ym1=cv;
	
	  cx=x-1;
	  cy=y;
	  if h1.find() ne 0  then xm1y0=0;
	  else xm1y0=cv;
	
	  cx=x+1;
	  cy=y;
	  if h1.find() ne 0  then xp1y0=0;
	  else xp1y0=cv;
	
	  cx=x-1;
	  cy=y+1;
	  if h1.find() ne 0  then xm1yp1=0;
	  else xm1yp1=cv;
	
	  cx=x;
	  cy=y+1;
	  if h1.find() ne 0  then x0yp1=0;
	  else x0yp1=cv;
	
	  cx=x+1;
	  cy=y+1;
	  if h1.find() ne 0  then xp1yp1=0;
	  else xp1yp1=cv;
	
	  count=sum(of xm1ym1 x0ym1 xp1ym1 xm1y0 xp1y0 xm1yp1 x0yp1 xp1yp1 );
	
	  if v = 1 then do;
		if count in (2:3) then v = 1;
		else v = 0;
	  end;
	   if v = 0 then do;
		if count =3 then v = 1;
		else v = 0;
	  end;
	
	  drop cx cy  cv xm1ym1 x0ym1 xp1ym1 xm1y0 xp1y0 xm1yp1 x0yp1 xp1yp1 count;
	 run;
	
	proc sgplot data=__wk2;
	styleattrs datacolors=(white gray);
	   heatmapparm x=x y=y colorgroup=v / outline  ;
	run;
	%mend;

	%macro loop(times=5);
	 proc sgplot data=__wk1;
	 styleattrs datacolors=(white gray);
	   heatmapparm x=x y=y colorgroup=v / outline ;
	   gradlegend;
	run;
	data __wk2;
		set __wk1;
	run;
	%do i=1 %to &times;
	 %calc;
	%end;
	%mend;

 	ods _all_ close;
 	ods listing;
 	options  nodate animation=start  animduration=0.5   printerpath=gif  ;
 	ods printer file="&outpath\&outfilename..gif";
   	%loop(times=&loop.)
 	options  animation=stop ;
 	ods printer close ;

%mend;
