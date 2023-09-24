Sveučilište Jurja Dobrile u Puli

Fakultet informatike u Puli

<img src="https://cdn.discordapp.com/attachments/931310318687236126/1064306501977645076/Unipu-logo-lat.png"   style="height:200px" />

Dokumentacija uz projektni zadatak

Sustav za upravljanje vojnim oružanim snagama

Tim 9

Izradili: Leo Matošević, Mateo Kocev, Stevan Čorak, Filippo Bubić, Jan Božac, David Kovačević

Studijski smjer: Informatika

Kolegij: Baza podataka II

Mentor: doc. dr. sc. Goran Oreški

____

## Stevan Čorak

## Uvod

U priloženoj dokumentaciji prezentirat ćemo naš projektni zadatak iz kolegija Baze podataka 2. Tema projekta je "Sustav za upravljanje vojnim oružanim snagama". Kao prvi korak izrade baze podataka došli smo do zaključka da cijelo ukupna baza podataka neće biti realistična depikcija cijele vojske, već će prikazivat najvažnije aspekte. Pod najvažnije aspekte odnose se podatci kao što su: *osoblje*, *tura*, *misija*, *vozila*, *oprema*, *trening*, *liječenje*,*lokacija*, *sektor*. Razlog iz kojeg smo odlučili ići "*nerealističnom*" metodom je zbog gotovo nemogućeg pronalaska klasificiranih vojnih podataka. 

Cilj našeg projekta je prikazat pojednostavljenu verziju svih ključnih podataka svake svjetske vojske. Unatoč našoj namjeri da pojednostavimo cijelu bazu podataka, naišli smo na problem pri upisivanju osoblja unutar baze podataka. Pošto smo smatrali da 30-50 osoba nije zadovoljavajuća količina ljudi da stvorimo kompleksnu vojnu strukturu. Zbog toga smo stvorili *python* kod koji generira osoblje po *MySQL* standardu, *python* kod ćemo prikazat i objasnit kasnije u projektu. 

## ER Dijagram

____

<img src="https://cdn.discordapp.com/attachments/912763032965369886/1064248436137930782/Untitled_1.png"/>

**Opis dijagrama** 

Skup entiteta **popravak** povezan je s ternarnom vezom s skupom entiteta **vozilo** i skupom entiteta **misija**. Odnos između ta tri skupa je:

-  unutar jedne **misije** može se nalazit više **vozila**, dok se jedno **vozilo** može koristit na više **misija**, odnos veza je više naprema više
-  iz tog razloga pojavio bi se novi skup entiteta ***vozilo_na_misiji***
- skup entiteta **popravak** se nadovezuje s novonastalim skupom entiteta ***vozilo_na_misiji*** s vezom jedan naprema više , pošto se može više **popravaka** izvršit nad jednim **vozilom_na_misiji** 
- također iz odnosa entiteta ***vozilo_na_misiji*** i **misije** možemo izlučit podatak *vrijeme_upotrebe* za pojedino vozilo 

Skup entiteta **vozila** povezana su s vezom više naprema više s skupom entiteta **tura**, jer jedno **vozilo** može biti na više **tura**, dok unutar jedne **ture** možemo pronaći više **vozila**. Iz ovog odnosa više na više dolazimo do stvaranja nove tablice ***vozilo_na_turi***. Iz ovog odnosa možemo izvući *vrijeme_upotrebe* pojedinog **vozila** unutar svake **ture**.      

Skup entiteta **tura** povezana su s vezom više na više s skupom entiteta **osoblja**, jer jedna **osoba**  može biti na više **tura**, dok unutar jedne **ture** možemo pronaći više **osoblja**. Iz ovog odnosa više na više dolazimo do stvaranja nove tablice ***osoblje_na_turi***.    

Skup entiteta **osoblje** povezan je s skupome entiteta **liječenje** više naprema jedan, jer možemo imat više **osoblja** od jednom na jednom **liječenju**, dok unutar jednog **liječenja** možemo imat više **osoblja**. Iz ovog odnosa možemo izlučit podatak *dostupno_osoblje*, tako što evidentiramo *id* od **osoblja** i *id_osoblje* od **liječenja** kako bi na kraju dobili podatak koliko je **osoblja** na **liječenju** i s tim podatkom dolazimo do *dostupnog_osoblja*.

Skup entiteta **lokacija** povezan je s skupom entiteta **sektor** više naprema jedan,  jer možemo stacionirat više **sektora** unutar jedne **lokacije**, dok unutar jedne **lokacije** možemo stacionirat više **sektora**.

Skup entiteta **misija** povezan je s skupom entiteta **lokacija** više naprema jedan,  jer možemo izvršit više **misija** unutar jedne **lokacije**, dok unutar jedne **lokacije** možemo izvršit više **misija**.

Skup relacija **osoblje** povezan je s skupom entiteta **trening** više naprema više, jer unutar jednog **trening** može sudjelovat više **osoblja**, dok jedna **osoba** može sudjelovat na više **treninga**. Iz tog razloga stvara se novi skup entiteta ***osoblje_na_treningu***

Skup entiteta **misija** povezan je s ternarnom vezom s skupom entiteta **osoblje** i skupom entiteta **oprema**. Odnos između ta tri skupa je:

-  unutar jedne **misije** može se nalazit više **osoblja**, dok se jedna **osoba** može nalazit na više **misija**

-  iz tog razloga pojavio bi se novi skup entiteta ***osoblje_na_misiji***

- za jednu **osobu** možemo izdat više **opreme**, dok jedna vrstu **opreme** se može izdat za više **osoba**.

- iz tog razloga se pojavio bi se  novi skup entiteta ***izdana_oprema***                   

  

Skup entiteta **lokacija** povezan je s ternarnom vezom s skupom entiteta **trening** i skupom entiteta **lijecenje**. Odnos između ta tri skupa je: 

-  pošto smo spomenuli da je relacija ***osoblje_na_treningu*** nastala iz relacije **trening** i **osoblje** zbog odnosa više naprema više, relacija ***osoblje_na_treningu*** povezana je s vezom više naprema jedan s **lokacijom**, pošto unutar jedne **lokacije** mogu izvršiti više **treninga** na kojem je ***osoblje_na_treningu***  
- na jednoj **lokaciji** se izvodi više **liječenje**, dok se više **liječenja** izvodi na jednoj **lokaciji**

## Jan Božac

## Tablice

____

**Relacija sektor**:
Ima sve sektore vojske

- id podatak tipa integer, primarni ključ unutar relacije
- Naziv podatak tipa varchar limitiran na 60 znakova
- datum_osnivanja podatak tipa DATE 
- opis podatak tipa TEXT koji je korišten za velike količine znakova
- Ograničenje not null označava da podatak ne smije biti null tip podatka.
- CONSTRAINT služi za dodavanje ograničenja 
- ck_proracun mora biti veći ili jednak nuli
- ck_naziv mora biti UNIQUE znaci ako nije jedinstven će nam javiti gresku

```mysql
CREATE TABLE sektor(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(60) NOT NULL,
    datum_osnivanja DATE NOT NULL,
    opis TEXT NOT NULL,
    ukupni_proracun DECIMAL(12,2) NOT NULL
);
 -- DROP TABLE sektor;
ALTER TABLE sektor
	ADD CONSTRAINT ck_proracun CHECK(ukupni_proracun>=0),
    ADD CONSTRAINT ck_naziv UNIQUE(naziv);
```

**Relacija lokacija**:
Sadrži sve lokacije

- id_sektor koji je integer i referencira se na sektor(id) kao FOREIGN KEY
  zemljopisna_duzina koja je DECIMAL kao i zemljopisna_sirina

- ck_duzina, ck_sirina i ck_naziv su UNIQUE

```mysql
CREATE TABLE lokacija(
    id INTEGER PRIMARY KEY,
    id_sektor INTEGER,
    naziv VARCHAR(60) NOT NULL,
    zemljopisna_duzina DECIMAL(10, 7) NOT NULL,
    zemljopisna_sirina DECIMAL(10, 7) NOT NULL,
    FOREIGN KEY (id_sektor) REFERENCES sektor(id)
);
-- DROP TABLE lokacija;
ALTER TABLE lokacija
	ADD CONSTRAINT ck_duzina UNIQUE(zemljopisna_duzina),
    ADD CONSTRAINT ck_sirina UNIQUE(zemljopisna_sirina),
    ADD CONSTRAINT ck_naziv UNIQUE(naziv);
```

**Relacija osoblje**:
Sadrži sve informacije o osoblju koje osim njihovih id-eva su:

- ime
- prezime 
- cin(čin) 
- datum_rodenja 
- datum_uclanjenja 
- status_osoblja 
- krvna_grupa  
- ocjena

- imamo FOREIGN KEY koji veže id_sektor sa id na tablici sektor

- CONSTRAINT ck_ocijena koji nam provjerava da je ocjena od jedan do pet

```mysql
CREATE TABLE osoblje(
    id INTEGER PRIMARY KEY,
    id_sektor INTEGER NOT NULL,
    ime VARCHAR(30) NOT NULL,
    prezime VARCHAR(30) NOT NULL,
    cin VARCHAR(20) NOT NULL,
    datum_rodenja DATE NOT NULL,
    datum_uclanjenja DATE NOT NULL,
    status_osoblja VARCHAR(50) NOT NULL,
    krvna_grupa CHAR(3) NOT NULL,
    ocjena INTEGER NOT NULL,
    FOREIGN KEY (id_sektor) REFERENCES sektor(id) ON DELETE CASCADE
);
-- DROP TABLE osoblje;
ALTER TABLE osoblje 
    ADD CONSTRAINT ck_ocijena CHECK(ocjena>=1 AND ocjena<=5);
```

**Relacija tura**:
Sadrži sve informacije o turi koje osim njihovih id-eva su:

- naziv
- vrsta_ture 
- vrijeme_pocetka
- vrijeme_kraja

- CONSTRAINT ck_naziv služi da bi naziv bio jedinstven dok vrs_tr provjerava dali je tura Mirovna ili Vojna

```mysql
CREATE TABLE tura(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(50) NOT NULL,
    vrsta_ture VARCHAR(69) NOT NULL,
    vrijeme_pocetka DATETIME NOT NULL,
    vrijeme_kraja DATETIME
);
-- DROP TABLE tura;
ALTER TABLE tura
	ADD CONSTRAINT ck_naziv UNIQUE(naziv),
	ADD CONSTRAINT vrs_tr CHECK(vrsta_ture = "Mirovna tura" or vrsta_ture = "Vojna tura");
    select * from tura;
```

**Relacija misija**:
Sadrži sve informacije o misiji kao što su:

- id 
- naziv 
- vrijeme pocetka i kraja 
- FOREIGN KEY id_lokacija koja referencira id od lokacije 
- FOREIGN KEY id_tura koji referencira id od ture
- ishod misije  
- trosak

- CONSTRAINT ck_trosak koji provjerava da uvijek bude trošak misije, te naziv_misija_ck da naziv bude jedinstven

```mysql
CREATE TABLE misija(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(50) NOT NULL,
    vrijeme_pocetka DATETIME NOT NULL,
    vrijeme_kraja DATETIME,
    id_lokacija INTEGER NOT NULL,
    id_tura INTEGER NOT NULL,
    ishod TEXT,   
    trosak_misije NUMERIC(15, 2) NOT NULL,
    FOREIGN KEY (id_lokacija) REFERENCES lokacija(id) ON DELETE CASCADE,
    FOREIGN KEY (id_tura) REFERENCES tura(id) ON DELETE CASCADE
);
-- DROP TABLE misija;

ALTER TABLE misija
	ADD CONSTRAINT ck_trosak CHECK(trosak_misije>=0),
    ADD CONSTRAINT naziv_misija_ck UNIQUE(naziv);
```

**Relacija osoblje_na_misiji**:
Služi kao povezivač osoblja sa misijom tako što referencira id od osoblja i id od misije

```mysql
CREATE TABLE osoblje_na_misiji(
    id INTEGER PRIMARY KEY,
    id_osoblje INTEGER NOT NULL,
    id_misija INTEGER NOT NULL,
    FOREIGN KEY (id_osoblje) REFERENCES osoblje(id) ON DELETE CASCADE,
    FOREIGN KEY (id_misija) REFERENCES misija(id) ON DELETE CASCADE
);
-- DROP TABLE osoblje_na_misiji;
```

**Relacija osoblje_na_turi**:
Služi kao povezivač osoblja sa turom tako što referencira id od osoblja i id od ture

```mysql
CREATE TABLE osoblje_na_turi(
    id INTEGER PRIMARY KEY,
    id_osoblje INTEGER NOT NULL,
    id_tura INTEGER NOT NULL,
    datum_pocetka DATETIME NOT NULL,
    datum_kraja DATETIME,
    FOREIGN KEY (id_osoblje) REFERENCES osoblje(id) ON DELETE CASCADE,
    FOREIGN KEY (id_tura) REFERENCES tura(id) ON DELETE CASCADE
);
-- DROP TABLE osoblje_na_turi;
```

**Relacija vozila**:
Ovdje su svi podatci o vozilima:

- id
-  naziv
- vrsta 
- ukupna_kolicina 
-  kapacitet

```mysql
CONSTRAINT ck_uk_kolicina i ck_kapacitet provjeravaju da ukupna_kolicina i kapacitet nisu nula te javljaju grešku u suprotnom

CREATE TABLE vozila(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(60) NOT NULL,
    vrsta VARCHAR(50) NOT NULL,
    ukupna_kolicina INTEGER NOT NULL,
    kapacitet INTEGER NOT NULL

);
-- DROP TABLE vozila;
ALTER TABLE vozila
	ADD CONSTRAINT ck_uk_kolicina CHECK(ukupna_kolicina>0),
    ADD CONSTRAINT ck_kapacitet CHECK(kapacitet>0);
```

**Relacija vozilo_na_misiji**:
Povezivač vozila i misije pomću FOREIGN KEY koji povezuje tablice misija i vozila pomocu njihovih id-eva
CONSTRAINT ck_kolicina1 provjerava da je količina veća od nule.

```mysql
CREATE TABLE vozilo_na_misiji(
    id INTEGER PRIMARY KEY,
    id_vozilo INTEGER NOT NULL,
    kolicina INTEGER NOT NULL,
    id_misija INTEGER NOT NULL,
    FOREIGN KEY (id_vozilo) REFERENCES vozila(id) ON DELETE CASCADE,
    FOREIGN KEY (id_misija) REFERENCES misija(id) ON DELETE CASCADE
);
-- DROP TABLE vozilo_na_misiji;
ALTER TABLE vozilo_na_misiji
	ADD CONSTRAINT ck_kolicina1 CHECK(kolicina>0);
```

**Relacija vozilo_na_turi**:
Povezuje vozila i turu uz FOREIGN KEY na id-eve te ima i id_odgovorni koji sluzi kako bi se i osoblje_na_turi povezalo sa tablicom vozila

- CONSTRAINT ck_iz_kolicina2 pazi da kolicina nije 0 te javlja grešku u suprotnome

```mysql
CREATE TABLE vozilo_na_turi(
    id INTEGER PRIMARY KEY,
    id_vozilo INTEGER,
    id_tura INTEGER,
    id_odgovorni INTEGER NOT NULL,
    kolicina INTEGER,
    FOREIGN KEY (id_vozilo) REFERENCES vozila(id) ON DELETE CASCADE,
    FOREIGN KEY (id_tura) REFERENCES tura(id) ON DELETE CASCADE,
    FOREIGN KEY (id_odgovorni) REFERENCES osoblje_na_turi(id) ON DELETE CASCADE
);
-- DROP TABLE vozilo_na_turi;
ALTER TABLE vozilo_na_turi
	ADD CONSTRAINT ck_kolicina2 CHECK(kolicina>0);
```

**Relacija popravak**:
Tablica koja sadrži sve informacije o popravku poput:

- id 
- id_vozilo_na_misiji FOREIGN KEY referencira id od vozilo_na_misiji 
- opis_stete 
- pocetak_popravka  
- kraj_popravka  
- trošak_popravak

- CONSTRAINT ck_popravak gleda da trosak_popravka nije nula te javlja grešku

```mysql
CREATE TABLE popravak(
    id INTEGER PRIMARY KEY,
    id_vozilo_na_misiji INTEGER NOT NULL,
    opis_stete TEXT NOT NULL,
    pocetak_popravka DATETIME NOT NULL,
    kraj_popravka DATETIME,
    trosak_popravka NUMERIC(15,2) NOT NULL,
    FOREIGN KEY (id_vozilo_na_misiji) REFERENCES vozilo_na_misiji(id) ON DELETE CASCADE
);
-- DROP TABLE popravak;
ALTER TABLE popravak
	ADD CONSTRAINT ck_popravak CHECK(trosak_popravka>=0);
```

**Relacija oprema**:
Sve informacije o opremi kao: 

- id
- naziv 
- vrsta 
- ukupna_kolicina

- CONSTRAINT ck_uk_kolicina1 provjerava da ukupna_kolicina nije nula.

```mysql
CREATE TABLE oprema(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(50) NOT NULL,
    vrsta VARCHAR(50) NOT NULL,
    ukupna_kolicina INTEGER NOT NULL
);
-- DROP TABLE oprema;
ALTER TABLE oprema
	ADD CONSTRAINT ck_uk_kolicina1 CHECK(ukupna_kolicina>0);
```

**Relacija izdana_oprema**:
Sadrži informacije od opremi koja je izdana kao: 

- id 
- id_oprema(id od opreme) 
- id_osoblje_na_misiji (kojem je osoblju dodjeljena oprema)
- izdana_kolicina

- CONSTRAINT ck_iz_kolicina provjerava da izdana_kolicina je veća od nule

```mysql
CREATE TABLE izdana_oprema(
    id INTEGER PRIMARY KEY,
    id_oprema INTEGER NOT NULL,
    id_osoblje_na_misiji INTEGER NOT NULL,
    izdana_kolicina INTEGER NOT NULL,         
    FOREIGN KEY (id_oprema) REFERENCES oprema(id) ON DELETE CASCADE,
    FOREIGN KEY (id_osoblje_na_misiji) REFERENCES osoblje_na_misiji(id) ON DELETE CASCADE
);
-- DROP TABLE izdana_oprema;

ALTER TABLE izdana_oprema
	ADD CONSTRAINT ck_iz_kolicina CHECK(izdana_kolicina>0);
```

**Relacija trening**:
Informacije o treningu kao njegovo:

- vrijeme_pocetka 
- vrijeme_kraja kraja 
- lokacija održavanja i naravno njegov id

```mysql
CREATE TABLE trening(
    id INTEGER PRIMARY KEY,
    vrijeme_pocetka DATETIME NOT NULL,
    vrijeme_kraja DATETIME NOT NULL,
    id_lokacija INTEGER NOT NULL,
    FOREIGN KEY (id_lokacija) REFERENCES lokacija(id) ON DELETE CASCADE
);
-- DROP TABLE trening;
```

**Relacija osoblje_na_treningu**:
Informacije o osoblju na treningu kao:

- id 
- id_osoblje(id od osoblja) 
- id_trening(id od treninga)   
- performans koji vojnici odrade na treningu

- CONSTRAINT ck_per provjerava da je performans uvijek veći od nule i manji od jedanaest

```mysql
CREATE TABLE osoblje_na_treningu(
	id INTEGER PRIMARY KEY,
	id_osoblje INTEGER NOT NULL,
	id_trening INTEGER NOT NULL,
	performans INTEGER NOT NULL,
	FOREIGN KEY (id_osoblje) REFERENCES osoblje(id) ON DELETE CASCADE,
	FOREIGN KEY (id_trening) REFERENCES trening(id) ON DELETE CASCADE
);
-- DROP TABLE osoblje_na_treningu;
ALTER TABLE osoblje_na_treningu
	ADD CONSTRAINT ck_per CHECK(performans >=0 AND performans<11);
```

**Relacija lijecenje**:
Podatci o liječenju kao: 

- id 
- id od osoblja 
- njihov status 
- pocetak_lijecenja  
- kraj_lijecenja  
- opis_ozlijede 
- trosak_lijecenja

- CONSTRAINT ck_lije provjerava da trosak liječenja je uvijek veći od nule

```mysql
CREATE TABLE lijecenje(
    id INTEGER PRIMARY KEY,
    id_osoblje INTEGER,
    status_lijecenja TEXT NOT NULL,  
    pocetak_lijecenja DATETIME NOT NULL,
    kraj_lijecenja DATETIME,
    opis_ozljede TEXT NOT NULL,
    trosak_lijecenja NUMERIC(15,2),
    FOREIGN KEY (id_osoblje) REFERENCES osoblje(id) ON DELETE CASCADE
);
-- DROP TABLE lijecenje;
ALTER TABLE lijecenje
	ADD CONSTRAINT ck_lije CHECK(trosak_lijecenja>=0);
```

> Ovaj upit će nam dati sva imena, prezimena i id ozlijeđenih vojnika kojima je liječenje koštalo više od 10000
> tako što prvo ćemo selektirati ono što nas zanima da nam se prikaže te zatim povezujemo sve što nam treba pomoću id-eva kroz različite relacije u tablici poput onm.id_osoblje= o.id gdje
> onm.id_osoblje nam je zapravo id jednak id-u od osoblja te ga se samo treba povezati na način da zadamo da ta dva id-a budu jedanki te tako ćemo dobiti većinu konekcija.
> Nakon toga samo moramo zadati uvijet da nam trosak_lijecenja mora iznositi više od 10000

```mysql
-- navedi sva imena i prezimena ozlijedenih vojnika na misiji kojima lijecenje kosta vise od 10000
select o.id,o.ime,o.prezime
from osoblje_na_misiji as onm
inner join osoblje as o 
on onm.id_osoblje= o.id
inner join lijecenje as l
on l.id_osoblje = o.id
where l.trosak_lijecenja>10000;
```

