create database QLVH
use QLVH
set dateformat DMY
-----QUOCGIA(MAQG,TENQG,CHAULUC,DIENTICH)
create table QUOCGIA
(
	MAQG varchar(10) not null,
	TENQG varchar(50),
	CHAULUC varchar(50),
	DIENTICH int
)
alter table QUOCGIA
add constraint PK_QUOCGIA primary key(MAQG)

create table THEVANHOI
(
	MATVH varchar(10) not null,
	TENTVH varchar(50),
	MAQG varchar(10),
	NAM int
)
alter table THEVANHOI
add constraint PK_THEVANHOI primary key(MATVH)

create table VANDONGVIEN
(
	MAVDV varchar(10) not null,
	HOTEN varchar(50),
	NGSINH datetime,
	GIOITINH varchar(50),
	QUOCTICH varchar(10)
)
alter table VANDONGVIEN
add constraint PK_VANDONGVIEN primary key(MAVDV)

create table NOIDUNGTHI
(
	MANDT varchar(10) not null,
	TENNDT varchar(50),
	GHICHU varchar(50)
)
alter table NOIDUNGTHI
add constraint PK_NOIDUNGTHI primary key(MANDT)

create table THAMGIA
(
	MAVDV varchar(10) not null,
	MANDT varchar(10) not null,
	MATVH varchar(10) not null,
	HUYCHUONG varchar(50)
)
alter table THAMGIA
add constraint PK_THAMGIA primary key(MAVDV,MANDT,MATVH)

--Nhập dữ liệu
insert into QUOCGIA
	(MAQG, TENQG, CHAULUC, DIENTICH)
values
	('DE', 'Đức', 'Châu Âu',NULL),
	('UK', 'Anh', 'Châu Âu',NULL),
	('JA', 'Nhật Bản', 'Châu Á',NULL),
	('BR', 'Brazil', 'Châu Mĩ',NULL),
	('CH', 'Trung Quốc', 'Châu Á',NULL)

insert into THEVANHOI
	(MATVH, TENTVH, MAQG, NAM)
values
	('TVH01', 'Olympic Bejing 2008', 'CH', '2008'),
	('TVH02', 'Olympic London 2012', 'UK', '2012'),
	('TVH03', 'Olympic Rio 2016', 'BR', '2016'),
	('TVH04', 'Olympic Tokyo 2020', 'JA', '2020')

insert into VANDONGVIEN
	(MAVDV,HOTEN, NGSINH, GIOITINH, QUOCTICH)
values
	('VDV001', 'John', '10/1/1988', 'Nam', 'UK'),
	('VDV002', 'Helen', '20/4/1989', 'Nu', 'UK'),
	('VDV003', 'Osaka', '17/3/1990', 'Nu', 'JA'),
	('VDV004', 'Ronaldo', '1/3/1990', 'Nam', 'BR')

insert into NOIDUNGTHI
	(MANDT, TENNDT,GHICHU)
values
	(1, 'Điền kinh',NULL),
	(2, 'Bắn súng',NULL),
	(3, 'Nhảy cầu',NULL)

----1. Tìm danh sách vận động viên(họ tên, ngày sinh, giới tính) có quốc tịch UK và săp xếp theo họ tên tăng dần
select HOTEN, NGSINH, GIOITINH
from VANDONGVIEN 
where QUOCTICH='UK' 
order by HOTEN
----2. In ra danh dách VDV tham gia nội dung thi bắn cung ở TVH Olympic Tokyo 2020
select MAVDV, HOTEN
from VANDONGVIEN where MAVDV in (select MAVDV from THAMGIA where MATVH in (select MATVH from THEVANHOI where TENTVH='Olympic Tokyo 2020')
									and MANDT in(select MANDT from NOIDUNGTHI where TENNDT='Bắn cung')
								)

----3. Cho biết số lượng HCV mà VDV Nhật bản đạt được ở TVH diễn ra vào năm 2020
select
	count(tg.HUYCHUONG) as TONG_HUY_CHUONG
from
	THAMGIA tg join VANDONGVIEN vdv on(tg.MAVDV=vdv.MAVDV) 
where 
	MATVH in (select MATVH from THEVANHOI where NAM=2020) and QUOCTICH in (select MAQG from QUOCGIA where TENQG='Nhật bản')

