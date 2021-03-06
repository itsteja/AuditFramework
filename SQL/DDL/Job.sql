CREATE SET TABLE Informatica_Test.Job ,FALLBACK ,
    NO BEFORE JOURNAL,
    NO AFTER JOURNAL,
    CHECKSUM = DEFAULT,
    DEFAULT MERGEBLOCKRATIO,
    MAP = TD_MAP1
    (
    JobID INTEGER GENERATED ALWAYS AS IDENTITY
    (START WITH 1 
    INCREMENT BY 1 
    MINVALUE 1 
    MAXVALUE 2147483647 
    NO CYCLE),
    JobName VARCHAR(40) CHARACTER SET LATIN CASESPECIFIC,
    BatchID INTEGER,
    Frequency VARCHAR(40) CHARACTER SET LATIN CASESPECIFIC,
    ActiveYN BYTEINT)
    UNIQUE PRIMARY INDEX ( JobID );