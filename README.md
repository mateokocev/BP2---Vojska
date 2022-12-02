# Sažetak projekta 

Kolegij: Baze podataka II 

Mentor: doc. dr. sc. Goran Oreški

Datum: 28.11.2022. 

Tema: Sustav za upravljanje vojnim oružanim snagama

Tim: 9

## Općenito

Projekt sustav za upravljanje vojnim oružanim snagama je prikaz minijaturne vojske i njene baze podataka. Kao referencu smo uzeli Hrvatsku vojsku. Unutar projekta prikazujemo sve ključne podatke bilo koje svjetske vojske.

**Osoblje unutar vojske**

Prikazuje ključne podatke svakog pojedinca unutar vojske:

- ime
- prezime
- krvnu grupu
- unutar kojeg se sektora nalazi
- datum rođenja
- datum učlanjenja 
- čin 
- status osobe jeli ranjen, aktivan itd...

**Vojni sektor**

Objašnjava unutar kojeg vojnog sektora se nalazi pojedini vojnik. Sektore koje smo implementirali su:

- kopnena vojska
- ratna mornarica
- ratno zrakoplovstvo 
- vojna policija

Svaki sektor također ima svoj datum osnivanja, budžet i kratki opis uloge pojedinog sektora.

**Oprema**

Pod opremu spada sva potrebna logistika za svakog pojedinca. U to ubrajamo:

-  oružje

- vojne i svečane uniforme 

- zaštitna oprema: kacige, pancirne prsluke itd...

- vojne ruksake 

  

Važno je za naglasit da unutar opreme *ne ubrajamo* vojna i logistička vozila, također pratimo količinu od svake opreme. 

**Vozila**

Glavna karakteristika je koja je vrsta vozila. Unutar projekta smo naveli sljedeće vrste vozila:

- Kopnena vozila koja se dijele na još više kategorija: oklopna, logistička, artiljerijska, itd...
- Pomorska vozila 
- Zračna vozila

Također pratimo količinu pojedinog vozila i njihov kapacitet koliko ljudskih resursa je moguće prevest.

**Trening**

Svaki pojedinac mora proći neku vrstu treninga kako bi bio prihvaćen unutar vojske. Svaki trening traje određenu količinu vremena i zahtjeva korištenje drugačije opreme. Trening je opisan pomoću:

- vremena početka treninga

- vremena kraja treninga

- lokacije gdje je trening izveden

- opis kako je trening proveden i s kojom opremom  

   

**Ture** 

Svaka ture reprezentira duži period odsutnosti pojedinog vojnika van države. Ture nemaju definirano vrijeme, neke mogu trajati po par mjeseci a neke po par godina. Svaka tura ima:

-  naziv
- vrstu ture mogu biti mirovne ili vojne
- vrijeme početka
- vrijeme kraja

Također je važno za naglasit da svaka *tura* se sastoji od *više misija*.

**Misije**

Misije su *zadaće* svakog vojnika. Vojnici odlaze na misije kako bi je izvršili naredbe nadležnih vlasti. Misije su prikazane pomoću sljedećih parametara:

- naziv misije
- vrijeme početka
- vrijeme kraja
- lokacije gdje se misija izvršava
- podatkom pod koju tura pripada svaka misija 
- ishoda bio on pozitivan ili negativan 

Na kraju svake misije je zabilježen *trošak misije* za lakšu raspodjelu budžeta.

 **Liječenje**

Liječenje simbolizira da svaki vojna misija će imati svoje ljudske gubitke. Zbog toga je potrebna *vojna bolnica* unutar koje se provodi liječenje vojnika. Sastoji se od sljedećih karakteristika: 

- identifikacijske oznake pojedinca na kojem se provodi liječenje 
-   statusa liječenja 
- datuma početka liječenja
- datuma kraja liječenja 
- opisa ozlijede 

Kao i za *misije* prati se trošak pojedinog liječenja.

 **Popravak**

Popravak prati bilo kakav rad na određenom vozilu unutar naše baze podataka. Popravak prati slijedeće podatke:

- identifikacijske oznaka pojedinog vozila 
- opis štete 
- datum početka popravka 
- datum kraja popravka

Također pratimo trošak svakog pojedinog vozila. 

## Izrada baze podataka

  Pri izradi baze podataka uspješno smo stvorili 10 relacija pod sljedećim nazivima:

