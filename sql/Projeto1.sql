
SELECT *
FROM IBM_DATA
-- DIMENSION TABLE 1: D_Position 


CREATE TABLE D_Position (
    PositionID   INT IDENTITY(1,1) PRIMARY KEY,
    Department   VARCHAR(50) NOT NULL,
    JobRole      VARCHAR(50) NOT NULL,
    JobLevel     INT         NOT NULL,
    UNIQUE (Department, JobRole, JobLevel)
);
GO

INSERT INTO D_Position (Department, JobRole, JobLevel)
SELECT DISTINCT
    LTRIM(RTRIM(i.Department)),
    LTRIM(RTRIM(i.JobRole)),
    i.JobLevel
FROM dbo.IBM_DATA i
WHERE i.Department IS NOT NULL
ORDER BY 1, 2, 3;
GO



-- DIMENSION TABLE 2: D_Employee



CREATE TABLE D_Employee (
    EmployeeID               INT          PRIMARY KEY,
    Age                      INT          NOT NULL,
    Attrition                BIT   NOT NULL,
    PositionID               INT          NOT NULL FOREIGN KEY REFERENCES D_Position(PositionID),
    DistanceFromHome         INT          NOT NULL,
    EducationField           VARCHAR(50)  NOT NULL,
    Education_Level          VARCHAR(50)  NOT NULL,
    Gender                   VARCHAR(20),
    Marital_Status           VARCHAR(50),
    BusinessTravel           VARCHAR(50),
    Overtime                 VARCHAR(3)   NOT NULL,
    NumCompaniesWorked       INT          NOT NULL,
    TotalWorkingYears        INT          NOT NULL,
    YearsAtCompany           INT          NOT NULL,
    YearsInCurrentRole       INT          NOT NULL,
    YearsSinceLastPromotion  INT          NOT NULL,
    YearsWithCurrManager     INT          NOT NULL,
    TrainingTimesLastYear    INT          NOT NULL,

    -- Computed columns
    BirthYear AS (YEAR(GETDATE()) - Age),
    Generation AS (
        CASE
            WHEN (YEAR(GETDATE()) - Age) >= 1997 THEN 'Gen Z'
            WHEN (YEAR(GETDATE()) - Age) >= 1981 THEN 'Millennial'
            WHEN (YEAR(GETDATE()) - Age) >= 1965 THEN 'Gen X'
            WHEN (YEAR(GETDATE()) - Age) >= 1946 THEN 'Baby Boomer'
            WHEN (YEAR(GETDATE()) - Age) >= 1925 THEN 'Silent Generation'
            ELSE 'Unknown'
        END
    ),
    Generation_Sort AS (
        CASE
            WHEN (YEAR(GETDATE()) - Age) >= 1997 THEN 5
            WHEN (YEAR(GETDATE()) - Age) >= 1981 THEN 4
            WHEN (YEAR(GETDATE()) - Age) >= 1965 THEN 3
            WHEN (YEAR(GETDATE()) - Age) >= 1946 THEN 2
            WHEN (YEAR(GETDATE()) - Age) >= 1925 THEN 1
            ELSE 0
        END
    ),
);
GO

INSERT INTO D_Employee (
    EmployeeID, Age, Attrition, PositionID, DistanceFromHome,
    EducationField, Education_Level, Gender, Marital_Status, BusinessTravel, Overtime,
    NumCompaniesWorked, TotalWorkingYears, YearsAtCompany, YearsInCurrentRole,
    YearsSinceLastPromotion, YearsWithCurrManager, TrainingTimesLastYear
)
SELECT
    i.EmployeeNumber,
    i.Age,
    i.Attrition,
    p.PositionID,
    i.DistanceFromHome,
    i.EducationField,
    CASE i.Education
        WHEN 1 THEN 'Below College'
        WHEN 2 THEN 'College'
        WHEN 3 THEN 'Bachelor'
        WHEN 4 THEN 'Master'
        WHEN 5 THEN 'Doctor'
        ELSE 'Unknown'
    END,
    i.Gender,
    i.MaritalStatus,
    i.BusinessTravel,
    i.OverTime,
    i.NumCompaniesWorked,
    i.TotalWorkingYears,
    i.YearsAtCompany,
    i.YearsInCurrentRole,
    i.YearsSinceLastPromotion,
    i.YearsWithCurrManager,
    i.TrainingTimesLastYear
