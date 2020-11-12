--ĐÂY LÀ DATA CỦA CSDL
----1 
insert	into NHACC
	(MACC,TENCC,DIACHICC)
values
	('CC01','Shoppe','Lâm Đồng, Việt Nam'),
	('CC02','Vinamilk','Đà Nẵng, Việt Nam')

insert into DONDH
	(MADH,NGAYDH,MACC,TONGTRIGIA,SOMH)
values
	('DH01','1/1/2020','CC01','1999999',10),
	('DH02','2/1/2020','CC02','11000000',1),
	('DH03','2/1/2020','CC02','1000',8)

----2
insert into MATHANG
	(MAMH, TENMH, DVT, NUOCSX)
values
	('MH001','Mì gói','gói','Trung Quốc'),
	('MH002','Sữa đậu nành','bị','Hàn Quốc')

insert into DONDH
	(MADH,NGAYDH,MACC,TONGTRIGIA,SOMH)
values 
	('DH04','1/1/2018','CC02',1000000,7),
	('DH05','1/8/2020','CC02',1000000,7),
	('DH06','1/9/2018','CC01',10000,6)


insert into CHITIET
	(MADH,MAMH,SOLUONG,DONGIA,TRIGIA)
values
	('DH04','MH001',5,10000,50000),
	('DH05','MH001',10, 100, 1000),
	('DH06','MH002',100,100, 100000),
	('DH06','MH001',100,111, 11100)

----3
insert into MATHANG
	(MAMH, TENMH, DVT, NUOCSX)
values
	('MH003','Siêu nhân điện quang','đĩa','Việt Nam')

insert into CUNGCAP
	(MACC,MAMH,TUNGAY)
values
	('CC01','MH003','1/1/2020'),
	('CC01','MH002','1/1/2020'),
	('CC02','MH001','1/1/1999')

delete from CUNGCAP where MACC='CC01' and MAMH='MH001'

----5
insert	into NHACC
	(MACC,TENCC,DIACHICC)
values
	('CC03','Vissan','Korea')

insert into CUNGCAP
	(MACC,MAMH,TUNGAY)
values
	('CC03','MH001','1/1/2020'),
	('CC03','MH002','1/1/2020'),
	('CC03','MH003','1/1/1999')

----9 
insert into NHACC
		(MACC,TENCC,DIACHICC)
values 
	('CC04','Super Captain','Mỹ')


insert into MATHANG
	(MAMH, TENMH, DVT, NUOCSX)
values
	('MH004','Mì trẻ em','gói','Mỹ')

insert into CUNGCAP
	(MACC,MAMH,TUNGAY)
values
	('CC04','MH002','1/1/2020'),
	('CC04','MH004','1/1/2020')



----8. 

insert into MATHANG
	(MAMH, TENMH, DVT, NUOCSX)
values
	('MH014','Bài yugioh', 'bộ', 'Nhật Bản')

insert into NHACC
	(MACC,TENCC,DIACHICC)
values
	('NCC007','Konami','Tokyo, Japan')

insert into CUNGCAP
	(MACC,MAMH,TUNGAY)
values
	('NCC007','MH014','1/1/2017'),
	('CC01','MH014','1/4/2020')

insert into DONDH
	(MADH,NGAYDH,MACC,TONGTRIGIA,SOMH)
values 
	('DH010','1/1/2019', 'NCC007',1000,10),
	('DH011','1/1/2019', 'NCC007',10000,10)

insert into CHITIET
	(MADH,MAMH,SOLUONG,DONGIA,TRIGIA)
values 
	('DH010','MH014',10,100,1000),
	('DH011', 'MH014',100,100,10000)

