/*** HELP START ***//*

Here is the explanation of %sudoku_solver.

### Sample code
puzzle=     : the Sudoku puzzle converted into a SAS dataset (Refer to the following 'prerequisites' section!)
outputpath= : the directory where the results are output (LOG file or RTF file when rtfYN=Y)
rtfYN=      : Default is N. If you change this parameter to Y, an RTF output will be created in 'outputpath'.
~~~sas
%sudoku_solver(
    puzzle=__sudoku__, 
    outputpath=/home/XXXXX/sudoku/, 
    rtfYN=Y
   )
~~~

### prerequisites
 <For input data> 
 Please convert the Sudoku puzzle you want to solve into a dataset as shown in the example below.
 (It must be SAS dataset with 9 numeric variables (c1-c9) and 9 observations.)
 Note: 
  - Fill the blank spaces in the puzzle with 0. 
  - Make sure to name the variables strictly as c1-c9, but the dataset name can be anything.
 
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

### Other
 - "Sudoku" is a registered trademark of Nikoli. (https://www.nikoli.co.jp/ja/puzzles/sudoku/)
 - The maximum number of backtracks is set to 50,000. 
 - This is because most Sudoku puzzles can be solved within 50,000 backtracks.
 - If there is a request to specify the number of backtracks in the macro parameter, I will consider it:)
 
* Author:      Miyuki Aso
* Date:        2025-07-25
* Version:     0.1

*//*** HELP END ***/

