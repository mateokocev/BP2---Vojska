DROP DATABASE IF EXISTS vojska;

CREATE DATABASE vojska;
USE vojska;


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
DROP TABLE osoblje;


CREATE TABLE sektor(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(60) NOT NULL,
    godina_osnivanja INTEGER,
    opis TEXT,
    ukupni_proracun DECIMAL(12,2)
);
DROP TABLE sektor;


CREATE TABLE lokacija(
    id INTEGER PRIMARY KEY,
    id_sektor INTEGER,
    naziv VARCHAR(60) NOT NULL,
    zemljopisna_dužina DECIMAL(10, 7),
    zemljopisna_širina DECIMAL(10, 7),
    FOREIGN KEY (id_sektor) REFERENCES sektor(id)
);
DROP TABLE lokacija;


CREATE TABLE vozila(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(60) NOT NULL,
    vrsta VARCHAR(50) NOT NULL,
    ukupna_kolicina INTEGER NOT NULL,
    kapacitet INTEGER NOT NULL -- leo je rekao da mu ne pase, zasto je to tu? ko je to dodao? zasto smo zivi? di mi je pistolj? auto increment?
);
DROP TABLE vozila;


CREATE TABLE oprema(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(50) NOT NULL,
    vrsta VARCHAR(50) NOT NULL,
    ukupna_kolicina INTEGER NULL
);
DROP TABLE oprema;


CREATE TABLE misija(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(50) NOT NULL,
    vrijeme_pocetka DATETIME NOT NULL,
    vrijeme_kraja DATETIME NOT NULL,
    id_lokacija INTEGER NOT NULL,
    id_tura INTEGER NOT NULL,
    ishod TEXT NOT NULL,
    trosak_misije NUMERIC(15, 2) NOT NULL,
    FOREIGN KEY (id_lokacija) REFERENCES lokacija(id),
    FOREIGN KEY (id_tura) REFERENCES tura(id)
); 
DROP TABLE misija;


CREATE TABLE osoblje_na_misiji(
    id INTEGER PRIMARY KEY,
    id_osoblje INTEGER,
    id_misija INTEGER,
    FOREIGN KEY (id_osoblje) REFERENCES osoblje(id),
    FOREIGN KEY (id_misija) REFERENCES misija(id)
);
DROP TABLE osoblje_na_misiji;


CREATE TABLE vozilo_na_misiji(
    id INTEGER PRIMARY KEY,
    id_vozilo INTEGER,
    kolicina INTEGER,
    id_misija INTEGER,
    FOREIGN KEY (id_vozilo) REFERENCES vozila(id),
    FOREIGN KEY (id_misija) REFERENCES misija(id)
);
DROP TABLE vozilo_na_misiji;


CREATE TABLE popravak(
    id INTEGER PRIMARY KEY,
    id_vozilo_na_misiji INTEGER,
    opis_stete TEXT NOT NULL,
    pocetak_popravka DATE NOT NULL,
    kraj_popravka DATE NOT NULL,
    trosak_popravka NUMERIC(15,2),
    FOREIGN KEY (id_vozilo_na_misiji) REFERENCES vozilo_na_misiji(id)
);
DROP TABLE popravak;


CREATE TABLE tura(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(50) NOT NULL,
    vrsta_ture VARCHAR(69) NOT NULL,
    vrijeme_pocetka DATETIME NOT NULL,
    vrijeme_kraja DATETIME NOT NULL
);
DROP TABLE tura;


CREATE TABLE osoblje_na_turi(
    id INTEGER PRIMARY KEY,
    id_osoblje INTEGER,
    id_tura INTEGER,
    datum_pocetka DATETIME NOT NULL,
    datum_kraja DATETIME NOT NULL,
    FOREIGN KEY (id_osoblje) REFERENCES osoblje(id),
    FOREIGN KEY (id_tura) REFERENCES tura(id)
);
DROP TABLE osoblje_na_turi;


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
DROP TABLE vozilo_na_turi;


CREATE TABLE izdana_oprema(
    id INTEGER PRIMARY KEY,
    id_oprema INTEGER,
    id_osoblje_na_misiji INTEGER,
    izdana_kolicina INTEGER DEFAULT 1,
    FOREIGN KEY (id_oprema) REFERENCES oprema(id),
    FOREIGN KEY (id_osoblje_na_misiji) REFERENCES osoblje_na_misiji(id)
);
DROP TABLE izdana_oprema;


CREATE TABLE trening(
    id INTEGER PRIMARY KEY,
    vrijeme_pocetka DATETIME NOT NULL,
    vrijeme_kraja DATETIME NOT NULL,
    id_lokacija INTEGER NOT NULL,
    opis VARCHAR(80) NOT NULL,
    FOREIGN KEY (id_lokacija) REFERENCES lokacija(id)
);
DROP TABLE trening;


CREATE TABLE osoblje_na_treningu(
	id INTEGER PRIMARY KEY,
);


CREATE TABLE lijecenje(
    id INTEGER PRIMARY KEY,
    id_osoblje INTEGER,
    status_lijecenja TEXT NOT NULL,  -- interaktivno ongoing completed itd. ako je ongoing datum kraja je null / possible trigger?
    pocetak_lijecenja DATE NOT NULL,
    kraj_lijecenja DATE NOT NULL,
	opis_ozljede TEXT NOT NULL,
    trosak_lijecenja NUMERIC(15,2),
    FOREIGN KEY (id_osoblje) REFERENCES osoblje(id)
);
DROP TABLE lijecenje;

