
SELECT *FROM doktor
SELECT *FROM teknisyen
SELECT *FROM hasta
SELECT *FROM randevu
SELECT *FROM muayene
SELECT *FROM ilac
SELECT *FROM recete
SELECT *FROM fatura
SELECT *FROM odeme
SELECT *FROM teþhis


--ADI A HARFÝ ÝLE BAÞLAYAN HASTALARA BAKAN DOKTORLARIN MAAÞLARININ ORTALAMASINI GETÝRÝR
SELECT AVG(doktor_maas) AS ortalama
FROM doktor
WHERE doktor_id IN (
					SELECT doktor_id
					FROM muayene
					WHERE hasta_id IN (
										SELECT hasta_id
										FROM hasta
										WHERE ad LIKE 'A%' ));

--'2023-01-01' AND '2023-12-31' ARASINDA ÝMPLANT TEDAVÝSÝ OLAN HASTALARIN BÝLGÝLERÝNÝ GÖSTERÝR
SELECT hasta.hasta_id, hasta.ad, hasta.soyad
FROM hasta 
JOIN muayene ON hasta.hasta_id = muayene.hasta_id
JOIN teþhis  ON muayene.teþhis_id = teþhis.teþhis_id
WHERE teþhis.tedavi = 'implant' AND muayene.muayene_tarihi BETWEEN '2023-01-01' AND '2023-12-31';

-- HANGÝ ÝLAÇ EN ÇOK REÇETELENDÝRÝLMÝÞTÝR?
SELECT ilac.ilac_id, COUNT(recete_id) AS recete_sayisi
FROM recete
JOIN ilac ON ilac.ilac_id = recete.ilac_id       
GROUP BY ilac.ilac_id
ORDER BY recete_sayisi DESC;

--HANGÝ DOKTORUN VERDÝÐÝ REÇETELERÝN ORTALAMA FÝYATI EN YÜKSEKTÝR? 
SELECT doktor_id, AVG(ilac.fiyat) AS ortalama_fiyat
FROM recete
JOIN ilac ON ilac.ilac_id = recete.ilac_id
GROUP BY doktor_id
ORDER BY ortalama_fiyat DESC;

--EN YAÞLI HASTANIN ÖDEME BÝLGÝSÝNÝ GÖSTERÝR
SELECT odeme_durumu
FROM odeme 
JOIN hasta ON odeme.hasta_id = hasta.hasta_id
WHERE hasta.dogum_tarihi = (SELECT MIN(dogum_tarihi) FROM hasta);

--ADI 'BERFU OLAN HASTANIN NUMARASI ,TC KÝMLÝK BÝLGÝSÝ VE NE TEDAVÝSÝ OLACAÐINI GÖSTEREN SORGU
SELECT hasta.hasta_id, hasta.tc_kimlik, teþhis.tedavi
FROM hasta INNER JOIN teþhis ON hasta.hasta_id = teþhis.hasta_id
WHERE hasta.ad = 'Berfu';

--EN YAÞLI OLAN HASTA VE ÖDEME DURUMUNU YAZDIRAN SORGU   
SELECT odeme_durumu,hasta.ad,hasta.soyad
FROM odeme 
JOIN hasta ON odeme.hasta_id = hasta.hasta_id
WHERE  hasta.dogum_tarihi = (SELECT MIN(dogum_tarihi) FROM hasta);



--ADI NAZLI OLAN DOKTORUN MUAYENE ETTÝÐÝ HASTALARIN ORTALAMA YAÞINI HESAPLAR
SELECT AVG(YEAR(GETDATE()) - YEAR(hasta.dogum_tarihi)) AS ort_yaþ
FROM hasta
JOIN muayene ON hasta.hasta_id = muayene.hasta_id
JOIN doktor ON muayene.doktor_id = doktor.doktor_id
WHERE doktor.ad = 'Nazlý';

--DÝÞ ETÝ HASTALIÐI TEDAVÝSÝ YAPTIRAN HASTALARIN FATURA BÝLGÝLERÝNÝ GETÝRÝR
SELECT hasta.ad, hasta.soyad, fatura.fatura_tarihi, fatura.tutar
FROM hasta
JOIN teþhis ON hasta.hasta_id = teþhis.hasta_id
JOIN fatura ON hasta.hasta_id = fatura.hasta_id
WHERE teþhis.tedavi = 'Diþ eti hastalýðý';

