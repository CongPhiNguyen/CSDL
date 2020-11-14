CREATE DATABASE QLGV

-- Cau 1 Tạo quan hệ và khai báo tất cả các ràng buộc khóa chính, khóa ngoại. Thêm vào 3 thuộc tính 
-- GHICHU, DIEMTB, XEPLOAI cho quan hệ HOCVIEN
CREATE TABLE KHOA
(	MAKHOA	VARCHAR(4),
	TENKHOA	VARCHAR(40),
	NGTLAP	SMALLDATETIME,
	TRGKHOA	CHAR(4),
	CONSTRAINT PK_KHOA PRIMARY KEY (MAKHOA)
)

CREATE TABLE MONHOC
(	MAMH	VARCHAR(10),
	TENMH	VARCHAR(40),
	TCLT	TINYINT,
	TCTH	TINYINT,
	MAKHOA	VARCHAR(4),
	CONSTRAINT PK_MONHOC PRIMARY KEY (MAMH)
)

CREATE TABLE DIEUKIEN
(	MAMH	VARCHAR(10),
	MAMH_TRUOC	VARCHAR(10),
	CONSTRAINT PK_DIEUKIEN PRIMARY KEY (MAMH, MAMH_TRUOC)
)

CREATE TABLE GIAOVIEN
(	MAGV	CHAR(4),
	HOTEN	VARCHAR(40),
	HOCVI	VARCHAR(10),
	HOCHAM	VARCHAR(10),
	GIOITINH	VARCHAR(3),
	NGSINH	SMALLDATETIME,
	NGVL	SMALLDATETIME,
	HESO	NUMERIC(4,2),
	MUCLUONG	MONEY,
	MAKHOA	VARCHAR(4),
	CONSTRAINT PK_GIAOVIEN PRIMARY KEY (MAGV)
)

CREATE TABLE LOP
(	MALOP	CHAR(3),
	TENLOP	VARCHAR(40),
	TRGLOP	CHAR(5),
	SISO	TINYINT,
	MAGVCN	CHAR(4),
	CONSTRAINT PK_LOP PRIMARY KEY (MALOP)
)

CREATE TABLE HOCVIEN
(	MAHV	CHAR(5),
	HO		VARCHAR(40),
	TEN		VARCHAR(10),
	NGSINH	SMALLDATETIME,
	GIOITINH	VARCHAR(3),
	NOISINH	VARCHAR(40),
	MALOP	CHAR(3),
	CONSTRAINT PK_HOCVIEN PRIMARY KEY (MAHV)
)

CREATE TABLE GIANGDAY
(	MALOP	CHAR(3),
	MAMH	VARCHAR(10),
	MAGV	CHAR(4),
	HOCKY	TINYINT,
	NAM		SMALLINT,
	TUNGAY	SMALLDATETIME,
	DENNGAY	SMALLDATETIME,
	CONSTRAINT PK_GIANGDAY PRIMARY KEY (MALOP, MAMH)
)

CREATE TABLE KETQUATHI
(	MAHV	CHAR(5),
	MAMH	VARCHAR(10),
	LANTHI	TINYINT,
	NGTHI	SMALLDATETIME,
	DIEM	NUMERIC(4,2),
	KQUA	VARCHAR(10),
	CONSTRAINT PK_KETQUATHI PRIMARY KEY (MAHV, MAMH, LANTHI)
)

ALTER TABLE MONHOC
ADD CONSTRAINT FK_MONHOC_MAKHOA FOREIGN KEY REFERENCES KHOA(MAKHOA)
ALTER TABLE DIEUKIEN
ADD CONSTRAINT FK_DIEUKIEN_MAMH REFERENCES MONHOC(MAMH)
ALTER TABLE DIEUKIEN
ADD CONSTRAINT FK_DIEUKIEN_MAMH_TRUOC REFERENCES MONHOC(MAMH)
ALTER TABLE GIAOVIEN
ADD CONSTRAINT FK_GIAOVIEN_MAKHOA REFERENCES KHOA(MAKHOA)
ALTER TABLE LOP
ADD CONSTRAINT FK_LOP_MAGVCN FOREIGN KEY REFERENCES GIAOVIEN(MAGV)
ALTER TABLE HOCVIEN
ADD CONSTRAINT PK_HOCVIEN_MALOP FOREIGN KEY REFERENCES LOP(MALOP)
ALTER TABLE GIANGDAY
ADD CONSTRAINT FK_GIANGDAY_MALOP FOREIGN KEY REFERENCES LOP(MALOP)
ALTER TABLE GIANGDAY
ADD CONSTRAINT FK_GIANGDAY_MAMH FOREIGN KEY REFERENCES MONHOC(MAMH)
ALTER TABLE GIANGDAY
ADD CONSTRAINT FK_GIANGDAY_MAGV FOREIGN KEY REFERENCES GIAOVIEN(MAGV)
ALTER TABLE KETQUATHI
ADD CONSTRAINT FK_KETQUATHI_MAHV FOREIGN KEY REFERENCES HOCVIEN(MAHV)
ALTER TABLE KETQUATHI
ADD CONSTRAINT FK_KETQUATHI_MAMH  FOREIGN KEY REFERENCES MONHOC(MAMH)

