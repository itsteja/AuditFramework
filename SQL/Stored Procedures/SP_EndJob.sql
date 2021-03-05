REPLACE PROCEDURE Informatica_Test.SP_EndJob (
    IN in_JobIDParam INTEGER,
    IN in_statusParam VARCHAR(8),
    IN in_ErrorMessageParam VARCHAR(1000),
    IN in_RowsInserted INTEGER,
    IN in_RowsUpdated INTEGER,
    IN in_RowsDeleted INTEGER
    )
    BEGIN 
                	    
        DECLARE JobControlIDVar INTEGER;
        SELECT JC.JobControlID INTO :JobControlIDVar
            FROM Informatica_Test.JobControl JC JOIN Informatica_Test.Job J  ON JC.JobID = J.JobID 
            JOIN Informatica_Test.BatchControl BC ON BC.BatchControlID = JC.BatchCtrlID
            WHERE J.JobID = :in_JobIDParam
                AND  BC.Status = 'RUNNING';
                       
                        
                        
        UPDATE Informatica_Test.JobControl 
        SET EndDatetime = CURRENT_TIMESTAMP,
        status = :in_statusParam,
        ErrorMessage = :in_ErrorMessageParam,
        RowsInserted = :in_RowsInserted,
        RowsUpdated = :in_RowsUpdated,
        RowsDeleted = :in_RowsDeleted
        WHERE JobControlID = JobControlIDVar;
    END;