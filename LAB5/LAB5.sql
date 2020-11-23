----TRIGGER----
--QLBH
--11. Ngày mua hàng (NGHD) của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó đăng ký thành viên (NGDK).
create trigger trigg_insert_hoadon on HOADON
for insert
as
begin
	--Lấy cái hóa đưn đc thêm vào
	declare @NgayHD smalldatetime, @MaKH char(4), @NgayDK smalldatetime
	select @NgayHD=NGHD, @MaKH=MAKH
	from inserted
	--Lấy thằng trong bảng khách hàng tương ứng
	select @NgayDK = NGDK
	from KHACHHANG
	where MAKH = @MaKH
	--So sánh 
	if(@NgayHD < @NgayDK)
		begin
			print 'LOI : NGAY HOA DON KHONG HOP LE!'
			rollback transaction
		end
	else
		begin
			print 'OKKKK'
		end
end

--select * from HOADON
--select * from KHACHHANG
--select * from NHANVIEN
-- 1 bộ sai để test nè:
set dateformat DMY
insert into HOADON
	(SOHD, NGHD, MAKH, MANV, TRIGIA)
values
	(1977,'1/1/1997','KH01','NV01',1000000)
delete from HOADON 
where SOHD=1977

-----Có thể làm thêm 2 trigger nữa insert update có thể để chung nhưng phải cùng bảng



--12. Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm.
go
create trigger trigg_insert_hoadon_checkNHANVIEN on HOADON
for insert
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
		print 'LOI ROI'
		rollback transaction
	end
	else
	begin
		print 'OK'
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
create trigger trigg_insert_hoadon_checkSOHD on HOADON
for insert
as
begin
	declare @soHD int, @dem int
	
	select @soHD = SOHD
	from inserted

	select @dem= count(*)
	from CTHD
	where @soHD=SOHD

	if(@dem<1)
	begin
		print 'LOI ROI'
		rollback transaction
	end
	else
	begin
		print 'OK'
	end
end
select * from CTHD
-- Testcase lỗi
insert into HOADON
	(SOHD)
values
	(99999)

delete from HOADON
where SOHD=99999


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
select * from HOADON
select * from SANPHAM
insert into CTHD
	(SOHD, MASP, SL)
values
	(1001,'ST10',2)

--15. Doanh số của một khách hàng là tổng trị giá các hóa đơn mà khách hàng thành viên đó đã mua.


go
create trigger trigg_insert_doanhso on KHACHHANG
for insert, update
as
begin
	declare @tongtrigia money,
	set @tongtrigia=0

	select from inserted

	declare cur_hoadon
	for
		set 
	open cur_hoadon

	fetch next from cur_hoadon
	into 

	while(@@FETCH_STATUS = 0)
	begin
		set @tongtrigia = @tongtrigia + 
		fetch next from cur_hoadon
		into 

	end

	close cur_hoadon
	deallocate cur_hoadon
	update 
end

