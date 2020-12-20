----CÂU 1:------------------------------------------------------------------------------------------------------


use QLBH
----TRIGGER----
--QLBH
--11. Ngày mua hàng (NGHD) của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó đăng ký thành viên (NGDK).
create trigger trigg_insert_hoadon on HOADON
for insert, update
as
begin
	--Lấy cái hóa đưn đc thêm vào
	declare @NgayHD smalldatetime, @MaKH char(4), @NgayDK smalldatetime
	select @NgayHD=NGHD, @MaKH=MAKH
	from inserted
	--Lấy trong bảng khách hàng tương ứng
	select @NgayDK = NGDK
	from KHACHHANG
	where MAKH = @MaKH
	--So sánh 
	if(@NgayHD < @NgayDK)
		begin
			print N'LỖI : NGÀY HÓA ĐƠN KHÔNG HỢP LỆ!'
			rollback transaction
		end
end

--select * from HOADON
--select * from KHACHHANG
--select * from NHANVIEN
-- Test case dùng để test:
set dateformat DMY
insert into HOADON
	(SOHD, NGHD, MAKH, MANV, TRIGIA)
values
	(1977,'1/1/1900','KH01','NV01',1000000)
delete from HOADON 
where SOHD=1977

-----Có thể làm thêm 2 trigger nữa insert update có thể để chung nhưng phải cùng bảng



--12. Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm.
go
create trigger trigg_insert_hoadon_checkNHANVIEN on HOADON
for insert, update
as
begin
	declare @NgayHD smalldatetime, @MaNV char(4), @NgayVL smalldatetime
	
	select @NgayHD = NGHD, @MaNV=MANV
	from inserted

	select @NgayVL = NGVL
	from NHANVIEN
	where @MaNV=MANV

	if(@NgayHD<@NgayVL)
	begin
		print N'LỖI: NGÀY BÁN HÀNG PHẢI LỚN HƠN HOẶC BẰNG NGÀY VÀO LÀM'
		rollback transaction
	end
end

select * from HOADON
insert into HOADON
	(SOHD,MANV,NGHD)
values
	(2001,'NV01','1/1/1999')
delete from HOADON
where SOHD=2001

--13. Mỗi một hóa đơn phải có ít nhất một chi tiết hóa đơn.

go 
create trigger trigg_checkSOHD on CTHD
for update, delete
as
begin
	declare @SOHD int, @demCTHD int, @demSOHD int
	select @SOHD=SOHD from deleted
	select @demCTHD=count(*) from CTHD where @SOHD=SOHD
	select @demSOHD=count(*) from HOADON where @SOHD=SOHD
	if(@demCTHD<1 and @demSOHD>0)
	begin
		print N'LỖI: MỖI HÓA ĐƠN PHẢI CÓ ÍT NHẤT 1 CHI TIẾT HÓA ĐƠN'
		rollback transaction
	end
end

select * from CTHD
select * from SANPHAM
select * from HOADON
-- Testcase dùng để test
insert into HOADON
	(SOHD)
values
	(9999)
insert into CTHD
	(SOHD,MASP)
values (9999,'BB01')


delete from HOADON
where SOHD=9999
delete from CTHD
where SOHD=9999
update CTHD
set SOHD=1111 where SOHD=9999

-- Thếm 1 sô trigger nữa

---------------CURSOR

--14. Trị giá của một hóa đơn là tổng thành tiền (số lượng*đơn giá) của các chi tiết thuộc hóa đơn đó.
go
create trigger trigg_insert on CTHD
for insert, update
as
begin
	declare @SoHD int, @MaSP char(4), @SoLuong int, @TriGia money

	select @SoHD=SOHD, @MaSP=MASP, @SoLuong=SL
	from inserted

	set @TriGia=@SoLuong * (select GIA from SANPHAM where MASP=@MaSP)--set = 0 ở đây cũng đc

	declare cur_cthd cursor
	for
		select MASP, SL from CTHD where SOHD=@SoHD
	open cur_cthd
	fetch next from cur_cthd
	into @MaSP, @SoLuong
	set @TriGia=0
	while(@@FETCH_STATUS = 0)
	begin
		set @TriGia=@TriGia + @soLuong * (select GIA from SANPHAM where MASP=@MaSP)
		fetch next from cur_cthd
		into @MaSP, @SoLuong
	end

	close cur_cthd
	deallocate cur_cthd
	update HOADON set TRIGIA=@TriGia where SOHD=@SoHD
end

