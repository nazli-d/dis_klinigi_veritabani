# DİŞ KLİNİĞİ VERİ TABANI (DENTAL CLİNİC MANAGEMENT, HOSPİTAL MANAGEMENT)

* Proje : Diş Kliniği veri tabanının modellenmesi
* Kullanılan veri tabanı [Microsoft SQL Server Management Studio 18](https://www.microsoft.com/tr-tr/sql-server/sql-server-downloads) ' dir
* ER Diyagram Çizimi için [draw.io](https://app.diagrams.net/) kullanılmıştır.

# Veri tabanı yapısı ve özellikleri
Bu proje, bir diş kliniğinin veritabanını oluşturmak ve yönetmek amacıyla geliştirilmiştir. Aşağıda, projede kullanılan tablolar ve ilişkiler hakkında bilgiler yer almaktadır.


| Tablolar     | İşlevi        |
| -------------| ------------- |
|doktor	|Diş doktorlarının bilgilerini içeren tablo.
|teknisyen|Diş teknisyenlerinin bilgilerini içeren tablo.
|hasta	|Hasta bilgilerini içeren tablo.
|randevu|Randevu bilgilerini içeren tablo.
|muayene	|Muayene bilgilerini içeren tablo.
|ilac	|İlaçların bilgilerini içeren tablo.
|teşhis	|Teşhislerin (tanı) bilgilerini içeren tablo.
|recete	|Reçetelerin bilgilerini içeren tablo.
|fatura|Faturaların bilgilerini içeren tablo.
|odeme	|Ödemelerin bilgilerini içerir.


### ER Diyagram (Entity Relationship Diagram)

---

![](https://github.com/nazli-d/dis_klinigi_veritabani/blob/main/ER%20diyagram.jpg)

---

### UML Class Diyagram (Unified Modeling Language) 

---

![](https://github.com/nazli-d/dis_klinigi_veritabani/blob/main/UML%20DIAGRAM.jpg)

---
### Veri tabanında bulunan nesneler

*	10 adet Tablo
*	3 adet Trigger
*	1 adet uml diyagramı
*	1 adet ER diyagramı
*	85 adet tablolarla ilişkili sorgu (query)
*	Veri girişleri
