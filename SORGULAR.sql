
SELECT *FROM doktor
SELECT *FROM teknisyen
SELECT *FROM hasta
SELECT *FROM randevu
SELECT *FROM muayene
SELECT *FROM ilac
SELECT *FROM recete
SELECT *FROM fatura
SELECT *FROM odeme
SELECT *FROM te�his


--ADI A HARF� �LE BA�LAYAN HASTALARA BAKAN DOKTORLARIN MAA�LARININ ORTALAMASINI GET�R�R
SELECT AVG(doktor_maas) AS ortalama
FROM doktor
WHERE doktor_id IN (
					SELECT doktor_id
					FROM muayene
					WHERE hasta_id IN (
										SELECT hasta_id
										FROM hasta
										WHERE ad LIKE 'A%' ));

--'2023-01-01' AND '2023-12-31' ARASINDA �MPLANT TEDAV�S� OLAN HASTALARIN B�LG�LER�N� G�STER�R
SELECT hasta.hasta_id, hasta.ad, hasta.soyad
FROM hasta 
JOIN muayene ON hasta.hasta_id = muayene.hasta_id
JOIN te�his  ON muayene.te�his_id = te�his.te�his_id
WHERE te�his.tedavi = 'implant' AND muayene.muayene_tarihi BETWEEN '2023-01-01' AND '2023-12-31';

-- HANG� �LA� EN �OK RE�ETELEND�R�LM��T�R?
SELECT ilac.ilac_id, COUNT(recete_id) AS recete_sayisi
FROM recete
JOIN ilac ON ilac.ilac_id = recete.ilac_id       
GROUP BY ilac.ilac_id
ORDER BY recete_sayisi DESC;

--HANG� DOKTORUN VERD��� RE�ETELER�N ORTALAMA F�YATI EN Y�KSEKT�R? 
SELECT doktor_id, AVG(ilac.fiyat) AS ortalama_fiyat
FROM recete
JOIN ilac ON ilac.ilac_id = recete.ilac_id
GROUP BY doktor_id
ORDER BY ortalama_fiyat DESC;

--EN YA�LI HASTANIN �DEME B�LG�S�N� G�STER�R
SELECT odeme_durumu
FROM odeme 
JOIN hasta ON odeme.hasta_id = hasta.hasta_id
WHERE hasta.dogum_tarihi = (SELECT MIN(dogum_tarihi) FROM hasta);

--ADI 'BERFU OLAN HASTANIN NUMARASI ,TC K�ML�K B�LG�S� VE NE TEDAV�S� OLACA�INI G�STEREN SORGU
SELECT hasta.hasta_id, hasta.tc_kimlik, te�his.tedavi
FROM hasta INNER JOIN te�his ON hasta.hasta_id = te�his.hasta_id
WHERE hasta.ad = 'Berfu';

--EN YA�LI OLAN HASTA VE �DEME DURUMUNU YAZDIRAN SORGU   
SELECT odeme_durumu,hasta.ad,hasta.soyad
FROM odeme 
JOIN hasta ON odeme.hasta_id = hasta.hasta_id
WHERE  hasta.dogum_tarihi = (SELECT MIN(dogum_tarihi) FROM hasta);



--ADI NAZLI OLAN DOKTORUN MUAYENE ETT��� HASTALARIN ORTALAMA YA�INI HESAPLAR
SELECT AVG(YEAR(GETDATE()) - YEAR(hasta.dogum_tarihi)) AS ort_ya�
FROM hasta
JOIN muayene ON hasta.hasta_id = muayene.hasta_id
JOIN doktor ON muayene.doktor_id = doktor.doktor_id
WHERE doktor.ad = 'Nazl�';

--D�� ET� HASTALI�I TEDAV�S� YAPTIRAN HASTALARIN FATURA B�LG�LER�N� GET�R�R
SELECT hasta.ad, hasta.soyad, fatura.fatura_tarihi, fatura.tutar
FROM hasta
JOIN te�his ON hasta.hasta_id = te�his.hasta_id
JOIN fatura ON hasta.hasta_id = fatura.hasta_id
WHERE te�his.tedavi = 'Di� eti hastal���';

--T�M DOKTORLARIN MUAYENE ETT��� HASTALARIN ORTALAMA YA�LARI
SELECT doktor.ad, AVG(YEAR(GETDATE()) - YEAR(hasta.dogum_tarihi))  AS ort_ya�
FROM hasta
JOIN muayene ON hasta.hasta_id = muayene.hasta_id
JOIN doktor ON muayene.doktor_id = doktor.doktor_id
GROUP BY doktor.ad;

