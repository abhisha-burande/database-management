Create database SCHEDULE

use SCHEDULE

---Student
CREATE TABLE Student (
NetID         VARCHAR(50) NOT NULL, 
FirstName       VARCHAR(100) NOT NULL,
LastName        VARCHAR(100),
Major           VARCHAR(50) NOT NULL,
Email          VARCHAR(200),
GradutionSem    VARCHAR(50) NOT NULL,
StatusFlag     CHAR (10) NOT NULL,
CONSTRAINT Student_PK PRIMARY KEY(NetID),
Check (StatusFlag in('I','D'))
);

 --2. International
 CREATE TABLE International(
 SevisNum           VARCHAR(50) NOT NULL,
 NetID         VARCHAR(50)         ,
 CONSTRAINT International_PK PRIMARY KEY(SevisNum),
 CONSTRAINT International_FK1 FOREIGN KEY(NetID) references Student (NetID)
 
 );

--3. Domestic

 CREATE TABLE Domestic(
  RealId          VARCHAR(50) NOT NULL,
  NetID         VARCHAR(50) ,
 CONSTRAINT Domestic_PK PRIMARY KEY(RealId),
 CONSTRAINT Domestic_FK1 FOREIGN KEY(NetID) references Student (NetID));

 --4. Department

 Create table Department(
 DeptId    VARCHAR(50) NOT NULL,
 DeptName  VARCHAR(100),
  CONSTRAINT Department_PK PRIMARY KEY(DeptId));
 
 --4. Instructor
create table Instructor
(CsuId              VARCHAR(50) NOT NULL ,
 FirstName          VARCHAR(50) NOT NULL,
 LastName           VARCHAR(25) ,
 Email              VARCHAR(200),
 Officeloc          VARCHAR(50),
 DeptId             VARCHAR(50),
  CONSTRAINT Instructor_PK PRIMARY KEY(CsuId),
  CONSTRAINT Instructor_FK1 FOREIGN KEY(DeptId) references Department (DeptId)
);
  
  --5. Courses
create table Course
(CourseId   VARCHAR(50) NOT NULL,
  CourseName      VARCHAR(60),
  Courselevel VARCHAR(10),
  CreditHour   integer,
  preReq       VARCHAR(50) NULL,
  CONSTRAINT Course_PK PRIMARY KEY(CourseId),
   CONSTRAINT Course_FK1 FOREIGN KEY(preReq) references Course (CourseId));



--6.Book

create table Book
(
 BookId       VARCHAR(100) NOT NULL,
 BookName     VARCHAR(100) NOT NULL,
 Author        VARCHAR(50),
 Publisher     VARCHAR(100),
 CONSTRAINT pk_CourseBook PRIMARY KEY (BookId)
);

---7 Section
create table Section
(
  SectId             VARCHAR(50) NOT NULL,
  CourseId           VARCHAR(50) NOT NULL,
  CsuId              VARCHAR(50) NOT NULL, 
  TermCode           VARCHAR(50) NOT NULL,
  RoomNum            VARCHAR(100)  NOT NULL,
  DayOfClass          VARCHAR(100),
  Timing              VARCHAR(100),
  CONSTRAINT Section_PK PRIMARY KEY(SectId) ,
  CONSTRAINT Section_FK1 FOREIGN KEY(CourseId) references Course (CourseId),
  CONSTRAINT Section_FK2 FOREIGN KEY(CsuId) references Instructor (CsuId),

 
);

--8.Enrollment

create table Enrollment
(
  NetID VARCHAR(50),
  SectId  VARCHAR(50),
  Completion_Date VARCHAR(50),

CONSTRAINT Enrollment_PK PRIMARY KEY(NetID,SectId),
CONSTRAINT Enrollment_FK1 FOREIGN KEY(NetID) references Student (NetID),
CONSTRAINT Enrollment_FK2 FOREIGN KEY(SectId) references Section (SectId),
);

--9.BookRef

create table BookRef
(
 
 SectId      VARCHAR(50) NOT NULL , 
 BookId       VARCHAR(100)  NOT NULL,

 CONSTRAINT BookRef_PK PRIMARY KEY(SectId,BookId),

 CONSTRAINT BookRef_FK1 FOREIGN KEY(SectId) references Section (SectId),
 CONSTRAINT BookRef_FK2 FOREIGN KEY(BookId) references Book (BookId));



 BULK
