/*** HELP START ***//*

This is macro to chat with LLMs(openAI / Google) in SAS DMS(Display Management System) for who cannot afford Viya Copilot. This is actually like Rshiny application which creates window for prompt and you can receive responses from LLMs in log window.

Parameters:
- provider: openAI or google
- model : please specify(e.g. gemini-1.5-flash, gpt-3.5-turbo)
- apikey : please input
- max_tokens : 512 (default)

*//*** HELP END ***/

%macro chatDMS(
	provider=google,
	model=gemini-1.5-flash,
	apikey=,
	max_tokens=512 );

	options nonotes;

  /* ==== window ==== */
  %window chatwin rows=30 columns=50
    #2 @5 'Provider (openAI/google):' provider 10 attr=underline
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
    run;

    /* API endpoint by provider */
    %if %lowcase(&provider)=openai %then %do;
      %let url=https://api.openai.com/v1/chat/completions;
      %let header=Authorization="Bearer &apikey";
      %let ct=application/json;
    %end;
    %else %if %lowcase(&provider)=google %then %do;
      %let url=https://generativelanguage.googleapis.com/v1/models/&model.:generateContent?key=&apikey;
      %let header=;
      %let ct=application/json;
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

    /* Extract the response */
	data _null_;
	  infile resp lrecl=32767 encoding="utf-8";
	  input;
	  length content $4000;
	  /* openai */
	  %if %lowcase(&provider)=openai %then %do;
	    if index(_infile_, '"content":') then do;
	      content = prxchange('s/.*"content":"(.*?)".*/\1/', 1, _infile_);
	      call symput('response', content);
	      put "ChatGPT: " content;
	    end;
	  %end;
	  /* google(gemini) */
	  %else %if %lowcase(&provider)=google %then %do;
	    if index(_infile_, '"text":') then do;
	      content = prxchange('s/.*"text":\s*"(.*?)".*/\1/', 1, _infile_);
	      content = tranwrd(content, '\n', '');
	      call symput('response', content);
	      put "Gemini: " content;
	    end;
	  %end;
	run;

	%let prompt=;   /* reset prompt */

  %end;

  %finish:

  options notes ;
%mend;