--EN �OK HANG� �DEME DURUMU TERC�H ED�LM��T�R
SELECT odeme_durumu, COUNT(odeme_durumu) AS �deme_durumu_sayisi  FROM hasta
JOIN odeme ON hasta.hasta_id = odeme.hasta_id
GROUP BY odeme_durumu
ORDER BY �deme_durumu_sayisi DESC;

--UZMANLIK ALANLARINA A�T RANDEVU SAYILARINI G�STEREN SORGU 
SELECT uzmanl�k, COUNT(*) FROM doktor
JOIN randevu ON doktor.doktor_id = randevu.doktor_id
GROUP BY uzmanl�k
ORDER BY COUNT(*) DESC;

--HANG� TEDAV� ���N KA� FARKLI �LA� TANIMLANMI�TIR
SELECT tedavi, COUNT(*) FROM te�his
INNER JOIN hasta ON hasta.hasta_id=te�his.hasta_id
INNER JOIN ilac ON ilac.hasta_id = hasta.hasta_id
GROUP BY tedavi
ORDER BY COUNT(*) DESC;

--KART �LE �DEME YAPAN HASTALAR
SELECT hasta.ad, hasta.soyad
FROM hasta
JOIN odeme ON hasta.hasta_id = odeme.hasta_id
WHERE odeme.odeme_tipi = 'kart';


--HANG� YA� ARALI�I HANG� TEDAV�Y� OLUCAK HESAPLAYAN SORGU
SELECT CASE
  WHEN YEAR(GETDATE()) - YEAR(hasta.dogum_tarihi) BETWEEN 19 AND 30 THEN 'Gen�'
  WHEN YEAR(GETDATE()) - YEAR(hasta.dogum_tarihi) BETWEEN 30 AND 50 THEN 'Yeti�kin'
  WHEN YEAR(GETDATE()) - YEAR(hasta.dogum_tarihi) BETWEEN 51 AND 65 THEN 'Orta Ya�'
  ELSE 'Ya�l�'
END AS 'Ya� Grubu', te�his.tedavi
FROM te�his
JOIN hasta ON te�his.hasta_id = hasta.hasta_id;

--UZMANLI�I ORTODONT� OLAN DOKTORLARIN MUAYENEE ETT��� HASTA SAYISI
SELECT doktor.doktor_id, COUNT(hasta.hasta_id) AS hasta_sayisi
FROM doktor
JOIN hasta ON doktor.doktor_id = hasta.doktor_id
WHERE doktor.uzmanl�k = 'ortodonti'
GROUP BY doktor.doktor_id;

--BEL�RL� B�R DOKTORA A�T T�M HASTALARIN L�STES�N� GET�R�R
SELECT ad, soyad
FROM hasta 
INNER JOIN muayene  ON muayene.hasta_id = hasta.hasta_id
WHERE muayene.doktor_id = 25;

--D�� �EK�M� TEDAV�S�N�N HANG� HASTALARA KA� KEZ UYGULANDI�INI G�STER�R
SELECT doktor.ad, doktor.soyad, SUM(CASE WHEN te�his.tedavi = 'Di� �ekimi' THEN 1 ELSE 0 END) AS di�_�ekimi_sayisi
FROM doktor
JOIN te�his ON doktor.doktor_id = te�his.doktor_id
GROUP BY doktor.doktor_id, doktor.ad, doktor.soyad
ORDER BY di�_�ekimi_sayisi DESC;

--BEL�RL� B�R �LA� ���N RE�ETELEND�R�LEN HASTALARIN L�STELER�
SELECT ad, soyad
FROM hasta 
INNER JOIN recete  ON recete.hasta_id = hasta.hasta_id
WHERE recete.ilac_id = 631;


--WHERE recete.ilac_id = 631;
--EN YA�LI HASTAYA BAKAN DOKTOR VE MUAYENE TAR�H�
SELECT doktor.ad, doktor.soyad, doktor.doktor_id, muayene.muayene_tarihi
FROM doktor 
JOIN hasta  ON doktor.doktor_id = hasta.doktor_id
JOIN muayene ON hasta.hasta_id = muayene.hasta_id
WHERE hasta.dogum_tarihi = (SELECT MIN(dogum_tarihi) FROM hasta);

