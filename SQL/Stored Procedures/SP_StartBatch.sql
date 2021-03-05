REPLACE PROCEDURE Informatica_Test.SP_StartBatch (
    IN in_BatchIDParam INTEGER,
    OUT out_BatchControlIDparam VARCHAR(30))
    BEGIN 
                        	-- Check if any batch is running for the same batch ID or not 
                                                                                                                                           
        DECLARE batchOpen  INT; -- Populate batchOpen variable with the open batchControlID
        DECLARE batchActive INT;
        DECLARE jobOpen INT; -- Count of waiting or error jobs
        DECLARE jobOpenRunning INT; -- Count of running jobs
        
        SELECT COUNT(BatchControlID) INTO batchOpen
            FROM Informatica_Test.BatchControl
            WHERE BatchID = :in_BatchIDParam
                AND  status = 'RUNNING'; -- To find if a batch is Active or not
        
        SELECT ActiveYN INTO batchActive
            FROM Informatica_Test.Batch
            WHERE BatchID = :in_BatchIDParam
                AND  ActiveYN = 1; -- Getting the count of the Jobs that are in error state for an Open BatchControlID
        
        SELECT 
            COUNT(1) INTO jobOpenRunning
            FROM Informatica_Test.BatchControl BC 
            JOIN Informatica_Test.JobControl JC  
            ON BC.BatchControlID = JC.BatchCtrlID
            JOIN (
            SELECT BatchCtrlID,
                JobID,
                MAX(RunID) AS MaxRunID
                FROM Informatica_Test.JobControl
                GROUP BY JobID,
                    BatchCtrlID) JC2
            ON BC.BatchControlID = JC2.BatchCtrlID AND JC.JobID = JC2.JobID AND JC.RunID = JC2.MaxRunID
            WHERE BC.status = 'RUNNING'
                AND  JC.status = 'RUNNING'
                AND  BC.BatchID =:in_BatchIDParam;
        SELECT 
            COUNT(1) INTO jobOpen
            FROM Informatica_Test.BatchControl BC 
            JOIN Informatica_Test.JobControl JC  
            ON BC.BatchControlID = JC.BatchCtrlID
            JOIN (
            SELECT BatchCtrlID,
                JobID,
                MAX(RunID) AS MaxRunID
                FROM Informatica_Test.JobControl
                GROUP BY JobID,
                    BatchCtrlID) JC2
            ON BC.BatchControlID = JC2.BatchCtrlID AND JC.JobID = JC2.JobID AND JC.RunID = JC2.MaxRunID
            WHERE BC.status = 'RUNNING'
                AND  (JC.status = 'WAITING' OR JC.status = 'ERROR')
                AND  BC.BatchID =:in_BatchIDParam; -- Check if batch is open means batchOpen value will be a non zero
         -- Check if jobs are failed means jobOpen value will be a non zero
        
        IF batchOpen<>0 AND jobOpenRunning<>0 THEN
                                        
            SET out_BatchControlIDparam = 'BatchControlID:-1';
                                        
            ELSEIF batchOpen<>0 OR jobOpen <>0 THEN
            SELECT 'BatchControlID:' || CAST(BatchControlID AS VARCHAR(15)) INTO out_BatchControlIDparam
                FROM Informatica_Test.BatchControl BC
                JOIN Informatica_Test.Batch B ON BC.BatchID = B.BatchID
                WHERE BC.BatchID = :in_BatchIDParam
                    AND  status = 'RUNNING'
                    AND  B.ActiveYN = 1;
                                                        
            ELSEIF batchOpen=0 AND batchActive = 1 THEN
            INSERT INTO  Informatica_Test.BatchControl  
            ("BatchID", "LoadWindowStartDate", "LoadWindowEndDate", "StartDatetime", "EndDatetime", "Status", "ErrorMessage")
            VALUES (:in_BatchIDParam,NULL,NULL,CURRENT_TIMESTAMP,NULL,'RUNNING',NULL);
            INSERT INTO "Informatica_Test"."JobControl"  
            ("BatchCtrlID", "JobID", "StartDateTime", "EndDateTime", "RunID", "Status", "Success_Source_Rows", "Success_Target_Rows", "Failed_Source_Rows", "Failed_Target_Rows", "ErrorMessage")
            SELECT BC.BatchControlID AS BatchCtrlID,
                J.JobID,
                NULL AS StartDateTime,
                NULL AS EndDateTime,
                1 AS RunID,
                'WAITING' AS Status,
                NULL AS Success_Source_Rows,
                NULL AS Success_Target_Rows,
                NULL AS Failed_Source_Rows,
                NULL AS Failed_Target_Rows,
                NULL AS ErrorMessage
                FROM Informatica_Test.BatchControl BC 
                JOIN Informatica_Test.Batch B 
                ON BC.BatchID = B.BatchID
                JOIN Informatica_Test.Job J
                ON B.BatchID = J.BatchID
                WHERE BC.status = 'RUNNING'
                    AND  B.BatchID = :in_BatchIDParam
                    AND  J.ActiveYN = 1;
            SELECT 'BatchControlID:' || CAST(BatchControlID AS VARCHAR(15)) INTO out_BatchControlIDparam
                FROM Informatica_Test.BatchControl BC
                JOIN Informatica_Test.Batch B ON BC.BatchID = B.BatchID
                WHERE BC.BatchID = :in_BatchIDParam
                    AND  status = 'RUNNING'
                    AND  B.ActiveYN = 1;
            END IF;
    END;