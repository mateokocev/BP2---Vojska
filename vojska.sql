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







-- UNOS TABLICA:

INSERT INTO sektor VALUES
(1, "Hrvatska kopnena vojska", STR_TO_DATE("28.05.1991.", "%d.%m.%Y."), "Najbrojnija je grana Oružanih snaga Republike Hrvatske, čija je uloga i namjena promicanje i zaštita vitalnih nacionalnih interesa Republike Hrvatske, obrana suvereniteta i teritorijalne cjelovitosti države. Temeljna zadaća je spriječiti prodor agresora u dubinu teritorija, sačuvati vitalne strategijske objekte, osigurati mobilizaciju ratnog sastava i pobijediti agresora. Nositeljica je i organizatorica kopnene obrane Republike Hrvatske.", 4324000000.00),
(2, "Hrvatska ratna mornarica", STR_TO_DATE("12.09.1991.", "%d.%m.%Y."), "Uloga i namjena HRM-e  je štititi integritet i suverenitet Republike Hrvatske na moru i s mora. Nositeljica je i organizatorica pomorske obrane Republike Hrvatske", 2876000000.00),
(3, "Hrvatsko ratno zrakoplovstvo", STR_TO_DATE("12.12.1991.", "%d.%m.%Y."), "Osnovna zadaća HRZ-a je osiguranje suverenosti zračnog prostora Republike Hrvatske te pružanje zrakoplovne potpore drugim granama u provedbi njihovih zadaća u združenim operacijama. Nositelj je i organizator integriranog sustava protuzračne obrane Republike Hrvatske.", 3622000000.00),
(4, "Hrvatska vojna policija", STR_TO_DATE("24.08.1991.", "%d.%m.%Y."), "Vojna policija Oružanih snaga Republike Hrvatske (VP OSRH) pruža potporu Ministarstvu obrane i Oružanim snagama Republike Hrvatske obavljanjem namjenskih vojnopolicijskih poslova u miru i ratu te borbenih zadaća u ratu.", 1822000000.00)
;




INSERT INTO tura VALUES
(01, "UNMOGIP", "Mirovna tura", STR_TO_DATE("01.08.2008","%d.%m.%Y."), STR_TO_DATE("04.11.2021","%d.%m.%Y.")),
(02, "EUFOR Tchad/RCA", "Vojna tura", STR_TO_DATE("01.10.2008","%d.%m.%Y."), STR_TO_DATE("15.04.2009","%d.%m.%Y.")),
(03, "ISAF", "Mirovna tura", STR_TO_DATE("01.12.2010","%d.%m.%Y."), STR_TO_DATE("16.11.2014","%d.%m.%Y.")),
(04, "Resolute support", "Mirovna tura", STR_TO_DATE("01.01.2015","%d.%m.%Y."), STR_TO_DATE("04.09.2020","%d.%m.%Y.")),
(05, "", "Mirovna tura", STR_TO_DATE("01.08.2008","%d.%m.%Y."), STR_TO_DATE("04.11.2021","%d.%m.%Y.")),
(06, "ISAF", "Mirovna tura", STR_TO_DATE("01.12.2010","%d.%m.%Y."), STR_TO_DATE("16.11.2014","%d.%m.%Y."));




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
 BEFORE INSERT ON osoblje
 FOR EACH ROW
BEGIN
 INSERT INTO login VALUES (new.id,new.ime,md5(new.ime));
 -- SET new.lozinka = MD5(new.lozinka);
        
END//
DELIMITER ;
drop trigger kriptiranje;


CREATE TABLE login(
    id INTEGER primary KEY,  -- autoincrement
	ime varchar(100),
    lozinka varchar(100)
);
DROP TABLE login;

-- za kriptiranje lozinke



/*
id INTEGER PRIMARY KEY,
    naziv VARCHAR(50) NOT NULL,
    vrsta_ture VARCHAR(69) NOT NULL,
    vrijeme_pocetka DATETIME NOT NULL,
    vrijeme_kraja DATETIME NOT NULL
*/


INSERT INTO vozila VALUES
(2000,"Patria AMV","Kotačna oklopna vozila",158,3),
(2001,"International MaxxPro","Kotačna oklopna vozila",40,5),
(2002,"Oshkosh M-ATV","Kotačna oklopna vozila",172,5),
(2003,"HMMWV","Kotačna oklopna vozila",112,4),
(2004,"Iveco LMV","Kotačna oklopna vozila",14,4),
(2005,"BOV","Kotačna oklopna vozila",84,6),

(2006,"M2 Bradley","Gusjenična oklopna vozila",67,5),
(2007,"BVP M-80A","Gusjenična oklopna vozila",128,4),
(2008,"M-84","Gusjenična oklopna vozila",78,4),

(2009,"RTOP-11 Kralj Petar Krešimir IV.","Mornarica",1,50),
(2010,"RTOP-12 Kralj Dmitar Zvonimir","Mornarica",1,20),
(2011,"RTOP-21 Šibenik","Mornarica",1,35),
(2012,"RTOP-41 Vukovar","Mornarica",1,36),
(2013,"RTOP-42 Dubrovnik","Mornarica",1,42),
(2014,"Lovac mina LM-51 Korčula","Mornarica",1,55),

(2015,"Dassault Rafale","Borbeni avioni",12,2),
(2016,"Mikojan-Gurjevič MiG-21","Borbeni avioni",7,1),

(2017,"Mil Mi-17","Helikopteri",11,2),
(2018,"Mil Mi-8","Helikopteri",13,4),
(2019,"Sikorsky UH-60 Black Hawk","Helikopteri",2,5),
(2020,"Bell OH-58 Kiowa Warrior","Helikopteri",15,6);