--EN GEN� OLAN HASTA VE �DEME DURUMUNU G�STEREN SORGU 
SELECT odeme_durumu,hasta.ad,hasta.soyad
FROM odeme 
JOIN hasta ON odeme.hasta_id = hasta.hasta_id
WHERE  hasta.dogum_tarihi = (SELECT MAX(dogum_tarihi) FROM hasta);

--AYNI C�NS�YETTE OLAN DOKTORLAR VE HASTALARI  
SELECT hasta.ad, hasta.soyad, doktor.ad, doktor.soyad
FROM hasta
JOIN doktor ON hasta.cinsiyet = doktor.cinsiyet;

--ODEME DURUMU BEKLEN�YOR OLAN KA� HASTA VAR 
SELECT COUNT(*) AS hasta_sayisi
FROM hasta
WHERE EXISTS (SELECT * FROM odeme WHERE hasta.hasta_id = odeme.hasta_id AND odeme.odeme_durumu = 'Bekleniyor');


-- HANG� DOKTOR EN FAZLA RECETEY� YAZMI�TIR? 
SELECT doktor_id, COUNT (recete_id) AS recete_sayisi
FROM recete
GROUP BY doktor_id
ORDER BY recete_sayisi DESC;

-- ADI  "Burak Ay" OLAN DOKTORUN MUAYENE ETT��� T�M HASTALARIN B�LG�LER�
SELECT * FROM hasta WHERE doktor_id IN (SELECT doktor_id FROM doktor WHERE ad = 'Burak' AND soyad = 'Ay');

--MAA�I 10000 ve 20000 ARASI OLAN VE UZMANLIK ALANI 'A��z-Di� ve �ene Cerrahisi' OLAN DOKTORLAR K�MLER
SELECT ad, soyad, doktor_maas
FROM doktor
WHERE doktor_maas BETWEEN 10000 AND 20000 AND uzmanl�k = 'A��z-Di� ve �ene Cerrahisi';

--ORTODONT� ALANINDA UZMAN DOKTORLARIN SAYISI
SELECT COUNT(hasta_id) AS hasta_sayisi
FROM hasta
WHERE doktor_id IN (SELECT doktor_id FROM doktor WHERE uzmanl�k = 'Ortodonti');

--UZMANLIK ALANI PROTEZ OLAN ERKEK DOKTORLARI GET�REN SORGU 
SELECT ad,soyad,doktor_id,cinsiyet
FROM doktor
WHERE uzmanl�k='Protez' AND cinsiyet='E';

SELECT * FROM doktor WHERE uzmanl�k = 'Endodonti';

-- 11 kas�m 2023 de randevusu olan t�m hastalar
SELECT hasta_id, ad, soyad, dogum_tarihi
FROM hasta
WHERE hasta_id IN (  SELECT hasta_id
                     FROM randevu
                     WHERE randevu_tarihi = '2023-11-29' );

--01 KASIM VE 30 KASIM ARASINDA OLAN T�M RANDEVULARI VE TAR�HLER�N� G�STER�R
SELECT hasta.hasta_id, hasta.ad, hasta.soyad, hasta.dogum_tarihi, randevu.randevu_tarihi
FROM hasta
JOIN randevu ON hasta.hasta_id = randevu.hasta_id
WHERE randevu.randevu_tarihi BETWEEN '2023-11-01' AND '2023-11-30';

-- KADIN HASTA MI YOKSA ERKEK HASTA MI FAZLA 
SELECT COUNT(*) AS hasta_sayisi, cinsiyet
FROM hasta
GROUP BY cinsiyet;

-- HANG� �DEME T�P� EN �OK SE��L�M��T�R
SELECT odeme_tipi, COUNT(odeme_tipi) AS odeme_sayisi
FROM odeme
WHERE odeme_tipi IS NOT NULL
GROUP BY odeme_tipi
ORDER BY odeme_sayisi DESC;

-- SADECE 'Parasetamol' ETKEN MADDES�NE SAH�P �LA�LAR
SELECT * FROM ilac WHERE etken_madde = 'Parasetamol';

-- ADI MERT OLAN DOKTORUN 1 G�NDE KA� HASTAYA BAKTI�INI G�STEREN SORGU
SELECT COUNT(hasta_id) AS hasta_sayisi
FROM muayene
WHERE doktor_id IN (SELECT doktor_id FROM doktor WHERE ad = 'Mert')
AND muayene_tarihi = '2023-11-26';

-- HANG� HASTANIN EN �OK RANDEVUSU VAR?
SELECT hasta_id, COUNT(*) as randevu_sayisi
FROM randevu
GROUP BY hasta_id
ORDER BY randevu_sayisi DESC;

-- HANG� DOKTORDAN EN AZ RANDEVU ALINMI�TIR?
SELECT doktor_id, COUNT(*) as randevu_sayisi
FROM randevu
GROUP BY doktor_id
ORDER BY randevu_sayisi ASC;

--HANG� ETKEN MADDE EN �OK KULLANILMI�TIR
SELECT etken_madde, COUNT(*) AS sayisi FROM ilac
GROUP BY etken_madde 
ORDER BY COUNT(*) DESC;

--HANG� DOKTORUN EN �OK HASTAYI MUAYENE ETT���N� G�STEREN SORGU           //COUNT(*) i�levi, verilen s�tunun de�erlerinin say�s�n� d�nd�r�r, bu nedenle her doktor i�in ka� muayene oldu�unu sayar.
SELECT doktor_id, COUNT(*) AS hasta_sayisi
FROM muayene
GROUP BY doktor_id
ORDER BY hasta_sayisi DESC;

--UZMANLIK ALANI ORTODONT� OLAN DOKTORUN MUAYENE ETT��� HASTA SAYISI 3 OLAN DOKTORU GET�REN SORGU 
SELECT * FROM doktor
WHERE uzmanl�k = 'Ortodonti'
AND doktor_id IN (SELECT doktor_id FROM muayene GROUP BY doktor_id HAVING COUNT(*) = 3);

--Hasta id=220 OLAN HASTANIN KULLANDI�I �LACIN B�LG�LER�
SELECT * FROM ilac WHERE hasta_id = 220;

--EN �OK HANG� TEDAV�N�N YAPILDI�I SORGUSU
SELECT tedavi, COUNT(*) as tedavi_sayisi FROM te�his
GROUP BY tedavi
ORDER BY tedavi_sayisi DESC;

--DOKTOR VE TEKN�SYENLER�N TOPLAM MAA�LARI VE ORTALAM MAA�LARI
SELECT 'doktor' AS pozisyon, SUM (doktor_maas) AS toplam_maas, AVG (doktor_maas) AS ortalama_maas
FROM doktor
UNION
SELECT 'teknisyen' AS pozisyon, SUM (teknisyen_maas) AS toplam_maas, AVG (teknisyen_maas) AS ortalama_maas
FROM teknisyen;

-- MAA�I ERKEK DOKTORLARIN MAA�LARIN ORTALAMALARINDAN FAZLA OLAN KADIN DOKTORLAR
select ad,cinsiyet,soyad,doktor_maas  from doktor
where cinsiyet='K'
group by ad,cinsiyet,soyad,doktor_maas
having doktor_maas > (Select avg(doktor_maas) as s from doktor where cinsiyet='E' );

-- TEL TEDAV�S� OLACAK HASTALARIN B�LG�LER�(cinsiyet, ad)
SELECT hasta.ad, hasta.cinsiyet
FROM hasta
WHERE hasta.hasta_id IN (SELECT te�his.hasta_id FROM te�his WHERE te�his.tedavi = 'Tel Tedavisi');

-- ADI Aleda OLAN DOKTORUN MAA�INI G�STEREN SORGU
SELECT doktor_maas
FROM doktor
WHERE ad = 'Aleda';

--BELL� B�R HASTANIN B�LG�LER�N� GET�R�R
SELECT tc_kimlik,tel_no,dogum_tarihi
FROM hasta
WHERE ad = 'Kubilay' and cinsiyet ='E'
AND soyad = 'Ova'

--HANG� DOKTORUN MAA�I EN Y�KSEK VE EN D���KT�R?
SELECT doktor_id, doktor_maas
FROM doktor
WHERE doktor_maas = ( SELECT MAX (doktor_maas) FROM doktor);

SELECT MIN (doktor_maas) AS en_d���k_doktor_maas FROM doktor;

--SENEM VE CENK'�N (DOKTORLAR) HANG� TEDAV�LER� YAPTIKLARINI G�STEREN SORGU  
SELECT * FROM te�his WHERE doktor_id IN (SELECT doktor_id FROM doktor WHERE ad IN ('Senem', 'Cenk'));

