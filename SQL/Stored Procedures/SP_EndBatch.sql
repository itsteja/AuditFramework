REPLACE PROCEDURE Informatica_Test.SP_EndBatch (
    IN in_BatchIDParam INTEGER,
    IN in_statusParam VARCHAR(8),
    IN in_ErrorMessageParam VARCHAR(1000))
    BEGIN 
        UPDATE Informatica_Test.BatchControl 
        SET EndDatetime = CURRENT_TIMESTAMP,
        status = :in_statusParam,
        ErrorMessage = :in_ErrorMessageParam
        WHERE Status = 'RUNNING'
            AND  BatchID = :in_BatchIDParam;
    END;