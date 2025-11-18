-- ============================
-- COLLEGE COURSE & ATTENDANCE MANAGEMENT SYSTEM
-- TECHNOLOGIES: MySQL, SQL, PL/SQL
-- ============================

CREATE DATABASE college_db;
USE college_db;

-- ============================
-- 1. STUDENTS TABLE
-- ============================
CREATE TABLE Students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    usn VARCHAR(20) UNIQUE,
    class_id INT,
    email VARCHAR(50)
);

-- ============================
-- 2. TEACHERS TABLE
-- ============================
CREATE TABLE Teachers (
    teacher_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    subject_id INT,
    email VARCHAR(50)
);

-- ============================
-- 3. SUBJECTS TABLE
-- ============================
CREATE TABLE Subjects (
    subject_id INT PRIMARY KEY AUTO_INCREMENT,
    subject_name VARCHAR(50)
);

-- ============================
-- 4. CLASSES TABLE
-- ============================
CREATE TABLE Classes (
    class_id INT PRIMARY KEY AUTO_INCREMENT,
    class_name VARCHAR(20),
    semester INT
);

-- ============================
-- 5. ATTENDANCE TABLE
-- ============================
CREATE TABLE Attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    subject_id INT,
    date DATE,
    status ENUM('Present','Absent'),
    percentage DECIMAL(5,2),
    FOREIGN KEY(student_id) REFERENCES Students(student_id),
    FOREIGN KEY(subject_id) REFERENCES Subjects(subject_id)
);

-- ============================
-- SAMPLE DATA INSERTION
-- ============================
INSERT INTO Classes(class_name, semester) VALUES ('CSE-A', 3), ('CSE-B', 3);

INSERT INTO Students(name, usn, class_id, email) VALUES
('Rohan', '1DS22CS001', 1, 'rohan@mail.com'),
('Priya', '1DS22CS002', 1, 'priya@mail.com'),
('Karthik', '1DS22CS003', 2, 'karthik@mail.com');

INSERT INTO Subjects(subject_name) VALUES ('DBMS'), ('OOP'), ('Maths');

INSERT INTO Teachers(name, subject_id, email) VALUES
('Manjunath', 1, 'manju@college.com'),
('Anitha', 2, 'anitha@college.com');

INSERT INTO Attendance(student_id, subject_id, date, status)
VALUES
(1,1,'2025-01-01','Present'),
(1,1,'2025-01-02','Absent'),
(2,1,'2025-01-01','Present'),
(3,2,'2025-01-01','Present');

-- ============================
-- TRIGGER: AUTO CALCULATE ATTENDANCE %
-- ============================
DELIMITER $$

CREATE TRIGGER update_attendance_percentage
AFTER INSERT ON Attendance
FOR EACH ROW
BEGIN
    DECLARE total INT DEFAULT 0;
    DECLARE present_count INT DEFAULT 0;
    DECLARE percent DECIMAL(5,2);

    SELECT COUNT(*) INTO total 
    FROM Attendance 
    WHERE student_id = NEW.student_id AND subject_id = NEW.subject_id;

    SELECT COUNT(*) INTO present_count
    FROM Attendance 
    WHERE student_id = NEW.student_id AND subject_id = NEW.subject_id
    AND status = 'Present';

    SET percent = (present_count / total) * 100;

    UPDATE Attendance 
    SET percentage = percent
    WHERE student_id = NEW.student_id AND subject_id = NEW.subject_id;
END$$

DELIMITER ;

-- ============================
-- STORED PROCEDURE: MONTHLY REPORT
-- ============================
DELIMITER $$

CREATE PROCEDURE monthly_report(IN stu_id INT, IN sub_id INT)
BEGIN
    SELECT student_id, subject_id, date, status, percentage
    FROM Attendance
    WHERE student_id = stu_id 
      AND subject_id = sub_id
      AND MONTH(date) = MONTH(CURRENT_DATE());
END$$

DELIMITER ;

-- ============================
-- VIEW: LOW ATTENDANCE (<75%)
-- ============================
CREATE VIEW low_attendance AS
SELECT student_id, subject_id, percentage
FROM Attendance
WHERE percentage < 75;

-- ============================
-- END OF PROJECT
-- ============================