ALTER TABLE HOCVIEN
ADD GHICHU TEXT

ALTER TABLE HOCVIEN
ADD DIEMTB NUMERIC(4,2)

ALTER TABLE HOCVIEN
ADD XEPLOAI VARCHAR(20)

-- CAU 2 Mã học viên là một chuỗi 5 ký tự, 3 ký tự đầu là mã lớp, 2 ký tự cuối cùng là số thứ tự học 
-- viên trong lớp. VD: “K1101”


-- CAU 3 Thuộc tính GIOITINH chỉ có giá trị là “Nam” hoặc “Nu”
ALTER TABLE HOCVIEN
ADD CONSTRAINT CHECK_GIOITINH_HOCVIEN CHECK (GIOITINH IN ('Nam', 'Nu'))

ALTER TABLE GIAOVIEN
ADD CONSTRAINT CHECK_GIOITINH_GIAOVIEN CHECK (GIOITINH IN ('Nam', 'Nu'))

-- CAU 4 Điểm số của một lần thi có giá trị từ 0 đến 10 và cần lưu đến 2 số lẽ (VD: 6.22)
ALTER TABLE KETQUATHI
ADD CONSTRAINT CHECK_DIEM CHECK (DIEM >= 0 AND DIEM <= 10)

-- CAU 5 Kết quả thi là “Dat” nếu điểm từ 5 đến 10 và “Khong dat” nếu điểm nhỏ hơn 5
SELECT
CASE
	WHEN DIEM < 5 THEN 'Khong dat' ELSE 'Dat'
END
AS KQUA FROM KETQUATHI

-- CAU 6 Học viên thi một môn tối đa 3 lần
ALTER TABLE KETQUATHI
ADD CONSTRAINT CHECK_LANTHI CHECK (LANTHI <= 3)

-- CAU 7 Học kỳ chỉ có giá trị từ 1 đến 3
ALTER TABLE GIANGDAY
ADD CONSTRAINT CHECK_HOCKY CHECK (HOCKY >= 1 AND HOCKY <= 3)

-- CAU 8 Học vị của giáo viên chỉ có thể là “CN”, “KS”, “Ths”, ”TS”, ”PTS”
ALTER TABLE GIAOVIEN
ADD CONSTRAINT CHECK_HOCVI CHECK (HOCVI IN ('CN', 'KS', 'Ths', 'TS', 'PTS'))

----------------------------------------------------------------------------------------------------------------------------------------
-- Nhập dữ liệu cho CSDL

-- KHOA
insert into KHOA
(MAKHOA,TENKHOA,NGTLAP,TRGKHOA)
values
('KHMT','Khoa hoc may tinh','7/6/2005','GV01'),
('HTTT','He thong thong tin','7/6/2005','GV02'),
('CNPM','Cong nghe phan mem','7/6/2005','GV04'),
('MTT','Mang va truyen thong','10/20/2005','GV03'),
('KTMT','Ky thuat may tinh','12/20/2005',Null)

-- LOP
insert into LOP
(MALOP,TENLOP,TRGLOP,SISO,MAGVCN)
values
('K11','Lop 1 khoa 1','K1108','11','GV07'),
('K12','Lop 2 khoa 1','K1205','12','GV09'),
('K13','Lop 3 khoa 1','K1305','12','GV14')