--TÜM DOKTORLARIN MUAYENE ETTÝÐÝ HASTALARIN ORTALAMA YAÞLARI
SELECT doktor.ad, AVG(YEAR(GETDATE()) - YEAR(hasta.dogum_tarihi))  AS ort_yaþ
FROM hasta
JOIN muayene ON hasta.hasta_id = muayene.hasta_id
JOIN doktor ON muayene.doktor_id = doktor.doktor_id
GROUP BY doktor.ad;

--EN ÇOK HANGÝ ÖDEME DURUMU TERCÝH EDÝLMÝÞTÝR
SELECT odeme_durumu, COUNT(odeme_durumu) AS ödeme_durumu_sayisi  FROM hasta
JOIN odeme ON hasta.hasta_id = odeme.hasta_id
GROUP BY odeme_durumu
ORDER BY ödeme_durumu_sayisi DESC;

--UZMANLIK ALANLARINA AÝT RANDEVU SAYILARINI GÖSTEREN SORGU 
SELECT uzmanlýk, COUNT(*) FROM doktor
JOIN randevu ON doktor.doktor_id = randevu.doktor_id
GROUP BY uzmanlýk
ORDER BY COUNT(*) DESC;

--HANGÝ TEDAVÝ ÝÇÝN KAÇ FARKLI ÝLAÇ TANIMLANMIÞTIR
SELECT tedavi, COUNT(*) FROM teþhis
INNER JOIN hasta ON hasta.hasta_id=teþhis.hasta_id
INNER JOIN ilac ON ilac.hasta_id = hasta.hasta_id
GROUP BY tedavi
ORDER BY COUNT(*) DESC;

--KART ÝLE ÖDEME YAPAN HASTALAR
SELECT hasta.ad, hasta.soyad
FROM hasta
JOIN odeme ON hasta.hasta_id = odeme.hasta_id
WHERE odeme.odeme_tipi = 'kart';


--HANGÝ YAÞ ARALIÐI HANGÝ TEDAVÝYÝ OLUCAK HESAPLAYAN SORGU
SELECT CASE
  WHEN YEAR(GETDATE()) - YEAR(hasta.dogum_tarihi) BETWEEN 19 AND 30 THEN 'Genç'
  WHEN YEAR(GETDATE()) - YEAR(hasta.dogum_tarihi) BETWEEN 30 AND 50 THEN 'Yetiþkin'
  WHEN YEAR(GETDATE()) - YEAR(hasta.dogum_tarihi) BETWEEN 51 AND 65 THEN 'Orta Yaþ'
  ELSE 'Yaþlý'
END AS 'Yaþ Grubu', teþhis.tedavi
FROM teþhis
JOIN hasta ON teþhis.hasta_id = hasta.hasta_id;

--UZMANLIÐI ORTODONTÝ OLAN DOKTORLARIN MUAYENEE ETTÝÐÝ HASTA SAYISI
SELECT doktor.doktor_id, COUNT(hasta.hasta_id) AS hasta_sayisi
FROM doktor
JOIN hasta ON doktor.doktor_id = hasta.doktor_id
WHERE doktor.uzmanlýk = 'ortodonti'
GROUP BY doktor.doktor_id;

--BELÝRLÝ BÝR DOKTORA AÝT TÜM HASTALARIN LÝSTESÝNÝ GETÝRÝR
SELECT ad, soyad
FROM hasta 
INNER JOIN muayene  ON muayene.hasta_id = hasta.hasta_id
WHERE muayene.doktor_id = 25;

--DÝÞ ÇEKÝMÝ TEDAVÝSÝNÝN HANGÝ HASTALARA KAÇ KEZ UYGULANDIÐINI GÖSTERÝR
SELECT doktor.ad, doktor.soyad, SUM(CASE WHEN teþhis.tedavi = 'Diþ çekimi' THEN 1 ELSE 0 END) AS diþ_çekimi_sayisi
FROM doktor
JOIN teþhis ON doktor.doktor_id = teþhis.doktor_id
GROUP BY doktor.doktor_id, doktor.ad, doktor.soyad
ORDER BY diþ_çekimi_sayisi DESC;

--BELÝRLÝ BÝR ÝLAÇ ÝÇÝN REÇETELENDÝRÝLEN HASTALARIN LÝSTELERÝ
SELECT ad, soyad
FROM hasta 
INNER JOIN recete  ON recete.hasta_id = hasta.hasta_id
WHERE recete.ilac_id = 631;


--WHERE recete.ilac_id = 631;
--EN YAÞLI HASTAYA BAKAN DOKTOR VE MUAYENE TARÝHÝ
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

--AYNI CÝNSÝYETTE OLAN DOKTORLAR VE HASTALARI  
SELECT hasta.ad, hasta.soyad, doktor.ad, doktor.soyad
FROM hasta
JOIN doktor ON hasta.cinsiyet = doktor.cinsiyet;

--ODEME DURUMU BEKLENÝYOR OLAN KAÇ HASTA VAR 
SELECT COUNT(*) AS hasta_sayisi
FROM hasta
WHERE EXISTS (SELECT * FROM odeme WHERE hasta.hasta_id = odeme.hasta_id AND odeme.odeme_durumu = 'Bekleniyor');


-- HANGÝ DOKTOR EN FAZLA RECETEYÝ YAZMIÞTIR? 
SELECT doktor_id, COUNT (recete_id) AS recete_sayisi
FROM recete
GROUP BY doktor_id
ORDER BY recete_sayisi DESC;

-- ADI  "Burak Ay" OLAN DOKTORUN MUAYENE ETTÝÐÝ TÜM HASTALARIN BÝLGÝLERÝ
SELECT * FROM hasta WHERE doktor_id IN (SELECT doktor_id FROM doktor WHERE ad = 'Burak' AND soyad = 'Ay');

--MAAÞI 10000 ve 20000 ARASI OLAN VE UZMANLIK ALANI 'Aðýz-Diþ ve Çene Cerrahisi' OLAN DOKTORLAR KÝMLER
SELECT ad, soyad, doktor_maas
FROM doktor
WHERE doktor_maas BETWEEN 10000 AND 20000 AND uzmanlýk = 'Aðýz-Diþ ve Çene Cerrahisi';

--ORTODONTÝ ALANINDA UZMAN DOKTORLARIN SAYISI
SELECT COUNT(hasta_id) AS hasta_sayisi
FROM hasta
WHERE doktor_id IN (SELECT doktor_id FROM doktor WHERE uzmanlýk = 'Ortodonti');

--UZMANLIK ALANI PROTEZ OLAN ERKEK DOKTORLARI GETÝREN SORGU 
SELECT ad,soyad,doktor_id,cinsiyet
FROM doktor
WHERE uzmanlýk='Protez' AND cinsiyet='E';

SELECT * FROM doktor WHERE uzmanlýk = 'Endodonti';

-- 11 kasým 2023 de randevusu olan tüm hastalar
SELECT hasta_id, ad, soyad, dogum_tarihi
FROM hasta
WHERE hasta_id IN (  SELECT hasta_id
                     FROM randevu
                     WHERE randevu_tarihi = '2023-11-29' );

--01 KASIM VE 30 KASIM ARASINDA OLAN TÜM RANDEVULARI VE TARÝHLERÝNÝ GÖSTERÝR
SELECT hasta.hasta_id, hasta.ad, hasta.soyad, hasta.dogum_tarihi, randevu.randevu_tarihi
FROM hasta
JOIN randevu ON hasta.hasta_id = randevu.hasta_id
WHERE randevu.randevu_tarihi BETWEEN '2023-11-01' AND '2023-11-30';

-- KADIN HASTA MI YOKSA ERKEK HASTA MI FAZLA 
SELECT COUNT(*) AS hasta_sayisi, cinsiyet
FROM hasta
GROUP BY cinsiyet;

-- HANGÝ ÖDEME TÝPÝ EN ÇOK SEÇÝLÝMÝÞTÝR
SELECT odeme_tipi, COUNT(odeme_tipi) AS odeme_sayisi
FROM odeme
WHERE odeme_tipi IS NOT NULL
GROUP BY odeme_tipi
ORDER BY odeme_sayisi DESC;

-- SADECE 'Parasetamol' ETKEN MADDESÝNE SAHÝP ÝLAÇLAR
SELECT * FROM ilac WHERE etken_madde = 'Parasetamol';

-- ADI MERT OLAN DOKTORUN 1 GÜNDE KAÇ HASTAYA BAKTIÐINI GÖSTEREN SORGU
SELECT COUNT(hasta_id) AS hasta_sayisi
FROM muayene
WHERE doktor_id IN (SELECT doktor_id FROM doktor WHERE ad = 'Mert')
AND muayene_tarihi = '2023-11-26';

-- HANGÝ HASTANIN EN ÇOK RANDEVUSU VAR?
SELECT hasta_id, COUNT(*) as randevu_sayisi
FROM randevu
GROUP BY hasta_id
ORDER BY randevu_sayisi DESC;

