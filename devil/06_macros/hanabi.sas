/*** HELP START ***//*

This macro is to celebrate something with fireworks!

Parameters
	- giffile: full path for gif file to create
	- ite: iteration number from 1 to 151(record number of __color_list)

*//*** HELP END ***/

%macro hanabi(giffile=C:\temp\hanabi.gif, ite=10) ;

%loadPackage(misc)
%color_swatch()

options printerpath=gif animation=start animduration=1 animloop=yes noanimoverlay;
ods printer printer=gif file="&giffile" ; 

    %do t=1 %to &ite.;

		data fireworks;
		rad = constant('pi')/180;
		call streaminit(0);
		  xpos = rand("uniform",-30,30);
		  ypos = rand("uniform",-30,30);
		  do rmax = 0, 36;
		  do r = 0 to rmax by 4;
		  do a = 0 to 360 by 15;
		    x=cos(a*rad)*r+xpos;
		    y=sin(a*rad)*r+ypos;
		    output;
		  end;
		  end;
		  end;
		run;

		data _null_ ;
			set __color_list ;
			if _n_=&t. then call symput("color", color) ;
		run ;
		
		title "&color." ;
		proc sgplot data=fireworks aspect=1 noautolegend;
		  styleattrs wallcolor=midnightblue;
		  scatter x=x y=y / markerattrs=(symbol=circlefilled color=&color. size=0.2cm );
		  xaxis min=-50 max=50 display=none;
		  yaxis min=-50 max=50 display=none;
		  inset "Congratulations!!!"/ position=bottom textattrs=(color=lightblue size=25cm family="Arial");
		  by rmax;
		run;
    %end;
ods printer close;
options animation=stop ;
%mend;