go
create trigger trigg_delete_CTHD on CTHD
for delete
as
begin
	declare @SoHD int, @MaSP char(4), @SoLuong int, @TriGia money
	select @SoHD=SOHD, @MaSP=MASP, @SoLuong=SL
	from deleted
	declare cur_cthd cursor
	for
		select MASP, SL from CTHD where SOHD=@SoHD
	open cur_cthd
	fetch next from cur_cthd
	into @MaSP, @SoLuong
	set @TriGia=0
	while(@@FETCH_STATUS = 0)
	begin
		set @TriGia=@TriGia + @soLuong * (select GIA from SANPHAM where MASP=@MaSP)
		fetch next from cur_cthd
		into @MaSP, @SoLuong
	end
	close cur_cthd
	deallocate cur_cthd
	update HOADON set TRIGIA=@TriGia where SOHD=@SoHD
end

--Testcase dùng để test
select * from HOADON
select * from SANPHAM
insert into CTHD
	(SOHD, MASP, SL)
values
	(1001,'ST10',3)

update CTHD set SL=5 where SOHD=1001 and MASP='ST10'
delete from CTHD where SOHD=1001 and MASP='ST10'

--15. Doanh số của một khách hàng là tổng trị giá các hóa đơn mà khách hàng thành viên đó đã mua.


go
create trigger trigg_insert_doanhso on HOADON
for insert, update
as
begin
-- Khai báo các biến (phải có @)
	declare @tongdoanhso money, @TRIGIA money, @MAKH char(4)
	set @tongdoanhso=0

--Lấy các giá trị từ bảng inserted
	select @TRIGIA=TRIGIA, @MAKH=MAKH from inserted

	declare cur_hoadon cursor
	for
		select TRIGIA from HOADON where MAKH=@MAKH
	open cur_hoadon

	fetch next from cur_hoadon
	into @TRIGIA
-- Vòng lặp để cộng tất cả các trị giá hóa đơn của 1 người 
	while(@@FETCH_STATUS = 0)
	begin
		set @tongdoanhso = @tongdoanhso + @TRIGIA
		fetch next from cur_hoadon
		into @TRIGIA
	end
-- Xóa con trỏ
	close cur_hoadon
	deallocate cur_hoadon
	update KHACHHANG set DOANHSO=@tongdoanhso where MAKH=@MAKH
end

go
create trigger trigg_delete_doanhso on HOADON
for delete
as
begin
-- Khai báo các biến (phải có @)
	declare @tongdoanhso money, @TRIGIA money, @MAKH char(4)
	set @tongdoanhso=0

--Lấy các giá trị từ bảng inserted
	select @TRIGIA=TRIGIA, @MAKH=MAKH from deleted

	declare cur_hoadon cursor
	for
		select TRIGIA from HOADON where MAKH=@MAKH
	open cur_hoadon

	fetch next from cur_hoadon
	into @TRIGIA
-- Vòng lặp để cộng tất cả các trị giá hóa đơn của 1 người 
	while(@@FETCH_STATUS = 0)
	begin
		set @tongdoanhso = @tongdoanhso + @TRIGIA
		fetch next from cur_hoadon
		into @TRIGIA
	end
-- Xóa con trỏ
	close cur_hoadon
	deallocate cur_hoadon
	update KHACHHANG set DOANHSO=@tongdoanhso where MAKH=@MAKH
end

-- Testcase dùng để test
select * from KHACHHANG
select * from HOADON
select * from SANPHAM

insert into CTHD
	(SOHD, MASP, SL)
values
	(1001,'ST10',100)

update CTHD set SL=5 where SOHD=1001 and MASP='ST10'
delete from CTHD where SOHD=1001 and MASP='ST10'

set dateformat DMY
insert into HOADON (SOHD,NGHD,MAKH,MANV,TRIGIA) 
values (1001,'23/7/2006','KH01','NV01','530000')

delete HOADON where SOHD=1001

--CÂU 2:------------------------------------------------------------------------------------------


select * from LOP
-- Testcase dùng để test
update LOP set TRGLOP='K1205' where MALOP='K11'
update LOP set TRGLOP='K1108' where MALOP='K11'



--10. Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”.
--15. Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này.
--16. Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn.
--17. Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó.
--18. Trong quan hệ DIEUKIEN giá trị của thuộc tính MAMH và MAMH_TRUOC trong cùng
--một bộ không được giống nhau (“A”,”A”) và cũng không tồn tại hai bộ (“A”,”B”) và (“B”,”A”).
--19. Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau.
--20. Học viên chỉ được thi lại (lần thi >1) khi điểm của lần thi trước đó dưới 5.
--21. Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học).
--22. Học viên chỉ được thi những môn mà lớp của học viên đó đã học xong.
--23. Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học (sau
--khi học xong những môn học phải học trước mới được học những môn liền sau).
--24. Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách

