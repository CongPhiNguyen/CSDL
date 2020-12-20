create database QLNX
go
use QLNX
create table NHACUNGCAP
(
	MANCC char(5) not null,
	TENNCC varchar(50),
	QUOCGIA varchar(20),
	LOAINCC varchar(20)
)
create table DUOCPHAM
(
	MADP char(4) not null,
	TENDP varchar(50),
	LOAIDP varchar(20),
	GIA money
)
set dateformat DMY
create table PHIEUNHAP
(
	SOPN int not null, 
	NGNHAP smalldatetime,
	MANCC char(5) not null,
	LOAINHAP varchar(20)
)
create table CTPN
(
	SOPN int not null, 
	MADP char(4) not null,
	SOLUONG int
)
--Tạo khóa chính
alter table NHACUNGCAP add constraint PK_MANCC primary key (MANCC)
alter table DUOCPHAM add constraint PK_MADP primary key (MADP)
alter table PHIEUNHAP add constraint PK_SOPN primary key(SOPN)
alter table CTPN add constraint PK_SOPN_MADP primary key(SOPN,MADP)
-- Tạo khóa ngoại 
alter table PHIEUNHAP 
add constraint FK_MANCC foreign key(MANCC) references NHACUNGCAP(MANCC)
alter table CTPN
add constraint FK_SOPN foreign key(SOPN) references PHIEUNHAP(SOPN)
alter table CTPN
add constraint FK_MADP foreign key(MADP) references DUOCPHAM(MADP)

-- Câu 2: Nhập dữ liệu cho 4 table như đề bài (1đ).
insert into  NHACUNGCAP
	(MANCC, TENNCC, QUOCGIA, LOAINCC)
values
('NCC01', 'Phuc Hung' ,'Viet Nam', 'Thuong xuyen'),
('NCC02', 'J. B. Pharmaceuticals' ,'India' ,'Vang lai'),
('NCC03' ,'Sapharco', 'Singapore', 'Vang lai')

insert into DUOCPHAM 
	(MADP, TENDP, LOAIDP ,GIA)
values
('DP01' , 'Thuoc ho PH' ,'Siro', '120000'),
('DP02' ,'Zecuf Herbal CouchRemedy' ,'Vien nen' ,'200000'),
('DP03' ,'Cotrim', 'Vien sui', '80000')


insert into PHIEUNHAP
(SOPN, NGNHAP, MANCC, LOAINHAP)
values
('00001' ,'22/11/2017' ,'NCC01', 'Noi dia'),
('00002' ,'04/12/2017' ,'NCC03' ,'Nhap khau'),
('00003' ,'10/12/2017', 'NCC02' ,'Nhap khau')
insert into CTPN
(SOPN, MADP, SOLUONG)
values
('00001', 'DP01', 100),
('00001', 'DP02', 200),
('00003', 'DP03' ,543)

--Câu 3: Hiện thực ràng buộc toàn vẹn sau: Tất cả các dược phẩm có loại là Siro đều có giá lớn hơn 100000đ (1đ).create trigger trigg_LOAISIRO on DUOCPHAMfor insert, updateasbegin	if exists (select * from inserted I where I.LOAIDP='Siro' and I.GIA <= 100000)	begin		print N'LỖI: Tất cả các dược phẩm có loại là Siro đều có giá lớn hơn 100000đ'		rollback transaction	endendinsert into DUOCPHAM values ('DP04' , 'Mr ' ,'Siro', '12000')--4. Hiện thực ràng buộc toàn vẹn sau: Phiếu nhập của những nhà cung cấp ở những quốc gia khác Việt Nam đều có loại nhập là Nhập khẩu. (2đ).
create trigger trigg_LOAINHAP on PHIEUNHAP
for insert, update
as
begin
	if exists (select * from inserted I join NHACUNGCAP ncc on I.MANCC=ncc.MANCC where QUOCGIA <> 'Viet Nam' and I.LOAINHAP<>'Nhap khau')
	begin		print N'LỖI: Phiếu nhập của những nhà cung cấp ở những quốc gia khác Việt Nam đều có loại nhập là Nhập khẩu'		rollback transaction	end
end
insert into PHIEUNHAP
(SOPN, NGNHAP, MANCC, LOAINHAP)
values
('00099' ,'22/11/2017' ,'NCC02', 'Noi dia')
--5. Tìm tất cả các phiếu nhập có ngày nhập trong tháng 12 năm 2017, sắp xếp kết quả tăng dần theo ngày nhập (1đ).
select * from PHIEUNHAP p where year(p.NGNHAP)=2017 and month(p.NGNHAP)=12 order by p.NGNHAP asc

--6. Tìm dược phẩm được nhập số lượng nhiều nhất trong năm 2017 (1đ).
select * from DUOCPHAM where MADP in
(select dp.MADP
from DUOCPHAM dp join CTPN ctpn on dp.MADP=ctpn.MADP join 
PHIEUNHAP pn on ctpn.SOPN=pn.SOPN group by dp.MADP having sum(SOLUONG) >=
				(select top 1 sum(SOLUONG) 
				from DUOCPHAM dp join CTPN ctpn on dp.MADP=ctpn.MADP join 
				PHIEUNHAP pn on ctpn.SOPN=pn.SOPN group by dp.MADP order by sum(SOLUONG) desc))
  
--7. Tìm dược phẩm chỉ có nhà cung cấp thường xuyên (LOAINCC là Thuong xuyen) cung cấp, nhà cung cấp vãng lai (LOAINCC là Vang lai) không cung cấp. (1đ).
select dp.MADP, dp.LOAIDP, dp.TENDP, dp.GIA from DUOCPHAM dp 
join CTPN ctpn on dp.MADP = ctpn.MADP 
join PHIEUNHAP pn on pn.SOPN=ctpn.SOPN
join NHACUNGCAP ncc on pn.MANCC=ncc.MANCC where LOAINCC='Thuong Xuyen'  
and dp.MADP not in
		(select dp.MADP from DUOCPHAM dp 
		join CTPN ctpn on dp.MADP = ctpn.MADP 
		join PHIEUNHAP pn on pn.SOPN=ctpn.SOPN
		join NHACUNGCAP ncc on pn.MANCC=ncc.MANCC where LOAINCC='Vang Lai')

--8. Tìm nhà cung cấp đã từng cung cấp tất cả những dược phẩm có giá trên 100000đ trong năm 2017 (1đ).select MANCC from PHIEUNHAP pn where year(pn.NGNHAP)=2017 and not exists	(select * from DUOCPHAM dp where GIA > 100000 and not exists	(select * from CTPN ctpn where pn.SOPN=ctpn.SOPN and dp.MADP=ctpn.MADP))