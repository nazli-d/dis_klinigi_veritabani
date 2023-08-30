
SELECT *FROM doktor
SELECT *FROM teknisyen
SELECT *FROM hasta
SELECT *FROM randevu
SELECT *FROM muayene
SELECT *FROM ilac
SELECT *FROM recete
SELECT *FROM fatura
SELECT *FROM odeme
SELECT *FROM teşhis


--ADI A HARFİ İLE BAŞLAYAN HASTALARA BAKAN DOKTORLARIN MAAŞLARININ ORTALAMASINI GETİRİR
SELECT AVG(doktor_maas) AS ortalama
FROM doktor
WHERE doktor_id IN (
					SELECT doktor_id
					FROM muayene
					WHERE hasta_id IN (
										SELECT hasta_id
										FROM hasta
										WHERE ad LIKE 'A%' ));

--'2023-01-01' AND '2023-12-31' ARASINDA İMPLANT TEDAVİSİ OLAN HASTALARIN BİLGİLERİNİ GÖSTERİR
SELECT hasta.hasta_id, hasta.ad, hasta.soyad
FROM hasta 
JOIN muayene ON hasta.hasta_id = muayene.hasta_id
JOIN teşhis  ON muayene.teşhis_id = teşhis.teşhis_id
WHERE teşhis.tedavi = 'implant' AND muayene.muayene_tarihi BETWEEN '2023-01-01' AND '2023-12-31';

-- HANGİ İLAÇ EN ÇOK REÇETELENDİRİLMİŞTİR?
SELECT ilac.ilac_id, COUNT(recete_id) AS recete_sayisi
FROM recete
JOIN ilac ON ilac.ilac_id = recete.ilac_id       
GROUP BY ilac.ilac_id
ORDER BY recete_sayisi DESC;

--HANGİ DOKTORUN VERDİĞİ REÇETELERİN ORTALAMA FİYATI EN YÜKSEKTİR? 
SELECT doktor_id, AVG(ilac.fiyat) AS ortalama_fiyat
FROM recete
JOIN ilac ON ilac.ilac_id = recete.ilac_id
GROUP BY doktor_id
ORDER BY ortalama_fiyat DESC;

--EN YAŞLI HASTANIN ÖDEME BİLGİSİNİ GÖSTERİR
SELECT odeme_durumu
FROM odeme 
JOIN hasta ON odeme.hasta_id = hasta.hasta_id
WHERE hasta.dogum_tarihi = (SELECT MIN(dogum_tarihi) FROM hasta);

--ADI 'BERFU OLAN HASTANIN NUMARASI ,TC KİMLİK BİLGİSİ VE NE TEDAVİSİ OLACAĞINI GÖSTEREN SORGU
SELECT hasta.hasta_id, hasta.tc_kimlik, teşhis.tedavi
FROM hasta INNER JOIN teşhis ON hasta.hasta_id = teşhis.hasta_id
WHERE hasta.ad = 'Berfu';

--EN YAŞLI OLAN HASTA VE ÖDEME DURUMUNU YAZDIRAN SORGU   
SELECT odeme_durumu,hasta.ad,hasta.soyad
FROM odeme 
JOIN hasta ON odeme.hasta_id = hasta.hasta_id
WHERE  hasta.dogum_tarihi = (SELECT MIN(dogum_tarihi) FROM hasta);

--ADI NAZLI OLAN DOKTORUN MUAYENE ETTİĞİ HASTALARIN ORTALAMA YAŞINI HESAPLAR
SELECT AVG(YEAR(GETDATE()) - YEAR(hasta.dogum_tarihi)) AS ort_yaþ
FROM hasta
JOIN muayene ON hasta.hasta_id = muayene.hasta_id
JOIN doktor ON muayene.doktor_id = doktor.doktor_id
WHERE doktor.ad = 'Nazlı';

