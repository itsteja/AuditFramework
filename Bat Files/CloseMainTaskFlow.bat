@echo off
:: Double colon is used for commenting 

:: Creating an empty TruncateTable.bteq file 
copy NUL CloseMainTaskFlowB%1.bteq
:: Building the TruncateTable.bteq file 
echo .LOGON 10.0.0.230/dbc,dbc; >> CloseMainTaskFlowB%1.bteq
:: If needed the above 3 values, i.e. server, user_name and password can be fetched from parameters
echo CALL Informatica_Test.SP_EndBatch(%1,%2,%3) >> CloseMainTaskFlowB%1.bteq

:: Getting current system timestamp
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c_%%a_%%b)
For /f "tokens=1-2 delims=/: " %%a in ("%TIME%") do (if %%a LSS 10 (set mytime=0%%a%%b) else (set mytime=%%a%%b))
::rename Close_Job_%1_%mydate%_%mytime%.out


:: Calling the bteq file for execution 
bteq < CloseMainTaskFlowB%1.bteq > CloseBatchLogB%1.out
rename CloseMainTaskFlowB%1.bteq CloseMainTaskFlowB_%1_%mydate%_%mytime%.bteq
rename CloseBatchLogB%1.out Close_Batch_%1_%mydate%_%mytime%.out