CREATE SET TABLE Informatica_Test.Batch ,FALLBACK ,
    NO BEFORE JOURNAL,
    NO AFTER JOURNAL,
    CHECKSUM = DEFAULT,
    DEFAULT MERGEBLOCKRATIO,
    MAP = TD_MAP1
    (
    BatchID INTEGER GENERATED ALWAYS AS IDENTITY
    (START WITH 1 
    INCREMENT BY 1 
    MINVALUE 1 
    MAXVALUE 2147483647 
    NO CYCLE),
    BatchName VARCHAR(30) CHARACTER SET LATIN CASESPECIFIC,
    Frequency VARCHAR(50) CHARACTER SET LATIN CASESPECIFIC,
    ActiveYN BYTEINT)
    UNIQUE PRIMARY INDEX ( BatchID );