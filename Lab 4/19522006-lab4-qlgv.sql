use QLGV
--Câu 19: Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất.

select 
	MAKHOA,
	TENKHOA
from KHOA
where NGTLAP in (select top 1
					NGTLAP
				from KHOA
				order by NGTLAP )

-- Câu 20: Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”
select
	count(MAGV) as SOGIAOVIEN
from GIAOVIEN
where HOCHAM='GS' or HOCHAM='PGS' 

--Câu 21: Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi khoa
select
	cackhoa.MAKHOA,  coalesce(SLCN,0) as SLCN, coalesce(SLKS,0) as SLKS, coalesce(SLThS,0) as SLThS, coalesce(SLTS,0) as SLTS, coalesce(SLPTS,0) as SLPTS
from
(select MAKHOA from KHOA) cackhoa full join
(select coalesce(count(MAGV),0) as SLCN, MAKHOA from GIAOVIEN where HOCVI='CN' group by MAKHOA) demcn on(cackhoa.MAKHOA=demcn.MAKHOA) full join 
(select coalesce(count(MAGV),0) as SLKS, MAKHOA from GIAOVIEN where HOCVI='KS' group by MAKHOA) demks on (cackhoa.MAKHOA=demks.MAKHOA) full join
(select coalesce(count(MAGV),0) as SLThS, MAKHOA from GIAOVIEN where HOCVI='ThS' group by MAKHOA) demThs on (demThs.MAKHOA=cackhoa.MAKHOA) full join
(select coalesce(count(MAGV),0) as SLTS, MAKHOA from GIAOVIEN where HOCVI='TS' group by MAKHOA) demTs on (demTs.MAKHOA=cackhoa.MAKHOA) full join
(select coalesce(count(MAGV),0) as SLPTS, MAKHOA from GIAOVIEN where HOCVI='PTS' group by MAKHOA) dempts on(dempts.MAKHOA=cackhoa.MAKHOA)
order by cackhoa.MAKHOA

--Câu 22:  Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt)

--Câu 23. Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp, đồng thời dạy cho lớp đó ít nhất một môn học.
select giaovien.MAGV,giaovien.HOTEN
from GIAOVIEN giaovien join
(
	select distinct
		giangday.MAGV
	from
		GIANGDAY giangday join
		LOP lop on(giangday.MAGV=lop.MAGVCN and giangday.MALOP=lop.MALOP) 
) tramagiaovien on tramagiaovien.MAGV=giaovien.MAGV


--Câu 24. Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất.
select
	hocvien.HO +' '+ hocvien.TEN as HOTEN_LOPTRUONG 
from 
	HOCVIEN hocvien join
	(select	MALOP, TRGLOP from LOP where SISO in (select top 1 SISO from LOP order by SISO desc)) loptruong on loptruong.TRGLOP=hocvien.MAHV


--Câu 26. Tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất.
select MAHV, HO + ' ' + TEN as HOTEN
from HOCVIEN
where MAHV in 
(
	select MAHV from (select count(DIEM) as DEM_9_10,MAHV from KETQUATHI where DIEM>=9 group by MAHV) bang_9_10
	where bang_9_10.DEM_9_10 in (select top 1 count(DIEM) as DEM_9_10 from KETQUATHI where DIEM>=9 group by MAHV order by count(DIEM) desc)
)

--Câu 27. Trong từng lớp, tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất.
select 
	thongke.MALOP, HOTEN, SODIEM_9_10 
from
(	
	select hv.MAHV, HO + ' ' + TEN as HOTEN, DEM_9_10, lop.MALOP
	from HOCVIEN hv join
	(
		select MAHV, DEM_9_10 from (select count(DIEM) as DEM_9_10,MAHV from KETQUATHI where DIEM>=9 group by MAHV) bang_9_10
	) bangtra on hv.MAHV=bangtra.MAHV join
	LOP lop on LOP.MALOP=hv.MALOP
) thongke join
(
	select lop.MALOP, MAX(DEM_9_10) as SODIEM_9_10
	from LOP lop join
	HOCVIEN hv on(hv.MALOP=lop.MALOP) join
	(select count(DIEM) as DEM_9_10,MAHV from KETQUATHI where DIEM>=9 group by MAHV) bang_9_10 on hv.MAHV=bang_9_10.MAHV
	group by lop.MALOP
) ketquathongke on (thongke.MALOP=ketquathongke.MALOP and thongke.DEM_9_10=ketquathongke.SODIEM_9_10)

--Câu 28. Trong từng học kỳ của từng năm, mỗi giáo viên phân công dạy bao nhiêu môn học, bao nhiêu lớp.
select 
	gv.MAGV,
	gv.HOTEN,
	coalesce(Thongkelop.NAM,0) as NAMHOC,
	coalesce(Thongkelop.HOCKY,0) as HOCKY, 
	coalesce(DEM_SO_MON,0) as SO_MON, 
	coalesce(DEM_SO_LOP_KHAC_NHAU,0) as SO_LOP
from 
	GIAOVIEN gv full join
	(
		select MAGV,NAM,HOCKY,count(MAMH) as DEM_SO_MON
		from GIANGDAY 
		group by MAGV,NAM,HOCKY 
	) as Thongkemon on(gv.MAGV=Thongkemon.MAGV) full join
	(
		select
			MAGV, NAM, HOCKY, count(distinct MALOP) as DEM_SO_LOP_KHAC_NHAU
		from 
			GIANGDAY
		group by MAGV, NAM, HOCKY
	) as Thongkelop on (Thongkelop.MAGV=Thongkemon.MAGV and Thongkelop.NAM=Thongkemon.NAM and Thongkemon.HOCKY=Thongkelop.HOCKY)