FROM IBM_DATA i
INNER JOIN D_Position p
    ON  LTRIM(RTRIM(i.Department)) = p.Department
    AND LTRIM(RTRIM(i.JobRole))    = p.JobRole
    AND i.JobLevel                 = p.JobLevel;
GO



-- FACT TABLE 1: F_Satisfaction

CREATE TABLE F_Satisfaction (
    SatisfactionID                  INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID                      INT  NOT NULL FOREIGN KEY REFERENCES D_Employee(EmployeeID),
    PositionID                      INT  NOT NULL FOREIGN KEY REFERENCES D_Position(PositionID),
    Inquiry_Date                    DATE NOT NULL ,
    Environment_Satisfaction        INT  NOT NULL,
    Job_Satisfaction                INT  NOT NULL,
    Job_Involvement                 INT  NOT NULL,
    Relationship_Satisfaction       INT  NOT NULL,
    Work_Life_Balance               INT  NOT NULL,

    -- Computed labels
    Environment_Satisfaction_Label  AS (CASE Environment_Satisfaction  WHEN 1 THEN 'Low' WHEN 2 THEN 'Medium' WHEN 3 THEN 'High' WHEN 4 THEN 'Very High' END) PERSISTED,
    Job_Satisfaction_Label          AS (CASE Job_Satisfaction          WHEN 1 THEN 'Low' WHEN 2 THEN 'Medium' WHEN 3 THEN 'High' WHEN 4 THEN 'Very High' END) PERSISTED,
    Job_Involvement_Label           AS (CASE Job_Involvement           WHEN 1 THEN 'Low' WHEN 2 THEN 'Medium' WHEN 3 THEN 'High' WHEN 4 THEN 'Very High' END) PERSISTED,
    Relationship_Satisfaction_Label AS (CASE Relationship_Satisfaction WHEN 1 THEN 'Low' WHEN 2 THEN 'Medium' WHEN 3 THEN 'High' WHEN 4 THEN 'Very High' END) PERSISTED,
    Work_Life_Balance_Label         AS (CASE Work_Life_Balance         WHEN 1 THEN 'Low' WHEN 2 THEN 'Medium' WHEN 3 THEN 'High' WHEN 4 THEN 'Very High' END) PERSISTED
);
GO

INSERT INTO F_Satisfaction (
    EmployeeID, PositionID, Inquiry_Date,
    Environment_Satisfaction, Job_Satisfaction, Job_Involvement,
    Relationship_Satisfaction, Work_Life_Balance
)
SELECT
    i.EmployeeNumber,
    p.PositionID,
    CAST('2026-01-22' AS DATE),
    i.EnvironmentSatisfaction,
    i.JobSatisfaction,
    i.JobInvolvement,
    i.RelationshipSatisfaction,
    i.WorkLifeBalance
FROM IBM_DATA i
INNER JOIN D_Position p
    ON  LTRIM(RTRIM(i.Department)) = p.Department
    AND LTRIM(RTRIM(i.JobRole))    = p.JobRole
    AND i.JobLevel                 = p.JobLevel;
GO

-- PingPong survey insert
INSERT INTO F_Satisfaction (
    EmployeeID, PositionID, Inquiry_Date,
    Environment_Satisfaction, Job_Satisfaction, Job_Involvement,
    Relationship_Satisfaction, Work_Life_Balance
)
SELECT
    s.EmployeeNumber,
    p.PositionID,
    CONVERT(VARCHAR(10), 
    CAST(
        SUBSTRING(CONVERT(VARCHAR(10), s.Datasurvey, 23), 1, 5) +
        SUBSTRING(CONVERT(VARCHAR(10), s.Datasurvey, 23), 9, 2) +
        '-' +
        SUBSTRING(CONVERT(VARCHAR(10), s.Datasurvey, 23), 6, 2)
    AS DATE)
, 23),
    s.EnvironmentSatisfaction,
    s.JobSatisfaction,
    s.JobInvolvement,
    s.RelationshipSatisfaction,
    s.WorkLifeBalance
