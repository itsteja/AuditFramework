@echo off
:: Double colon is used for commenting 

:: Creating an empty TruncateTable.bteq file 
copy NUL CloseJob%1.bteq
:: Building the TruncateTable.bteq file 
echo .LOGON 10.0.0.230/dbc,dbc; >> CloseJob%1.bteq
:: If needed the above 3 values, i.e. server, user_name and password can be fetched from parameters
echo CALL Informatica_Test.SP_EndJob (%1,%2,%3,%4,%5,%6,%7); >> CloseJob%1.bteq
:: Calling the bteq file for execution 
echo .logoff >> CloseJob%1.bteq

:: Getting current system timestamp
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c_%%a_%%b)
For /f "tokens=1-2 delims=/: " %%a in ("%TIME%") do (if %%a LSS 10 (set mytime=0%%a%%b) else (set mytime=%%a%%b))
::rename Close_Job_%1_%mydate%_%mytime%.out

bteq < CloseJob%1.bteq > CloseJob_%1_%mydate%_%mytime%.out

:: renaming the .bteq file with the current timestamp 
rename CloseJob%1.bteq CloseJob_%1_%mydate%_%mytime%.bteq

if %7 gtr 0 (
	exit 1 
)