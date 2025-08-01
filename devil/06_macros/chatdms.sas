/*** HELP START ***//*
This is macro to chat with LLMs(openAI / Google) in SAS DMS(Display Management System) for who cannot afford Viya Copilot. This is actually like Rshiny application which creates window for prompt and you can receive responses from LLMs in log window.

Parameters:
- provider: openAI / google / anthropic
- model : please specify(e.g. gemini-1.5-flash, gpt-3.5-turbo)
- apikey : please input
- max_tokens : 1024 (default)

*//*** HELP END ***/
%macro chatDMS(
	provider=google,
	model=gemini-1.5-flash,
	apikey=,
	max_tokens=1024 );
	options nonotes;
  /* ==== window ==== */
  %window chatwin rows=30 columns=50
    #2 @5 'Provider (openAI/google/anthropic):' provider 10 attr=underline
    #4 @5 'Model:' model 20 attr=underline
    #8 @5 'Your prompt:' prompt 100 attr=underline
    #10 @5 '** Enter blank for quit **' ;
  /* ==== initial values ==== */
  %let provider=&provider;
  %let model=&model;
  %let apikey=&apikey;
  %let prompt=;
  %let response=;
  %do %while(1);
    %display chatwin;
    /* Blank Enter for finish */
    %if "&prompt" = "" %then %goto finish;
    filename req temp ;
    filename resp temp ;
    /* Request body by provider */
    data _null_;
      file req encoding="utf-8";
      %if %lowcase(&provider)=openai %then %do;
        put '{';
        put '  "model": "' "&model" '",';
        put '  "messages": [ {"role": "user", "content": "' "&prompt" '"} ],';
        put '  "max_tokens": ' "&max_tokens";
        put '}';
      %end;
      %else %if %lowcase(&provider)=google %then %do;
		put '{';
		put '  "contents": [ { "parts": [ { "text": "' "&prompt" '" } ] } ],';
		put '  "generationConfig": { "maxOutputTokens": ' "&max_tokens" ' }';
		put '}';
      %end;
	  %else %if %lowcase(&provider)=anthropic %then %do;
	    put '{';
	    put '  "model": "' "&model" '",';
	    put '  "messages": [ {"role": "user", "content": "' "&prompt" '"} ],';
	    put '  "max_tokens": ' "&max_tokens" ',';
	    put '  "system": "You are a helpful assistant."';
	    put '}';
	  %end;
    run;
    /* API endpoint by provider */
    %if %lowcase(&provider)=openai %then %do;
      %let url=https://api.openai.com/v1/chat/completions;
    %end;
    %else %if %lowcase(&provider)=google %then %do;
      %let url=https://generativelanguage.googleapis.com/v1/models/&model.:generateContent?key=&apikey;
    %end;
	%else %if %lowcase(&provider)=anthropic %then %do;
	  %let url=https://api.anthropic.com/v1/messages;
	%end;
    /* HTTP request */
	%if %lowcase(&provider)=openai %then %do;
	  proc http
	    url="&url"
	    method="POST"
	    in=req
	    out=resp
	    headers
	      "Authorization"="Bearer &apikey"
	    ct="application/json";
	  run;
	%end;
	%else %if %lowcase(&provider)=google %then %do;
	  proc http
	    url="&url"
	    method="POST"
	    in=req
	    out=resp
	    ct="application/json";
	  run;
	%end;
	%else %if %lowcase(&provider)=anthropic %then %do;
	  proc http
	    url="&url"
	    method="POST"
	    in=req
	    out=resp
	    headers
	      "Authorization"="Bearer &apikey"
	      "anthropic-version"="2023-06-01"
	    ct="application/json";
	  run;
	%end;
 
    /* Extract the response using JSON Engine */
    libname respjson json fileref=resp;
    
    /* check dataset created */
    proc datasets lib=respjson nolist;
    quit;
    
    /* Google/Gemini */
    %if %lowcase(&provider)=google %then %do;
      data _null_;
        length txt $4000;
        /* extract text part */
        set respjson.alldata;
        where P1 = 'candidates' and P2 = 'content' and P3 = 'parts' and P4 = 'text';
        txt = value;
        call symputx('response', txt);
        put "Gemini: " txt;
        stop;
      run;
    %end;
    
    /* OpenAI */
    %else %if %lowcase(&provider)=openai %then %do;
      data _null_;
        length txt $4000;
        /* extract content part */
        set respjson.alldata;
        where P1 = 'choices' and P2 = 'message' and P3 = 'content';
        txt = value;
        call symputx('response', txt);
        put "ChatGPT: " txt;
        stop;
      run;
    %end;

	/* Anthropic */
	%if %lowcase(&provider)=anthropic %then %do;
	  data _null_;
	    length txt $4000;
	    /* extract assistant content text */
	    set respjson.alldata;
	    where P1 = 'content' and P2 = '1' and P3 = 'text';
	    txt = value;
	    call symputx('response', txt);
	    put "Claude: " txt;
	    stop;
	  run;
	%end;

    libname respjson clear;
	%let prompt=;   /* reset prompt */
  %end;
  %finish:
  options notes ;
%mend;