-- GIAOVIEN
insert into GIAOVIEN
(MAGV,HOTEN,HOCVI,HOCHAM,GIOITINH,NGSINH,NGVL,HESO,MUCLUONG,MAKHOA)
values
('GV01','Ho Thanh Son',     'PTS',   'GS',    'Nam',   '5/2/1950',    '1/11/2004',   '5',2250000,'KHMT'),
('GV02','Tran Tam Thanh',   'TS',    'PGS',   'Nam',   '12/17/1965',  '4/20/2004',   '4.5',2025000,'HTTT'),
('GV03','Do Nghiem Phung',  'TS',    'GS',    'Nu',    '8/1/1950',    '9/23/2004',   '4',1800000,'CNPM'),
('GV04','Tran Nam Son',     'TS',    'PGS',   'Nam',   '2/22/1961',   '1/12/2005',   '4.5',2025000,'KTMT'),
('GV05','Mai Thanh Danh',   'ThS',   'GV',    'Nam',   '3/12/1958',   '1/12/2005',   '3',1350000,'HTTT'),
('GV06','Tran Doan Hung',   'TS',    'GV',    'Nam',   '3/11/1953',   '1/12/2005',   '4.5',2025000,'KHMT'),
('GV07','Nguyen Minh Tien', 'ThS',   'GV',    'Nam',   '11/23/1971',  '3/1/2005',    '4',1800000,'KHMT'),
('GV08','Le Thi Tran',      'KS',    Null,    'Nu',    '3/26/1974',   '3/1/2005',    '1.69',760500,'KHMT'),
('GV09','Nguyen To Lan',    'ThS',   'GV',    'Nu',    '12/31/1966',  '3/1/2005',    '4',1800000,'HTTT'),
('GV10','Le Tran Anh Loan', 'KS',    Null,    'Nu',    '7/17/1972',   '3/1/2005',    '1.86',837000,'CNPM'),
('GV11','Ho Thanh Tung',    'CN',    'GV',    'Nam',   '1/12/1980',   '5/15/2005',   '2.67',1201500,'MTT'),
('GV12','Tran Van Anh',     'CN',    Null,    'Nu',    '3/29/1981',   '5/15/2005',   '1.69',760500,'CNPM'),
('GV13','Nguyen Linh Dan',  'CN',    Null,    'Nu',    '5/23/1980',   '5/15/2005',   '1.69',760500,'KTMT'),
('GV14','Truong Minh Chau', 'ThS',   'GV',    'Nu',    '11/30/1976',  '5/15/2005',   '3', 1350000,'MTT'),
('GV15','Le Ha Thanh','ThS',         'GV',    'Nam',   '5/4/1978',    '5/15/2005',   '3',  1350000,'KHMT')

-- HOCVIEN
insert into HOCVIEN
(MAHV,HO,TEN,NGSINH,GIOITINH,NOISINH,MALOP)
values
('K1101','Nguyen Van','A','1/27/1986','Nam','TpHCM','K11'),
('K1102','Tran Ngoc','Han','3/14/1986','Nu','Kien Giang','K11'),
('K1103','Ha Duy','Lap','4/18/1986','Nam','Nghe An','K11'),
('K1104','Tran Ngoc','Linh','3/30/1986','Nu','Tay Ninh','K11'),
('K1105','Tran Minh','Long','2/27/1986','Nam','TpHCM','K11'),
('K1106','Le Nhat','Minh','1/24/1986','Nam','TpHCM','K11'),
('K1107','Nguyen Nhu','Nhut','1/27/1986','Nam','Ha Noi','K11'),
('K1108','Nguyen Manh','Tam','2/27/1986','Nam','Kien Giang','K11'),
('K1109','Phan Thi Thanh','Tam','1/27/1986','Nu','Vinh Long','K11'),
('K1110','Le Hoai','Thuong','2/5/1986','Nu','Can Tho','K11'),
('K1111','Le Ha','Vinh','12/25/1986','Nam','Vinh Long','K11'),
('K1201','Nguyen Van','B','2/11/1986','Nam','TpHCM','K12'),
('K1202','Nguyen Thi Kim','Duyen','1/18/1986','Nu','TpHCM','K12'),
('K1203','Tran Thi Kim','Duyen','9/17/1986','Nu','TpHCM','K12'),
('K1204','Truong My','Hanh','5/19/1986','Nu','Dong Nai','K12'),
('K1205','Nguyen Thanh','Nam','4/17/1986','Nam','TpHCM','K12'),
('K1206','Nguyen Thi Truc','Thanh','3/4/1986','Nu','Kien Giang','K12'),
('K1207','Tran Thi Bich','Thuy','2/8/1986','Nu','Nghe An','K12'),
('K1208','Huynh Thi Kim','Trieu','4/8/1986','Nu','Tay Ninh','K12'),
('K1209','Pham Thanh','Trieu','2/23/1986','Nam','TpHCM','K12'),
('K1210','Ngo Thanh','Tuan','2/14/1986','Nam','TpHCM','K12'),
('K1211','Do Thi','Xuan','3/9/1986','Nu','Ha Noi','K12'),
('K1212','Le Thi Phi','Yen','3/12/1986','Nu','TpHCM','K12'),
('K1301','Nguyen Thi Kim','Cuc','6/9/1986','Nu','Kien Giang','K13'),
('K1302','Truong Thi My','Hien','3/18/1986','Nu','Nghe An','K13'),
('K1303','Le Duc','Hien','3/21/1986','Nam','Tay Ninh','K13'),
('K1304','Le Quang','Hien','4/18/1986','Nam','TpHCM','K13'),
('K1305','Le Thi','Huong','3/27/1986','Nu','TpHCM','K13'),
('K1306','Nguyen Thai','Huu','3/30/1986','Nam','Ha Noi','K13'),
('K1307','Tran Minh','Man','5/28/1986','Nam','TpHCM','K13'),
('K1308','Nguyen Hieu','Nghia','4/8/1986','Nam','Kien Giang','K13'),
('K1309','Nguyen Trung','Nghia','1/18/1987','Nam','Nghe An','K13'),
('K1310','Tran Thi Hong','Tham','4/22/1986','Nu','Tay Ninh','K13'),
('K1311','Tran Minh','Thuc','4/4/1986','Nam','TpHCM','K13'),
('K1312','Nguyen Thi Kim','Yen','9/7/1986','Nu','TpHCM','K13')

-- MONHOC
insert into MONHOC
(MAMH,TENMH,TCLT,TCTH,MAKHOA)
values
('THDC','Tin hoc dai cuong','4','1','KHMT'),
('CTRR','Cau truc roi rac','5','0','KHMT'),
('CSDL','Co so du lieu','3','1','HTTT'),
('CTDLGT','Cau truc du lieu va giai thuat','3','1','KHMT'),
('PTTKTT','Phan tich thiet ke thuat toan','3','0','KHMT'),
('DHMT','Do hoa may tinh','3','1','KHMT'),
('KTMT','Kien truc may tinh','3','0','KTMT'),
('TKCSDL','Thiet ke co so du lieu','3','1','HTTT'),
('PTTKHTTT','Phan tich thiet ke he thong thong tin','4','1','HTTT'),
('HDH','He dieu hanh','4','0','KTMT'),
('NMCNPM','Nhap mon cong nghe phan mem','3','0','CNPM'),
('LTCFW','Lap trinh C for win','3','1','CNPM'),
('LTHDT','Lap trinh huong doi tuong','3','1','CNPM')

-- GIANGDAY
insert into GIANGDAY
 values
('K11','THDC','GV07','1','2006','01/02/2006','05/12/2006'),
('K12','THDC','GV06','1','2006','01/02/2006','05/12/2006'),
('K13','THDC','GV15','1','2006','01/02/2006','05/12/2006'),
('K11','CTRR','GV02','1','2006','01/09/2006','05/17/2006'),
('K12','CTRR','GV02','1','2006','01/09/2006','05/17/2006'),
('K13','CTRR','GV08','1','2006','01/09/2006','05/17/2006'),
('K11','CSDL','GV05','2','2006','06/01/2006','07/15/2006'),
('K12','CSDL','GV09','2','2006','06/01/2006','07/15/2006'),
('K13','CTDLGT','GV15','2','2006','06/01/2006','07/15/2006'),
('K13','CSDL','GV05','3','2006','08/01/2006','12/15/2006'),
('K13','DHMT','GV07','3','2006','08/01/2006','12/15/2006'),
('K11','CTDLGT','GV15','3','2006','08/01/2006','12/15/2006'),
('K12','CTDLGT','GV15','3','2006','08/01/2006','12/15/2006'),
('K11','HDH','GV04','1','2007','01/02/2007','02/18/2007'),
('K12','HDH','GV04','1','2007','01/02/2007','03/20/2007'),
('K11','DHMT','GV07','1','2007','02/18/2007','03/20/2007')

-- DIEUKIEN
insert into DIEUKIEN
values
('CSDL','CTRR'),
('CSDL','CTDLGT'),
('CTDLGT','THDC'),
('PTTKTT','THDC'),
('PTTKTT','CTDLGT'),
('DHMT','THDC'),
('LTHDT','THDC'),
('PTTKHTTT','CSDL')