--DİŞ ETİ HASTALIĞI TEDAVİSİ YAPTIRAN HASTALARIN FATURA BİLGİLERİNİ GETİRİR
SELECT hasta.ad, hasta.soyad, fatura.fatura_tarihi, fatura.tutar
FROM hasta
JOIN teşhis ON hasta.hasta_id = teşhis.hasta_id
JOIN fatura ON hasta.hasta_id = fatura.hasta_id
WHERE teşhis.tedavi = 'Diş eti hastalığı';

--TÜM DOKTORLARIN MUAYENE ETTİĞİ HASTALARIN ORTALAMA YAÞLARI
SELECT doktor.ad, AVG(YEAR(GETDATE()) - YEAR(hasta.dogum_tarihi))  AS ort_yaş
FROM hasta
JOIN muayene ON hasta.hasta_id = muayene.hasta_id
JOIN doktor ON muayene.doktor_id = doktor.doktor_id
GROUP BY doktor.ad;

--EN ÇOK HANGİ ÖDEME DURUMU TERCİH EDİLMİŞTİR
SELECT odeme_durumu, COUNT(odeme_durumu) AS ödeme_durumu_sayisi  FROM hasta
JOIN odeme ON hasta.hasta_id = odeme.hasta_id
GROUP BY odeme_durumu
ORDER BY ödeme_durumu_sayisi DESC;

--UZMANLIK ALANLARINA AİT RANDEVU SAYILARINI GÖSTEREN SORGU 
SELECT uzmanlik, COUNT(*) FROM doktor
JOIN randevu ON doktor.doktor_id = randevu.doktor_id
GROUP BY uzmanlik
ORDER BY COUNT(*) DESC;

--HANGİ TEDAVİ İÇİN KAÇ FARKLI İLAÇ TANIMLANMIŞTIR
SELECT tedavi, COUNT(*) FROM teşhis
INNER JOIN hasta ON hasta.hasta_id=teşhis.hasta_id
INNER JOIN ilac ON ilac.hasta_id = hasta.hasta_id
GROUP BY tedavi
ORDER BY COUNT(*) DESC;

--KART İLE ÖDEME YAPAN HASTALAR
SELECT hasta.ad, hasta.soyad
FROM hasta
JOIN odeme ON hasta.hasta_id = odeme.hasta_id
WHERE odeme.odeme_tipi = 'kart';

--HANGİ YAŞ ARALIĞI HANGİ TEDAVİYİ OLUCAK HESAPLAYAN SORGU
SELECT CASE
  WHEN YEAR(GETDATE()) - YEAR(hasta.dogum_tarihi) BETWEEN 19 AND 30 THEN 'Genç'
  WHEN YEAR(GETDATE()) - YEAR(hasta.dogum_tarihi) BETWEEN 30 AND 50 THEN 'Yetişkin'
  WHEN YEAR(GETDATE()) - YEAR(hasta.dogum_tarihi) BETWEEN 51 AND 65 THEN 'Orta Yaş'
  ELSE 'Yaşlı'
END AS 'Yaş Grubu', teşhis.tedavi
FROM teşhis
JOIN hasta ON teşhis.hasta_id = hasta.hasta_id;

--UZMANLIĞI ORTODONTİ OLAN DOKTORLARIN MUAYENEE ETTİĞİ HASTA SAYISI
SELECT doktor.doktor_id, COUNT(hasta.hasta_id) AS hasta_sayisi
FROM doktor
JOIN hasta ON doktor.doktor_id = hasta.doktor_id
WHERE doktor.uzmanlik = 'ortodonti'
GROUP BY doktor.doktor_id;

--BELİRLİ BİR DOKTORA AİT TÜM HASTALARIN LİSTESİNİ GETİRİR
SELECT ad, soyad
FROM hasta 
INNER JOIN muayene  ON muayene.hasta_id = hasta.hasta_id
WHERE muayene.doktor_id = 25;