-- HANGÝ DOKTORDAN EN AZ RANDEVU ALINMIÞTIR?
SELECT doktor_id, COUNT(*) as randevu_sayisi
FROM randevu
GROUP BY doktor_id
ORDER BY randevu_sayisi ASC;

--HANGÝ ETKEN MADDE EN ÇOK KULLANILMIÞTIR
SELECT etken_madde, COUNT(*) AS sayisi FROM ilac
GROUP BY etken_madde 
ORDER BY COUNT(*) DESC;

--HANGÝ DOKTORUN EN ÇOK HASTAYI MUAYENE ETTÝÐÝNÝ GÖSTEREN SORGU           //COUNT(*) iþlevi, verilen sütunun deðerlerinin sayýsýný döndürür, bu nedenle her doktor için kaç muayene olduðunu sayar.
SELECT doktor_id, COUNT(*) AS hasta_sayisi
FROM muayene
GROUP BY doktor_id
ORDER BY hasta_sayisi DESC;

--UZMANLIK ALANI ORTODONTÝ OLAN DOKTORUN MUAYENE ETTÝÐÝ HASTA SAYISI 3 OLAN DOKTORU GETÝREN SORGU 
SELECT * FROM doktor
WHERE uzmanlýk = 'Ortodonti'
AND doktor_id IN (SELECT doktor_id FROM muayene GROUP BY doktor_id HAVING COUNT(*) = 3);

--Hasta id=220 OLAN HASTANIN KULLANDIÐI ÝLACIN BÝLGÝLERÝ
SELECT * FROM ilac WHERE hasta_id = 220;

--EN ÇOK HANGÝ TEDAVÝNÝN YAPILDIÐI SORGUSU
SELECT tedavi, COUNT(*) as tedavi_sayisi FROM teþhis
GROUP BY tedavi
ORDER BY tedavi_sayisi DESC;

--DOKTOR VE TEKNÝSYENLERÝN TOPLAM MAAÞLARI VE ORTALAM MAAÞLARI
SELECT 'doktor' AS pozisyon, SUM (doktor_maas) AS toplam_maas, AVG (doktor_maas) AS ortalama_maas
FROM doktor
UNION
SELECT 'teknisyen' AS pozisyon, SUM (teknisyen_maas) AS toplam_maas, AVG (teknisyen_maas) AS ortalama_maas
FROM teknisyen;

-- MAAÞI ERKEK DOKTORLARIN MAAÞLARIN ORTALAMALARINDAN FAZLA OLAN KADIN DOKTORLAR
select ad,cinsiyet,soyad,doktor_maas  from doktor
where cinsiyet='K'
group by ad,cinsiyet,soyad,doktor_maas
having doktor_maas > (Select avg(doktor_maas) as s from doktor where cinsiyet='E' );

-- TEL TEDAVÝSÝ OLACAK HASTALARIN BÝLGÝLERÝ(cinsiyet, ad)
SELECT hasta.ad, hasta.cinsiyet
FROM hasta
WHERE hasta.hasta_id IN (SELECT teþhis.hasta_id FROM teþhis WHERE teþhis.tedavi = 'Tel Tedavisi');

-- ADI Aleda OLAN DOKTORUN MAAÞINI GÖSTEREN SORGU
SELECT doktor_maas
FROM doktor
WHERE ad = 'Aleda';

--BELLÝ BÝR HASTANIN BÝLGÝLERÝNÝ GETÝRÝR
SELECT tc_kimlik,tel_no,dogum_tarihi
FROM hasta
WHERE ad = 'Kubilay' and cinsiyet ='E'
AND soyad = 'Ova'

--HANGÝ DOKTORUN MAAÞI EN YÜKSEK VE EN DÜÞÜKTÜR?
SELECT doktor_id, doktor_maas
FROM doktor
WHERE doktor_maas = ( SELECT MAX (doktor_maas) FROM doktor);

SELECT MIN (doktor_maas) AS en_düþük_doktor_maas FROM doktor;

--SENEM VE CENK'ÝN (DOKTORLAR) HANGÝ TEDAVÝLERÝ YAPTIKLARINI GÖSTEREN SORGU  
SELECT * FROM teþhis WHERE doktor_id IN (SELECT doktor_id FROM doktor WHERE ad IN ('Senem', 'Cenk'));

--EN YAÞLI HASTANIN BÝLGÝLERÝ
SELECT ad, soyad, dogum_tarihi
FROM hasta
WHERE dogum_tarihi = (SELECT MIN(dogum_tarihi) FROM hasta);

