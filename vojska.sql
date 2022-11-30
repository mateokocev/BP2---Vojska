DROP DATABASE IF EXISTS vojska;

CREATE DATABASE vojska;
USE vojska;


CREATE TABLE sektor(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(60) NOT NULL,
    datum_osnivanja DATE NOT NULL,
    opis TEXT,
    ukupni_proracun DECIMAL(12,2) NOT NULL
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
    vrijeme_kraja DATETIME
);
-- DROP TABLE tura;



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
    datum_kraja DATETIME,
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
    pocetak_popravka DATETIME NOT NULL,
    kraj_popravka DATETIME,
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
    pocetak_lijecenja DATETIME NOT NULL,
    kraj_lijecenja DATETIME,
    opis_ozljede TEXT NOT NULL,
    trosak_lijecenja NUMERIC(15,2),
    FOREIGN KEY (id_osoblje) REFERENCES osoblje(id)
);
-- DROP TABLE lijecenje;








-- OKIDACI
						
-- tekst zadataka ce bit jos restrukturiran, ovo je okvirno

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
-- Prati se da zbroj izdane kolicine zeljene opreme ne bude veci od sveukupne moguce kolicine opreme tijekom insert-a
	
DROP TRIGGER IF EXISTS kop;

DELIMITER //
CREATE TRIGGER kop
    BEFORE INSERT ON izdana_oprema
    FOR EACH ROW
BEGIN
    DECLARE br INTEGER;
    DECLARE uk INTEGER;
    
    SELECT SUM(izdana_kolicina) INTO br
    FROM izdana_oprema
    WHERE id_oprema = new.id_oprema;
    
    SELECT ukupna_kolicina INTO uk
    FROM oprema
    WHERE id = new.id_oprema;
    
    IF br + new.izdana_kolicina > uk THEN
	SIGNAL SQLSTATE '40000'
        SET MESSAGE_TEXT = 'Oprema koju zelite unijeti nije dostupna u zeljenoj kolicini!';
    END IF;
END//
DELIMITER ;






-- DK
-- Prati se da zbroj izdane kolicine ne bude veci od sveukupne moguce kolicine opreme tijekom update-a

DROP TRIGGER IF EXISTS ukop;

DELIMITER //
CREATE TRIGGER ukop
    BEFORE UPDATE ON izdana_oprema
    FOR EACH ROW
BEGIN
    DECLARE br INTEGER;
    DECLARE uk INTEGER;
    
    SELECT SUM(izdana_kolicina) INTO br
    FROM izdana_oprema
    WHERE id_oprema = new.id_oprema;
    
    
    SELECT ukupna_kolicina INTO uk
    FROM oprema
    WHERE id = new.id_oprema;
    
    IF (br - old.izdana_kolicina) + new.izdana_kolicina > uk THEN
	SIGNAL SQLSTATE '40000'
        SET MESSAGE_TEXT = 'Ne mozete promijenit kolicinu zeljene opreme koja je izdana osobi zato jer nije dostupna u toj kolicini!';
    END IF;
END//
DELIMITER ;





-- DK
-- Datetime pocetka popravka ne moze biti veci od datetime kraja. Idemo ih usporedivat samo uz uvjet da kraj nije NULL.
-- Ak je kraj NULL to znaci da je popravak jos uvijek u tijeku
 
DROP TRIGGER IF EXISTS vr_po;

DELIMITER //
CREATE TRIGGER vr_po
    BEFORE INSERT ON popravak
    FOR EACH ROW
BEGIN
	IF DATE(new.pocetak_popravka) >= DATE(new.kraj_popravka) AND new.kraj_popravka != NULL THEN
		SIGNAL SQLSTATE '40000'
                SET MESSAGE_TEXT = 'Neispravno je uneseno vrijeme pocetka ili/i kraja popravka!';
        END IF;
END//
DELIMITER ;






-- DK
-- Vrijeme pocetka ne smije biti isto ili manje kao vrijeme kraja te trening bi najmanje trebao trajat 20 min(jos vidjet s Stevanom)
DROP TRIGGER IF EXISTS vr_tr;

DELIMITER //
CREATE TRIGGER vr_tr
    BEFORE INSERT ON trening
    FOR EACH ROW
BEGIN
    IF DATE(new.vrijeme_pocetka) >= DATE(new.vrijeme_kraja) OR TIMESTAMPDIFF(MINUTE, new.vrijeme_pocetka, new.vrijeme_kraja) < 20 THEN
	SIGNAL SQLSTATE '40000'
        SET MESSAGE_TEXT = 'Neispravno je uneseno vrijeme pocetka ili/i kraja treninga!';
    END IF;
END//
DELIMITER ;





-- DK
-- Datetime pocetka lijecenja ne moze biti veci od datetime kraja. Idemo ih usporedivat samo uz uvjet da kraj nije NULL.
-- Ak je kraj NULL to znaci da je lijecenje jos uvijek u tijeku
DROP TRIGGER IF EXISTS vrli;

DELIMITER //
CREATE TRIGGER vrli
    BEFORE INSERT ON lijecenje
    FOR EACH ROW
BEGIN
    IF DATE(new.pocetak_lijecenja) >= DATE(new.kraj_lijecenja) AND new.kraj_lijecenja != NULL THEN
	 SIGNAL SQLSTATE '40000'
         SET MESSAGE_TEXT = 'Neispravno je uneseno vrijeme pocetka ili/i kraja lijecenja!';
    END IF;
END//
DELIMITER ;





-- FUNKCIJE:

-- Funkcija vraca ukupni trosak

DELIMITER //
CREATE FUNCTION trosak() RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE ukupno_misija, ukupni_popravak, ukupno_lijecenje DECIMAL(8,2);
    
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



-- Funkcija racuna koliko je novca ostalo "viska" iz proracuna:

DELIMITER //
CREATE FUNCTION visak() RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE proracun_svih_sektora DECIMAL(12,2);
    
    SELECT SUM(ukupni_proracun) INTO proracun_svih_sektora
    FROM sektor;
    
    RETURN proracun_svih_sektora - trosak();
END//
DELIMITER ;

SELECT visak() AS visak FROM DUAL;






-- PROCEDURE:

...






-- UNOS TABLICA:

INSERT INTO sektor VALUES 
(1, "Hrvatska kopnena vojska", STR_TO_DATE("28.05.1991.", "%d.%m.%Y."), "Najbrojnija je grana Oružanih snaga Republike Hrvatske, čija je uloga i namjena promicanje i zaštita vitalnih nacionalnih interesa Republike Hrvatske, obrana suvereniteta i teritorijalne cjelovitosti države. Temeljna zadaća je spriječiti prodor agresora u dubinu teritorija, sačuvati vitalne strategijske objekte, osigurati mobilizaciju ratnog sastava i pobijediti agresora. Nositeljica je i organizatorica kopnene obrane Republike Hrvatske.", 4324000000.00),
(2, "Hrvatska ratna mornarica", STR_TO_DATE("12.09.1991.", "%d.%m.%Y."), "Uloga i namjena HRM-e  je štititi integritet i suverenitet Republike Hrvatske na moru i s mora. Nositeljica je i organizatorica pomorske obrane Republike Hrvatske", 2876000000.00),
(3, "Hrvatsko ratno zrakoplovstvo", STR_TO_DATE("12.12.1991.", "%d.%m.%Y."), "Osnovna zadaća HRZ-a je osiguranje suverenosti zračnog prostora Republike Hrvatske te pružanje zrakoplovne potpore drugim granama u provedbi njihovih zadaća u združenim operacijama. Nositelj je i organizator integriranog sustava protuzračne obrane Republike Hrvatske.", 3622000000.00),
(4, "Hrvatska vojna policija", STR_TO_DATE("24.08.1991.", "%d.%m.%Y."), "Vojna policija Oružanih snaga Republike Hrvatske (VP OSRH) pruža potporu Ministarstvu obrane i Oružanim snagama Republike Hrvatske obavljanjem namjenskih vojnopolicijskih poslova u miru i ratu te borbenih zadaća u ratu.", 1822000000.00)
;


INSERT INTO osoblje VALUES
()


INSERT INTO tura VALUES
(01, "UNMOGIP", "Mirovna tura", STR_TO_DATE("01.08.2008","%d.%m.%Y."), STR_TO_DATE("04.11.2021","%d.%m.%Y.")),
(02, "EUFOR Tchad/RCA", "Vojna tura", STR_TO_DATE("01.10.2008","%d.%m.%Y."), STR_TO_DATE("15.04.2009","%d.%m.%Y.")),
(03, "ISAF", "Mirovna tura", STR_TO_DATE("01.12.2010","%d.%m.%Y."), STR_TO_DATE("16.11.2014","%d.%m.%Y.")),
(04, "Resolute support", "Mirovna tura", STR_TO_DATE("01.01.2015","%d.%m.%Y."), STR_TO_DATE("04.09.2020","%d.%m.%Y.")),
(05, "", "Mirovna tura", STR_TO_DATE("01.08.2008","%d.%m.%Y."), STR_TO_DATE("04.11.2021","%d.%m.%Y.")),
(06, "ISAF", "Mirovna tura", STR_TO_DATE("01.12.2010","%d.%m.%Y."), STR_TO_DATE("16.11.2014","%d.%m.%Y.")),




CREATE TABLE vozila(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(60) NOT NULL,
    vrsta VARCHAR(50) NOT NULL,
    ukupna_kolicina INTEGER NOT NULL,
    kapacitet INTEGER NOT NULL -- leo je rekao da mu ne pase, zasto je to tu? ko je to dodao? zasto smo zivi? di mi je pistolj? auto increment?
);
INSERT INTO vozila VALUES






-- BACKEND:


DELIMITER //
CREATE TRIGGER kriptiranje
 BEFORE INSERT ON login
 FOR EACH ROW
BEGIN
 SET new.lozinka = MD5(new.lozinka);
END//
DELIMITER ;



CREATE TABLE login(
    id INTEGER primary KEY,  -- autoincrement
	ime varchar(100),
    lozinka varchar(100)
);
-- DROP TABLE login;

-- za kriptiranje lozinke



/*
id INTEGER PRIMARY KEY,
    naziv VARCHAR(50) NOT NULL,
    vrsta_ture VARCHAR(69) NOT NULL,
    vrijeme_pocetka DATETIME NOT NULL,
    vrijeme_kraja DATETIME NOT NULL
*/

-- enkripcija podataka

INSERT INTO login VALUES (1,"pero","1234");
INSERT INTO login VALUES (2,"ivan","1234");
INSERT INTO login VALUES (3,"test","test");
select * from login;

-- provjera lozinke
select lozinka from login
where ime="pero" and md5("1234") = lozinka;

select * from login;
