@echo off
:: Double colon is used for commenting 

:: Creating an empty TruncateTable.bteq file 
copy NUL StartJob%1.bteq
:: Building the TruncateTable.bteq file 
echo .LOGON 10.0.0.230/dbc,dbc; >> StartJob%1.bteq
:: If needed the above 3 values, i.e. server, user_name and password can be fetched from parameters
echo CALL Informatica_Test.SP_StartJob(%1,out_JobControlIDparam);  >> StartJob%1.bteq
echo .logoff >> StartJob%1.bteq

:: Getting current system timestamp
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c_%%a_%%b)
For /f "tokens=1-2 delims=/: " %%a in ("%TIME%") do (if %%a LSS 10 (set mytime=0%%a%%b) else (set mytime=%%a%%b))
::rename Close_Job_%1_%mydate%_%mytime%.out

:: Calling the bteq file for execution and logging the output to a file 
bteq < StartJob%1.bteq > logJ%1.out

:: Fetching the needed JobControlID from the log.out file after that
:: renaming the logJ%1.out file with the current JobID and timestamp as the extension
for /F "delims=" %%a in ('findstr /I "JobControlID:" logJ%1.out') do set "batToolDir=%%a"
if %batToolDir:~13% neq -1 (
	::del StartJob%1.bteq
	::del logJ%1.out
	rename logJ%1.out Start_Job_%1_%mydate%_%mytime%.out
	rename StartJob%1.bteq StartJob_%1_%mydate%_%mytime%.bteq 
	exit 0
) 
::del StartJob%1.bteq
::del logJ%1.out
rename logJ%1.out Start_Job_%1_%mydate%_%mytime%.out
rename StartJob%1.bteq StartJob_%1_%mydate%_%mytime%.bteq 
exit 1