--EN YA�LI HASTANIN B�LG�LER�
SELECT ad, soyad, dogum_tarihi
FROM hasta
WHERE dogum_tarihi = (SELECT MIN(dogum_tarihi) FROM hasta);

--EN GEN� HASTANIN B�LG�LER�
SELECT ad, soyad, dogum_tarihi
FROM hasta
WHERE dogum_tarihi = (SELECT MAX(dogum_tarihi) FROM hasta);

--EN Y�KSEK MAA�I ALAN DOKTORUN UZMANLK ALANI NED�R
SELECT uzmanl�k, doktor_maas
FROM doktor
WHERE doktor_maas = (SELECT MAX(doktor_maas) FROM doktor);


--ETKEN MADDES� AYNI OLAN �LA�LAR
SELECT ilac_id, ilac_ad, fiyat, son_kullanma_tarihi, etken_madde
FROM ilac
WHERE etken_madde IN (SELECT etken_madde FROM ilac GROUP BY etken_madde HAVING COUNT(*) > 1);

-- doktor_id =1 OLAN DOKTORUN AD VE SOYADINI G�NCELLEMEK ���N KULLANILDI
UPDATE hasta
SET ad = 'Kubilay', soyad ='Ova'
WHERE hasta_id = 1;

--B�R DOKTORUN MAA�INI G�NCELLEME
UPDATE doktor
SET doktor_maas = 35500
WHERE doktor_id = 1;

--F�YATI 100 TL'DEN AZ OLAN �LA�LAR
SELECT ilac_ad, etken_madde,fiyat FROM ilac WHERE fiyat < 100.00;

-- TC K�ML�K NO'SU 10875639821 OLAN K���N�N B�LG�LER�N� G�STEREN SORGU
SELECT*FROM hasta
WHERE tc_kimlik = 10875639821;

-- ADI KARYA OLAN HASTALARIN B�LG�LER�N� G�STEREN SORGU
SELECT * FROM hasta WHERE ad = 'Karya';

--20000 �ST�NDE MAA� ALAN KADIN DOKTORLAR
SELECT ad, soyad,doktor_maas FROM doktor
WHERE doktor_maas  > 20000 AND cinsiyet = 'K';

--9000 ALTINDA MAA� ALAN ERKEK TEKN�SYENLER
SELECT ad, soyad,teknisyen_maas FROM teknisyen
WHERE teknisyen_maas < 9000 AND cinsiyet = 'E';

--2. en y�ksek maa� alan doktor
SELECT ad, soyad, doktor_maas FROM doktor
WHERE doktor_maas = ( SELECT MAX (doktor_maas) FROM doktor WHERE doktor_maas NOT IN ( SELECT MAX (doktor_maas) FROM doktor));

SELECT doktor_maas,doktor.ad 
from doktor 
WHERE cinsiyet = 'K' 
ORDER BY doktor_maas  DESC;

--doktor_id=5 OLAN DOKTORUN MAA�INDAN DAHA Y�KSEK MAA� ALAN DOKTORLARIN �S�MLER� 
SELECT ad,soyad
FROM   doktor
WHERE  doktor_maas > ALL ( SELECT doktor_maas
                           FROM   doktor
					       WHERE  doktor_id = 5 );
--F�YATI 50TL DEN FAZLA OLUP SON KULLANMA TAR�H� '2023-01-01' VE '2023-12-31' TAR�HLER� ARASINDA OLAN �LA�LAR
SELECT ilac_ad, fiyat,son_kullanma_tarihi FROM ilac WHERE fiyat > 50.00 AND son_kullanma_tarihi BETWEEN '2023-01-01' AND '2023-12-31';

-- DOKTORLARA %10 ZAM YAPILIRSA
SELECT*FROM doktor
UPDATE doktor
SET doktor_maas = doktor_maas * 1.1;

--UZMANLIK ALANI PROTEZ OLAN DOKTORLARA %10 ZAM YAPILMASI
UPDATE doktor
SET doktor_maas = doktor_maas * 1.1
WHERE uzmanl�k = 'Protez';
SELECT *FROM doktor;

-- YAPILAN ZAM GER� ALINIRSA 
UPDATE doktor
SET doktor_maas = doktor_maas / 1.1;
SELECT*FROM doktor;

-- SOY�SM�N�N �LK �K� HARF� 'ER' OLAN HASTALAR
SELECT *FROM hasta
WHERE soyad LIKE 'ER%';

