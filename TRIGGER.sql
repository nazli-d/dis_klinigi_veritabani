CREATE TRIGGER son_kullanma_tarihi_kontrol
ON ilac
AFTER INSERT, UPDATE
AS
BEGIN
    IF (EXISTS(SELECT * FROM INSERTED WHERE son_kullanma_tarihi < GETDATE())) 
	BEGIN
	   PRINT('ÝLACIN SON KULLANMA TARÝHÝ GEÇMÝÞ OLAMAZ!');
       ROLLBACK TRANSACTION;
    END 
END

INSERT INTO ilac (ilac_id,hasta_id, ilac_ad, fiyat, son_kullanma_tarihi, etken_madde) VALUES (653,270, 'Parol', 95.99,'2022-04-27', 'Asetilsalisilik asit');


CREATE TRIGGER tarih_kontrol
ON muayene
AFTER INSERT
AS
BEGIN
  IF (SELECT muayene_tarihi FROM inserted) < GETDATE()
  BEGIN
    PRINT('MUAYENE TARÝHÝ BUGÜNÜN TARÝHÝ VEYA DAHA ÝLERÝSÝ OLMALIDIR!');
	ROLLBACK TRANSACTION;
  END
END;

INSERT INTO muayene (muayene_id, doktor_id, teknisyen_id, hasta_id,teþhis_id, muayene_tarihi, muayene_saati) VALUES (489, 22, 112, 211,950,'2022-01-01', '08:30:00');


CREATE TRIGGER tc_kimlik_kontrol
ON hasta
AFTER INSERT
AS
BEGIN
  IF EXISTS (SELECT * FROM hasta WHERE tc_kimlik = (SELECT tc_kimlik FROM inserted))
  BEGIN
    PRINT('GÝRÝLEN TC KÝMLÝK NUMARASI DAHA ÖNCE KAYDEDÝLMÝÞ!');
	ROLLBACK TRANSACTION;
  END
END;

INSERT INTO hasta (hasta_id, doktor_id, teknisyen_id, ad, soyad, tc_kimlik, cinsiyet, tel_no, dogum_tarihi)
VALUES (290, 10, 112, 'Sinan', 'Arýn', '13469728640', 'E', '05473297451', '1981-03-12');