--DİŞ ÇEKİMİ TEDAVİSİNİN HANGİ HASTALARA KAÇ KEZ UYGULANDIĞINI GÖSTERİR
SELECT doktor.ad, doktor.soyad, SUM(CASE WHEN teşhis.tedavi = 'Diş çekimi' THEN 1 ELSE 0 END) AS diş_çekimi_sayisi
FROM doktor
JOIN teşhis ON doktor.doktor_id = teşhis.doktor_id
GROUP BY doktor.doktor_id, doktor.ad, doktor.soyad
ORDER BY diş_çekimi_sayisi DESC;

--BELİRLİ BİR İLAÇ İÇİN REÇETELENDİRİLEN HASTALARIN LİSTELERİ
SELECT ad, soyad
FROM hasta 
INNER JOIN recete  ON recete.hasta_id = hasta.hasta_id
WHERE recete.ilac_id = 631;

--EN YAŞLI HASTAYA BAKAN DOKTOR VE MUAYENE TARİHİ
SELECT doktor.ad, doktor.soyad, doktor.doktor_id, muayene.muayene_tarihi
FROM doktor 
JOIN hasta  ON doktor.doktor_id = hasta.doktor_id
JOIN muayene ON hasta.hasta_id = muayene.hasta_id
WHERE hasta.dogum_tarihi = (SELECT MIN(dogum_tarihi) FROM hasta);

--EN GENÇ OLAN HASTA VE ÖDEME DURUMUNU GÖSTEREN SORGU 
SELECT odeme_durumu,hasta.ad,hasta.soyad
FROM odeme 
JOIN hasta ON odeme.hasta_id = hasta.hasta_id
WHERE  hasta.dogum_tarihi = (SELECT MAX(dogum_tarihi) FROM hasta);

--AYNI CİNSİYETTE OLAN DOKTORLAR VE HASTALARI  
SELECT hasta.ad, hasta.soyad, doktor.ad, doktor.soyad
FROM hasta
JOIN doktor ON hasta.cinsiyet = doktor.cinsiyet;

--ODEME DURUMU BEKLENİYOR OLAN KAÇ HASTA VAR 
SELECT COUNT(*) AS hasta_sayisi
FROM hasta
WHERE EXISTS (SELECT * FROM odeme WHERE hasta.hasta_id = odeme.hasta_id AND odeme.odeme_durumu = 'Bekleniyor');

-- HANGİ DOKTOR EN FAZLA RECETEYİ YAZMIŞTIR? 
SELECT doktor_id, COUNT (recete_id) AS recete_sayisi
FROM recete
GROUP BY doktor_id
ORDER BY recete_sayisi DESC;

-- ADI  "Burak Ay" OLAN DOKTORUN MUAYENE ETTİĞİ TÜM HASTALARIN BİLGİLERİ
SELECT * FROM hasta WHERE doktor_id IN (SELECT doktor_id FROM doktor WHERE ad = 'Burak' AND soyad = 'Ay');

--MAAŞI 10000 ve 20000 ARASI OLAN VE UZMANLIK ALANI 'Ağız-Diş ve Çene Cerrahisi' OLAN DOKTORLAR KİMLER
SELECT ad, soyad, doktor_maas
FROM doktor
WHERE doktor_maas BETWEEN 10000 AND 20000 AND uzmanlik = 'Ağız-Diş ve Çene Cerrahisi';

--ORTODONTİ ALANINDA UZMAN DOKTORLARIN SAYISI
SELECT COUNT(hasta_id) AS hasta_sayisi
FROM hasta
WHERE doktor_id IN (SELECT doktor_id FROM doktor WHERE uzmanlik = 'Ortodonti');

--UZMANLIK ALANI PROTEZ OLAN ERKEK DOKTORLARI GETİREN SORGU 
SELECT ad,soyad,doktor_id,cinsiyet
FROM doktor
WHERE uzmanlik='Protez' AND cinsiyet='E';