-- KETQUATHI
insert into KETQUATHI
values
('K1101','CSDL','1','07/20/2006','10','Dat'),
('K1101','CTDLGT','1','12/28/2006','9','Dat'),
('K1101','THDC','1','05/20/2006','9','Dat'),
('K1101','CTRR','1','05/13/2006','9.5','Dat'),
('K1102','CSDL','1','07/20/2006','4','Khong Dat'),
('K1102','CSDL','2','07/20/2006','4.25','Khong Dat'),
('K1102','CSDL','3','08/10/2006','4.5','Khong Dat'),
('K1102','CTDLGT','1','12/28/2006','4.5','Khong Dat'),
('K1102','CTDLGT','2','01/05/2007','4','Khong Dat'),
('K1102','CTDLGT','3','01/15/2007','6','Dat'),
('K1102','THDC','1','05/20/2006','5','Dat'),
('K1102','CTRR','1','05/13/2006','7','Dat'),
('K1103','CSDL','1','07/20/2006','3.5','Khong Dat'),
('K1103','CSDL','2','07/27/2006','8.25','Dat'),
('K1103','CTDLGT','1','12/28/2006','7','Dat'),
('K1103','THDC','1','05/20/2006','8','Dat'),
('K1103','CTRR','1','05/13/2006','6.5','Dat'),
('K1104','CSDL','1','07/20/2006','3.75','Khong Dat'),
('K1104','CTDLGT','1','12/28/2006','4','Khong Dat'),
('K1104','THDC','1','05/20/2006','4','Khong Dat'),
('K1104','CTRR','1','05/13/2006','4','Khong Dat'),
('K1104','CTRR','2','05/20/2006','3.5','Khong Dat'),
('K1104','CTRR','3','06/30/2006','4','Khong Dat'),
('K1201','CSDL','1','07/20/2006','6','Dat'),
('K1201','CTDLGT','1','12/28/2006','5','Dat'),
('K1201','THDC','1','05/20/2006','8.5','Dat'),
('K1201','CTRR','1','05/13/2006','9','Dat'),
('K1202','CSDL','1','07/20/2006','8','Dat'),
('K1202','CTDLGT','1','12/28/2006','4','Khong Dat'),
('K1202','CTDLGT','2','01/05/2007','5','Dat'),
('K1202','THDC','1','05/20/2006','4','Khong Dat'),
('K1202','THDC','2','05/27/2006','4','Khong Dat'),
('K1202','CTRR','1','05/13/2006','3','Khong Dat'),
('K1202','CTRR','2','05/20/2006','4','Khong Dat'),
('K1202','CTRR','3','06/30/2006','6.25','Dat'),
('K1203','CSDL','1','07/20/2006','9.25','Dat'),
('K1203','CTDLGT','1','12/28/2006','9.5','Dat'),
('K1203','THDC','1','05/20/2006','10','Dat'),
('K1203','CTRR','1','05/13/2006','10','Dat'),
('K1204','CSDL','1','07/20/2006','8.5','Dat'),
('K1204','CTDLGT','1','12/28/2006','6.75','Dat'),
('K1204','THDC','1','05/20/2006','4','Khong Dat'),
('K1204','CTRR','1','05/13/2006','6','Dat'),
('K1301','CSDL','1','12/20/2006','4.25','Khong Dat'),
('K1301','CTDLGT','1','07/25/2006','8','Dat'),
('K1301','THDC','1','05/20/2006','7.75','Dat'),
('K1301','CTRR','1','05/13/2006','8','Dat'),
('K1302','CSDL','1','12/20/2006','6.75','Dat'),
('K1302','CTDLGT','1','07/25/2006','5','Dat'),
('K1302','THDC','1','05/20/2006','8','Dat'),
('K1302','CTRR','1','05/13/2006','8.5','Dat'),
('K1303','CSDL','1','12/20/2006','4','Khong Dat'),
('K1303','CTDLGT','1','07/25/2006','4.5','Khong Dat'),
('K1303','CTDLGT','2','08/07/2006','4','Khong Dat'),
('K1303','CTDLGT','3','08/15/2006','4.25','Khong Dat'),
('K1303','THDC','1','05/20/2006','4.5','Khong Dat'),
('K1303','CTRR','1','05/13/2006','3.25','Khong Dat'),
('K1303','CTRR','2','05/20/2006','5','Dat'),
('K1304','CSDL','1','12/20/2006','7.75','Dat'),
('K1304','CTDLGT','1','07/25/2006','9.75','Dat'),
('K1304','THDC','1','05/20/2006','5.5','Dat'),
('K1304','CTRR','1','05/13/2006','5','Dat'),
('K1305','CSDL','1','12/20/2006','9.25','Dat'),
('K1305','CTDLGT','1','07/25/2006','10','Dat'),
('K1305','THDC','1','05/20/2006','8','Dat'),
('K1305','CTRR','1','05/13/2006','10','Dat')

-- CAU 11 Học viên ít nhất là 18 tuổi
ALTER TABLE HOCVIEN
ADD CONSTRAINT CHECK_TUOI CHECK (YEAR(NGSINH)  <=  (YEAR(GETDATE()) - 18))

-- CAU 12 Giảng dạy một môn học ngày bắt đầu (TUNGAY) phải nhỏ hơn ngày kết thúc 
-- (DENNGAY)
ALTER TABLE GIANGDAY
ADD CONSTRAINT CHECK_DENNGAY CHECK (TUNGAY < DENNGAY)

