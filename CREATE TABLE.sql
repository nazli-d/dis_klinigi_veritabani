CREATE TABLE doktor
(
doktor_id   INTEGER     NOT NULL,
ad          VARCHAR(30) NOT NULL,
soyad       VARCHAR(30) NOT NULL,
cinsiyet    CHAR(1)     NOT NULL,
doktor_maas INTEGER     NOT NULL,
uzmanlik    VARCHAR(30) NOT NULL,

PRIMARY KEY (doktor_id),
CHECK (cinsiyet = 'E' OR cinsiyet = 'K'),
CHECK (uzmanlik IN ('Ortodonti','Periodontoloji','Ağız-Diş ve Çene Cerrahisi','Endodonti','Protez'))
);


CREATE TABLE teknisyen
(
teknisyen_id   INTEGER     NOT NULL,
ad             VARCHAR(30) NOT NULL,
soyad          VARCHAR(30) NOT NULL,
cinsiyet       CHAR(1)     NOT NULL,
teknisyen_maas INTEGER     NOT NULL,

PRIMARY KEY (teknisyen_id),
CHECK (cinsiyet = 'E' OR cinsiyet = 'K')
);


CREATE TABLE hasta
(
hasta_id     INTEGER     NOT NULL,
doktor_id    INTEGER     NOT NULL,
teknisyen_id INTEGER     NOT NULL,
ad           VARCHAR(30) NOT NULL,
soyad        VARCHAR(30) NOT NULL,
tc_kimlik    BIGINT      NOT NULL,
cinsiyet     CHAR(1)     NOT NULL,
tel_no       CHAR(11)    NOT NULL,
dogum_tarihi DATE        NOT NULL,

PRIMARY KEY (hasta_id),
CONSTRAINT hasta_fk1 FOREIGN KEY (doktor_id) REFERENCES doktor (doktor_id),
CONSTRAINT hasta_fk2 FOREIGN KEY (teknisyen_id) REFERENCES teknisyen (teknisyen_id),
CHECK (cinsiyet = 'E' OR cinsiyet = 'K'),
CHECK (LEN ( tel_no ) = 11 ),
CHECK (LEN ( tc_kimlik ) = 11 ),
CHECK ( tc_kimlik >= 0 )
);


CREATE TABLE randevu
(
randevu_id     INTEGER      NOT NULL,
doktor_id      INTEGER      NOT NULL,
hasta_id       INTEGER      NOT NULL,
randevu_tarihi DATE         NOT NULL,
randevu_saati  VARCHAR(10)  NOT NULL,

PRIMARY KEY (randevu_id),
CONSTRAINT randevu_fk1 FOREIGN KEY (doktor_id) REFERENCES doktor (doktor_id),
CONSTRAINT randevu_fk2 FOREIGN KEY (hasta_id) REFERENCES hasta (hasta_id),
CHECK (randevu_tarihi > GETDATE())                                        
);

CREATE TABLE muayene
(
muayene_id     INTEGER     NOT NULL,
doktor_id      INTEGER     NOT NULL,
teknisyen_id   INTEGER     NOT NULL,
hasta_id       INTEGER     NOT NULL,
teþhis_id      INTEGER     NOT NULL ,
muayene_tarihi DATE        NOT NULL,
muayene_saati  VARCHAR(10) NOT NULL,

PRIMARY KEY (muayene_id),
CONSTRAINT muayene_fk1 FOREIGN KEY (doktor_id) REFERENCES doktor (doktor_id),
CONSTRAINT muayene_fk2 FOREIGN KEY (teknisyen_id) REFERENCES teknisyen (teknisyen_id),
CONSTRAINT muayene_fk3 FOREIGN KEY (hasta_id) REFERENCES hasta (hasta_id)
);

CREATE TABLE ilac
(
ilac_id             INTEGER     NOT NULL,
hasta_id            INTEGER     NOT NULL,
ilac_ad             VARCHAR(30) NOT NULL,
fiyat               FLOAT       NOT NULL,
son_kullanma_tarihi DATE        NOT NULL,
etken_madde         VARCHAR(50) NOT NULL,

PRIMARY KEY (ilac_id)
);


CREATE TABLE teşhis
(
Teşhis_id INTEGER     NOT NULL,
ilac_id   INTEGER     NOT NULL,
hasta_id  INTEGER     NOT NULL,
doktor_id INTEGER     NOT NULL,
tedavi    VARCHAR(30) NOT NULL,

PRIMARY KEY (teşhis_id),
CONSTRAINT teşhis_fk4 FOREIGN KEY (hasta_id) REFERENCES hasta (hasta_id),
CONSTRAINT teşhis_fk2 FOREIGN KEY (doktor_id)REFERENCES doktor(doktor_id),
CONSTRAINT teşhis_fk3 FOREIGN KEY (ilac_id)  REFERENCES ilac  (ilac_id),
CHECK (tedavi IN ('Diş Eti Hastalığı','Protez Diþ Tedavisi','Tel Tedavisi','Dolgu Tedavisi','Diş Beyazlatma','Diş çekimi','Kanal Tedavisi','implant'))
);


CREATE TABLE recete
(
recete_id     INTEGER NOT NULL,
doktor_id     INTEGER NOT NULL,
hasta_id      INTEGER NOT NULL,
ilac_id       INTEGER NOT NULL,
recete_tarihi DATE    NOT NULL,

PRIMARY KEY (recete_id),
CONSTRAINT recete_fk1 FOREIGN KEY (doktor_id) REFERENCES doktor (doktor_id),
CONSTRAINT recete_fk2 FOREIGN KEY (hasta_id) REFERENCES hasta (hasta_id),
CONSTRAINT recete_fk3 FOREIGN KEY (ilac_id) REFERENCES ilac (ilac_id),
CHECK (recete_tarihi > GETDATE())
);

CREATE TABLE fatura
(
fatura_id     INTEGER NOT NULL,
hasta_id      INTEGER NOT NULL,
recete_id     INTEGER NOT NULL,
tutar         FLOAT   NOT NULL,
fatura_tarihi DATE    NOT NULL,

PRIMARY KEY (fatura_id),
CONSTRAINT fatura_fk1 FOREIGN KEY (hasta_id) REFERENCES hasta (hasta_id),
CONSTRAINT fatura_fk2 FOREIGN KEY (recete_id) REFERENCES recete (recete_id),
CHECK (fatura_tarihi >= GETDATE())
);


CREATE TABLE odeme
(
odeme_id     INTEGER NOT NULL,
hasta_id     INTEGER NOT NULL,
fatura_id    INTEGER NOT NULL,
odeme_durumu VARCHAR(30),
odeme_tipi   VARCHAR(30),
odeme_tarihi DATE ,
odeme_tutari FLOAT   NOT NULL ,

PRIMARY KEY (odeme_id),
CONSTRAINT odeme_fk FOREIGN KEY (fatura_id) REFERENCES fatura (fatura_id),
CHECK (odeme_durumu = 'ödenmedi' OR odeme_durumu = 'bekleniyor' OR odeme_durumu = 'ödendi'),
CHECK (odeme_tipi = 'Online Banka' OR odeme_tipi = 'Kart' OR odeme_tipi = 'Nakit')
);