----4. Liệt kê họ tên, quốc tịch VDV tham gia cả 2 nội dung thi 100m bơi ngửa và 200m bơi tự do
select HOTEN, QUOCTICH
from VANDONGVIEN
where MAVDV in(select 
					MAVDV
				from THAMGIA
				where MANDT in(select MANDT from NOIDUNGTHI where TENNDT='100m bơi ngửa')
					and MAVDV in (select MAVDV from THAMGIA where MANDT in (select MANDT from NOIDUNGTHI where TENNDT='200m bơi tự do')))

----5. In ra MAVDV , họ tên của VDV nữ người anh tham gia tất cả kỳ TVH từ 2008 đến nay
select vdv.MAVDV,VDV.HOTEN 
from VANDONGVIEN vdv
where vdv.GIOITINH='Nu' and VDV.QUOCTICH in (select MAQG from QUOCGIA where TENQG='Anh') 
		and not exists (select * from (select MATVH from THEVANHOI where NAM>=2008) as bangtra
				where not exists
					(
						select * from THAMGIA tg where vdv.MAVDV=tg.MAVDV and bangtra.MATVH=tg.MATVH
					)
				)
----6. Tìm VDV (Mã VDV, Họ tên) đã đạt từ 2 HCV trở lên ở Olympic Rio 2016
select 
	MAVDV, HOTEN
from
	VANDONGVIEN
where 
	MAVDV in(
		select 
			MAVDV
		from 
			THAMGIA
		where 
			MATVH in (select MATVH from THEVANHOI where TENTVH='Olympic Rio 2016') and HUYCHUONG='HCV'
		group by MAVDV
		having count(HUYCHUONG)>2
		)
----7. In ra VDV tham gia điền kinh Olympic Rio 2016
select 
	MAVDV, HOTEN
from
	VANDONGVIEN
where 
	MAVDV in (select MAVDV from THAMGIA where MATVH in (select MATVH from THEVANHOI where TENTVH='Olympic Rio 2016'))
----8. Cho biết số huy chương bạc mà VDV Trung Quốc đạt đc ở TVH diễn ra vào 2012
select
	count(HUYCHUONG) as DEM_HUY_CHUONG_BAC
from 
	THAMGIA tg join THEVANHOI tvh on(tg.MATVH=tvh.MATVH)
	join VANDONGVIEN vdv on tg.MAVDV=vdv.MAVDV
where 
	vdv.QUOCTICH in (select MAQG from QUOCGIA where TENQG='Trung Quốc')
	and tg.HUYCHUONG='HCB'
----9. Liệt kê họ tên, quốc tịch của những vận động viên tham gia 100 m bơi ngửa nhưng không tham gia 200m bơi tự do
select HOTEN, QUOCTICH
from VANDONGVIEN
where MAVDV in(select 
					MAVDV
				from THAMGIA
				where MANDT in(select MANDT from NOIDUNGTHI where TENNDT='100m bơi ngửa')
					and MAVDV not in (select MAVDV from THAMGIA where MANDT in (select MANDT from NOIDUNGTHI where TENNDT='200m bơi tự do')))
---10. In ra thông tin MAVDV, Ho Ten của VDV nam người đức tham gia full thế vận hội từ năm 2012 đến nay
select vdv.MAVDV,VDV.HOTEN 
from VANDONGVIEN vdv
where vdv.GIOITINH='Nam' and VDV.QUOCTICH in (select MAQG from QUOCGIA where TENQG='Đức') 
		and not exists (select * from (select MATVH from THEVANHOI where NAM>=2012) as bangtra
				where not exists
					(
						select * from THAMGIA tg where vdv.MAVDV=tg.MAVDV and bangtra.MATVH=tg.MATVH
					)
				)
---11. Tim VDV(MaVDV, Họ tên) đã đạt từ 2 HCV trở lên ở nội dung thi bắn cung
select 
	MAVDV, HOTEN
from
	VANDONGVIEN
where 
	MAVDV in(
		select 
			MAVDV
		from 
			THAMGIA
		where 
			MANDT in(select MANDT from NOIDUNGTHI where TENNDT='Bắn cung') and HUYCHUONG='HCV'
		group by MAVDV
		having count(HUYCHUONG)>2
		)

