INSERT INTO osoblje VALUES
 ( 10001 , 3 , "Jagoda" , "Lučić" , "Pozornik" , STR_TO_DATE("5.3.1968.", "%d.%m.%Y.") , STR_TO_DATE("21.3.2002.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10002 , 3 , "Arabela" , "Herceg" , "Skupnik" , STR_TO_DATE("1.10.1967.", "%d.%m.%Y.") , STR_TO_DATE("20.10.2013.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10003 , 1 , "Vilim" , "Grgurić" , "Skupnik" , STR_TO_DATE("30.10.1956.", "%d.%m.%Y.") , STR_TO_DATE("3.2.2016.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10004 , 2 , "Julija" , "Kovačić" , "Narednik" , STR_TO_DATE("5.5.1970.", "%d.%m.%Y.") , STR_TO_DATE("8.9.1993.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10005 , 1 , "Anđela" , "Klarić" , "Narednik" , STR_TO_DATE("28.11.1961.", "%d.%m.%Y.") , STR_TO_DATE("18.5.1995.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10006 , 1 , "Donata" , "Vukelić" , "Razvodnik" , STR_TO_DATE("8.10.1956.", "%d.%m.%Y.") , STR_TO_DATE("18.1.2005.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10007 , 4 , "Matija" , "Perić" , "Poručnik" , STR_TO_DATE("24.12.1952.", "%d.%m.%Y.") , STR_TO_DATE("4.11.1995.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10008 , 3 , "Sabina" , "Stanić" , "Pukovnik" , STR_TO_DATE("28.3.1962.", "%d.%m.%Y.") , STR_TO_DATE("13.1.2014.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10009 , 4 , "Alaia" , "Božić" , "Skupnik" , STR_TO_DATE("20.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("13.5.1992.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10010 , 2 , "Damjan" , "Blažević" , "Pozornik" , STR_TO_DATE("24.7.1956.", "%d.%m.%Y.") , STR_TO_DATE("28.7.2005.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10011 , 2 , "Malija" , "Šimunić" , "Brigadir" , STR_TO_DATE("11.5.1955.", "%d.%m.%Y.") , STR_TO_DATE("26.3.2012.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10012 , 1 , "Anamarija" , "Mandić" , "Pozornik" , STR_TO_DATE("24.3.1957.", "%d.%m.%Y.") , STR_TO_DATE("16.10.2008.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10013 , 2 , "Janko" , "Perković" , "Skupnik" , STR_TO_DATE("13.2.1967.", "%d.%m.%Y.") , STR_TO_DATE("4.3.1996.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10014 , 2 , "Korina" , "Babić" , "Pozornik" , STR_TO_DATE("17.10.1969.", "%d.%m.%Y.") , STR_TO_DATE("14.12.1999.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10015 , 4 , "Toni" , "Vukelić" , "Brigadir" , STR_TO_DATE("5.9.1967.", "%d.%m.%Y.") , STR_TO_DATE("3.7.2004.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10016 , 3 , "Nora" , "Marić" , "Brigadir" , STR_TO_DATE("4.5.1956.", "%d.%m.%Y.") , STR_TO_DATE("18.8.1998.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10017 , 3 , "Jana" , "Šimić" , "Pozornik" , STR_TO_DATE("7.2.1952.", "%d.%m.%Y.") , STR_TO_DATE("20.5.2004.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10018 , 4 , "Elio" , "Horvat" , "Narednik" , STR_TO_DATE("29.4.1955.", "%d.%m.%Y.") , STR_TO_DATE("25.8.1999.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10019 , 3 , "Melanija" , "Horvat" , "Skupnik" , STR_TO_DATE("25.7.1967.", "%d.%m.%Y.") , STR_TO_DATE("27.6.1994.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10020 , 1 , "Isla" , "Pavlić" , "Poručnik" , STR_TO_DATE("1.10.1966.", "%d.%m.%Y.") , STR_TO_DATE("19.5.2003.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10021 , 4 , "Emberli" , "Filipović" , "Pukovnik" , STR_TO_DATE("16.9.1970.", "%d.%m.%Y.") , STR_TO_DATE("8.3.2017.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10022 , 2 , "Desa" , "Jovanović" , "Satnik" , STR_TO_DATE("20.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("26.2.1997.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10023 , 2 , "Kalen" , "Katić" , "Skupnik" , STR_TO_DATE("21.1.1963.", "%d.%m.%Y.") , STR_TO_DATE("22.3.2014.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10024 , 4 , "Alijah" , "Šimunić" , "Pozornik" , STR_TO_DATE("6.10.1954.", "%d.%m.%Y.") , STR_TO_DATE("28.6.1996.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10025 , 4 , "Iva" , "Lončar" , "Poručnik" , STR_TO_DATE("30.4.1952.", "%d.%m.%Y.") , STR_TO_DATE("8.9.1993.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10026 , 1 , "Siri" , "Kovačić" , "Bojnik" , STR_TO_DATE("24.6.1962.", "%d.%m.%Y.") , STR_TO_DATE("23.2.2013.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10027 , 3 , "Ilko" , "Novak" , "Razvodnik" , STR_TO_DATE("12.5.1968.", "%d.%m.%Y.") , STR_TO_DATE("25.11.2007.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10028 , 1 , "Martina" , "Kovačić" , "Pozornik" , STR_TO_DATE("9.10.1967.", "%d.%m.%Y.") , STR_TO_DATE("7.5.2006.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10029 , 1 , "Aldo" , "Janković" , "Satnik" , STR_TO_DATE("14.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("8.3.2017.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10030 , 3 , "Emelina" , "Šimunić" , "Razvodnik" , STR_TO_DATE("29.5.1958.", "%d.%m.%Y.") , STR_TO_DATE("13.5.2012.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10031 , 1 , "Esmeralda" , "Ružić" , "Pukovnik" , STR_TO_DATE("1.9.1953.", "%d.%m.%Y.") , STR_TO_DATE("26.2.2015.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10032 , 3 , "Ela" , "Kovačić" , "Satnik" , STR_TO_DATE("8.7.1970.", "%d.%m.%Y.") , STR_TO_DATE("20.7.1995.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10033 , 1 , "Karina" , "Šimić" , "Pozornik" , STR_TO_DATE("7.7.1951.", "%d.%m.%Y.") , STR_TO_DATE("21.2.2013.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10034 , 2 , "Lara" , "Grgić" , "Razvodnik" , STR_TO_DATE("28.4.1968.", "%d.%m.%Y.") , STR_TO_DATE("25.7.2013.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10035 , 2 , "Anatea" , "Lončarić" , "Skupnik" , STR_TO_DATE("8.2.1954.", "%d.%m.%Y.") , STR_TO_DATE("28.1.2005.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10036 , 2 , "Nova" , "Burić" , "Narednik" , STR_TO_DATE("31.7.1968.", "%d.%m.%Y.") , STR_TO_DATE("24.8.2007.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10037 , 1 , "Marjan" , "Marjanović" , "Narednik" , STR_TO_DATE("30.10.1968.", "%d.%m.%Y.") , STR_TO_DATE("31.1.1995.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10038 , 2 , "Mirna" , "Đurđević" , "Pozornik" , STR_TO_DATE("27.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("3.12.2012.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10039 , 2 , "Slavica" , "Cvitković" , "Pozornik" , STR_TO_DATE("11.5.1969.", "%d.%m.%Y.") , STR_TO_DATE("5.11.1998.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10040 , 2 , "Dorotej" , "Lukić" , "Pukovnik" , STR_TO_DATE("6.5.1956.", "%d.%m.%Y.") , STR_TO_DATE("21.9.2006.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10041 , 3 , "Dragutin" , "Novaković" , "Razvodnik" , STR_TO_DATE("17.5.1960.", "%d.%m.%Y.") , STR_TO_DATE("9.5.2000.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10042 , 2 , "Denis" , "Varga" , "Brigadir" , STR_TO_DATE("7.5.1967.", "%d.%m.%Y.") , STR_TO_DATE("14.10.2002.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10043 , 1 , "Milana" , "Horvat" , "Poručnik" , STR_TO_DATE("11.6.1955.", "%d.%m.%Y.") , STR_TO_DATE("30.10.2017.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10044 , 3 , "Gvena" , "Varga" , "Pukovnik" , STR_TO_DATE("25.9.1963.", "%d.%m.%Y.") , STR_TO_DATE("2.8.2011.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10045 , 1 , "Penelopa" , "Grgurić" , "Bojnik" , STR_TO_DATE("19.2.1968.", "%d.%m.%Y.") , STR_TO_DATE("7.11.1998.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10046 , 4 , "Zarija" , "Marjanović" , "Narednik" , STR_TO_DATE("26.5.1955.", "%d.%m.%Y.") , STR_TO_DATE("7.3.2015.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10047 , 3 , "Željkica" , "Matijević" , "Pozornik" , STR_TO_DATE("4.1.1962.", "%d.%m.%Y.") , STR_TO_DATE("31.7.2006.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10048 , 3 , "Julija" , "Ivanović" , "Poručnik" , STR_TO_DATE("7.10.1965.", "%d.%m.%Y.") , STR_TO_DATE("27.1.2007.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10049 , 1 , "Dijana" , "Vuković" , "Poručnik" , STR_TO_DATE("11.12.1969.", "%d.%m.%Y.") , STR_TO_DATE("8.12.2015.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10050 , 4 , "Lili" , "Jozić" , "Pukovnik" , STR_TO_DATE("2.5.1955.", "%d.%m.%Y.") , STR_TO_DATE("22.1.2014.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10051 , 3 , "Jaro" , "Lučić" , "Poručnik" , STR_TO_DATE("19.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("9.4.2003.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10052 , 3 , "Aleks" , "Lučić" , "Brigadir" , STR_TO_DATE("23.2.1967.", "%d.%m.%Y.") , STR_TO_DATE("26.12.2006.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10053 , 2 , "Elie" , "Galić" , "Pukovnik" , STR_TO_DATE("2.3.1966.", "%d.%m.%Y.") , STR_TO_DATE("24.6.2018.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10054 , 4 , "Mihaela" , "Novak" , "Bojnik" , STR_TO_DATE("1.7.1969.", "%d.%m.%Y.") , STR_TO_DATE("20.8.1994.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10055 , 1 , "Matea" , "Sever" , "Poručnik" , STR_TO_DATE("7.9.1958.", "%d.%m.%Y.") , STR_TO_DATE("16.1.2016.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10056 , 4 , "Antun" , "Barišić" , "Razvodnik" , STR_TO_DATE("17.10.1951.", "%d.%m.%Y.") , STR_TO_DATE("23.4.2018.", "%d.%m.%Y.") , "Aktivan" , "A+" );
insert into osoblje values ( 10057 , 4 , "Rhea" , "Živković" , "Narednik" , STR_TO_DATE("22.9.1964.", "%d.%m.%Y.") , STR_TO_DATE("28.2.1996.", "%d.%m.%Y.") , "Umirovljen" , "B+" );
insert into osoblje values( 10058 , 2 , "Mario" , "Šimić" , "Bojnik" , STR_TO_DATE("12.3.1951.", "%d.%m.%Y.") , STR_TO_DATE("10.8.1990.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10059 , 1 , "Jolena" , "Šimunić" , "Brigadir" , STR_TO_DATE("13.12.1961.", "%d.%m.%Y.") , STR_TO_DATE("14.2.2016.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10060 , 3 , "Dorotea" , "Kovačević" , "Poručnik" , STR_TO_DATE("23.10.1968.", "%d.%m.%Y.") , STR_TO_DATE("30.4.2019.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10061 , 2 , "Nika" , "Jurišić" , "Skupnik" , STR_TO_DATE("16.6.1960.", "%d.%m.%Y.") , STR_TO_DATE("18.12.2007.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10062 , 2 , "Slađana" , "Abramović" , "Pukovnik" , STR_TO_DATE("12.6.1970.", "%d.%m.%Y.") , STR_TO_DATE("22.4.1993.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10063 , 4 , "Ela" , "Grgurić" , "Brigadir" , STR_TO_DATE("28.11.1961.", "%d.%m.%Y.") , STR_TO_DATE("27.1.1994.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10064 , 4 , "Oto" , "Janković" , "Poručnik" , STR_TO_DATE("21.5.1966.", "%d.%m.%Y.") , STR_TO_DATE("14.10.1994.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10065 , 1 , "Alicija" , "Marjanović" , "Skupnik" , STR_TO_DATE("2.12.1954.", "%d.%m.%Y.") , STR_TO_DATE("14.3.1997.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10066 , 3 , "Nala" , "Tomić" , "Razvodnik" , STR_TO_DATE("26.3.1958.", "%d.%m.%Y.") , STR_TO_DATE("31.5.2001.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10067 , 3 , "Zoi" , "Ivančić" , "Bojnik" , STR_TO_DATE("30.3.1968.", "%d.%m.%Y.") , STR_TO_DATE("15.10.2018.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10068 , 2 , "Magda" , "Perić" , "Pukovnik" , STR_TO_DATE("10.1.1969.", "%d.%m.%Y.") , STR_TO_DATE("3.12.2017.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10069 , 4 , "Sendi" , "Popović" , "Skupnik" , STR_TO_DATE("5.9.1951.", "%d.%m.%Y.") , STR_TO_DATE("20.6.2020.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10070 , 3 , "Manda" , "Vidaković" , "Brigadir" , STR_TO_DATE("11.9.1958.", "%d.%m.%Y.") , STR_TO_DATE("8.10.2008.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10071 , 4 , "Harmina" , "Knežević" , "Satnik" , STR_TO_DATE("29.5.1951.", "%d.%m.%Y.") , STR_TO_DATE("3.3.2005.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10072 , 1 , "Leon" , "Ružić" , "Skupnik" , STR_TO_DATE("8.4.1956.", "%d.%m.%Y.") , STR_TO_DATE("5.5.1991.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10073 , 4 , "Elana" , "Mandić" , "Poručnik" , STR_TO_DATE("27.1.1950.", "%d.%m.%Y.") , STR_TO_DATE("22.5.2002.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10074 , 4 , "Sendi" , "Šimunić" , "Poručnik" , STR_TO_DATE("9.1.1950.", "%d.%m.%Y.") , STR_TO_DATE("24.12.2018.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10075 , 4 , "Lilika" , "Varga" , "Brigadir" , STR_TO_DATE("29.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("5.9.1992.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10076 , 3 , "Mihael" , "Katić" , "Poručnik" , STR_TO_DATE("21.10.1964.", "%d.%m.%Y.") , STR_TO_DATE("30.6.2005.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10077 , 1 , "Elivija" , "Perić" , "Pukovnik" , STR_TO_DATE("23.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("25.1.2016.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10078 , 4 , "Goranka" , "Brkić" , "Bojnik" , STR_TO_DATE("26.3.1959.", "%d.%m.%Y.") , STR_TO_DATE("15.4.1999.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10079 , 1 , "Leonardo" , "Bilić" , "Bojnik" , STR_TO_DATE("21.6.1966.", "%d.%m.%Y.") , STR_TO_DATE("22.12.1990.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10080 , 4 , "Alora" , "Marušić" , "Satnik" , STR_TO_DATE("23.4.1960.", "%d.%m.%Y.") , STR_TO_DATE("12.3.2010.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10081 , 3 , "Sandi" , "Jurić" , "Pukovnik" , STR_TO_DATE("23.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("30.11.2016.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10082 , 1 , "Eta" , "Matić" , "Razvodnik" , STR_TO_DATE("28.11.1950.", "%d.%m.%Y.") , STR_TO_DATE("13.12.2002.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10083 , 1 , "Šime" , "Klarić" , "Brigadir" , STR_TO_DATE("25.11.1968.", "%d.%m.%Y.") , STR_TO_DATE("21.7.2010.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10084 , 3 , "Azalea" , "Grgurić" , "Brigadir" , STR_TO_DATE("20.12.1950.", "%d.%m.%Y.") , STR_TO_DATE("8.5.2003.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10085 , 2 , "Amaja" , "Matković" , "Poručnik" , STR_TO_DATE("18.10.1970.", "%d.%m.%Y.") , STR_TO_DATE("6.7.2000.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10086 , 4 , "Lola" , "Filipović" , "Skupnik" , STR_TO_DATE("11.4.1950.", "%d.%m.%Y.") , STR_TO_DATE("25.2.2006.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10087 , 3 , "Sunčana" , "Novaković" , "Satnik" , STR_TO_DATE("29.4.1956.", "%d.%m.%Y.") , STR_TO_DATE("22.1.2015.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10088 , 2 , "Kai" , "Lukić" , "Pukovnik" , STR_TO_DATE("27.1.1958.", "%d.%m.%Y.") , STR_TO_DATE("1.6.1996.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10089 , 2 , "Severina" , "Kralj" , "Brigadir" , STR_TO_DATE("2.5.1960.", "%d.%m.%Y.") , STR_TO_DATE("4.1.2017.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10090 , 2 , "Tihana" , "Vrdoljak" , "Pukovnik" , STR_TO_DATE("8.5.1957.", "%d.%m.%Y.") , STR_TO_DATE("12.6.2000.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10091 , 1 , "Julijana" , "Lukić" , "Bojnik" , STR_TO_DATE("11.5.1967.", "%d.%m.%Y.") , STR_TO_DATE("21.7.1991.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10092 , 3 , "Cvijeta" , "Ivanković" , "Pukovnik" , STR_TO_DATE("11.5.1969.", "%d.%m.%Y.") , STR_TO_DATE("22.3.2013.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10093 , 3 , "Viena" , "Matijević" , "Skupnik" , STR_TO_DATE("23.6.1960.", "%d.%m.%Y.") , STR_TO_DATE("13.9.1994.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10094 , 3 , "Zoi" , "Matić" , "Razvodnik" , STR_TO_DATE("4.3.1954.", "%d.%m.%Y.") , STR_TO_DATE("11.5.2018.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10095 , 2 , "Teresa" , "Butković" , "Brigadir" , STR_TO_DATE("24.9.1964.", "%d.%m.%Y.") , STR_TO_DATE("16.6.1990.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10096 , 2 , "Jadranko" , "Perković" , "Pozornik" , STR_TO_DATE("21.2.1951.", "%d.%m.%Y.") , STR_TO_DATE("16.11.2020.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10097 , 2 , "Slaven" , "Dujmović" , "Razvodnik" , STR_TO_DATE("21.12.1970.", "%d.%m.%Y.") , STR_TO_DATE("30.11.2002.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10098 , 3 , "Alana" , "Jovanović" , "Skupnik" , STR_TO_DATE("14.2.1966.", "%d.%m.%Y.") , STR_TO_DATE("17.5.2010.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10099 , 2 , "Antun" , "Bilić" , "Bojnik" , STR_TO_DATE("8.4.1969.", "%d.%m.%Y.") , STR_TO_DATE("4.9.2018.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10100 , 4 , "Barbara" , "Jelić" , "Pozornik" , STR_TO_DATE("5.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("17.12.2009.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10101 , 3 , "Liv" , "Perković" , "Pukovnik" , STR_TO_DATE("27.11.1951.", "%d.%m.%Y.") , STR_TO_DATE("4.10.1991.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10102 , 2 , "Zoe" , "Pavlić" , "Narednik" , STR_TO_DATE("8.9.1969.", "%d.%m.%Y.") , STR_TO_DATE("14.4.2018.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10103 , 4 , "Zvjezdana" , "Jelić" , "Bojnik" , STR_TO_DATE("14.6.1966.", "%d.%m.%Y.") , STR_TO_DATE("11.4.2013.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10104 , 3 , "Zarija" , "Mandić" , "Brigadir" , STR_TO_DATE("24.5.1965.", "%d.%m.%Y.") , STR_TO_DATE("26.9.2019.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10105 , 2 , "Teo" , "Lončar" , "Brigadir" , STR_TO_DATE("13.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("11.2.1992.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10106 , 4 , "Levi" , "Burić" , "Razvodnik" , STR_TO_DATE("4.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("20.9.1994.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10107 , 1 , "Oto" , "Popović" , "Pozornik" , STR_TO_DATE("28.2.1970.", "%d.%m.%Y.") , STR_TO_DATE("30.12.1991.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10108 , 1 , "Emil" , "Bošnjak" , "Bojnik" , STR_TO_DATE("7.5.1958.", "%d.%m.%Y.") , STR_TO_DATE("5.6.2011.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10109 , 3 , "Valentin" , "Brajković" , "Brigadir" , STR_TO_DATE("16.8.1964.", "%d.%m.%Y.") , STR_TO_DATE("31.3.2006.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10110 , 1 , "Mae" , "Tomić" , "Razvodnik" , STR_TO_DATE("14.6.1960.", "%d.%m.%Y.") , STR_TO_DATE("25.10.2020.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10111 , 3 , "Josipa" , "Posavec" , "Bojnik" , STR_TO_DATE("27.5.1964.", "%d.%m.%Y.") , STR_TO_DATE("28.3.2020.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10112 , 1 , "Siri" , "Šimunić" , "Bojnik" , STR_TO_DATE("9.4.1960.", "%d.%m.%Y.") , STR_TO_DATE("1.8.1994.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10113 , 2 , "Leonardo" , "Mandić" , "Narednik" , STR_TO_DATE("6.7.1960.", "%d.%m.%Y.") , STR_TO_DATE("26.9.1993.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10114 , 2 , "Lena" , "Šimunović" , "Pozornik" , STR_TO_DATE("29.12.1959.", "%d.%m.%Y.") , STR_TO_DATE("9.5.2003.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10115 , 1 , "David" , "Lučić" , "Skupnik" , STR_TO_DATE("8.6.1951.", "%d.%m.%Y.") , STR_TO_DATE("13.8.2005.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10116 , 1 , "Jaro" , "Krznarić" , "Satnik" , STR_TO_DATE("5.4.1953.", "%d.%m.%Y.") , STR_TO_DATE("25.9.1991.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10117 , 4 , "Demi" , "Jovanović" , "Satnik" , STR_TO_DATE("27.4.1965.", "%d.%m.%Y.") , STR_TO_DATE("28.11.2002.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10118 , 2 , "Adela" , "Kolarić" , "Satnik" , STR_TO_DATE("17.12.1963.", "%d.%m.%Y.") , STR_TO_DATE("8.2.2008.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10119 , 3 , "Katarina" , "Matković" , "Pozornik" , STR_TO_DATE("31.7.1962.", "%d.%m.%Y.") , STR_TO_DATE("9.7.2009.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10120 , 2 , "Vada" , "Kovačić" , "Pukovnik" , STR_TO_DATE("17.12.1953.", "%d.%m.%Y.") , STR_TO_DATE("6.11.2009.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10121 , 4 , "Neven" , "Šarić" , "Skupnik" , STR_TO_DATE("6.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("28.8.2002.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10122 , 4 , "Jolena" , "Horvat" , "Poručnik" , STR_TO_DATE("11.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("17.2.1997.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10123 , 4 , "Dragica" , "Kovačević" , "Brigadir" , STR_TO_DATE("18.8.1959.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2004.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10124 , 4 , "Arijela" , "Rukavina" , "Satnik" , STR_TO_DATE("16.1.1967.", "%d.%m.%Y.") , STR_TO_DATE("10.3.2016.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10125 , 2 , "Martina" , "Babić" , "Brigadir" , STR_TO_DATE("2.1.1970.", "%d.%m.%Y.") , STR_TO_DATE("10.7.1998.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10126 , 3 , "Jasmina" , "Novosel" , "Poručnik" , STR_TO_DATE("13.3.1956.", "%d.%m.%Y.") , STR_TO_DATE("17.6.2004.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10127 , 3 , "Mila" , "Perković" , "Bojnik" , STR_TO_DATE("1.4.1962.", "%d.%m.%Y.") , STR_TO_DATE("17.7.2012.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10128 , 1 , "Ezra" , "Posavec" , "Razvodnik" , STR_TO_DATE("7.7.1960.", "%d.%m.%Y.") , STR_TO_DATE("24.12.2004.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10129 , 2 , "Maksima" , "Crnković" , "Bojnik" , STR_TO_DATE("11.2.1970.", "%d.%m.%Y.") , STR_TO_DATE("23.12.2013.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10130 , 4 , "Zola" , "Šimunović" , "Razvodnik" , STR_TO_DATE("21.10.1968.", "%d.%m.%Y.") , STR_TO_DATE("20.9.2012.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10131 , 4 , "Penelopa" , "Sever" , "Pukovnik" , STR_TO_DATE("30.11.1957.", "%d.%m.%Y.") , STR_TO_DATE("27.1.1997.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10132 , 2 , "Leona" , "Ivanković" , "Pozornik" , STR_TO_DATE("22.10.1950.", "%d.%m.%Y.") , STR_TO_DATE("19.12.1993.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10133 , 4 , "Kiana" , "Klarić" , "Razvodnik" , STR_TO_DATE("29.3.1967.", "%d.%m.%Y.") , STR_TO_DATE("27.1.1994.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10134 , 2 , "Kali" , "Dragičević" , "Pukovnik" , STR_TO_DATE("21.10.1953.", "%d.%m.%Y.") , STR_TO_DATE("26.1.2006.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10135 , 4 , "Tomislava" , "Jelić" , "Satnik" , STR_TO_DATE("12.11.1959.", "%d.%m.%Y.") , STR_TO_DATE("22.9.1991.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10136 , 2 , "Manuel" , "Đurđević" , "Satnik" , STR_TO_DATE("25.5.1958.", "%d.%m.%Y.") , STR_TO_DATE("5.10.2002.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10137 , 3 , "Nia" , "Jurić" , "Pozornik" , STR_TO_DATE("28.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("27.1.2004.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10138 , 3 , "Ksaver" , "Burić" , "Poručnik" , STR_TO_DATE("30.6.1963.", "%d.%m.%Y.") , STR_TO_DATE("26.5.2016.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10139 , 2 , "Jerko" , "Mitrović" , "Razvodnik" , STR_TO_DATE("4.3.1951.", "%d.%m.%Y.") , STR_TO_DATE("22.2.2012.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10140 , 4 , "Tina" , "Petrović" , "Bojnik" , STR_TO_DATE("18.9.1962.", "%d.%m.%Y.") , STR_TO_DATE("23.5.2012.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10141 , 2 , "Severino" , "Božić" , "Bojnik" , STR_TO_DATE("25.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("30.4.2020.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10142 , 3 , "Lika" , "Kralj" , "Brigadir" , STR_TO_DATE("6.6.1953.", "%d.%m.%Y.") , STR_TO_DATE("14.9.2004.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10143 , 1 , "Darko" , "Ivanković" , "Poručnik" , STR_TO_DATE("28.3.1957.", "%d.%m.%Y.") , STR_TO_DATE("28.5.2004.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10144 , 1 , "Jada" , "Dujmović" , "Skupnik" , STR_TO_DATE("17.5.1961.", "%d.%m.%Y.") , STR_TO_DATE("5.5.1998.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10145 , 1 , "Aleksandra" , "Jozić" , "Poručnik" , STR_TO_DATE("14.12.1952.", "%d.%m.%Y.") , STR_TO_DATE("12.9.2007.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10146 , 4 , "Marcel" , "Kolarić" , "Satnik" , STR_TO_DATE("11.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("19.1.2002.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10147 , 3 , "Romea" , "Marković" , "Bojnik" , STR_TO_DATE("15.12.1965.", "%d.%m.%Y.") , STR_TO_DATE("5.12.2010.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10148 , 1 , "Dunja" , "Kovačić" , "Skupnik" , STR_TO_DATE("9.7.1961.", "%d.%m.%Y.") , STR_TO_DATE("19.6.1999.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10149 , 1 , "Sunčana" , "Dujmović" , "Bojnik" , STR_TO_DATE("9.2.1970.", "%d.%m.%Y.") , STR_TO_DATE("17.11.2017.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10150 , 3 , "Divna" , "Galić" , "Brigadir" , STR_TO_DATE("20.3.1959.", "%d.%m.%Y.") , STR_TO_DATE("1.7.2001.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10151 , 4 , "Mikaela" , "Blažević" , "Razvodnik" , STR_TO_DATE("7.1.1965.", "%d.%m.%Y.") , STR_TO_DATE("22.4.1992.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10152 , 4 , "Natalija" , "Janković" , "Bojnik" , STR_TO_DATE("22.12.1958.", "%d.%m.%Y.") , STR_TO_DATE("29.4.1993.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10153 , 1 , "Oskar" , "Perković" , "Bojnik" , STR_TO_DATE("11.3.1952.", "%d.%m.%Y.") , STR_TO_DATE("3.10.2015.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10154 , 2 , "Estela" , "Blažević" , "Narednik" , STR_TO_DATE("3.4.1957.", "%d.%m.%Y.") , STR_TO_DATE("23.12.2003.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10155 , 2 , "Koraljka" , "Kovač" , "Brigadir" , STR_TO_DATE("4.6.1966.", "%d.%m.%Y.") , STR_TO_DATE("25.3.2008.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10156 , 3 , "Hai" , "Vidaković" , "Satnik" , STR_TO_DATE("16.10.1969.", "%d.%m.%Y.") , STR_TO_DATE("6.2.2013.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10157 , 2 , "Hada" , "Marić" , "Pozornik" , STR_TO_DATE("10.2.1960.", "%d.%m.%Y.") , STR_TO_DATE("20.10.2018.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10158 , 2 , "Alea" , "Jelić" , "Razvodnik" , STR_TO_DATE("21.12.1965.", "%d.%m.%Y.") , STR_TO_DATE("28.4.2007.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10159 , 2 , "Serena" , "Knežević" , "Pukovnik" , STR_TO_DATE("18.12.1955.", "%d.%m.%Y.") , STR_TO_DATE("8.12.2017.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10160 , 2 , "Amaia" , "Rukavina" , "Pukovnik" , STR_TO_DATE("27.7.1966.", "%d.%m.%Y.") , STR_TO_DATE("29.5.2010.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10161 , 1 , "Ivano" , "Miletić" , "Bojnik" , STR_TO_DATE("28.6.1953.", "%d.%m.%Y.") , STR_TO_DATE("7.11.2009.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10162 , 3 , "Briela" , "Jakovljević" , "Skupnik" , STR_TO_DATE("31.8.1965.", "%d.%m.%Y.") , STR_TO_DATE("13.10.1995.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10163 , 3 , "Tristan" , "Đurić" , "Pukovnik" , STR_TO_DATE("16.1.1958.", "%d.%m.%Y.") , STR_TO_DATE("19.8.1997.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10164 , 1 , "Nikolina" , "Galić" , "Poručnik" , STR_TO_DATE("9.10.1953.", "%d.%m.%Y.") , STR_TO_DATE("5.7.1990.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10165 , 3 , "Rohan" , "Kovačić" , "Razvodnik" , STR_TO_DATE("11.4.1966.", "%d.%m.%Y.") , STR_TO_DATE("22.7.1992.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10166 , 4 , "Liam" , "Šimunović" , "Pukovnik" , STR_TO_DATE("5.5.1960.", "%d.%m.%Y.") , STR_TO_DATE("22.12.2008.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10167 , 2 , "Kaja" , "Brajković" , "Satnik" , STR_TO_DATE("16.10.1966.", "%d.%m.%Y.") , STR_TO_DATE("11.8.1993.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10168 , 2 , "Vada" , "Kralj" , "Pozornik" , STR_TO_DATE("22.2.1956.", "%d.%m.%Y.") , STR_TO_DATE("20.5.2018.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10169 , 1 , "Sumka" , "Grgurić" , "Narednik" , STR_TO_DATE("4.11.1951.", "%d.%m.%Y.") , STR_TO_DATE("3.6.2008.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10170 , 4 , "Toni" , "Vuković" , "Razvodnik" , STR_TO_DATE("27.10.1966.", "%d.%m.%Y.") , STR_TO_DATE("26.12.2016.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10171 , 3 , "Loreta" , "Đurđević" , "Satnik" , STR_TO_DATE("1.3.1958.", "%d.%m.%Y.") , STR_TO_DATE("28.5.2014.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10172 , 2 , "Martina" , "Knežević" , "Narednik" , STR_TO_DATE("21.2.1967.", "%d.%m.%Y.") , STR_TO_DATE("10.10.2013.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10173 , 1 , "Martina" , "Josipović" , "Razvodnik" , STR_TO_DATE("2.11.1968.", "%d.%m.%Y.") , STR_TO_DATE("30.6.1999.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10174 , 3 , "Klementina" , "Janković" , "Razvodnik" , STR_TO_DATE("13.4.1962.", "%d.%m.%Y.") , STR_TO_DATE("11.10.1991.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10175 , 3 , "Lile" , "Cindrić" , "Poručnik" , STR_TO_DATE("29.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.6.1990.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10176 , 2 , "Eliza" , "Vuković" , "Satnik" , STR_TO_DATE("1.2.1966.", "%d.%m.%Y.") , STR_TO_DATE("18.3.2004.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10177 , 4 , "Željkica" , "Vidović" , "Brigadir" , STR_TO_DATE("29.1.1969.", "%d.%m.%Y.") , STR_TO_DATE("16.5.2016.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10178 , 3 , "Franko" , "Butković" , "Skupnik" , STR_TO_DATE("18.11.1967.", "%d.%m.%Y.") , STR_TO_DATE("1.4.1993.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10179 , 2 , "Pepa" , "Nikolić" , "Brigadir" , STR_TO_DATE("1.7.1970.", "%d.%m.%Y.") , STR_TO_DATE("5.9.2018.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10180 , 3 , "Mauro" , "Knežević" , "Brigadir" , STR_TO_DATE("4.6.1962.", "%d.%m.%Y.") , STR_TO_DATE("31.7.2013.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10181 , 1 , "Salema" , "Blažević" , "Bojnik" , STR_TO_DATE("27.11.1951.", "%d.%m.%Y.") , STR_TO_DATE("9.12.2009.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10182 , 1 , "Adam" , "Šimunović" , "Narednik" , STR_TO_DATE("7.3.1960.", "%d.%m.%Y.") , STR_TO_DATE("10.5.2011.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10183 , 3 , "Leonida" , "Vidaković" , "Pukovnik" , STR_TO_DATE("22.4.1956.", "%d.%m.%Y.") , STR_TO_DATE("12.12.2018.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10184 , 3 , "Bara" , "Perković" , "Razvodnik" , STR_TO_DATE("11.3.1958.", "%d.%m.%Y.") , STR_TO_DATE("28.6.2013.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10185 , 2 , "Delila" , "Dragičević" , "Brigadir" , STR_TO_DATE("14.7.1955.", "%d.%m.%Y.") , STR_TO_DATE("11.11.2013.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10186 , 4 , "Davina" , "Perić" , "Pukovnik" , STR_TO_DATE("28.12.1957.", "%d.%m.%Y.") , STR_TO_DATE("11.3.1996.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10187 , 2 , "Leonid" , "Marković" , "Pozornik" , STR_TO_DATE("16.11.1952.", "%d.%m.%Y.") , STR_TO_DATE("8.11.2015.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10188 , 1 , "Siena" , "Božić" , "Satnik" , STR_TO_DATE("4.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("7.12.2020.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10189 , 1 , "Anabela" , "Bašić" , "Pozornik" , STR_TO_DATE("18.5.1966.", "%d.%m.%Y.") , STR_TO_DATE("3.8.2020.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10190 , 4 , "Bela" , "Varga" , "Brigadir" , STR_TO_DATE("16.12.1960.", "%d.%m.%Y.") , STR_TO_DATE("1.9.1993.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10191 , 1 , "Amir" , "Božić" , "Poručnik" , STR_TO_DATE("8.9.1965.", "%d.%m.%Y.") , STR_TO_DATE("19.11.2010.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10192 , 2 , "Đina" , "Perković" , "Brigadir" , STR_TO_DATE("25.8.1953.", "%d.%m.%Y.") , STR_TO_DATE("26.3.1997.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10193 , 3 , "Rubi" , "Grgurić" , "Pukovnik" , STR_TO_DATE("16.2.1954.", "%d.%m.%Y.") , STR_TO_DATE("12.2.2002.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10194 , 3 , "Daniel" , "Brajković" , "Satnik" , STR_TO_DATE("11.8.1956.", "%d.%m.%Y.") , STR_TO_DATE("30.9.1997.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10195 , 2 , "Karmela" , "Crnković" , "Pozornik" , STR_TO_DATE("14.10.1958.", "%d.%m.%Y.") , STR_TO_DATE("28.8.1998.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10196 , 3 , "Filip" , "Pavlović" , "Satnik" , STR_TO_DATE("2.1.1951.", "%d.%m.%Y.") , STR_TO_DATE("10.4.2003.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10197 , 1 , "Kaila" , "Matković" , "Brigadir" , STR_TO_DATE("16.10.1962.", "%d.%m.%Y.") , STR_TO_DATE("18.4.2000.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10198 , 4 , "Princa" , "Lukić" , "Brigadir" , STR_TO_DATE("23.4.1966.", "%d.%m.%Y.") , STR_TO_DATE("15.11.2003.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10199 , 2 , "Roberta" , "Grgić" , "Razvodnik" , STR_TO_DATE("31.1.1954.", "%d.%m.%Y.") , STR_TO_DATE("29.12.1993.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10200 , 1 , "Ediza" , "Mikulić" , "Brigadir" , STR_TO_DATE("11.9.1964.", "%d.%m.%Y.") , STR_TO_DATE("20.6.2013.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10201 , 1 , "Janko" , "Kovač" , "Bojnik" , STR_TO_DATE("20.11.1968.", "%d.%m.%Y.") , STR_TO_DATE("17.11.2017.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10202 , 4 , "Gema" , "Pavlović" , "Narednik" , STR_TO_DATE("24.1.1969.", "%d.%m.%Y.") , STR_TO_DATE("28.3.1998.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10203 , 3 , "Filip" , "Vrdoljak" , "Brigadir" , STR_TO_DATE("20.12.1962.", "%d.%m.%Y.") , STR_TO_DATE("6.9.2017.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10204 , 2 , "Iris" , "Vučković" , "Pukovnik" , STR_TO_DATE("12.4.1967.", "%d.%m.%Y.") , STR_TO_DATE("26.6.2006.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10205 , 4 , "Miranda" , "Crnković" , "Razvodnik" , STR_TO_DATE("10.11.1952.", "%d.%m.%Y.") , STR_TO_DATE("9.6.2006.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10206 , 2 , "Paola" , "Petrović" , "Narednik" , STR_TO_DATE("2.5.1969.", "%d.%m.%Y.") , STR_TO_DATE("23.11.1995.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10207 , 4 , "Pavle" , "Mandić" , "Satnik" , STR_TO_DATE("17.12.1967.", "%d.%m.%Y.") , STR_TO_DATE("22.7.2020.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10208 , 2 , "Karolina" , "Šarić" , "Brigadir" , STR_TO_DATE("3.7.1961.", "%d.%m.%Y.") , STR_TO_DATE("15.1.2005.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10209 , 4 , "Marija" , "Kralj" , "Narednik" , STR_TO_DATE("10.12.1951.", "%d.%m.%Y.") , STR_TO_DATE("29.4.1998.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10210 , 2 , "Levi" , "Filipović" , "Poručnik" , STR_TO_DATE("8.7.1965.", "%d.%m.%Y.") , STR_TO_DATE("6.6.2003.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10211 , 2 , "Nikol" , "Mandić" , "Pukovnik" , STR_TO_DATE("27.2.1968.", "%d.%m.%Y.") , STR_TO_DATE("11.1.1994.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10212 , 3 , "Kai" , "Novosel" , "Poručnik" , STR_TO_DATE("17.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("1.6.2012.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10213 , 2 , "Eva" , "Bošnjak" , "Pukovnik" , STR_TO_DATE("2.11.1961.", "%d.%m.%Y.") , STR_TO_DATE("5.10.2011.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10214 , 2 , "Leonardo" , "Abramović" , "Poručnik" , STR_TO_DATE("25.9.1951.", "%d.%m.%Y.") , STR_TO_DATE("2.1.2000.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10215 , 2 , "Tim" , "Knežević" , "Brigadir" , STR_TO_DATE("15.7.1960.", "%d.%m.%Y.") , STR_TO_DATE("16.1.1998.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10216 , 2 , "Ela" , "Šimić" , "Brigadir" , STR_TO_DATE("21.8.1967.", "%d.%m.%Y.") , STR_TO_DATE("30.5.1999.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10217 , 4 , "Aleksandra" , "Jelić" , "Narednik" , STR_TO_DATE("4.6.1961.", "%d.%m.%Y.") , STR_TO_DATE("5.8.1994.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10218 , 2 , "Tim" , "Živković" , "Pukovnik" , STR_TO_DATE("26.7.1958.", "%d.%m.%Y.") , STR_TO_DATE("20.10.2009.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10219 , 3 , "Simon" , "Barišić" , "Satnik" , STR_TO_DATE("27.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("27.4.1992.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10220 , 3 , "Ita" , "Janković" , "Poručnik" , STR_TO_DATE("2.12.1956.", "%d.%m.%Y.") , STR_TO_DATE("8.11.2000.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10221 , 1 , "Armina" , "Marušić" , "Pukovnik" , STR_TO_DATE("25.11.1951.", "%d.%m.%Y.") , STR_TO_DATE("29.4.2005.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10222 , 3 , "Mara" , "Ružić" , "Pukovnik" , STR_TO_DATE("4.7.1957.", "%d.%m.%Y.") , STR_TO_DATE("15.10.2005.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10223 , 4 , "Lada" , "Lončar" , "Brigadir" , STR_TO_DATE("7.12.1957.", "%d.%m.%Y.") , STR_TO_DATE("16.3.2015.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10224 , 2 , "Florenca" , "Novosel" , "Bojnik" , STR_TO_DATE("23.10.1959.", "%d.%m.%Y.") , STR_TO_DATE("10.12.2000.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10225 , 2 , "Dalia" , "Perić" , "Brigadir" , STR_TO_DATE("9.2.1969.", "%d.%m.%Y.") , STR_TO_DATE("30.8.2005.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10226 , 4 , "Samara" , "Novaković" , "Narednik" , STR_TO_DATE("5.12.1962.", "%d.%m.%Y.") , STR_TO_DATE("12.6.1990.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10227 , 1 , "Kiara" , "Šimunović" , "Pukovnik" , STR_TO_DATE("27.5.1961.", "%d.%m.%Y.") , STR_TO_DATE("27.10.1994.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10228 , 3 , "Aziel" , "Tomić" , "Pozornik" , STR_TO_DATE("17.8.1969.", "%d.%m.%Y.") , STR_TO_DATE("19.2.2001.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10229 , 3 , "Levi" , "Kolarić" , "Skupnik" , STR_TO_DATE("21.5.1964.", "%d.%m.%Y.") , STR_TO_DATE("9.5.2012.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10230 , 1 , "Liam" , "Grgić" , "Poručnik" , STR_TO_DATE("14.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("13.2.2010.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10231 , 4 , "Luna" , "Marušić" , "Bojnik" , STR_TO_DATE("9.7.1961.", "%d.%m.%Y.") , STR_TO_DATE("19.12.1997.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10232 , 4 , "Marica" , "Horvat" , "Poručnik" , STR_TO_DATE("17.8.1961.", "%d.%m.%Y.") , STR_TO_DATE("1.3.2019.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10233 , 2 , "Gvena" , "Vrdoljak" , "Pozornik" , STR_TO_DATE("24.2.1950.", "%d.%m.%Y.") , STR_TO_DATE("20.4.1995.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10234 , 3 , "Ivo" , "Abramović" , "Skupnik" , STR_TO_DATE("6.1.1968.", "%d.%m.%Y.") , STR_TO_DATE("24.9.2009.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10235 , 2 , "Oli" , "Vučković" , "Satnik" , STR_TO_DATE("13.12.1965.", "%d.%m.%Y.") , STR_TO_DATE("14.1.2015.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10236 , 4 , "Alija" , "Marković" , "Brigadir" , STR_TO_DATE("18.9.1970.", "%d.%m.%Y.") , STR_TO_DATE("23.8.2004.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10237 , 4 , "Mira" , "Ružić" , "Satnik" , STR_TO_DATE("7.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("12.6.2005.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10238 , 1 , "Maca" , "Tomić" , "Skupnik" , STR_TO_DATE("9.4.1960.", "%d.%m.%Y.") , STR_TO_DATE("23.11.2001.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10239 , 4 , "Franjo" , "Lončar" , "Brigadir" , STR_TO_DATE("31.10.1954.", "%d.%m.%Y.") , STR_TO_DATE("28.9.1991.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10240 , 1 , "Ante" , "Pavlić" , "Pozornik" , STR_TO_DATE("19.1.1966.", "%d.%m.%Y.") , STR_TO_DATE("21.12.2000.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10241 , 1 , "Loreta" , "Bošnjak" , "Pukovnik" , STR_TO_DATE("22.5.1970.", "%d.%m.%Y.") , STR_TO_DATE("23.3.2011.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10242 , 3 , "Amber" , "Sever" , "Poručnik" , STR_TO_DATE("6.8.1968.", "%d.%m.%Y.") , STR_TO_DATE("28.3.2015.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10243 , 1 , "Josipa" , "Pavlović" , "Brigadir" , STR_TO_DATE("15.11.1953.", "%d.%m.%Y.") , STR_TO_DATE("9.9.2019.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10244 , 3 , "Dejan" , "Posavec" , "Poručnik" , STR_TO_DATE("8.4.1968.", "%d.%m.%Y.") , STR_TO_DATE("23.12.2000.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10245 , 3 , "Miroslava" , "Jakovljević" , "Narednik" , STR_TO_DATE("19.4.1967.", "%d.%m.%Y.") , STR_TO_DATE("28.9.2017.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10246 , 2 , "Srećko" , "Barišić" , "Razvodnik" , STR_TO_DATE("29.7.1966.", "%d.%m.%Y.") , STR_TO_DATE("28.1.1994.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10247 , 1 , "Mio" , "Knežević" , "Pukovnik" , STR_TO_DATE("15.5.1959.", "%d.%m.%Y.") , STR_TO_DATE("10.12.2005.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10248 , 1 , "Kina" , "Jukić" , "Skupnik" , STR_TO_DATE("3.1.1955.", "%d.%m.%Y.") , STR_TO_DATE("24.10.1997.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10249 , 3 , "Zakarija" , "Živković" , "Satnik" , STR_TO_DATE("24.10.1957.", "%d.%m.%Y.") , STR_TO_DATE("19.1.2015.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10250 , 2 , "Sanja" , "Grgić" , "Skupnik" , STR_TO_DATE("27.2.1970.", "%d.%m.%Y.") , STR_TO_DATE("16.11.2004.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10251 , 2 , "Oli" , "Crnković" , "Brigadir" , STR_TO_DATE("23.2.1953.", "%d.%m.%Y.") , STR_TO_DATE("17.10.1995.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10252 , 2 , "Greta" , "Jukić" , "Pozornik" , STR_TO_DATE("10.2.1952.", "%d.%m.%Y.") , STR_TO_DATE("27.12.2013.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10253 , 1 , "Nataša" , "Novosel" , "Satnik" , STR_TO_DATE("20.8.1957.", "%d.%m.%Y.") , STR_TO_DATE("26.5.2013.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10254 , 2 , "Tereza" , "Babić" , "Brigadir" , STR_TO_DATE("9.2.1954.", "%d.%m.%Y.") , STR_TO_DATE("11.12.2007.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10255 , 3 , "Elora" , "Kolarić" , "Bojnik" , STR_TO_DATE("27.6.1961.", "%d.%m.%Y.") , STR_TO_DATE("22.6.2006.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10256 , 2 , "Lejla" , "Tomić" , "Poručnik" , STR_TO_DATE("11.7.1957.", "%d.%m.%Y.") , STR_TO_DATE("28.5.1993.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10257 , 2 , "Romea" , "Marić" , "Pozornik" , STR_TO_DATE("25.4.1956.", "%d.%m.%Y.") , STR_TO_DATE("30.6.1990.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10258 , 4 , "Ane" , "Jozić" , "Pukovnik" , STR_TO_DATE("2.2.1960.", "%d.%m.%Y.") , STR_TO_DATE("20.10.2008.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10259 , 2 , "Simona" , "Crnković" , "Skupnik" , STR_TO_DATE("14.10.1960.", "%d.%m.%Y.") , STR_TO_DATE("4.3.1999.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10260 , 3 , "Irena" , "Petrović" , "Skupnik" , STR_TO_DATE("22.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("10.9.2014.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10261 , 1 , "Marina" , "Jurić" , "Satnik" , STR_TO_DATE("11.5.1950.", "%d.%m.%Y.") , STR_TO_DATE("25.12.2014.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10262 , 4 , "Mirijam" , "Pavlović" , "Skupnik" , STR_TO_DATE("10.11.1952.", "%d.%m.%Y.") , STR_TO_DATE("12.8.1994.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10263 , 3 , "Magda" , "Blažević" , "Razvodnik" , STR_TO_DATE("7.12.1968.", "%d.%m.%Y.") , STR_TO_DATE("22.12.2008.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10264 , 4 , "Lovorka" , "Lončar" , "Satnik" , STR_TO_DATE("30.4.1951.", "%d.%m.%Y.") , STR_TO_DATE("11.1.1998.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10265 , 1 , "Jara" , "Tomić" , "Narednik" , STR_TO_DATE("27.10.1961.", "%d.%m.%Y.") , STR_TO_DATE("8.2.2012.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10266 , 1 , "Disa" , "Ivanović" , "Satnik" , STR_TO_DATE("13.4.1961.", "%d.%m.%Y.") , STR_TO_DATE("21.11.1999.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10267 , 4 , "Simon" , "Mitrović" , "Narednik" , STR_TO_DATE("22.2.1963.", "%d.%m.%Y.") , STR_TO_DATE("10.1.2017.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10268 , 2 , "Anastasija" , "Dragičević" , "Poručnik" , STR_TO_DATE("30.8.1964.", "%d.%m.%Y.") , STR_TO_DATE("10.8.2013.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10269 , 1 , "Breta" , "Babić" , "Bojnik" , STR_TO_DATE("25.3.1969.", "%d.%m.%Y.") , STR_TO_DATE("29.1.2016.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10270 , 4 , "Barbara" , "Jurković" , "Skupnik" , STR_TO_DATE("2.2.1964.", "%d.%m.%Y.") , STR_TO_DATE("28.6.2008.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10271 , 3 , "Noela" , "Horvat" , "Bojnik" , STR_TO_DATE("12.8.1951.", "%d.%m.%Y.") , STR_TO_DATE("10.6.2011.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10272 , 1 , "Leandro" , "Miletić" , "Bojnik" , STR_TO_DATE("29.3.1963.", "%d.%m.%Y.") , STR_TO_DATE("25.7.2014.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10273 , 1 , "Draženka" , "Barišić" , "Brigadir" , STR_TO_DATE("15.4.1969.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2010.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10274 , 3 , "Lora" , "Šarić" , "Skupnik" , STR_TO_DATE("12.5.1957.", "%d.%m.%Y.") , STR_TO_DATE("20.11.2005.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10275 , 4 , "Jakov" , "Bilić" , "Razvodnik" , STR_TO_DATE("25.10.1965.", "%d.%m.%Y.") , STR_TO_DATE("30.10.1996.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10276 , 1 , "Monika" , "Šimunović" , "Pukovnik" , STR_TO_DATE("26.9.1955.", "%d.%m.%Y.") , STR_TO_DATE("2.1.2005.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10277 , 3 , "Azalea" , "Tomić" , "Razvodnik" , STR_TO_DATE("3.4.1957.", "%d.%m.%Y.") , STR_TO_DATE("15.6.2018.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10278 , 1 , "Ramona" , "Novaković" , "Narednik" , STR_TO_DATE("10.4.1962.", "%d.%m.%Y.") , STR_TO_DATE("9.4.1992.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10279 , 4 , "Romina" , "Krznarić" , "Poručnik" , STR_TO_DATE("18.2.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.3.1992.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10280 , 4 , "Rubika" , "Blažević" , "Narednik" , STR_TO_DATE("8.7.1965.", "%d.%m.%Y.") , STR_TO_DATE("20.10.1998.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10281 , 1 , "Nova" , "Dujmović" , "Pozornik" , STR_TO_DATE("4.1.1950.", "%d.%m.%Y.") , STR_TO_DATE("11.4.2017.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10282 , 3 , "Darinka" , "Đurić" , "Bojnik" , STR_TO_DATE("16.8.1964.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2004.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10283 , 4 , "Nika" , "Pavlović" , "Poručnik" , STR_TO_DATE("13.7.1969.", "%d.%m.%Y.") , STR_TO_DATE("2.5.2008.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10284 , 4 , "Lada" , "Grubišić" , "Satnik" , STR_TO_DATE("24.2.1967.", "%d.%m.%Y.") , STR_TO_DATE("27.11.2018.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10285 , 4 , "Nikolina" , "Pavić" , "Pukovnik" , STR_TO_DATE("28.12.1968.", "%d.%m.%Y.") , STR_TO_DATE("5.5.2002.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10286 , 4 , "Loreta" , "Cindrić" , "Satnik" , STR_TO_DATE("3.4.1957.", "%d.%m.%Y.") , STR_TO_DATE("24.11.2020.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10287 , 2 , "Žaklina" , "Vukelić" , "Poručnik" , STR_TO_DATE("2.11.1968.", "%d.%m.%Y.") , STR_TO_DATE("4.4.1992.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10288 , 1 , "Mara" , "Filipović" , "Skupnik" , STR_TO_DATE("14.12.1953.", "%d.%m.%Y.") , STR_TO_DATE("19.8.2015.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10289 , 2 , "Hrvojka" , "Jurčević" , "Pozornik" , STR_TO_DATE("26.2.1959.", "%d.%m.%Y.") , STR_TO_DATE("21.2.2004.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10290 , 4 , "Naja" , "Antunović" , "Pozornik" , STR_TO_DATE("10.8.1961.", "%d.%m.%Y.") , STR_TO_DATE("18.6.2003.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10291 , 3 , "Delila" , "Vukelić" , "Pukovnik" , STR_TO_DATE("5.8.1968.", "%d.%m.%Y.") , STR_TO_DATE("13.6.2009.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10292 , 3 , "Eli" , "Mikulić" , "Narednik" , STR_TO_DATE("5.4.1968.", "%d.%m.%Y.") , STR_TO_DATE("22.2.2013.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10293 , 3 , "David" , "Knežević" , "Skupnik" , STR_TO_DATE("7.8.1959.", "%d.%m.%Y.") , STR_TO_DATE("6.5.2014.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10294 , 1 , "Artemisa" , "Dragičević" , "Razvodnik" , STR_TO_DATE("13.2.1960.", "%d.%m.%Y.") , STR_TO_DATE("29.3.1997.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10295 , 3 , "Ante" , "Jukić" , "Bojnik" , STR_TO_DATE("28.3.1950.", "%d.%m.%Y.") , STR_TO_DATE("8.3.2008.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10296 , 2 , "Evica" , "Mandić" , "Pukovnik" , STR_TO_DATE("15.7.1952.", "%d.%m.%Y.") , STR_TO_DATE("15.6.2015.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10297 , 2 , "Edita" , "Petković" , "Razvodnik" , STR_TO_DATE("19.3.1961.", "%d.%m.%Y.") , STR_TO_DATE("27.6.2015.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10298 , 3 , "Janko" , "Posavec" , "Razvodnik" , STR_TO_DATE("24.7.1952.", "%d.%m.%Y.") , STR_TO_DATE("3.6.1996.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10299 , 1 , "Andrija" , "Vukelić" , "Skupnik" , STR_TO_DATE("30.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("28.1.1999.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10300 , 1 , "Amaja" , "Mandić" , "Brigadir" , STR_TO_DATE("3.11.1957.", "%d.%m.%Y.") , STR_TO_DATE("20.2.2006.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10301 , 3 , "Bosiljka" , "Vučković" , "Brigadir" , STR_TO_DATE("31.12.1951.", "%d.%m.%Y.") , STR_TO_DATE("11.11.2012.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10302 , 1 , "Benjamin" , "Stanić" , "Pukovnik" , STR_TO_DATE("28.2.1964.", "%d.%m.%Y.") , STR_TO_DATE("27.6.2009.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10303 , 1 , "Gvena" , "Nikolić" , "Narednik" , STR_TO_DATE("17.11.1950.", "%d.%m.%Y.") , STR_TO_DATE("9.5.2009.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10304 , 1 , "Leana" , "Lukić" , "Pozornik" , STR_TO_DATE("3.12.1970.", "%d.%m.%Y.") , STR_TO_DATE("15.10.1994.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10305 , 1 , "Naja" , "Vidaković" , "Razvodnik" , STR_TO_DATE("19.11.1969.", "%d.%m.%Y.") , STR_TO_DATE("30.10.1992.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10306 , 3 , "Jura" , "Grgić" , "Narednik" , STR_TO_DATE("12.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("15.7.2005.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10307 , 2 , "Evelin" , "Burić" , "Brigadir" , STR_TO_DATE("7.12.1964.", "%d.%m.%Y.") , STR_TO_DATE("22.3.2008.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10308 , 3 , "Iko" , "Perković" , "Bojnik" , STR_TO_DATE("20.1.1960.", "%d.%m.%Y.") , STR_TO_DATE("18.11.2008.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10309 , 1 , "Desa" , "Jurišić" , "Pukovnik" , STR_TO_DATE("24.2.1959.", "%d.%m.%Y.") , STR_TO_DATE("9.2.1990.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10310 , 2 , "Klarisa" , "Jurišić" , "Bojnik" , STR_TO_DATE("12.2.1952.", "%d.%m.%Y.") , STR_TO_DATE("15.8.1996.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10311 , 2 , "Ben" , "Klarić" , "Narednik" , STR_TO_DATE("7.7.1965.", "%d.%m.%Y.") , STR_TO_DATE("9.7.1990.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10312 , 2 , "Tristan" , "Popović" , "Brigadir" , STR_TO_DATE("3.7.1952.", "%d.%m.%Y.") , STR_TO_DATE("18.10.2017.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10313 , 1 , "Kata" , "Mitrović" , "Satnik" , STR_TO_DATE("23.3.1959.", "%d.%m.%Y.") , STR_TO_DATE("28.10.2015.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10314 , 2 , "Lobel" , "Perković" , "Pozornik" , STR_TO_DATE("3.7.1964.", "%d.%m.%Y.") , STR_TO_DATE("18.3.1992.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10315 , 1 , "Leonid" , "Martinović" , "Razvodnik" , STR_TO_DATE("22.2.1951.", "%d.%m.%Y.") , STR_TO_DATE("25.12.2010.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10316 , 4 , "Bruna" , "Šimunović" , "Skupnik" , STR_TO_DATE("11.3.1965.", "%d.%m.%Y.") , STR_TO_DATE("29.1.1995.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10317 , 1 , "Ljerka" , "Crnković" , "Skupnik" , STR_TO_DATE("3.3.1960.", "%d.%m.%Y.") , STR_TO_DATE("15.7.2015.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10318 , 4 , "Romina" , "Vrdoljak" , "Skupnik" , STR_TO_DATE("25.8.1960.", "%d.%m.%Y.") , STR_TO_DATE("8.4.1991.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10319 , 3 , "Adela" , "Josipović" , "Razvodnik" , STR_TO_DATE("22.12.1957.", "%d.%m.%Y.") , STR_TO_DATE("22.4.2016.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10320 , 3 , "Lucijano" , "Petković" , "Satnik" , STR_TO_DATE("22.3.1967.", "%d.%m.%Y.") , STR_TO_DATE("5.7.2012.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10321 , 2 , "Kiana" , "Lučić" , "Narednik" , STR_TO_DATE("16.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("24.12.2013.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10322 , 2 , "Irena" , "Butković" , "Skupnik" , STR_TO_DATE("15.10.1962.", "%d.%m.%Y.") , STR_TO_DATE("11.4.2010.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10323 , 3 , "Martea" , "Pavlović" , "Pozornik" , STR_TO_DATE("15.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("14.9.2018.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10324 , 2 , "Dajana" , "Knežević" , "Pukovnik" , STR_TO_DATE("4.4.1952.", "%d.%m.%Y.") , STR_TO_DATE("1.5.2017.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10325 , 4 , "Lav" , "Lončar" , "Pozornik" , STR_TO_DATE("21.7.1956.", "%d.%m.%Y.") , STR_TO_DATE("20.3.2018.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10326 , 1 , "Siri" , "Kolarić" , "Pozornik" , STR_TO_DATE("1.9.1961.", "%d.%m.%Y.") , STR_TO_DATE("6.7.2020.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10327 , 4 , "Olga" , "Kolarić" , "Narednik" , STR_TO_DATE("18.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("27.6.1999.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10328 , 3 , "Denisa" , "Mikulić" , "Poručnik" , STR_TO_DATE("12.3.1961.", "%d.%m.%Y.") , STR_TO_DATE("4.2.2000.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10329 , 2 , "Lucijano" , "Vukelić" , "Narednik" , STR_TO_DATE("7.5.1967.", "%d.%m.%Y.") , STR_TO_DATE("25.12.2003.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10330 , 2 , "Rivka" , "Kovačić" , "Pozornik" , STR_TO_DATE("15.5.1966.", "%d.%m.%Y.") , STR_TO_DATE("1.12.2004.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10331 , 1 , "Madison" , "Petković" , "Razvodnik" , STR_TO_DATE("5.7.1959.", "%d.%m.%Y.") , STR_TO_DATE("13.5.2006.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10332 , 1 , "Aida" , "Bilić" , "Pozornik" , STR_TO_DATE("8.5.1961.", "%d.%m.%Y.") , STR_TO_DATE("10.8.2013.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10333 , 2 , "Julijan" , "Jurić" , "Poručnik" , STR_TO_DATE("25.9.1954.", "%d.%m.%Y.") , STR_TO_DATE("11.11.1991.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10334 , 4 , "Florenca" , "Klarić" , "Razvodnik" , STR_TO_DATE("26.4.1950.", "%d.%m.%Y.") , STR_TO_DATE("25.6.2003.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10335 , 2 , "Ada" , "Grgurić" , "Razvodnik" , STR_TO_DATE("15.12.1956.", "%d.%m.%Y.") , STR_TO_DATE("20.2.2018.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10336 , 2 , "Greta" , "Bilić" , "Poručnik" , STR_TO_DATE("14.1.1964.", "%d.%m.%Y.") , STR_TO_DATE("31.8.1991.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10337 , 3 , "Alea" , "Barišić" , "Poručnik" , STR_TO_DATE("29.10.1959.", "%d.%m.%Y.") , STR_TO_DATE("26.6.2017.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10338 , 1 , "Kina" , "Kralj" , "Skupnik" , STR_TO_DATE("2.2.1963.", "%d.%m.%Y.") , STR_TO_DATE("20.5.1992.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10339 , 1 , "Jolena" , "Novaković" , "Bojnik" , STR_TO_DATE("1.1.1957.", "%d.%m.%Y.") , STR_TO_DATE("20.1.2000.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10340 , 4 , "Margareta" , "Radić" , "Poručnik" , STR_TO_DATE("3.1.1960.", "%d.%m.%Y.") , STR_TO_DATE("22.12.2005.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10341 , 3 , "Natalija" , "Šimunović" , "Pozornik" , STR_TO_DATE("11.5.1956.", "%d.%m.%Y.") , STR_TO_DATE("23.3.1999.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10342 , 1 , "Katja" , "Grgurić" , "Narednik" , STR_TO_DATE("10.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("11.1.2008.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10343 , 3 , "Slađana" , "Kovačević" , "Razvodnik" , STR_TO_DATE("24.2.1964.", "%d.%m.%Y.") , STR_TO_DATE("1.12.1992.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10344 , 1 , "Leksi" , "Janković" , "Brigadir" , STR_TO_DATE("18.3.1962.", "%d.%m.%Y.") , STR_TO_DATE("27.12.1996.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10345 , 2 , "Pavel" , "Popović" , "Narednik" , STR_TO_DATE("16.6.1956.", "%d.%m.%Y.") , STR_TO_DATE("13.10.2016.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10346 , 2 , "Vigo" , "Božić" , "Brigadir" , STR_TO_DATE("10.4.1951.", "%d.%m.%Y.") , STR_TO_DATE("6.3.2020.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10347 , 3 , "Elanija" , "Kralj" , "Skupnik" , STR_TO_DATE("29.12.1958.", "%d.%m.%Y.") , STR_TO_DATE("18.4.2013.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10348 , 3 , "Lidija" , "Matić" , "Narednik" , STR_TO_DATE("25.12.1968.", "%d.%m.%Y.") , STR_TO_DATE("2.6.1995.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10349 , 1 , "Etna" , "Barišić" , "Poručnik" , STR_TO_DATE("12.10.1951.", "%d.%m.%Y.") , STR_TO_DATE("20.8.2007.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10350 , 1 , "Filipa" , "Pavlić" , "Pozornik" , STR_TO_DATE("6.8.1956.", "%d.%m.%Y.") , STR_TO_DATE("9.1.2017.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10351 , 4 , "Tončica" , "Dragičević" , "Brigadir" , STR_TO_DATE("21.11.1969.", "%d.%m.%Y.") , STR_TO_DATE("28.4.2010.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10352 , 1 , "Ljudevit" , "Crnković" , "Bojnik" , STR_TO_DATE("8.3.1968.", "%d.%m.%Y.") , STR_TO_DATE("28.2.1998.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10353 , 4 , "Andrija" , "Vukelić" , "Satnik" , STR_TO_DATE("26.3.1961.", "%d.%m.%Y.") , STR_TO_DATE("29.5.2011.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10354 , 4 , "Romea" , "Šimunić" , "Pozornik" , STR_TO_DATE("22.8.1954.", "%d.%m.%Y.") , STR_TO_DATE("25.4.1994.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10355 , 2 , "Slaven" , "Đurić" , "Brigadir" , STR_TO_DATE("26.10.1969.", "%d.%m.%Y.") , STR_TO_DATE("29.5.2017.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10356 , 4 , "Agata" , "Filipović" , "Skupnik" , STR_TO_DATE("11.3.1954.", "%d.%m.%Y.") , STR_TO_DATE("29.6.1991.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10357 , 4 , "Rea" , "Kralj" , "Skupnik" , STR_TO_DATE("2.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("20.1.2000.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10358 , 3 , "Daniel" , "Đurić" , "Skupnik" , STR_TO_DATE("18.2.1952.", "%d.%m.%Y.") , STR_TO_DATE("26.7.1993.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10359 , 2 , "Matej" , "Burić" , "Poručnik" , STR_TO_DATE("18.3.1954.", "%d.%m.%Y.") , STR_TO_DATE("3.12.1998.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10360 , 2 , "Željkica" , "Abramović" , "Poručnik" , STR_TO_DATE("10.2.1968.", "%d.%m.%Y.") , STR_TO_DATE("30.6.2000.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10361 , 3 , "Beata" , "Novak" , "Brigadir" , STR_TO_DATE("23.9.1957.", "%d.%m.%Y.") , STR_TO_DATE("13.6.1991.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10362 , 1 , "Elora" , "Jurković" , "Narednik" , STR_TO_DATE("18.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("24.9.1998.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10363 , 1 , "Koa" , "Matković" , "Bojnik" , STR_TO_DATE("4.1.1951.", "%d.%m.%Y.") , STR_TO_DATE("2.1.2009.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10364 , 3 , "Parka" , "Šarić" , "Bojnik" , STR_TO_DATE("23.10.1967.", "%d.%m.%Y.") , STR_TO_DATE("18.7.2016.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10365 , 3 , "Judita" , "Burić" , "Pukovnik" , STR_TO_DATE("25.4.1952.", "%d.%m.%Y.") , STR_TO_DATE("12.6.1992.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10366 , 2 , "Ofelia" , "Horvat" , "Poručnik" , STR_TO_DATE("18.3.1961.", "%d.%m.%Y.") , STR_TO_DATE("13.3.2005.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10367 , 1 , "Noel" , "Blažević" , "Skupnik" , STR_TO_DATE("28.2.1959.", "%d.%m.%Y.") , STR_TO_DATE("6.8.2002.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10368 , 3 , "Malija" , "Miletić" , "Bojnik" , STR_TO_DATE("12.8.1967.", "%d.%m.%Y.") , STR_TO_DATE("29.7.2006.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10369 , 1 , "Igor" , "Lovrić" , "Pozornik" , STR_TO_DATE("15.6.1957.", "%d.%m.%Y.") , STR_TO_DATE("13.7.2000.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10370 , 4 , "Sofija" , "Bošnjak" , "Bojnik" , STR_TO_DATE("3.6.1954.", "%d.%m.%Y.") , STR_TO_DATE("10.7.2019.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10371 , 1 , "Alesia" , "Burić" , "Brigadir" , STR_TO_DATE("20.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("26.5.2011.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10372 , 2 , "Saša" , "Antunović" , "Satnik" , STR_TO_DATE("14.11.1961.", "%d.%m.%Y.") , STR_TO_DATE("7.10.2009.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10373 , 4 , "Igor" , "Jurčević" , "Bojnik" , STR_TO_DATE("4.6.1966.", "%d.%m.%Y.") , STR_TO_DATE("10.7.2004.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10374 , 2 , "Lili" , "Golubić" , "Razvodnik" , STR_TO_DATE("15.1.1950.", "%d.%m.%Y.") , STR_TO_DATE("12.5.2002.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10375 , 2 , "Filip" , "Kovač" , "Razvodnik" , STR_TO_DATE("15.7.1959.", "%d.%m.%Y.") , STR_TO_DATE("9.7.2002.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10376 , 3 , "Cecilija" , "Babić" , "Pozornik" , STR_TO_DATE("11.8.1958.", "%d.%m.%Y.") , STR_TO_DATE("6.12.1999.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10377 , 3 , "Pavao" , "Đurić" , "Brigadir" , STR_TO_DATE("5.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("19.3.2011.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10378 , 3 , "Elizabeta" , "Babić" , "Pozornik" , STR_TO_DATE("27.4.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2009.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10379 , 3 , "Paisa" , "Klarić" , "Pukovnik" , STR_TO_DATE("24.5.1965.", "%d.%m.%Y.") , STR_TO_DATE("26.3.2004.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10380 , 3 , "Ema" , "Vučković" , "Satnik" , STR_TO_DATE("6.8.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.11.2000.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10381 , 3 , "Zoja" , "Brajković" , "Pozornik" , STR_TO_DATE("10.7.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.6.2012.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10382 , 1 , "Melkiot" , "Šarić" , "Brigadir" , STR_TO_DATE("20.1.1951.", "%d.%m.%Y.") , STR_TO_DATE("6.8.2017.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10383 , 1 , "Rina" , "Vukelić" , "Razvodnik" , STR_TO_DATE("14.12.1962.", "%d.%m.%Y.") , STR_TO_DATE("21.4.2015.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10384 , 4 , "Roberta" , "Matković" , "Poručnik" , STR_TO_DATE("3.1.1967.", "%d.%m.%Y.") , STR_TO_DATE("25.10.2000.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10385 , 2 , "Gloria" , "Šimunović" , "Bojnik" , STR_TO_DATE("20.2.1963.", "%d.%m.%Y.") , STR_TO_DATE("18.1.2001.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10386 , 4 , "Elivija" , "Mitrović" , "Skupnik" , STR_TO_DATE("8.11.1956.", "%d.%m.%Y.") , STR_TO_DATE("18.2.2011.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10387 , 2 , "Bela" , "Janković" , "Pozornik" , STR_TO_DATE("28.7.1961.", "%d.%m.%Y.") , STR_TO_DATE("12.7.2016.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10388 , 3 , "Šimun" , "Burić" , "Razvodnik" , STR_TO_DATE("1.7.1951.", "%d.%m.%Y.") , STR_TO_DATE("11.12.2014.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10389 , 3 , "Izak" , "Marković" , "Skupnik" , STR_TO_DATE("20.4.1960.", "%d.%m.%Y.") , STR_TO_DATE("18.3.2011.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10390 , 1 , "Princa" , "Vukelić" , "Bojnik" , STR_TO_DATE("31.10.1958.", "%d.%m.%Y.") , STR_TO_DATE("15.5.2010.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10391 , 1 , "Lukas" , "Vučković" , "Bojnik" , STR_TO_DATE("9.3.1969.", "%d.%m.%Y.") , STR_TO_DATE("1.4.2007.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10392 , 1 , "Stjepan" , "Barišić" , "Brigadir" , STR_TO_DATE("6.2.1954.", "%d.%m.%Y.") , STR_TO_DATE("30.6.1995.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10393 , 2 , "Valerija" , "Petrović" , "Skupnik" , STR_TO_DATE("17.7.1965.", "%d.%m.%Y.") , STR_TO_DATE("14.1.2016.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10394 , 2 , "Marcel" , "Novosel" , "Narednik" , STR_TO_DATE("6.3.1965.", "%d.%m.%Y.") , STR_TO_DATE("12.10.2000.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10395 , 4 , "Lora" , "Šimunić" , "Brigadir" , STR_TO_DATE("15.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("29.3.2009.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10396 , 2 , "Samuel" , "Posavec" , "Narednik" , STR_TO_DATE("21.5.1967.", "%d.%m.%Y.") , STR_TO_DATE("19.1.2012.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10397 , 2 , "Lea" , "Šarić" , "Pozornik" , STR_TO_DATE("26.3.1955.", "%d.%m.%Y.") , STR_TO_DATE("3.4.2005.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10398 , 3 , "Michelle" , "Lončar" , "Razvodnik" , STR_TO_DATE("26.9.1966.", "%d.%m.%Y.") , STR_TO_DATE("26.2.2019.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10399 , 1 , "Antonija" , "Kovačić" , "Skupnik" , STR_TO_DATE("18.10.1965.", "%d.%m.%Y.") , STR_TO_DATE("14.1.2000.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10400 , 2 , "Mirna" , "Vidović" , "Satnik" , STR_TO_DATE("11.5.1953.", "%d.%m.%Y.") , STR_TO_DATE("7.7.1992.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10401 , 3 , "Ivano" , "Matijević" , "Bojnik" , STR_TO_DATE("24.1.1965.", "%d.%m.%Y.") , STR_TO_DATE("23.12.2012.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10402 , 4 , "Dragutin" , "Đurđević" , "Brigadir" , STR_TO_DATE("10.6.1954.", "%d.%m.%Y.") , STR_TO_DATE("30.12.2015.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10403 , 4 , "Klementina" , "Martinović" , "Poručnik" , STR_TO_DATE("23.1.1950.", "%d.%m.%Y.") , STR_TO_DATE("5.12.2001.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10404 , 1 , "Nevena" , "Vidaković" , "Pozornik" , STR_TO_DATE("14.8.1964.", "%d.%m.%Y.") , STR_TO_DATE("6.1.2019.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10405 , 4 , "Josipa" , "Perić" , "Bojnik" , STR_TO_DATE("4.8.1957.", "%d.%m.%Y.") , STR_TO_DATE("8.2.2018.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10406 , 2 , "Lilia" , "Jurišić" , "Pukovnik" , STR_TO_DATE("22.1.1959.", "%d.%m.%Y.") , STR_TO_DATE("22.1.1993.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10407 , 1 , "Madison" , "Jakovljević" , "Narednik" , STR_TO_DATE("15.12.1965.", "%d.%m.%Y.") , STR_TO_DATE("19.6.2005.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10408 , 2 , "Valentin" , "Radić" , "Bojnik" , STR_TO_DATE("25.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("17.5.2006.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10409 , 1 , "David" , "Sever" , "Satnik" , STR_TO_DATE("18.9.1953.", "%d.%m.%Y.") , STR_TO_DATE("10.8.1998.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10410 , 1 , "Lea" , "Vrdoljak" , "Skupnik" , STR_TO_DATE("11.6.1953.", "%d.%m.%Y.") , STR_TO_DATE("29.8.1994.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10411 , 4 , "Olja" , "Novosel" , "Brigadir" , STR_TO_DATE("30.4.1956.", "%d.%m.%Y.") , STR_TO_DATE("5.9.2009.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10412 , 1 , "Zola" , "Babić" , "Bojnik" , STR_TO_DATE("27.5.1959.", "%d.%m.%Y.") , STR_TO_DATE("29.5.2014.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10413 , 1 , "Siena" , "Josipović" , "Poručnik" , STR_TO_DATE("9.8.1960.", "%d.%m.%Y.") , STR_TO_DATE("13.9.1992.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10414 , 1 , "Emil" , "Novaković" , "Bojnik" , STR_TO_DATE("28.7.1958.", "%d.%m.%Y.") , STR_TO_DATE("11.8.2003.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10415 , 3 , "Savana" , "Lončar" , "Skupnik" , STR_TO_DATE("19.5.1963.", "%d.%m.%Y.") , STR_TO_DATE("11.7.1997.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10416 , 3 , "Ramona" , "Vidaković" , "Satnik" , STR_TO_DATE("5.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("4.2.2018.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10417 , 2 , "Krista" , "Butković" , "Poručnik" , STR_TO_DATE("2.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("25.11.2008.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10418 , 4 , "Goranka" , "Blažević" , "Pozornik" , STR_TO_DATE("5.9.1953.", "%d.%m.%Y.") , STR_TO_DATE("26.1.1991.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10419 , 2 , "Krešimir" , "Đurić" , "Pukovnik" , STR_TO_DATE("12.7.1965.", "%d.%m.%Y.") , STR_TO_DATE("2.1.2003.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10420 , 1 , "Jura" , "Butković" , "Poručnik" , STR_TO_DATE("14.1.1954.", "%d.%m.%Y.") , STR_TO_DATE("3.5.2002.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10421 , 4 , "Dora" , "Grgić" , "Razvodnik" , STR_TO_DATE("1.7.1951.", "%d.%m.%Y.") , STR_TO_DATE("25.1.2008.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10422 , 2 , "Mara" , "Bošnjak" , "Narednik" , STR_TO_DATE("7.2.1953.", "%d.%m.%Y.") , STR_TO_DATE("2.8.2018.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10423 , 3 , "Rubika" , "Knežević" , "Pukovnik" , STR_TO_DATE("24.10.1961.", "%d.%m.%Y.") , STR_TO_DATE("22.12.2015.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10424 , 3 , "Dora" , "Mitrović" , "Skupnik" , STR_TO_DATE("30.3.1959.", "%d.%m.%Y.") , STR_TO_DATE("8.10.1991.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10425 , 3 , "Lora" , "Antunović" , "Brigadir" , STR_TO_DATE("12.12.1961.", "%d.%m.%Y.") , STR_TO_DATE("23.2.2003.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10426 , 3 , "Marlin" , "Pavlić" , "Skupnik" , STR_TO_DATE("15.4.1970.", "%d.%m.%Y.") , STR_TO_DATE("3.12.1998.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10427 , 3 , "Karina" , "Janković" , "Pukovnik" , STR_TO_DATE("4.9.1951.", "%d.%m.%Y.") , STR_TO_DATE("8.5.1999.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10428 , 4 , "Arav" , "Božić" , "Bojnik" , STR_TO_DATE("13.1.1954.", "%d.%m.%Y.") , STR_TO_DATE("11.12.2013.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10429 , 2 , "Mateo" , "Bilić" , "Razvodnik" , STR_TO_DATE("18.10.1958.", "%d.%m.%Y.") , STR_TO_DATE("4.3.2007.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10430 , 4 , "Aurelia" , "Blažević" , "Narednik" , STR_TO_DATE("30.4.1961.", "%d.%m.%Y.") , STR_TO_DATE("7.1.2018.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10431 , 4 , "Kendra" , "Ivanović" , "Pozornik" , STR_TO_DATE("29.8.1951.", "%d.%m.%Y.") , STR_TO_DATE("1.1.1997.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10432 , 3 , "Andrija" , "Antunović" , "Brigadir" , STR_TO_DATE("11.12.1968.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2010.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10433 , 2 , "Chaja" , "Mikulić" , "Brigadir" , STR_TO_DATE("7.11.1969.", "%d.%m.%Y.") , STR_TO_DATE("12.8.2000.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10434 , 3 , "Dunja" , "Cindrić" , "Pukovnik" , STR_TO_DATE("7.6.1952.", "%d.%m.%Y.") , STR_TO_DATE("14.3.2007.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10435 , 3 , "Dorotej" , "Ivanković" , "Skupnik" , STR_TO_DATE("6.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("23.6.2001.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10436 , 3 , "Adela" , "Ružić" , "Pukovnik" , STR_TO_DATE("15.3.1959.", "%d.%m.%Y.") , STR_TO_DATE("13.10.2003.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10437 , 2 , "Sara" , "Miletić" , "Poručnik" , STR_TO_DATE("15.5.1963.", "%d.%m.%Y.") , STR_TO_DATE("12.12.2012.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10438 , 4 , "Eta" , "Radić" , "Satnik" , STR_TO_DATE("30.11.1964.", "%d.%m.%Y.") , STR_TO_DATE("10.6.2001.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10439 , 2 , "Eli" , "Ivanović" , "Pozornik" , STR_TO_DATE("9.12.1964.", "%d.%m.%Y.") , STR_TO_DATE("2.7.1996.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10440 , 2 , "Dina" , "Vidaković" , "Pozornik" , STR_TO_DATE("26.11.1954.", "%d.%m.%Y.") , STR_TO_DATE("25.11.2000.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10441 , 4 , "Karolina" , "Jozić" , "Skupnik" , STR_TO_DATE("15.2.1957.", "%d.%m.%Y.") , STR_TO_DATE("27.3.2003.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10442 , 2 , "Patrik" , "Grgić" , "Poručnik" , STR_TO_DATE("1.2.1958.", "%d.%m.%Y.") , STR_TO_DATE("26.12.2017.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10443 , 1 , "Ljerka" , "Jurković" , "Skupnik" , STR_TO_DATE("29.7.1953.", "%d.%m.%Y.") , STR_TO_DATE("11.9.2008.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10444 , 4 , "Marcel" , "Posavec" , "Brigadir" , STR_TO_DATE("23.7.1959.", "%d.%m.%Y.") , STR_TO_DATE("18.11.1999.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10445 , 1 , "Lucija" , "Kralj" , "Bojnik" , STR_TO_DATE("23.8.1967.", "%d.%m.%Y.") , STR_TO_DATE("14.12.2010.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10446 , 1 , "Ivan" , "Šimunić" , "Bojnik" , STR_TO_DATE("3.11.1962.", "%d.%m.%Y.") , STR_TO_DATE("23.6.2001.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10447 , 2 , "Franciska" , "Nikolić" , "Pukovnik" , STR_TO_DATE("3.8.1962.", "%d.%m.%Y.") , STR_TO_DATE("19.4.1995.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10448 , 2 , "Rajna" , "Božić" , "Bojnik" , STR_TO_DATE("18.5.1963.", "%d.%m.%Y.") , STR_TO_DATE("3.9.2010.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10449 , 4 , "Mada" , "Marić" , "Bojnik" , STR_TO_DATE("17.7.1970.", "%d.%m.%Y.") , STR_TO_DATE("27.1.2005.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10450 , 2 , "Eva" , "Jovanović" , "Satnik" , STR_TO_DATE("7.9.1950.", "%d.%m.%Y.") , STR_TO_DATE("16.10.1993.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10451 , 2 , "Ela" , "Burić" , "Skupnik" , STR_TO_DATE("5.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("16.7.2000.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10452 , 1 , "Naja" , "Filipović" , "Pozornik" , STR_TO_DATE("10.12.1965.", "%d.%m.%Y.") , STR_TO_DATE("21.8.2009.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10453 , 2 , "Paisa" , "Mikulić" , "Narednik" , STR_TO_DATE("29.4.1960.", "%d.%m.%Y.") , STR_TO_DATE("20.1.2019.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10454 , 4 , "Tia" , "Rukavina" , "Narednik" , STR_TO_DATE("1.10.1952.", "%d.%m.%Y.") , STR_TO_DATE("19.6.2003.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10455 , 3 , "Toni" , "Blažević" , "Pozornik" , STR_TO_DATE("7.5.1969.", "%d.%m.%Y.") , STR_TO_DATE("30.9.2008.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10456 , 3 , "Tiana" , "Golubić" , "Pukovnik" , STR_TO_DATE("18.1.1956.", "%d.%m.%Y.") , STR_TO_DATE("9.7.2018.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10457 , 3 , "Juda" , "Ružić" , "Skupnik" , STR_TO_DATE("25.3.1963.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2014.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10458 , 2 , "Ezra" , "Rukavina" , "Bojnik" , STR_TO_DATE("3.3.1970.", "%d.%m.%Y.") , STR_TO_DATE("7.3.1992.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10459 , 4 , "Lucijano" , "Jovanović" , "Skupnik" , STR_TO_DATE("11.4.1968.", "%d.%m.%Y.") , STR_TO_DATE("21.11.2009.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10460 , 3 , "Karlo" , "Marjanović" , "Razvodnik" , STR_TO_DATE("24.10.1960.", "%d.%m.%Y.") , STR_TO_DATE("24.11.2015.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10461 , 1 , "Viktor" , "Vučković" , "Pozornik" , STR_TO_DATE("27.6.1961.", "%d.%m.%Y.") , STR_TO_DATE("24.5.1990.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10462 , 4 , "Anabela" , "Lončarić" , "Satnik" , STR_TO_DATE("16.8.1960.", "%d.%m.%Y.") , STR_TO_DATE("21.10.2011.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10463 , 3 , "Magdalena" , "Marušić" , "Pozornik" , STR_TO_DATE("15.9.1965.", "%d.%m.%Y.") , STR_TO_DATE("22.6.1995.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10464 , 1 , "Hara" , "Lovrić" , "Pukovnik" , STR_TO_DATE("11.6.1958.", "%d.%m.%Y.") , STR_TO_DATE("24.8.2015.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10465 , 4 , "Gabrijel" , "Mikulić" , "Razvodnik" , STR_TO_DATE("9.6.1951.", "%d.%m.%Y.") , STR_TO_DATE("21.11.1990.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10466 , 3 , "Moli" , "Novosel" , "Narednik" , STR_TO_DATE("4.11.1969.", "%d.%m.%Y.") , STR_TO_DATE("20.2.1991.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10467 , 3 , "Izak" , "Tomić" , "Bojnik" , STR_TO_DATE("8.8.1962.", "%d.%m.%Y.") , STR_TO_DATE("29.7.1996.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10468 , 1 , "Ćiril" , "Mitrović" , "Narednik" , STR_TO_DATE("18.7.1964.", "%d.%m.%Y.") , STR_TO_DATE("27.12.2015.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10469 , 1 , "Aden" , "Horvat" , "Narednik" , STR_TO_DATE("9.5.1958.", "%d.%m.%Y.") , STR_TO_DATE("28.3.1990.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10470 , 2 , "Briela" , "Mikulić" , "Bojnik" , STR_TO_DATE("8.3.1958.", "%d.%m.%Y.") , STR_TO_DATE("20.3.2015.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10471 , 3 , "Eliana" , "Crnković" , "Poručnik" , STR_TO_DATE("14.2.1953.", "%d.%m.%Y.") , STR_TO_DATE("4.10.1999.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10472 , 3 , "Duje" , "Marković" , "Brigadir" , STR_TO_DATE("19.11.1966.", "%d.%m.%Y.") , STR_TO_DATE("3.2.1994.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10473 , 2 , "Desa" , "Jukić" , "Pozornik" , STR_TO_DATE("5.5.1956.", "%d.%m.%Y.") , STR_TO_DATE("11.2.2015.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10474 , 4 , "Stjepan" , "Katić" , "Brigadir" , STR_TO_DATE("11.3.1954.", "%d.%m.%Y.") , STR_TO_DATE("18.12.2014.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10475 , 2 , "Hrvojka" , "Grubišić" , "Pukovnik" , STR_TO_DATE("21.8.1967.", "%d.%m.%Y.") , STR_TO_DATE("7.7.1992.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10476 , 2 , "Janko" , "Posavec" , "Razvodnik" , STR_TO_DATE("13.4.1952.", "%d.%m.%Y.") , STR_TO_DATE("12.2.2020.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10477 , 3 , "Krsto" , "Šimunović" , "Narednik" , STR_TO_DATE("13.10.1961.", "%d.%m.%Y.") , STR_TO_DATE("18.2.1992.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10478 , 1 , "Marcela" , "Kovačić" , "Razvodnik" , STR_TO_DATE("10.7.1956.", "%d.%m.%Y.") , STR_TO_DATE("24.9.1998.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10479 , 4 , "Elana" , "Herceg" , "Pozornik" , STR_TO_DATE("24.7.1956.", "%d.%m.%Y.") , STR_TO_DATE("5.2.1990.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10480 , 4 , "Jan" , "Bašić" , "Brigadir" , STR_TO_DATE("12.10.1955.", "%d.%m.%Y.") , STR_TO_DATE("27.4.1999.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10481 , 3 , "Roman" , "Ivančić" , "Skupnik" , STR_TO_DATE("13.10.1966.", "%d.%m.%Y.") , STR_TO_DATE("16.6.2014.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10482 , 2 , "Nikolina" , "Krznarić" , "Satnik" , STR_TO_DATE("12.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("26.3.2009.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10483 , 1 , "Ozren" , "Posavec" , "Poručnik" , STR_TO_DATE("21.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("23.1.2014.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10484 , 3 , "Nina" , "Jovanović" , "Poručnik" , STR_TO_DATE("28.5.1955.", "%d.%m.%Y.") , STR_TO_DATE("15.11.2008.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10485 , 2 , "Lejla" , "Lovrić" , "Brigadir" , STR_TO_DATE("22.9.1957.", "%d.%m.%Y.") , STR_TO_DATE("10.4.2018.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10486 , 4 , "Paisa" , "Martinović" , "Poručnik" , STR_TO_DATE("8.10.1964.", "%d.%m.%Y.") , STR_TO_DATE("5.6.2001.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10487 , 2 , "Slavica" , "Ivančić" , "Bojnik" , STR_TO_DATE("6.2.1963.", "%d.%m.%Y.") , STR_TO_DATE("5.3.2011.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10488 , 1 , "Matilda" , "Abramović" , "Pukovnik" , STR_TO_DATE("15.9.1959.", "%d.%m.%Y.") , STR_TO_DATE("1.9.2005.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10489 , 4 , "Mislav" , "Matić" , "Poručnik" , STR_TO_DATE("7.2.1957.", "%d.%m.%Y.") , STR_TO_DATE("16.12.2019.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10490 , 3 , "Mihael" , "Galić" , "Poručnik" , STR_TO_DATE("19.12.1955.", "%d.%m.%Y.") , STR_TO_DATE("20.12.2017.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10491 , 4 , "Julijana" , "Perić" , "Razvodnik" , STR_TO_DATE("8.5.1960.", "%d.%m.%Y.") , STR_TO_DATE("23.1.1995.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10492 , 3 , "Ilijana" , "Petrović" , "Pukovnik" , STR_TO_DATE("27.6.1961.", "%d.%m.%Y.") , STR_TO_DATE("8.4.2015.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10493 , 2 , "Olga" , "Petković" , "Brigadir" , STR_TO_DATE("2.6.1951.", "%d.%m.%Y.") , STR_TO_DATE("1.6.2004.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10494 , 2 , "Evona" , "Burić" , "Skupnik" , STR_TO_DATE("9.4.1959.", "%d.%m.%Y.") , STR_TO_DATE("17.3.1994.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10495 , 2 , "Estela" , "Posavec" , "Pozornik" , STR_TO_DATE("22.6.1959.", "%d.%m.%Y.") , STR_TO_DATE("29.9.1992.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10496 , 1 , "Rea" , "Golubić" , "Narednik" , STR_TO_DATE("29.4.1955.", "%d.%m.%Y.") , STR_TO_DATE("21.7.1990.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10497 , 3 , "Olga" , "Blažević" , "Brigadir" , STR_TO_DATE("28.6.1959.", "%d.%m.%Y.") , STR_TO_DATE("11.7.1991.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10498 , 1 , "Kila" , "Pavlić" , "Pukovnik" , STR_TO_DATE("27.11.1959.", "%d.%m.%Y.") , STR_TO_DATE("16.8.2011.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10499 , 2 , "Bruno" , "Mitrović" , "Pozornik" , STR_TO_DATE("15.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("21.8.2011.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10500 , 3 , "Edita" , "Jurčević" , "Brigadir" , STR_TO_DATE("3.11.1953.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2011.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10501 , 4 , "Anatea" , "Josipović" , "Bojnik" , STR_TO_DATE("17.12.1966.", "%d.%m.%Y.") , STR_TO_DATE("31.5.1991.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10502 , 4 , "Branimir" , "Lovrić" , "Poručnik" , STR_TO_DATE("10.11.1959.", "%d.%m.%Y.") , STR_TO_DATE("5.4.2001.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10503 , 3 , "Denis" , "Marušić" , "Narednik" , STR_TO_DATE("16.11.1965.", "%d.%m.%Y.") , STR_TO_DATE("5.11.2014.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10504 , 2 , "Neda" , "Grubišić" , "Brigadir" , STR_TO_DATE("27.11.1965.", "%d.%m.%Y.") , STR_TO_DATE("5.2.2004.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10505 , 3 , "Melani" , "Josipović" , "Pukovnik" , STR_TO_DATE("20.1.1960.", "%d.%m.%Y.") , STR_TO_DATE("30.5.2013.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10506 , 1 , "Boris" , "Matijević" , "Satnik" , STR_TO_DATE("12.7.1963.", "%d.%m.%Y.") , STR_TO_DATE("6.11.2008.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10507 , 4 , "Stefanija" , "Dragičević" , "Poručnik" , STR_TO_DATE("14.10.1952.", "%d.%m.%Y.") , STR_TO_DATE("22.11.2012.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10508 , 3 , "Eva" , "Galić" , "Razvodnik" , STR_TO_DATE("27.10.1966.", "%d.%m.%Y.") , STR_TO_DATE("27.9.2020.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10509 , 3 , "Hara" , "Jozić" , "Skupnik" , STR_TO_DATE("2.11.1967.", "%d.%m.%Y.") , STR_TO_DATE("11.2.1994.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10510 , 1 , "Kristina" , "Jurčević" , "Satnik" , STR_TO_DATE("18.9.1951.", "%d.%m.%Y.") , STR_TO_DATE("24.6.2010.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10511 , 2 , "Gabrijel" , "Lončarić" , "Bojnik" , STR_TO_DATE("5.12.1958.", "%d.%m.%Y.") , STR_TO_DATE("14.4.2002.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10512 , 4 , "Donat" , "Horvat" , "Skupnik" , STR_TO_DATE("8.4.1952.", "%d.%m.%Y.") , STR_TO_DATE("21.4.2013.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10513 , 1 , "Talia" , "Antunović" , "Pukovnik" , STR_TO_DATE("14.1.1965.", "%d.%m.%Y.") , STR_TO_DATE("25.6.1993.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10514 , 2 , "Dante" , "Ćosić" , "Satnik" , STR_TO_DATE("23.11.1954.", "%d.%m.%Y.") , STR_TO_DATE("19.12.2005.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10515 , 1 , "Lorena" , "Jurišić" , "Poručnik" , STR_TO_DATE("6.4.1965.", "%d.%m.%Y.") , STR_TO_DATE("21.3.2001.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10516 , 2 , "Siera" , "Babić" , "Satnik" , STR_TO_DATE("13.10.1960.", "%d.%m.%Y.") , STR_TO_DATE("31.5.1992.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10517 , 4 , "Ivan" , "Kovačević" , "Poručnik" , STR_TO_DATE("17.2.1965.", "%d.%m.%Y.") , STR_TO_DATE("5.8.1990.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10518 , 3 , "Dejan" , "Filipović" , "Satnik" , STR_TO_DATE("13.5.1961.", "%d.%m.%Y.") , STR_TO_DATE("28.9.1999.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10519 , 1 , "Karina" , "Burić" , "Poručnik" , STR_TO_DATE("25.3.1958.", "%d.%m.%Y.") , STR_TO_DATE("12.9.2012.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10520 , 2 , "Adriana" , "Babić" , "Brigadir" , STR_TO_DATE("27.12.1962.", "%d.%m.%Y.") , STR_TO_DATE("21.9.1996.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10521 , 2 , "Ermina" , "Bošnjak" , "Bojnik" , STR_TO_DATE("25.3.1963.", "%d.%m.%Y.") , STR_TO_DATE("10.8.2003.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10522 , 4 , "Maris" , "Brajković" , "Narednik" , STR_TO_DATE("12.10.1958.", "%d.%m.%Y.") , STR_TO_DATE("12.2.2005.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10523 , 2 , "Aleksandra" , "Horvat" , "Pozornik" , STR_TO_DATE("8.3.1968.", "%d.%m.%Y.") , STR_TO_DATE("22.3.2000.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10524 , 3 , "Aurora" , "Vuković" , "Brigadir" , STR_TO_DATE("9.2.1969.", "%d.%m.%Y.") , STR_TO_DATE("13.9.2007.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10525 , 4 , "Filip" , "Abramović" , "Pozornik" , STR_TO_DATE("28.6.1966.", "%d.%m.%Y.") , STR_TO_DATE("11.12.2007.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10526 , 1 , "Žak" , "Kovačić" , "Pozornik" , STR_TO_DATE("27.5.1958.", "%d.%m.%Y.") , STR_TO_DATE("20.12.2019.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10527 , 2 , "Khalesi" , "Nikolić" , "Brigadir" , STR_TO_DATE("16.2.1957.", "%d.%m.%Y.") , STR_TO_DATE("3.12.1995.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10528 , 4 , "Maksima" , "Jurić" , "Satnik" , STR_TO_DATE("1.2.1959.", "%d.%m.%Y.") , STR_TO_DATE("21.7.2019.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10529 , 3 , "Lobel" , "Marić" , "Pukovnik" , STR_TO_DATE("22.9.1965.", "%d.%m.%Y.") , STR_TO_DATE("17.11.2002.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10530 , 1 , "Maksima" , "Dujmović" , "Poručnik" , STR_TO_DATE("7.1.1956.", "%d.%m.%Y.") , STR_TO_DATE("16.12.2020.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10531 , 3 , "Maksim" , "Martinović" , "Razvodnik" , STR_TO_DATE("14.10.1956.", "%d.%m.%Y.") , STR_TO_DATE("1.5.2012.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10532 , 2 , "Adonis" , "Novak" , "Poručnik" , STR_TO_DATE("22.4.1964.", "%d.%m.%Y.") , STR_TO_DATE("29.4.1999.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10533 , 3 , "Esmeralda" , "Vidović" , "Pozornik" , STR_TO_DATE("3.10.1960.", "%d.%m.%Y.") , STR_TO_DATE("8.6.2012.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10534 , 3 , "Zakarija" , "Jurić" , "Satnik" , STR_TO_DATE("25.6.1965.", "%d.%m.%Y.") , STR_TO_DATE("28.9.2000.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10535 , 1 , "Lika" , "Petković" , "Skupnik" , STR_TO_DATE("3.1.1955.", "%d.%m.%Y.") , STR_TO_DATE("6.10.2000.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10536 , 3 , "Zarija" , "Lovrić" , "Poručnik" , STR_TO_DATE("30.11.1962.", "%d.%m.%Y.") , STR_TO_DATE("7.11.1991.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10537 , 4 , "Valentina" , "Tomić" , "Razvodnik" , STR_TO_DATE("4.3.1954.", "%d.%m.%Y.") , STR_TO_DATE("18.12.2005.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10538 , 3 , "Dmitar" , "Vidović" , "Poručnik" , STR_TO_DATE("30.11.1962.", "%d.%m.%Y.") , STR_TO_DATE("14.4.2006.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10539 , 4 , "Roman" , "Martinović" , "Bojnik" , STR_TO_DATE("7.6.1970.", "%d.%m.%Y.") , STR_TO_DATE("16.5.2006.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10540 , 1 , "Aleksa" , "Pavić" , "Pozornik" , STR_TO_DATE("28.6.1958.", "%d.%m.%Y.") , STR_TO_DATE("15.7.1996.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10541 , 4 , "Severina" , "Šimunić" , "Pozornik" , STR_TO_DATE("7.9.1960.", "%d.%m.%Y.") , STR_TO_DATE("18.2.1997.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10542 , 2 , "Aziel" , "Šarić" , "Brigadir" , STR_TO_DATE("14.12.1970.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2007.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10543 , 4 , "Marisol" , "Popović" , "Razvodnik" , STR_TO_DATE("16.9.1950.", "%d.%m.%Y.") , STR_TO_DATE("5.2.2015.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10544 , 1 , "Aria" , "Katić" , "Razvodnik" , STR_TO_DATE("26.6.1956.", "%d.%m.%Y.") , STR_TO_DATE("18.7.2000.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10545 , 4 , "Zoe" , "Šarić" , "Skupnik" , STR_TO_DATE("28.9.1968.", "%d.%m.%Y.") , STR_TO_DATE("14.9.1995.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10546 , 2 , "Sandi" , "Blažević" , "Bojnik" , STR_TO_DATE("21.3.1950.", "%d.%m.%Y.") , STR_TO_DATE("9.6.1999.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10547 , 4 , "Magda" , "Bošnjak" , "Satnik" , STR_TO_DATE("10.11.1951.", "%d.%m.%Y.") , STR_TO_DATE("23.1.2008.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10548 , 1 , "Šime" , "Bošnjak" , "Poručnik" , STR_TO_DATE("14.12.1959.", "%d.%m.%Y.") , STR_TO_DATE("17.3.1997.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10549 , 1 , "Rajna" , "Šimić" , "Pukovnik" , STR_TO_DATE("21.7.1962.", "%d.%m.%Y.") , STR_TO_DATE("23.7.1997.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10550 , 1 , "Marina" , "Matijević" , "Narednik" , STR_TO_DATE("29.10.1951.", "%d.%m.%Y.") , STR_TO_DATE("30.1.2003.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10551 , 4 , "Ognjen" , "Šimunović" , "Pukovnik" , STR_TO_DATE("30.3.1960.", "%d.%m.%Y.") , STR_TO_DATE("6.5.1990.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10552 , 2 , "Adelina" , "Pavić" , "Razvodnik" , STR_TO_DATE("12.11.1957.", "%d.%m.%Y.") , STR_TO_DATE("8.3.2000.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10553 , 2 , "Franka" , "Marić" , "Skupnik" , STR_TO_DATE("15.3.1969.", "%d.%m.%Y.") , STR_TO_DATE("10.10.2000.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10554 , 3 , "Jakov" , "Vuković" , "Razvodnik" , STR_TO_DATE("18.11.1964.", "%d.%m.%Y.") , STR_TO_DATE("4.7.2016.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10555 , 1 , "Kila" , "Posavec" , "Narednik" , STR_TO_DATE("26.2.1960.", "%d.%m.%Y.") , STR_TO_DATE("24.1.2013.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10556 , 4 , "Budimir" , "Mitrović" , "Narednik" , STR_TO_DATE("10.10.1969.", "%d.%m.%Y.") , STR_TO_DATE("1.3.2018.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10557 , 3 , "Mariam" , "Jurčević" , "Pozornik" , STR_TO_DATE("9.2.1950.", "%d.%m.%Y.") , STR_TO_DATE("29.4.2013.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10558 , 3 , "Iko" , "Burić" , "Skupnik" , STR_TO_DATE("16.11.1952.", "%d.%m.%Y.") , STR_TO_DATE("5.9.2012.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10559 , 2 , "Eme" , "Jelić" , "Pukovnik" , STR_TO_DATE("29.9.1961.", "%d.%m.%Y.") , STR_TO_DATE("11.3.2008.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10560 , 2 , "Šime" , "Babić" , "Poručnik" , STR_TO_DATE("21.6.1962.", "%d.%m.%Y.") , STR_TO_DATE("25.12.2012.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10561 , 2 , "Paisa" , "Ivanović" , "Bojnik" , STR_TO_DATE("21.9.1962.", "%d.%m.%Y.") , STR_TO_DATE("28.12.2012.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10562 , 1 , "Adrian" , "Filipović" , "Razvodnik" , STR_TO_DATE("31.7.1969.", "%d.%m.%Y.") , STR_TO_DATE("20.1.2018.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10563 , 2 , "Mikaela" , "Posavec" , "Bojnik" , STR_TO_DATE("28.7.1961.", "%d.%m.%Y.") , STR_TO_DATE("1.10.1995.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10564 , 1 , "Violeta" , "Klarić" , "Skupnik" , STR_TO_DATE("24.12.1969.", "%d.%m.%Y.") , STR_TO_DATE("6.10.2005.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10565 , 2 , "Vincent" , "Jurić" , "Razvodnik" , STR_TO_DATE("18.6.1961.", "%d.%m.%Y.") , STR_TO_DATE("26.3.2019.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10566 , 2 , "Natan" , "Petrović" , "Poručnik" , STR_TO_DATE("20.2.1951.", "%d.%m.%Y.") , STR_TO_DATE("6.10.2018.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10567 , 1 , "Kamari" , "Bašić" , "Pukovnik" , STR_TO_DATE("21.11.1965.", "%d.%m.%Y.") , STR_TO_DATE("23.5.2011.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10568 , 2 , "Milena" , "Golubić" , "Satnik" , STR_TO_DATE("26.9.1966.", "%d.%m.%Y.") , STR_TO_DATE("31.1.2004.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10569 , 3 , "Franciska" , "Perković" , "Razvodnik" , STR_TO_DATE("4.10.1954.", "%d.%m.%Y.") , STR_TO_DATE("24.3.2008.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10570 , 3 , "Viktoria" , "Šimunić" , "Pozornik" , STR_TO_DATE("17.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("26.4.2011.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10571 , 2 , "Valentino" , "Jakovljević" , "Bojnik" , STR_TO_DATE("13.1.1959.", "%d.%m.%Y.") , STR_TO_DATE("27.11.2014.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10572 , 3 , "Pavao" , "Lončar" , "Skupnik" , STR_TO_DATE("20.4.1970.", "%d.%m.%Y.") , STR_TO_DATE("28.11.1998.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10573 , 4 , "Ferdinand" , "Popović" , "Bojnik" , STR_TO_DATE("31.3.1966.", "%d.%m.%Y.") , STR_TO_DATE("21.8.2019.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10574 , 4 , "Princa" , "Lučić" , "Skupnik" , STR_TO_DATE("30.11.1956.", "%d.%m.%Y.") , STR_TO_DATE("16.7.2009.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10575 , 4 , "Bonie" , "Vuković" , "Poručnik" , STR_TO_DATE("16.6.1958.", "%d.%m.%Y.") , STR_TO_DATE("26.7.2001.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10576 , 2 , "Paisa" , "Brkić" , "Bojnik" , STR_TO_DATE("13.2.1950.", "%d.%m.%Y.") , STR_TO_DATE("2.6.2016.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10577 , 2 , "Borisa" , "Golubić" , "Pukovnik" , STR_TO_DATE("27.11.1960.", "%d.%m.%Y.") , STR_TO_DATE("29.5.1995.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10578 , 3 , "Samira" , "Jurčević" , "Pozornik" , STR_TO_DATE("28.3.1957.", "%d.%m.%Y.") , STR_TO_DATE("2.4.1992.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10579 , 3 , "Krista" , "Jakovljević" , "Pukovnik" , STR_TO_DATE("17.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("16.1.1991.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10580 , 1 , "Fiona" , "Živković" , "Satnik" , STR_TO_DATE("5.2.1958.", "%d.%m.%Y.") , STR_TO_DATE("25.12.1997.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10581 , 3 , "Ita" , "Perić" , "Razvodnik" , STR_TO_DATE("20.2.1953.", "%d.%m.%Y.") , STR_TO_DATE("21.3.2007.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10582 , 1 , "Janko" , "Novaković" , "Pukovnik" , STR_TO_DATE("4.7.1957.", "%d.%m.%Y.") , STR_TO_DATE("28.2.1995.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10583 , 4 , "Tomislav" , "Dragičević" , "Narednik" , STR_TO_DATE("17.12.1964.", "%d.%m.%Y.") , STR_TO_DATE("10.3.1992.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10584 , 3 , "Princa" , "Varga" , "Bojnik" , STR_TO_DATE("5.9.1970.", "%d.%m.%Y.") , STR_TO_DATE("26.3.1997.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10585 , 2 , "Denisa" , "Nikolić" , "Brigadir" , STR_TO_DATE("12.1.1958.", "%d.%m.%Y.") , STR_TO_DATE("19.3.2002.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10586 , 3 , "Kain" , "Pavić" , "Brigadir" , STR_TO_DATE("20.3.1963.", "%d.%m.%Y.") , STR_TO_DATE("2.2.2016.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10587 , 3 , "Ivo" , "Bašić" , "Narednik" , STR_TO_DATE("7.10.1950.", "%d.%m.%Y.") , STR_TO_DATE("29.3.2003.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10588 , 2 , "Dora" , "Bilić" , "Pozornik" , STR_TO_DATE("19.12.1963.", "%d.%m.%Y.") , STR_TO_DATE("7.11.2005.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10589 , 3 , "Petra" , "Lučić" , "Narednik" , STR_TO_DATE("6.6.1957.", "%d.%m.%Y.") , STR_TO_DATE("26.8.2010.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10590 , 4 , "Eli" , "Burić" , "Razvodnik" , STR_TO_DATE("26.9.1952.", "%d.%m.%Y.") , STR_TO_DATE("18.11.2011.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10591 , 2 , "Martin" , "Ivanković" , "Pukovnik" , STR_TO_DATE("30.3.1959.", "%d.%m.%Y.") , STR_TO_DATE("1.12.2001.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10592 , 2 , "Klo" , "Brajković" , "Razvodnik" , STR_TO_DATE("29.7.1959.", "%d.%m.%Y.") , STR_TO_DATE("8.11.1994.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10593 , 4 , "Benjamin" , "Crnković" , "Narednik" , STR_TO_DATE("21.9.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.8.2007.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10594 , 3 , "Leonardo" , "Matković" , "Brigadir" , STR_TO_DATE("2.7.1957.", "%d.%m.%Y.") , STR_TO_DATE("23.3.1995.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10595 , 3 , "Rita" , "Posavec" , "Brigadir" , STR_TO_DATE("30.9.1967.", "%d.%m.%Y.") , STR_TO_DATE("16.5.2018.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10596 , 1 , "Krešimir" , "Babić" , "Skupnik" , STR_TO_DATE("2.6.1957.", "%d.%m.%Y.") , STR_TO_DATE("30.3.2003.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10597 , 4 , "Franka" , "Šimić" , "Skupnik" , STR_TO_DATE("2.6.1962.", "%d.%m.%Y.") , STR_TO_DATE("31.5.1994.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10598 , 2 , "Tihana" , "Jozić" , "Pukovnik" , STR_TO_DATE("26.6.1968.", "%d.%m.%Y.") , STR_TO_DATE("18.1.1990.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10599 , 3 , "Nadia" , "Miletić" , "Narednik" , STR_TO_DATE("15.2.1965.", "%d.%m.%Y.") , STR_TO_DATE("23.9.2016.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10600 , 1 , "Vita" , "Filipović" , "Bojnik" , STR_TO_DATE("7.6.1964.", "%d.%m.%Y.") , STR_TO_DATE("18.12.1999.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10601 , 4 , "Ada" , "Dragičević" , "Razvodnik" , STR_TO_DATE("26.1.1950.", "%d.%m.%Y.") , STR_TO_DATE("15.2.2006.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10602 , 2 , "Korina" , "Mitrović" , "Razvodnik" , STR_TO_DATE("8.7.1955.", "%d.%m.%Y.") , STR_TO_DATE("21.11.2014.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10603 , 1 , "Marjan" , "Pavlović" , "Satnik" , STR_TO_DATE("25.5.1956.", "%d.%m.%Y.") , STR_TO_DATE("27.7.2016.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10604 , 1 , "Leandro" , "Šimunović" , "Bojnik" , STR_TO_DATE("1.6.1970.", "%d.%m.%Y.") , STR_TO_DATE("16.12.1997.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10605 , 3 , "Tiago" , "Đurđević" , "Poručnik" , STR_TO_DATE("26.10.1953.", "%d.%m.%Y.") , STR_TO_DATE("25.2.1999.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10606 , 1 , "Khalesi" , "Sever" , "Bojnik" , STR_TO_DATE("4.1.1958.", "%d.%m.%Y.") , STR_TO_DATE("17.2.1996.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10607 , 3 , "Miroslava" , "Jurčević" , "Skupnik" , STR_TO_DATE("12.7.1968.", "%d.%m.%Y.") , STR_TO_DATE("3.2.2004.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10608 , 3 , "Aleksandra" , "Grubišić" , "Razvodnik" , STR_TO_DATE("24.5.1964.", "%d.%m.%Y.") , STR_TO_DATE("11.7.2011.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10609 , 1 , "Dani" , "Dujmović" , "Narednik" , STR_TO_DATE("5.4.1951.", "%d.%m.%Y.") , STR_TO_DATE("4.8.2008.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10610 , 3 , "Elana" , "Tomić" , "Razvodnik" , STR_TO_DATE("13.1.1950.", "%d.%m.%Y.") , STR_TO_DATE("6.11.2018.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10611 , 1 , "Nia" , "Ivanović" , "Pukovnik" , STR_TO_DATE("9.7.1967.", "%d.%m.%Y.") , STR_TO_DATE("1.10.2013.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10612 , 4 , "Marcela" , "Šimunović" , "Narednik" , STR_TO_DATE("10.7.1958.", "%d.%m.%Y.") , STR_TO_DATE("1.9.1992.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10613 , 1 , "Aron" , "Vidaković" , "Satnik" , STR_TO_DATE("10.6.1960.", "%d.%m.%Y.") , STR_TO_DATE("11.11.2012.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10614 , 1 , "Simon" , "Martinović" , "Bojnik" , STR_TO_DATE("5.3.1963.", "%d.%m.%Y.") , STR_TO_DATE("14.3.2013.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10615 , 4 , "Rina" , "Mandić" , "Razvodnik" , STR_TO_DATE("4.10.1961.", "%d.%m.%Y.") , STR_TO_DATE("20.4.2012.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10616 , 2 , "Ivo" , "Miletić" , "Narednik" , STR_TO_DATE("26.9.1963.", "%d.%m.%Y.") , STR_TO_DATE("12.6.2004.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10617 , 2 , "Iris" , "Marjanović" , "Satnik" , STR_TO_DATE("13.3.1967.", "%d.%m.%Y.") , STR_TO_DATE("15.1.2003.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10618 , 2 , "Goga" , "Perković" , "Satnik" , STR_TO_DATE("28.1.1968.", "%d.%m.%Y.") , STR_TO_DATE("23.3.2006.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10619 , 4 , "Lilia" , "Živković" , "Narednik" , STR_TO_DATE("24.12.1963.", "%d.%m.%Y.") , STR_TO_DATE("24.5.2001.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10620 , 4 , "Ada" , "Grgić" , "Poručnik" , STR_TO_DATE("29.12.1956.", "%d.%m.%Y.") , STR_TO_DATE("18.2.1992.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10621 , 3 , "Augustin" , "Barišić" , "Narednik" , STR_TO_DATE("22.4.1959.", "%d.%m.%Y.") , STR_TO_DATE("30.9.2005.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10622 , 3 , "Mariam" , "Kovač" , "Pukovnik" , STR_TO_DATE("28.5.1963.", "%d.%m.%Y.") , STR_TO_DATE("20.3.2006.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10623 , 3 , "Sandi" , "Šimunović" , "Bojnik" , STR_TO_DATE("21.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("15.1.1995.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10624 , 3 , "Elena" , "Filipović" , "Pukovnik" , STR_TO_DATE("18.5.1964.", "%d.%m.%Y.") , STR_TO_DATE("19.2.2020.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10625 , 3 , "Aria" , "Šimunić" , "Razvodnik" , STR_TO_DATE("30.3.1950.", "%d.%m.%Y.") , STR_TO_DATE("11.10.2014.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10626 , 1 , "Boris" , "Josipović" , "Bojnik" , STR_TO_DATE("19.11.1950.", "%d.%m.%Y.") , STR_TO_DATE("5.6.2005.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10627 , 1 , "Moreno" , "Vučković" , "Pukovnik" , STR_TO_DATE("25.9.1968.", "%d.%m.%Y.") , STR_TO_DATE("22.4.2005.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10628 , 4 , "Remi" , "Marić" , "Brigadir" , STR_TO_DATE("2.9.1965.", "%d.%m.%Y.") , STR_TO_DATE("31.8.1994.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10629 , 3 , "Marlin" , "Marić" , "Poručnik" , STR_TO_DATE("5.8.1965.", "%d.%m.%Y.") , STR_TO_DATE("22.10.2019.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10630 , 2 , "Nova" , "Mitrović" , "Razvodnik" , STR_TO_DATE("8.10.1970.", "%d.%m.%Y.") , STR_TO_DATE("24.6.2011.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10631 , 1 , "Sendi" , "Đurić" , "Narednik" , STR_TO_DATE("11.3.1953.", "%d.%m.%Y.") , STR_TO_DATE("26.11.2009.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10632 , 4 , "Zakarija" , "Brkić" , "Narednik" , STR_TO_DATE("28.2.1970.", "%d.%m.%Y.") , STR_TO_DATE("2.7.2014.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10633 , 1 , "Martea" , "Stanić" , "Narednik" , STR_TO_DATE("4.9.1952.", "%d.%m.%Y.") , STR_TO_DATE("13.7.2009.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10634 , 3 , "Kira" , "Petrović" , "Razvodnik" , STR_TO_DATE("4.3.1956.", "%d.%m.%Y.") , STR_TO_DATE("9.11.2015.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10635 , 2 , "Liv" , "Blažević" , "Brigadir" , STR_TO_DATE("25.6.1963.", "%d.%m.%Y.") , STR_TO_DATE("31.1.2003.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10636 , 1 , "Amaris" , "Ćosić" , "Razvodnik" , STR_TO_DATE("12.6.1953.", "%d.%m.%Y.") , STR_TO_DATE("16.10.2000.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10637 , 1 , "Edita" , "Klarić" , "Narednik" , STR_TO_DATE("23.1.1964.", "%d.%m.%Y.") , STR_TO_DATE("6.3.2015.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10638 , 1 , "Slavica" , "Matijević" , "Narednik" , STR_TO_DATE("3.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("22.3.2018.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10639 , 2 , "Elaina" , "Matić" , "Razvodnik" , STR_TO_DATE("2.6.1963.", "%d.%m.%Y.") , STR_TO_DATE("11.10.1999.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10640 , 2 , "Rebeka" , "Marković" , "Brigadir" , STR_TO_DATE("16.6.1964.", "%d.%m.%Y.") , STR_TO_DATE("29.8.2016.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10641 , 4 , "Leona" , "Novak" , "Pukovnik" , STR_TO_DATE("3.8.1964.", "%d.%m.%Y.") , STR_TO_DATE("12.11.1995.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10642 , 1 , "Dajana" , "Novaković" , "Pukovnik" , STR_TO_DATE("18.2.1969.", "%d.%m.%Y.") , STR_TO_DATE("8.3.2009.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10643 , 3 , "Goran" , "Jelić" , "Skupnik" , STR_TO_DATE("27.2.1968.", "%d.%m.%Y.") , STR_TO_DATE("2.7.2008.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10644 , 2 , "Kali" , "Horvat" , "Skupnik" , STR_TO_DATE("27.2.1966.", "%d.%m.%Y.") , STR_TO_DATE("27.9.2000.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10645 , 2 , "Lea" , "Lončarić" , "Pukovnik" , STR_TO_DATE("21.1.1970.", "%d.%m.%Y.") , STR_TO_DATE("2.4.2012.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10646 , 2 , "Madelin" , "Babić" , "Skupnik" , STR_TO_DATE("24.9.1959.", "%d.%m.%Y.") , STR_TO_DATE("25.5.1990.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10647 , 4 , "Marcel" , "Dragičević" , "Pukovnik" , STR_TO_DATE("4.11.1956.", "%d.%m.%Y.") , STR_TO_DATE("12.5.2003.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10648 , 1 , "Kai" , "Antunović" , "Poručnik" , STR_TO_DATE("21.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("30.4.2013.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10649 , 4 , "Samira" , "Janković" , "Satnik" , STR_TO_DATE("16.6.1960.", "%d.%m.%Y.") , STR_TO_DATE("10.7.1999.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10650 , 1 , "Brigita" , "Lovrić" , "Pukovnik" , STR_TO_DATE("16.4.1955.", "%d.%m.%Y.") , STR_TO_DATE("10.5.1994.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10651 , 2 , "Elena" , "Brkić" , "Pozornik" , STR_TO_DATE("27.3.1960.", "%d.%m.%Y.") , STR_TO_DATE("18.4.2014.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10652 , 2 , "Lilika" , "Kovač" , "Brigadir" , STR_TO_DATE("13.8.1954.", "%d.%m.%Y.") , STR_TO_DATE("22.11.2006.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10653 , 1 , "Gustav" , "Perić" , "Narednik" , STR_TO_DATE("24.2.1950.", "%d.%m.%Y.") , STR_TO_DATE("9.8.1990.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10654 , 2 , "Vanesa" , "Jozić" , "Pozornik" , STR_TO_DATE("15.11.1959.", "%d.%m.%Y.") , STR_TO_DATE("8.12.2010.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10655 , 4 , "Mariam" , "Cindrić" , "Satnik" , STR_TO_DATE("28.9.1959.", "%d.%m.%Y.") , STR_TO_DATE("1.5.2005.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10656 , 2 , "Jakov" , "Vuković" , "Brigadir" , STR_TO_DATE("17.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("23.2.2000.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10657 , 1 , "Hai" , "Horvat" , "Pozornik" , STR_TO_DATE("17.12.1951.", "%d.%m.%Y.") , STR_TO_DATE("1.3.2002.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10658 , 4 , "Anamarija" , "Jurčević" , "Narednik" , STR_TO_DATE("31.3.1962.", "%d.%m.%Y.") , STR_TO_DATE("13.5.1995.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10659 , 1 , "Gisela" , "Perić" , "Brigadir" , STR_TO_DATE("25.10.1969.", "%d.%m.%Y.") , STR_TO_DATE("5.10.2019.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10660 , 3 , "Toni" , "Popović" , "Poručnik" , STR_TO_DATE("12.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("16.1.2019.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10661 , 2 , "Sebastijan" , "Brkić" , "Narednik" , STR_TO_DATE("20.8.1960.", "%d.%m.%Y.") , STR_TO_DATE("10.10.2005.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10662 , 3 , "Maris" , "Krznarić" , "Poručnik" , STR_TO_DATE("16.8.1961.", "%d.%m.%Y.") , STR_TO_DATE("14.3.1991.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10663 , 1 , "Franciska" , "Nikolić" , "Satnik" , STR_TO_DATE("20.4.1961.", "%d.%m.%Y.") , STR_TO_DATE("28.1.2019.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10664 , 4 , "Rajna" , "Matić" , "Pukovnik" , STR_TO_DATE("22.10.1950.", "%d.%m.%Y.") , STR_TO_DATE("10.10.1994.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10665 , 3 , "Evica" , "Vidaković" , "Skupnik" , STR_TO_DATE("9.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("1.12.2004.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10666 , 1 , "Elena" , "Kovačević" , "Pozornik" , STR_TO_DATE("24.8.1953.", "%d.%m.%Y.") , STR_TO_DATE("29.9.1991.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10667 , 3 , "Dajana" , "Krznarić" , "Poručnik" , STR_TO_DATE("13.9.1957.", "%d.%m.%Y.") , STR_TO_DATE("22.9.2002.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10668 , 1 , "Oliver" , "Jurić" , "Razvodnik" , STR_TO_DATE("30.11.1959.", "%d.%m.%Y.") , STR_TO_DATE("9.10.1993.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10669 , 1 , "Leo" , "Posavec" , "Pukovnik" , STR_TO_DATE("17.2.1956.", "%d.%m.%Y.") , STR_TO_DATE("16.5.1990.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10670 , 1 , "Stela" , "Sever" , "Pukovnik" , STR_TO_DATE("25.7.1966.", "%d.%m.%Y.") , STR_TO_DATE("9.2.1995.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10671 , 3 , "Lenon" , "Pavlović" , "Brigadir" , STR_TO_DATE("21.11.1954.", "%d.%m.%Y.") , STR_TO_DATE("7.4.1998.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10672 , 4 , "Dana" , "Radić" , "Satnik" , STR_TO_DATE("30.4.1955.", "%d.%m.%Y.") , STR_TO_DATE("9.9.2004.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10673 , 4 , "Rea" , "Jurišić" , "Bojnik" , STR_TO_DATE("30.6.1952.", "%d.%m.%Y.") , STR_TO_DATE("23.6.1996.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10674 , 1 , "Dajana" , "Vrdoljak" , "Skupnik" , STR_TO_DATE("16.8.1967.", "%d.%m.%Y.") , STR_TO_DATE("8.2.2001.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10675 , 3 , "Mauro" , "Rukavina" , "Poručnik" , STR_TO_DATE("26.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("29.10.2014.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10676 , 4 , "Isla" , "Grgurić" , "Bojnik" , STR_TO_DATE("8.8.1962.", "%d.%m.%Y.") , STR_TO_DATE("22.6.2011.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10677 , 1 , "Dario" , "Lončarić" , "Skupnik" , STR_TO_DATE("9.12.1951.", "%d.%m.%Y.") , STR_TO_DATE("7.5.1996.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10678 , 1 , "Rosalia" , "Radić" , "Pukovnik" , STR_TO_DATE("20.6.1965.", "%d.%m.%Y.") , STR_TO_DATE("1.1.2002.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10679 , 3 , "Branimir" , "Babić" , "Pukovnik" , STR_TO_DATE("16.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("29.3.2011.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10680 , 2 , "Dalia" , "Burić" , "Razvodnik" , STR_TO_DATE("14.12.1963.", "%d.%m.%Y.") , STR_TO_DATE("29.4.2012.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10681 , 4 , "Lilika" , "Kolarić" , "Pozornik" , STR_TO_DATE("5.10.1967.", "%d.%m.%Y.") , STR_TO_DATE("14.3.2007.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10682 , 4 , "Elivija" , "Ružić" , "Pukovnik" , STR_TO_DATE("17.12.1959.", "%d.%m.%Y.") , STR_TO_DATE("11.8.2004.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10683 , 2 , "Viktor" , "Crnković" , "Razvodnik" , STR_TO_DATE("10.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("18.12.2002.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10684 , 1 , "Niko" , "Ivanković" , "Skupnik" , STR_TO_DATE("20.12.1970.", "%d.%m.%Y.") , STR_TO_DATE("18.11.2002.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10685 , 4 , "Natalija" , "Antunović" , "Narednik" , STR_TO_DATE("11.7.1967.", "%d.%m.%Y.") , STR_TO_DATE("10.11.1995.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10686 , 3 , "Ben" , "Perković" , "Satnik" , STR_TO_DATE("13.11.1958.", "%d.%m.%Y.") , STR_TO_DATE("11.5.1995.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10687 , 3 , "Melkiot" , "Pavlić" , "Pozornik" , STR_TO_DATE("28.11.1959.", "%d.%m.%Y.") , STR_TO_DATE("8.9.2000.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10688 , 2 , "Vito" , "Jukić" , "Pukovnik" , STR_TO_DATE("11.10.1960.", "%d.%m.%Y.") , STR_TO_DATE("9.10.2001.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10689 , 2 , "Katarina" , "Lončar" , "Poručnik" , STR_TO_DATE("15.12.1969.", "%d.%m.%Y.") , STR_TO_DATE("31.3.1996.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10690 , 1 , "Viktor" , "Ivančić" , "Brigadir" , STR_TO_DATE("7.5.1966.", "%d.%m.%Y.") , STR_TO_DATE("22.9.1998.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10691 , 1 , "Rebeka" , "Radić" , "Poručnik" , STR_TO_DATE("8.10.1960.", "%d.%m.%Y.") , STR_TO_DATE("25.1.2002.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10692 , 2 , "Bruno" , "Petrović" , "Narednik" , STR_TO_DATE("28.11.1951.", "%d.%m.%Y.") , STR_TO_DATE("25.3.2013.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10693 , 4 , "Nia" , "Stanić" , "Narednik" , STR_TO_DATE("14.3.1950.", "%d.%m.%Y.") , STR_TO_DATE("6.2.2000.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10694 , 2 , "Nives" , "Perković" , "Pukovnik" , STR_TO_DATE("24.10.1968.", "%d.%m.%Y.") , STR_TO_DATE("9.12.2020.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10695 , 2 , "Dani" , "Marković" , "Poručnik" , STR_TO_DATE("12.7.1965.", "%d.%m.%Y.") , STR_TO_DATE("21.11.2000.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10696 , 4 , "Marisol" , "Šimić" , "Razvodnik" , STR_TO_DATE("2.2.1959.", "%d.%m.%Y.") , STR_TO_DATE("12.10.2011.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10697 , 2 , "Estela" , "Vidović" , "Pozornik" , STR_TO_DATE("22.3.1968.", "%d.%m.%Y.") , STR_TO_DATE("25.4.2017.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10698 , 3 , "Mateo" , "Marjanović" , "Razvodnik" , STR_TO_DATE("18.6.1968.", "%d.%m.%Y.") , STR_TO_DATE("26.4.2012.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10699 , 3 , "Zelda" , "Sever" , "Brigadir" , STR_TO_DATE("21.7.1970.", "%d.%m.%Y.") , STR_TO_DATE("12.4.2002.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10700 , 1 , "Juna" , "Josipović" , "Brigadir" , STR_TO_DATE("18.8.1953.", "%d.%m.%Y.") , STR_TO_DATE("18.6.1993.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10701 , 2 , "Teodor" , "Pavlić" , "Poručnik" , STR_TO_DATE("18.6.1950.", "%d.%m.%Y.") , STR_TO_DATE("8.2.2004.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10702 , 4 , "Kalisa" , "Jurčević" , "Poručnik" , STR_TO_DATE("27.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("7.1.2007.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10703 , 1 , "Leona" , "Krznarić" , "Brigadir" , STR_TO_DATE("16.4.1959.", "%d.%m.%Y.") , STR_TO_DATE("5.11.2003.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10704 , 1 , "Ena" , "Kovač" , "Razvodnik" , STR_TO_DATE("8.7.1968.", "%d.%m.%Y.") , STR_TO_DATE("5.8.2011.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10705 , 2 , "Matej" , "Vidović" , "Poručnik" , STR_TO_DATE("23.5.1950.", "%d.%m.%Y.") , STR_TO_DATE("15.9.2000.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10706 , 2 , "Arijana" , "Tomić" , "Pukovnik" , STR_TO_DATE("3.2.1958.", "%d.%m.%Y.") , STR_TO_DATE("22.2.2007.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10707 , 3 , "Nikol" , "Jurišić" , "Pozornik" , STR_TO_DATE("7.11.1954.", "%d.%m.%Y.") , STR_TO_DATE("30.6.1992.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10708 , 3 , "Krista" , "Jurišić" , "Pukovnik" , STR_TO_DATE("31.3.1963.", "%d.%m.%Y.") , STR_TO_DATE("16.3.2011.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10709 , 2 , "Rosalia" , "Rukavina" , "Satnik" , STR_TO_DATE("3.6.1951.", "%d.%m.%Y.") , STR_TO_DATE("30.7.1993.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10710 , 2 , "Lenon" , "Ivanović" , "Bojnik" , STR_TO_DATE("25.12.1956.", "%d.%m.%Y.") , STR_TO_DATE("24.6.2011.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10711 , 1 , "Natalija" , "Vidović" , "Razvodnik" , STR_TO_DATE("5.4.1967.", "%d.%m.%Y.") , STR_TO_DATE("7.7.2000.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10712 , 3 , "Željkica" , "Filipović" , "Poručnik" , STR_TO_DATE("3.12.1963.", "%d.%m.%Y.") , STR_TO_DATE("25.11.2019.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10713 , 4 , "Maca" , "Jozić" , "Pukovnik" , STR_TO_DATE("1.11.1957.", "%d.%m.%Y.") , STR_TO_DATE("4.1.2013.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10714 , 4 , "Moli" , "Kralj" , "Satnik" , STR_TO_DATE("11.6.1951.", "%d.%m.%Y.") , STR_TO_DATE("2.6.1993.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10715 , 3 , "Melanija" , "Šimić" , "Poručnik" , STR_TO_DATE("3.3.1951.", "%d.%m.%Y.") , STR_TO_DATE("26.10.1992.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10716 , 2 , "Milena" , "Pavić" , "Razvodnik" , STR_TO_DATE("3.1.1951.", "%d.%m.%Y.") , STR_TO_DATE("9.9.1994.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10717 , 3 , "Bria" , "Herceg" , "Razvodnik" , STR_TO_DATE("5.4.1957.", "%d.%m.%Y.") , STR_TO_DATE("31.5.2001.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10718 , 4 , "Elie" , "Petrović" , "Narednik" , STR_TO_DATE("16.10.1961.", "%d.%m.%Y.") , STR_TO_DATE("3.10.2009.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10719 , 4 , "Kruna" , "Marušić" , "Bojnik" , STR_TO_DATE("24.12.1950.", "%d.%m.%Y.") , STR_TO_DATE("26.4.2014.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10720 , 3 , "Gaj" , "Horvat" , "Poručnik" , STR_TO_DATE("22.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("28.11.2012.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10721 , 1 , "Nira" , "Jurković" , "Pozornik" , STR_TO_DATE("9.4.1969.", "%d.%m.%Y.") , STR_TO_DATE("21.8.2006.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10722 , 4 , "Harmina" , "Jurišić" , "Pukovnik" , STR_TO_DATE("17.11.1969.", "%d.%m.%Y.") , STR_TO_DATE("1.9.2002.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10723 , 4 , "Rila" , "Jurčević" , "Narednik" , STR_TO_DATE("5.3.1961.", "%d.%m.%Y.") , STR_TO_DATE("3.5.1995.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10724 , 1 , "Alma" , "Bašić" , "Satnik" , STR_TO_DATE("8.8.1967.", "%d.%m.%Y.") , STR_TO_DATE("10.11.1997.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10725 , 4 , "Marina" , "Mikulić" , "Poručnik" , STR_TO_DATE("30.4.1959.", "%d.%m.%Y.") , STR_TO_DATE("4.1.2012.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10726 , 1 , "Beatrica" , "Ružić" , "Narednik" , STR_TO_DATE("10.8.1960.", "%d.%m.%Y.") , STR_TO_DATE("1.6.2004.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10727 , 1 , "Rhea" , "Lovrić" , "Skupnik" , STR_TO_DATE("8.8.1950.", "%d.%m.%Y.") , STR_TO_DATE("14.8.2013.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10728 , 3 , "Kristian" , "Jurčević" , "Pukovnik" , STR_TO_DATE("16.12.1962.", "%d.%m.%Y.") , STR_TO_DATE("2.12.1997.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10729 , 1 , "Santino" , "Tomić" , "Skupnik" , STR_TO_DATE("4.3.1951.", "%d.%m.%Y.") , STR_TO_DATE("25.5.1999.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10730 , 3 , "Laura" , "Butković" , "Razvodnik" , STR_TO_DATE("30.9.1960.", "%d.%m.%Y.") , STR_TO_DATE("4.6.1992.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10731 , 1 , "Roman" , "Ivanović" , "Razvodnik" , STR_TO_DATE("2.6.1966.", "%d.%m.%Y.") , STR_TO_DATE("21.12.1990.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10732 , 4 , "Fabijan" , "Pavić" , "Skupnik" , STR_TO_DATE("16.10.1954.", "%d.%m.%Y.") , STR_TO_DATE("15.8.2018.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10733 , 3 , "Belen" , "Herceg" , "Skupnik" , STR_TO_DATE("31.12.1958.", "%d.%m.%Y.") , STR_TO_DATE("11.1.2008.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10734 , 2 , "Makena" , "Radić" , "Poručnik" , STR_TO_DATE("7.4.1953.", "%d.%m.%Y.") , STR_TO_DATE("22.3.2009.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10735 , 3 , "Kina" , "Pavlić" , "Brigadir" , STR_TO_DATE("8.12.1961.", "%d.%m.%Y.") , STR_TO_DATE("2.10.2016.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10736 , 1 , "Oto" , "Novak" , "Bojnik" , STR_TO_DATE("26.2.1950.", "%d.%m.%Y.") , STR_TO_DATE("13.6.1998.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10737 , 4 , "Izaija" , "Grubišić" , "Pukovnik" , STR_TO_DATE("24.7.1966.", "%d.%m.%Y.") , STR_TO_DATE("16.2.1990.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10738 , 4 , "Ofelia" , "Vučković" , "Satnik" , STR_TO_DATE("21.3.1956.", "%d.%m.%Y.") , STR_TO_DATE("19.7.2019.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10739 , 3 , "Vanja" , "Nikolić" , "Skupnik" , STR_TO_DATE("2.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("2.8.1996.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10740 , 2 , "Luela" , "Herceg" , "Razvodnik" , STR_TO_DATE("21.10.1969.", "%d.%m.%Y.") , STR_TO_DATE("22.7.2015.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10741 , 1 , "Estela" , "Kolarić" , "Pozornik" , STR_TO_DATE("6.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("3.4.2000.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10742 , 4 , "Mela" , "Šimić" , "Pozornik" , STR_TO_DATE("4.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("27.9.2002.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10743 , 2 , "Filipa" , "Ćosić" , "Razvodnik" , STR_TO_DATE("30.1.1969.", "%d.%m.%Y.") , STR_TO_DATE("7.4.2015.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10744 , 2 , "Roman" , "Barišić" , "Brigadir" , STR_TO_DATE("18.11.1952.", "%d.%m.%Y.") , STR_TO_DATE("22.3.2017.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10745 , 3 , "Rhea" , "Mitrović" , "Bojnik" , STR_TO_DATE("21.2.1965.", "%d.%m.%Y.") , STR_TO_DATE("23.4.2019.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10746 , 3 , "Korina" , "Jelić" , "Razvodnik" , STR_TO_DATE("16.11.1967.", "%d.%m.%Y.") , STR_TO_DATE("5.8.1992.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10747 , 1 , "Damir" , "Matković" , "Poručnik" , STR_TO_DATE("3.3.1968.", "%d.%m.%Y.") , STR_TO_DATE("21.9.2010.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10748 , 2 , "Nova" , "Sever" , "Poručnik" , STR_TO_DATE("9.12.1967.", "%d.%m.%Y.") , STR_TO_DATE("8.8.1999.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10749 , 1 , "Evanđelika" , "Cindrić" , "Pukovnik" , STR_TO_DATE("10.2.1968.", "%d.%m.%Y.") , STR_TO_DATE("9.2.2013.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10750 , 1 , "Anemari" , "Grgurić" , "Pukovnik" , STR_TO_DATE("1.5.1966.", "%d.%m.%Y.") , STR_TO_DATE("28.5.2010.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10751 , 2 , "Bartola" , "Pavić" , "Pozornik" , STR_TO_DATE("28.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("11.5.2002.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10752 , 1 , "Pavel" , "Jovanović" , "Pozornik" , STR_TO_DATE("2.9.1959.", "%d.%m.%Y.") , STR_TO_DATE("6.9.2011.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10753 , 1 , "Evina" , "Nikolić" , "Pukovnik" , STR_TO_DATE("4.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("15.4.2016.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10754 , 2 , "Lea" , "Novak" , "Narednik" , STR_TO_DATE("30.4.1967.", "%d.%m.%Y.") , STR_TO_DATE("11.12.1995.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10755 , 4 , "Lina" , "Nikolić" , "Pukovnik" , STR_TO_DATE("25.1.1963.", "%d.%m.%Y.") , STR_TO_DATE("23.2.2020.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10756 , 1 , "Matea" , "Novak" , "Bojnik" , STR_TO_DATE("15.2.1964.", "%d.%m.%Y.") , STR_TO_DATE("22.11.2008.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10757 , 4 , "Tara" , "Rukavina" , "Poručnik" , STR_TO_DATE("6.6.1964.", "%d.%m.%Y.") , STR_TO_DATE("11.12.2020.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10758 , 3 , "Davina" , "Đurđević" , "Poručnik" , STR_TO_DATE("10.1.1954.", "%d.%m.%Y.") , STR_TO_DATE("10.7.2002.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10759 , 1 , "Jolena" , "Lončarić" , "Skupnik" , STR_TO_DATE("25.3.1957.", "%d.%m.%Y.") , STR_TO_DATE("22.1.2004.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10760 , 2 , "Vincent" , "Petković" , "Pukovnik" , STR_TO_DATE("3.8.1962.", "%d.%m.%Y.") , STR_TO_DATE("6.3.1997.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10761 , 3 , "Evica" , "Jovanović" , "Bojnik" , STR_TO_DATE("27.7.1950.", "%d.%m.%Y.") , STR_TO_DATE("20.7.2002.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10762 , 2 , "Emili" , "Vuković" , "Pukovnik" , STR_TO_DATE("7.7.1959.", "%d.%m.%Y.") , STR_TO_DATE("19.1.1997.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10763 , 2 , "Marisol" , "Pavić" , "Satnik" , STR_TO_DATE("20.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("18.1.2017.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10764 , 1 , "Natalija" , "Horvat" , "Brigadir" , STR_TO_DATE("9.1.1962.", "%d.%m.%Y.") , STR_TO_DATE("3.3.2006.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10765 , 3 , "Maca" , "Miletić" , "Skupnik" , STR_TO_DATE("26.5.1957.", "%d.%m.%Y.") , STR_TO_DATE("13.10.2005.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10766 , 1 , "Alana" , "Brkić" , "Brigadir" , STR_TO_DATE("24.4.1969.", "%d.%m.%Y.") , STR_TO_DATE("15.11.2019.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10767 , 3 , "Salema" , "Grgić" , "Skupnik" , STR_TO_DATE("25.9.1958.", "%d.%m.%Y.") , STR_TO_DATE("3.6.2008.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10768 , 3 , "Bruno" , "Jurišić" , "Satnik" , STR_TO_DATE("10.5.1955.", "%d.%m.%Y.") , STR_TO_DATE("9.8.2009.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10769 , 4 , "Dorotej" , "Varga" , "Pozornik" , STR_TO_DATE("11.3.1958.", "%d.%m.%Y.") , STR_TO_DATE("31.10.1996.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10770 , 4 , "Saša" , "Varga" , "Bojnik" , STR_TO_DATE("3.12.1958.", "%d.%m.%Y.") , STR_TO_DATE("24.6.2005.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10771 , 2 , "Viena" , "Ćosić" , "Pozornik" , STR_TO_DATE("14.12.1970.", "%d.%m.%Y.") , STR_TO_DATE("17.10.2017.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10772 , 4 , "Izaija" , "Jurković" , "Pukovnik" , STR_TO_DATE("4.1.1958.", "%d.%m.%Y.") , STR_TO_DATE("26.6.1992.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10773 , 4 , "Ivor" , "Vuković" , "Bojnik" , STR_TO_DATE("5.10.1964.", "%d.%m.%Y.") , STR_TO_DATE("17.6.1994.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10774 , 1 , "Beta" , "Šimunić" , "Brigadir" , STR_TO_DATE("13.4.1950.", "%d.%m.%Y.") , STR_TO_DATE("9.6.1990.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10775 , 3 , "Moli" , "Posavec" , "Pukovnik" , STR_TO_DATE("12.11.1961.", "%d.%m.%Y.") , STR_TO_DATE("9.4.1990.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10776 , 3 , "Adam" , "Popović" , "Narednik" , STR_TO_DATE("4.6.1964.", "%d.%m.%Y.") , STR_TO_DATE("24.9.2003.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10777 , 1 , "Gema" , "Ivanović" , "Pozornik" , STR_TO_DATE("16.12.1963.", "%d.%m.%Y.") , STR_TO_DATE("29.12.2014.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10778 , 1 , "Goran" , "Vrdoljak" , "Bojnik" , STR_TO_DATE("16.5.1959.", "%d.%m.%Y.") , STR_TO_DATE("14.6.2008.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10779 , 2 , "Mila" , "Dragičević" , "Satnik" , STR_TO_DATE("15.11.1954.", "%d.%m.%Y.") , STR_TO_DATE("20.9.2011.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10780 , 4 , "Alesia" , "Šimunović" , "Pozornik" , STR_TO_DATE("1.5.1965.", "%d.%m.%Y.") , STR_TO_DATE("11.3.2009.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10781 , 3 , "Julijan" , "Dujmović" , "Skupnik" , STR_TO_DATE("11.4.1956.", "%d.%m.%Y.") , STR_TO_DATE("24.4.2003.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10782 , 2 , "Miroslava" , "Šimunić" , "Narednik" , STR_TO_DATE("22.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("5.9.2007.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10783 , 2 , "Hada" , "Novak" , "Narednik" , STR_TO_DATE("9.9.1950.", "%d.%m.%Y.") , STR_TO_DATE("23.9.2005.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10784 , 3 , "Ćiril" , "Vučković" , "Brigadir" , STR_TO_DATE("1.12.1951.", "%d.%m.%Y.") , STR_TO_DATE("23.4.1998.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10785 , 1 , "Mihaela" , "Sever" , "Pozornik" , STR_TO_DATE("10.11.1950.", "%d.%m.%Y.") , STR_TO_DATE("5.4.2006.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10786 , 2 , "Lucija" , "Tomić" , "Pukovnik" , STR_TO_DATE("5.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("30.7.2008.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10787 , 1 , "Mauro" , "Abramović" , "Brigadir" , STR_TO_DATE("8.4.1970.", "%d.%m.%Y.") , STR_TO_DATE("20.10.2019.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10788 , 4 , "Leksi" , "Grgić" , "Pozornik" , STR_TO_DATE("12.11.1968.", "%d.%m.%Y.") , STR_TO_DATE("6.8.2011.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10789 , 4 , "Dragica" , "Jovanović" , "Satnik" , STR_TO_DATE("23.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("30.4.2000.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10790 , 3 , "Frida" , "Katić" , "Poručnik" , STR_TO_DATE("13.5.1950.", "%d.%m.%Y.") , STR_TO_DATE("30.9.1993.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10791 , 2 , "Paisa" , "Ivanković" , "Poručnik" , STR_TO_DATE("25.3.1953.", "%d.%m.%Y.") , STR_TO_DATE("2.7.1994.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10792 , 1 , "Božidar" , "Novosel" , "Razvodnik" , STR_TO_DATE("28.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("16.12.2011.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10793 , 1 , "Franjo" , "Antunović" , "Pukovnik" , STR_TO_DATE("10.9.1965.", "%d.%m.%Y.") , STR_TO_DATE("10.8.1993.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10794 , 3 , "Florijan" , "Filipović" , "Skupnik" , STR_TO_DATE("10.12.1963.", "%d.%m.%Y.") , STR_TO_DATE("26.8.1999.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10795 , 2 , "Siri" , "Jakovljević" , "Pozornik" , STR_TO_DATE("12.7.1958.", "%d.%m.%Y.") , STR_TO_DATE("18.6.2006.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10796 , 1 , "Eva" , "Novaković" , "Pozornik" , STR_TO_DATE("25.7.1970.", "%d.%m.%Y.") , STR_TO_DATE("19.5.2008.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10797 , 2 , "Serena" , "Tomić" , "Brigadir" , STR_TO_DATE("18.12.1956.", "%d.%m.%Y.") , STR_TO_DATE("9.11.2016.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10798 , 2 , "Adam" , "Jakovljević" , "Poručnik" , STR_TO_DATE("11.4.1966.", "%d.%m.%Y.") , STR_TO_DATE("10.2.2012.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10799 , 2 , "Jerko" , "Matković" , "Pozornik" , STR_TO_DATE("29.10.1954.", "%d.%m.%Y.") , STR_TO_DATE("5.5.1992.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10800 , 3 , "Zaria" , "Šarić" , "Narednik" , STR_TO_DATE("1.3.1954.", "%d.%m.%Y.") , STR_TO_DATE("4.11.2015.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10801 , 2 , "Renata" , "Jurišić" , "Poručnik" , STR_TO_DATE("12.4.1961.", "%d.%m.%Y.") , STR_TO_DATE("9.12.2017.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10802 , 2 , "Neo" , "Popović" , "Pukovnik" , STR_TO_DATE("17.12.1952.", "%d.%m.%Y.") , STR_TO_DATE("25.10.1995.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10803 , 4 , "Amira" , "Mikulić" , "Poručnik" , STR_TO_DATE("11.8.1967.", "%d.%m.%Y.") , STR_TO_DATE("12.6.2005.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10804 , 1 , "Jordan" , "Šarić" , "Brigadir" , STR_TO_DATE("16.1.1954.", "%d.%m.%Y.") , STR_TO_DATE("10.12.2020.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10805 , 1 , "Vera" , "Šimunović" , "Brigadir" , STR_TO_DATE("2.1.1953.", "%d.%m.%Y.") , STR_TO_DATE("29.12.2019.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10806 , 4 , "Emil" , "Matijević" , "Poručnik" , STR_TO_DATE("13.8.1959.", "%d.%m.%Y.") , STR_TO_DATE("6.4.1995.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10807 , 1 , "Lea" , "Marjanović" , "Pozornik" , STR_TO_DATE("20.9.1964.", "%d.%m.%Y.") , STR_TO_DATE("3.7.1999.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10808 , 2 , "Samanta" , "Jakovljević" , "Narednik" , STR_TO_DATE("16.3.1966.", "%d.%m.%Y.") , STR_TO_DATE("26.12.2011.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10809 , 3 , "Anđeo" , "Pavlić" , "Razvodnik" , STR_TO_DATE("28.2.1967.", "%d.%m.%Y.") , STR_TO_DATE("11.5.1996.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10810 , 1 , "Gloria" , "Radić" , "Satnik" , STR_TO_DATE("28.2.1961.", "%d.%m.%Y.") , STR_TO_DATE("2.6.1991.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10811 , 4 , "Renato" , "Butković" , "Poručnik" , STR_TO_DATE("25.6.1964.", "%d.%m.%Y.") , STR_TO_DATE("15.1.1991.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10812 , 1 , "Jara" , "Ćosić" , "Pozornik" , STR_TO_DATE("2.5.1970.", "%d.%m.%Y.") , STR_TO_DATE("27.8.2019.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10813 , 1 , "Antonio" , "Đurić" , "Bojnik" , STR_TO_DATE("14.7.1952.", "%d.%m.%Y.") , STR_TO_DATE("10.4.1997.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10814 , 1 , "Dorian" , "Bašić" , "Narednik" , STR_TO_DATE("5.5.1953.", "%d.%m.%Y.") , STR_TO_DATE("5.12.2004.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10815 , 3 , "Moreno" , "Antunović" , "Poručnik" , STR_TO_DATE("20.6.1950.", "%d.%m.%Y.") , STR_TO_DATE("14.2.2000.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10816 , 1 , "Brigita" , "Crnković" , "Pozornik" , STR_TO_DATE("29.3.1966.", "%d.%m.%Y.") , STR_TO_DATE("12.11.2013.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10817 , 3 , "Aliza" , "Šimunović" , "Razvodnik" , STR_TO_DATE("14.9.1955.", "%d.%m.%Y.") , STR_TO_DATE("11.9.2010.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10818 , 2 , "Milica" , "Živković" , "Satnik" , STR_TO_DATE("15.9.1955.", "%d.%m.%Y.") , STR_TO_DATE("14.2.2016.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10819 , 2 , "Zoja" , "Bilić" , "Skupnik" , STR_TO_DATE("26.12.1962.", "%d.%m.%Y.") , STR_TO_DATE("28.2.1993.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10820 , 3 , "Tatjana" , "Krznarić" , "Skupnik" , STR_TO_DATE("10.4.1967.", "%d.%m.%Y.") , STR_TO_DATE("8.3.2020.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10821 , 4 , "Siri" , "Božić" , "Bojnik" , STR_TO_DATE("22.6.1955.", "%d.%m.%Y.") , STR_TO_DATE("29.4.2013.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10822 , 2 , "Lina" , "Kralj" , "Skupnik" , STR_TO_DATE("16.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("24.3.1990.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10823 , 4 , "Noela" , "Bašić" , "Pozornik" , STR_TO_DATE("16.6.1970.", "%d.%m.%Y.") , STR_TO_DATE("17.6.1991.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10824 , 4 , "Lorena" , "Matković" , "Bojnik" , STR_TO_DATE("13.8.1969.", "%d.%m.%Y.") , STR_TO_DATE("16.4.2011.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10825 , 2 , "Severino" , "Pavlović" , "Bojnik" , STR_TO_DATE("10.1.1963.", "%d.%m.%Y.") , STR_TO_DATE("24.7.2001.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10826 , 1 , "Magnolija" , "Burić" , "Pukovnik" , STR_TO_DATE("16.7.1969.", "%d.%m.%Y.") , STR_TO_DATE("26.1.2017.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10827 , 3 , "Moli" , "Novosel" , "Pozornik" , STR_TO_DATE("20.9.1961.", "%d.%m.%Y.") , STR_TO_DATE("4.8.1995.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10828 , 3 , "Viktor" , "Mitrović" , "Poručnik" , STR_TO_DATE("29.4.1968.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2003.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10829 , 3 , "Nora" , "Pavlić" , "Brigadir" , STR_TO_DATE("26.6.1966.", "%d.%m.%Y.") , STR_TO_DATE("30.10.2019.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10830 , 1 , "Lucija" , "Šimunić" , "Brigadir" , STR_TO_DATE("22.5.1956.", "%d.%m.%Y.") , STR_TO_DATE("20.10.2008.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10831 , 2 , "Nadia" , "Marušić" , "Pukovnik" , STR_TO_DATE("30.6.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2003.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10832 , 4 , "Lora" , "Vuković" , "Pozornik" , STR_TO_DATE("4.5.1962.", "%d.%m.%Y.") , STR_TO_DATE("6.6.1996.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10833 , 1 , "Evina" , "Petković" , "Razvodnik" , STR_TO_DATE("25.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("6.2.1992.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10834 , 1 , "Nikola" , "Vidaković" , "Narednik" , STR_TO_DATE("17.11.1968.", "%d.%m.%Y.") , STR_TO_DATE("8.1.1993.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10835 , 2 , "Marta" , "Miletić" , "Narednik" , STR_TO_DATE("2.10.1960.", "%d.%m.%Y.") , STR_TO_DATE("25.3.2014.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10836 , 4 , "Lika" , "Dragičević" , "Narednik" , STR_TO_DATE("2.5.1954.", "%d.%m.%Y.") , STR_TO_DATE("24.3.2007.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10837 , 3 , "Zoe" , "Mikulić" , "Narednik" , STR_TO_DATE("22.6.1965.", "%d.%m.%Y.") , STR_TO_DATE("7.4.2002.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10838 , 4 , "Simona" , "Barišić" , "Pozornik" , STR_TO_DATE("28.2.1970.", "%d.%m.%Y.") , STR_TO_DATE("25.2.2003.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10839 , 1 , "Tim" , "Perić" , "Brigadir" , STR_TO_DATE("22.9.1954.", "%d.%m.%Y.") , STR_TO_DATE("10.8.2015.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10840 , 3 , "Teo" , "Vrdoljak" , "Satnik" , STR_TO_DATE("4.7.1967.", "%d.%m.%Y.") , STR_TO_DATE("4.1.2006.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10841 , 4 , "Ariel" , "Barišić" , "Satnik" , STR_TO_DATE("28.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("9.8.2000.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10842 , 3 , "Alen" , "Tomić" , "Narednik" , STR_TO_DATE("23.7.1970.", "%d.%m.%Y.") , STR_TO_DATE("10.6.2019.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10843 , 3 , "Nira" , "Đurđević" , "Bojnik" , STR_TO_DATE("4.12.1967.", "%d.%m.%Y.") , STR_TO_DATE("6.10.2019.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10844 , 2 , "Kate" , "Petrović" , "Poručnik" , STR_TO_DATE("22.9.1951.", "%d.%m.%Y.") , STR_TO_DATE("28.7.1990.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10845 , 4 , "Galilea" , "Marić" , "Brigadir" , STR_TO_DATE("13.9.1966.", "%d.%m.%Y.") , STR_TO_DATE("11.4.2008.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10846 , 1 , "Kiana" , "Lončar" , "Pozornik" , STR_TO_DATE("24.11.1964.", "%d.%m.%Y.") , STR_TO_DATE("15.2.2020.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10847 , 4 , "Aida" , "Radić" , "Narednik" , STR_TO_DATE("15.3.1963.", "%d.%m.%Y.") , STR_TO_DATE("17.11.2001.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10848 , 1 , "Adelina" , "Matijević" , "Razvodnik" , STR_TO_DATE("16.4.1953.", "%d.%m.%Y.") , STR_TO_DATE("28.5.2008.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10849 , 3 , "Elaina" , "Novosel" , "Pozornik" , STR_TO_DATE("20.2.1954.", "%d.%m.%Y.") , STR_TO_DATE("21.6.2008.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10850 , 3 , "Korina" , "Burić" , "Poručnik" , STR_TO_DATE("29.1.1956.", "%d.%m.%Y.") , STR_TO_DATE("16.1.2003.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10851 , 4 , "Velina" , "Marjanović" , "Poručnik" , STR_TO_DATE("10.5.1959.", "%d.%m.%Y.") , STR_TO_DATE("29.11.2010.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10852 , 2 , "Marija" , "Miletić" , "Bojnik" , STR_TO_DATE("10.6.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.2.1993.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10853 , 1 , "Karmen" , "Mandić" , "Poručnik" , STR_TO_DATE("1.5.1969.", "%d.%m.%Y.") , STR_TO_DATE("11.10.1993.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10854 , 1 , "Artemisa" , "Brajković" , "Pukovnik" , STR_TO_DATE("5.2.1967.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2000.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10855 , 2 , "Kamila" , "Kralj" , "Satnik" , STR_TO_DATE("2.7.1963.", "%d.%m.%Y.") , STR_TO_DATE("24.2.2001.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10856 , 4 , "Goran" , "Krznarić" , "Brigadir" , STR_TO_DATE("26.7.1951.", "%d.%m.%Y.") , STR_TO_DATE("14.7.2013.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10857 , 4 , "Slaven" , "Matković" , "Skupnik" , STR_TO_DATE("10.9.1963.", "%d.%m.%Y.") , STR_TO_DATE("24.9.2008.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10858 , 3 , "Hada" , "Kralj" , "Brigadir" , STR_TO_DATE("30.12.1957.", "%d.%m.%Y.") , STR_TO_DATE("8.8.2002.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10859 , 2 , "Nikol" , "Kralj" , "Skupnik" , STR_TO_DATE("26.2.1956.", "%d.%m.%Y.") , STR_TO_DATE("4.7.2001.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10860 , 1 , "Kenia" , "Dujmović" , "Skupnik" , STR_TO_DATE("17.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("2.6.1997.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10861 , 4 , "Fran" , "Perković" , "Poručnik" , STR_TO_DATE("10.1.1969.", "%d.%m.%Y.") , STR_TO_DATE("3.5.2010.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10862 , 2 , "Lovorka" , "Perić" , "Poručnik" , STR_TO_DATE("1.12.1968.", "%d.%m.%Y.") , STR_TO_DATE("1.7.2013.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10863 , 3 , "Vito" , "Knežević" , "Narednik" , STR_TO_DATE("28.5.1968.", "%d.%m.%Y.") , STR_TO_DATE("4.2.2014.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10864 , 2 , "Fernand" , "Lukić" , "Poručnik" , STR_TO_DATE("16.8.1955.", "%d.%m.%Y.") , STR_TO_DATE("11.5.2002.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10865 , 4 , "Breta" , "Perković" , "Razvodnik" , STR_TO_DATE("7.3.1956.", "%d.%m.%Y.") , STR_TO_DATE("19.4.2011.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10866 , 3 , "Skila" , "Lovrić" , "Razvodnik" , STR_TO_DATE("10.4.1954.", "%d.%m.%Y.") , STR_TO_DATE("10.5.1997.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10867 , 4 , "Gabrijela" , "Marković" , "Razvodnik" , STR_TO_DATE("29.10.1952.", "%d.%m.%Y.") , STR_TO_DATE("18.10.2009.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10868 , 4 , "Lilia" , "Posavec" , "Pukovnik" , STR_TO_DATE("14.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("19.12.2006.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10869 , 1 , "Elanija" , "Sever" , "Razvodnik" , STR_TO_DATE("20.1.1961.", "%d.%m.%Y.") , STR_TO_DATE("7.5.2018.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10870 , 1 , "Ernest" , "Lukić" , "Poručnik" , STR_TO_DATE("5.12.1966.", "%d.%m.%Y.") , STR_TO_DATE("21.7.2002.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10871 , 2 , "Amber" , "Sever" , "Pozornik" , STR_TO_DATE("12.1.1966.", "%d.%m.%Y.") , STR_TO_DATE("24.3.2009.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10872 , 4 , "Kiara" , "Galić" , "Narednik" , STR_TO_DATE("10.10.1958.", "%d.%m.%Y.") , STR_TO_DATE("20.7.2011.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10873 , 2 , "Ivan" , "Jovanović" , "Poručnik" , STR_TO_DATE("11.11.1965.", "%d.%m.%Y.") , STR_TO_DATE("3.3.2010.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10874 , 2 , "Theodora" , "Miletić" , "Narednik" , STR_TO_DATE("23.1.1955.", "%d.%m.%Y.") , STR_TO_DATE("15.7.1994.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10875 , 3 , "Emberli" , "Perić" , "Brigadir" , STR_TO_DATE("3.5.1964.", "%d.%m.%Y.") , STR_TO_DATE("22.11.1996.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10876 , 2 , "Rubi" , "Kralj" , "Brigadir" , STR_TO_DATE("18.9.1957.", "%d.%m.%Y.") , STR_TO_DATE("5.4.2005.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10877 , 3 , "Majin" , "Đurđević" , "Satnik" , STR_TO_DATE("21.9.1954.", "%d.%m.%Y.") , STR_TO_DATE("7.11.2010.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10878 , 2 , "Nala" , "Martinović" , "Skupnik" , STR_TO_DATE("1.7.1966.", "%d.%m.%Y.") , STR_TO_DATE("5.10.1995.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10879 , 3 , "Avi" , "Vukelić" , "Bojnik" , STR_TO_DATE("4.4.1951.", "%d.%m.%Y.") , STR_TO_DATE("4.9.2006.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10880 , 3 , "Adam" , "Matković" , "Narednik" , STR_TO_DATE("22.7.1958.", "%d.%m.%Y.") , STR_TO_DATE("5.9.1999.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10881 , 3 , "Bosiljka" , "Šimunović" , "Satnik" , STR_TO_DATE("17.1.1957.", "%d.%m.%Y.") , STR_TO_DATE("19.1.2016.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10882 , 2 , "Jema" , "Pavić" , "Narednik" , STR_TO_DATE("22.4.1957.", "%d.%m.%Y.") , STR_TO_DATE("10.11.1993.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10883 , 3 , "Brigita" , "Lovrić" , "Satnik" , STR_TO_DATE("23.10.1962.", "%d.%m.%Y.") , STR_TO_DATE("28.12.2010.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10884 , 4 , "Anabela" , "Šarić" , "Poručnik" , STR_TO_DATE("10.11.1952.", "%d.%m.%Y.") , STR_TO_DATE("1.5.1998.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10885 , 1 , "Lili" , "Bašić" , "Brigadir" , STR_TO_DATE("8.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("20.7.2018.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10886 , 1 , "Oleg" , "Klarić" , "Satnik" , STR_TO_DATE("25.6.1970.", "%d.%m.%Y.") , STR_TO_DATE("9.3.1991.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10887 , 2 , "Harmina" , "Mandić" , "Pozornik" , STR_TO_DATE("12.12.1967.", "%d.%m.%Y.") , STR_TO_DATE("24.6.1990.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10888 , 4 , "Fredo" , "Ćosić" , "Pukovnik" , STR_TO_DATE("13.11.1961.", "%d.%m.%Y.") , STR_TO_DATE("26.1.2017.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10889 , 2 , "Selena" , "Matijević" , "Brigadir" , STR_TO_DATE("12.6.1968.", "%d.%m.%Y.") , STR_TO_DATE("1.9.1992.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10890 , 4 , "Antea" , "Vuković" , "Razvodnik" , STR_TO_DATE("14.3.1965.", "%d.%m.%Y.") , STR_TO_DATE("17.6.2019.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10891 , 3 , "Hrvoje" , "Vuković" , "Poručnik" , STR_TO_DATE("2.10.1964.", "%d.%m.%Y.") , STR_TO_DATE("16.3.1992.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10892 , 2 , "Cecilija" , "Josipović" , "Pukovnik" , STR_TO_DATE("31.1.1956.", "%d.%m.%Y.") , STR_TO_DATE("18.3.2016.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10893 , 2 , "Leonardo" , "Marić" , "Poručnik" , STR_TO_DATE("16.4.1952.", "%d.%m.%Y.") , STR_TO_DATE("1.7.2016.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10894 , 3 , "Linda" , "Šimić" , "Satnik" , STR_TO_DATE("18.7.1950.", "%d.%m.%Y.") , STR_TO_DATE("17.11.1997.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10895 , 4 , "Marin" , "Barišić" , "Razvodnik" , STR_TO_DATE("1.3.1956.", "%d.%m.%Y.") , STR_TO_DATE("2.4.2006.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10896 , 4 , "Remi" , "Crnković" , "Skupnik" , STR_TO_DATE("26.3.1955.", "%d.%m.%Y.") , STR_TO_DATE("7.6.2005.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10897 , 4 , "Aleksandra" , "Bašić" , "Poručnik" , STR_TO_DATE("17.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("4.9.2004.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10898 , 3 , "Anastasija" , "Marić" , "Narednik" , STR_TO_DATE("17.4.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2014.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10899 , 4 , "Maksima" , "Kovačić" , "Pozornik" , STR_TO_DATE("8.2.1970.", "%d.%m.%Y.") , STR_TO_DATE("15.5.2012.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10900 , 3 , "Emili" , "Šimić" , "Skupnik" , STR_TO_DATE("30.9.1953.", "%d.%m.%Y.") , STR_TO_DATE("12.12.2009.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10901 , 3 , "Matej" , "Kovač" , "Brigadir" , STR_TO_DATE("1.1.1967.", "%d.%m.%Y.") , STR_TO_DATE("15.5.1994.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10902 , 3 , "Jerko" , "Novosel" , "Narednik" , STR_TO_DATE("25.12.1954.", "%d.%m.%Y.") , STR_TO_DATE("14.12.2002.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10903 , 4 , "Biserka" , "Crnković" , "Bojnik" , STR_TO_DATE("16.5.1963.", "%d.%m.%Y.") , STR_TO_DATE("16.9.2011.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10904 , 1 , "Rita" , "Galić" , "Pozornik" , STR_TO_DATE("4.7.1963.", "%d.%m.%Y.") , STR_TO_DATE("24.11.2006.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10905 , 4 , "Ivana" , "Ivanović" , "Narednik" , STR_TO_DATE("1.5.1970.", "%d.%m.%Y.") , STR_TO_DATE("13.12.1994.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10906 , 3 , "Ognjen" , "Krznarić" , "Skupnik" , STR_TO_DATE("18.2.1954.", "%d.%m.%Y.") , STR_TO_DATE("1.2.1992.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10907 , 1 , "Ofelia" , "Grgić" , "Pukovnik" , STR_TO_DATE("8.11.1957.", "%d.%m.%Y.") , STR_TO_DATE("1.9.2008.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10908 , 3 , "Rea" , "Filipović" , "Pozornik" , STR_TO_DATE("4.12.1958.", "%d.%m.%Y.") , STR_TO_DATE("31.1.1999.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10909 , 2 , "Klementina" , "Lovrić" , "Razvodnik" , STR_TO_DATE("18.1.1967.", "%d.%m.%Y.") , STR_TO_DATE("30.12.1995.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10910 , 2 , "Itzela" , "Matić" , "Poručnik" , STR_TO_DATE("10.2.1963.", "%d.%m.%Y.") , STR_TO_DATE("26.9.1999.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10911 , 4 , "Rebeka" , "Đurđević" , "Razvodnik" , STR_TO_DATE("10.4.1956.", "%d.%m.%Y.") , STR_TO_DATE("2.2.2001.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10912 , 4 , "Gordan" , "Marković" , "Narednik" , STR_TO_DATE("24.8.1962.", "%d.%m.%Y.") , STR_TO_DATE("26.5.2011.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10913 , 1 , "Goran" , "Cindrić" , "Satnik" , STR_TO_DATE("20.2.1952.", "%d.%m.%Y.") , STR_TO_DATE("20.10.2014.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10914 , 4 , "Emir" , "Jakovljević" , "Poručnik" , STR_TO_DATE("13.1.1968.", "%d.%m.%Y.") , STR_TO_DATE("25.9.1990.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10915 , 4 , "Imani" , "Jozić" , "Bojnik" , STR_TO_DATE("17.6.1963.", "%d.%m.%Y.") , STR_TO_DATE("17.5.2001.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10916 , 2 , "Karla" , "Crnković" , "Pozornik" , STR_TO_DATE("14.12.1961.", "%d.%m.%Y.") , STR_TO_DATE("12.5.2020.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10917 , 4 , "Karmen" , "Vidaković" , "Satnik" , STR_TO_DATE("12.11.1957.", "%d.%m.%Y.") , STR_TO_DATE("26.1.2000.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10918 , 2 , "Lilia" , "Vučković" , "Poručnik" , STR_TO_DATE("3.12.1967.", "%d.%m.%Y.") , STR_TO_DATE("5.8.2002.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10919 , 2 , "Tončica" , "Grubišić" , "Narednik" , STR_TO_DATE("9.7.1950.", "%d.%m.%Y.") , STR_TO_DATE("29.3.2010.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10920 , 3 , "Franka" , "Galić" , "Pozornik" , STR_TO_DATE("17.9.1970.", "%d.%m.%Y.") , STR_TO_DATE("1.5.2003.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10921 , 2 , "Željkica" , "Matijević" , "Pukovnik" , STR_TO_DATE("8.3.1969.", "%d.%m.%Y.") , STR_TO_DATE("13.5.1990.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10922 , 2 , "Karina" , "Galić" , "Brigadir" , STR_TO_DATE("6.9.1966.", "%d.%m.%Y.") , STR_TO_DATE("3.3.1995.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10923 , 4 , "Ira" , "Lončar" , "Brigadir" , STR_TO_DATE("14.7.1956.", "%d.%m.%Y.") , STR_TO_DATE("8.3.2014.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10924 , 4 , "Tihana" , "Jurišić" , "Bojnik" , STR_TO_DATE("7.7.1950.", "%d.%m.%Y.") , STR_TO_DATE("18.8.2005.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10925 , 3 , "Vanja" , "Bašić" , "Satnik" , STR_TO_DATE("26.9.1967.", "%d.%m.%Y.") , STR_TO_DATE("20.10.1996.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10926 , 1 , "Mikaela" , "Perić" , "Poručnik" , STR_TO_DATE("13.10.1961.", "%d.%m.%Y.") , STR_TO_DATE("26.8.2000.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10927 , 3 , "Janica" , "Jozić" , "Pozornik" , STR_TO_DATE("8.2.1956.", "%d.%m.%Y.") , STR_TO_DATE("3.5.2013.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10928 , 4 , "Korina" , "Sever" , "Narednik" , STR_TO_DATE("13.6.1953.", "%d.%m.%Y.") , STR_TO_DATE("19.12.2015.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10929 , 2 , "Vigo" , "Krznarić" , "Skupnik" , STR_TO_DATE("7.7.1955.", "%d.%m.%Y.") , STR_TO_DATE("5.1.2007.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10930 , 4 , "Chaja" , "Josipović" , "Skupnik" , STR_TO_DATE("21.9.1970.", "%d.%m.%Y.") , STR_TO_DATE("5.9.2011.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10931 , 1 , "Zorka" , "Đurić" , "Narednik" , STR_TO_DATE("3.2.1966.", "%d.%m.%Y.") , STR_TO_DATE("5.11.2011.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10932 , 4 , "Ferdinand" , "Jovanović" , "Narednik" , STR_TO_DATE("4.10.1966.", "%d.%m.%Y.") , STR_TO_DATE("16.12.2020.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10933 , 1 , "Elio" , "Posavec" , "Bojnik" , STR_TO_DATE("3.6.1964.", "%d.%m.%Y.") , STR_TO_DATE("14.10.2005.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10934 , 4 , "Alijah" , "Butković" , "Pukovnik" , STR_TO_DATE("14.7.1967.", "%d.%m.%Y.") , STR_TO_DATE("12.9.2015.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10935 , 3 , "Ezra" , "Jovanović" , "Narednik" , STR_TO_DATE("21.7.1955.", "%d.%m.%Y.") , STR_TO_DATE("8.9.2005.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10936 , 4 , "Neven" , "Kovač" , "Bojnik" , STR_TO_DATE("10.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("22.10.2019.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10937 , 2 , "Željko" , "Lukić" , "Skupnik" , STR_TO_DATE("27.6.1963.", "%d.%m.%Y.") , STR_TO_DATE("21.2.2013.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10938 , 2 , "Oliver" , "Marić" , "Pozornik" , STR_TO_DATE("26.12.1966.", "%d.%m.%Y.") , STR_TO_DATE("3.12.1999.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10939 , 2 , "Teo" , "Posavec" , "Satnik" , STR_TO_DATE("27.4.1962.", "%d.%m.%Y.") , STR_TO_DATE("8.3.1997.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10940 , 3 , "Damir" , "Petrović" , "Razvodnik" , STR_TO_DATE("17.4.1950.", "%d.%m.%Y.") , STR_TO_DATE("17.6.1995.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10941 , 2 , "Zara" , "Filipović" , "Brigadir" , STR_TO_DATE("20.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("19.8.2019.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10942 , 3 , "Zahra" , "Kovačević" , "Poručnik" , STR_TO_DATE("17.4.1970.", "%d.%m.%Y.") , STR_TO_DATE("2.3.2016.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10943 , 2 , "Penelopa" , "Horvat" , "Skupnik" , STR_TO_DATE("30.6.1953.", "%d.%m.%Y.") , STR_TO_DATE("3.7.2003.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10944 , 2 , "Željka" , "Jakovljević" , "Narednik" , STR_TO_DATE("8.6.1952.", "%d.%m.%Y.") , STR_TO_DATE("15.1.2010.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10945 , 2 , "Ljerka" , "Ivanković" , "Narednik" , STR_TO_DATE("1.7.1954.", "%d.%m.%Y.") , STR_TO_DATE("28.12.2013.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10946 , 2 , "Marta" , "Katić" , "Poručnik" , STR_TO_DATE("10.8.1969.", "%d.%m.%Y.") , STR_TO_DATE("24.10.2020.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10947 , 3 , "Dragica" , "Bošnjak" , "Poručnik" , STR_TO_DATE("6.12.1956.", "%d.%m.%Y.") , STR_TO_DATE("29.3.2012.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10948 , 1 , "Mina" , "Tomić" , "Pozornik" , STR_TO_DATE("15.4.1968.", "%d.%m.%Y.") , STR_TO_DATE("1.5.2014.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10949 , 4 , "Katalina" , "Šimunić" , "Narednik" , STR_TO_DATE("27.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("18.10.2010.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10950 , 2 , "Jaka" , "Bošnjak" , "Bojnik" , STR_TO_DATE("3.3.1953.", "%d.%m.%Y.") , STR_TO_DATE("1.3.2001.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10951 , 2 , "Lidija" , "Popović" , "Satnik" , STR_TO_DATE("1.8.1960.", "%d.%m.%Y.") , STR_TO_DATE("17.12.2015.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10952 , 3 , "Jura" , "Ivanković" , "Skupnik" , STR_TO_DATE("24.9.1958.", "%d.%m.%Y.") , STR_TO_DATE("7.12.1996.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10953 , 3 , "Anamarija" , "Vučković" , "Pozornik" , STR_TO_DATE("17.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("11.2.2016.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10954 , 2 , "Damjan" , "Petrović" , "Satnik" , STR_TO_DATE("30.5.1961.", "%d.%m.%Y.") , STR_TO_DATE("26.12.2017.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10955 , 3 , "Eli" , "Matković" , "Narednik" , STR_TO_DATE("24.11.1963.", "%d.%m.%Y.") , STR_TO_DATE("5.10.2002.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10956 , 4 , "Tristan" , "Bašić" , "Razvodnik" , STR_TO_DATE("5.2.1963.", "%d.%m.%Y.") , STR_TO_DATE("2.3.2016.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10957 , 4 , "Lea" , "Galić" , "Pukovnik" , STR_TO_DATE("16.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("6.12.2015.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10958 , 2 , "Erik" , "Dujmović" , "Satnik" , STR_TO_DATE("20.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("4.12.2015.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10959 , 1 , "Lovorka" , "Vukelić" , "Pukovnik" , STR_TO_DATE("19.5.1964.", "%d.%m.%Y.") , STR_TO_DATE("20.6.2018.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10960 , 4 , "Kristina" , "Marić" , "Poručnik" , STR_TO_DATE("19.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("12.9.2010.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10961 , 1 , "Regina" , "Božić" , "Razvodnik" , STR_TO_DATE("8.12.1965.", "%d.%m.%Y.") , STR_TO_DATE("2.1.1990.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10962 , 3 , "Ante" , "Kralj" , "Pukovnik" , STR_TO_DATE("1.10.1953.", "%d.%m.%Y.") , STR_TO_DATE("23.1.2019.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10963 , 3 , "Jeremija" , "Pavlić" , "Skupnik" , STR_TO_DATE("8.1.1964.", "%d.%m.%Y.") , STR_TO_DATE("14.2.1996.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10964 , 2 , "Držislav" , "Lukić" , "Satnik" , STR_TO_DATE("3.5.1970.", "%d.%m.%Y.") , STR_TO_DATE("3.3.2004.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10965 , 2 , "Imani" , "Cvitković" , "Satnik" , STR_TO_DATE("5.5.1956.", "%d.%m.%Y.") , STR_TO_DATE("10.3.2007.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10966 , 1 , "Teresa" , "Golubić" , "Poručnik" , STR_TO_DATE("24.8.1961.", "%d.%m.%Y.") , STR_TO_DATE("10.1.1998.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10967 , 1 , "Fredo" , "Božić" , "Brigadir" , STR_TO_DATE("23.9.1960.", "%d.%m.%Y.") , STR_TO_DATE("12.2.2017.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10968 , 1 , "Krunoslav" , "Marjanović" , "Pozornik" , STR_TO_DATE("11.9.1958.", "%d.%m.%Y.") , STR_TO_DATE("5.4.2007.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10969 , 1 , "Sven" , "Marušić" , "Pozornik" , STR_TO_DATE("25.2.1956.", "%d.%m.%Y.") , STR_TO_DATE("4.1.2012.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10970 , 4 , "Iris" , "Krznarić" , "Poručnik" , STR_TO_DATE("30.6.1956.", "%d.%m.%Y.") , STR_TO_DATE("25.6.1990.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10971 , 1 , "Moreno" , "Babić" , "Pukovnik" , STR_TO_DATE("28.6.1960.", "%d.%m.%Y.") , STR_TO_DATE("15.5.2001.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10972 , 4 , "Vladimir" , "Jovanović" , "Brigadir" , STR_TO_DATE("5.10.1966.", "%d.%m.%Y.") , STR_TO_DATE("16.4.1995.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10973 , 4 , "Dea" , "Živković" , "Brigadir" , STR_TO_DATE("7.9.1954.", "%d.%m.%Y.") , STR_TO_DATE("10.7.2009.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10974 , 2 , "Siri" , "Golubić" , "Razvodnik" , STR_TO_DATE("20.6.1959.", "%d.%m.%Y.") , STR_TO_DATE("17.8.2005.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10975 , 1 , "Anabela" , "Đurđević" , "Brigadir" , STR_TO_DATE("31.1.1970.", "%d.%m.%Y.") , STR_TO_DATE("7.4.2010.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10976 , 1 , "Elina" , "Katić" , "Pozornik" , STR_TO_DATE("5.10.1959.", "%d.%m.%Y.") , STR_TO_DATE("15.12.2000.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10977 , 3 , "Otta" , "Burić" , "Skupnik" , STR_TO_DATE("24.4.1966.", "%d.%m.%Y.") , STR_TO_DATE("10.11.2012.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10978 , 2 , "Selina" , "Lončarić" , "Narednik" , STR_TO_DATE("11.3.1967.", "%d.%m.%Y.") , STR_TO_DATE("15.6.1994.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10979 , 1 , "Severino" , "Vidaković" , "Bojnik" , STR_TO_DATE("28.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("10.2.2008.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10980 , 4 , "Ezekiel" , "Mitrović" , "Pukovnik" , STR_TO_DATE("6.10.1964.", "%d.%m.%Y.") , STR_TO_DATE("15.5.1993.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10981 , 3 , "Nikolina" , "Cindrić" , "Narednik" , STR_TO_DATE("12.8.1962.", "%d.%m.%Y.") , STR_TO_DATE("8.4.2010.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10982 , 4 , "Emil" , "Vuković" , "Razvodnik" , STR_TO_DATE("19.11.1952.", "%d.%m.%Y.") , STR_TO_DATE("1.1.2016.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10983 , 4 , "Sumka" , "Jelić" , "Pukovnik" , STR_TO_DATE("5.2.1953.", "%d.%m.%Y.") , STR_TO_DATE("21.3.2011.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10984 , 1 , "Anamarija" , "Marić" , "Razvodnik" , STR_TO_DATE("23.10.1955.", "%d.%m.%Y.") , STR_TO_DATE("5.7.1993.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10985 , 4 , "Rahela" , "Vidaković" , "Pukovnik" , STR_TO_DATE("2.10.1958.", "%d.%m.%Y.") , STR_TO_DATE("19.7.2012.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10986 , 1 , "Dijana" , "Radić" , "Poručnik" , STR_TO_DATE("7.11.1968.", "%d.%m.%Y.") , STR_TO_DATE("20.12.2018.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10987 , 2 , "Lovro" , "Jurković" , "Brigadir" , STR_TO_DATE("15.8.1962.", "%d.%m.%Y.") , STR_TO_DATE("19.9.2017.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10988 , 4 , "Leonida" , "Lončarić" , "Bojnik" , STR_TO_DATE("28.3.1962.", "%d.%m.%Y.") , STR_TO_DATE("10.5.1991.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10989 , 2 , "Eva" , "Abramović" , "Pozornik" , STR_TO_DATE("24.1.1966.", "%d.%m.%Y.") , STR_TO_DATE("11.5.1997.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10990 , 1 , "Evona" , "Crnković" , "Skupnik" , STR_TO_DATE("8.1.1951.", "%d.%m.%Y.") , STR_TO_DATE("20.5.2020.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10991 , 2 , "Aida" , "Šarić" , "Pozornik" , STR_TO_DATE("14.4.1960.", "%d.%m.%Y.") , STR_TO_DATE("2.6.2010.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10992 , 2 , "Katarina" , "Radić" , "Pukovnik" , STR_TO_DATE("4.11.1956.", "%d.%m.%Y.") , STR_TO_DATE("27.12.1994.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10993 , 4 , "Lana" , "Krznarić" , "Satnik" , STR_TO_DATE("15.8.1958.", "%d.%m.%Y.") , STR_TO_DATE("20.9.1993.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10994 , 2 , "Oskar" , "Matković" , "Skupnik" , STR_TO_DATE("17.6.1970.", "%d.%m.%Y.") , STR_TO_DATE("15.4.2014.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10995 , 3 , "Bena" , "Marković" , "Pozornik" , STR_TO_DATE("26.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("25.11.2003.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10996 , 3 , "Marina" , "Marjanović" , "Skupnik" , STR_TO_DATE("27.3.1952.", "%d.%m.%Y.") , STR_TO_DATE("19.6.2003.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10997 , 1 , "Felicija" , "Herceg" , "Pozornik" , STR_TO_DATE("10.1.1958.", "%d.%m.%Y.") , STR_TO_DATE("29.4.2007.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10998 , 3 , "Božana" , "Galić" , "Narednik" , STR_TO_DATE("1.6.1968.", "%d.%m.%Y.") , STR_TO_DATE("19.10.1995.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10999 , 3 , "Pavle" , "Dujmović" , "Razvodnik" , STR_TO_DATE("4.9.1955.", "%d.%m.%Y.") , STR_TO_DATE("24.11.1995.", "%d.%m.%Y.") , "Neaktivan" , "A+" );