INSERT Department
FROM 'C:\Users\anshi\Desktop\DBMS-12dec\Text files\Department.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO
---------------------INSTRUCTOR
BULK
INSERT Instructor
FROM 'C:\Users\anshi\Desktop\DBMS-12dec\Text files\Instructor.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO
---------Course
BULK
INSERT Course
FROM 'C:\Users\anshi\Desktop\DBMS-12dec\Text files\Courses.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO
---------Book
BULK
INSERT Book
FROM 'C:\Users\anshi\Desktop\DBMS-12dec\Text files\Book.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO
------Student
BULK
INSERT Student
FROM 'C:\Users\anshi\Desktop\DBMS-12dec\Text files\Student.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO

----International

BULK
INSERT International
FROM 'C:\Users\anshi\Desktop\DBMS-12dec\Text files\International.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO

---Domestic
BULK
INSERT Domestic
FROM 'C:\Users\anshi\Desktop\DBMS-12dec\Text files\Domestic.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO
---Section
BULK
INSERT Section
FROM 'C:\Users\anshi\Desktop\DBMS-12dec\Text files\Section.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO
---Enrollment
BULK
INSERT Enrollment
FROM 'C:\Users\anshi\Desktop\DBMS-12dec\Text files\Enrollment.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO
---BookRef
BULK
INSERT BookRef
FROM 'C:\Users\anshi\Desktop\DBMS-12dec\Text files\BookRef.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO

--Display all tables with each rows and columns.


SELECT * from Student;
SELECT * from Instructor;
SELECT * from Section;
SELECT * from Book;
SELECT * from BookRef;
SELECT * from Enrollment;
SELECT * from Course;
SELECT * from Department;
SELECT * from International;
SELECT * from Domestic;


---Query

---1. 	Count the number of students who are graduating in the same semester. 

select GradutionSem,COUNT(*) AS "Total Student Graduating" from Student
GROUP BY GradutionSem ;

---2.	Display the students name and major who have taken BAN 610.


SELECT Student.FirstName,Student.LastName,Student.Major
FROM Student where Student.NetID IN(
select NetID from Enrollment
Where SectId IN(
select SectId from Section
 where CourseId ='BAN610'));

 ----3.	Display the NetID and student name of the students who have taken more than 8 courses in 2019

 SELECT Student.NetID,Student.FirstName,Student.LastName
FROM Student
WHERE Student.NetID
IN (SELECT Enrollment.NetID FROM Enrollment
     WHERE Enrollment.Completion_Date LIKE '%19'
	 GROUP BY Enrollment.NetID
	 HAVING COUNT(Enrollment.SectId) >8);


--4.	Display the NetID and the total credit hours taken by each student in 2019.


  select Enrollment.NetID,
COUNT(Section.CourseId)*Course.CreditHour  AS "2019 CreditHours" 
from 
  Section,Enrollment, Course 

 where Section.SectId = Enrollment.SectId
 AND Section.CourseId= Course.CourseId
  AND Enrollment.Completion_Date LIKE '%19'
 GROUP BY Enrollment.NetID,Course.CreditHour ;

 
 --5.Display the instructors name and the number of course books prescribed by each instructor.

SELECT Instructor.FirstName,Instructor.LastName,COUNT(distinct(BookRef.BookId)) AS " TotalBookPrescribed"
 FROM Instructor,BookRef,Section
 WHERE BookRef.SectId =Section.SectId
 AND Instructor.CsuId =Section.CsuId
 GROUP BY Instructor.FirstName,Instructor.LastName
 HAVING COUNT(BookRef.BookId) >= 1
 ORDER BY [ TotalBookPrescribed]DESC;

 ---Additional 1.Show Course details who has prerequistes

Select * from Course where preReq ='BAN602';
Select * from Course where preReq ='BAN610';


 ---Additional 2. Display student schedule who took BAN602 under prof Khodursky

 SELECT Student.FirstName,Student.LastName,Student.Major,Section.SectId,Section.DayOfClass,Section.Timing ,Enrollment.NetID 
FROM Student,Section ,Enrollment 
where Enrollment.NetID =Student.NetID  
And Enrollment.SectId = Section.SectId 
AND Section.CourseId ='BAN602'
AND Section.CsuId =  (Select CsuId from Instructor where LastName = 'Khodursky');