> Ovaj upit će nam dati koliko smaokresa se koristi u misijama od strane mornarice tako što se joinaju id od izdane opreme id i id od opreme što se povezuje na id osoblje na misiji 
> i id od sektora sa sektor id i stavljamo uvijet gdje naziv sektora mora biti Hrvatska ratna mornarica i vrsta opreme Samokres.

```mysql
-- navedi koliko se izdanih samokresa na misiji koristi od strane mornarice
select sum(izo.izdana_kolicina) as samokresa_u_mornarici
from izdana_oprema as izo
inner join oprema as op
on op.id= izo.id_oprema
inner join osoblje_na_misiji as onm
on onm.id=izo.id_osoblje_na_misiji
inner join osoblje as o
on o.id=onm.id_osoblje
inner join sektor as s
on s.id=o.id_sektor
where s.naziv= "Hrvatska ratna mornarica" and op.vrsta="Samokres";
```

> Ovim upitom ćemo dobiti sva vozila na popravku koja ujedno sudjeluju na misiji i treba ih se nabrojati koliko ih je a rezultat mozemo dobiti pomocu spajanja id-eva od vozila na misiji
> sa id-em od vozila i id misije sa id-em od misije te trazimo misiju sa nazivom Vitez.

```mysql
-- Hrvatska ratna mornarica
-- nabroji sva vozila na popravku koja su ujedno i na misiji "Vitez" te ih nabroji koliko ih je
select sum(ukupna_kolicina) as totalni_br
from vozila as v
inner join vozilo_na_misiji as vnm
on v.id=vnm.id_vozilo
inner join misija as m
on m.id=vnm.id_misija
where m.naziv="Vitez";
```

> Ovaj upit pomoću povezivanja id osoblja na misiji sa id-em od osoblja a zatim povezujemo misija id sa id-em od misije te id lokacija sa id-em od lokacije te trazimo lokaciju sa nazivom Ohio

```mysql
-- svo osoblje koje je na misiji u ohiu
Select * 
from osoblje as o
inner join osoblje_na_misiji as onm
on onm.id_osoblje= o.id
inner join misija as m
on onm.id_misija= m.id
inner join lokacija as l
on l.id=m.id_lokacija
where l.naziv="Ohio";
```

> Ovjde tražimo id-eve osoblja krvne grupe 0+ koje je na lijecenju i u sektoru Hrvatska kopnena vojska a to cemo dobiti pomocu povezivanja id osoblja sa id-em od osoblja 
> i id sektorom sa id-em od sektora

```mysql
-- svi idevi osoblja krvne grupe 0+ koje je na lijecenju i u sektoru je "Hrvatska kopnena vojska"
Select l.id_osoblje, o.ime, o.prezime
from lijecenje as l
inner join osoblje as o
on l.id_osoblje= o.id
inner join sektor as s
on s.id=o.id_sektor
where o.krvna_grupa="0+" and s.naziv="Hrvatska kopnena vojska";
```

> Ovdje imamo pogled  kojim cemo uvijek prikazivati sve ture gdje kolicina vozila ce biti veca od 10 a to ostvarujemo pomocu povezivanja id od ture sa id vozilo na turi gdje ce nam
> kolicina vozila na turi biti veca od 10

```mysql
-- pogled koji nam prikazuje sve ture koje imaju kolicinu vozila vecu od 10
CREATE VIEW puno_vozila AS
SELECT t.naziv, vnt.kolicina
FROM tura as t
JOIN vozilo_na_turi as vnt ON t.id = vnt.id_tura
HAVING vnt.kolicina > 10;
```

> Ovaj pogled ce nam pokazati svo osoblje na misiji cija je ocjena 5 a to ostvarujemo povezivanjem tablice osoblje_na_misiji i osoblje sa id-em gdje ocjena u osoblje mora biti 5.

```mysql
-- pogled koji ima svo osoblje na misiji cija je ocjena 5
SELECT ime,prezime,ocjena
FROM osoblje AS o
JOIN osoblje_na_misiji AS onm ON o.id = onm.id_osoblje
HAVING ocjena = 5;
```



## Mateo Kocev

## FUNCKIJE

##### Osnovna Arhitektura funkcija

Koristimo <code> DELIMITER // </code>kako bi promijenili delimiter sa **;** na **//**. Na kraju funkcije Vraćamo delimiter na normalnu vrijednost;

To nam omogućava da SQL učitava naš blok instrukcija kao jednu cijelu naredbu umjesto svaku naredbu zasebno. Na kraju funkcije vračamo delimiter na **;**

Koristimo <code> CREATE FUNCTION ime_funckije() RETURNS [data_type] </code> za stvaranje funkcije. U zagradu pored imena funkcije možemo odrediti ulazne parametre u kojima moramo definirati tip podatka pored imena varijable te sa <code>RETURNS</code> odredimo vrstu podatka koju će funkcija vraćati.

Sa <code>DETERMINISTIC</code> impliciramo da će izlazni podatak biti uvijek isti ako su ulazni podaci i stanje baze podataka isti.

<code>BEGIN</code> i <code>END//</code> određuju početak i kraj funkcije.

##### FUNKCIJA 1 - Jednostavna funkcija koja vraća broj osoblja po sektoru.

U funkciji stvaramo varijablu sa <code>DECLARE broj INTEGER;</code> te sa jednostavnim upitom u nju spremamo ukupnu količinu osoblja u sektoru.

Sa <code>RETURN broj;</code> instrukcijom vraćamo vrijednost spremljenu u varijablu kada je funkcija pozvana sa prikladnim ulaznim parametrom definiranim <code>p_id_sektor INTEGER</code> tijekom stvaranja funkcije

```mysql
CREATE FUNCTION broj_osoblja_u_sektoru( p_id_sektor INTEGER) RETURNS INTEGER
DETERMINISTIC
BEGIN
    DECLARE broj INTEGER;
    
    SELECT COUNT(*) INTO broj 
        FROM osoblje 
            WHERE id_sektor = p_id_sektor;
            
  RETURN broj;
END//
DELIMITER ;
```

##### FUNKCIJA 2 - Prosječna ocjena po sektoru

Sljedeće nam je funkcija bez ulaznih parametra koja vraća string podatak dužine 1000.

Imamo nekoliko pomoćnih varijabli:

1. <code>p_id_sektor</code> nam prima id od sektora te će nam u ovom slučaju služiti kao brojač da bi izašli iz petlje kad prođemo kroz sve sektore
2. <code>broj_osoblja</code> nam prima broj osoblja u određenom sektoru sektoru tj. onaj određen po id-u spremljenom u <code>p_id_sektor</code> varijabli
3. <code>sum_ocjena</code> prima sumu svih ocjena osoblja koji se nalaze u određenom sektoru tj. onaj određen po id-u spremljenom u <code>p_id_sektor</code> varijabli
4. <code>prosjek</code> se koristi za spremanje prosjeka ocjena u određenom sektoru (nepotrebno ali ubačeno za lakše čitanje koda)
5. <code>rezultat</code> varijabla nam služi za spremanje zadnjeg rezultata, sa CONCAT instrukcijom spajamo rezultate svih sektora u jedan dugi string.

Koristimo prvu selekciju da bi dohvatili prvi sektor, tj. sektor sa id-em 1. Otvaramo while petlju te sa dvije selekcije spremamo u varijable broj osoblja u sektoru i sumu ocjena osoblja u sektoru, računamo prosjek, spremamo u rezultat sa CONCAT i povećavamo id sektora za 1.
Proces se ponavlja sve dok se zadovolji uvjet IF naredbe koja provjerava je li id sektora dostigao najveću vrijednost id-a u tablici sektor te napušta loop sa <code>LEAVE myloop;</code> naredbom

```mysql
CREATE FUNCTION prosjecna_ocjena_po_sektoru() RETURNS VARCHAR(1000)
DETERMINISTIC
BEGIN
    DECLARE p_id_sektor INTEGER;
    DECLARE broj_osoblja INTEGER;
    DECLARE sum_ocjena INTEGER;
    DECLARE prosjek DECIMAL(3,2);
    DECLARE rezultat VARCHAR(1000) DEFAULT '';

    SELECT id INTO p_id_sektor
        FROM sektor
        ORDER BY id ASC
        LIMIT 1;

    myloop: WHILE (p_id_sektor <= (SELECT MAX(id) FROM sektor)) DO

        SELECT COUNT(osoblje.id) INTO broj_osoblja 
            FROM osoblje 
                WHERE id_sektor = p_id_sektor;
        SELECT SUM(ocjena) INTO sum_ocjena 
            FROM osoblje 
                WHERE id_sektor = p_id_sektor;
                
        SET prosjek = sum_ocjena / broj_osoblja;

        SET rezultat = CONCAT(rezultat, 'Sektor ', (SELECT id FROM sektor AS s WHERE s.id = p_id_sektor LIMIT 1), ': ', prosjek, '  ');
        
        IF p_id_sektor = (SELECT MAX(id) FROM sektor) THEN
            LEAVE myloop;
        END IF;

        SELECT id INTO p_id_sektor
            FROM sektor WHERE id > p_id_sektor 
                ORDER BY id ASC
                LIMIT 1;
                
    END WHILE myloop;
    
    RETURN rezultat;
END//
```

##### FUNKCIJA 3 - Trošak misija po sektoru

Slično kao prošla funkcija računamo podatke u svakom sektoru te u ovom slučaju računamo troškove misija po sektoru.

umjesto while petlje i upita koji sprema ID u varijablu ovdje sam primijenio kursor koji će fetch komandom uzimati sljedeću vrijednost dostupnu po rezultatu upita

Nakon deklaracije svih varijabla, kursora i handlera otvaramo kursor i petlju. Vrijednost kursora spremamo u <code>p_id_sektor</code> i odmah provjeravamo je li vrijednost varijable gotov postavljena na 1 sa strane continue handlera, ako uvijet if naredbe nije zadovoljen, izvodi se upit koji sumira troškove misija vezane provjeravajući ako osoblje na misiji pripada određenom sektoru. Rezultat se sprema u string te se proces ponavlja dok continue handler ne postavi varijablu gotov na 1 tj. dok kursor ne pređe sve retke u rezultatu.

```mysql
CREATE FUNCTION trosak_misija_po_sektoru() RETURNS VARCHAR(1000)
DETERMINISTIC
BEGIN
    DECLARE p_id_sektor INTEGER;
    DECLARE ukupni_trosak DECIMAL(20,2) DEFAULT 0;
    DECLARE gotov INTEGER DEFAULT 0;
    DECLARE rezultat VARCHAR(1000) DEFAULT '';
    DECLARE cur CURSOR FOR SELECT id FROM sektor;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET gotov = 1;

    SET rezultat = ' ';

    OPEN cur;
        iteracija_sektora: LOOP
            FETCH cur INTO p_id_sektor;

            IF gotov = 1 THEN
                LEAVE iteracija_sektora;
            END IF;

            SELECT SUM(trosak_misije) INTO ukupni_trosak 
                FROM misija AS m
                INNER JOIN osoblje_na_misiji AS onm ON m.id = onm.id_misija
                INNER JOIN osoblje AS o ON o.id = onm.id_osoblje
                    WHERE o.id_sektor = p_id_sektor;

            SET rezultat = CONCAT(rezultat, 'Sektor ', (SELECT naziv FROM sektor AS s WHERE s.id = p_id_sektor), ': ', ukupni_trosak, " ");
        END LOOP;
    CLOSE cur;

    RETURN rezultat;
END//
DELIMITER ;
```

##### FUNKCIJA 4 - Dostupnost određenog vojnika za misiju bazirano dobi i prisutnosti na misiji

Sljedeća funkcija se sastoji od jednostavne provjere preko upita ali poziva drugu funkciju kako bi provjerili je li specifično osoblje na misiji ili ne.

Imamo varijable za trenutnu dob i jednu boolean varijablu za povratnu vrijednost koju vraća druga funkcija.

Druga funkcija preko jednostavnog upita provjerava je ili osoba na misiji ili nije te vraća podatak vrste BOOLEAN.

U glavnoj funkciji imamo upit koji preko DATEDIFF() komande računa dob osobe i sprema ju u varijablu <code>trenutna_dob</code>, poziv pomoćne funkcije sa ulaznim parametrom ID osoblje sprema povratnu informaciju u BOOLEAN varijablu <code>jeilinije</code> te preko if naredbe provjeravamo je li osoba dostupna i kvalificirana za misiju.

```mysql
DELIMITER //
CREATE FUNCTION osoblje_na_misiji_mod(p_id_osoblje INTEGER) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE jeilinije BOOLEAN DEFAULT FALSE;
    
    SELECT EXISTS(
        SELECT 1
            FROM osoblje AS o
            INNER JOIN osoblje_na_misiji AS onm ON o.id = onm.id_osoblje
            INNER JOIN misija AS m ON onm.id_misija = m.id
            INNER JOIN lokacija AS l ON m.id_lokacija = l.id
                WHERE m.vrijeme_kraja IS NULL AND o.id = p_id_osoblje
        ) INTO jeilinije;
    RETURN jeilinije;
END//
DELIMITER ;
-- --------
DELIMITER //
CREATE FUNCTION dostupnost_za_misiju(p_id_osoblje INTEGER, p_dob_misija INTEGER) RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
    DECLARE trenutna_dob INTEGER;
    DECLARE jeilinije BOOLEAN DEFAULT FALSE;

    SELECT (DATEDIFF(NOW(), o.datum_rodenja) DIV 365.25) INTO trenutna_dob
        FROM osoblje AS o
            WHERE o.id = p_id_osoblje;

    SELECT osoblje_na_misiji_mod(p_id_osoblje) INTO jeilinije;

    IF NOT jeilinije AND trenutna_dob <= p_dob_misija THEN
        RETURN 'Dostupan';
    ELSE
        RETURN 'Nedostupan';
    END IF;
END//
DELIMITER ;
```

### PROCEDURE

##### Procedura 1 - Ažuriranje statusa osoblja

Prva procedura je jednostavni primjer sa 2 ulazna parametra koja prima id osoblja i novi čin koji želimo postaviti, pa sa update komandom ažuriramo podatke u našoj bazi.

S time da procedura ne vraća nikakve podatke, rezultat će biti vidljiv preko odvojene projekcije podataka.

```
CREATE PROCEDURE promjena_statusa_osoblja(IN p_id_osoblje INT, IN p_status_osoblja VARCHAR(50))
BEGIN
    UPDATE osoblje
        SET status_osoblja = p_status_osoblja
            WHERE id = p_id_osoblje;
END//
DELIMITER ;
```

##### Procedura 2 - Svo aktivno osoblje koje se trenutačno nalazi na misiji

Procedura bez ulaznih ili izlaznih podataka koja koristi upit kako bi provjerili koje osoblje je trenutačno na misiji.

Spajamo tablice osoblje, osoblje_na_misiji, misija i lokacija kako bi dobili svo osoblje koje se trenutačno nalazi na misiji, na kojoj misiji sudjeluju i gdje se održava u svijetu. Kako bi odredili kraj misije koristimo <code>WHERE m.vrijeme_kraja IS NULL;</code> s time da smo odredili da misije u tijeku imaju vrijeme kraja kao NULL podatak.

**KOD:**

```
DELIMITER //
CREATE PROCEDURE svo_osoblje_na_misiji()
BEGIN
    SELECT o.*, m.naziv, l.naziv
        FROM osoblje AS o
        INNER JOIN osoblje_na_misiji AS onm ON o.id = onm.id_osoblje
        INNER JOIN misija AS m ON onm.id_misija = m.id
        INNER JOIN lokacija AS l ON m.id_lokacija = l.id
            WHERE m.vrijeme_kraja IS NULL;
END//
DELIMITER ;
```

##### Procedura 3 - Promocija ovisno o najnovijim ocjenama performanse na treningu

U sljedećoj proceduri imamo samo jedan ulazni podatak a to je id od osoblja koje želimo provjeriti.
U idealnom sustavu ova procedura bi se izvodila za svakog vojnika nakon svakog treninga kako bi ocjena bila najpreciznije određena.

Koristimo 2 pomoćne varijable u koju ćemo spremati ocjenu određenog vojnika te u drugu ćemo spremati rating sa zadnjeg treninga na kojem je sudjelovao.
Sa if naredbom provjeravamo performans te dodjeljujemo dodatne bodove na ocjeni ovisno o performansi.

Ako je ocjena prešla nižu ili višu granicu će se postaviti na određeni limit te će korisnik dobiti nazad povratnu informaciju koja preporućuje promociju ili sniženje čina.

**KOD:**

```mysql
DELIMITER //
CREATE PROCEDURE provjera_promocija_sniženje_cin(IN p_id_osoblje INT)
BEGIN
    DECLARE p_ocjena INT;
    DECLARE p_performans INT;

    SELECT ocjena INTO p_ocjena FROM osoblje WHERE id = p_id_osoblje;
    
    SELECT performans INTO p_performans
        FROM osoblje_na_treningu AS ont
        INNER JOIN trening AS t ON t.id = ont.id_trening
            WHERE id_osoblje = p_id_osoblje AND vrijeme_kraja IS NOT NULL
            ORDER BY vrijeme_pocetka DESC
            LIMIT 1;

    IF p_performans < 4 THEN
        SET p_ocjena = ( SELECT ocjena FROM osoblje WHERE id = p_id_osoblje ) - 5;
    ELSEIF p_performans < 5 THEN
        SET p_ocjena = ( SELECT ocjena FROM osoblje WHERE id = p_id_osoblje ) - 3;
    ELSEIF p_performans < 6 THEN
        SET p_ocjena = ( SELECT ocjena FROM osoblje WHERE id = p_id_osoblje ) - 1;
    ELSEIF p_performans >= 9 THEN
        SET p_ocjena = ( SELECT ocjena FROM osoblje WHERE id = p_id_osoblje ) + 5;
    ELSEIF p_performans >= 8 THEN
        SET p_ocjena = ( SELECT ocjena FROM osoblje WHERE id = p_id_osoblje ) + 3;
    ELSEIF p_performans >= 7 THEN
        SET p_ocjena = ( SELECT ocjena FROM osoblje WHERE id = p_id_osoblje ) + 1;
    END IF;

    IF p_ocjena < 1 THEN
    
        SET p_ocjena = 1;
        
        UPDATE osoblje
            SET ocjena = p_ocjena
                WHERE id = p_id_osoblje;
                
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ocjena je prešla najniže prihvatljive razine te se preporućuje sniženje čina';
    ELSEIF p_ocjena > 5 THEN
    
        SET p_ocjena = 5;
            
        UPDATE osoblje
            SET ocjena = p_ocjena
                WHERE id = p_id_osoblje;
                    
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ocjena je prešla najvišu razinu te se preporućuje povečanje čina';
    ELSE
        UPDATE osoblje
            SET ocjena = p_ocjena
                WHERE id = p_id_osoblje;
    END IF;
END//
DELIMITER ;
```

##### Procedura 4 - Update status na umirovljen

Procedura koja ažurira status osoblja ako nisu sudjelovali na treningu ili turi duže od godinu dana.

Koristimo update na tablicu osoblja te u selekciji provjeravamo je li status postavljen na aktivan ili neaktivan i je li id ne postoji u upitu koji traži je li bio na treningu ili turi.

```mysql
DELIMITER //
CREATE PROCEDURE promjena_statusa_na_neaktivan()
BEGIN
    UPDATE osoblje
    SET status_osoblja = 'Umirovljen'
    WHERE status_osoblja = 'Aktivan' 
    AND id NOT IN (SELECT id_osoblje FROM osoblje_na_turi WHERE datum_kraja > DATE_SUB(NOW(), INTERVAL 1 YEAR)) 
    AND id NOT IN (SELECT id_osoblje FROM osoblje_na_treningu AS ont INNER JOIN trening AS t ON t.id = ont.id_trening WHERE vrijeme_kraja > DATE_SUB(NOW(), INTERVAL 1 YEAR));
END //
DELIMITER ;
CALL promjena_statusa_na_neaktivan();
CALL promjena_statusa_na_neaktivan();
```

##### Procedura 5 - Broj osoblja koje nam je ostalo

Provjeravamo tablicu osoblje te brojimo koliko osoblja vezano za ulazni parametar <code>p_id_sektor</code> i nema status ‘Mrtav’ ili ‘Umirovljen’.

```mysql
-- Svo osoblje u određenom sektoru koje nije mrtvo 
DELIMITER //
CREATE PROCEDURE ukupno_osoblje_u_sektoru(IN p_id_sektor INT)
BEGIN
    SELECT COUNT(*)
    FROM osoblje
    WHERE id_sektor = p_id_sektor AND status_osoblja != 'Mrtav' OR status_osoblja != 'Umirovljen';
END//
DELIMITER ;
```

### OKIDAČI

##### Okidač 1 - Neaktivni vojnici

Osoblju koje trenutačno nije na turi, tj. turi koja ima datum_kraja postavljeno na NULL se postavlja status ‘Neaktivan’

Koristimo <code>AFTER UPDATE</code> argument te provjeravamo je li datum kraja promjenjen sa NULL na određeni datum.

```mysql
DELIMITER //
CREATE TRIGGER updtstatus_post_tura AFTER UPDATE ON tura
FOR EACH ROW
BEGIN
    IF NEW.vrijeme_kraja != NULL THEN
        UPDATE osoblje
            SET status_osoblja = "Neaktivan" WHERE id IN (SELECT id_osoblje FROM osoblje_na_turi WHERE id_tura = NEW.id AND datum_kraja IS NULL);
    END IF;
END//
DELIMITER ;
```

##### Okidač 2 - Točnost datuma ture

