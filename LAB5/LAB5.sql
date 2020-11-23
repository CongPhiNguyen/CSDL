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



--15. Doanh số của một khách hàng là tổng trị giá các hóa đơn mà khách hàng thành viên đó đã mua.