-- CAU 13 Giáo viên khi vào làm ít nhất là 22 tuổi
ALTER TABLE GIAOVIEN
ADD CONSTRAINT CHECK_TUOI_GIAOVIEN CHECK (YEAR(NGSINH)  <=  (YEAR(GETDATE()) - 22))

-- CAU 14 Tất cả các môn học đều có số tín chỉ lý thuyết và tín chỉ thực hành chênh lệch nhau không 
-- quá 3
ALTER TABLE MONHOC
DROP CONSTRAINT CHECK_TINCHI
ALTER TABLE MONHOC WITH NOCHECK -- Chỉ kiểm tra dữ liệu nhập sau này mà không cần thay đổi dữ liệu trước đó, vì môn học CTRR có tín chỉ là 5 - 0
ADD CONSTRAINT CHECK_TINCHI CHECK ((TCLT - TCTH) <= 3 AND (TCLT - TCTH) >= -3)

--------------------------------------------------------------------------------------------------------------------------------------
-- PHAN 2

-- CAU 1 Tăng hệ số lương thêm 0.2 cho những giáo viên là trưởng khoa.
UPDATE GIAOVIEN
SET HESO = HESO + 0.2
WHERE GIAOVIEN.MAGV IN (SELECT TRGKHOA FROM KHOA)

-- CAU 2 Cập nhật giá trị điểm trung bình tất cả các môn học (DIEMTB) của mỗi học viên (tất cả các 
-- môn học đều có hệ số 1 và nếu học viên thi một môn nhiều lần, chỉ lấy điểm của lần thi sau 
-- cùng).
UPDATE HOCVIEN
SET DIEMTB = B.DIEMTB FROM
	(SELECT MAHV, AVG(A.DIEM) AS DIEMTB
	FROM (SELECT S.MAHV, S.MAMH, KETQUATHI.DIEM
		FROM (SELECT MAHV, MAMH, MAX(LANTHI) AS "LANTHI" FROM KETQUATHI GROUP BY MAHV, MAMH) AS S 
		INNER JOIN KETQUATHI ON
		S.MAHV = KETQUATHI.MAHV AND S.MAMH = KETQUATHI.MAMH AND S.LANTHI = KETQUATHI.LANTHI) AS A
	GROUP BY A.MAHV) AS B
WHERE HOCVIEN.MAHV = B.MAHV

-- CAU 3 Cập nhật giá trị cho cột GHICHU là “Cam thi” đối với trường hợp: học viên có một môn bất 
-- kỳ thi lần thứ 3 dưới 5 điểm.
UPDATE HOCVIEN
SET GHICHU = 'Cam thi'
WHERE MAHV IN (
	SELECT DISTINCT MAHV FROM KETQUATHI
	WHERE LANTHI = 3 AND DIEM < 5)

-- CAU 4 Cập nhật giá trị cho cột XEPLOAI trong quan hệ HOCVIEN như sau:
-- Nếu DIEMTB >= 9 thì XEPLOAI =”XS”
-- Nếu 8 <= DIEMTB < 9 thì XEPLOAI = “G”
-- Nếu 6.5 <= DIEMTB < 8 thì XEPLOAI = “K”
-- Nếu 5 <= DIEMTB < 6.5 thì XEPLOAI = “TB”
-- Nếu DIEMTB < 5 thì XEPLOAI = ”Y”
UPDATE HOCVIEN
SET XEPLOAI = 'XS'
WHERE DIEMTB >= 9
UPDATE HOCVIEN
SET XEPLOAI = 'G'
WHERE DIEMTB >= 8 AND DIEMTB < 9
UPDATE HOCVIEN
SET XEPLOAI = 'K'
WHERE DIEMTB >= 6.5 AND DIEMTB < 8
UPDATE HOCVIEN
SET XEPLOAI = 'TB'
WHERE DIEMTB >= 5 AND DIEMTB < 6.5
UPDATE HOCVIEN
SET XEPLOAI = 'Y'
WHERE DIEMTB < 5

------------------------------------------------------------------------------------------------------------------------------------------------
-- PHAN 3

-- CAU 1 In ra danh sách (mã học viên, họ tên, ngày sinh, mã lớp) lớp trưởng của các lớp
SELECT MAHV, HO, TEN, NGSINH, HOCVIEN.MALOP
FROM HOCVIEN, LOP
WHERE HOCVIEN.MAHV = LOP.TRGLOP

-- CAU 2 In ra bảng điểm khi thi (mã học viên, họ tên , lần thi, điểm số) môn CTRR của lớp “K12”, 
-- sắp xếp theo tên, họ học viên
SELECT HOCVIEN.MAHV, HO, TEN, LANTHI, DIEM
FROM KETQUATHI, HOCVIEN
WHERE KETQUATHI.MAMH = 'CTRR' AND HOCVIEN.MALOP = 'K12' AND KETQUATHI.MAHV = HOCVIEN.MAHV
ORDER BY TEN ASC, HO ASC

