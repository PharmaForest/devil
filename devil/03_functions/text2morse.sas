/*** HELP START ***//*

text2morse is a function that converts text to Morse code.
options cmplib=work.f ; is required prior to f1 is used.

*//*** HELP END ***/

function text2morse (text $) $ ;

length key1  $1 text  _rvalue rvalue $2000 ;

_text=upcase(compress(text));

 declare dictionary  d1 ;

   d1["A"] = "・－";

   d1["B"] = "－・・・";

   d1["C"] = "－・－・";

   d1["D"] = "－・・";

   d1["E"] = "・";

   d1["F"] = "・・－・";

   d1["G"] = "－－・";

   d1["H"] = "・・・・";

   d1["I"] = "・・";

   d1["J"] = "・－－－";

   d1["K"] = "－・－";

   d1["L"] = "・－・・";

   d1["M"] = "－－";

   d1["N"] = "－・";

   d1["O"] = "－－－";

   d1["P"] = "・－－・";

   d1["Q"] = "－－・－";

   d1["R"] = "・－・";

   d1["S"] = "・・・";

   d1["T"] = "－";

   d1["U"] = "・・－";

   d1["V"] = "・・・－";

   d1["W"] = "・－－";

   d1["X"] = "－・・－";

   d1["Y"] = "－・－－";

   d1["Z"] = "－－・・";

 do i = 1 to length(_text); 

  _key1=char(_text,i);

  _rvalue= d1[_key1];

  rvalue=catx(" ",rvalue,_rvalue);

 end;

  put _text= rvalue=;

  return(rvalue);

 endsub;