%macro sudoku_solver(puzzle=, outputpath=,rtfYN=N);
  options nodate nonumber;
  options nosource nonotes;
  options formdlim="-";
  options pagesize=1000;
  ods html close;
  ods listing;
  proc printto log="&outputpath.sudoku_answer.log" new; *--Output Log START;
  run;

  %let START_TIME=%sysfunc( datetime() ); *Measuring processing time: Start time;
  %put %sysfunc( putn(&START_TIME., e8601dt. -L) );
  %put ***[START]**********************************************;
  %put <<========Puzzle=========>>;
  data _null_;
    set &puzzle.;
    put (_all_) (+0);
  run;
  /*=======================================================================*/
  data __sudoku__;
    set &puzzle.;
  run;
  *----------------------------------------------------------------------;
  /*for ROW*/
  proc transpose data=__sudoku__ out=__sudoku__trn(drop=_NAME_) prefix=r;
    var c1-c9;
  run;

  /*for BOX*/
  data _bl1 _bl2 _bl3;
    set __sudoku__;
    num=_n_;
    if num in (1, 2, 3) then output _bl1;
    if num in (4, 5, 6) then output _bl2;
    if num in (7, 8, 9) then output _bl3;
  run;

  %macro tranblx();
    %do K=1 %to 9;
      %let m=%eval(%sysfunc(int(%eval(&K.-1)/3))+1);
      %let n1=%eval(%sysfunc(mod(%eval(&K.+2), 3))*3+1);
      %let n2=%eval(%sysfunc(mod(%eval(&K.+2), 3))*3+2);
      %let n3=%eval(%sysfunc(mod(%eval(&K.+2), 3))*3+3);

      proc transpose data=_bl&m.  out=_b&K.(drop=num _NAME_);
        var c&n1. c&n2. c&n3.;
        by num;
      run;
    %end;
  %mend;
  %tranblx;
  *----------------------------------------------------------------------;
  options cmplib=_null_; 
  proc fcmp outlib=work.funcs.temp;
    *[function 1] A function to check the possible numbers;
    function check_row(value, Q[*]) varargs;
      total=0;
      do p=1 to dim(Q);
      if Q[p]=value then total+1;
      end;
      return(total);
    endsub;
  
    *[function 2] A subroutine to solve Sudoku.;
    subroutine solve_sudoku(rx, cy, kz, numbt, __backtrack);
      outargs __backtrack; 
    
      *Matrix declaration (input, output);
      array inp[9, 9] / nosymbols;
      rc=read_array('__sudoku__', inp);
      array outp[9, 9] / nosymbols; 
    
      *Array declaration (for number checking and updating);
      %macro X_read_array();
        %do I=1 %to 9;
          array R&I.[9, 1] / nosymbols;
          array trn_R&I.[1, 9] / nosymbols;
          rc=read_array('__sudoku__trn', R&I., "r&I.");
          call transpose(R&I., trn_R&I.);
          array C&I.[9, 1] / nosymbols;
          array trn_C&I.[1, 9] / nosymbols;
          rc=read_array('__sudoku__', C&I., "c&I.");
          call transpose(C&I., trn_C&I.);
          array B&I.[9, 1] / nosymbols;
          array trn_B&I.[1, 9] / nosymbols;
          rc=read_array("_b&I.", B&I., "COL1");
          call transpose(B&I., trn_B&I.);
        %end;
      %mend X_read_array;
      %X_read_array;
    
      r_snum=rx;
      c_snum=cy;
      k_snum=kz;
      __backtrack=0;

      *Do Loop (Backtracking Method);
      do until (__backtrack=numbt); *AAAAA;
        __backtrack+1;
        call missing(check, check_b);
     
        *==>>>Forward-----------------------;
        do i=r_snum to 9; *<<mkrdi>>;
          do j=c_snum to 9; *<<mkrdj>>;
            if inp[i, j]=0 then do; *<<mkrx1>>;
                do k=k_snum to 9; * ***;
                
                  *1. The same number cannot appear in the same row.;
                  if i=1 and check_row(k, trn_R1)=0 then _ok_r=1;
                  if i=2 and check_row(k, trn_R2)=0 then _ok_r=1;
                  if i=3 and check_row(k, trn_R3)=0 then _ok_r=1;
                  if i=4 and check_row(k, trn_R4)=0 then _ok_r=1;
                  if i=5 and check_row(k, trn_R5)=0 then _ok_r=1;
                  if i=6 and check_row(k, trn_R6)=0 then _ok_r=1;
                  if i=7 and check_row(k, trn_R7)=0 then _ok_r=1;
                  if i=8 and check_row(k, trn_R8)=0 then _ok_r=1;
                  if i=9 and check_row(k, trn_R9)=0 then _ok_r=1;
                  
                  *2. The same number cannot appear in the same column.;
                  if j=1 and check_row(k, trn_C1)=0 then _ok_c=1;
                  if j=2 and check_row(k, trn_C2)=0 then _ok_c=1;
                  if j=3 and check_row(k, trn_C3)=0 then _ok_c=1;
                  if j=4 and check_row(k, trn_C4)=0 then _ok_c=1;
                  if j=5 and check_row(k, trn_C5)=0 then _ok_c=1;
                  if j=6 and check_row(k, trn_C6)=0 then _ok_c=1;
                  if j=7 and check_row(k, trn_C7)=0 then _ok_c=1;
                  if j=8 and check_row(k, trn_C8)=0 then _ok_c=1;
                  if j=9 and check_row(k, trn_C9)=0 then _ok_c=1;
                       
                  *3. The same number cannot appear in the same BOX;
                  if i in (1, 2, 3) and j in (1, 2, 3) and check_row(k, trn_B1)=0 then _ok_b=1;
                  if i in (1, 2, 3) and j in (4, 5, 6) and check_row(k, trn_B2)=0 then _ok_b=1;
                  if i in (1, 2, 3) and j in (7, 8, 9) and check_row(k, trn_B3)=0 then _ok_b=1;
                  if i in (4, 5, 6) and j in (1, 2, 3) and check_row(k, trn_B4)=0 then _ok_b=1;
                  if i in (4, 5, 6) and j in (4, 5, 6) and check_row(k, trn_B5)=0 then _ok_b=1;
                  if i in (4, 5, 6) and j in (7, 8, 9) and check_row(k, trn_B6)=0 then _ok_b=1;
                  if i in (7, 8, 9) and j in (1, 2, 3) and check_row(k, trn_B7)=0 then _ok_b=1;
                  if i in (7, 8, 9) and j in (4, 5, 6) and check_row(k, trn_B8)=0 then _ok_b=1;
                  if i in (7, 8, 9) and j in (7, 8, 9) and check_row(k, trn_B9)=0 then _ok_b=1;
   
                  if _ok_r=1 and _ok_c=1 and _ok_b=1 then do; *tt;
                      outp[i, j]=k;
                      
                      if i=1 then trn_R1[1, j]=outp[i, j];
                      if i=2 then trn_R2[1, j]=outp[i, j];
                      if i=3 then trn_R3[1, j]=outp[i, j];
                      if i=4 then trn_R4[1, j]=outp[i, j];
                      if i=5 then trn_R5[1, j]=outp[i, j];
                      if i=6 then trn_R6[1, j]=outp[i, j];
                      if i=7 then trn_R7[1, j]=outp[i, j];
                      if i=8 then trn_R8[1, j]=outp[i, j];
                      if i=9 then trn_R9[1, j]=outp[i, j];
                      
                      if j=1 then trn_C1[1, i]=k;
                      if j=2 then trn_C2[1, i]=k;
                      if j=3 then trn_C3[1, i]=k;
                      if j=4 then trn_C4[1, i]=k;
                      if j=5 then trn_C5[1, i]=k;
                      if j=6 then trn_C6[1, i]=k;
                      if j=7 then trn_C7[1, i]=k;
                      if j=8 then trn_C8[1, i]=k;
                      if j=9 then trn_C9[1, i]=k;
                      
                      z=mod(i+2, 3)*3+mod(j+2, 3)+1;
                      if i in (1, 2, 3) and j in (1, 2, 3) then trn_B1[1, z]=k;
                      if i in (1, 2, 3) and j in (4, 5, 6) then trn_B2[1, z]=k;
                      if i in (1, 2, 3) and j in (7, 8, 9) then trn_B3[1, z]=k;
                      if i in (4, 5, 6) and j in (1, 2, 3) then trn_B4[1, z]=k;
                      if i in (4, 5, 6) and j in (4, 5, 6) then trn_B5[1, z]=k;
                      if i in (4, 5, 6) and j in (7, 8, 9) then trn_B6[1, z]=k;
                      if i in (7, 8, 9) and j in (1, 2, 3) then trn_B7[1, z]=k;
                      if i in (7, 8, 9) and j in (4, 5, 6) then trn_B8[1, z]=k;
                      if i in (7, 8, 9) and j in (7, 8, 9) then trn_B9[1, z]=k;
                      
                      call missing(of _ok_:);
                      check=1;
                      leave; *leave from do loop*** ;
                  end; *tt;
                  else do; *ff;
                      call missing(of _ok_:);
                      outp[i, j]=.;
                  end; *ff;
                end; ***;

              if outp[i, j]=. then do; *<<mkrx2>>;
                check=0;
                tmp_I=i;
                tmp_J=j;
                *Identify the previous cell and the number it contains (prioritize columns);
                if tmp_I>1 and tmp_J>1 then do;
                  now_I=tmp_I;
                  now_J=tmp_J-1;
                  pre_k=outp[i, j-1];
                end;
                else if tmp_I>1 and tmp_J=1 then do;
                  now_I=tmp_I-1;
                  now_J=9;
                  pre_k=outp[i-1, 9];
                end;
                else if tmp_I=1 and tmp_J>1 then do;
                  now_I=1;
                  now_J=tmp_J-1;
                  pre_k=outp[1, j-1];
                end;
                else if tmp_I=1 and tmp_J=1 then do;
                  now_I=1;
                  now_J=1;
                  pre_k=outp[1, 1];
                end;
                  r2_snum=now_I;
                  c2_snum=now_J;
                  if pre_k=9 then k2_snum=100;
                  else k2_snum=pre_k+1;
                  leave;
              end; *<<mkrx2>>;
            end; *<<mkrx1>>;
            else do; *<<mkrx1>>;
              outp[i, j]=inp[i, j];
              check=1;
            end; *<<mkrx1>>;
         
            *Repeat >>>Forward;
            if check=1 then do; *<<mkrx3>>;
              tmp_f_I=i;
              tmp_f_J=j;
              if tmp_f_I<9 and tmp_f_J<9 then do;
                 now_f_I=tmp_f_I;
                 now_f_J=tmp_f_J+1;
              end;
              else if tmp_f_I<9 and tmp_f_J=9 then do;
                 now_f_I=tmp_f_I+1;
                 now_f_J=1;
              end;
              else if tmp_f_I=9 and tmp_f_J<9 then do;
                 now_f_I=9;
                 now_f_J=tmp_f_J+1;
              end;
              else if tmp_f_I=9 and tmp_f_J=9 then do;
                 now_f_I=9;
                 now_f_J=9;
              end;
              r_snum=now_f_I;
              c_snum=now_f_J;
              k_snum=1;
            end; *<<mkrx3>>;
            if check=0 then leave;
          end; *<<mkrdj>>;
          if check=0 then leave;
        end; *<<mkrdi>>;
     
        *==<<<Backward-----------------------;
        if check=0 then do; *<<mkrxb1>>;
          do m=r2_snum to 1 by -1; *<<mkrdm>>;
            do n=c2_snum to 1 by -1; *<<mkrdn>>;
              if inp[m, n]=0 then do; *<<mkry1>>;
                 *Initialize the value of the previous cell in trn_series (= set to 0).;
                 if m=1 then trn_R1[1, n]=0;
                 if m=2 then trn_R2[1, n]=0;
                 if m=3 then trn_R3[1, n]=0;
                 if m=4 then trn_R4[1, n]=0;
                 if m=5 then trn_R5[1, n]=0;
                 if m=6 then trn_R6[1, n]=0;
                 if m=7 then trn_R7[1, n]=0;
                 if m=8 then trn_R8[1, n]=0;
                 if m=9 then trn_R9[1, n]=0;
                 if n=1 then trn_C1[1, m]=0;
                 if n=2 then trn_C2[1, m]=0;
                 if n=3 then trn_C3[1, m]=0;
                 if n=4 then trn_C4[1, m]=0;
                 if n=5 then trn_C5[1, m]=0;
                 if n=6 then trn_C6[1, m]=0;
                 if n=7 then trn_C7[1, m]=0;
                 if n=8 then trn_C8[1, m]=0;
                 if n=9 then trn_C9[1, m]=0;
                 
                 zz=mod(m+2, 3)*3+mod(n+2, 3)+1;
                 if m in (1, 2, 3) and n in (1, 2, 3) then trn_B1[1, zz]=0;
                 if m in (1, 2, 3) and n in (4, 5, 6) then trn_B2[1, zz]=0;
                 if m in (1, 2, 3) and n in (7, 8, 9) then trn_B3[1, zz]=0;
                 if m in (4, 5, 6) and n in (1, 2, 3) then trn_B4[1, zz]=0;
                 if m in (4, 5, 6) and n in (4, 5, 6) then trn_B5[1, zz]=0;
                 if m in (4, 5, 6) and n in (7, 8, 9) then trn_B6[1, zz]=0;
                 if m in (7, 8, 9) and n in (1, 2, 3) then trn_B7[1, zz]=0;
                 if m in (7, 8, 9) and n in (4, 5, 6) then trn_B8[1, zz]=0;
                 if m in (7, 8, 9) and n in (7, 8, 9) then trn_B9[1, zz]=0;
                   
                 if .<k2_snum<=9 then do; *<<mkry2>>;
                     do f=k2_snum to 9; * ****** ;
                     
                       *1. The same number cannot appear in the same row.;
                       if m=1 and check_row(f, trn_R1)=0 then _ok_r=1;
                       if m=2 and check_row(f, trn_R2)=0 then _ok_r=1;
                       if m=3 and check_row(f, trn_R3)=0 then _ok_r=1;
                       if m=4 and check_row(f, trn_R4)=0 then _ok_r=1;
                       if m=5 and check_row(f, trn_R5)=0 then _ok_r=1;
                       if m=6 and check_row(f, trn_R6)=0 then _ok_r=1;
                       if m=7 and check_row(f, trn_R7)=0 then _ok_r=1;
                       if m=8 and check_row(f, trn_R8)=0 then _ok_r=1;
                       if m=9 and check_row(f, trn_R9)=0 then _ok_r=1;
                       
                       *2. The same number cannot appear in the same column.;
                       if n=1 and check_row(f, trn_C1)=0 then _ok_c=1;
                       if n=2 and check_row(f, trn_C2)=0 then _ok_c=1;
                       if n=3 and check_row(f, trn_C3)=0 then _ok_c=1;
                       if n=4 and check_row(f, trn_C4)=0 then _ok_c=1;
                       if n=5 and check_row(f, trn_C5)=0 then _ok_c=1;
                       if n=6 and check_row(f, trn_C6)=0 then _ok_c=1;
                       if n=7 and check_row(f, trn_C7)=0 then _ok_c=1;
                       if n=8 and check_row(f, trn_C8)=0 then _ok_c=1;
                       if n=9 and check_row(f, trn_C9)=0 then _ok_c=1;
                       
                       *3. The same number cannot appear in the same BOX;
                       if m in (1, 2, 3) and n in (1, 2, 3) and check_row(f, trn_B1)=0 then _ok_b=1;
                       if m in (1, 2, 3) and n in (4, 5, 6) and check_row(f, trn_B2)=0 then _ok_b=1;
                       if m in (1, 2, 3) and n in (7, 8, 9) and check_row(f, trn_B3)=0 then _ok_b=1;
                       if m in (4, 5, 6) and n in (1, 2, 3) and check_row(f, trn_B4)=0 then _ok_b=1;
                       if m in (4, 5, 6) and n in (4, 5, 6) and check_row(f, trn_B5)=0 then _ok_b=1;
                       if m in (4, 5, 6) and n in (7, 8, 9) and check_row(f, trn_B6)=0 then _ok_b=1;
                       if m in (7, 8, 9) and n in (1, 2, 3) and check_row(f, trn_B7)=0 then _ok_b=1;
                       if m in (7, 8, 9) and n in (4, 5, 6) and check_row(f, trn_B8)=0 then _ok_b=1;
                       if m in (7, 8, 9) and n in (7, 8, 9) and check_row(f, trn_B9)=0 then _ok_b=1;

                       if _ok_r=1 and _ok_c=1 and _ok_b=1 then do; *tttt;
                           outp[m, n]=f;
                           
                           if m=1 then trn_R1[1, n]=f;
                           if m=2 then trn_R2[1, n]=f;
                           if m=3 then trn_R3[1, n]=f;
                           if m=4 then trn_R4[1, n]=f;
                           if m=5 then trn_R5[1, n]=f;
                           if m=6 then trn_R6[1, n]=f;
                           if m=7 then trn_R7[1, n]=f;
                           if m=8 then trn_R8[1, n]=f;
                           if m=9 then trn_R9[1, n]=f;
                           
                           if n=1 then trn_C1[1, m]=f;
                           if n=2 then trn_C2[1, m]=f;
                           if n=3 then trn_C3[1, m]=f;
                           if n=4 then trn_C4[1, m]=f;
                           if n=5 then trn_C5[1, m]=f;
                           if n=6 then trn_C6[1, m]=f;
                           if n=7 then trn_C7[1, m]=f;
                           if n=8 then trn_C8[1, m]=f;
                           if n=9 then trn_C9[1, m]=f;
                           
                           zz=mod(m+2, 3)*3+mod(n+2, 3)+1;
                           if m in (1, 2, 3) and n in (1, 2, 3) then trn_B1[1, zz]=f;
                           if m in (1, 2, 3) and n in (4, 5, 6) then trn_B2[1, zz]=f;
                           if m in (1, 2, 3) and n in (7, 8, 9) then trn_B3[1, zz]=f;
                           if m in (4, 5, 6) and n in (1, 2, 3) then trn_B4[1, zz]=f;
                           if m in (4, 5, 6) and n in (4, 5, 6) then trn_B5[1, zz]=f;
                           if m in (4, 5, 6) and n in (7, 8, 9) then trn_B6[1, zz]=f;
                           if m in (7, 8, 9) and n in (1, 2, 3) then trn_B7[1, zz]=f;
                           if m in (7, 8, 9) and n in (4, 5, 6) then trn_B8[1, zz]=f;
                           if m in (7, 8, 9) and n in (7, 8, 9) then trn_B9[1, zz]=f;
                           
                           call missing(of _ok_:);
                           check_b=1;
                           leave; *leave from do loop****** ;
                       end; *tttt;
                       else do; *ffff;
                           call missing(of _ok_:);
                           outp[m, n]=.;
                           check_b=0;
                       end; *ffff;
                     end; ***;
                 end; *<<mkry2>>;
                 else do; *<<mkry2>>;
                     call missing(of _ok_:);
                     outp[m, n]=.;
                     check_b=0;
                 end; *<<mkry2>>;
                 
                 *Go Back to >>>Forward;
                 if check_b=1 then do;
                     tmp_m=m;
                     tmp_n=n;
                     if tmp_m<9 and tmp_n<9 then do;
                         now_m=tmp_m;
                         now_n=tmp_n+1;
                     end;
                     else if tmp_m<9 and tmp_n=9 then do;
                         now_m=tmp_m+1;
                         now_n=1;
                     end;
                     else if tmp_m=9 and tmp_n<9 then do;
                         now_m=9;
                         now_n=tmp_n+1;
                     end;
                     else if tmp_m=9 and tmp_n=9 then do;
                         now_m=9;
                         now_n=9;
                     end;
                     r_snum=now_m;
                     c_snum=now_n;
                     k_snum=1;
                     leave;
                 end;
              end; *<<mkry1>>;
              else do; *<<mkry1>>;
                outp[m, n]=inp[m, n];
                check_b=0;
              end; *<<mkry1>>;
             
              *Repeat <<<Backward;
              if check_b=0 then do; *<<mkry3>>;
                 tmp_b_m=m;
                 tmp_b_n=n;
                 if tmp_b_m>1 and tmp_b_n>1 then do;
                     now_b_m=tmp_b_m;
                     now_b_n=tmp_b_n-1;
                     pre_b_k=outp[m, n-1];
                 end;
                 else if tmp_b_m>1 and tmp_b_n=1 then do;
                     now_b_m=tmp_b_m-1;
                     now_b_n=9;
                     pre_b_k=outp[m-1, 9];
                 end;
                 else if tmp_b_m=1 and tmp_b_n>1 then do;
                     now_b_m=1;
                     now_b_n=tmp_b_n-1;
                    pre_b_k=outp[1, n-1];
                end;
                else if tmp_b_m=1 and tmp_b_n=1 then do;
                    now_b_m=1;
                    now_b_n=1;
                    pre_b_k=outp[1, 1];
                end;
                r2_snum=now_b_m;
                c2_snum=now_b_n;
                k2_snum=pre_b_k+1;
              end; *<<mkry3>>;
            end; *<<mkrdn>>;
            if check_b=1 then leave;
            if m=1 and n=1 then do;
              r_snum=1;
              c_snum=1;
              k_snum=outp[1, 1]+1;
              leave;
            end;
          end; *<<mkrdm>>;
        end; *<<mkrxb1>>;
        
        if i=10 and j=10 then leave; *Exit the DO loop upon reaching [9,9].;
        
      end; *AAAAA;
      
      *Write outp (matrix) into __sudoku_ans (SAS dataset);
      rc=write_array('__sudoku__ans', outp);
    endsub;
  quit;
  *----------------------------------------------------------------------;
  options cmplib=work.funcs;
  data aaa;
    call missing(res);
    call solve_sudoku(1, 1, 1, 50000, res); *;
    call symputx("num_bktr", put(res,best.));
    put "The number of Backtrack: " res;
  run;

  %put <<========Answer========>>;
  data _null_;
    set __sudoku__ans;
    put (_all_) (+0);
  run;

  /*=======================================================================*/
  %let END_TIME=%sysfunc( datetime() );*Measuring processing time: End time;
  %let RUNNING_TIME_S=%sysevalf(&END_TIME. - &START_TIME.);*Measuring processing time: End time - Start time;
  %let RUNNING_TIME_S_r=%sysfunc( round(&RUNNING_TIME_S., 1e-3) ); *seconds (rounded);
  %let RUNNING_TIME_M=%sysfunc( round(&RUNNING_TIME_S./60, 1e-2) ); *minutes (rounded);
 
  %put ***[END]**********************************************;
  %put %sysfunc( putn(&END_TIME.,  e8601dt. -L) );
  %put Processing time: &RUNNING_TIME_S_r. sec. (&RUNNING_TIME_M. min.);
 
  proc printto; run; *--Output Log END;
  
  /*=======================================================================*/
  *For RTF output;
  
  %if &rtfYN.=Y %then %do;
    *dataset;
    data __sudoku__c;
      length col1-col9 $2.;
      set __sudoku__;
      array nx c1-c9;
      array cx col1-col9;
      do over nx;
        if nx^=0 then cx=put(nx, best. -L);
        else if nx=0 then cx="";
      end;
    run;
    data __sudoku__ans_c;
      length col1-col9 $2.;
      set __sudoku__ans;
      array nx outp1-outp9;
      array cx col1-col9;
      do over nx;
        cx=put(nx, best. -L);
      end;
    run;
    
    *rtf template;
    ods path reset; ods path(remove) sasuser.templat; ods path(prepend) work.templat(update); 
    proc template;
      define style disp_pzl;
      parent=styles.RTF; 
      class systemtitle/
        font_face  = "Arial"
        font_size   = 12pt
        font_weight= medium
        font_style  = roman
        foreground = black
        background= white
        ;

      class header/
        font_face  = "Arial"
        font_size   = 12pt
        font_weight= medium
        font_style  = roman
        foreground = black
        background= white
        verticalalign=center
        ;

      class data/
        font_face  = "Arial"
        font_size   = 20pt
        font_weight= BOLD
        font_style  = roman
        foreground = black
        background= white
        textalign = center
        verticalalign=center
        ;

      class table/
        foreground = black
        background= white
        cellspacing= 0
        cellpadding= 0%
        frame = box
        rules  = ALL
        textalign = center
        borderwidth = 0.3pt
        bordercolor = black
        borderstyle = solid
        ;
        
      class usertext from usertext/
        font_face  = "Arial"
        font_size   = 12pt
        font_weight= medium
        font_style  = roman
        foreground = black 
        background= white
        borderbottomstyle=none
        bordertopstyle=none 
        textalign=center
        ;
      end;
    run;

    options orientation="portrait"; 
    ods escapechar="~";ods listing close; ods html close; 
    ods noresults;

    *Macro Variables For Setting BOLD Lines;
    %let BoldB=%str(borderbottomwidth=3pt);
    %let BoldT=%str(bordertopwidth=3pt);
    %let BoldL=%str(borderleftwidth=3pt);
    %let BoldR=%str(borderrightwidth=3pt);

    *Initialization: Titles and Footnotes;
    title;
    footnote;

    *Setting: Titles and Footnotes;
    title1 j=center "Sudoku Solver";
    title2 j=center "Processing time: &RUNNING_TIME_S_r. sec. (&RUNNING_TIME_M. min.)";
    
    *ODS RTF;
    ods rtf file="&outputpath.sudoku_answer.rtf" style=disp_pzl startpage=no; 
 
    proc odstable data=__sudoku__c;
      cellstyle 
        _col_ in (1,4,7) and _row_ in (1,4,7) as data{&BoldL. &BoldT.},
        _col_ in (1,4,7) and _row_ in (3,6,9) as data{&BoldL. &BoldB.},
        _col_ in (1,4,7) and _row_ in (2,5,8) as data{&BoldL.},
        _col_ in (3,6,9) and _row_ in (1,4,7) as data{&BoldR. &BoldT.},
        _col_ in (3,6,9) and _row_ in (3,6,9) as data{&BoldR. &BoldB.},
        _col_ in (3,6,9) and _row_ in (2,5,8) as data{&BoldR.},
        _col_ in (2,5,8) and _row_ in (1,4,7) as data{&BoldT.},
        _col_ in (2,5,8) and _row_ in (3,6,9) as data{&BoldB.},
        _col_ in (2,5,8) and _row_ in (2,5,8) as data{}
        ;
      column col1-col9;
      define header hd1; text "Puzzle"; start=col1; end=col9; style={just=c}; end;
      define col1; style={cellwidth=10mm}; print_headers=off; end;
      define col2; style={cellwidth=10mm}; print_headers=off; end;
      define col3; style={cellwidth=10mm}; print_headers=off; end;
      define col4; style={cellwidth=10mm}; print_headers=off; end;
      define col5; style={cellwidth=10mm}; print_headers=off; end;
      define col6; style={cellwidth=10mm}; print_headers=off; end;
      define col7; style={cellwidth=10mm}; print_headers=off; end;
      define col8; style={cellwidth=10mm}; print_headers=off; end;
      define col9; style={cellwidth=10mm}; print_headers=off; end;
    run;
    
    ods rtf text="The number of Backtrack: &num_bktr."; 
    
    proc odstable data=__sudoku__ans_c;
      cellstyle 
        _col_ in (1,4,7) and _row_ in (1,4,7) as data{&BoldL. &BoldT.},
        _col_ in (1,4,7) and _row_ in (3,6,9) as data{&BoldL. &BoldB.},
        _col_ in (1,4,7) and _row_ in (2,5,8) as data{&BoldL.},
        _col_ in (3,6,9) and _row_ in (1,4,7) as data{&BoldR. &BoldT.},
        _col_ in (3,6,9) and _row_ in (3,6,9) as data{&BoldR. &BoldB.},
        _col_ in (3,6,9) and _row_ in (2,5,8) as data{&BoldR.},
        _col_ in (2,5,8) and _row_ in (1,4,7) as data{&BoldT.},
        _col_ in (2,5,8) and _row_ in (3,6,9) as data{&BoldB.},
        _col_ in (2,5,8) and _row_ in (2,5,8) as data{}
        ;
      column col1-col9;
      define header hd1; text "Answer"; start=col1; end=col9; style={just=c}; end;
      define col1; style={cellwidth=10mm}; print_headers=off; end;
      define col2; style={cellwidth=10mm}; print_headers=off; end;
      define col3; style={cellwidth=10mm}; print_headers=off; end;
      define col4; style={cellwidth=10mm}; print_headers=off; end;
      define col5; style={cellwidth=10mm}; print_headers=off; end;
      define col6; style={cellwidth=10mm}; print_headers=off; end;
      define col7; style={cellwidth=10mm}; print_headers=off; end;
      define col8; style={cellwidth=10mm}; print_headers=off; end;
      define col9; style={cellwidth=10mm}; print_headers=off; end;
    run;
    ods rtf close;
  
  %end;

%mend sudoku_solver;