-- CAU 3 In ra danh sách những học viên (mã học viên, họ tên) và những môn học mà học viên đó thi 
-- lần thứ nhất đã đạt
SELECT HOCVIEN.MAHV, HO, TEN, MAMH
FROM HOCVIEN, KETQUATHI
WHERE LANTHI = 1 AND KQUA = 'Dat' AND HOCVIEN.MAHV = KETQUATHI.MAHV

-- CAU 4 In ra danh sách học viên (mã học viên, họ tên) của lớp “K11” thi môn CTRR không đạt (ở 
-- lần thi 1)
SELECT HOCVIEN.MAHV, HO, TEN
FROM HOCVIEN, KETQUATHI
WHERE MALOP = 'K11' AND LANTHI = 1 AND KETQUATHI.MAMH = 'CTRR' AND KQUA = 'Khong Dat'

-- CAU 5 Danh sách học viên (mã học viên, họ tên) của lớp “K” thi môn CTRR không đạt (ở tất cả 
-- các lần thi)
-- Của lớp 'K'?
SELECT DISTINCT HOCVIEN.MAHV, HO, TEN
FROM HOCVIEN, KETQUATHI
WHERE HOCVIEN.MAHV IN
(
SELECT MAHV
FROM KETQUATHI
WHERE KQUA ='Khong Dat'
)
AND HOCVIEN.MAHV NOT IN
(
	SELECT MAHV
	FROM    KETQUATHI
	WHERE	KQUA = 'Dat'
	AND     MAMH = 'CTRR' 
	GROUP BY MAHV
)

-- CAU 6 Tìm tên những môn học mà giáo viên có tên “Tran Tam Thanh” dạy trong học kỳ 1 năm 
-- 2006.
SELECT TENMH
FROM MONHOC INNER JOIN (SELECT DISTINCT MAMH
						FROM (SELECT MAMH, MAGV FROM GIANGDAY WHERE HOCKY = 1 AND NAM = 2006) AS A INNER JOIN GIAOVIEN
						ON A.MAGV = GIAOVIEN.MAGV AND GIAOVIEN.HOTEN = 'Tran Tam Thanh') AS B
ON MONHOC.MAMH = B.MAMH

-- CAU 7 Tìm những môn học (mã môn học, tên môn học) mà giáo viên chủ nhiệm lớp “K11” dạy 
-- trong học kỳ 1 năm 2006.
SELECT MONHOC.MAMH, TENMH
FROM MONHOC INNER JOIN (SELECT DISTINCT MAMH
						FROM (SELECT MAMH, MAGV FROM GIANGDAY WHERE HOCKY = 1 AND NAM = 2006) AS A INNER JOIN
						(SELECT MAGVCN FROM LOP WHERE MALOP = 'K11') AS B
						ON A.MAGV = B.MAGVCN) AS C
ON MONHOC.MAMH = C.MAMH

-- CAU 8 Tìm họ tên lớp trưởng của các lớp mà giáo viên có tên “Nguyen To Lan” dạy môn “Co So 
-- Du Lieu”.
SELECT HO, TEN FROM HOCVIEN INNER JOIN 
	(SELECT TRGLOP FROM LOP INNER JOIN
		(SELECT MALOP FROM (SELECT MAGV FROM GIAOVIEN WHERE HOTEN = 'Nguyen To Lan') AS B INNER JOIN
				(SELECT MALOP, MAGV FROM (SELECT MAMH FROM MONHOC WHERE TENMH = 'Co so du lieu') AS A INNER JOIN GIANGDAY 
				ON A.MAMH = GIANGDAY.MAMH) AS C 
			ON B.MAGV = C.MAGV) AS C 
	ON LOP.MALOP = C.MALOP) AS D 
ON HOCVIEN.MAHV = D.TRGLOP

-- CAU 9 In ra danh sách những môn học (mã môn học, tên môn học) phải học liền trước môn “Co So 
-- Du Lieu”.
SELECT MAMH, TENMH FROM MONHOC INNER JOIN
	(SELECT MAMH_TRUOC FROM DIEUKIEN INNER JOIN
		(SELECT MAMH FROM MONHOC WHERE TENMH = 'Co so du lieu') AS A
	ON DIEUKIEN.MAMH = A.MAMH) AS B
ON MONHOC.MAMH = B.MAMH_TRUOC

