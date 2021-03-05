@echo off
:: Double colon is used for commenting 

:: Creating an empty TruncateTable.bteq file 
copy NUL OpenMainTaskFlow%1%1.bteq
:: Building the TruncateTable.bteq file 
echo .LOGON 10.0.0.230/dbc,dbc; >> OpenMainTaskFlow%1.bteq
:: If needed the above 3 values, i.e. server, user_name and password can be fetched from parameters
echo CALL Informatica_Test.SP_StartBatch(%1,out_BatchControlIDparam); >> OpenMainTaskFlow%1.bteq
echo .logoff >> OpenMainTaskFlow%1.bteq
:: Calling the bteq file for execution 
bteq < OpenMainTaskFlow%1.bteq > logB%1.out

:: Getting current system timestamp
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c_%%a_%%b)
For /f "tokens=1-2 delims=/: " %%a in ("%TIME%") do (if %%a LSS 10 (set mytime=0%%a%%b) else (set mytime=%%a%%b))
::rename Close_Job_%1_%mydate%_%mytime%.out



:: Fetching the needed BatchControlID from the log.out file 
for /F "delims=" %%a in ('findstr /I "BatchControlID:" logB%1.out') do set "batToolDir=%%a"
if %batToolDir:~15% neq -1 (
	rename OpenMainTaskFlow%1.bteq OpenMainTaskFlow_%1_%mydate%_%mytime%.bteq
	rename logB%1.out Open_Batch_%1_%mydate%_%mytime%.out
	exit 0
) 
::del OpenMainTaskFlow%1.bteq
::del logB%1.out
exit 1
