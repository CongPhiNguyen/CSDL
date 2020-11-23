--9. Lớp trưởng của một lớp phải là học viên của lớp đó.
drop trigger trigg_checkLopTruong
go
create trigger trigg_checkLopTruong on LOP
for insert, update
as
begin
	declare @maloptruong_LOP char(5), @dem int , @malop_LOP char(3)
	
	select @maloptruong_LOP=TRGLOP, @malop_LOP=MALOP from inserted

	select @dem = count(*)
	from HOCVIEN
	where @malop_LOP=MALOP and @maloptruong_LOP=MAHV

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

--select * from LOPc
--select * from HOCVIEN
--update LOP
--set TRGLOP='K1108' where MALOP='K11'



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