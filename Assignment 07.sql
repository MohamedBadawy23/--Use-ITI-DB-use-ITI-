/*======================================== Assignment 07 ========================================*/

/*== Part 01 (Functions) ==*/

--Use ITI DB:
use ITI
--1.	Create a scalar function that takes a date and returns the Month name of that date.
Go
Create Function GetMonthNameByDate(@date date)
Returns Varchar(max)
Begin
	return Format(@date , 'MMMM')
End
Go
--Run
Select dbo.GetMonthNameByDate(GetDate())

--2.	 Create a multi-statements table-valued function that takes 2 integers and returns the values between them.
Go
Create Function GetValuesBetween2Num(@Num1 int , @Num2 int)
Returns @table table(ValueInBetween int)
AS
Begin
	While(@Num1 < @Num2-1)
		begin
			Set @Num1 += 1
			Insert into @table Values(@Num1)
		End
		Return
End
GO
--Run

Select * From dbo.GetValuesBetween2Num(1,10)


--3.	 Create a table-valued function that takes Student No and returns Department Name with Student full name.
GO
Create Function GetDeptNameByStudentNum(@StudentNum int)
Returns @table Table (FullName Varchar(max) , DeptName Varchar(Max))
AS
Begin
	Insert into @table
	Select CONCAT(S.St_Fname , ' ' , S.St_Lname) ,  D.Dept_Name
	From Student S , Department D
	Where D.Dept_Id = S.Dept_Id and S.St_Id = @StudentNum
	Return 
End
GO
--Run

Select * From dbo.GetDeptNameByStudentNum(1) 
--4.	Create a scalar function that takes Student ID and returns a message to user 
	--a.	If first name and Last name are null then display 'First name & last name are null'
	--b.	If First name is null then display 'first name is null'
	--c.	If Last name is null then display 'last name is null'
	--d.	Else display 'First name & last name are not null'

GO
Create Function ShowMessageBassedOnStudentName(@StudentNum int)
Returns Varchar(Max)
Begin
	
	Declare @Msg Varchar(Max)
	Declare @FName Varchar(Max)
	Declare @LName Varchar(Max)

	Select @FName =  S.St_Fname , @LName = S.St_Lname
	From Student S
	Where S.St_Id = @StudentNum 

	if(@FName Is NULL) and (@LName Is NULL)
		Select @Msg =  'First name & last name are null'
	else if (@FName Is NULL)
		Select @Msg =  'first name is null'
	else if (@LName Is NULL)
		Select @Msg =  'last name is null'
	else
		Select @Msg ='First name & last name are not null'

	Return @Msg
		
End
GO

--Run
Select Dbo.ShowMessageBassedOnStudentName(22)

--5.	Create a function that takes an integer which represents the format of the Manager hiring date and displays department name, Manager Name and hiring date with this format.  
GO
Create Function GetManagerFromHirringDate(@Format int)
Returns @table Table
(
	DeptName Varchar(Max),
	ManagerName Varchar(Max),
	HirringDate Varchar(MAx)
)

AS
Begin
	Insert into @table
	Select D.Dept_Name , I.Ins_Name , CONVERT(varchar , D.Manager_hiredate ,@Format )
	From Instructor I , Department D
	Where D.Dept_Id = I.Dept_Id
	Return
End
Go

--Run

Select * From Dbo.GetManagerFromHirringDate(110)
--6.	Create multi-statement table-valued function that takes a string
	--a.	If string='first name' returns student first name
	--b.	If string='last name' returns student last name 
	--c.	If string='full name' returns Full Name from student table  (Note: Use “ISNULL” function)
GO
Create Function GetStudentNameBassedOnPassedFormat(@Format Varchar(Max))
Returns @table Table (StudentName varchar(Max))
As
Begin
	if (@Format = 'first name')
		Insert into @table
		Select ISNULL( S.St_Fname , 'Not Found')
		From Student S
	else if (@Format = 'last name')
		Insert into @table
		Select ISNULL( S.St_Lname , 'Not Found')
		From Student S
	else if (@Format = 'full name' )
		Insert into @table
		Select ISNULL(S.St_Fname , 'Not Found') + ISNULL( S.St_Lname , 'Not Found')
		From Student S 
	Return

End
GO

Select * From Dbo.GetStudentNameBassedOnPassedFormat('first name')


--7.	Create function that takes project number and display all employees in this project (Use MyCompany DB)
Use MyCompany
Go
Create Function GetEmployeesByPNumber(@ProjectNum int)
Returns @Table Table ([Employee Name] varchar(Max))
AS
Begin
	Insert Into @Table
	Select  CONCAT(E.Fname , ' ' , E.Lname)
	From Employee E , Works_for W , Project P
	Where E.SSN = W.ESSn and P.Pnumber = W.Pno and P.Pnumber = @ProjectNum
	Return
End
Go


--Run 

Select * From Dbo.GetEmployeesByPNumber(100)
/*============================================================================================================================*/

/*== Part 02 (Views) ==*/
--Use ITI DB:
use iti
--1.	 Create a view that displays the student's full name, course name if the student has a grade more than 50. 
Go
Create View DisplayStudentsCoursesGrades
AS
	Select CONCAT(S.St_Fname , St_Lname) As  [Full Name] , C.Crs_Name [Course Name]  
	From Student S , Stud_Course SC , Course C
	Where S.St_Id = SC.St_Id and C.Crs_Id = Sc.Crs_Id and SC.Grade > 50
Go
--Run

Select * From DisplayStudentsCoursesGrades

--2.	 Create an Encrypted view that displays instructor names and the topics they teach. 

Go
Create OR Alter View InstructorsTopicsView
With Encryption
AS
	Select Distinct I.Ins_Name , T.Top_Name
	From Instructor I , Topic T , Ins_Course IC , Course C
	Where I.Ins_Id = IC.Ins_Id and C.Crs_Id = IC.Crs_Id and T.Top_Id = C.Top_Id
Go

--Run

Select * From InstructorsTopicsView

--3.	Create a view that will display Instructor Name, Department Name for the ‘SD’ or ‘Java’ Department “use Schema binding” and describe what is the meaning of Schema Binding
Go
Create View InstructorSD_JavaView 
With Schemabinding , encryption
AS
	Select I.Ins_Name , D.Dept_Name
	From dbo.Instructor I ,  dbo.Department D
	Where I.Dept_Id = D.Dept_Id and D.Dept_Name in ('SD' , 'Java')
Go

--Run

Select * From InstructorSD_JavaView  

--4. Create a view “V1” that displays student data for student who lives in Alex or Cairo. 
--Note: Prevent the users to run the following query 
--Update V1 set st_address=’tanta’
--Where st_address=’alex’;
GO
Create View V1
With Encryption
AS
	Select *
	From Student 
	Where St_Address in ('Alex' , 'Cairo') With Check Option 
Go


--Run

Select * From V1

Update V1 set st_address='tanta'
Where st_address='alex'


--5.	Create a view that will display the project name and the number of employees working on it. (Use Company DB)
use MyCompany
Go 
Create View DiplayProjectNameNumOfEmp
AS
	Select P.Pname , COUNT(W.ESSn) As [Number Of Employees]
	From Project P , Works_for W
	Where P.Pnumber = W.Pno
	Group By P.Pname
Go 



--Run

Select * From DiplayProjectNameNumOfEmp

-- Part 2
--use IKEA_Company_DB:
use [IKEA_Company]
--1.	Create a view named   “v_clerk” that will display employee Number ,project Number, the date of hiring of all the jobs of the type 'Clerk'.
Go
Create View v_clerk
AS
	Select  EmpNo , ProjectNo , Enter_Date
	From Works_on 
	Where Job = 'Clerk'
Go
--Run

Select * From v_clerk
--2.	 Create view named  “v_without_budget” that will display all the projects data without budget
GO
Create View v_without_budget
AS
	 Select ProjectNo , ProjectName
	 From HR.Project
Go
--Run
Select * From v_without_budget

--3.	Create view named  “v_count “ that will display the project name and the Number of jobs in it
GO
Create View v_count
AS
	Select P.ProjectName , COUNT(W.Job) As [Number Of Jobs]
	From HR.Project P , Works_on W
	Where P.ProjectNo = W.ProjectNo
	Group By P.ProjectName
GO
--Run

Select * From v_count

--4.	 Create view named ” v_project_p2” that will display the emp# s for the project# ‘p2’ . (use the previously created view  “v_clerk”)
GO
Create View v_project_p2
AS
	Select V.EmpNo [Employee Number]
	From v_clerk V
	Where V.ProjectNo = 2
GO
--Run

Select * From v_project_p2

--5.	modify the view named  “v_without_budget”  to display all DATA in project p1 and p2.

Alter View v_without_budget
AS
	Select *
	From HR.Project P
	Where P.ProjectNo in (1,2)

Select * From v_without_budget

--6.	Delete the views  “v_ clerk” and “v_count”

Drop View v_clerk , v_count

--7.	Create view that will display the emp# and emp last name who works on deptNumber is ‘d2’
Go
Create View DisplayEmployee
AS
	Select EmpNo , EmpLname
	From HR.Employee
	Where DeptNo = 2 
GO 
--Run

