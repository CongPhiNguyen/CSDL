--select * from LOP
--select * from HOCVIEN
--update LOP
--set TRGLOP='K1108' where MALOP='K11'
--Câu 9: Lớp trưởng của một lớp phải là học viên của lớp đó
use QLGV
go 
create trigger trigg_LOPTRUONG on LOP
for insert, update
as 
begin
	declare @TRGLOP char(5), @MALOP char(3)
	select @TRGLOP=TRGLOP, @MALOP=MALOP  from inserted 
	if(NOT EXISTS (select * from HOCVIEN where MAHV=@TRGLOP and MALOP=@MALOP))
	begin
		print N'LỖI: LỚP TRƯỞNG PHẢI LÀ THÀNH VIÊN CỦA LỚP ĐÓ'
		rollback transaction
	end
end		

create trigger trigg_CHUYENLOP on HOCVIEN
for update, delete
as
begin
	declare @MAHV char(5), @MALOP char(3)
	select @MAHV=MAHV, @MALOP=MALOP from deleted 
	if(@MAHV in (select TRGLOP from LOP where MALOP=@MALOP))
	begin
		print N'LỖI: TRƯỚC KHI CHUYỂN LỚP TRƯỞNG ĐI PHẢI THAY ĐỔI LỚP TRƯỞNG'
		rollback transaction
	end
end

select * from LOP
-- Testcase dùng để test
update LOP set TRGLOP='K1205' where MALOP='K11'
--update LOP set TRGLOP='K1108' where MALOP='K11'
update HOCVIEN set MALOP='K12' where MAHV='K1108'
--10. Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”.
go 
create trigger trigg_KHOA_checktruongkhoa on KHOA
for update, insert
as
begin
	declare @MaKhoa varchar(4), @MaTrgKhoa_Khoa varchar(4), @dem int

	select @MaKhoa=MAKHOA, @MaTrgKhoa_Khoa=TRGKHOA from inserted

	select * from GIAOVIEN

	select @dem = count(*)
	from GIAOVIEN
	where @MaKhoa=MAKHOA and @MaTrgKhoa_Khoa=MAGV and HOCVI in ('TS','PTS')

	if(@dem=0)
	begin
		print 'LOI CMNR'
		rollback transaction
	end
	else 
	begin
		print 'OKKKK'
	end
end

--Check lỗi

select * from KHOA
select * from GIAOVIEN order by MAKHOA
update KHOA
set TRGKHOA='GV12' where MAKHOA='CNPM'

---CURSOR----

--15. Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này.


--16. Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn.
--17. Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó.
--18. Trong quan hệ DIEUKIEN giá trị của thuộc tính MAMH và MAMH_TRUOC trong cùng một bộ không được giống nhau (“A”,”A”) và cũng 
--không tồn tại hai bộ (“A”,”B”) và (“B”,”A”).
--19. Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau.
--20. Học viên chỉ được thi lại (lần thi >1) khi điểm của lần thi trước đó dưới 5.
--21. Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học).
--22. Học viên chỉ được thi những môn mà lớp của học viên đó đã học xong.
--23. Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học (sau 
--khi học xong những môn học phải học trước mới được học những môn liền sau).
--24. Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách.