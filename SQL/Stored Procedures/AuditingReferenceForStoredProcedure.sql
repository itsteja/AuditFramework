REPLACE PROCEDURE Informatica_Test.SP_Order3()
    BEGIN
        DECLARE UpdateDateTime TIMESTAMP(6);
        DECLARE Current_JobID INTEGER;
        DECLARE JobControlIDVar INTEGER;
        DECLARE InsertActivityCount BIGINT DEFAULT 0;
        DECLARE UpdateActivityCount BIGINT DEFAULT 0;
        SET UpdateDateTime = CURRENT_TIMESTAMP;
        --SET Current_JobID = WillBeSetDuringIntegration;
        /*
        select JobControlID INTO JobControlIDVar 
        from Informatica_Test.JobControl JC 
        where JC.JobID = Current_JobID and JC.status = 'RUNNING'; 
         */               
		--Close off existing records that have changed
        UPDATE Informatica_Test.Order_MSL_Stage
        FROM (
        SELECT S.orderNumber AS ord_number
            FROM Informatica_Test.Order_MSL_Landing L
            INNER JOIN Informatica_Test.Order_MSL_Stage S
            ON L.orderNumber = S.orderNumber AND S.activeInd = 1
            WHERE /*hash_md5(S.orderDate, S.requiredDate, S.shippedDate, S.status, S.comments, S.customerNumber, S.LastUpdateDate) <> hash_md5(L.orderDate, L.requiredDate, L.shippedDate, L.status, L.comments, L.customerNumber, L.LastUpdateDate)*/ S.orderDate <> L.orderDate
                OR  S.requiredDate <> L.requiredDate
                OR  COALESCE(S.shippedDate,'2099-12-31') <> COALESCE(L.shippedDate,'2099-12-31')
                OR  S.status <> L.status
                OR  S.comments <> L.comments
                OR  S.customerNumber <> L.customerNumber
                OR  S.LastUpdateDate <> L.LastUpdateDate 
        ) a
        SET activeInd = 0
        ,ETL_RECORD_UPDATED_TIMESTAMP = :UpdateDateTime
        WHERE ord_number = orderNumber;
        
       SET UpdateActivityCount = UpdateActivityCount + ACTIVITY_COUNT;
        
        --Set to inactive for deleted records
        UPDATE Informatica_Test.Order_MSL_Stage
        FROM (
        SELECT S.orderNumber AS ord_number
            FROM Informatica_Test.Order_MSL_Stage S
            WHERE NOT EXISTS (
            SELECT *
                FROM Informatica_Test.Order_MSL_Landing L
                WHERE S.orderNumber = L.orderNumber)) a
        SET activeInd = 0
        ,ETL_RECORD_UPDATED_TIMESTAMP = :UpdateDateTime
        WHERE ord_number = orderNumber;
        
        SET UpdateActivityCount = UpdateActivityCount + ACTIVITY_COUNT;
        /*
        UPDATE "Informatica_Test"."JobControl"
		set 
		Target_Updated_Rows = UpdateActivityCount 
		where JobControlID = JobControlIDVar;
        */
                		
		-- Insert new records which do not exist
        INSERT INTO Informatica_Test.Order_MSL_Stage
        (
        orderNumber,
        orderDate,
        requiredDate,
        shippedDate,
        status,
        comments,
        customerNumber,
        LastUpdateDate,
        ETL_RECORD_UPDATED_TIMESTAMP,
        activeInd
        )
        SELECT 
            L.orderNumber,
            L.orderDate,
            L.requiredDate,
            L.shippedDate,
            L.status,
            L.comments,
            L.customerNumber,
            L.LastUpdateDate,
            :UpdateDateTime AS ETL_RECORD_UPDATED_TIMESTAMP,
            1 AS activeInd
            FROM Informatica_Test.Order_MSL_Landing L
            WHERE NOT EXISTS (
            SELECT *
                FROM Informatica_Test.Order_MSL_Stage S
                WHERE L.orderNumber = S.orderNumber);
                			-- LEFT JOIN Informatica_Test.Order_MSL_Stage S
                            -- ON L.orderNumber = S.orderNumber
                            -- WHERE S.orderNumber IS NULL;
        
		SET InsertActivityCount = InsertActivityCount + ACTIVITY_COUNT;
		/*
		UPDATE "Informatica_Test"."JobControl"
		set 
		Target_Inserted_Rows = InsertActivityCount 
		where JobControlID = JobControlIDVar;
		*/
		
                		-- Insert new updated records
        INSERT INTO Informatica_Test.Order_MSL_Stage
        (
        orderNumber,
        orderDate,
        requiredDate,
        shippedDate,
        status,
        comments,
        customerNumber,
        LastUpdateDate,
        ETL_RECORD_UPDATED_TIMESTAMP,
        activeInd
        )
        SELECT 
            S.orderNumber,
            L.orderDate,
            L.requiredDate,
            L.shippedDate,
            L.status,
            L.comments,
            L.customerNumber,
            L.LastUpdateDate,
            :UpdateDateTime AS ETL_RECORD_UPDATED_TIMESTAMP,
            1 AS activeInd
            FROM Informatica_Test.Order_MSL_Landing L 
            INNER JOIN Informatica_Test.Order_MSL_Stage S
            ON L.orderNumber = S.orderNumber
            AND S.activeInd = 0
            AND S.ETL_RECORD_UPDATED_TIMESTAMP = :UpdateDateTime;
           
		
    END;