SELECT * FROM doktor WHERE uzmanlik = 'Endodonti';

-- 11 kasım 2023 de randevusu olan tüm hastalar
SELECT hasta_id, ad, soyad, dogum_tarihi
FROM hasta
WHERE hasta_id IN (  SELECT hasta_id
                     FROM randevu
                     WHERE randevu_tarihi = '2023-11-29' );

--01 KASIM VE 30 KASIM ARASINDA OLAN TÜM RANDEVULARI VE TARİHLERİNİ GÖSTERİR
SELECT hasta.hasta_id, hasta.ad, hasta.soyad, hasta.dogum_tarihi, randevu.randevu_tarihi
FROM hasta
JOIN randevu ON hasta.hasta_id = randevu.hasta_id
WHERE randevu.randevu_tarihi BETWEEN '2023-11-01' AND '2023-11-30';

-- KADIN HASTA MI YOKSA ERKEK HASTA MI FAZLA 
SELECT COUNT(*) AS hasta_sayisi, cinsiyet
FROM hasta
GROUP BY cinsiyet;

-- HANGİ ÖDEME TİPİ EN ÇOK SEÇİLİMİŞTİR
SELECT odeme_tipi, COUNT(odeme_tipi) AS odeme_sayisi
FROM odeme
WHERE odeme_tipi IS NOT NULL
GROUP BY odeme_tipi
ORDER BY odeme_sayisi DESC;

-- SADECE 'Parasetamol' ETKEN MADDESİNE SAHİP İLAÇLAR
SELECT * FROM ilac WHERE etken_madde = 'Parasetamol';

-- ADI MERT OLAN DOKTORUN 1 GÜNDE KAÇ HASTAYA BAKTIĞINI GÖSTEREN SORGU
SELECT COUNT(hasta_id) AS hasta_sayisi
FROM muayene
WHERE doktor_id IN (SELECT doktor_id FROM doktor WHERE ad = 'Mert')
AND muayene_tarihi = '2023-11-26';

-- HANGİ HASTANIN EN ÇOK RANDEVUSU VAR?
SELECT hasta_id, COUNT(*) as randevu_sayisi
FROM randevu
GROUP BY hasta_id
ORDER BY randevu_sayisi DESC;

-- HANGİ DOKTORDAN EN AZ RANDEVU ALINMIŞTIR?
SELECT doktor_id, COUNT(*) as randevu_sayisi
FROM randevu
GROUP BY doktor_id
ORDER BY randevu_sayisi ASC;

--HANGİ ETKEN MADDE EN ÇOK KULLANILMIŞTIR
SELECT etken_madde, COUNT(*) AS sayisi FROM ilac
GROUP BY etken_madde 
ORDER BY COUNT(*) DESC;

--HANGİ DOKTORUN EN ÇOK HASTAYI MUAYENE ETTİĞİNİ GÖSTEREN SORGU           //COUNT(*) işlevi, verilen sütunun deðerlerinin sayısını döndürür, bu nedenle her doktor için kaç muayene olduðunu sayar.
SELECT doktor_id, COUNT(*) AS hasta_sayisi
FROM muayene
GROUP BY doktor_id
ORDER BY hasta_sayisi DESC;

--UZMANLIK ALANI ORTODONTİ OLAN DOKTORUN MUAYENE ETTİĞİ HASTA SAYISI 3 OLAN DOKTORU GETÝREN SORGU 
SELECT * FROM doktor
WHERE uzmanlik = 'Ortodonti'
AND doktor_id IN (SELECT doktor_id FROM muayene GROUP BY doktor_id HAVING COUNT(*) = 3);

--Hasta id=220 OLAN HASTANIN KULLANDIĞI İLACIN BİLGİLERİ
SELECT * FROM ilac WHERE hasta_id = 220;

