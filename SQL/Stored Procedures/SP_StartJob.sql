REPLACE PROCEDURE Informatica_Test.SP_StartJob (
    IN in_JobIDParam INTEGER,
    OUT out_JobControlIDparam VARCHAR(30))
    BEGIN 
                                                                	-- Check if any Job is running for the same Job ID or not    
        DECLARE JobOpen  INT;
        DECLARE BatchCtrlIDVar  INT;
        DECLARE JobActive INT;
        DECLARE JobStatusVar VARCHAR(10);
        DECLARE JobControlIDVar INT;
        DECLARE MaxRunID INT;
        SELECT COUNT(1) INTO JobOpen
            FROM Informatica_Test.JobControl JC JOIN Informatica_Test.Job J ON J.JobID = JC.JobID
            WHERE J.JobID = :in_JobIDParam
                AND  JC.status = 'RUNNING';
        SELECT ActiveYN INTO JobActive
            FROM Informatica_Test.Job
            WHERE JobID = :in_JobIDParam;
        SELECT BC.BatchControlID INTO BatchCtrlIDVar
            FROM Informatica_Test.Job J JOIN Informatica_Test.BatchControl BC ON BC.BatchID = J.BatchID
            WHERE BC.Status = 'RUNNING'
                AND  J.JobID = :in_JobIDParam;
        SELECT JC.Status INTO JobStatusVar
            FROM Informatica_Test.JobControl JC JOIN Informatica_Test.Job J  ON JC.JobID = J.JobID
            WHERE J.JobID = :in_JobIDParam
                AND  JC.BatchCtrlID = BatchCtrlIDVar;
        SELECT JC.JobControlID INTO JobControlIDVar
            FROM Informatica_Test.JobControl JC JOIN Informatica_Test.Job J  ON JC.JobID = J.JobID
            WHERE J.JobID = :in_JobIDParam
                AND  JC.BatchCtrlID = BatchCtrlIDVar;
        SELECT MAX(JC.RunID) INTO MaxRunID
            FROM Informatica_Test.JobControl JC
            WHERE JC.JobID = :in_JobIDParam
                AND  JC.BatchCtrlID = BatchCtrlIDVar;
        IF JobStatusVar = 'WAITING' AND JobActive=1  THEN
            UPDATE Informatica_Test.JobControl 
            SET Status = 'RUNNING' ,
            StartDateTime = CURRENT_TIMESTAMP,
            RunID = MaxRunID + 1
            WHERE JobControlID = JobControlIDVar;
            SELECT 'JobControlID:' || CAST(JobControlID AS VARCHAR(15)) INTO out_JobControlIDparam
                FROM Informatica_Test.JobControl JC
                JOIN Informatica_Test.Job J ON JC.JobID = J.JobID
                WHERE JC.JobID = :in_JobIDParam
                    AND  JC.status = 'RUNNING'
                    AND  J.ActiveYN = 1;
                                                                    
                                                                                                
            ELSEIF JobStatusVar = 'ERROR' AND JobActive=1 THEN
            UPDATE Informatica_Test.JobControl
            SET Status = 'RUNNING',
            StartDateTime = CURRENT_TIMESTAMP
            WHERE JobControlID = JobControlIDVar;
            SELECT 'JobControlID:' || CAST(JobControlID AS VARCHAR(15)) INTO out_JobControlIDparam
                FROM Informatica_Test.JobControl JC
                JOIN Informatica_Test.Job J ON JC.JobID = J.JobID
                WHERE JC.JobID = :in_JobIDParam
                    AND  JC.status = 'RUNNING'
                    AND  J.ActiveYN = 1;
                                                			
            ELSE
            SET out_JobControlIDparam = 'JobControlID:-1';
            END IF;
    END;