**sektor**

```mysql
CREATE TABLE sektor(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(60) NOT NULL,
    datum_osnivanja DATE NOT NULL,
    opis TEXT,
    ukupni_proracun DECIMAL(12,2) NOT NULL
);
```

**lokacija**

```mysql
CREATE TABLE lokacija(
    id INTEGER PRIMARY KEY,
    id_sektor INTEGER,
    naziv VARCHAR(60) NOT NULL,
    zemljopisna_duzina DECIMAL(10, 7),
    zemljopisna_sirina DECIMAL(10, 7),
    FOREIGN KEY (id_sektor) REFERENCES sektor(id)
)
```

**osoblje**

```mysql
CREATE TABLE osoblje(
    id INTEGER PRIMARY KEY,
    id_sektor INTEGER,
    ime VARCHAR(30) NOT NULL,
    prezime VARCHAR(30) NOT NULL,
    cin VARCHAR(20) NOT NULL,
    datum_rodenja DATE NOT NULL,
    datum_uclanjenja DATE NOT NULL,
    status_osoblja VARCHAR(50) NOT NULL,
    krvna_grupa CHAR(3) NOT NULL,
    FOREIGN KEY (id_sektor) REFERENCES sektor(id)
);
```

**tura**

```mysql
CREATE TABLE tura(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(50) NOT NULL,
    vrsta_ture VARCHAR(69) NOT NULL,
    vrijeme_pocetka DATETIME NOT NULL,
    vrijeme_kraja DATETIME
);
```

**misija**

```mysql

CREATE TABLE misija(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(50) NOT NULL,
    vrijeme_pocetka DATETIME NOT NULL,
    vrijeme_kraja DATETIME,
    id_lokacija INTEGER NOT NULL,
    id_tura INTEGER NOT NULL,
    ishod TEXT NOT NULL,
    trosak_misije NUMERIC(15, 2),
    FOREIGN KEY (id_lokacija) REFERENCES lokacija(id),
    FOREIGN KEY (id_tura) REFERENCES tura(id)
);
```

**vozila**

```mysql
CREATE TABLE vozila(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(60) NOT NULL,
    vrsta VARCHAR(50) NOT NULL,
    ukupna_kolicina INTEGER NOT NULL,
    kapacitet INTEGER NOT NULL
    );
```

**popravak**

```mysql
CREATE TABLE popravak(
    id INTEGER PRIMARY KEY,
    id_vozilo_na_misiji INTEGER,
    opis_stete TEXT NOT NULL,
    pocetak_popravka DATETIME NOT NULL,
    kraj_popravka DATETIME,
    trosak_popravka NUMERIC(15,2),
    FOREIGN KEY (id_vozilo_na_misiji) REFERENCES vozilo_na_misiji(id)
);
```

**oprema**

```mysql
CREATE TABLE oprema(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(50) NOT NULL,
    vrsta VARCHAR(50) NOT NULL,
    ukupna_kolicina INTEGER NULL
);
```

**trening**

```mysql
CREATE TABLE trening(
    id INTEGER PRIMARY KEY,
    vrijeme_pocetka DATETIME NOT NULL,
    vrijeme_kraja DATETIME NOT NULL,
    id_lokacija INTEGER NOT NULL,
    opis VARCHAR(80) NOT NULL,
    FOREIGN KEY (id_lokacija) REFERENCES lokacija(id)
);
```

**lijecenje**

```mysql
CREATE TABLE lijecenje(
    id INTEGER PRIMARY KEY,
    id_osoblje INTEGER,
    status_lijecenja TEXT NOT NULL,  
    pocetak_lijecenja DATETIME NOT NULL,
    kraj_lijecenja DATETIME,
    opis_ozljede TEXT NOT NULL,
    trosak_lijecenja NUMERIC(15,2),
    FOREIGN KEY (id_osoblje) REFERENCES osoblje(id)
);
```

Svaka od navedenih relacija je opisana unutar općenitog dijela sažetka projekta. Zbog odnosa između pojedinih relacija bilo je potrebno stvoriti dodatnih 6 relacija:

**osoblje_na treningu**

Relacija je nastala zbog odnosa više na više između relacija **trening** i **osoblja**.