--�LA� ADINDA VEYA ETKEN MADDES�NDE 'PRO' VEYA 'P' OLAN �LA�LAR
SELECT ilac_ad, hasta_id,etken_madde FROM ilac WHERE ilac_ad LIKE '%pro%' OR etken_madde LIKE 'P%';

--SON KULLANMA TAR�H� '2024-05-01' VE '2024-09-30' VEYA '2025-05-01' VE '2025-09-30' TAR�HLER� ARASINDA OLAN �LA�LAR
SELECT ilac_ad, fiyat,son_kullanma_tarihi FROM ilac WHERE son_kullanma_tarihi BETWEEN '2024-05-01' AND '2024-09-30' OR son_kullanma_tarihi BETWEEN '2025-05-01' AND '2025-09-30';

--SIRAYLA DOKTOR VE TEKN�SYENLER 
SELECT ad, soyad, 'doktor' FROM doktor
UNION
SELECT ad, soyad, 'teknisyen' FROM teknisyen;

-- DOKTORLARNI MAA�LARININ ORTALAMASI
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
ORDER BY doktor_maas DESC;                  --ORDER BY ifadesi, sat�rlar�n nas�l s�ralanaca��n� belirtir. S�ra artan (ASC) veya azalan (DESC) olabilir. Varsay�lan olarak, s�ra artand�r.

SELECT ad, soyad, doktor_maas FROM doktor;

-- TEKN�SYENLER�N EN D���K VE EN Y�KSEK  MAA�INI SORGULAR
SELECT teknisyen_id,teknisyen_maas,ad,soyad
FROM teknisyen
WHERE teknisyen_maas=(SELECT MAX(teknisyen_maas)FROM teknisyen);

SELECT teknisyen_id,teknisyen_maas,ad,soyad
From teknisyen
WHERE teknisyen_maas=(SELECT MIN(teknisyen_maas)FROM teknisyen );

SELECT MAX(teknisyen_maas) AS en_y�ksek_teknisyen_maas, MIN(teknisyen_maas) AS en_d���k_teknisyen_maas
FROM teknisyen;

SELECT AVG(teknisyen_maas) AS erkek_teknisyen_maas_ort
FROM teknisyen
WHERE cinsiyet = 'E';

-- DOKTOR OLUP KADIN VE EN Y�KSEK MAA� ALAN K�M ? 
SELECT doktor_id, ad, soyad, doktor_maas
FROM doktor
WHERE cinsiyet = 'K' AND doktor_maas = (	SELECT MAX (doktor_maas)
											FROM doktor
											WHERE cinsiyet = 'K' );

--ERKEK TEKN�SYENLERDEN EN Y�KSEK MAA�I ALAN K�M ?
SELECT teknisyen_id, ad, soyad, teknisyen_maas
FROM teknisyen 
WHERE cinsiyet = 'E' AND teknisyen_maas = (
											SELECT MIN(teknisyen_maas)
											FROM teknisyen 
											WHERE cinsiyet = 'E' );


--T�M MAA�LAR VE FARKLI MAA�LARI G�STEREN SORGU 
SELECT ALL teknisyen_maas
FROM  teknisyen;

SELECT DISTINCT teknisyen_maas 
FROM teknisyen;

-- DOKTORLAR VE MUAYENE ETT�KLER� HASTA SAYILARINI GET�REN SORGU  (SUNUM YAPARKEN SORDU�UNUZ VE YAPTI�IM SORGU)
SELECT doktor.ad, COUNT(*)  AS Muayene_sayisi
FROM hasta
JOIN muayene ON hasta.hasta_id = muayene.hasta_id
JOIN doktor ON muayene.doktor_id = doktor.doktor_id
GROUP BY doktor.ad
ORDER BY Muayene_sayisi DESC;

--DOLGU TEDAV�S� OLAN HASTALAIN ADLARI VE HASTAYA VER�LEN �LA�LAR (AYNI HASTA B�RDEN FAZLA �LA� ALAB�L�R) (SUNUM ESNASINDA SORDU�UNUZ FAKAT YAPAMADI�IM SORGU)
SELECT ad, soyad,ilac.ilac_ad
FROM hasta 
INNER JOIN te�his ON te�his.hasta_id = hasta.hasta_id
INNER JOIN ilac ON ilac.hasta_id = hasta.hasta_id
WHERE te�his.tedavi='dolgu tedavisi'