FROM dbo.PingPongSurvey s
INNER JOIN D_Employee e ON e.EmployeeID = s.EmployeeNumber
INNER JOIN D_Position p ON p.PositionID = e.PositionID;
GO



-- FACT TABLE 2: F_Performance


CREATE TABLE F_Performance (
    PerformanceID           INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID              INT  NOT NULL FOREIGN KEY REFERENCES D_Employee(EmployeeID),
    PositionID              INT  NOT NULL FOREIGN KEY REFERENCES D_Position(PositionID),
    DatePerformanceReview   DATE NOT NULL ,
    Performance_Rating      INT  NOT NULL,

    Performance_Rating_Label AS (
        CASE Performance_Rating
            WHEN 1 THEN 'Low'
            WHEN 2 THEN 'Good'
            WHEN 3 THEN 'Excellent'
            WHEN 4 THEN 'Outstanding'
        END
    ) PERSISTED
);
GO

INSERT INTO F_Performance (EmployeeID, PositionID, DatePerformanceReview, Performance_Rating)
SELECT
    i.EmployeeNumber,
    p.PositionID,
    CAST('2026-01-22' AS DATE),
    i.PerformanceRating
FROM IBM_DATA i
INNER JOIN D_Position p
    ON  LTRIM(RTRIM(i.Department)) = p.Department
    AND LTRIM(RTRIM(i.JobRole))    = p.JobRole
    AND i.JobLevel                 = p.JobLevel;
GO



-- FACT TABLE 3: F_Employee_History


CREATE TABLE F_Employee_History (
    HistoryID            INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID           INT  NOT NULL FOREIGN KEY REFERENCES D_Employee(EmployeeID),
    PositionID           INT  NOT NULL FOREIGN KEY REFERENCES D_Position(PositionID),
    Review_Date          DATE NOT NULL ,
    DailyRate            INT  NOT NULL,
    HourlyRate           INT  NOT NULL,
    MonthlyIncome        INT  NOT NULL,
    MonthlyRate          INT  NOT NULL,
    StockOptionLevel     INT  NOT NULL,
    SalaryHike           INT  NOT NULL,

    Stock_Option_Category AS (
        CASE StockOptionLevel
            WHEN 0 THEN 'None'
            WHEN 1 THEN 'Low'
            WHEN 2 THEN 'Medium'
            WHEN 3 THEN 'High'
        END
    ) PERSISTED
);
GO

INSERT INTO F_Employee_History (
    EmployeeID, PositionID, Review_Date,
    DailyRate, HourlyRate, MonthlyIncome, MonthlyRate, StockOptionLevel, SalaryHike
)
SELECT
    i.EmployeeNumber,
    p.PositionID,
   DATEADD(
    DAY,
    ABS(CHECKSUM(NEWID())) % 
        DATEDIFF(
            DAY,
            DATEFROMPARTS(YEAR(GETDATE()) - i.YearsAtCompany, 1, 1),
            GETDATE()
        ),
    DATEFROMPARTS(YEAR(GETDATE()) - i.YearsAtCompany, 1, 1)
),
    i.DailyRate,
    i.HourlyRate,
    i.MonthlyIncome,
    i.MonthlyRate,
    i.StockOptionLevel,
    i.PercentSalaryHike
FROM IBM_DATA i
INNER JOIN D_Position p
    ON  LTRIM(RTRIM(i.Department)) = p.Department
    AND LTRIM(RTRIM(i.JobRole))    = p.JobRole
    AND i.JobLevel                 = p.JobLevel;
GO

SELECT *
FROM [D_Employee]

SELECT *
FROM D_Position

SELECT *

FROM F_Employee_History

SELECT *
FROM F_Performance

SELECT *
FROM F_Satisfaction