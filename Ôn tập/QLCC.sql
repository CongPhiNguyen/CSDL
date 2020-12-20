create database QLCC
go
use QLCC
create table KHACHHANG
(
	MAKH char(4) not null,
	TENKH varchar(255),
	DIACHI varchar(20),
	LOAIKH varchar(20)
)
create table LOAICAY
(
	MALC char(4) not null,
	TENLC varchar(50),
	XUATXU varchar(20),
	GIA money
)
set dateformat DMY
create table HOADON
(
	SOHD int not null,
	NGHD smalldatetime,
	MAKH char(4) not null,
	KHUYENMAI int
)
create table CTHD 
(
	SOHD int not null,
	MALC char(4) not null,
	SOLUONG int
)
-- Chèn khóa chính
alter table KHACHHANG add constraint PK_MAKH primary key (MAKH)
alter table LOAICAY add constraint PK_MALC primary key (MALC)
alter table HOADON add constraint PK_SOHD primary key (SOHD)
alter table CTHD add constraint PK_SOHD_MALC primary key (SOHD,MALC)
--Chèn khóa ngoại
alter table HOADON
add constraint FK_MAKH foreign key(MAKH) references KHACHHANG(MAKH)
alter table CTHD
add constraint FK_SOHD foreign key(SOHD) references HOADON(SOHD)
alter table CTHD
add constraint FK_MALC foreign key(MALC) references LOAICAY(MALC)

--use master drop database QLCC

-- Câu 2: Nhập dữ liêu:
insert into KHACHHANG
(MAKH, TENKH, DIACHI, LOAIKH)
values
('KH01','Liz Kim Cuong', 'Ha Noi','Vang lai'),
('KH02','Ivone Dieu Linh', 'Da Nang','Thuong Xuyen'),
('KH03','Liz Kim Cuong', 'TP.HCM','Vang lai')

insert into LOAICAY
(MALC, TENLC, XUATXU, GIA)
values
('LC01', 'Xuong rong tai tho', 'Mexico', 180000),
('LC02', 'Sen thach ngoc ','Anh', 300000),
('LC03' ,'Ba mau rau' ,'Nam Phi', 270000)
set dateformat DMY
insert into HOADON
	(SOHD,NGHD,MAKH,KHUYENMAI)
values
('00001','22/11/2017', 'KH01', 5),
('00002', '04/12/2017', 'KH03', 5),
('00003', '10/12/2017', 'KH02', 10)
alter table CTHD
nocheck constraint FK_SOHD
insert into CTHD
	(SOHD, MALC, SOLUONG)
values
('00001', 'LC01', 1),
('00001', 'LC02', 2),
('00003', 'LC03', 5)

-- Câu 3: Hiện thực ràng buộc toàn vẹn sau: Tất cả các mặt hàng xuất xứ từ nước Anh đều có giá lớn hơn 250.000đ (1đ).
create trigger trigg_HANG_TU_ANH on LOAICAY
for insert, update
as
begin
	if exists (select * from inserted I where XUATXU='Anh' and GIA <= 250000)
	begin
		print N'LỖI: Tất cả các mặt hàng xuất xứ từ nước Anh đều có giá lớn hơn 250.000đ'
		rollback transaction
	end
end
insert into LOAICAY values ('LC04', 'Cây kem', 'Anh', 1000)
-- Câu 4: Hiện thực ràng buộc toàn vẹn sau: Hóa đơn mua với số lượng tổng cộng lớn hơn hoặc bằng 5 đều được giảm giá 10 phần trăm(1đ)
create trigger trigg_GIAMGIATONGSOLUON on CTHD
for insert, update
as
begin
	declare @SOHD int, @SOLUONG int, @tongsoluong int
	set @tongsoluong=0
	select @SOHD=SOHD from inserted
	declare cur_CTHD cursor
	for
		select SOLUONG from CTHD where SOHD=@SOHD 
	open cur_CTHD

	fetch next from cur_CTHD into @SOLUONG
	while(@@FETCH_STATUS =0)
	begin
		set @tongsoluong=@tongsoluong+@SOLUONG
		fetch next from cur_CTHD into @SOLUONG
	end
	close cur_CTHD
	deallocate cur_CTHD
	if(@tongsoluong>5)
	update HOADON set KHUYENMAI=10  where SOHD=@SOHD
end

select * from HOADON 
insert into CTHD 
values('0001','LC03',100)
delete from CTHD where SOHD='0001' and MALC='LC03'

-- Câu 5: Tìm tất cả các hóa đơn có ngày lập hóa đơn trong quý 4 năm 2017, sắp xếp kết quả tăng dần theo phần trăm giảm giá (1đ)

select * from HOADON
where MONTH(NGHD)>10 and YEAR(NGHD)=2017 order by KHUYENMAI 

-- Câu 6. Tìm loại cây có số lượng mua ít nhất trong tháng 12 (1đ).
select MALC, TENLC
from LOAICAY where MALC in
(select MALC from CTHD cthd join HOADON hd on (cthd.SOHD=hd.SOHD) group by MALC having sum(SOLUONG) <=
(select top 1 sum(SOLUONG) from CTHD cthd join HOADON hd on (cthd.SOHD=hd.SOHD) group by MALC order by sum(SOLUONG) asc))

-- Câu 7. Tìm loại cây mà cả khách thường xuyên (LOAIKH là ‘Thuong xuyen’) và khách vãng lai (LOAIKH là ‘Vang lai’) đều mua. (1đ)
select cthd.MALC from 
CTHD cthd join HOADON hd on cthd.SOHD=hd.SOHD 
join KHACHHANG kh on hd.MAKH=kh.MAKH 
where LOAIKH='Vang Lai' and cthd.MALC in(select cthd.MALC from 
											CTHD cthd join HOADON hd on cthd.SOHD=hd.SOHD 
											join KHACHHANG kh on hd.MAKH=kh.MAKH 
											where LOAIKH='Thuong Xuyen')

-- Câu 8. Tìm khách hàng đã từng mua tất cả các loại cây (1đ).
select kh.MAKH, kh.TENKH from KHACHHANG kh join HOADON hd on kh.MAKH=hd.MAKH
where not exists 
(select * from LOAICAY lc where not exists (
	select * from CTHD cthd where cthd.MALC= lc.MALC and hd.SOHD=cthd.SOHD))