Select * From DisplayEmployee

--8.	Display the employee  lastname that contains letter “J” (Use the previous view created in Q#7)

Select E.EmpLname
From DisplayEmployee E
Where E.EmpLname Like '%J%'

--9.	Create view named “v_dept” that will display the department# and department name
GO
Create View v_dept
AS
	Select DeptNo [Depatment Num] , DeptName [Department Name]
	From Department
GO
--Run

Select * From v_dept
--10) using the previous view try enter new department data where dept# is (d4) and dept name is ‘Development’

Insert Into v_dept Values (4 , 'Development')

--11) Create view name (v_2006_check) that will display employee Number, 
--    the project Number where he works and the date of joining the project 
--    which must be from the first of January and the last of December 2006.
--    this view will be used to insert data so make sure that the coming new data must match the condition

Go
Create View v_2006_check
AS
	Select EmpNo [Employee Number] , ProjectNo [Project Number] , Enter_Date [Joining Date]
	From Works_on 
	Where Enter_Date between '2006-1-1' and '2006-12-30' With Check Option
Go 
--Run
Select * From v_2006_check

Insert Into v_2006_check Values(22222 , 2 , '2006-2-1') -- successful insertion
 Insert Into v_2006_check Values(22222 , 1 , '2007-2-1')-- failed because Date Range

/*========================================================================================================*/
--Part 03

--Create a database “by Wizard” named “RouteCompany”
--1.	Create the following tables with all the required information and load the required data as specified in each table using insert statements[at least two rows]
use RouteCompany

--Table Name				Details										Comments

--Department		--DeptNo (PK)	DeptName	Location      --	1-Create it programmatically	--[By Code]						
					--d1			Research		NY
					--d2			Accounting		DS
					--d3			Marketing		KW
															
create table Department
(
DeptNo int Primary Key,
DeptName varchar(50),
Location varchar(20)
)

insert into Department
values (1 , 'Research' , 'NY'),
       (2 ,'Accounting','DS'),
	   (3 , 'Marketing','KW')


--Employee	--EmpNo (PK)	Emp Fname	Emp Lname	DeptNo		Salary
			--25348			Mathew		Smith		d3			2500
			--10102			Ann			Jones		d3			3000
			--18316			John		Barrymore	d1			2400
			--29346			James		James		d2			2800
			--9031			Lisa		Bertoni		d2			4000
			--2581			Elisa		Hansel		d2			3600
			--28559			Sybl		Moser		d1			2900
--1-Create it programmatically
--2-PK constraint on EmpNo
--3-FK constraint on DeptNo
--4-Unique constraint on Salary
--5-EmpFname, EmpLname don’t accept null values 
create table Employee
(
EmpNo int Primary Key,
EmpFname varchar(40) not null,
EmpLname varchar(40) not null,
DeptNo int foreign key references Department(DeptNo) ,
Salary int unique
)

insert into Employee
values (25348 , 'Mathew' , 'Smith' , 3 , 2500),
       (10102 , 'Ann' , 'Jones' , 3 , 3500),
	   (18316 , 'John' , 'Barrimore' , 1 , 2400),
       (29346 , 'James' , 'James' , 2 , 2800),
	   (9031 , 'Lisa' , 'Bertoni' , 2 , 4000),
	   (2581 , 'Elisa' , 'Hansel' , 2 , 3600),
	   (28559 , 'Sybl' , 'Moser' , 1 , 2900)

--Project	--ProjectNo (PK)	ProjectName		Budget
			--p1				Apollo			120000
			--p2				Gemini			95000
			--p3				Mercury			185600
--1-Create it by Wizard
--2-ProjectName can't contain null values
--3-Budget allow null

insert into Project
values ( 1 , 'Apollo' , 120000),
       ( 2 , 'Gemini' , 95000),
       ( 3 , 'Mercury' , 185600)

--Works_on	--EmpNo (PK)	ProjectNo(PK)	Job			Enter_Date
			--10102				p1			Analyst		2006.10.1
			--10102				p3			Manager		2012.1.1
			--25348				p2			Clerk		2007.2.15
			--18316				p2			NULL		2007.6.1
			--29346				p2			NULL		2006.12.15
			--2581				p3			Analyst		2007.10.15
			--9031				p1			Manager		2007.4.15
			--28559				p1			NULL		2007.8.1
			--28559				p2			Clerk		2012.2.1
			--9031				p3			Clerk		2006.11.15
			--29346				p1			Clerk		2007.1.4

--1-Create it Wizard
--2- EmpNo INTEGER NOT NULL
--3-ProjectNo doesn't accept null values
--4-Job can accept null
--5-Enter_Date can’t accept null
--and has the current system date as a default value[visually]
--6-The primary key will be EmpNo,ProjectNo) 
--7-there is a relation between works_on and employee, Project  tables

insert into Works_on
values (10102 , 1 , 'Analyst' ,'2006.10.1'),
       (10102 , 3 , 'Manager' ,'2012.1.1'),
	   (25348 , 2 , 'Clerk' ,'2007.2.15'),
       (18316 ,2,NULL,'2007.6.1'),
       (29346,2,NULL,'2006.12.15'),
       (2581,3,'Analyst','2007.10.15'),
       (9031,1,'Manager','2007.4.15'),
       (28559,1,NULL,'2007.8.1'),
       (28559,2, 'Clerk','2012.2.1'),
       (9031,3,'Clerk','2006.11.15'),
       (29346,1,'Clerk','2007.1.4')

---------------------------------------------------------------------------------------------

--Testing Referential Integrity	
--1-Add new employee with EmpNo =11111 In the works_on table [what will happen]
insert into works_on (EmpNo)
values (11111)

-- The statement has been terminated (INSERT fails) 
-- Cannot insert the value NULL into column 'ProjectNo'column does not allow nulls
---------------------------------------------------------------------------------------------
--2-Change the employee number 10102  to 11111  in the works on table [what will happen]

update Works_on
set EmpNo = 11111
where EmpNo = 10102

-- because there is no employee with number 11111 
-- The UPDATE statement conflicted with the FOREIGN KEY constraint "FK_Works_on_Employee".
-- The conflict occurred in database "RouteCompany", table "HR.Employee", column 'EmpNo'.

---------------------------------------------------------------------------------------------
--3-Modify the employee number 10102 in the employee table to 22222. [what will happen]

update Employee
set EmpNo = 22222
where EmpNo = 10102

-- The statement has been terminated.
-- The UPDATE statement conflicted with the REFERENCE constraint "FK_Works_on_Employee". 
-- The conflict occurred in database "RouteCompany", table "dbo.Works_on", column 'EmpNo'.

---------------------------------------------------------------------------------------------
--4-Delete the employee with id 10102

delete from Employee 
where EmpNo = 10102

-- The statement has been terminated.
--The DELETE statement conflicted with the REFERENCE constraint "FK_Works_on_Employee". 
-- The conflict occurred in database "RouteCompany", table "dbo.Works_on", column 'EmpNo'.

---------------------------------------------------------------------------------------------

--Table Modification

--1-Add  TelephoneNumber column to the employee table[programmatically]

Alter Table Employee
Add TelephoneNumber Varchar(15)

--2-drop this column[programmatically]

Alter Table Employee
Drop Column TelephoneNumber

--3-Build A diagram to show Relations between tables
----------------------------------------------------------------------------------------------
--2.	Create the following schema and transfer the following tables to it 
	--a.	Company Schema 
		--i.	Department table 
		--ii.	Project table 
Go
Create Schema Company
GO

Alter Schema Company Transfer Department

Alter Schema Company Transfer Project



	--b.	Human Resource Schema
		--i.	  Employee table 

GO
Create Schema HR
GO

Alter Schema HR Transfer Employee


--3.	Increase the budget of the project where the manager number is 10102 by 10%.


Update [Company].[Project]
Set Budget += Budget * 0.1
From HR.Employee Emp , [Company].[Project] P , [dbo].[Works_on] W
Where Emp.EmpNo = W.EmpNo and P.ProjectNo = W.ProjectNo and W.Job = 'manager' and Emp.EmpNo = 10102


--4.	Change the name of the department for which the employee named James works.The new department name is Sales.

Update [Company].[Department]
Set DeptName = 'Sales'
From [Company].[Department] Dep , [HR].[Employee] Emp
Where Dep.DeptNo = Emp.DeptNo and Emp.EmpFname = 'James'


--5.	Change the enter date for the projects for those employees who work in project p1 and belong to department ‘Sales’. The new date is 12.12.2007.


Update Works_On
Set Enter_Date = '12.12.2007'
From [HR].[Employee] Emp , [Company].[Department] Dep , Works_On W , [Company].[Project] P
Where Emp.EmpNo = W.EmpNo and Dep.DeptNo = Emp.DeptNo and W.ProjectNo = 1 and Dep.DeptName = 'Sales'



--6.	Delete the information in the works_on table for all employees who work for the department located in KW.

Delete From Works_on
Where EmpNo in 
(
	Select EmpNo
	From [HR].[Employee] E , [Company].[Department] D 
	Where D.DeptNo = E.DeptNo and D.Location = 'KW'  
)


------------------------------------------------------------------------------------------------------------------------