order by gv.MAGV

--Câu 29. Trong từng học kỳ của từng năm, tìm giáo viên (mã giáo viên, họ tên) giảng dạy nhiều nhất.
select 
	gv.MAGV,gv.HOTEN ,bang_nhieu_mon_nhat_theo_nam.NAM,bang_nhieu_mon_nhat_theo_nam.HOCKY, DEM_SO_MON
from 
	(
		select MAGV,NAM,HOCKY,count(MAMH) as DEM_SO_MON
		from GIANGDAY 
		group by MAGV,NAM,HOCKY 
	) as Thong_ke_nam_hoc_theo_hoc_ky join
	(
		select	
			NAM,HOCKY,MAX(DEM_SO_MON) as MAXSOMON
		from
			(select MAGV,NAM,HOCKY,count(MAMH) as DEM_SO_MON
			from GIANGDAY 
			group by MAGV,NAM,HOCKY  
			) as Thong_ke_nam_hoc_theo_hoc_ky1
		group by NAM,HOCKY
	) as bang_nhieu_mon_nhat_theo_nam on(Thong_ke_nam_hoc_theo_hoc_ky.NAM=bang_nhieu_mon_nhat_theo_nam.NAM
										and Thong_ke_nam_hoc_theo_hoc_ky.HOCKY=bang_nhieu_mon_nhat_theo_nam.HOCKY
										and Thong_ke_nam_hoc_theo_hoc_ky.DEM_SO_MON=bang_nhieu_mon_nhat_theo_nam.MAXSOMON) join
		GIAOVIEN gv on Thong_ke_nam_hoc_theo_hoc_ky.MAGV=gv.MAGV
order by bang_nhieu_mon_nhat_theo_nam.NAM, bang_nhieu_mon_nhat_theo_nam.HOCKY

--Câu 30. Tìm môn học (mã môn học, tên môn học) có nhiều học viên thi không đạt (ở lần thi thứ 1) nhất.
select 
	mh.MAMH,mh.TENMH
from
(
	select MAMH, count(MAHV) as DEM_ROT
	from
	(select * from KETQUATHI
	where LANTHI=1 and KQUA='Khong Dat') as bangsonguoithirot
	group by MAMH
) as so_nguoi_rot_theo_mon join MONHOC mh on(so_nguoi_rot_theo_mon.MAMH=mh.MAMH)
where so_nguoi_rot_theo_mon.DEM_ROT in(
										select top 1 count(MAHV) as DEM_ROT
										from
										(select * from KETQUATHI
										where LANTHI=1 and KQUA='Khong Dat') as bangsonguoithirot
										group by MAMH
										)
select * from KETQUATHI
--Câu 31. Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi thứ 1).
select distinct
	kqt.MAHV , hv.HO +' '+ hv.TEN as HOTEN
from 
	KETQUATHI kqt join HOCVIEN hv on kqt.MAHV=hv.MAHV
where
	LANTHI=1 and kqt.KQUA='Dat' and kqt.MAHV not in (select distinct MAHV from KETQUATHI where LANTHI=1 and KQUA='Khong Dat')

--Câu 32. * Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng).
select distinct
	kqt.MAHV , hv.HO +' '+ hv.TEN as HOTEN
from 
	KETQUATHI kqt join HOCVIEN hv on kqt.MAHV=hv.MAHV
where LANTHI=1 and kqt.KQUA='Dat' and kqt.MAHV not in(select distinct MAHV from KETQUATHI where LANTHI=1 and KQUA='Khong Dat')
	or (LANTHI=2 and kqt.KQUA='Dat' and kqt.MAHV not in (select distinct MAHV from KETQUATHI where LANTHI=2 and KQUA='Khong Dat'))
	or (LANTHI=3 and kqt.KQUA='Dat' and kqt.MAHV not in (select distinct MAHV from KETQUATHI where LANTHI=3 and KQUA='Khong Dat'))

--Câu 33. * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn đều đạt (chỉ xét lần thi thứ 1).
select	
	hv.MAHV, hv.HO+' '+hv.TEN as HOTEN
from HOCVIEN hv 
where not exists
	(
		select * from (select MAMH from MONHOC) as bangtra
		where not exists 
		(
			select * from KETQUATHI kqt where hv.MAHV=kqt.MAHV and bangtra.MAMH=kqt.MAMH and kqt.LANTHI=1 and kqt.KQUA='Dat'
		)
	)

--Câu 34. * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn đều đạt (chỉ xét lần thi sau cùng).
select	
	hv.MAHV, hv.HO+' '+hv.TEN as HOTEN
from HOCVIEN hv 
where not exists
	(
		select * from (select MAMH from MONHOC) as bangtra
		where not exists 
		(
			select * from KETQUATHI kqt where hv.MAHV=kqt.MAHV and bangtra.MAMH=kqt.MAMH and kqt.KQUA='Dat'
		)
	)

--Câu 35. ** Tìm học viên (mã học viên, họ tên) có điểm thi cao nhất trong từng môn (lấy điểm ở lần thi sau cùng).