--EN ÇOK HANGİ TEDAVİNİN YAPILDIÐI SORGUSU
SELECT tedavi, COUNT(*) as tedavi_sayisi FROM teşhis
GROUP BY tedavi
ORDER BY tedavi_sayisi DESC;

--DOKTOR VE TEKNİSYENLERİN TOPLAM MAAÞLARI VE ORTALAM MAAŞLARI
SELECT 'doktor' AS pozisyon, SUM (doktor_maas) AS toplam_maas, AVG (doktor_maas) AS ortalama_maas
FROM doktor
UNION
SELECT 'teknisyen' AS pozisyon, SUM (teknisyen_maas) AS toplam_maas, AVG (teknisyen_maas) AS ortalama_maas
FROM teknisyen;

-- MAAÞI ERKEK DOKTORLARIN MAAŞLARIN ORTALAMALARINDAN FAZLA OLAN KADIN DOKTORLAR
select ad,cinsiyet,soyad,doktor_maas  from doktor
where cinsiyet='K'
group by ad,cinsiyet,soyad,doktor_maas
having doktor_maas > (Select avg(doktor_maas) as s from doktor where cinsiyet='E' );

-- TEL TEDAVİSİ OLACAK HASTALARIN BİLGİLERİ(cinsiyet, ad)
SELECT hasta.ad, hasta.cinsiyet
FROM hasta
WHERE hasta.hasta_id IN (SELECT teşhis.hasta_id FROM teşhis WHERE teşhis.tedavi = 'Tel Tedavisi');

-- ADI Aleda OLAN DOKTORUN MAAŞINI GÖSTEREN SORGU
SELECT doktor_maas
FROM doktor
WHERE ad = 'Aleda';

--BELLİ BİR HASTANIN BİLGİLERİNİ GETİRİR
SELECT tc_kimlik,tel_no,dogum_tarihi
FROM hasta
WHERE ad = 'Kubilay' and cinsiyet ='E'
AND soyad = 'Ova'

--HANGİ DOKTORUN MAAŞI EN YÜKSEK VE EN DÜŞÜKTÜR?
SELECT doktor_id, doktor_maas
FROM doktor
WHERE doktor_maas = ( SELECT MAX (doktor_maas) FROM doktor);

SELECT MIN (doktor_maas) AS en_düþük_doktor_maas FROM doktor;

--SENEM VE CENK'İN (DOKTORLAR) HANGİ TEDAVİLERİ YAPTIKLARINI GÖSTEREN SORGU  
SELECT * FROM teþhis WHERE doktor_id IN (SELECT doktor_id FROM doktor WHERE ad IN ('Senem', 'Cenk'));

--EN YAŞLI HASTANIN BİLGİLERİ
SELECT ad, soyad, dogum_tarihi
FROM hasta
WHERE dogum_tarihi = (SELECT MIN(dogum_tarihi) FROM hasta);

--EN GENÇ HASTANIN BİLGİLERİ
SELECT ad, soyad, dogum_tarihi
FROM hasta
WHERE dogum_tarihi = (SELECT MAX(dogum_tarihi) FROM hasta);

--EN YÜKSEK MAAŞI ALAN DOKTORUN UZMANLK ALANI NEDİR
SELECT uzmanlik, doktor_maas
FROM doktor
WHERE doktor_maas = (SELECT MAX(doktor_maas) FROM doktor);

--ETKEN MADDESİ AYNI OLAN İLAÇLAR
SELECT ilac_id, ilac_ad, fiyat, son_kullanma_tarihi, etken_madde
FROM ilac
WHERE etken_madde IN (SELECT etken_madde FROM ilac GROUP BY etken_madde HAVING COUNT(*) > 1);

-- doktor_id =1 OLAN DOKTORUN AD VE SOYADINI GÜNCELLEMEK İÇİN KULLANILDI
UPDATE hasta
SET ad = 'Kubilay', soyad ='Ova'
WHERE hasta_id = 1;