INSERT INTO osoblje VALUES
 ( 2 , 101 , "Borisa" , "Šimunić" , "vojnik" , 2018-4-17 , 2002-11-23 , True , "0+" ),
 ( 3 , 102 , "Dani" , "Đurić" , "vojnik" , 2018-7-8 , 2015-7-10 , True , "AB+" ),
 ( 4 , 103 , "Eliana" , "Pavlović" , "general" , 2001-7-24 , 2012-10-16 , False , "AB+" ),
 ( 5 , 104 , "Neli" , "Lučić" , "vojnik" , 2013-12-4, 2013-4-1 , False , "0+" ),
 ( 6 , 105 , "Slaven" , "Novaković" , "vojnik" , 2015-4-13 , 2017-10-4 , False , "0+" ),
 ( 7 , 106 , "Franka" , "Mitrović" , "general" , 2000-9-5 , 2007-5-22 , True , "AB+" ),
 ( 8 , 107 , "Zvjezdana" , "Radić" , "general" , 2007-5-17 , 2020-7-11 , False , "AB+" ),
 ( 9 , 108 , "Elana" , "Barišić" , "vojnik" , 2012-8-8 , 2003-2-21 , True , "0+" ),
 ( 10 , 109 , "Darko" , "Jozić" , "vojnik" , 2013-6-9 , 2018-6-29 , True , "AB+" ),
 ( 11 , 110 , "Elizabeta" , "Ružić" , "vojnik" , 2008-3-28 , 2020-10-15 , True , "AB+" ),
 ( 12 , 111 , "Jaka" , "Martinović" , "vojnik" , 2005-10-16 , 2006-8-29 , False , "AB+" ),
 ( 13 , 112 , "Šime" , "Vučković" , "vojnik" , 2001-5-11 , 2016-6-13 , True , "AB+" ),
 ( 14 , 113 , "Manuel" , "Josipović" , "vojnik" , 2009-4-7 , 2017-5-1 , False , "0+" ),
 ( 15 , 114 , "Noel" , "Dragičević" , "vojnik" , 2006-4-17 , 2000-9-15 , False , "0+" ),
 ( 16 , 115 , "Kate" , "Pavić" , "vojnik" , 2017-3-21 , 2019-6-1 , False , "AB+" ),
 ( 17 , 116 , "Toma" , "Jurković" , "general" , 2012-1-2 , 2016-7-21 , False , "AB+" ),
 ( 18 , 117 , "Arijana" , "Matić" , "vojnik" , 2016-1-10 , 2013-6-12 , True , "AB+" ),
 ( 19 , 118 , "Lucijano" , "Novaković" , "vojnik" , 2019-3-28 , 2001-4-28 , True , "AB+" ),
 ( 20 , 119 , "Magda" , "Živković" , "vojnik" , 2021-10-25 , 2010-2-14 , False , "AB+" ),
 ( 21 , 120 , "Alfi" , "Vidović" , "general" , 2013-12-9 , 2022-11-8 , True , "AB+" ),
 ( 22 , 121 , "Fabijan" , "Nikolić" , "general" , 2001-7-28 , 2007-2-5 , True , "0+" ),
 ( 23 , 122 , "Aliza" , "Đurić" , "general" , 2010-2-18 , 2002-9-24 , True , "AB+" ),
 ( 24 , 123 , "Tara" , "Novaković" , "general" , 2016-9-9 , 2001-9-11 , False , "0+" ),
 ( 25 , 124 , "Aubriela" , "Jelić" , "vojnik" , 2005-2-29 , 2007-2-22 , True , "0+" ),
 ( 26 , 125 , "Kalani" , "Filipović" , "vojnik" , 2018-12-20 , 2000-9-21 , True , "0+" ),
 ( 27 , 126 , "Gabrijela" , "Kralj" , "vojnik" , 2007-1-16 , 2001-1-5 , False , "AB+" ),
 ( 28 , 127 , "Ela" , "Šimunović" , "vojnik" , 2010-1-30 , 2004-8-9 , False , "0+" ),
 ( 29 , 128 , "Saša" , "Kolarić" , "general" , 2014-8-20 , 2017-12-12 , False , "AB+" ),
 ( 30 , 129 , "Jasen" , "Miletić" , "general" , 2021-7-6 , 2005-5-1 , True , "AB+" ),
 ( 31 , 130 , "Analia" , "Šarić" , "vojnik" , 2017-10-18 , 2016-10-11 , True , "AB+" ),
 ( 32 , 131 , "Emil" , "Antunović" , "general" , 2018-11-9 , 2019-3-28 , False , "0+" ),
 ( 33 , 132 , "Gema" , "Ivančić" , "general" , 2003-9-25 , 2002-8-22 , True , "AB+" ),
 ( 34 , 133 , "Ana" , "Šimunović" , "vojnik" , 2015-6-8 , 2008-1-14 , True , "AB+" ),
 ( 35 , 134 , "Bianka" , "Perković" , "general" , 2022-5-24 , 2014-2-8 , True , "0+" ),
 ( 36 , 135 , "Roko" , "Ivanović" , "general" , 2015-5-15 , 2007-11-21 , True , "0+" ),
 ( 37 , 136 , "Ronald" , "Tomić" , "general" , 2001-3-10 , 2013-6-5 , False , "0+" ),
 ( 38 , 137 , "Maks" , "Marjanović" , "vojnik" , 2001-4-8 , 2003-10-14 , False , "0+" ),
 ( 39 , 138 , "Siri" , "Grgić" , "vojnik" , 2020-3-30 , 2012-9-4 , False , "0+" ),
 ( 40 , 139 , "Dela" , "Ćosić" , "vojnik" , 2017-2-12 , 2010-11-16 , False , "0+" ),
 ( 41 , 140 , "Aurora" , "Vuković" , "general" , 2012-7-17 , 2006-6-17 , True , "0+" );