Ovaj okidač nam osigurava da datum kraja osoblja na turi ne bude veći od datum kraja same ture.

Koristimo <code>AFTER UPDATE</code> argument te provjeravamo da datum kraja nije null i mijenjamo tablicu osoblja na turi s time da postavljamo datum_kraja na isti datum_kraja ture, naravno također provjeravamo da datum_kraja od osoblja na turi je null.

```mysql
DROP TRIGGER IF EXISTS updtkraj_post_tura;

DELIMITER //
CREATE TRIGGER updtkraj_post_tura AFTER UPDATE ON tura
FOR EACH ROW
BEGIN
    IF NEW.vrijeme_kraja != NULL THEN
        UPDATE osoblje_na_turi 
            SET datum_kraja = NEW.vrijeme_kraja 
                WHERE id_tura = NEW.id AND datum_kraja IS NULL;
    END IF;
END//
DELIMITER ;
```

##### Okidač 3 - Obavezna oprema

Ovaj okidač se mora pokrenuti nakon što su početni podaci ručno uneseni inaće se neće pokrenuti baza kako treba

Koristimo <code>AFTER INSERT</code> argument na tablici osoblje_na_misiji kako bi provjerili je li određeni vojnik poslan na misiju

Imamo malu selekciju koja će se dati random između 2 broja tj. id-a kako bi nasumično odabrali pištolj za vojnika.

Ostatak su samo <code>INSERT INTO</code> naredbe kojima pomoću funkcije dodjeljujemo prvi slobodan ID u tablici.

```mysql
DELIMITER //
CREATE FUNCTION dostupni_id_izdana_oprema() RETURNS INTEGER
DETERMINISTIC
BEGIN
    DECLARE id_dostupnost INTEGER DEFAULT 5001;
    
    SELECT MAX(id) + 1 INTO id_dostupnost
        FROM izdana_oprema;
    
    RETURN id_dostupnost;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER minoprema_pre_misija AFTER INSERT ON osoblje_na_misiji
FOR EACH ROW
BEGIN
    DECLARE rand_samokres INTEGER;
    SELECT FLOOR(1301 + RAND() * (1303-1301)) INTO rand_samokres;
    
    -- garantira jedan od dva dostupna samokresa
    INSERT INTO izdana_oprema(id, id_oprema, id_osoblje_na_misiji, izdana_kolicina)
    VALUES(dostupni_id_izdana_oprema(), rand_samokres, NEW.id, 1);
    -- garantira kacigu
    INSERT INTO izdana_oprema(id, id_oprema, id_osoblje_na_misiji, izdana_kolicina)
    VALUES(dostupni_id_izdana_oprema(), 1358, NEW.id, 1);
    -- garantira pancirku
    INSERT INTO izdana_oprema(id, id_oprema, id_osoblje_na_misiji, izdana_kolicina)
    VALUES(dostupni_id_izdana_oprema(), 1359, NEW.id, 1);
    -- garantira uniformu
    INSERT INTO izdana_oprema(id, id_oprema, id_osoblje_na_misiji, izdana_kolicina)
    VALUES(dostupni_id_izdana_oprema(), 1360, NEW.id, 1);
    -- garantira čizme
    INSERT INTO izdana_oprema(id, id_oprema, id_osoblje_na_misiji, izdana_kolicina)
    VALUES(dostupni_id_izdana_oprema(), 1363, NEW.id, 1);
END//
DELIMITER ; 
```

##### Okidač 4 - Promjena odgovornog za vozilo

Koristimo <code>AFTER UPDATE</code> na osoblje na turi, te u slućaju da se osoblje koje je zaduženo za vozilo povuče prije kraja ture automatski se postavlja novi odgovorni na vozilo_na_turi.

```mysql
DELIMITER //
CREATE TRIGGER promjena_odgovornog AFTER UPDATE ON osoblje_na_turi
FOR EACH ROW
BEGIN
    IF NEW.datum_kraja != NULL AND OLD.datum_kraja = NULL THEN
        SELECT id INTO @zamjena
            FROM osoblje_na_turi
                WHERE datum_kraja IS NULL AND id_tura = OLD.id_tura
                LIMIT 1;

        IF @zamjena != NULL THEN
            UPDATE vozilo_na_turi
                SET id_odgovorni = @zamjena
                    WHERE id_odgovorni = OLD.id;
        ELSE
          SIGNAL SQLSTATE '40000' 
            SET MESSAGE_TEXT = 'Nije pronađena zamjena, moguće da je došlo do greške ili je tura gotova';
        END IF;
    END IF;
END//
DELIMITER ;
```

##### Okidač 5 - Dostupnost vojnika

Koristimo <code>BEFORE INSERT</code> s time da dostupnost vojnika moramo odrediti prije nego potvrdimo unesene podatke.

Brojimo količinu osoblja_na_misiji vezane na id-eve osoblja te ako ih j više od 0, javlja grešku da osoba nije dostupna.

```mysql
DELIMITER //
CREATE TRIGGER dostupnost_osoblja BEFORE INSERT ON osoblje_na_misiji
FOR EACH ROW
BEGIN
    
    SELECT COUNT(onm.id) INTO @dostupan
        FROM osoblje_na_misiji AS onm
        INNER JOIN osoblje AS o ON onm.id_osoblje = o.id
        INNER JOIN osoblje_na_turi AS ont ON o.id = ont.id_osoblje
        INNER JOIN misija AS m ON onm.id_misija = m.id
            WHERE onm.id_osoblje = NEW.id_osoblje AND ont.id_osoblje = NEW.id_osoblje AND m.vrijeme_kraja = NULL;
    IF @dostupan > 0 THEN
        SIGNAL SQLSTATE '40000'
            SET MESSAGE_TEXT = 'Osoblje nije dostupno za novu misiju';
    END IF;
END//
DELIMITER ;
```

### TRANSAKCIJE

##### Transakcija 1 - Uplata kapitala za sektor

Koristimo <code>ISOLATION LEVEL READ UNCOMMITTED</code> kako bi korisnik mogao provjeriti je li već postoji transakcija prije nego commita update.

Koristimo 2 session varijable koje primaju količinu novca i id sektora u koji isplaćujemo novac.

Preko jednostavnog update-a ažuriramo podatke, tj. proračun sektora i koristimo 2 upita kako bi provjerili kapital prije i poslije update-a.

Također imamo <code>ROLLBACK;</code> ili <code>COMMIT;</code> koje korisnik pokreće ručno

```mysql
SET AUTOCOMMIT = OFF;
SET @isplata_sektoru = 50000;
SET @id_sektor_transakcija1 = 2;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
    
    SELECT id, naziv, ukupni_proracun FROM sektor WHERE id = @id_sektor_transakcija1;
    
    UPDATE sektor
        SET ukupni_proracun = ukupni_proracun + @isplata_sektoru
            WHERE id = @id_sektor_transakcija1;
    
    SELECT id, naziv, ukupni_proracun FROM sektor WHERE id = @id_sektor_transakcija1;

COMMIT;
SET AUTOCOMMIT = ON;
```

##### Transakcija 2 - Naplata troškova misije određenom sektoru

Koristimo session varijablu kako bi odredili koju misiju naplaćujemo sektoru.

Prvi upit sprema id sektora kojem će se naplatiti trošak ovisno o koliko vojnika iz tog sektora je sudjelovalo na misiji.

Sa update komandom uzimamo trosak misije od ukupnog proracuna.

Zadnja selekcija se nalazi samo kako bi provjerili je li sve prošlo bez greške.

Važno je napomenuti da se ovaj sustav može dalje poboljšati pošto zasad nemamo kako pratiti otplaćene misije:

- Trebalo bi dodati novu tablicu koja bi pratila status otplate troška
- Doraditi transakciju kako bi u toj tablici pratili koji se dug podmirio

```mysql
SET @id_misija_za_naplatu = 3003;
SET @naplata_sektoru = 1;
SET @nekoristena = 1;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;

    SELECT o.id_sektor, COUNT(id_osoblje) AS broj_osoblja INTO @naplata_sektoru, @nekoristena
        FROM osoblje_na_misiji AS onm
        INNER JOIN osoblje AS o ON onm.id_osoblje = o.id
            WHERE id_misija = @id_misija_za_isplatu
            GROUP BY o.id_sektor
            ORDER BY broj_osoblja DESC
            LIMIT 1;
    
    UPDATE sektor
        SET ukupni_proracun = ukupni_proracun - (SELECT trosak_misije FROM misija WHERE id = @id_misija_za_naplatu)
            WHERE id = @naplata_sektoru;

    SELECT ukupni_proracun
        FROM sektor
            WHERE id = @naplata_sektoru;
COMMIT;
SET AUTOCOMMIT = ON;
```

### DELETE FUNKCIONALNOST NA SUČELJU

Važno napomenuti da je ovo napravljeno po template-u koji je napravio kolega Leo Matošević te varijable u kodu nisu sve iskorištene.