--BÝR DOKTORUN MAAŞINI GÜNCELLEME
UPDATE doktor
SET doktor_maas = 35500
WHERE doktor_id = 1;

--FÝYATI 100 TL'DEN AZ OLAN İLAÇLAR
SELECT ilac_ad, etken_madde,fiyat FROM ilac WHERE fiyat < 100.00;

-- TC KİMLİK NO'SU 10875639821 OLAN KİŞİNİN BİLGİLERİNİ GÖSTEREN SORGU
SELECT*FROM hasta
WHERE tc_kimlik = 10875639821;

-- ADI KARYA OLAN HASTALARIN BİLGİLERİNİ GÖSTEREN SORGU
SELECT * FROM hasta WHERE ad = 'Karya';

--20000 ÜSTÜNDE MAAŞ ALAN KADIN DOKTORLAR
SELECT ad, soyad,doktor_maas FROM doktor
WHERE doktor_maas  > 20000 AND cinsiyet = 'K';

--9000 ALTINDA MAAŞ ALAN ERKEK TEKNİSYENLER
SELECT ad, soyad,teknisyen_maas FROM teknisyen
WHERE teknisyen_maas < 9000 AND cinsiyet = 'E';

--2. en yüksek maaş alan doktor
SELECT ad, soyad, doktor_maas FROM doktor
WHERE doktor_maas = ( SELECT MAX (doktor_maas) FROM doktor WHERE doktor_maas NOT IN ( SELECT MAX (doktor_maas) FROM doktor));

SELECT doktor_maas,doktor.ad 
from doktor 
WHERE cinsiyet = 'K' 
ORDER BY doktor_maas  DESC;

--doktor_id=5 OLAN DOKTORUN MAAŞINDAN DAHA YÜKSEK MAAŞ ALAN DOKTORLARIN İSİMLERİ 
SELECT ad,soyad
FROM   doktor
WHERE  doktor_maas > ALL ( SELECT doktor_maas
                           FROM   doktor
					       WHERE  doktor_id = 5 );

--FİYATI 50TL DEN FAZLA OLUP SON KULLANMA TARİHİ '2023-01-01' VE '2023-12-31' TARİHLERİ ARASINDA OLAN İLAÇLAR
SELECT ilac_ad, fiyat,son_kullanma_tarihi FROM ilac WHERE fiyat > 50.00 AND son_kullanma_tarihi BETWEEN '2023-01-01' AND '2023-12-31';

-- DOKTORLARA %10 ZAM YAPILIRSA
SELECT*FROM doktor
UPDATE doktor
SET doktor_maas = doktor_maas * 1.1;

--UZMANLIK ALANI PROTEZ OLAN DOKTORLARA %10 ZAM YAPILMASI
UPDATE doktor
SET doktor_maas = doktor_maas * 1.1
WHERE uzmanlik = 'Protez';
SELECT *FROM doktor;

-- YAPILAN ZAM GERİ ALINIRSA 
UPDATE doktor
SET doktor_maas = doktor_maas / 1.1;
SELECT*FROM doktor;

-- SOYİSMİNİN İLK İKİ HARFİ 'ER' OLAN HASTALAR
SELECT *FROM hasta
WHERE soyad LIKE 'ER%';

--İLAÇ ADINDA VEYA ETKEN MADDESİNDE 'PRO' VEYA 'P' OLAN İLAÇLAR
SELECT ilac_ad, hasta_id,etken_madde FROM ilac WHERE ilac_ad LIKE '%pro%' OR etken_madde LIKE 'P%';

--SON KULLANMA TARİHİ '2024-05-01' VE '2024-09-30' VEYA '2025-05-01' VE '2025-09-30' TARİHLERİ ARASINDA OLAN İLAÇLAR
SELECT ilac_ad, fiyat,son_kullanma_tarihi FROM ilac WHERE son_kullanma_tarihi BETWEEN '2024-05-01' AND '2024-09-30' OR son_kullanma_tarihi BETWEEN '2025-05-01' AND '2025-09-30';

