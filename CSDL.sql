create database QLDH
go 
use QLDH
set dateformat DMY
create table MATHANG
(
	MAMH varchar(10) not null,
	TENMH varchar(40),
	DVT varchar(40),
	NUOCSX varchar(10),
	constraint PK_MATHANG primary key (MAMH)
)
create table NHACC
(
	MACC varchar(10) not null,
	TENCC varchar(40),
	DIACHICC varchar(40)
)
--Tao khoa chinh
alter table NHACC
	add constraint PK_NHACC primary key (MACC)

create table CUNGCAP
(
	MACC varchar(10) not null,
	MAMH varchar(40) not null,
	TUNGAY smalldatetime,
	constraint FK_MACC foreign key(MACC) references NHACC(MACC),
	constraint PK_CUNGCAP primary key(MACC,MAMH)
)
create table DONDH
(
	MADH varchar(10) not null,
	NGAYDH smalldatetime,
	MACC varchar(10),
	TONGTRIGIA money,
	SOMH int,
	constraint PK_DONDH primary key(MADH)
)
create table CHITIET
(
	MADH varchar(10) not null,
	MAMH varchar(10) not null,
	SOLUONG int,
	DONGIA money,
	TRIGIA money,
	constraint FK_MADH foreign key(MADH) references DONDH(MADH),
	constraint FK_MAMH foreign key(MAMH) references MATHANG(MAMH),
	constraint PK_CHITIET primary key(MADH,MAMH)
)

--Các câu lệnh

-----1. Liệt kê danh sách các đơn hàng gồm mã đơn hàng, ngày đơn hàng, tổng trị giá của nhà cung cấp 'Vinamilk' với tổng trị giá lớn hơn 1 triệu
select 
	donhang.MADH, donhang.NGAYDH, donhang.TONGTRIGIA
from 
	DONDH donhang join
	NHACC ncc on donhang.MACC=ncc.MACC
where
	(donhang.TONGTRIGIA>1000000) and TENCC='Vinamilk'

-----2. Liệt kê tổng số lượng sản phẩm có mã mặt hàng là MH001 đã đặt trong năm 2018
select 
	sum(SOLUONG) as SOLUONG_MH001
from 
	CHITIET ct join DONDH dh on ct.MADH=dh.MADH
where
	year(dh.NGAYDH)=2018 and MAMH='MH001'

-----3.Liệt kê những nhà cung cấp bai gồm mã và tên có thể cung cấp những mặt hàng do Việt Nam sản xuất và không cung cấp mặt hàng do Trung Quốc sản xuất
select distinct
	cc.MACC, ncc.TENCC
from 
	CUNGCAP cc join
	MATHANG mh on (cc.MAMH=mh.MAMH) join
	NHACC ncc on(cc.MACC=ncc.MACC)
where
	mh.NUOCSX='Việt Nam' and cc.MACC not in (select cc1.MACC from CUNGCAP cc1 join MATHANG mh1 on cc1.MAMH=mh1.MAMH where mh1.NUOCSX='Trung Quốc')

-----4.Tính tổng số mặt hàng của tất cả các đơn đặt hàng theo từng năm, thông tin hiển thị là năm đặt hàng và tổng số lượng
select
	year(ddh.NGAYDH) as NAM,
	sum(ct.SOLUONG) as TONG_THE0_NAM
from 
	DONDH ddh join
	CHITIET ct on(ddh.MADH=ct.MADH)
group by  year(ddh.NGAYDH)

-----5.Tìm mã đặt hàng đã đặt tất cả mặt hàng do nhà cung cấp Vissan cung cấp

select ddh.MADH 
from DONDH ddh
where not exists (select * from (select MAMH from CUNGCAP where MACC in (select MACC from NHACC where TENCC='Vissan')) as bangtra
				where not exists
				(
					select * from CHITIET ct where ddh.MADH=ct.MADH and 
					ct.MAMH=bangtra.MAMH
				)  
			)

-----6.Tìm những mặt hàng (tên và mã) có số lượng đặt hàng nhiều nhất trong năm 2018
select thongke.MAMH, mh.TENMH
from
(select 
	MAMH, sum(SOLUONG) as SOLUONGNAM
from CHITIET ct1 join DONDH ddh1 on (ct1.MADH=ddh1.MADH) where year(ddh1.NGAYDH)=2018
group by MAMH) as thongke join MATHANG mh on thongke.MAMH=mh.MAMH
where SOLUONGNAM in (select top 1
						sum(SOLUONG) as SOLUONG 
						from 
						CHITIET ct join DONDH ddh on(ct.MADH=ddh.MADH)
						where 
						year(ddh.NGAYDH)=2018 
						group by MAMH 
						order by SOLUONG desc)

-----7.Liệt kê danh sách nhà cung cấp (mã, tên, ngày bắt đầu cung cấp) có thể cung cấp mặt hàng MH001 từ ngày 1/1/2018 
select distinct
	ncc.MACC, ncc.TENCC, cc.TUNGAY 
from
	NHACC ncc join CUNGCAP cc on(ncc.MACC=cc.MACC)
where 
	cc.MAMH='MH001' and cc.TUNGAY >='1/1/2018' 

-----8.Tính tổng trị giá đơn hàng  có mã mặt hàng là MH014 từ nhà  cung cấp NCC007
select 
	SUM(ddh.TONGTRIGIA) as TONG
from 
	DONDH ddh join CHITIET ct on ddh.MADH=ct.MADH
where ddh.MACC='NCC007' and ct.MAMH='MH014' 

-----9.Liệt kê những nhà cung cấp (mã, tên) có thể cung cấp hàng do Mỹ và Hàn Quốc sản xuất
select distinct
	cc.MACC, ncc.TENCC
from 
	CUNGCAP cc join
	MATHANG mh on (cc.MAMH=mh.MAMH) join
	NHACC ncc on(cc.MACC=ncc.MACC)
where
	mh.NUOCSX='Mỹ' and cc.MACC in (select cc1.MACC from CUNGCAP cc1 join MATHANG mh1 on cc1.MAMH=mh1.MAMH where mh1.NUOCSX='Hàn Quốc')

-----10.Tổng trị giá của các đơn hàng theo từng năm thông tin gồm năm và tổng trị giá
select
	year(ddh.NGAYDH) as NAM,
	sum(ct.SOLUONG) as TONG_THE0_NAM
from 
	DONDH ddh join
	CHITIET ct on(ddh.MADH=ct.MADH)
group by  year(ddh.NGAYDH)

-----11.Tìm mặt hàng(mã,tên) có SL đặt ít nhất năm 2020
select thongke.MAMH, mh.TENMH
from
(select 
	MAMH, sum(SOLUONG) as SOLUONGNAM
from CHITIET ct1 join DONDH ddh1 on (ct1.MADH=ddh1.MADH) where year(ddh1.NGAYDH)=2020
group by MAMH) as thongke join MATHANG mh on thongke.MAMH=mh.MAMH
where SOLUONGNAM in (select top 1
						sum(SOLUONG) as SOLUONG 
						from 
						CHITIET ct join DONDH ddh on(ct.MADH=ddh.MADH)
						where 
						year(ddh.NGAYDH)=2020
						group by MAMH 
						order by SOLUONG)