--EN GENÇ HASTANIN BÝLGÝLERÝ
SELECT ad, soyad, dogum_tarihi
FROM hasta
WHERE dogum_tarihi = (SELECT MAX(dogum_tarihi) FROM hasta);

--EN YÜKSEK MAAÞI ALAN DOKTORUN UZMANLK ALANI NEDÝR
SELECT uzmanlýk, doktor_maas
FROM doktor
WHERE doktor_maas = (SELECT MAX(doktor_maas) FROM doktor);


--ETKEN MADDESÝ AYNI OLAN ÝLAÇLAR
SELECT ilac_id, ilac_ad, fiyat, son_kullanma_tarihi, etken_madde
FROM ilac
WHERE etken_madde IN (SELECT etken_madde FROM ilac GROUP BY etken_madde HAVING COUNT(*) > 1);

-- doktor_id =1 OLAN DOKTORUN AD VE SOYADINI GÜNCELLEMEK ÝÇÝN KULLANILDI
UPDATE hasta
SET ad = 'Kubilay', soyad ='Ova'
WHERE hasta_id = 1;

--BÝR DOKTORUN MAAÞINI GÜNCELLEME
UPDATE doktor
SET doktor_maas = 35500
WHERE doktor_id = 1;

--FÝYATI 100 TL'DEN AZ OLAN ÝLAÇLAR
SELECT ilac_ad, etken_madde,fiyat FROM ilac WHERE fiyat < 100.00;

-- TC KÝMLÝK NO'SU 10875639821 OLAN KÝÞÝNÝN BÝLGÝLERÝNÝ GÖSTEREN SORGU
SELECT*FROM hasta
WHERE tc_kimlik = 10875639821;

-- ADI KARYA OLAN HASTALARIN BÝLGÝLERÝNÝ GÖSTEREN SORGU
SELECT * FROM hasta WHERE ad = 'Karya';

--20000 ÜSTÜNDE MAAÞ ALAN KADIN DOKTORLAR
SELECT ad, soyad,doktor_maas FROM doktor
WHERE doktor_maas  > 20000 AND cinsiyet = 'K';

--9000 ALTINDA MAAÞ ALAN ERKEK TEKNÝSYENLER
SELECT ad, soyad,teknisyen_maas FROM teknisyen
WHERE teknisyen_maas < 9000 AND cinsiyet = 'E';

--2. en yüksek maaþ alan doktor
SELECT ad, soyad, doktor_maas FROM doktor
WHERE doktor_maas = ( SELECT MAX (doktor_maas) FROM doktor WHERE doktor_maas NOT IN ( SELECT MAX (doktor_maas) FROM doktor));

SELECT doktor_maas,doktor.ad 
from doktor 
WHERE cinsiyet = 'K' 
ORDER BY doktor_maas  DESC;

--doktor_id=5 OLAN DOKTORUN MAAÞINDAN DAHA YÜKSEK MAAÞ ALAN DOKTORLARIN ÝSÝMLERÝ 
SELECT ad,soyad
FROM   doktor
WHERE  doktor_maas > ALL ( SELECT doktor_maas
                           FROM   doktor
					       WHERE  doktor_id = 5 );
--FÝYATI 50TL DEN FAZLA OLUP SON KULLANMA TARÝHÝ '2023-01-01' VE '2023-12-31' TARÝHLERÝ ARASINDA OLAN ÝLAÇLAR
SELECT ilac_ad, fiyat,son_kullanma_tarihi FROM ilac WHERE fiyat > 50.00 AND son_kullanma_tarihi BETWEEN '2023-01-01' AND '2023-12-31';

-- DOKTORLARA %10 ZAM YAPILIRSA
SELECT*FROM doktor
UPDATE doktor
SET doktor_maas = doktor_maas * 1.1;

--UZMANLIK ALANI PROTEZ OLAN DOKTORLARA %10 ZAM YAPILMASI
UPDATE doktor
SET doktor_maas = doktor_maas * 1.1
WHERE uzmanlýk = 'Protez';
SELECT *FROM doktor;

-- YAPILAN ZAM GERÝ ALINIRSA 
UPDATE doktor
SET doktor_maas = doktor_maas / 1.1;
SELECT*FROM doktor;

-- SOYÝSMÝNÝN ÝLK ÝKÝ HARFÝ 'ER' OLAN HASTALAR
SELECT *FROM hasta
WHERE soyad LIKE 'ER%';