Sa dekoratorom <code>@app.route(’/izmjena/delete/<tablica>/<ID>’, methods = [‘GET’, ‘POST’]) </code>postavljamo rutu za funkciju u [server.py](http://server.py/) datoteci koja se veže našu frontend adresu.

<code>try</code> i <code>except</code> služe kao preventivna metoda da izbjegnem error u slućaju prazne tablice (BP_DataAll je funkcija koju je napisao Leo Matošević te će je on zasebno prezentirati)

U IF komandi podatke spajamo u polje preko for petlje te u sljedećoj petlji ih brišemo sa BP_Command (također funkcija koju je napravio Leo Matošević)

<code>return render_template()</code> se koristi za renderiranje HTML template-a . Kada se template renderira, imat će pristup varijablama te će ih koristiti za generiranje sadržaja na stranici. Renderani template će bit poslan natrag kao odgovor na zahtjev.

```python
@app.route('/izmjena/delete/<tablica>/<ID>', methods = ['GET', 'POST'])
def delete (tablica, ID):
    
    error=""
    popravak = BP_DataAll("select id_vozilo_na_misiji,misija.naziv from popravak,vozilo_na_misiji,misija where id_vozilo_na_misiji = vozilo_na_misiji.id and vozilo_na_misiji.id_misija = misija.id;")
    lokacija = BP_DataAll("select id, naziv from lokacija;")
    tura = BP_DataAll("select id, naziv from tura;")
    ImportID = BP_DataAll("select id from "+tablica+";")
    ImportData =""
    poljeID= []
    
    
    getData = BP_DataAll("Select * from "+ tablica+" ;")
    try:
        getRowLen = len(getData[0])
    except:
        getRowLen=0
        print("empty")


    if request.method == 'POST':
            polje = []
            for x in range(len(getData)):
                if "podatak"+str(x) in request.form:
                    polje.append(request.form["podatak"+str(x)])

            for x in polje:
                BP_Command("DELETE FROM " + tablica + " WHERE id = " + x + ";")
    
    
    return render_template('delete.html',popravak=popravak,popravakLen= len(popravak), poljeID = poljeID ,ImportData = ImportData,cinovi=cinovi,cinLen= len(cinovi),tablica = tablica,tura = tura,turaLen = len(tura),lokacija=lokacija,lokacijaLen = len(lokacija),getData=getData, getDatalen = len(getData),getRowLen=getRowLen,error=error)
```

Također imam i formu u HTML datoteci zvana delete.html gdje se ugnježdene petlje koriste za prikaz podataka koje smo povukli sa bekenda spremljeni u getData varijabli

**HTML forma:**

```html
                   <form method="POST" style="grid-template-columns: {{ getRowLen * 'auto '}}  ;"  class="gridauto" >
            
                    {% for i in range(0, getDatalen) %}
                        {% for x in range(0, 10) %}
                            {% if getData[i][x] or getData[i][x] == None or getData[i][x] == "" %}
    
                                {% if getData[i][x] in poljeID %}
                                
                                    <input type="checkbox" value="{{getData[i][x]}}" id="scales" name="podatak{{i}}" >
                               
                                
                                    
                               
                                
                             
                                {% else %}
                                <p>{{getData[i][x]}}</p>
                                
                                {% endif %}
                            {% endif %}
                        {%endfor%}
                    {%endfor%}

                    <button type="submit"  style=" margin-bottom: 10px; height: 50%; width: 50%;" class="newButton" role="button"><i class="fa-solid fa-trash"></i> Izbriši</button>
                </form>
```

## David Kovačević

## OKIDAČI

____

Datum početka ture ne može biti veći ili jednak od datuma kraja ture. U slučaju da je kraj NULL to znači da je tura još uvijek u tijeku. Riječ je o UPDATE-u.

```mysql
DROP TRIGGER IF EXISTS u_tura_vrijeme;

DELIMITER //
CREATE TRIGGER u_tura_vrijeme
    BEFORE UPDATE ON tura
    FOR EACH ROW
BEGIN
    IF new.vrijeme_pocetka >= new.vrijeme_kraja AND ISNULL(new.vrijeme_kraja) = 0 THEN
        SIGNAL SQLSTATE '40000'
        SET MESSAGE_TEXT = 'Neispravno je uneseno vrijeme pocetka ili/i kraja ture';
    END IF;
END//
DELIMITER ;
```

> Prije **ažuriranja** tablice **‘tura’** ovaj okidač će provjerit da li je novounešeno *vrijeme_pocetka*(DATETIME) veće od novounešenog *vrijeme_kraja*. U slučaju da *new.vrijeme_kraja* nije jednak *NULL* i da je *new.vrijeme_pocetka* veće/jednako od *new.vrijeme_kraja* onda se korisniku javlja tekstualna greška jer *vrijeme_kraja* ne može vremenski(i logički) biti prije *vrijeme_pocetka*. Ne treba javljat grešku ako je *new.vrijeme_kraja* jednako *NULL* jer to znači da je tura još uvijek u tijeku. U slučaju da je *new.vrijeme_kraja* veći od *new.vrijeme_pocetka* ili je *new.vrijeme_kraja* jednak *NULL* onda se ništa ne događa, odnosno ažuriranje tablice se može izvest bez ikakvog problema.

------

Datum početka misije ne može biti veći ili jednak od datuma kraja misije. U slučaju da je kraj NULL to znači da je misija još uvijek u tijeku. Riječ je o UPDATE-u.

```mysql
DROP TRIGGER IF EXISTS u_mis_vrijeme;

DELIMITER //
CREATE TRIGGER u_mis_vrijeme
    BEFORE UPDATE ON misija
    FOR EACH ROW
BEGIN
    IF new.vrijeme_pocetka >= new.vrijeme_kraja AND ISNULL(new.vrijeme_kraja) = 0 THEN
        SIGNAL SQLSTATE '40000'
        SET MESSAGE_TEXT = 'Neispravno je uneseno vrijeme pocetka ili/i kraja misije';
    END IF;
END//
DELIMITER ;
```

> Prije **ažuriranja** tablice **‘misija’** ovaj okidač će provjerit da li je novounešeno *vrijeme_pocetka*(DATETIME) veće od novounešenog *vrijeme_kraja*. U slučaju da *new.vrijeme_kraja* nije jednak *NULL* i *new.vrijeme_pocetka* je veće/jednako od *new.vrijeme_kraja* onda se korisniku javlja tekstualna greška jer *vrijeme_kraja* ne može vremenski(i logički) biti prije *vrijeme_pocetka*. Ne treba javljat grešku ako je *new.vrijeme_kraja* jednako *NULL* jer to znači da je misija još uvijek u tijeku. U slučaju da je *new.vrijeme_kraja* veći od *new.vrijeme_pocetka* ili je *new.vrijeme_kraja* jednak *NULL* onda se ništa ne događa, odnosno ažuriranje tablice se može izvest bez ikakvog problema.

------

Datum početka sudjelovanja osoblja na turi ne može biti veći ili jednak od datuma kraja sudjelovanja. U slučaju da je kraj NULL to znači da osoba još uvijek sudjeluje u turi. Riječ je o UPDATE-u.

```mysql
DROP TRIGGER IF EXISTS u_ont_vrijeme;

DELIMITER //
CREATE TRIGGER u_ont_vrijeme
    BEFORE UPDATE ON osoblje_na_turi
    FOR EACH ROW
BEGIN
    IF new.datum_pocetka >= new.datum_kraja AND ISNULL(new.datum_kraja) = 0 THEN
        SIGNAL SQLSTATE '40000'
        SET MESSAGE_TEXT = 'Neispravno je uneseno vrijeme pocetka ili/i kraja sudjelovanja osoblja na turi!';
    END IF;
END//
DELIMITER ;
```

> Prije **ažuriranja** tablice **‘osoblje_na_turi’** ovaj okidač će provjerit da li je novounešeno *datum_pocetka*(DATETIME) veće od novounešenog *datum_kraja*. U slučaju da *new.datum_kraja* nije jednak *NULL* i *new.datum_pocetka* je veće/jednako od *new.datum_kraja* onda se korisniku javlja tekstualna greška jer *datum_kraja* ne može vremenski(i logički) biti prije *datum_pocetka*. Ne treba javljat grešku ako je *new.datum_kraja* jednako *NULL* jer to znači da je osoba još uvijek na toj turi. U slučaju da je *new.datum_kraja* veći od *new.datum_pocetka* ili je *new.datum_kraja* jednak *NULL* onda se ništa ne događa, odnosno ažuriranje tablice se može izvest bez ikakvog problema.

------

Datum početka popravka ne može biti veći ili jednak od datuma kraja popravka. U slučaju da je kraj NULL to znači da je popravak još uvijek u tijeku. Riječ je o INSERT-u.

```mysql
DROP TRIGGER IF EXISTS i_po_vrijeme;

DELIMITER //
CREATE TRIGGER i_po_vrijeme
    BEFORE INSERT ON popravak
    FOR EACH ROW
BEGIN
    IF new.pocetak_popravka >= new.kraj_popravka AND ISNULL(new.kraj_popravka) = 0 THEN
        SIGNAL SQLSTATE '40000'
        SET MESSAGE_TEXT = 'Neispravno je uneseno vrijeme pocetka ili/i kraja popravka!';
    END IF;
END//
DELIMITER ;
```

> Prije **unosa** vrijednosti u tablici **‘popravak’** ovaj okidač će provjerit da li je novounešeno *pocetak_popravka*(DATETIME) veće od novounešenog *kraj_popravka*. U slučaju da *new.kraj_popravka* nije jednak *NULL* i da je *new.pocetak_popravka* veće/jednako od *new.kraj_popravka* onda se korisniku javlja tekstualna greška jer *kraj_popravka* ne može vremenski(i logički) biti prije *pocetak_popravka*. Ne treba javljat grešku ako je *new.kraj_popravka* jednako *NULL* jer to znači da je popravak još uvijek u tijeku. U slučaju da je *new.kraj_popravka* veći od *new.pocetak_popravka* ili je *new.kraj_popravka* jednak *NULL* onda se ništa ne događa, odnosno unos podataka u tablici se može izvest bez ikakvog problema.

------

Datum početka treninga ne može biti veći ili jednak od datuma kraja treninga te trening bi najmanje trebao trajat 20 minuta. Riječ je o INSERT-u.

```mysql
DROP TRIGGER IF EXISTS i_tr_vrijeme;

DELIMITER //
CREATE TRIGGER i_tr_vrijeme
    BEFORE INSERT ON trening
    FOR EACH ROW
BEGIN
    IF new.vrijeme_pocetka >= new.vrijeme_kraja OR TIMESTAMPDIFF(MINUTE, new.vrijeme_pocetka, new.vrijeme_kraja) < 20 THEN
        SIGNAL SQLSTATE '40000'
        SET MESSAGE_TEXT = 'Neispravno je uneseno vrijeme pocetka ili/i kraja treninga!';
    END IF;
END//
DELIMITER ;
```

> Prije **unosa** vrijednosti u tablici **‘trening’** ovaj okidač će provjerit da li je novounešeno *vrijeme_pocetka*(DATETIME) veće od novounešenog *vrijeme_kraja*. U slučaju da trening traje manje od 20 minuta(naša politika baze) i da je *new.vrijeme_pocetka* veće/jednako od *new.vrijeme_kraja* onda se korisniku javlja tekstualna greška jer *vrijeme_kraja* ne može vremenski(i logički) biti prije *vrijeme_pocetka*. Trajanje treninga se računa uz pomoć funkcije TIMESTAMPDIFF koja vraća minutnu razliku između *new.vrijeme_kraja* i *new.vrijeme_pocetka*. U slučaju da je *new.vrijeme_kraja* veći od *new.vrijeme_pocetka* te da trening traje najmanje 20 minuta onda se ništa ne događa, odnosno unos podataka u tablici se može izvest bez ikakvog problema.

------

Datum početka liječenja ne može biti veći ili jednak od datuma kraja liječenja kada je riječ o INSERT-u. U slučaju je datum kraja liječenja NULL to znači da je liječenje još uvijek u tijeku.

```mysql
DROP TRIGGER IF EXISTS i_li_vrijeme;                                                                                                      
DELIMITER //
CREATE TRIGGER i_li_vrijeme
    BEFORE INSERT ON lijecenje
    FOR EACH ROW
BEGIN
    IF new.pocetak_lijecenja >= new.kraj_lijecenja AND ISNULL(new.kraj_lijecenja) = 0 THEN
         SIGNAL SQLSTATE '40000'
         SET MESSAGE_TEXT = 'Neispravno je uneseno vrijeme pocetka ili/i kraja lijecenja!';
    END IF;
END//
DELIMITER ;
```

> Prije **unosa** vrijednosti u tablici **‘lijecenje’** ovaj okidač će provjerit da li je novounešeno *pocetak_lijecenja*(DATETIME) veće od novounešenog *kraj_lijecenja*. U slučaju da *new.kraj_lijecenja* nije jednak *NULL* i da je *new.pocetak_lijecenja* veće/jednako od *new.kraj_lijecenja* onda se korisniku javlja tekstualna greška jer *kraj_lijecenja* ne može vremenski(i logički) biti prije *pocetak_lijecenja*. Ne treba javljat grešku ako je *new.kraj_lijecenja* jednako *NULL* jer to znači da je liječenje još uvijek u tijeku. U slučaju da je *new.kraj_lijecenja* veći od *new.pocetak_lijecenja* ili je *new.kraj_lijecenja* jednak *NULL* onda se ništa ne događa, odnosno unos podataka u tablici se može izvest bez ikakvog problema.

------

Prati se da zbroj količine željene izdane opreme ne bude veći od sveukupne moguće količine opreme tijekom INSERT-a. Prati se da u određenom razdoblju tj. misiji to ne bude prekoračeno.

```mysql
DROP TRIGGER IF EXISTS i_kol_op;

DELIMITER //
CREATE TRIGGER i_kol_op
    BEFORE INSERT ON izdana_oprema
    FOR EACH ROW
BEGIN
    DECLARE id_zadane_misije INTEGER;
    DECLARE br INTEGER;
    DECLARE uk INTEGER;
    
    SELECT id_misija INTO id_zadane_misije
    FROM osoblje_na_misiji
    WHERE osoblje_na_misiji.id = new.id_osoblje_na_misiji;
    
    SELECT SUM(izdana_kolicina) INTO br
    FROM izdana_oprema
    INNER JOIN osoblje_na_misiji
    ON izdana_oprema.id_osoblje_na_misiji = osoblje_na_misiji.id
    WHERE id_oprema = new.id_oprema AND id_misija = id_zadane_misije;
    
    SELECT ukupna_kolicina INTO uk
    FROM oprema
    WHERE id = new.id_oprema;

    IF br + new.izdana_kolicina > uk THEN
    SIGNAL SQLSTATE '40000'
        SET MESSAGE_TEXT = 'Oprema koju zelite unijeti nije dostupna u zeljenoj kolicini!';
    END IF;
END//
DELIMITER ;
```

> Okidač se izvodi nad tablicom *izdana_oprema* prilikom INSERT-a. U prvom SELECT-u saznajemo id misije koji će nam biti potreban za pračenje količine izdane opreme. Id misije ćemo saznat iz tablice *osoblje_na_misiji*, a poveznicu na tu tablicu i na samu misiju u INSERT-u je *new.id_osoblje_na_misiji*. Nakon što smo saznali za koju misiju ćemo pratit količinu izdane (određene)opreme moramo saznat koliko je do sada bilo izdano te specifične opreme u danoj misiji. Tu vrijednost spremamo u *br* te nas zanima koliko je sveukupno od te specifične opreme općenita sveukupna količina. Tu vrijednost spremamo u *uk* te potom provjeravamo da li zbroj količine specifične opreme koju želimo unijet na toj misiji i broja koji predstavlja koliko je do sada u toj misiji izdano te specifične opreme prelazi ukupnu količinu te specifične opreme. U slučaju da prelazi javlja tekstualnu grešku, a u protivnom se izvodi bez problema.

------

Prati se da zbroj izdane količine ne bude veći od sveukupne moguće količine opreme tijekom UPDATE-a. Prati se da u određenom razdoblju tj. misiji to ne bude prekoračeno.

```mysql
DROP TRIGGER IF EXISTS u_kol_op;

DELIMITER //
CREATE TRIGGER u_kol_op
    BEFORE UPDATE ON izdana_oprema
    FOR EACH ROW
BEGIN
    DECLARE id_zadane_misije INTEGER;
    DECLARE br INTEGER;
    DECLARE uk INTEGER;

    SELECT id_misija INTO id_zadane_misije
    FROM osoblje_na_misiji
    WHERE osoblje_na_misiji.id = new.id_osoblje_na_misiji;
    
    SELECT SUM(izdana_kolicina) INTO br
    FROM izdana_oprema
    INNER JOIN osoblje_na_misiji
    ON izdana_oprema.id_osoblje_na_misiji = osoblje_na_misiji.id
    WHERE id_oprema = new.id_oprema AND id_misija = id_zadane_misije;

    SELECT ukupna_kolicina INTO uk
    FROM oprema
    WHERE id = new.id_oprema;

    IF (br - old.izdana_kolicina) + new.izdana_kolicina > uk THEN
    SIGNAL SQLSTATE '40000'
        SET MESSAGE_TEXT = 'Ne mozete promijenit kolicinu zeljene opreme koja je izdana osobi zato jer nije dostupna u toj kolicini!';
    END IF;
END//
DELIMITER ;
```

> Okidač se izvodi nad tablicom *izdana_oprema* prilikom UPDATE-a. U prvom SELECT-u saznajemo id misije koji će nam biti potreban za pračenje količine izdane opreme. Id misije ćemo saznat iz tablice *osoblje_na_misiji*, a poveznicu na tu tablicu i na samu misiju u INSERT-u je *new.id_osoblje_na_misiji*. Nakon što smo saznali za koju misiju ćemo pratit količinu izdane (određene)opreme moramo saznat koliko je do sada bilo izdano te specifične opreme u danoj misiji. Tu vrijednost spremamo u *br* te nas zanima koliko je sveukupno od te specifične opreme općenita sveukupna količina. Od sveukupnog količine u kojoj je ta oprema izdana na toj misiji se oduzima *old.izdana_kolicina* zato jer je to vrijednost koja više neće postojat(zbog UPDATE) te se pridodaje nova količina. Provjerava se da li ovaj izračun prelazi sveukupnu količinu te specifične opreme. U slučaju da prelazi javlja tekstualnu grešku, a u protivnom se UPDATE izvodi bez problema.

## UPITI

____

Prikaži id, ime i prezime 10 osoba koje su imale najveći performans na treningu, a preduvjet za njihovo pojavljivanje na listi je da su bile na barem jednoj misiji koja u svom intervalu održavanja ima najmanje jedan dan u 12. mjesecu.

```mysql
SELECT os.id, ime, prezime
FROM osoblje_na_treningu AS o
INNER JOIN osoblje AS os
    ON os.id = o.id_osoblje
INNER JOIN osoblje_na_misiji AS om
    ON om.id_osoblje = os.id
INNER JOIN (SELECT id FROM misija WHERE 12 - MONTH(vrijeme_pocetka) <= TIMESTAMPDIFF(MONTH, vrijeme_pocetka, vrijeme_kraja)) AS m
    ON om.id_misija = m.id
ORDER BY performans DESC
LIMIT 10;
```

> Trebamo kao prvo uzet u obzir kako ćemo doći do informacija koje su nam potrebne da dostignemo željeni rezultat. Id, ime, prezime osoblja ćemo dobit iz tablice *osoblje*. Njihov performans ćemo saznati u tablici *osoblje_na_treningu*, a informacije o održavanju misije ćemo saznat u tablici *misija*. Tablica *osoblje_na_misiji* služi kao povecnica između drugih tablici. Spojit ćemo navedene tablice s INNER JOIN kako bi došli do željenih podataka. Uz naglasak da smo iz tablice misija uzeli samo podatke koji zadovoljavaju uvjet da misija u svom intervalu održavanja ima najmanje jedan dan u 12. mjesecu(metoda za provjeravanje ovog uvjeta je testirana i funkcionira).
> Na dobiveni skup podataka ćemo izvest ORDER BY perofrmans DESC kako bi performans bio raspoređen od najveće vrijednosti prema najmanjoj te ćemo potom limitirat na 10 kako bi dobili 10 osoba s najvećim performansom.

------

Prikaži id, ime, prezime i čin osobe koja je bila odgovorna za vozilo vrste “Helikopteri” koje je bilo na najviše popravaka.

```mysql
SELECT ime, prezime, cin
FROM
    (SELECT ime, prezime, cin, COUNT(*) AS broj_popravka
    FROM popravak AS p
    INNER JOIN vozilo_na_misiji AS vm
        ON p.id_vozilo_na_misiji = vm.id
    INNER JOIN (SELECT * FROM vozila WHERE vrsta = "Helikopteri") AS v
        ON v.id = vm.id_vozilo
    INNER JOIN vozilo_na_turi AS vt
        ON vt.id_vozilo = v.id
    INNER JOIN osoblje_na_turi AS ot
        ON ot.id = vt.id_odgovorni
    INNER JOIN osoblje AS o
        ON o.id = ot.id_osoblje
    GROUP BY v.id) AS l
    ORDER BY broj_popravka DESC
    LIMIT 1;
```

> Kako bi došli do željenog rezultata trebamo INNER JOIN-at nekoliko tablica. Tablica *vozilo* nam je potrebna kako bi došli do vrste, a tablica *osoblje* kako bi došli do finalnih podataka. Tablice *osoblje_na_turi*, *vozilo_na_turi* i *vozilo_na_misiji* služe kao poveznice među ostalim tablicama te kako bi došli do smislenih rezultata. Među join-ovima postavljamo i uvjet da vrtsa vozila mora biti “Helikopteri” te kasnije grupiramo po id-evima vozila kako bi prebrojili njihov broj popravka. Svrstat ćemo skup podataka po broju popravka od najveće vrijednosti prema najmanjoj te ćemo limitirat na 1 kako bi ostala samo najveća vrijednost.

------

Prikaži naziv ture kod koje je izdano najmanje opreme.

```mysql
SELECT naziv
FROM
    (SELECT t.naziv, SUM(izdana_kolicina) AS izdano_na_turi
    FROM izdana_oprema AS i
    INNER JOIN osoblje_na_misiji AS om
        ON i.id_osoblje_na_misiji = om.id
    INNER JOIN misija AS m
        ON om.id_misija = m.id
    INNER JOIN tura AS t
        ON t.id = m.id_tura
    GROUP BY t.id) AS l
    ORDER BY izdano_na_turi ASC
    LIMIT 1;
```

> U unutarnjem SELECT-u ćemo spojit s INNER JOIN tablice *izdana_oprema* i *osoblje_na_misiji* zato jer se u *izdana_oprema* nalazi informacija o količini izdane opreme, a jedini način da dođemo do količine izdane opreme u turi je da prvo izračunamo količinu izdane opreme po misiji. Kako bi postigli povezanost s *misija* koristimo tablicu *osoblje_na_misiji* te potom rezultat prvog join-a INNER JOIN-amo s tablicom *misija*. Tura se sastoji od misija te su međusobno povezane kao tablice. INNER JOIN-amo s turom te grupiramo s [t.id](http://t.id/)(id tura) kako bi mogli za svaku pojedinačnu turu mogli izračunat sumu izdane količine opreme. Upravo ćemo izvest ORDER BY na skup podataka na temelju količine izdane opreme na pojedinoj turi, a nizat će se od najmanje vrijednosti količine izdane opreme na pojedinoj turi prema najvećoj. Izvest ćemo LIMIT 1 s čime smo limitirali na samo prvi redak tj red koji ima najmanju količinu izdane opreme određenoj turi. Na kraju izvodimo SELECT s kojim dohvaćamo samo naziv željene ture kao što nam je u zadatku zadano.

Prikaži ukupni proračun sektora koji ima drugi najveći broj osoblja koji nisu bili na liječenju niti jedanput te koji su sudjelovali na najmanje jednom treningu čiji datum početka nije bio prije 23 godinu dana od sada.

```mysql
SELECT ukupni_proracun
FROM
    (SELECT ukupni_proracun, COUNT(DISTINCT o.id) AS br_osoblja_uvjeti
    FROM osoblje AS o
    INNER JOIN sektor AS s
        ON o.id_sektor = s.id
    INNER JOIN osoblje_na_treningu AS ot
        ON ot.id_osoblje = o.id
    INNER JOIN trening AS t
        ON t.id = ot.id_trening
    WHERE o.id NOT IN (SELECT id_osoblje FROM lijecenje) AND DATE(vrijeme_pocetka) + INTERVAL 23 YEAR >= NOW()
    GROUP BY id_sektor) AS l
    ORDER BY br_osoblja_uvjeti DESC
    LIMIT 1, 1;
```

> INNER JOIN-at ćemo tablice *osoblje*, *sektor*, *osoblje_na_treningu* i *trening*. Tablica *sektor* nam je primarno potrebna kako bi došli do ukupnog proračuna sektora. Tablica *trening* nam je potrebna kako bi došli do podatka *vrijeme_pocetka*. Tablice *osoblje* i *osoblje_na_treningu* su nam “poveznica” za tablice *sektor* i *trening* te kako bi id osoblja mogli koristi za uvjet. Uvjet gleda koji id-evi osoblja se ne nalaze u tablici *lijecenje*, odnosno da nikad nisu bili na liječenju, te da vrijeme početka treninga na kojem su sudjelovali nije bio prije 23 godina od sada. Potom grupiramo po *id_sektor* kako bi prebrojali koliko osoblja zadovoljava uvjet po sektoru. ORDER BY ćemo po broju osoblja koji zadovoljavaju taj uvjet po sektoru tako što će taj niz biti poredan od najvećeg prema najmanjem. LIMIT 1,1 koristimo kako bi došli do drugog najvećeg i samo njega prikazali.

------

Prikaži nazive misija i njene lokacije, ali samo za misije u kojima je sudjelovalo osoblje starije od 31 godinu i koje je bilo odgovorno za najmanje jedno vozilo u nekoj turi.

```mysql
SELECT m.naziv AS naziv_misije, l.naziv AS naziv_lokacije
FROM lokacija AS l
INNER JOIN misija AS m
    ON m.id_lokacija = l.id
INNER JOIN osoblje_na_misiji AS om
    ON om.id_misija = m.id
INNER JOIN osoblje AS o
    ON o.id = om.id_osoblje
WHERE TIMESTAMPDIFF(YEAR, datum_rodenja, vrijeme_pocetka) > 31 AND o.id IN
(SELECT id_osoblje FROM vozilo_na_turi AS vt INNER JOIN osoblje_na_turi AS ot ON vt.id_odgovorni = ot.id);
```

> INNER JOIN-at ćemo tablicu *misija* i *lokacija* kako bi kasnije došli do željenih podataka(nazivi), ali nakon toga moramo INNER JOIN-at i s tablicom *osoblje* i *osoblje_na_misiji* kako bi postavili uvjet da osoba mora biti starija od 31 godina te *osoblje_na_misiji* služi kao poveznica između *osoblje* i *misija*. U uvjetovanju uz uvjet godina se treba zadovoljit i uvjet da se prikažu podaci koji imaju id osoblja koje je bilo odgovorno za barem jedno vozilo u nekoj turi. Naglašavam da se u tablici *vozilo_na_turi* nalazi *id_ogovorni* koji se referencira na osoblje_na_turi.id jer se odgovornost osoblja na vozilo dodjeljuje po turi te samim time možemo doći do id osoblja koje je bilo odgovorno za vozilo.

------

Treba se napraviti pogled koji će prikazat dodatne podatke vezane uz turu. Treba se prikazat od koliko se misija ta tura sastoji, koliki je trošak ture, broj osoblja koji je sudjelovao, broj opreme koji je određen za tu turu te broj vozila koji je određen za tu turu. Ovi dodatni prikazi će biti za ture koje sadrže barem jedan od navedenih podataka.

```mysql
DROP VIEW IF EXISTS tura_informacije;

CREATE VIEW tura_informacije AS
SELECT t_naziv AS tura_naziv, broj_misija, trosak_ture, broj_osoblja_na_turi, COUNT(*) AS broj_vozila_na_turi
FROM 
(SELECT t_id, t_naziv, broj_misija, trosak_ture, COUNT(*) AS broj_osoblja_na_turi
FROM 
(SELECT tura.id AS t_id, tura.naziv AS t_naziv, COUNT(*) AS broj_misija, SUM(trosak_misije) AS trosak_ture
FROM tura
INNER JOIN misija ON misija.id_tura = tura.id
GROUP BY tura.id) AS l
INNER JOIN osoblje_na_turi ON osoblje_na_turi.id_tura = l.t_id
GROUP BY id_tura) AS k
INNER JOIN vozilo_na_turi ON vozilo_na_turi.id_tura = k.t_id
GROUP BY id_tura;

SELECT * FROM tura_informacije;
```

> U skroz unutarnjem SELECT-u(onaj koji se prvi izvodi) smo napravili INNER JOIN između tablice *tura* i tablice *misija* te smo potom grupirali na temelju id tura kako bi za svaku pojedinu turu dobili njezin broj misija i sumu troškova misija koji ju čine. Važno je naglasiti da se nije moglo odmah INNER JOIN-at s tablicama s kojima se kasnije u upitu radi i grupirat samo jedanput po id tura zato jer smo za određene COUNT-ove dobili nepoželjne rezultate(provjereno više puta). Zatim ćemo dobivene podatke INNER JOIN-at s tablicom *osoblje_na_turi* kako bi mogli ponovno grupirat po id tura te prebrojat osoblje u pojedinoj turi. Isti postupak se ponavlja i za tablicu *vozilo_na_turi*.

------

Treba se napraviti pogled koji će prikazat dodatne podatke vezane uz misiju. Treba se prikazat koliki je trošak misije, broj osoblja koji je sudjelovao, broj opreme koji je određen za tu misiju te broj vozila koji je određen za tu misiju. Ovi dodatni prikazi će biti za misije koje sadrže barem jedan od navedenih podataka.

```mysql
DROP VIEW IF EXISTS misija_informacije;

CREATE VIEW misija_informacije AS
SELECT m_naziv AS misija_naziv, trosak_misije, broj_osoblja_na_misiji, broj_opreme_na_misiji, COUNT(*) AS broj_vozila_na_misiji
FROM
(SELECT misija.id AS m_id, misija.naziv AS m_naziv, trosak_misije, COUNT(*) AS broj_osoblja_na_misiji, SUM(izdana_kolicina) AS broj_opreme_na_misiji
FROM misija
INNER JOIN osoblje_na_misiji ON osoblje_na_misiji.id_misija = misija.id
INNER JOIN izdana_oprema ON izdana_oprema.id_osoblje_na_misiji = osoblje_na_misiji.id
GROUP BY id_misija) AS p
INNER JOIN vozilo_na_misiji ON vozilo_na_misiji.id_misija = p.m_id
GROUP BY id_misija;

SELECT * FROM misija_informacije;
```

> U unutarnjem SELECT-u se INNER JOIN-a tablica *misija*, *osoblje_na_misiji* i *izdana_oprema*. Iz tablice *misija* dobivamo osnovone podatke o misiji. Tablica *osoblje_na_misiji* nam omogućuje da prebrojimo koliko je osoba bilo na pojedinoj misiji zahvaljujući GROUP BY id_misija, a tablica *izdana_oprema* nam omogućuje da sumiramo izdane količine opreme na pojedinoj misiji(zahvaljujući GROUP BY id_misija). Kao i kod prošlog upita, tj pogleda, zbog ponašanja COUNT i GROUP BY nakon INNER JOIN-a određenih tablica moramo posebno SELECT-at tj. grupirat kako bi dobili ispravne podatke. Zatim INNER JOIN-amo skup podataka s *vozilo_na_misiji* ako bi potom nakon grupiranja po *id_misija* dobili broj vozila po pojedinoj misiji.

------

Treba se napraviti pogled koji će prikazat koliko je puta pojedina osoba bila na treningu, misiji i liječenju.

```mysql
DROP VIEW IF EXISTS osoblje_informacije;

CREATE VIEW osoblje_informacije AS
SELECT o_id AS osoblje_id, o_ime AS osoblje_ime, o_p AS osoblje_prezime, broj_sudjelovanja_na_treningu, broj_lijecenja, broj_sudjelovanja_na_misiji
FROM 
((SELECT l.o_id, l.o_ime, l.o_p, broj_sudjelovanja_na_treningu, broj_lijecenja, broj_sudjelovanja_na_misiji
FROM
(SELECT osoblje.id AS o_id, osoblje.ime AS o_ime, osoblje.prezime AS o_p, COUNT(*) AS broj_sudjelovanja_na_treningu
FROM osoblje
INNER JOIN osoblje_na_treningu ON osoblje.id = osoblje_na_treningu.id_osoblje
GROUP BY id_osoblje
UNION
SELECT osoblje.id AS o_id, osoblje.ime AS o_ime, osoblje.prezime AS o_p, IFNULL(osoblje_na_treningu.id, 0) AS broj_sudjelovanja_na_treningu
FROM osoblje
LEFT JOIN osoblje_na_treningu ON osoblje.id = osoblje_na_treningu.id_osoblje
WHERE ISNULL(osoblje_na_treningu.id) = 1) AS l
INNER JOIN
(SELECT osoblje.id AS o_id, osoblje.ime AS o_ime, osoblje.prezime AS o_p, COUNT(*) AS broj_lijecenja
FROM osoblje
INNER JOIN lijecenje ON osoblje.id = lijecenje.id_osoblje
GROUP BY id_osoblje
UNION
SELECT osoblje.id AS o_id, osoblje.ime AS o_ime, osoblje.prezime AS o_p, IFNULL(lijecenje.id, 0) AS  broj_lijecenja
FROM osoblje
LEFT JOIN lijecenje ON osoblje.id = lijecenje.id_osoblje
WHERE ISNULL(lijecenje.id) = 1) AS k
ON l.o_id = k.o_id
INNER JOIN
(SELECT osoblje.id AS o_id, osoblje.ime AS o_ime, osoblje.prezime AS o_p, COUNT(*) AS broj_sudjelovanja_na_misiji
FROM osoblje
INNER JOIN osoblje_na_misiji ON osoblje.id = osoblje_na_misiji.id_osoblje
GROUP BY id_osoblje
UNION
SELECT osoblje.id AS o_id, osoblje.ime AS o_ime, osoblje.prezime AS o_p, IFNULL(osoblje_na_misiji.id, 0) AS broj_sudjelovanja_na_misiji
FROM osoblje
LEFT JOIN osoblje_na_misiji ON osoblje.id = osoblje_na_misiji.id_osoblje
WHERE ISNULL(osoblje_na_misiji.id) = 1) AS z
ON l.o_id = z.o_id)) AS r
ORDER BY o_id ASC;

SELECT * FROM osoblje_informacije;
```

> Ovo je veoma složen te ću ga pokušat konceptualno objasnit. Saznati ćemo koliko je koja osoba bila na treningu tako što ćemo INNER JOIN-at *osoblje* i *osoblje_na_treningu* te zatim ćemo grupirajući po id osoblju prebrojat koliko je koja osoba bila na treningu. Moramo uzet u obzir da su ovime prikazane osobe koje su se pojavile jedanput, dvaput ili više, a nisu se pojavile osobe koje nisu niti jedanput prisustvovale treningu tj u *broj_sudjelovanja_na_treningu* za sada nemamo vrijednost 0. Dobivene vrijednosti ćemo s unijom spojiti s SELECT-om u kojem ovaj put izvodimo LEFT JOIN između *osoblje_na_treningu* i *osoblje*. S ovim spajanjem ćemo dobit i osoblje koje niti jedanput nije bilo na treningu te će specifični stupci upravo za to osoblje bit NULL. Mi ćemo postavit uvjet da nas zanimaju redci koji imaju osoblje_na_treningu.id kao NULL jer to znači da to osoblje uopće nije prisustvovalo na treningu. Taj NULL ćemo zamijenit s vrijednost 0. Nakon unije imamo i osoblje koje je sudjelovalo na treningu(1 ili više sudjelovanja)te osoblje koje uopce nije sudjelovalo na treningu(odnosno vrijednost 0). Isti postupak se izvodi za liječenje i misije. Na kraju INNER JOIN-amo te tri unije na temelju id-eva osoblja te ćemo order-at id-eve osoblja kako bi krenuli od najmanjeg prema najvećem.

## FUNKCIJE

____

Treba napraviti funkciju koja računa ukupan trošak.

```mysql
DROP FUNCTION IF EXISTS trosak;

DELIMITER //
CREATE FUNCTION trosak() RETURNS DECIMAL(22,2)
DETERMINISTIC
BEGIN
    DECLARE ukupno_misija, ukupni_popravak, ukupno_lijecenje DECIMAL(30,2);

    SELECT SUM(trosak_misije) INTO ukupno_misija
    FROM misija;

    SELECT SUM(trosak_popravka) INTO ukupni_popravak
    FROM popravak;

    SELECT SUM(trosak_lijecenja) INTO ukupno_lijecenje
    FROM lijecenje;

    RETURN ukupno_misija + ukupni_popravak + ukupno_lijecenje;
END//
DELIMITER ;

SELECT trosak() AS ukupni_trosak FROM DUAL;
```

> Podatke o troškovima možemo pronaći u tablicama *misija*, *lijecenje* i *popravak*. Stvaramo tri varijable u kojima ćemo spremiti troškove iz pojedine tablice. U prvom SELECT-u funkcije se računa suma troškova iz tablice *misija* te se ta vrijednost sprema u varijablu *ukupno_misija*. U drugom SELECT-u funkcije se računa suma troškova iz tablice *popravak* te se ta vrijednost sprema u varijablu *ukupno_popravak*. U trećem SELECT-u funkcije se računa suma troškova iz tablice *lijecenje* te se ta vrijednost sprema u varijablu *ukupno_lijecenje*. Funkcija vraća zbroj triju varijabla koje sam prije naveo, a taj zbroj istovremeno predstavlja ukupni trošak naše vojske. Funkciji nije potreban niti jedan ulazni argument, a tip podataka koji vraća je DECIMAL(22,2).

------

Treba napraviti funkciju koja računa koliko je novca ostalo “viška” iz proračuna.

```mysql
DROP FUNCTION IF EXISTS visak;

DELIMITER //
CREATE FUNCTION visak() RETURNS DECIMAL(22,2)
DETERMINISTIC
BEGIN
    DECLARE proracun_svih_sektora DECIMAL(22,2);

    SELECT SUM(ukupni_proracun) INTO proracun_svih_sektora
    FROM sektor;

    RETURN proracun_svih_sektora - trosak();
END//
DELIMITER ;

SELECT visak() AS visak FROM DUAL;
```

> Višak za cijelu našu bazu ćemo izračunat tako da prvo saznamo koliko iznosi naš sveukupni proračun te potom tu vrijednost oduzimamo s ukupnim troškom. Naš sveukupni proračun ćemo izračunat tako da zbrojimo proračune za svaki pojedini sektor. Ukupni trošak možemo lako dobit pošto smo prije ove funkcije napravili funkciju trosak(). Vraćamo razliku između sveukupnog proračuna i ukupnih troškova, odnosno višak. Taj višak tj povratna vrijendost je tipa DECIMAL(22,2). Funkciji ponovno nije potreban niti jedan argument.

------

Funkcija koja vraća broj osoblja koje je imalo uvijek perofrmans na treningu viši od 6 te da nikad nisu bili na liječenju.

```mysql
DROP FUNCTION IF EXISTS br_os_tr_i_li;

DELIMITER //
CREATE FUNCTION br_os_tr_i_li() RETURNS INTEGER
DETERMINISTIC
BEGIN
    DECLARE br_os_tr_li INTEGER;

    CREATE TEMPORARY TABLE br_perf_veci_od_sest
    SELECT id_osoblje, COUNT(*) AS br_perf_vece_sest
    FROM osoblje_na_treningu
    WHERE performans > 6
    GROUP BY id_osoblje;
    
    CREATE TEMPORARY TABLE br_perf_po_osobi
    SELECT id_osoblje AS id_os, COUNT(*) AS br_perf
    FROM osoblje_na_treningu
    GROUP BY id_osoblje;

    SELECT COUNT(*) INTO br_os_tr_li
    FROM
    (SELECT id_osoblje
    FROM br_perf_veci_od_sest
    INNER JOIN br_perf_po_osobi
    ON br_perf_veci_od_sest.id_osoblje = br_perf_po_osobi.id_os
    WHERE br_perf_vece_sest = br_perf) AS l
    WHERE id_osoblje 
    NOT IN (SELECT id_osoblje FROM lijecenje);

    DROP TEMPORARY TABLE br_perf_veci_od_sest;
    DROP TEMPORARY TABLE br_perf_po_osobi;

    RETURN br_os_tr_li;
END//
DELIMITER ;

SELECT br_os_tr_i_li() AS br_osoblja_dobar_performans_nikad_na_lijecenju FROM DUAL;
```

> Stvaramo vraijablu *br_os_tr_li* u kojoj ćemo spremiti finalni rezultat, odnosno broj osoblja koje je imalo uvijek perofrmans na treningu viši od 6 te da nikad nisu bili na liječenju. Dio **uvijek perofrmans na treningu viši od 6** znači da **broj sudjelovanja određene osobe na treningu mora biti jednak broju treninga u kojim je osoba imala performans veći od 6**. Prvo ćemo napraviti privremenu tablicu s osobljem koje je imalo barem jednom performans veći od 6 te ćemo u njoj spremiti *id* i *br_perf_vece_sest* -> broj koji označava koliko je puta osoba imala performans veći od 6 (neće se prikazat pojedinci s 0 *br_perf_vece_sest*, a to nam nije ni potrebno). U drugoj privremenoj tablici su spremljeni id-evi osoba koje su sudjelovale na misijama i *br_perf* -> koji označava broj sudjelovanja na treningu(samim time i broj performansa, jedan trening = jedan performans) koje je pojedinac imao. U SELECT-u spajamo te dvije privremene tablice s INNER JOIN te potom postavljamo uvijet *br_perf_vece_sest = br_perf* koji zadovoljava uvijet: **broj sudjelovanja određene osobe na treningu mora biti jednak broju treninga u kojim je osoba imala performans veći od 6**. Zatim provjeravamo da se osoblje koje ovo zadovoljava ne nalazi u tablici *lijecenje*. Nakon toga jednostavno brojimo(COUNT()) koliko ima pojedinaca a da zadovoljavaju sve prijašnje navedene uvjete.

------

Za određeni id osoblja treba se dati tekstualni odgovor u čemu je sve osoba sujelovala. Npr. “Arabela Herceg je sudjelovala u najmanje jednoj/m: treningu i lijecenju.”
Moguće je više kombinacija, a najduža je npr “Arabela Herceg je sudjelovao/la u najmanje jednoj: turi, misiji,treningu i lijecenju.” U slučaju da osoba nije sudjelovala još uvijek u ničemu bit će ispisano npr
“Arabela Herceg nije sudjelovao/la ni u jednoj: turi, misiji,treningu ili lijecenju.”

```mysql
DROP FUNCTION IF EXISTS os_sudjelovanje;

DELIMITER //
CREATE FUNCTION os_sudjelovanje(id_os INTEGER) RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE odg VARCHAR(100);
    DECLARE brojac INTEGER;
    DECLARE tura VARCHAR(20);
    DECLARE misija VARCHAR(20);
    DECLARE trening VARCHAR(20);
    DECLARE lijecenje VARCHAR(20);
    
    SELECT CONCAT(ime, " ",prezime) INTO odg
    FROM osoblje 
    WHERE id = id_os;

    IF id_os IN (SELECT id_osoblje FROM osoblje_na_turi) THEN
        SET tura = " turi,";
        SET brojac = brojac + 1;
    ELSE  
        SET tura = "";
    END IF;


    IF id_os IN (SELECT id_osoblje FROM osoblje_na_misiji) THEN
        SET misija = " misiji,";
        SET brojac = brojac + 1;
    ELSE  
        SET misija = "";
    END IF;
    
    IF id_os IN (SELECT id_osoblje FROM osoblje_na_treningu) THEN
        SET trening = " treningu,";
        SET brojac = brojac + 1;
    ELSE  
        SET trening = "";
    END IF;
    
    IF id_os IN (SELECT id_osoblje FROM lijecenje) THEN
        SET lijecenje = " lijecenju,";
        SET brojac = brojac + 1;
    ELSE  
        SET lijecenje = "";
    END IF;
    
    
    IF brojac = 0 THEN 
        SET odg = CONCAT(odg," nije sudjelovao/la ni u jednoj: turi, misiji,treningu ili lijecenju.");
    ELSE 
        SET odg = CONCAT(odg," je sudjelovao/la u najmanje jednoj:", tura, misija, trening, lijecenje);
    END IF; 
    
    SET odg = CONCAT(LEFT(odg, LENGTH(odg)-3),".");
    
    RETURN odg;
END//
DELIMITER ;

SELECT os_sudjelovanje(10009) AS os_sudjelovanje FROM DUAL;
```

> Neovisno o tome kako će izgledati finalni odgovor sigurni smo da će se na početku u varijablu *odg* spremiti ime i prezime osobe čiji id odgovara *id_os* koji je ulazni argument funkcije. Prvo provjeravamo s IF da li se id zadane osobe nalazi u tablici *osoblje_na_turi* jer ako se nalazi to znači da je osoba zasigurno sudjelovala u najmanje jednoj turi. U slučaju da je dani uvjet zadovoljen u varijablu *tura* će se spremiti tekst **turi,** te će varijabla *brojac* biti povećana za 1. Brojać se nalazi i u drugim IF-ovima, a njegova svrha je da se na kraju sazna da li je brojac jednak nuli. U sluačju da je brojač jednak nuli to znači da osoba nije sudjelovala ni u jednoj od potrebnih aktivnosti te se za to sprema određeni odgovor na kraju funkcije. Brojač se nalazi kod svakog IF-a jer se moramo i pobrinut i za slučajeve u kojima će biti samo jedna aktivnost za tu osobu. U slučaju da IF uvjet nije zadovoljen onda se u*tura* varijablu sprema **“”** koji označava da se to neće pridodat u finalni odgovor tj neće bit vidljiv ljudskom oku. Ostali IF-ovi funckioniraju na istom principu uz izuzetak zadnjeg. U zadnjem provjeravamo da li je *brojac* jednak nula(prije sam objasnio) te u slučaju da nije zadovoljen uvjet onda se spajaju sve varijable u kojoj je spremljen određeni tekst. Na kraju funckije se moramo još pobrinut da se na kraju rečenice nalazi znak **,** umjesto točke pa ćemo ga zamjenit s **.**

------

Performans na treningu može bit od 1 do 10 ([1,10]). Želi se pratiti za pojedini performans koliko je puta osoblje po određenim činom imalo taj performans. Ne treba prikazat čin čije osoblje nikad nije bilo dio te skupine performansa.
Format treba izgledat kao:
performans cinovi_i_br_zadanog_performansa
10 skupnik: 3 , brigadir: 3 , bojnik: 1 , pukovnik: 1 , poručnik: 2 , narednik: 2
9 pozornik: 1 , narednik: 2 , bojnik: 3 , satnik: 1 , brigadir: 2 , poručnik: 2 , skupnik: 1 , razvodnik: 1
… …

```mysql
DROP FUNCTION IF EXISTS performans_cinovi;

DELIMITER //
CREATE FUNCTION performans_cinovi(perf INTEGER) RETURNS VARCHAR(500)
DETERMINISTIC
BEGIN
    DECLARE red VARCHAR(100);
    DECLARE cin_i_br_pojavljivanja VARCHAR(800)  DEFAULT "";
    DECLARE finished INTEGER DEFAULT 0;

    DECLARE cur CURSOR FOR
    SELECT CONCAT(LOWER(cin), ": ",COUNT(*)) AS perf_des
    FROM osoblje_na_treningu
    INNER JOIN osoblje ON osoblje.id = osoblje_na_treningu.id_osoblje
    WHERE performans = perf
    GROUP BY cin;
 
    DECLARE CONTINUE HANDLER 
    FOR SQLSTATE '02000' SET finished = 1;

    OPEN cur;
         iteriraj_cinove: LOOP
             FETCH cur INTO red;
             
             IF finished = 1 THEN
                LEAVE iteriraj_cinove;
             END IF;
             
             SET cin_i_br_pojavljivanja = CONCAT(cin_i_br_pojavljivanja, ", ", red, " ");
             
         END LOOP iteriraj_cinove;
    CLOSE cur;
    
    SET cin_i_br_pojavljivanja = TRIM(LEADING "," FROM cin_i_br_pojavljivanja);
    
    RETURN cin_i_br_pojavljivanja;
END //
DELIMITER ;

SELECT DISTINCT performans, performans_cinovi(performans) AS cinovi_i_br_pojavljivanja
FROM osoblje_na_treningu
ORDER BY performans DESC;
```

> SELECT koji se nalazi nakon funkcije ju poziva i daje joj ulazni argument. Ulazni argument je INETEGER, odnosno vrijednosti performansa, a SELECT funkciji daje vrijednost performansa jedno po jedno. U funkciji ćemo koristit kursor, a kursor ćemo deklarirat na temelju SELECT-a koji prikazuje kao tekst pojedini čin i broj broj puta što je to osoblje s tim činom imalo performans koji je vanjski SELECT prilikom poziva funkcije njoj prenijo. Nakon toga ćemo deklarirat *CONTINUE HANDLER* koji će se pobrinut da nakon što FETCH-amo u prazni red se ne javi greška te da nastavimo s radom prilikom čega će varijabla *finished* koja će postat 1 omogućit će nam izlazak iz petlje(LOOP-a). U kursoru se nalazi petlja koja će pojedini redak koji se bude FETCH-ao spremiti u varijablu *red*. Nakon rada LOOP-a i korištenja HANDLER-a u *cin_i_br_pojavljivanja* će biti tekstualno “spojeni”(CONCAT()) činovi i njihov broj performansa, ali tako da se svi ti podaci za taj jedan performans nalaze u jednom redu. Na kraju funkcije moramo maknut početni zarez(jer u kursoru prvotno *cin_i_br_pojavljivanja* predstavlja “” pa je zarez prvi iznak cijelog tekstualnog izraza).

## PROCEDURE

____

Za određeni id_osoblja treba vratit koliko je sati proveo/la na misiji, na treningu a koliko na liječenju.

```mysql
DROP PROCEDURE IF EXISTS sati_provedeno_osoblje;

DELIMITER //
CREATE PROCEDURE sati_provedeno_osoblje(IN id_os INTEGER, OUT misija_h INTEGER, OUT trening_h INTEGER, OUT lijecenje_h INTEGER)
DETERMINISTIC
BEGIN

    SELECT SUM(TIMESTAMPDIFF(HOUR, vrijeme_pocetka, vrijeme_kraja)) INTO misija_h
    FROM misija
    INNER JOIN osoblje_na_misiji
    ON misija.id = osoblje_na_misiji.id_misija
    WHERE id_osoblje = id_os;
    
    SELECT IFNULL(misija_h, 0) INTO misija_h;
    
    SELECT SUM(TIMESTAMPDIFF(HOUR, vrijeme_pocetka, vrijeme_kraja)) INTO trening_h
    FROM trening
    INNER JOIN osoblje_na_treningu
    ON trening.id = osoblje_na_treningu.id_trening
    WHERE id_osoblje = id_os;
    
    SELECT IFNULL(trening_h, 0) INTO trening_h;
    
    SELECT SUM(TIMESTAMPDIFF(HOUR, pocetak_lijecenja, kraj_lijecenja)) INTO lijecenje_h
    FROM lijecenje
    WHERE id_osoblje = id_os;

    SELECT IFNULL(lijecenje_h, 0) INTO lijecenje_h;

END//
DELIMITER ;

CALL sati_provedeno_osoblje(10322, @h_m, @h_t, @h_l);
SELECT @h_m AS sati_provedeni_na_misiji, @h_t AS sati_provedeni_na_treningu, @h_l AS sati_provedeni_na_lijecenju FROM DUAL; 
```

> Ulazni argument ove procedure je id osoblja, a izlazni argumenti su INTEGER-i koji predstavljaju broj sati osobe određene id-om koje je proveo/la na misiji, liječenju i treningu(za svaki od navedenih posebna vrijednost). Kako bi saznali koliko je sati osoba provela na misiji moramo INNER JOIN-at tablicu *misija*(tu se nalaze podaci o trajanju misije, a samim time je ta osoba to vrijeme tamo provela ako se njegov/njezin id osoblja nalazi u tablici *osoblje_na_misiji* za danu misiju) i tablicu *osoblje_na_misiji*. U izlaznu varijablu ćemo spremit sumu satne razlike u svim misijama u kojima je pojedinac sudjelovao/-la. Postoji mogućnost da osoba uopće nije sudjelovala u misija/treningu/liječenju pa sbi u tom slučaju u neku od izlaznih varijabla ostao spremljen NULL. To provjeravamo s IFNULL te u slučaju da je NULL zamjenjujemo NULL s 0. Isti postupak se izvodi kako bi saznali koliko je sati osoba provela na treningu. Naglašavam da za liječenje se nije trebalo INNER JOIN-at jer se u tablici *lijecenje* nalaze nama potrebni podaci.

------

Za određeni iznos novca se gleda da li bi taj novac mogao pokriti troškove najmanje pola misija te vraća odgovor ‘DA’ ili ‘NE’

```mysql
DROP PROCEDURE IF EXISTS novac_misije;

DELIMITER //
CREATE PROCEDURE novac_misije(IN iznos DECIMAL(30, 2), OUT odg CHAR(2))
DETERMINISTIC
BEGIN
    DECLARE br_pola_misija INTEGER;
    DECLARE trosak_najmanje_polovice DECIMAL(30, 2);

    SELECT (COUNT(*)/2) INTO br_pola_misija
    FROM misija;
         
    SELECT SUM(trosak_misije) INTO trosak_najmanje_polovice
    FROM misija
    ORDER BY trosak_misije ASC
    LIMIT br_pola_misija;

    IF iznos >= trosak_najmanje_polovice THEN
        SET odg = 'DA';
    ELSE 
        SET odg = 'NE';
    END IF;
END//
DELIMITER ;

CALL novac_misije(30000000, @odg);
SELECT @odg AS Da_li_iznos_pokriva_troskove_pola_misija FROM DUAL;  
```

> U proceduri se unosi određeni broj koji predstavlja novčani iznos tipa DECIMAL(30, 2), a izlazna vrijednost procedure je tipa CHAR(2) jer se očekuje povratni odgovor u obliku ‘DA’ ili ‘NE’. Prvo moramo saznati koliki je broj misija/2 jer nas zanima za pola misija(ako je zadovoljen uvjet **najmanje** broj misija iz zadatka onda će za količinu misija manju od **najmanje** sigurno biti zadovoljen uvjet). U drugom SELECT-u ćemo saznat kolika je suma troškova broj misija/2 koje imaju najmanji troška. Potom se postavlja ispitivanje uvjeta gdje nas zanima da li je iznos veći od vrijednosti koje smo dobili u drugom SELECT-u. U slučaju da je uvjet zadovoljen onda se kao povratna vrijednost procedure postavlja ‘DA’, a u protivnom se sprema ‘NE’.

------

Treba ispisati koliki je broj osoblja, vozila, opreme trenutačno dostupno (3 vrijednosti) u danom intervalu (dva datuma koje korisnik izabere kao ulazne argumente.

```mysql
DROP PROCEDURE IF EXISTS br_dostupnog_os_vo_op;

DELIMITER //
CREATE PROCEDURE br_dostupnog_os_vo_op(IN datum_p DATETIME, IN datum_k DATETIME, OUT dost_os INT, OUT dost_vo INT, OUT dost_op INT)
DETERMINISTIC
BEGIN
   DECLARE oduzet_br_voz INTEGER;
   DECLARE oduzet_br_op INTEGER;
   
   SELECT COUNT(*) INTO dost_os
   FROM osoblje 
   WHERE id NOT IN
    (SELECT DISTINCT id_osoblje
    FROM osoblje_na_treningu
    INNER JOIN trening
    ON trening.id = osoblje_na_treningu.id_trening
    WHERE (datum_p > vrijeme_pocetka AND datum_p < vrijeme_kraja) OR (datum_k > vrijeme_pocetka AND datum_k < vrijeme_kraja)
    UNION
    SELECT DISTINCT id_osoblje
    FROM lijecenje
    WHERE (datum_p > pocetak_lijecenja AND datum_p < kraj_lijecenja) OR (datum_k > pocetak_lijecenja AND datum_k < kraj_lijecenja)
    UNION
    SELECT DISTINCT id_osoblje
    FROM osoblje_na_turi
    WHERE (datum_p > datum_pocetka AND datum_p < datum_kraja) OR (datum_k > datum_pocetka AND datum_k < datum_kraja));
    
    
    
   SELECT SUM(ukupna_kolicina) INTO dost_vo
   FROM vozila;
    
   SELECT SUM(br_voz_zauzet) INTO oduzet_br_voz
   FROM
   (SELECT COUNT(*) AS br_voz_zauzet
   FROM popravak 
   INNER JOIN vozilo_na_misiji
   ON popravak.id_vozilo_na_misiji = vozilo_na_misiji.id
   WHERE (datum_p > pocetak_popravka AND datum_p < kraj_popravka) OR (datum_k > pocetak_popravka AND datum_k < kraj_popravka)
   UNION ALL
   SELECT SUM(kolicina) AS br_voz_zauzet
   FROM misija
   INNER JOIN vozilo_na_misiji
   ON misija.id = vozilo_na_misiji.id
   WHERE (datum_p > vrijeme_pocetka AND datum_p < vrijeme_kraja) OR (datum_k > vrijeme_pocetka AND datum_k < vrijeme_kraja)) AS l;
   
   SET dost_vo = dost_vo - oduzet_br_voz;
    
    
    
    SELECT SUM(ukupna_kolicina) INTO dost_op
    FROM oprema;
    
    SELECT SUM(izdana_kolicina) INTO oduzet_br_op
    FROM izdana_oprema
    INNER JOIN osoblje_na_misiji
    ON osoblje_na_misiji.id = izdana_oprema.id_osoblje_na_misiji
    INNER JOIN 
    (SELECT id
    FROM misija
    WHERE (datum_p > vrijeme_pocetka AND datum_p < vrijeme_kraja) OR (datum_k > vrijeme_pocetka AND datum_k < vrijeme_kraja)) AS l
    ON l.id = osoblje_na_misiji.id_misija;
    
    SET dost_op = dost_op - oduzet_br_op;
END//
DELIMITER ;

CALL br_dostupnog_os_vo_op(STR_TO_DATE("1.10.1991.  12:37:13", "%d.%m.%Y. %H:%i:%s"), 
STR_TO_DATE("1.10.2013.  12:37:13", "%d.%m.%Y. %H:%i:%s"), @a, @b, @c);
SELECT  @a AS br_dostupnog_osoblja, @b AS br_dostupnih_vozila, @c AS br_dostupne_opreme FROM DUAL;
```

> Imamo dva ulazna argumenta koji su datumi te predstavljaju vremenski interval za koji ćemo morat saznat broj osoblja, vozila i opreme koji je tada slobodan. U prvom dužem izrazu unutar procedure su se brojali svi id-evi osoblja koji se nisu nalazili unutar unije. U uniji smo dohvatili sve id-eve osoblja koji su u nama danom intervalu tada bili zauzeti na treningu, lijecenju i/ili turi(nije potrebno navest misije jer tura se sastoji od misija). Prateći tu logiku mi smo dohvatili sve id-eve osoblja koji u tom intervalu nisu nigdje bili zauzeti(WHERE id NOT IN *skup id-eva osoblja koji su tada bili zauzeti*). Vrijednost COUNT-a spremamo u izlaznu varijablu. Za izračunavanje količine dostupne opreme i vozila sam koristio drugačiji pristup. Prvo se izračuna kolika je suma količine svih vozila, a nakon SELECT-a(u kojem ćemo saznat sumu količine vozila koja je zauzeta ) ćemo od sveukupne količine vozila oduzet količinu vozila koji su zauzeti u nama danom vremenskom intervalu. Samim time ćemo dobit količinu vozila koji su nam dostupni u danom intervalu. Vračajući se na SELECT za vozila treba naglasit da se sumiralo broj vozila koji su bili na popravku(tijekom intervala) i njihove količine koja je izdana za misiju. Time smo dobili sumu količine vozila koja je zauzeta te ćemo provest razliku koju sam prije naveo. Isti postupak se provodi za opremu jedino uz drugačije tablice.

------

Za dva vremenski intervala (pojedini će biti određen s dvije datumske vrijednosti) se mora odrediti pojedinačni ukupni trošak za misije, ukupni trošak za popravak, ukupni trošak za liječenje te usporedit.
Ispis treba biti u obliku:
Vremensko razdoblje od 1.10.1991. do 11.07.1998. ima manji trošak kada je riječ o misijama u usporedbi s razdobljem od 23.04.1997. do 2.12.2001.
Vremensko razdoblje od 23.04.1997. do 2.12.2001. ima manji trošak kada je riječ o popravcima u usporedbi s razdobljem od 1.10.1991. do 11.07.1998.
Vremensko razdoblje od 1.10.1991. do 11.07.1998. ima manji trošak kada je riječ liječenju u usporedbi s razdobljem od 23.04.1997. do 2.12.2001.

```mysql
DROP PROCEDURE IF EXISTS usporedba;

DELIMITER //
CREATE PROCEDURE usporedba(IN prvi_datum_p DATETIME, IN prvi_datum_k DATETIME, IN drugi_datum_p DATETIME, IN drugi_datum_k DATETIME, OUT txt_mi VARCHAR(200), OUT txt_po VARCHAR(200), OUT txt_li VARCHAR(200))
BEGIN
    DECLARE prvo_misija NUMERIC(15, 2);
    DECLARE prvo_popravak NUMERIC(15, 2);
    DECLARE prvo_lijecenje NUMERIC(15, 2);
    
    DECLARE drugo_misija NUMERIC(15, 2);
    DECLARE drugo_popravak NUMERIC(15, 2);
    DECLARE drugo_lijecenje NUMERIC(15, 2);
    
    SELECT SUM(trosak_misije) INTO prvo_misija
    FROM misija
    WHERE vrijeme_pocetka >= prvi_datum_p AND vrijeme_kraja <= prvi_datum_k;
    
    SELECT SUM(trosak_misije) INTO drugo_misija
    FROM misija
    WHERE vrijeme_pocetka >= drugi_datum_p AND vrijeme_kraja <= drugi_datum_k;
    
    IF prvo_misija = drugo_misija THEN
        SET txt_mi = CONCAT("Vremensko razdoblje od ", prvi_datum_p," do ", prvi_datum_k, " ima isti trošak kada je riječ o misijama u usporedbi s razdobljem od ",  drugi_datum_p, " do ", drugi_datum_k);
    ELSEIF prvo_misija > drugo_misija THEN
        SET txt_mi = CONCAT("Vremensko razdoblje od ", prvi_datum_p," do ", prvi_datum_k, " ima veći trošak kada je riječ o misijama u usporedbi s razdobljem od ",  drugi_datum_p, " do ", drugi_datum_k);
    ELSE
        SET txt_mi = CONCAT("Vremensko razdoblje od ", prvi_datum_p," do ", prvi_datum_k, " ima manji trošak kada je riječ o misijama u usporedbi s razdobljem od ",  drugi_datum_p, " do ", drugi_datum_k);
    END IF;
    
    
    SELECT SUM(trosak_popravka) INTO prvo_popravak
    FROM popravak
    WHERE pocetak_popravka >= prvi_datum_p AND kraj_popravka <= prvi_datum_k;
    
    SELECT SUM(trosak_popravka) INTO drugo_popravak
    FROM popravak
    WHERE pocetak_popravka >= drugi_datum_p AND kraj_popravka <= drugi_datum_k;
    
    IF prvo_popravak = drugo_popravak THEN
        SET txt_po = CONCAT("Vremensko razdoblje od ", prvi_datum_p," do ", prvi_datum_k, " ima isti trošak kada je riječ o popravcima u usporedbi s razdobljem od ",  drugi_datum_p, " do ", drugi_datum_k);
    ELSEIF prvo_popravak > drugo_popravak THEN
        SET txt_po = CONCAT("Vremensko razdoblje od ", prvi_datum_p," do ", prvi_datum_k, " ima veći trošak kada je riječ o popravcima u usporedbi s razdobljem od ",  drugi_datum_p, " do ", drugi_datum_k);
    ELSE
        SET txt_po = CONCAT("Vremensko razdoblje od ", prvi_datum_p," do ", prvi_datum_k, " ima manji trošak kada je riječ o popravcima u usporedbi s razdobljem od ",  drugi_datum_p, " do ", drugi_datum_k);
    END IF;
    
    
    SELECT SUM(trosak_lijecenja) INTO prvo_lijecenje
    FROM lijecenje
    WHERE pocetak_lijecenja >= prvi_datum_p AND kraj_lijecenja <= prvi_datum_k;

    SELECT SUM(trosak_lijecenja) INTO drugo_lijecenje
    FROM lijecenje
    WHERE pocetak_lijecenja >= drugi_datum_p AND kraj_lijecenja <= drugi_datum_k;

    IF prvo_lijecenje = drugo_lijecenje THEN
        SET txt_li = CONCAT("Vremensko razdoblje od ", prvi_datum_p," do ", prvi_datum_k, " ima isti trošak kada je riječ o lijecenju u usporedbi s razdobljem od ",  drugi_datum_p, " do ", drugi_datum_k);
    ELSEIF prvo_lijecenje > drugo_lijecenje THEN
        SET txt_li = CONCAT("Vremensko razdoblje od ", prvi_datum_p," do ", prvi_datum_k, " ima veći trošak kada je riječ o lijecenju u usporedbi s razdobljem od ",  drugi_datum_p, " do ", drugi_datum_k);
    ELSE
        SET txt_li = CONCAT("Vremensko razdoblje od ", prvi_datum_p," do ", prvi_datum_k, " ima manji trošak kada je riječ o lijecenju u usporedbi s razdobljem od ",  drugi_datum_p, " do ", drugi_datum_k);
    END IF;

END //
DELIMITER ;

CALL usporedba(STR_TO_DATE("1.10.1991.  12:37:13", "%d.%m.%Y. %H:%i:%s"), STR_TO_DATE("1.10.2013.  12:37:13", "%d.%m.%Y. %H:%i:%s"), 
               STR_TO_DATE("1.10.1995.  10:45:10", "%d.%m.%Y. %H:%i:%s"), STR_TO_DATE("1.10.2011.  19:37:16", "%d.%m.%Y. %H:%i:%s"),
@usp_mi, @usp_po, @usp_li);
SELECT  @usp_mi AS rez_usporedbe_misija, @usp_po AS rez_usporedbe_popravci, @usp_li AS rez_usporedbe_lijecenje FROM DUAL;
```

> Ulazni argumenti su datum koji predstavljaju prvi vremenski interval i drugi vremenski interval, a izlazni argumenti su tri tekstualna odgovora. Prvo ćemo deklarirat varijable u kojima ćemo spremiti troškove misija, popravka i liječenja prvog vremenskog intervala, a zatim ćemo deklarirat varijable u kojima ćemo spremiti troškove misija, popravka i liječenja drugog vremenskog intervala. Računamo trošak misija za prvo vremensko razdoblje te potom za drugo. U IF-ovima provjeravamo njih međuodnos(tj. da li su jednaki ili je neki veći od drugog) te se daje adekvatan odgovor. za njihovu usporedbu na temelju formata koji je zadan u zadatku. Isti postupak se provodi za popravak i za liječenje.

------

Treba odrediti koje misije su održane na području sjeverne polutke, a koje na području južne polutke. Prilikom navoda se koristi naziv misije. Format mora bit sličan:
Misije održane na sjevernoj polutci: naziv1, naziv2, …
Misije održane na južnoj polutci: naziv1, naziv2, …
Misije održane na ekvatoru: naziv1, naziv2, …

```mysql
DROP PROCEDURE IF EXISTS polutke_misije;

DELIMITER //
CREATE PROCEDURE polutke_misije(OUT sj_misije VARCHAR(1000), OUT ju_misije VARCHAR(1000), OUT ekv_misije VARCHAR(1000))
BEGIN
    DECLARE ime_misije VARCHAR(50) ;
    DECLARE sirina DECIMAL(10, 7);
    DECLARE finished INTEGER DEFAULT 0;

    DECLARE cur CURSOR FOR
    SELECT misija.naziv, zemljopisna_sirina
    FROM misija
    INNER JOIN lokacija
    ON misija.id_lokacija = lokacija.id;

    DECLARE CONTINUE HANDLER
    FOR SQLSTATE '02000' SET finished = 1;

    SET sj_misije = "Misije održane na sjevernoj polutci: ";
    SET ju_misije = "Misije održane na južnoj polutci: ";
    SET ekv_misije = "Misije održane na ekvatoru: ";

    OPEN cur;
        iteriraj_kordinate: LOOP

            FETCH cur INTO ime_misije, sirina;

            IF finished = 1 THEN
               LEAVE iteriraj_kordinate;
            END IF;
            
            IF sirina > 0 THEN
                SET sj_misije = CONCAT(sj_misije, ime_misije, ", ");
            ELSEIF sirina < 0 THEN
                SET ju_misije = CONCAT(ju_misije, ime_misije, ", ");
            ELSE
                SET ekv_misije = CONCAT(ekv_misije, ime_misije, ", ");
            END IF;
            
      END LOOP iteriraj_kordinate;
  CLOSE cur;
     
  SET sj_misije = TRIM(TRAILING ", " FROM sj_misije);
  SET ju_misije = TRIM(TRAILING ", " FROM ju_misije);
  SET ekv_misije = TRIM(TRAILING ", " FROM ekv_misije);
END //
DELIMITER ;

CALL polutke_misije(@sj_naziv, @ju_naziv, @ekv_naziv);

SELECT @sj_naziv AS nazivi_misija FROM DUAL
UNION
SELECT @ju_naziv FROM DUAL
UNION 
SELECT @ekv_naziv FROM DUAL;
```

> Izlazne vrijednosti ove procedure će biti tri različita VARCHAR-a koji će, kao što je navedeno u formatu, imati uz tip polutke ili ekvator naveden naziv misija koje su se na tom području održale. Možemo proučit tablice gdje ćemo vidjet da se misija održava na nekoj lokaciji, a lokacija ima podatke o zemljopisnoj dužini i širini. U ovom slučaju nas zanima samo zemljopisna širina jer ona prikazuje koordinate od gore prema dole(ili od dole prema gore) te ćemo s tim saznat ako je riječ o sjevernoj polutci, južnoj polutci ili ekvatoru. U tablici lokacija je za zempljopisna_sirina korištena mjera decimalnih stupnjeva. Važno je naglasit da vrijednosti [-90,0> (sve manje od nula)predstavljaju južnu polutku, vrijednost {0} predstavlja ekvator, a vrijednosti <0,90] (sve veće od nule)predstavljaju sjevernu polutku. Na početku procedure ćemo deklarirat varijable koje će na biti korisne za spremanje nama željenih podataka te varijabla finished koja će biti korisna kod prestanka rada petlje. Stvaramo kursor za podatke koji predstavljaju naziv misije i zemljopisnu širinu te misije. Zahvaljujući kursoru i petlji koja se nalazi u njemu možemo iterirat kod svaki red koji smo odredili kod deklariranja kursora. Vrijednosti retka kojeg dohvatimo stavljamo u varijable koje smo na početku
> deklarirali. Provjerava se za varijablu u kojoj je spremljena širina koja je vrijednost te širine te u slučaju da ta vrijednost zadovoljava intervale koje sam prije naveo onda pripada tom području. Naziv misije se pri tome pridodaje jednim od finalnih tekstualnih odgovora. Naravno prije ovoga smo deklarirali CONTINUE HANDLER kako bi riješili problem nakon
> FETCH-anja zadnjeg reda i zato jer nakon samog kursora imamo još određene operacije za
> odradit. Nakon aktiviranja CONTINUE HANDLER-a nastavljamo s radom van kursora te
> uređujemo naša tri tekstualna odgovora tako da se na kraju ne nalazi zarez već točka.

## Leo Matošević

## Program za generiranje podataka za Bazu podataka

____

Napisao sam program za lakše generiranje podataka. Program nije optimiziran niti savršen, ali je poslužio u projektu. Nakon ispisa smo izmjenili dosta podataka i ispravili ih. Preuzima imena i prezimena iz druge datoteke *imena.py*

```python
import random
from imena import ime, prezime
# variables
custom1 = []
custom2 = []
custom3 = []
custom4 = []
custom5 = []
#functions
def randname():
    return random.choice(ime)
def randprezime():
    return random.choice(prezime)

def randbool():
    x = random.randint(0, 1)
    if x == 0:
        return False
    else:
        return True

def RandNumb(brFrom, brTo):
    return random.randint(brFrom, brTo)

def Customrandname(custom=[]):
    return random.choice(custom)
         
def Date(addTime=True, addDate=False,god1=2,god2=2):
  
  vrijeme = str( random.randint( 1, 24 )) + ":" + str( random.randint( 0, 60 )) + ":" + str(random.randint( 0, 60 ))
  datum = str(random.randint( 1, 28 ))+ "." + str(random.randint( 1, 12 )) +"."+str(random.randint( god1, god2 ))+"." 

  if addTime and not addDate:
      return vrijeme
    
  elif not addTime and addDate:
      return datum

  elif addDate and addTime:
      return datum + "  " + vrijeme
  return "greska"

print("Dostupni atributi: \n [id] [ime] [prezime] \n [datum[(max 2)]] [customname[(max 5)]] [bool] \n [randnum[(max 5)]] [foreignkey[nummber] umirovljen \n Exmaple: id ime date2 customname4")
lista = list(map(str, input().split()))


for x in lista:
  if ("customname1"==x):
      for x in range(int(input("nummber of diffrent names for customnames: "))):
          custom1.append(input(str(x+1) + " name: "))
  if ("customname2"==x):
      for x in range(int(input("nummber of diffrent names for customnames: "))):
          custom2.append(input(str(x+1) + " name: "))
  if ("customname3"==x):
      for x in range(int(input("nummber of diffrent names for customnames: "))):
          custom3.append(input(str(x+1) + " name: "))
  if ("customname4"==x):
      for x in range(int(input("nummber of diffrent names for customnames: "))):
          custom4.append(input(str(x+1) + " name: "))
  if ("customname5"==x):
      for x in range(int(input("nummber of diffrent names for customnames: "))):
          custom5.append(input(str(x+1) + " name: "))

  if ("id" ==x):
      id = int(input("Id starts at? "))
    
  if ("foreignkey1" ==x):
      foreignkey1= int(input("Foreign key1 starts at? "))
  if ("foreignkey2" ==x):
      foreignkey2= int(input("Foreign key2 starts at? "))
  if ("foreignkey3" ==x):
      foreignkey3= int(input("Foreign key3 starts at? "))
  if ("foreignkey4" ==x):
      foreignkey4= int(input("Foreign key4 starts at? "))
  if ("foreignkey5" ==x):
      foreignkey5= int(input("Foreign key5 starts at? "))
  
  if ("datum1"== x):
      if input("Add Time? y/n") == "y":
          Vrijeme1 = True
      else:
          Vrijeme1 = False
      if input("Add Date? y/n") == "y":
          Datum1 = True
      else:
          Datum1 = False
      god1=input("date from: ")
      god2=input("date to: ")
        
  if ("datum2"== x):
    
      if input("Add Time? y/n") == "y":
          Vrijeme2 = True
      else:
          Vrijeme2 = False
      if input("Add Date? y/n") == "y":
          Datum2 = True
      else:
          Datum2 = False
      god3=input("date from: ")
      god4=input("date to: ")

    
        
  if ("randnum1"==x):
      start1 = input("rand number starts at? ")
      end1 = input("rand number ends at? ")
  if ("randnum2"==x):
      start2 = input("rand number starts at? ")
      end2 = input("rand number ends at? ")
  if ("randnum3"==x):
      start3 = input("rand number starts at? ")
      end3 = input("rand number ends at? ")
  if ("randnum4"==x):
      start4 = input("rand number starts at? ")
      end4 = input("rand number ends at? ")
  if ("randnum5"==x):
      start5 = input("rand number starts at? ")
      end5 = input("rand number ends at? ")

# crearting table
rj = []
rj.append("INSERT INTO " + input("Naziv Tablice? ") + " VALUES \n")

for y in range(int(input("Velicina tablice? "))):
    rj.append("(")
    for x in lista:
        
        if x == "id":
            id += 1
            rj.append(str(id) )
                #ime prezime
        elif x == "ime":
            rj.append(str('"'+randname())+'"' )
        elif x == "prezime":
            rj.append(str('"'+randprezime())+'"' )
                #datum - vrijeme
        elif x == "datum1":     #STR_TO_DATE("22.03.1991.", "%d.%m.%Y.")
           
            rj.append(str('STR_TO_DATE("'+str(Date(Vrijeme1, Datum1,int(god1),int(god2)))+'"'+', "%d.%m.%Y.")') )  
        elif x == "datum2":
              rj.append(str('STR_TO_DATE("'+str(Date(Vrijeme2, Datum2,int(god3),int(god4)))+'"'+', "%d.%m.%Y.")') )  
                #custom name
        elif x == "customname1":
            rj.append(str('"'+ Customrandname(custom1)+'"') )
        elif x == "customname2":
            rj.append(str('"'+Customrandname(custom2))+'"' )
        elif x == "customname3":
            rj.append(str('"'+Customrandname(custom3))+'"' )
        elif x == "customname4":
            rj.append(str('"'+Customrandname(custom4))+'"' )
        elif x == "customname5":
            rj.append(str('"'+Customrandname(custom5))+'"' )
                #foreign keys
        elif x == "foreignkey1":
            foreignkey1 += 1
            rj.append(str(foreignkey1) )
        elif x == "foreignkey2":
            foreignkey2 += 1
            rj.append(str(foreignkey2) )
        elif x == "foreignkey3":
            foreignkey3 += 1
            rj.append(str(foreignkey3) )
        elif x == "foreignkey4":
            foreignkey4 += 1
            rj.append(str(foreignkey4) )
        elif x == "foreignkey5":
            foreignkey5 += 1
            rj.append(str(foreignkey5) )
                #bool
        elif x == "bool":
            rj.append(str(randbool()) )
                #random nummbers
        elif x == "randnum1":
            rj.append(str(RandNumb(int(start1), int(end1))) )
        elif x == "randnum2":
            rj.append(str(RandNumb(int(start2), int(end2))) )
        elif x == "randnum3":
            rj.append(str(RandNumb(int(start3), int(end3))) )
        elif x == "randnum4":
            rj.append(str(RandNumb(int(start4), int(end4))) )
        elif x == "randnum5":
            rj.append(str(RandNumb(int(start5), int(end5))) )
        
        rj.append(",")
    rj=rj[:-1]
    rj.append("),\n")
print(*rj, end=");")
```

## Flask aplikacija koja se povezuje s MySQL bazom podataka nazivom "vojska"

<hr>

### 	Korišteni Alati:

- **Python**

- **Flask**

- **mysql-connector**

- **numpy**

- **matplotlib.pyplot**

- **HTML**

- **CSS**

### Definira nekoliko funkcija koje interagiraju s bazom podataka:

- `BP_DataRow(sql)`: Izvršava dani SQL upit i vraća **jedan red** podataka iz rezultata.

  ```python
   # Get data row from Database
  def BP_DataRow(sql):
      vojska = mysql.connector.connect(host = 'localhost', database = 'vojska', user = 'root', password = 'root')
      MainKursor = vojska.cursor()
      MainKursor.execute(sql)
      return MainKursor.fetchone()
  ```

- `BP_DataAll(sql)`: Izvršava dani SQL upit i vraća **sve redove** podataka iz rezultata.

  ```python
      # get data ALL from Database
  def BP_DataAll(sql):
      vojska =  mysql.connector.connect(host = 'localhost', database = 'vojska', user = 'root', password = 'root')
      MainKursor = vojska.cursor()
      MainKursor.execute(sql)
      return  MainKursor.fetchall()
  ```

- `BP_Command(sql)`: Izvršava dani SQL naredbu (npr. *insert*, *update*, *delete*) i potvrđuje promjene u bazi podataka.

  ```python
      # Function for Using Raw mysql commands
  def BP_Command(sql):
      vojska = mysql.connector.connect(host = 'localhost', database = 'vojska', user = 'root', password = 'root')
      MainKursor = vojska.cursor()
      MainKursor.execute(sql)
      vojska.commit()
      return "Done"
  ```

- `BP_UpdateSql(tablename, data)`: generira i izvršava SQL naredbu za ažuriranje, te poziva funkciju **BP_Command(sql)** za izvršavanje naredbe.

  ```python
      # Function for Updating Tables
  def BP_UpdateSql(tablename,data):
      sql = "UPDATE "+ tablename+" SET "
      tabela = BP_DataAll("Show COLUMNS from "+tablename+";")
  
      for x in range(2,len(data)):
          sql = sql+ str(tabela[x][0]) + " = '" + str(data[x]) +"',"
  
      sql = sql [ : -1]
      sql = sql + " WHERE "+ str(tabela[0][0]) +" = "+ str(data[0])+";"
      print(sql)
      BP_Command(sql)
      return "Done"
  ```

- `BP_Insert(array, tablica, maxId)`: generira i izvršava SQL naredbu za umetanje.

  ```python
       # Function for Inserting Tables
  def BP_Insert (array, tablica,maxId):
      sqlTxt="INSERT INTO "+ tablica+" VALUES("+ str(maxId)+","
      for x in array:
          
          if x == int:
              sqlTxt += x
          elif x:
              sqlTxt += "'"+x+"',"
  
      sqlTxt =sqlTxt[:-1] 
      sqlTxt += ");"
     
      BP_Command(sqlTxt)
  ```

### Također definira nekoliko pomoćnih funkcija:

- `RandomImageGenerator()`: vraća nasumično odabrani put slike iz predefiniranog skupa slika profila.
- `SortTwoDimensionalTuple(lst, reverseType)`: sortira dvodimenzionalni tuple na temelju predzadnjeg elementa u svakom pod-tupleu.
- `GetCin(cin, sektor)`: vraća izmijenjenu verziju dana čina (cin) na temelju dana sektora (sektor) kako bi se kasnije moglo koristiti za slike.

```python
                # Random functions
        #Generates random nummber for profile pictures
def RandomImageGenerator():
    x = str(randrange(5))
    return "/static/img/profPictures/"+x+".png"

        #Sort Two Dimensional Tuple
def SortTwoDimensionalTuple(lst,reverseType):
    return sorted(lst, key=lambda x: x[-2],reverse= reverseType)

        # Outputs Ranks with ther correct picture format
def GetCin(cin,sektor):
    if sektor == "Hrvatska ratna mornarica":
        cin = str(cin) +"_p"

    elif sektor == "Hrvatsko ratno zrakoplovstvo":
        cin = str(cin) +"_z"
    return cin
```

# Login

Ovaj kod definira rutu u Flask aplikaciji koja je dostupna putem GET ili POST zahtjeva na osnovnu URL ("/"). Kada se pristupi ruti, izvršava se funkcija `login()`.

Funkcija počinje povezivanjem s MySQL bazom podataka “vojska” na lokalnom poslužitelju s “root” i “root” i stvara kursor objekt za izvršavanje upita.

Ako je metoda zahtjeva POST zahtjev, funkcija preuzima vrijednosti “username” i “password” iz podataka *form* zahtjeva i dodjeljuje ih varijablama `name` i `UpisLozinka`.

Zatim funkcija stvara SELECT upit koji spaja varijable `name` i `UpisLozinka` i hasha ih s md5. Zatim uspoređuje hashed vrijednost s poljem “lozinka” u tablici “login”. Ako upit ne vraća nijedan red, varijabla error se postavlja na tekst “Kriva lozinka pokusaj ponovno!” .

Ako upit vraća red, funkcija dohvaća podatke iz tablica “osoblje” i “sektor”, te prosljeđuje u “index.html” gdje su prikazani, ako su podaci ispravni. U svakom slučaju, funkcija vraća “Login.html” sa varijablom error koja prikazuje eventualnu pogrešku.

```python
# Route for handling the login page
@app.route('/', methods = ['GET', 'POST'])
def login():
  
    vojska = mysql.connector.connect(host = 'localhost', database = 'vojska', user = 'root', password = 'root')
    krusor = vojska.cursor()
    error = ""

    if request.method == 'POST':

        global name
        global UpisLozinka

        name = request.form['username']
        UpisLozinka = request.form['password']
        
        krusor.execute("select * from login where md5(concat('"+name+"','"+UpisLozinka+"')) = lozinka;")
                        
        error=""
        if krusor.fetchone() == None:
            error = 'Kriva lozinka pokusaj ponovno!'

        else:
            osoblje=BP_DataRow("select osoblje.ime,prezime,cin,datum_rodenja,datum_uclanjenja,status_osoblja,krvna_grupa from login,osoblje where lozinka = md5(concat('"+name+"','"+UpisLozinka+"')) and osoblje.ime = '"+name+"';")
            
            VojskaText = BP_DataAll("select opis from sektor;")
           
            global randimg
            randimg = RandomImageGenerator()
            return render_template('index.html', randimg = randimg , ime = name, VojskaText = VojskaText, cin = osoblje[2])
    
    return render_template('Login.html',error = error)
```

<img src="https://cdn.discordapp.com/attachments/913822778988331009/1064179407935250432/image.png"/>

## Tablica login u mysql

Izradio sam tablicu login koja sprema sva korisnička imena i lozinke korisnika, te trigger koji hasira lozinku prije unosa u login

 **Napomena**

> *Lozinke su lako “Provaliti” jer koristi se metoda md5(ime+prezime) za izradu lozinke u “Stvarnom” životu sam zamislio da svaki vojnik dobije svoju lozinku i korisnički račun*

```mysql
-- BACKEND:
CREATE TABLE login(
    id INTEGER primary KEY,  -- autoincrement
    ime varchar(100),
    lozinka varchar(100)
);
-- DROP TABLE login;
DELIMITER //
CREATE TRIGGER kriptiranje
 BEFORE INSERT ON osoblje
 FOR EACH ROW
BEGIN
 INSERT INTO login VALUES (new.id,new.ime,md5(concat(new.ime,new.prezime)));
 -- SET new.lozinka = MD5(new.lozinka);
END//
DELIMITER ;
```

# Profile

Ovaj kod kreira “profile” stranicu koja prikazuje informacije o korisniku koji se trenutno prijavio. Kada se korisnik prijavi, kod koristi ime i lozinku koje je korisnik unio da bi dobio informacije o korisniku iz baze podataka. Informacije uključuju ime, prezime, čin, datum rođenja, datum učlanjenja, status osoblja i krvnu grupu. Također se dobiva i naziv sektora u kojem korisnik radi. Konačno, poziva se funkcija “GetCin” koja dobiva čin korisnika na temelju njegovog čina i sektora. Sve te informacije se zatim prikazuju korisniku na profile stranici.

```mysql
# Route for handling the Profile page
@app.route('/profile', methods = ['GET', 'POST'])
def profile():
    
    osoblje= BP_DataRow("select osoblje.ime,prezime,cin,datum_rodenja,datum_uclanjenja,status_osoblja,krvna_grupa from login,osoblje where lozinka = md5(concat('"+name+"','"+UpisLozinka+"')) and osoblje.ime = '"+name+"';")
    sektor = BP_DataRow("select sektor.naziv from login,osoblje,sektor where lozinka = md5(concat('"+name+"','"+UpisLozinka+"')) and osoblje.ime = '"+name+"' and osoblje.prezime='"+UpisLozinka+"' and id_sektor = sektor.id;")
    cin= GetCin(osoblje[2],sektor[0])

    return render_template('profile.html', randimg = randimg, osoblje = osoblje, sektor = sektor, cin = cin)
    
```

<img src="https://cdn.discordapp.com/attachments/913822778988331009/1064180051383439390/image.png"/>

# Insert

Ovaj kod služi za obradu zahtjeva koji se odnose na stranicu za uređivanje podataka u tablici baze podataka. Prvo se dohvaćaju podaci iz baze podataka koji su potrebni za ispis na stranici, kao što su podaci o lokaciji i ture. Zatim se dohvaća maksimalni ID iz odabrane tablice. Kada se korisnik želi unijeti novi red u tablicu, kod će izvršiti unos podataka u tablicu. Ako dođe do bilo kakve pogreške pri unosu, ispisat će se poruka o pogrešci.

```python
# Route for handling the Edit -> Insert page
@app.route('/izmjena/insert/<tablica>', methods = ['GET', 'POST'])
def database(tablica):
    
            # Get Data
    error=""
    lokacija = BP_DataAll("select id, naziv from lokacija;")
    tura = BP_DataAll("select id, naziv from tura;")
    maxid = BP_DataRow("select max(id) from "+tablica+" limit 1") 
    getData = BP_DataAll("Select * from "+ tablica+" ;")
    try:
     getRowLen = len(getData[0])
    except:
        getRowLen=0
        print("empty")
 
    try:     
        if request.method == 'POST':
                if tablica :

                    polje = []
                    for x in range(10):
                        if "podatak"+str(x) in request.form:
                            polje.append(request.form["podatak"+str(x)])

                    BP_Insert(polje,tablica,maxid[0]+1)
                    print("Uspjesno dodano!")
                    if error != "":                   
                            error= "Uspjesno Dodano!"            
            
    except Exception as e:
                  error=e
    
    return render_template('izmjena.html',cinovi=cinovi,cinLen= len(cinovi),tablica= tablica,tura = tura,turaLen = len(tura),lokacija=lokacija,lokacijaLen = len(lokacija),getData=getData, getDatalen = len(getData),getRowLen=getRowLen,error=error,maxid=maxid)
```

![alt text](https://cdn.discordapp.com/attachments/913822778988331009/1064313054956900472/image.png)

# Update

Ovaj kod predstavlja rutu koja se uređuje bazu podatak unutar aplikacije. Funkcija “Update” prima jedan argument “tablica” koji predstavlja naziv tablicu u bazi podataka na koju se želi izvršiti promjena.

U početku se dohvaćaju podaci iz tablica “lokacija” i “tura”, te se dohvaća maksimalni ID iz zadane tablica. Nakon toga se dohvaća svi podaci iz zadane tablica i provjerava je li tablica prazna. Ako je prazna, ispisuje se “empty”.

Kada se pritisne “POST” tipka na formi, preuzima sve podatke iz forme te ih sprema u polje, nakon toga koristeći funkciju BP_UpdateSql(tablica,polje) gdje su ulazni podatci tablica odnosno ime tablice i polje sa podatcima koji se kasnije ažuriraju u bazu podataka.

Na kraju se poziva “render_template” funkcija koja prikazuje “update.html” sa svim dohvaćenim podacima i varijablama.

```mysql
# Route for handling the Edit -> Update page
@app.route('/izmjena/update/<tablica>', methods = ['GET', 'POST'])
def Update(tablica):
    error=""
    lokacija = BP_DataAll("select id, naziv from lokacija;")
    tura = BP_DataAll("select id, naziv from tura;")
    maxid = BP_DataRow("select max(id) from "+tablica+" limit 1") 

        # getting id 
    getData = BP_DataAll("Select * from "+ tablica+" ;")
    try:
     getRowLen = len(getData[0])
    except:
        getRowLen=0
        print("empty")
    ImportID = BP_DataAll("select id from "+tablica+";")
    ImportData=[]
    poljeID= []
    for x in range(len(ImportID)):
        poljeID.append(ImportID[x][0])

    if request.method == 'POST':
        
            if tablica:
                        # nova laksa metoda
                polje = []
                for x in range(10):
                    if "podatak"+str(x) in request.form:
                        polje.append(request.form["podatak"+str(x)])
                BP_UpdateSql(tablica,polje)
                return redirect("/izmjena/update/"+tablica, code=302)
    
    return render_template('update.html',ImportData= ImportData,poljeID = poljeID,ImportID=ImportID,cinovi=cinovi,cinLen= len(cinovi),tablica= tablica,tura = tura,turaLen = len(tura),lokacija=lokacija,lokacijaLen = len(lokacija),getData=getData, getDatalen = len(getData),getRowLen=getRowLen,error=error,maxid=maxid)
    
```

<img src="https://cdn.discordapp.com/attachments/913822778988331009/1064181165264740382/image.png"/>

## Update s određenim id-em

Ova funkcija je skoro ista kao prijasni update, samo je razlika u tome sto prima ID i ažurira formu sa podatcima toga id-a

```python
# Route for handling the Edit -> Update -> ID page
@app.route('/izmjena/update/<tablica>/<ID>', methods = ['GET', 'POST'])
def UpdateFetchId(tablica,ID):
    getData =   BP_DataAll("Select * from "+ tablica+" ;")
    popravak = BP_DataAll("select id_vozilo_na_misiji,misija.naziv from popravak,vozilo_na_misiji,misija where id_vozilo_na_misiji = vozilo_na_misiji.id and vozilo_na_misiji.id_misija = misija.id;")
   
    try:
     getRowLen = len(getData[0])
    except:
        getRowLen=0
        print("empty")
    error=""
    lokacija = BP_DataAll("select id, naziv from lokacija;")
    tura = BP_DataAll("select id, naziv from tura;")
    maxid = BP_DataRow("select max(id) from "+tablica+" limit 1") 
    ImportID = BP_DataAll("select id from "+tablica+";")
    ImportData = BP_DataRow("select * from "+tablica+" where id = "+ID+";")
    poljeID= []

    osobljeIme = BP_DataAll("Select id,ime from osoblje;")
    for x in range(len(ImportID)):
        poljeID.append(ImportID[x][0])

   

    if request.method == 'POST':
            getData =   BP_DataAll("Select * from "+ tablica+" ;")
            if tablica:
                        # nova laksa metoda
                polje = []
                for x in range(10):
                    if "podatak"+str(x) in request.form:
                        polje.append(request.form["podatak"+str(x)])
                BP_UpdateSql(tablica,polje)
                return redirect("/izmjena/update/tura/"+ str(ID), code=302)
            


    return render_template('update.html',osobljeIme=osobljeIme,osobljeImeLen=len(osobljeIme),popravak=popravak,popravakLen = len(popravak),ImportData=ImportData,poljeID = poljeID,ImportID=ImportID,cinovi=cinovi,cinLen= len(cinovi),tablica= tablica,tura = tura,turaLen = len(tura),lokacija=lokacija,lokacijaLen = len(lokacija),getData=getData, getDatalen = len(getData),getRowLen=getRowLen,error=error,maxid=maxid)
```

# Infromacije

Ovaj kod predstavlja rutu koja se koristi za obradu stranicu “informacije” u aplikaciji. Funkcija “informacije” prima dva argumenta “data” i “sektor”.

Prvo se provjerava što se unosi u “sektor” i prema tome se pridjeljuje vrijednost “SektorId” (1,2,3 ili 4). Nakon toga se dohvaćaju podaci iz tablica “osoblje”, “osoblje_na_misiji” i “misija” te se prikazuju podaci o osoblju iz zadnog sektora koji su na misiji s nazivom “data”. Slično se dohvaćaju i podaci o vozilima koji su na misiji “data”.

Nakon toga se koriste funkcije “pie” i “BP_DataAll” za dohvaćanje podataka o troškovima misije, broju osoblja na misiji i količini vozila na misiji te se prikazuju u obliku grafova.

```python
# Route for handling informacije (Info) page
@app.route('/informacije/<sektor>/<data>')  #Exception
def informacije (data,sektor):

    if sektor == "Kopnena Vojska":
        SektorId = "1"
    elif sektor == "Ratna Mornarica":
        SektorId = "2"
    elif sektor == "Ratno Zrakoplovstvo":
        SektorId = "3"
    elif sektor == "Vojna Policija":
        SektorId = "4"
    
    osoblje = BP_DataAll("select osoblje.ime,osoblje.prezime,osoblje.cin,osoblje.krvna_grupa from osoblje,osoblje_na_misiji,misija where osoblje.id =osoblje_na_misiji.id_osoblje and  osoblje_na_misiji.id_misija = misija.id and osoblje.id_sektor = "+SektorId+" and  misija.naziv = '"+data+"' ;")
    vozila = BP_DataAll("select vozila.naziv,vozila.vrsta,vozila.ukupna_kolicina,vozila.kapacitet from misija,vozilo_na_misiji,vozila where misija.id = vozilo_na_misiji.id_misija and vozilo_na_misiji.id_vozilo = vozila.id and misija.naziv = '"+data+"';")
    
    
            #troskovi misija
    pie("troskovi","select ( select sum(trosak_misije)from misija), 'Trošak svih misija'from misija where naziv = '"+data+"' union select trosak_misije, naziv from misija where naziv = '"+data+"' ;",fileType="svg")

    Troskovi = BP_DataAll("select ( select sum(trosak_misije)from misija), 'Trošak svih misija'from misija where naziv = '"+data+"' union select trosak_misije, naziv from misija where naziv = '"+data+"' ;")
    
    
            #kolicina osoblja na misiji
    pie("osoblje","select count(*), 'Osoblja na misiji' from osoblje,osoblje_na_misiji,misija where osoblje.id =osoblje_na_misiji.id_osoblje and  osoblje_na_misiji.id_misija = misija.id and osoblje.id_sektor = "+SektorId+" and  misija.naziv = '"+data+"' union select count(id),'Svo osoblje' from osoblje ;select count(id),'Svo osoblje' from osoblje ;",fileType="svg")
            
    Osoblje = BP_DataAll("select count(*), 'Osoblja na misiji' from osoblje,osoblje_na_misiji,misija where osoblje.id =osoblje_na_misiji.id_osoblje and  osoblje_na_misiji.id_misija = misija.id and osoblje.id_sektor = "+SektorId+" and  misija.naziv = '"+data+"' union select count(id),'Svo osoblje' from osoblje ;select count(id),'Svo osoblje' from osoblje ;")

            #kolicina vozila na misiji
    pie("vozila","select sum(ukupna_kolicina), 'vozilo na misiji' from misija,vozilo_na_misiji,vozila where misija.id = vozilo_na_misiji.id_misija and vozilo_na_misiji.id_vozilo = vozila.id and misija.naziv = '"+data+"' union select sum(ukupna_kolicina),'ukupna kolicina svih vozila' from vozila ;",fileType="svg")

    Vozila = BP_DataAll("select sum(ukupna_kolicina), 'vozilo na misiji' from misija,vozilo_na_misiji,vozila where misija.id = vozilo_na_misiji.id_misija and vozilo_na_misiji.id_vozilo = vozila.id and misija.naziv = '"+data+"' union select sum(ukupna_kolicina),'ukupna kolicina svih vozila' from vozila ;")

    return render_template('informacije.html',Vozila = Vozila ,Troskovi = Troskovi, Osoblje = Osoblje, sektor=sektor,data=str(data),Svozila="vozila.svg",Sosoblje="osoblje.svg",Stroskovi="troskovi.svg",osoblje=osoblje,vozila=vozila, len2=len(osoblje),lenVozila = len(vozila),)
```

<img src="https://cdn.discordapp.com/attachments/913822778988331009/1064311935971115089/image.png"/>



## [Graph.py](http://graph.py/)

Ovaj kod koristi matplotlib i mysql.connector biblioteke za generiranje i spremanje dijagrama pie podataka iz baze podataka. Funkcija prima naslov dijagrama, SQL upit za dohvaćanje podataka iz baze podataka, naziv datoteke za spremanje, boju dijagrama, vrstu datoteke i veličinu fonta. Funkcija dohvaća podatke iz baze podataka pomoću SQL upita i pohranjuje ih u varijable. Dohvaćene vrijednosti se koriste za generiranje kružnog dijagrama pomoću matplotlib biblioteke. Dijagram se nakon toga sprema kao slika u određenu mapu i prikazuje na html stranici.

```python
import matplotlib.pyplot as plt
import numpy as np
import mysql.connector

def pie(title, mySql, fileName="test", color="winter", fileType="png", font=15):
    
    vojska = mysql.connector.connect(host='localhost',database='vojska',user='root',password='root')
    MainKursor = vojska.cursor()
    MainKursor.execute(mySql)
    data = MainKursor.fetchall()

    MainKursor.close()
    nummberItems = len(data)
    labels = []
    stuff = []
    for x in range(nummberItems):
        stuff.append(data[x][0])
        labels.append(data[x][1])

       
    for x in range(len(stuff)):
        if stuff[x] == None:
            stuff[x]=0
            
    plt.rc('font', size=2)  
    plt.style.use('_mpl-gallery-nogrid')
    colors = plt.get_cmap(color)(np.linspace(0.2, 0.7, len(stuff)))

  
    fig, ax = plt.subplots()

    ax.pie(stuff, colors=colors, autopct="%1.1f%%", labels=labels, wedgeprops={"linewidth": 1, "edgecolor": "white"})
    ax.legend(loc='lower right')
    
    saveTo = 'static/img/statistics/'
    plt.savefig(saveTo + (title + "." + fileType), dpi=500)
    print("Info:" + str(data))
    
```

Prikaz grafa izrađen u *[graph.py](http://graph.py/)* datoteka je u obliku *svg*

<img src="https://cdn.discordapp.com/attachments/913822778988331009/1064182197709455480/image.png" alt="troskovi" />

# Misije

Ovaj kod predstavlja rutu koja se koristi za obradu stranice “Misija” u aplikaciji. Funkcija “PrikazTura” prima dva argumenta “misija” i “sektor”.

Prvo se provjerava što se unosi u “sektor” i prema tome se pridjeljuje vrijednost “SektorId” (1,2,3 ili 4). Nakon toga se dohvaćaju podaci iz tablica “tura” i “misija” te se prikazuju svi podaci o turama i misijama koje su povezane s nazivom misije “misija”. Slično se dohvaćaju i podaci o datumima početka i kraja tih misija.

Na kraju se poziva “render_template” funkcija koja prikazuje predložak “misija.html” sa svim dohvaćenim podacima i varijablama.

```python
# Route for handling Mission page
@app.route('/<sektor>/<misija>') 
def PrikazTura (misija,sektor):
    
    if sektor == "Kopnena Vojska":
        SektorId = "1)"
    elif sektor == "Ratna Mornarica":
        SektorId = "2"
    elif sektor == "Ratno Zrakoplovstvo":
        SektorId = "3"
    elif sektor == "Vojna Policija":
        SektorId = "4"

    data = BP_DataAll('select naziv,vrsta_ture,date(vrijeme_pocetka),date(vrijeme_kraja) from tura;')
    MisijenaTuri= BP_DataAll("select * from tura,misija where tura.id = misija.id_tura and tura.naziv ='"+misija.replace('%20'," ")+"';")
    MisijenaTuriDatumi= BP_DataAll("select date(misija.vrijeme_pocetka), date(misija.vrijeme_kraja) from tura,misija where tura.id = misija.id_tura and tura.naziv ='"+misija.replace('%20'," ")+"';")
    return render_template('misija.html',SektorId=SektorId,sektor = sektor,MisijenaTuri=MisijenaTuri,data=data,misija=misija,MisijenaTuriDatumi=MisijenaTuriDatumi,len=len(data),len2=len(MisijenaTuri))
```

<img src="https://cdn.discordapp.com/attachments/913822778988331009/1064312038538616852/image.png"/>



# Statistika

Ovaj kod predstavlja rutu koja se koristi za obradu stranice “Statistika” u aplikaciji. Funkcija “statistika” ne prima nikakve argumente.

U ovom kodu se koriste neki SQL upiti koji se izvršavaju preko funkcije BP_DataRow() i BP_DataAll(). Ovi upiti se koriste za dohvaćanje različitih podataka iz baze podataka, kao što su ukupni trošak, višak novca, informacije o turama, troškovi misija, popravaka i liječenja, te podaci o osoblju.

Nakon što se svi podaci dohvate, koristi se “render_template” funkcija koja prikazuje predložak “statistika.html” sa svim dohvaćenim podacima i varijablama.

```python
# Route for handling Statistics page
@app.route("/statistika", methods = ['GET', 'POST'])
def statistika():

    trosak = BP_DataRow("SELECT trosak() AS ukupni_trosak FROM DUAL;")
    visak = BP_DataRow("SELECT visak() AS visak FROM DUAL;")
    kuna = str(visak[0])[:-3]
    euri=float(visak[0]) // float(7.53)
    tura_informacije = BP_DataAll("SELECT * FROM tura_informacije;")

        #troskovi
    trosak_misije = BP_DataAll("SELECT * FROM (SELECT IFNULL(DATE(vrijeme_kraja), DATE(NOW())) AS datum, SUM(trosak_misije) AS trosak_misije FROM misija GROUP BY DATE(vrijeme_kraja)) AS l ORDER BY datum ASC;")
    trosak_popravak = BP_DataAll("SELECT * FROM (SELECT IFNULL(DATE(kraj_popravka), DATE(NOW())) AS datum, SUM(trosak_popravka) AS trosak_popravka FROM popravak GROUP BY DATE(kraj_popravka)) AS l ORDER BY datum ASC;")
    trosak_ljecenje = BP_DataAll("SELECT * FROM (SELECT IFNULL(DATE(kraj_lijecenja), DATE(NOW())) AS datum, SUM(trosak_lijecenja) AS trosak_lijecenja FROM lijecenje GROUP BY DATE(kraj_lijecenja)) AS l ORDER BY datum ASC;")
    trosak_svega = BP_DataAll("SELECT SUM(trosak_misije) AS trosak_svih_misija FROM misija union  SELECT SUM(trosak_popravka) AS trosak_svih_popravka FROM popravak union SELECT SUM(trosak_lijecenja) AS trosak_svih_lijecenja FROM lijecenje;")
        #osoblje
    kopnenaBroj = BP_DataRow("SELECT broj_osoblja_u_sektoru(1) AS broj_osoblja_u_sektoru;")
    mornaricaBroj = BP_DataRow("SELECT broj_osoblja_u_sektoru(2) AS broj_osoblja_u_sektoru;")
    zrakoplovnaBroj = BP_DataRow("SELECT broj_osoblja_u_sektoru(3) AS broj_osoblja_u_sektoru;")
    policijaBroj = BP_DataRow("SELECT broj_osoblja_u_sektoru(4) AS broj_osoblja_u_sektoru;")
    godine = BP_DataAll("SELECT osoblje_godina, COUNT(*) AS broj_osoba_s_tim_godinama FROM (select id, timestampdiff(year,datum_rodenja,curdate()) as osoblje_godina  from osoblje) AS l GROUP BY osoblje_godina;")
    statusosoblja = BP_DataAll("SELECT status_osoblja, COUNT(*) AS broj_pojedinaca_u_statusu FROM osoblje GROUP BY status_osoblja;")
    cinosoblje = BP_DataAll("SELECT cin, COUNT(*) AS broj_pojedinaca_u_statusu FROM osoblje GROUP BY cin;")

    return render_template('statistika.html',cinosoblje=cinosoblje,cinosobljeLen=len(cinosoblje),statusosoblja=statusosoblja,statusosobljaLen = len(statusosoblja),godineLen= len(godine),godine=godine,kopnenaBroj = kopnenaBroj, mornaricaBroj= mornaricaBroj, zrakoplovnaBroj = zrakoplovnaBroj, policijaBroj= policijaBroj,trosak=trosak,trosak_svega=trosak_svega,trosak_ljecenje=trosak_ljecenje,trosak_ljecenjeLen=len(trosak_ljecenje),trosak_popravak=trosak_popravak,trosak_popravakLen=len(trosak_popravak),trosak_misije=trosak_misije,trosak_misijeLen=len(trosak_misije),euri=euri,kuna=kuna,visak= visak,tura_informacije=tura_informacije,tura_informacijeLen = len(tura_informacije))
```

## Prikaz statistike

*U html sam koristio* *chart.js* *koji mi omogućio uljepšani prikaz statistike*

<img src="https://cdn.discordapp.com/attachments/913822778988331009/1064212187687694407/statistika.png"/>

# Ocjenjivanje

Ovaj kod je ruta za obradu stranice za ocijenjivanje. Korisniku se prikazuje popis osoblja sa njihovim imenom, prezimenom, činom, ocjenom i sektorom te omogućuje mu da traži određeno osoblje po imenu, prezimenu ili činu. Ukoliko korisnik želi, može sortirati popis osoblja po ocjeni u rastućem ili opadajućem redoslijedu. Ukoliko korisnik unese nepostojeće ime, prezime ili čin, dobit će poruku o grešci.

```python
# Route for handling Rating (Ocijenjivanje) page
@app.route("/ocjenjivanje/<Stype>", methods = ['GET', 'POST'])  #Exception
def ocjenjivanje(Stype):  

    osoblje = BP_DataAll("select ime, prezime,cin,ocjena,sektor.naziv from osoblje,sektor where osoblje.id_sektor = sektor.id;")
    accountRating = BP_DataRow("select ocjena from osoblje where ime = '"+name+"' and prezime = '"+ UpisLozinka+"';")
    
    if request.method == 'POST':
        Search = request.form['search']
        
        
        if Search.lower() in cinovi:
            
            osoblje = BP_DataAll("select ime, prezime,cin,ocjena,sektor.naziv  from osoblje,sektor where cin = '"+Search+"';")
            return render_template('ocjenjivanje.html',accountRating=accountRating,name=name,err = "Ocijenjivanje",Stype=Stype, note = "error", desc = "ocjena",ime=name,osoblje = osoblje, lenosoblje = len(osoblje))    
        

        else:
            osoblje = BP_DataAll("select ime, prezime,cin,ocjena,sektor.naziv  from osoblje,sektor where ime = '"+Search+"';")
            
          
            if osoblje != []:
                return render_template('ocjenjivanje.html',accountRating=accountRating,name=name,err = "Ocijenjivanje",Stype=Stype, note = "error", desc = "ocjena",ime=name,osoblje = osoblje, lenosoblje = len(osoblje))    
            
            
            else:
                osoblje = BP_DataAll("select ime, prezime,cin,ocjena,sektor.naziv  from osoblje where prezime = '"+Search+"';")
                return render_template('ocjenjivanje.html',accountRating=accountRating,name=name,err = "Ocijenjivanje",Stype=Stype, note = "error", desc = "ocjena",ime=name,osoblje = osoblje, lenosoblje = len(osoblje))    


    if Stype == 'asc': 
        osoblje= SortTwoDimensionalTuple(osoblje,False)
        

    if Stype == 'desc':
        osoblje= SortTwoDimensionalTuple(osoblje,True)
        
    


    return render_template('ocjenjivanje.html',accountRating=accountRating,name=name,err = "Ocijenjivanje",Stype=Stype, note = "error", desc = "ocjena",ime=name,osoblje = osoblje, lenosoblje = len(osoblje))    
```

<img src="https://cdn.discordapp.com/attachments/913822778988331009/1064183143281721574/image.png"/>

# Errori

Ovaj kod je za obradu grešaka u slučaju da se korisnik nađe na nepostojećoj stranici ili ako se dogodi neka druga pogreška. Prva funkcija @app.errorhandler(505) se koristi za obradu greške kada se korisnik nađe na nepostojećoj stranici i vraća predložak “404.html” sa određenim varijablama (err, note, desc, ime) koji se koriste u predlošku. Druga funkcija @app.errorhandler(505) se koristi za obradu bilo kakve druge greške koja se pojavi i također vraća predložak “404.html” sa određenim varijablama (err, note, desc, ime) koji se koriste u predlošku.

```python
                        # Error if you are lost
@app.errorhandler(505)
def page_not_found(error):
    return render_template('404.html', err = "4o4 error ", note = "programur profesional", desc = "What are you looking for here silly?", ime = name,)



@app.errorhandler(505)  #Exception error if anything goes wrong
def page_not_found(error):  
    return render_template('404.html', err = "PlEaSe ReFrEsH eVeRyThInG", note = error, desc = "brrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr",ime=name,)    
```

<img src="https://cdn.discordapp.com/attachments/913822778988331009/1064183730186502214/image.png"/>

<img src="https://cdn.discordapp.com/attachments/913822778988331009/1064184421302947841/image.png"/>

# HTML

> Također imam puno flask koda unutar samih html datoteka, ali smatram da bi to oduzelo puno mjesta
>
> primjer koda:

```html
        {% for i in range(0, lenosoblje) %}
        <div class="ocjena">
                <h3>#{{i+1}}</h3>
               
                <h3>ime: {{osoblje[i][0]}}</h3>
                <h3>Prezime: {{osoblje[i][1]}}</h3>
                <h3>Čin: {{osoblje[i][2]}}</h3>

                {% if osoblje [i][4] == "Hrvatska ratna mornarica" %}
                <h3> <img src="/static/img/cin/{{osoblje[i][2]}}_p.png"></h3>
                
                {% elif osoblje [i][4] == "Hrvatsko ratno zrakoplovstvo" %}
                <h3> <img src="/static/img/cin/{{osoblje[i][2]}}_z.png"></h3>

                {% else %}
                <h3> <img src="/static/img/cin/{{osoblje[i][2]}}.png"></h3>

                {% endif %}
                
                <h3>{{osoblje[i][3] * '⭐'}}</h3>
                <h3>Ocijena: {{osoblje[i][3]}}</h3>
                <h3>{{osoblje[i][4]}}</h3>
        </div>
        <hr>
        {%endfor%}
```





## Filippo Bubić

**Funkcija za popis opreme**

*@app.route* je dekorator koji povezuje našu funkciju s određenim adresom. 

Funkcija je stvorena za pregled opreme prema:

- *nazivu opreme* 

- *vrsti opreme*

Nadalje omogućena je pretraga prema sljedećim karakteristikama:

- ```python
  "select naziv, vrsta, ukupna_kolicina from oprema where naziv = '%"+Search+"%';
  ```

- ```python
  "select naziv, vrsta, ukupna_kolicina from oprema where vrsta = '%"+Search+"%';"
  ```

  

```python
@app.route("/oprema", methods = ['GET', 'POST'])
def oprema():
    oprema = BP_DataAll("select naziv, vrsta, ukupna_kolicina from oprema")
    opremaLen = len(oprema)

    if request.method == 'POST':
        Search = request.form['search']    
        
        #Pretraga po nazivu oružja
        oprema = BP_DataAll("select naziv, vrsta, ukupna_kolicina from oprema where naziv = '%"+Search+"%';")
        opremaLen = len(oprema)

        #Pretraga po vrsti oružja
        oprema = BP_DataAll("select naziv, vrsta, ukupna_kolicina from oprema where vrsta = '%"+Search+"%';")
        opremaLen = len(oprema)

    return render_template('oprema.html', oprema = oprema, opremaLen = opremaLen)

```

**Funkcija za popis vozila**

Funkcija je stvorena za pregled vozila prema:

-  *po nazivu vozila*
- *po vrsti vozila*
- *po kapacitetu vozila*

Nadalje omogućena je pretraga prema sljedećim karakteristikama:

- ```python
   "select naziv, vrsta, ukupna_kolicina, kapacitet from vozila where naziv like '%"+Search+"%';"
  ```

- ```python
  "select naziv, vrsta, ukupna_kolicina, kapacitet from vozila where vrsta like '%"+Search+"%';"
  ```

- ```python
  "select naziv, vrsta, ukupna_kolicina, kapacitet from vozila where kapacitet like '%"+Search+"%';"
  ```

```python
@app.route("/garaza", methods = ['GET', 'POST'])
def garaza():
    garaza = BP_DataAll("select naziv, vrsta, ukupna_kolicina, kapacitet from vozila")
    garazaLen = len(garaza)

    if request.method == 'POST':
        Search = request.form['search']

        garaza = BP_DataAll("select naziv, vrsta, ukupna_kolicina, kapacitet from vozila where naziv like '%"+Search+"%';")
        garazaLen = len(garaza) #Pretraga po nazivu vozila

        garaza = BP_DataAll("select naziv, vrsta, ukupna_kolicina, kapacitet from vozila where vrsta like '%"+Search+"%';")
        garazaLen = len(garaza) #Pretraga po vrsti vozila

        garaza = BP_DataAll("select naziv, vrsta, ukupna_kolicina, kapacitet from vozila where kapacitet like '%"+Search+"%';")
        garazaLen = len(garaza) #Pretraga po kapacitetu vozila

    return render_template('garaza.html', garaza = garaza, garazaLen = garazaLen)
```



**Funkcija za pretragu neizliječenih vojnika**

Funkcija je stvorena za pregled  neizliječenih vojnika prema:

- *po imenu*

- *po prezimenu*
- *po ozlijedi*
- *po činu* 
- *po početku liječenja*

Nadalje omogućena je pretraga prema sljedećim karakteristikama:

- ```python
  "select ime, prezime, cin, pocetak_lijecenja, opis_ozljede, trosak_lijecenja from osoblje inner join lijecenje on osoblje.id = lijecenje.id_osoblje where isnull(kraj_lijecenja) = 1 and ime like '%"+Search+"%';"
  ```

- ​	

  ```python
  "select ime, prezime, cin, pocetak_lijecenja, opis_ozljede, trosak_lijecenja from osoblje inner join lijecenje on osoblje.id = lijecenje.id_osoblje where isnull(kraj_lijecenja) = 1 and prezime like '%"+Search+"%';"
  ```

- ```python
  "select ime, prezime, cin, pocetak_lijecenja, opis_ozljede, trosak_lijecenja from osoblje inner join lijecenje on osoblje.id = lijecenje.id_osoblje where isnull(kraj_lijecenja) = 1 and opis_ozljede like '%"+Search+"%';"
  ```

- ​	

  ```python
  "select ime, prezime, cin, pocetak_lijecenja, opis_ozljede, trosak_lijecenja from osoblje inner join lijecenje on osoblje.id = lijecenje.id_osoblje where isnull(kraj_lijecenja) = 1 and cin like '%"+Search+"%';"
  ```

- ```python
  "select ime, prezime, cin, pocetak_lijecenja, opis_ozljede, trosak_lijecenja from osoblje inner join lijecenje on osoblje.id = lijecenje.id_osoblje where isnull(kraj_lijecenja) = 1 and pocetak_lijecenja like '%"+Search+"%';"
  ```

```python
@app.route("/bolnica", methods = ['GET', 'POST'])
def bolnica():
    bolnica = BP_DataAll("select ime, prezime, cin, pocetak_lijecenja, opis_ozljede, trosak_lijecenja from osoblje inner join lijecenje on osoblje.id = lijecenje.id_osoblje where isnull(kraj_lijecenja) = 1;")
    bolnicaLen = len(bolnica)

    if request.method == 'POST':
        Search = request.form['search']    
        
        #Pretraga po imenu
        bolnica = BP_DataAll("select ime, prezime, cin, pocetak_lijecenja, opis_ozljede, trosak_lijecenja from osoblje inner join lijecenje on osoblje.id = lijecenje.id_osoblje where isnull(kraj_lijecenja) = 1 and ime like '%"+Search+"%';")
        bolnicaLen = len(bolnica)

        #Pretraga po prezimenu
        bolnica = BP_DataAll("select ime, prezime, cin, pocetak_lijecenja, opis_ozljede, trosak_lijecenja from osoblje inner join lijecenje on osoblje.id = lijecenje.id_osoblje where isnull(kraj_lijecenja) = 1 and prezime like '%"+Search+"%';")
        bolnicaLen = len(bolnica)

        #Pretraga po ozljedi
        bolnica = BP_DataAll("select ime, prezime, cin, pocetak_lijecenja, opis_ozljede, trosak_lijecenja from osoblje inner join lijecenje on osoblje.id = lijecenje.id_osoblje where isnull(kraj_lijecenja) = 1 and opis_ozljede like '%"+Search+"%';")
        bolnicaLen = len(bolnica)

        #Pretraga po činu
        bolnica = BP_DataAll("select ime, prezime, cin, pocetak_lijecenja, opis_ozljede, trosak_lijecenja from osoblje inner join lijecenje on osoblje.id = lijecenje.id_osoblje where isnull(kraj_lijecenja) = 1 and cin like '%"+Search+"%';")
        bolnicaLen = len(bolnica)

        #Pretraga po početku liječenja
        bolnica = BP_DataAll("select ime, prezime, cin, pocetak_lijecenja, opis_ozljede, trosak_lijecenja from osoblje inner join lijecenje on osoblje.id = lijecenje.id_osoblje where isnull(kraj_lijecenja) = 1 and pocetak_lijecenja like '%"+Search+"%';")
        bolnicaLen = len(bolnica)

    return render_template('bolnica.html', bolnica = bolnica, bolnicaLen = bolnicaLen)
```