--SIRAYLA DOKTOR VE TEKNİSYENLER 
SELECT ad, soyad, 'doktor' FROM doktor
UNION
SELECT ad, soyad, 'teknisyen' FROM teknisyen;

-- DOKTORLARNI MAAŞLARININ ORTALAMASI
SELECT AVG (doktor_maas) AS ortalama_maas
FROM doktor;

SELECT cinsiyet, AVG (doktor_maas) AS ortalama_maas
FROM doktor
GROUP BY cinsiyet;

SELECT cinsiyet
FROM doktor
WHERE doktor_maas = ( SELECT MIN (doktor_maas) FROM doktor);

SELECT cinsiyet
FROM doktor
ORDER BY doktor_maas DESC;                  --ORDER BY ifadesi, satırların nasıl sıralanacağını belirtir. Sıra artan (ASC) veya azalan (DESC) olabilir. Varsayýlan olarak, sýra artandýr.

SELECT ad, soyad, doktor_maas FROM doktor;

-- TEKNİSYENLERİN EN DÜŞÜK VE EN YÜKSEK  MAAŞINI SORGULAR
SELECT teknisyen_id,teknisyen_maas,ad,soyad
FROM teknisyen
WHERE teknisyen_maas=(SELECT MAX(teknisyen_maas)FROM teknisyen);

SELECT teknisyen_id,teknisyen_maas,ad,soyad
From teknisyen
WHERE teknisyen_maas=(SELECT MIN(teknisyen_maas)FROM teknisyen );

SELECT MAX(teknisyen_maas) AS en_yüksek_teknisyen_maas, MIN(teknisyen_maas) AS en_düşük_teknisyen_maas
FROM teknisyen;

SELECT AVG(teknisyen_maas) AS erkek_teknisyen_maas_ort
FROM teknisyen
WHERE cinsiyet = 'E';

-- DOKTOR OLUP KADIN VE EN YÜKSEK MAAÞ ALAN KİM ? 
SELECT doktor_id, ad, soyad, doktor_maas
FROM doktor
WHERE cinsiyet = 'K' AND doktor_maas = (	SELECT MAX (doktor_maas)
						FROM doktor
						WHERE cinsiyet = 'K' );

--ERKEK TEKNİSYENLERDEN EN YÜKSEK MAAŞI ALAN KİM ?
SELECT teknisyen_id, ad, soyad, teknisyen_maas
FROM teknisyen 
WHERE cinsiyet = 'E' AND teknisyen_maas = (
						SELECT MIN(teknisyen_maas)
						FROM teknisyen 
						WHERE cinsiyet = 'E' );


--TÜM MAAŞLAR VE FARKLI MAAŞLARI GÖSTEREN SORGU 
SELECT ALL teknisyen_maas
FROM  teknisyen;

SELECT DISTINCT teknisyen_maas 
FROM teknisyen;

-- DOKTORLAR VE MUAYENE ETTİKLERİ HASTA SAYILARINI GETİREN SORGU  
SELECT doktor.ad, COUNT(*)  AS Muayene_sayisi
FROM hasta
JOIN muayene ON hasta.hasta_id = muayene.hasta_id
JOIN doktor ON muayene.doktor_id = doktor.doktor_id
GROUP BY doktor.ad
ORDER BY Muayene_sayisi DESC;

--DOLGU TEDAVİSİ OLAN HASTALAIN ADLARI VE HASTAYA VERİLEN İLAÇLAR (AYNI HASTA BİRDEN FAZLA İLAÇ ALABİLİR) 
SELECT ad, soyad,ilac.ilac_ad
FROM hasta 
INNER JOIN teşhis ON teşhis.hasta_id = hasta.hasta_id
INNER JOIN ilac ON ilac.hasta_id = hasta.hasta_id
WHERE teşhis.tedavi='dolgu tedavisi'
