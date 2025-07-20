# devil (latest version 0.0.1 on 21July2025)
Welcome to DEVIL (Developer's Ideas Library)!  

<img src="https://github.com/PharmaForest/devil/blob/main/devil_logo.png?raw=true" alt="logo" width="300"/>

**Share your devils (any ideas at any stage)** for joking(for fun), trial, inspiring, showing-off, or recruiting members for further development by showing POC. Main target of the package is especially someone who doesn't have github account or is not faimliar yet with SAS packages framework but is interested in sharing. You can know from description.sas of devil that author is "Any Developers". First devil is provided in advance for reference. Knock the door of devil.

## 1. %chatDMS() :  
Chat application in SAS DMS(Display Management System) for those who cannot afford Viya Copilot😂  
Sample code:
~~~sas
%chatDMS(
  provider=google,           /* AI provider(only openAI and Google available) */
  model=gemini-1.5-flash,    /* Model information */
  apikey=xxxxxxxxxxxxxxx,    /* API key */
  max_tokens=512)            /* Max token */
~~~

## Version history  
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