-- CAU 10 Môn “Cau Truc Roi Rac” là môn bắt buộc phải học liền trước những môn học (mã môn học, 
-- tên môn học) nào.
SELECT MONHOC.MAMH, TENMH FROM MONHOC INNER JOIN
	(SELECT DIEUKIEN.MAMH FROM DIEUKIEN INNER JOIN
		(SELECT MAMH FROM MONHOC WHERE TENMH = 'Cau truc roi rac') AS A
	ON DIEUKIEN.MAMH_TRUOC = A.MAMH) AS B
ON MONHOC.MAMH = B.MAMH

-- CAU 11 Tìm họ tên giáo viên dạy môn CTRR cho cả hai lớp “K11” và “K12” trong cùng học kỳ 1 
-- năm 2006.
SELECT MAGV FROM GIANGDAY WHERE MAMH = 'CTRR' AND MALOP ='K11'
	AND MAGV IN (SELECT MAGV FROM GIANGDAY WHERE MAMH = 'CTRR' AND MALOP ='K12')

-- CAU 12 Tìm những học viên (mã học viên, họ tên) thi không đạt môn CSDL ở lần thi thứ 1 nhưng 
-- chưa thi lại môn này.
SELECT MAHV FROM KETQUATHI WHERE MAMH = 'CSDL' AND LANTHI = 1 AND KQUA = 'Khong Dat' 
	AND MAHV NOT IN (SELECT MAHV FROM KETQUATHI WHERE MAMH = 'CSDL' AND LANTHI = 2)

-- CAU 13 Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào.
SELECT MAGV, HOTEN FROM GIAOVIEN WHERE MAGV NOT IN (SELECT DISTINCT MAGV FROM GIANGDAY)

-- CAU 14 Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào 
-- thuộc khoa giáo viên đó phụ trách.
SELECT MAGV, HOTEN FROM GIAOVIEN WHERE MAGV NOT IN
	(SELECT DISTINCT MAGV FROM MONHOC INNER JOIN
		(SELECT GIAOVIEN.MAGV, MAMH, MAKHOA FROM GIAOVIEN INNER JOIN
			(SELECT DISTINCT MAGV, MAMH FROM GIANGDAY) AS A
		ON GIAOVIEN.MAGV = A.MAGV) AS B
	ON MONHOC.MAMH = B.MAMH AND MONHOC.MAKHOA = B.MAKHOA)

-- CAU 15 Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn “Khong dat”
-- hoặc thi lần thứ 2 môn CTRR được 5 điểm.
SELECT HO, TEN FROM HOCVIEN INNER JOIN
	(SELECT A.MAHV, MAMH, LANTHI, DIEM, KQUA FROM KETQUATHI INNER JOIN
		(SELECT MAHV FROM HOCVIEN WHERE MALOP = 'K11') AS A 
	ON KETQUATHI.MAHV = A.MAHV
	WHERE (LANTHI = 3 AND KQUA = 'Khong Dat')
		OR (MAMH = 'CTRR' AND LANTHI = 2 AND DIEM = 5)) AS B
ON HOCVIEN.MAHV = B.MAHV

-- CAU 16 Tìm họ tên giáo viên dạy môn CTRR cho ít nhất hai lớp trong cùng một học kỳ của một năm 
-- học.
SELECT HOTEN FROM GIAOVIEN INNER JOIN
	(SELECT MAGV, COUNT(MALOP) AS SOLOP, HOCKY, NAM FROM GIANGDAY
	GROUP BY MAGV, MAMH, HOCKY, NAM HAVING MAMH = 'CTRR') AS A
ON GIAOVIEN.MAGV = A.MAGV
WHERE SOLOP = 2

-- CAU 17 Danh sách học viên và điểm thi môn CSDL (chỉ lấy điểm của lần thi sau cùng).
SELECT A.MAHV, HO, TEN, DIEM FROM HOCVIEN INNER JOIN
	(SELECT MAHV, DIEM, MAX(LANTHI) AS LANTHI FROM KETQUATHI
	GROUP BY MAHV, MAMH, DIEM HAVING MAMH = 'CSDL') AS A
ON HOCVIEN.MAHV = A.MAHV

-- CAU 18 Danh sách học viên và điểm thi môn “Co So Du Lieu” (chỉ lấy điểm cao nhất của các lần 
-- thi).
SELECT A.MAHV, HO, TEN, DIEM FROM HOCVIEN INNER JOIN
	(SELECT MAHV, DIEM, MAX(LANTHI) AS LANTHI FROM KETQUATHI
	GROUP BY MAHV, MAMH, DIEM HAVING MAMH IN (SELECT MAMH FROM MONHOC WHERE TENMH = 'Co So Du Lieu')) AS A
ON HOCVIEN.MAHV = A.MAHV