--ÝLAÇ ADINDA VEYA ETKEN MADDESÝNDE 'PRO' VEYA 'P' OLAN ÝLAÇLAR
SELECT ilac_ad, hasta_id,etken_madde FROM ilac WHERE ilac_ad LIKE '%pro%' OR etken_madde LIKE 'P%';

--SON KULLANMA TARÝHÝ '2024-05-01' VE '2024-09-30' VEYA '2025-05-01' VE '2025-09-30' TARÝHLERÝ ARASINDA OLAN ÝLAÇLAR
SELECT ilac_ad, fiyat,son_kullanma_tarihi FROM ilac WHERE son_kullanma_tarihi BETWEEN '2024-05-01' AND '2024-09-30' OR son_kullanma_tarihi BETWEEN '2025-05-01' AND '2025-09-30';

--SIRAYLA DOKTOR VE TEKNÝSYENLER 
SELECT ad, soyad, 'doktor' FROM doktor
UNION
SELECT ad, soyad, 'teknisyen' FROM teknisyen;

-- DOKTORLARNI MAAÞLARININ ORTALAMASI
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
ORDER BY doktor_maas DESC;                  --ORDER BY ifadesi, satýrlarýn nasýl sýralanacaðýný belirtir. Sýra artan (ASC) veya azalan (DESC) olabilir. Varsayýlan olarak, sýra artandýr.

SELECT ad, soyad, doktor_maas FROM doktor;

-- TEKNÝSYENLERÝN EN DÜÞÜK VE EN YÜKSEK  MAAÞINI SORGULAR
SELECT teknisyen_id,teknisyen_maas,ad,soyad
FROM teknisyen
WHERE teknisyen_maas=(SELECT MAX(teknisyen_maas)FROM teknisyen);

SELECT teknisyen_id,teknisyen_maas,ad,soyad
From teknisyen
WHERE teknisyen_maas=(SELECT MIN(teknisyen_maas)FROM teknisyen );

SELECT MAX(teknisyen_maas) AS en_yüksek_teknisyen_maas, MIN(teknisyen_maas) AS en_düþük_teknisyen_maas
FROM teknisyen;

SELECT AVG(teknisyen_maas) AS erkek_teknisyen_maas_ort
FROM teknisyen
WHERE cinsiyet = 'E';

-- DOKTOR OLUP KADIN VE EN YÜKSEK MAAÞ ALAN KÝM ? 
SELECT doktor_id, ad, soyad, doktor_maas
FROM doktor
WHERE cinsiyet = 'K' AND doktor_maas = (	SELECT MAX (doktor_maas)
											FROM doktor
											WHERE cinsiyet = 'K' );

--ERKEK TEKNÝSYENLERDEN EN YÜKSEK MAAÞI ALAN KÝM ?
SELECT teknisyen_id, ad, soyad, teknisyen_maas
FROM teknisyen 
WHERE cinsiyet = 'E' AND teknisyen_maas = (
											SELECT MIN(teknisyen_maas)
											FROM teknisyen 
											WHERE cinsiyet = 'E' );


--TÜM MAAÞLAR VE FARKLI MAAÞLARI GÖSTEREN SORGU 
SELECT ALL teknisyen_maas
FROM  teknisyen;

SELECT DISTINCT teknisyen_maas 
FROM teknisyen;

-- DOKTORLAR VE MUAYENE ETTÝKLERÝ HASTA SAYILARINI GETÝREN SORGU  (SUNUM YAPARKEN SORDUÐUNUZ VE YAPTIÐIM SORGU)
SELECT doktor.ad, COUNT(*)  AS Muayene_sayisi
FROM hasta
JOIN muayene ON hasta.hasta_id = muayene.hasta_id
JOIN doktor ON muayene.doktor_id = doktor.doktor_id
GROUP BY doktor.ad
ORDER BY Muayene_sayisi DESC;

--DOLGU TEDAVÝSÝ OLAN HASTALAIN ADLARI VE HASTAYA VERÝLEN ÝLAÇLAR (AYNI HASTA BÝRDEN FAZLA ÝLAÇ ALABÝLÝR) (SUNUM ESNASINDA SORDUÐUNUZ FAKAT YAPAMADIÐIM SORGU)
SELECT ad, soyad,ilac.ilac_ad
FROM hasta 
INNER JOIN teþhis ON teþhis.hasta_id = hasta.hasta_id
INNER JOIN ilac ON ilac.hasta_id = hasta.hasta_id
WHERE teþhis.tedavi='dolgu tedavisi'
