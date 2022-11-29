DROP DATABASE IF EXISTS vojska;

CREATE DATABASE vojska;
USE vojska;


CREATE TABLE sektor(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(60) NOT NULL,
    godina_osnivanja INTEGER,
    opis TEXT,
    ukupni_proracun DECIMAL(12,2)
);
-- DROP TABLE sektor;



CREATE TABLE lokacija(
    id INTEGER PRIMARY KEY,
    id_sektor INTEGER,
    naziv VARCHAR(60) NOT NULL,
    zemljopisna_duzina DECIMAL(10, 7),
    zemljopisna_sirina DECIMAL(10, 7),
    FOREIGN KEY (id_sektor) REFERENCES sektor(id)
);
-- DROP TABLE lokacija;



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
-- DROP TABLE osoblje;




CREATE TABLE tura(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(50) NOT NULL,
    vrsta_ture VARCHAR(69) NOT NULL,
    vrijeme_pocetka DATETIME NOT NULL,
    vrijeme_kraja DATETIME NOT NULL
);
-- DROP TABLE tura;



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
-- DROP TABLE misija;


CREATE TABLE osoblje_na_misiji(
    id INTEGER PRIMARY KEY,
    id_osoblje INTEGER,
    id_misija INTEGER,
    FOREIGN KEY (id_osoblje) REFERENCES osoblje(id),
    FOREIGN KEY (id_misija) REFERENCES misija(id)
);
-- DROP TABLE osoblje_na_misiji;



CREATE TABLE osoblje_na_turi(
    id INTEGER PRIMARY KEY,
    id_osoblje INTEGER,
    id_tura INTEGER,
    datum_pocetka DATETIME NOT NULL,
    datum_kraja DATETIME NOT NULL,
    FOREIGN KEY (id_osoblje) REFERENCES osoblje(id),
    FOREIGN KEY (id_tura) REFERENCES tura(id)
);
-- DROP TABLE osoblje_na_turi;



CREATE TABLE vozila(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(60) NOT NULL,
    vrsta VARCHAR(50) NOT NULL,
    ukupna_kolicina INTEGER NOT NULL,
    kapacitet INTEGER NOT NULL -- leo je rekao da mu ne pase, zasto je to tu? ko je to dodao? zasto smo zivi? di mi je pistolj? auto increment?
);
-- DROP TABLE vozila;



CREATE TABLE vozilo_na_misiji(
    id INTEGER PRIMARY KEY,
    id_vozilo INTEGER,
    kolicina INTEGER,
    id_misija INTEGER,
    FOREIGN KEY (id_vozilo) REFERENCES vozila(id),
    FOREIGN KEY (id_misija) REFERENCES misija(id)
);
-- DROP TABLE vozilo_na_misiji;



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
-- DROP TABLE vozilo_na_turi;



CREATE TABLE popravak(
    id INTEGER PRIMARY KEY,
    id_vozilo_na_misiji INTEGER,
    opis_stete TEXT NOT NULL,
    pocetak_popravka DATE NOT NULL,
    kraj_popravka DATE NOT NULL,
    trosak_popravka NUMERIC(15,2),
    FOREIGN KEY (id_vozilo_na_misiji) REFERENCES vozilo_na_misiji(id)
);
-- DROP TABLE popravak;



CREATE TABLE oprema(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(50) NOT NULL,
    vrsta VARCHAR(50) NOT NULL,
    ukupna_kolicina INTEGER NULL
);
-- DROP TABLE oprema;



CREATE TABLE izdana_oprema(
    id INTEGER PRIMARY KEY,
    id_oprema INTEGER,
    id_osoblje_na_misiji INTEGER,
    izdana_kolicina INTEGER DEFAULT 1,
    FOREIGN KEY (id_oprema) REFERENCES oprema(id),
    FOREIGN KEY (id_osoblje_na_misiji) REFERENCES osoblje_na_misiji(id)
);
-- DROP TABLE izdana_oprema;


CREATE TABLE trening(
    id INTEGER PRIMARY KEY,
    vrijeme_pocetka DATETIME NOT NULL,
    vrijeme_kraja DATETIME NOT NULL,
    id_lokacija INTEGER NOT NULL,
    opis VARCHAR(80) NOT NULL,
    FOREIGN KEY (id_lokacija) REFERENCES lokacija(id)
);
-- DROP TABLE trening;


CREATE TABLE osoblje_na_treningu(
	id INTEGER PRIMARY KEY,
	id_osoblje INTEGER NOT NULL,
	id_trening INTEGER NOT NULL,
	performans INTEGER NOT NULL,
	CHECK(performans >= 0 AND performans < 11),
    FOREIGN KEY (id_osoblje) REFERENCES osoblje(id),
    FOREIGN KEY (id_trening) REFERENCES trening(id)
);
-- DROP TABLE osoblje_na_treningu;


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
-- DROP TABLE lijecenje;

CREATE TABLE login(
    id INTEGER primary KEY,  -- autoincrement
	ime varchar(100),
    lozinka varchar(100)
   
);
-- DROP TABLE login;





-- OKIDACI
						-- za kriptiranje lozinke
DELIMITER //
CREATE TRIGGER kriptiranje
 BEFORE INSERT ON login
 FOR EACH ROW
BEGIN
 SET new.lozinka = MD5(new.lozinka);
END//
DELIMITER ;

-- struktura je ova:
/*
DROP TRIGGER IF EXISTS ime_okidaca;

DELIMITER //
CREATE TRIGGER ime_okidaca
	BEFORE INSERT ON naziv_tablice
    FOR EACH ROW
BEGIN



END//
DELIMITER ;
*/


-- DK
-- imamo: id 3, 4 pistolja te kosirnik bespotrebno dodaje id 5 s 3 pistolja. Stvaramo okidac koji ce tih 3 zbrojit s 5 zato jer 
-- korisnik nije ispravno postupio. Tezimo tome da baza bude optimalna te da optimalno radi

DROP TRIGGER IF EXISTS postoji;

DELIMITER //
CREATE TRIGGER postoji
	AFTER INSERT ON oprema
    FOR EACH ROW
BEGIN
	DECLARE br INTEGER;
    
	SELECT COUNT(*) INTO br
    FROM oprema
    WHERE naziv = new.naziv;
    
    
	IF br > 1 THEN
        UPDATE oprema SET ukupna_kolicina = ukupna_kolicina + new.ukupna_kolicina WHERE naziv = new.naziv;
    END IF;

	DELETE FROM oprema WHERE id = new.id;
END//
DELIMITER ;



-- DK
/*
DROP TRIGGER IF EXISTS vec_ima;

DELIMITER //
CREATE TRIGGER vec_ima
	BEFORE INSERT ON popravak
    FOR EACH ROW
BEGIN

	IF new.id_vozilo_

END//
DELIMITER ;

*/





-- FUNKCIJE:










-- PROCEDURE:









-- UNOS TABLICA:


-- enkripcija podataka

INSERT INTO login VALUES (1,"pero","1234");
INSERT INTO login VALUES (2,"ivan","1234");
INSERT INTO login VALUES (3,"test","test");
select * from login;

-- provjera lozinke
select lozinka from login
where ime="pero" and md5("1234") = lozinka;

select * from login;