```mysql
CREATE TABLE osoblje_na_treningu(
	id INTEGER PRIMARY KEY,
	id_osoblje INTEGER NOT NULL,
	id_trening INTEGER NOT NULL,
	performans INTEGER NOT NULL,
	CHECK(performans >= 0 AND performans < 11),
    FOREIGN KEY (id_osoblje) REFERENCES osoblje(id),
    FOREIGN KEY (id_trening) REFERENCES trening(id)
);
```

**osoblje_na_turi**

Relacija je nastala zbog odnosa više na više između relacija **ture** i **osoblja**.

```mysql
CREATE TABLE osoblje_na_turi(
    id INTEGER PRIMARY KEY,
    id_osoblje INTEGER,
    id_tura INTEGER,
    datum_pocetka DATETIME NOT NULL,
    datum_kraja DATETIME,
    FOREIGN KEY (id_osoblje) REFERENCES osoblje(id),
    FOREIGN KEY (id_tura) REFERENCES tura(id)
);
```

**osoblje_na_misiji**

Relacija je nastala zbog odnosa više na više između relacija **misije** i **osoblje**.

```mysql
CREATE TABLE osoblje_na_misiji(
    id INTEGER PRIMARY KEY,
    id_osoblje INTEGER,
    id_misija INTEGER,
    FOREIGN KEY (id_osoblje) REFERENCES osoblje(id),
    FOREIGN KEY (id_misija) REFERENCES misija(id)
);
```

**vozilo_na_turi**

Relacija je nastala zbog odnosa više na više između relacija **tura** i **vozila**.

```mysql
CREATE TABLE vozilo_na_turi(
    id INTEGER PRIMARY KEY,
    id_vozilo INTEGER,
    id_tura INTEGER,
    id_odgovorni INTEGER NOT NULL,
    kolicina INTEGER,
    FOREIGN KEY (id_vozilo) REFERENCES vozila(id),
    FOREIGN KEY (id_tura) REFERENCES tura(id),
    FOREIGN KEY (id_odgovorni) REFERENCES osoblje_na_turi(id)
);
```

**vozilo_na_misiji**

Relacija je nastala zbog odnosa više na više između relacija **misije** i **vozila**.

```mysql
CREATE TABLE vozilo_na_misiji(
    id INTEGER PRIMARY KEY,
    id_vozilo INTEGER,
    kolicina INTEGER,
    id_misija INTEGER,
    FOREIGN KEY (id_vozilo) REFERENCES vozila(id),
    FOREIGN KEY (id_misija) REFERENCES misija(id)
);
```

**izdana_oprema**

Relacija je nastala zbog odnosa više na više između relacija **opreme** i **osoblje_na_misiji**.

```mysql
CREATE TABLE izdana_oprema(
    id INTEGER PRIMARY KEY,
    id_oprema INTEGER,
    id_osoblje_na_misiji INTEGER,
    izdana_kolicina INTEGER DEFAULT 1,
    FOREIGN KEY (id_oprema) REFERENCES oprema(id),
    FOREIGN KEY (id_osoblje_na_misiji) REFERENCES osoblje_na_misiji(id)
);
```



### Upiti, okidači, funkcije i procedure

Trenutačno su u izradi upiti, funckije, procedure te okidači. Okidači će doprinositi smislenosti i ispravnosti unošenja, brisanja i ažuriranja podataka u tablicama naše baze podataka. Funkcije i procedure omogućuju da se dohvate određeni podaci za koje nije moguće doći putem built-in funkcijama u MySql-u (npr. procedura koja će provjeravati kolicinu opreme u zadanom trenutku) te da se određeni kod ne ponavlja više puta.



##  Izrada grafičkog sučelja i backend-a

## Ciljevi:

- Izrada interaktivne web aplikacije
- sustav prijavljivanja vojnika
- Profil korisnika
- Pregled misija
- Pregled tura
- Pregled opreme
- pregled podataka i statistike o podatcima iz baze podataka

## Alati prilikom izrade frontend-a i backend-a

- ### Flask

- ### Html

- ### Css

- ### JavaScript

- ### VSCode

- ### VSCode - Live Share (addon)

## Zaključak

Projekt na odličnoj putanji. Strukturiranje baze podataka je završeno kao i ER dijagram. S već navedenim relacijama i idejama koje ćemo tek implementirat unutar MySQL i grafičkog sučelja predviđamo savršenu minijaturnu presliku susutava za upravljanje vojnim oružanim snagama.



