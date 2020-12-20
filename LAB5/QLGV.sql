
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
		print N'LỖI: Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”.'
		rollback transaction
	end
end

---CURSOR----

--15. Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này.

create trigger trigg_THISAUKHIHOCXONG on KETQUATHI
for insert, update
as 
begin
	declare @NGTHI smalldatetime, @MAMH varchar(10), @MAHV char(5)
	select @NGTHI=NGTHI, @MAMH =MAMH, @MAHV=MAHV from inserted
	if(@NGTHI is not null 
		and exists (select * from GIANGDAY where MAMH=@MAMH 
					and MALOP in (select MALOP from HOCVIEN where MAHV=@MAHV)
					and @NGTHI < DENNGAY))
		begin
			print N'LỖI: Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này'
			rollback transaction	
		end 
end
--16. Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn.
create trigger trigg_GIOIHANMON on GIANGDAY
for insert, update
as
begin
	if exists (select * from inserted I group by I.HOCKY,I.MALOP,I.NAM having count(*) > 3)
	begin
		print N'LỖI:  Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn'
		rollback transaction	
	end 
end
--17. Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó.
create trigger trigg_SOHOCSINH on HOCVIEN
for insert, update
as
begin
	declare @MALOP char(3), @MAHV char(5), @SISO int
	select @MALOP=MALOP from inserted
	declare cur_HOCVIEN cursor
	for select MAHV from HOCVIEN where MALOP=@MALOP 
	open cur_HOCVIEN
	fetch next from cur_HOCVIEN into @MAHV
	set @SISO=0
	while(@@FETCH_STATUS = 0)
	begin
		set @SISO = @SISO + 1
		fetch next from cur_HOCVIEN into @MAHV
	end
	close cur_HOCVIEN
	deallocate cur_HOCVIEN
	update LOP set SISO = @SISO where MALOP=@MALOP 
end
drop trigger trigg_SOHOCSINH_XOA
create trigger trigg_SOHOCSINH_XOA on HOCVIEN
for delete
as
begin
	declare @MALOP char(3), @MAHV char(5), @SISO int
	select @MALOP=MALOP from deleted
	declare cur_HOCVIEN cursor
	for select MAHV from HOCVIEN where MALOP=@MALOP 
	open cur_HOCVIEN
	fetch next from cur_HOCVIEN into @MAHV
	set @SISO=0
	while(@@FETCH_STATUS = 0)
	begin
		set @SISO = @SISO + 1
		fetch next from cur_HOCVIEN into @MAHV
	end
	close cur_HOCVIEN
	deallocate cur_HOCVIEN
	update LOP set SISO = @SISO where MALOP=@MALOP 
end
--18. Trong quan hệ DIEUKIEN giá trị của thuộc tính MAMH và MAMH_TRUOC trong cùng một bộ không được giống nhau (“A”,”A”) và cũng 
--không tồn tại hai bộ (“A”,”B”) và (“B”,”A”).
drop trigger trigg_KHONGTRUNG
create trigger trigg_KHONGTRUNG on DIEUKIEN
for insert, update
as
begin
	if exists (select * from INSERTED I, INSERTED I2 where (I.MAMH=I.MAMH_TRUOC))
	begin
		print N'LỖI:  Môn học trước đã trùng với môn học sau'
		rollback transaction	
	end
	if exists (select * from INSERTED I join DIEUKIEN I2 on (I.MAMH=I2.MAMH_TRUOC and I.MAMH_TRUOC=I2.MAMH))
	begin
		print N'LỖI: Môn học trước và môn học sau đã được insert ngược lại '
		rollback transaction	
	end
end
--19. Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau.
create trigger trigg_TINHLUONG on GIAOVIEN
for insert, update
as
begin
	if exists (select * from GIAOVIEN g join INSERTED I on (g.HOCHAM = I.HOCHAM and g.HESO=I.HESO 
															and g.HOCVI=I.HOCVI and g.MUCLUONG<>I.HESO ))
	begin
		print N'LỖI:  Các giáo viên có cùng học vị, học hàm, hệ số lương có mức lương không bằng nhau'
		rollback transaction	
	end
end
--20. Học viên chỉ được thi lại (lần thi > 1) khi điểm của lần thi trước đó dưới 5.
create trigger trigg_DIEUKIENTHILAI on kETQUATHI
for insert, update
as 
begin
	declare @LANTHI tinyint
	select @LANTHI=LANTHI from inserted
	if @LANTHI > 1 and exists(select * from KETQUATHI k join inserted I on (k.MAMH=I.MAMH and k.MAHV=I.MAHV 
				and k.LANTHI=@LANTHI - 1) where k.DIEM >= 5)
	begin
		print N'LỖI: Học viên chỉ được thi lại (lần thi > 1) khi điểm của lần thi trước đó dưới 5'
		rollback transaction	
	end
end	  
--21. Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học).
create trigger trigg_DIEUKIENNGAYTHI on kETQUATHI
for insert, update
as 
begin
	declare @LANTHI tinyint
	select @LANTHI=LANTHI from inserted
	if @LANTHI > 1 and exists(select * from KETQUATHI k join inserted I on (k.MAMH=I.MAMH and k.MAHV=I.MAHV 
				and k.LANTHI=@LANTHI - 1) where k.NGTHI >= I.NGTHI)
	begin
		print N'LỖI: Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học)'
		rollback transaction	
	end
end	
--22. Học viên chỉ được thi những môn mà lớp của học viên đó đã học xong.
create trigger trigg_THISAUKHIHOCXONG2 on KETQUATHI
for insert, update
as 
begin
	declare @NGTHI smalldatetime, @MAMH varchar(10), @MAHV char(5)
	select @NGTHI=NGTHI, @MAMH =MAMH, @MAHV=MAHV from inserted
	if(@NGTHI is not null 
		and exists (select * from GIANGDAY where MAMH=@MAMH 
					and MALOP in (select MALOP from HOCVIEN where MAHV=@MAHV)
					and @NGTHI < DENNGAY))
		begin
			print N'LỖI: Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này'
			rollback transaction	
		end 
end
--23. Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học (sau 
--khi học xong những môn học phải học trước mới được học những môn liền sau).

--24. Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách.