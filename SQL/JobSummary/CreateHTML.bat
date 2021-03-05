@echo off
if exist JobOutput.txt del /f /q JobOutput.txt
if exist BatchOutput.txt del /f /q BatchOutput.txt
bteq < JobData.bteq
bteq < BatchData.bteq

if exist out.txt del /f /q out.txt

setlocal enabledelayedexpansion

set /p texte=< BatchOutput.txt  
echo %texte%

set tmp=^<b^>Total Batch Runtime: %texte% Mins^</b^>^<br^>^<br^>^<b^>Batch Execution Summary^</b^>  


set tmp= !tmp! ^<table border="1"^>^<tr^>^<th^>Job ID^</th^>^<th^>Job Name^</th^>^<th^>JobCtrlID^</th^>^<th^>StartTime^</th^>^<th^>EndTime^</th^>^<th^>RunID^</th^>^<th^>Status^</th^>^<th^>Source Success Rows^</th^>^<th^>Target Success Rows^</th^>^<th^>Source Failed Rows^</th^>^<th^>Target Failed Rows^</th^>^</tr^>

for /f "tokens=1,2,3,4,5,6,7,8,9,10,11 delims=|" %%a in (JobOutput.txt) do (
set tmp=!tmp! ^<tr^>^<td^>%%a^</td^>^<td^>%%b^</td^>^<td^>%%c^</td^>^<td^>%%d^</td^>^<td^>%%e^</td^>^<td^>%%f^</td^>^<td^>%%g^</td^>^<td^>%%h^</td^>^<td^>%%i^</td^>^<td^>%%j^</td^>^<td^>%%k^</td^>^</tr^>
)
set tmp = !tmp! ^</table^>
echo HTMLData >> out.txt 
echo !tmp! >> out.txt 

