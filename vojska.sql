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
    ishod TEXT,   -- vratit NOT NULL
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
/*
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



-- BACKEND:


DELIMITER //
CREATE TRIGGER kriptiranje
 BEFORE INSERT ON osoblje
 FOR EACH ROW
BEGIN
 INSERT INTO login VALUES (new.id,new.ime,md5(concat(new.ime,new.prezime)));
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
select* from login;
select * from login where lozinka = md5(concat("Eliza","Eliza")) and login.ime = "Eliza";
"Eliza" , "Vuković"
select * from login;
*/


INSERT INTO sektor VALUES
(1, "Hrvatska kopnena vojska", STR_TO_DATE("28.05.1991.", "%d.%m.%Y."), "Najbrojnija je grana Oružanih snaga Republike Hrvatske, čija je uloga i namjena promicanje i zaštita vitalnih nacionalnih interesa Republike Hrvatske, obrana suvereniteta i teritorijalne cjelovitosti države. Temeljna zadaća je spriječiti prodor agresora u dubinu teritorija, sačuvati vitalne strategijske objekte, osigurati mobilizaciju ratnog sastava i pobijediti agresora. Nositeljica je i organizatorica kopnene obrane Republike Hrvatske.", 4324000000.00),
(2, "Hrvatska ratna mornarica", STR_TO_DATE("12.09.1991.", "%d.%m.%Y."), "Uloga i namjena HRM-e  je štititi integritet i suverenitet Republike Hrvatske na moru i s mora. Nositeljica je i organizatorica pomorske obrane Republike Hrvatske", 2876000000.00),
(3, "Hrvatsko ratno zrakoplovstvo", STR_TO_DATE("12.12.1991.", "%d.%m.%Y."), "Osnovna zadaća HRZ-a je osiguranje suverenosti zračnog prostora Republike Hrvatske te pružanje zrakoplovne potpore drugim granama u provedbi njihovih zadaća u združenim operacijama. Nositelj je i organizator integriranog sustava protuzračne obrane Republike Hrvatske.", 3622000000.00),
(4, "Hrvatska vojna policija", STR_TO_DATE("24.08.1991.", "%d.%m.%Y."), "Vojna policija Oružanih snaga Republike Hrvatske (VP OSRH) pruža potporu Ministarstvu obrane i Oružanim snagama Republike Hrvatske obavljanjem namjenskih vojnopolicijskih poslova u miru i ratu te borbenih zadaća u ratu.", 1822000000.00);



INSERT INTO lokacija VALUES
(16,null,"Jaipur",26.922070,75.778885),
(17,null,"Islamabad",33.738045,73.084488),
(18,null,"Kabul",34.543896,69.160652),
(19,null,"Herat",34.343044,62.199074),
(20,null,"Kholm",51.14312320,23.47119860),
(21,null,"Charikar",35.013058,69.168892),
(22,null,"Solun",40.64361,22.93086),
(23,null,"Patras",38.246639,21.734573),
(24,null,"Kijev",50.450001,30.523333),
(25,null,"Nikolajev",46.96591,31.9974),
(26,null,"Pretorija",-25.731340,28.218370),
(27,null,"Kaapstad",-33.918861,18.423300),
(28,null,"Taipei",25.105497,121.597366),
(29,null,"Kaohsiung",22.633333,120.266670),
(30,null,"Ulsan",35.549999,129.316666),
(31,null,"Busan",35.166668,129.066666),
(32,null,"Sarajevo",43.856430,18.413029),
(33,null,"Bihac",44.811962,15.868565),
(34,null,"Caracas",10.500000,-66.916664),
(35,null,"Maracaibo",10.653860,-71.645966),
(36,null,"Stavanger",58.969975,5.733107),
(37,null,"Narvik",68.438499,17.427261),
(38,null,"Bern",46.947456,7.451123),
(39,null,"Chur",46.8499,9.5329),
(40,null,"Ohio",40.367474,-82.996216),
(41,null,"Columbus",39.983334,-82.983330);



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
 ( 10056 , 4 , "Antun" , "Barišić" , "Razvodnik" , STR_TO_DATE("17.10.1951.", "%d.%m.%Y.") , STR_TO_DATE("23.4.2018.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10057 , 4 , "Rhea" , "Živković" , "Narednik" , STR_TO_DATE("22.9.1964.", "%d.%m.%Y.") , STR_TO_DATE("28.2.1996.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10058 , 2 , "Mario" , "Šimić" , "Bojnik" , STR_TO_DATE("12.3.1951.", "%d.%m.%Y.") , STR_TO_DATE("10.8.1990.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
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
 ( 10999 , 3 , "admin" , "admin" , "Razvodnik" , STR_TO_DATE("4.9.1955.", "%d.%m.%Y.") , STR_TO_DATE("24.11.1995.", "%d.%m.%Y.") , "Pokojan u duši" , "A+" );





INSERT INTO tura VALUES
(1, "Indijska i Pakistanska tura", "Mirovna tura", STR_TO_DATE("01.08.2008","%d.%m.%Y."), STR_TO_DATE("04.11.2021","%d.%m.%Y.")),
(2, "1. Afganistanska tura", "Vojna tura", STR_TO_DATE("01.10.2008","%d.%m.%Y."), STR_TO_DATE("15.04.2009","%d.%m.%Y.")),
(3, "Grčka tura", "Vojna tura", STR_TO_DATE("01.12.2010","%d.%m.%Y."), STR_TO_DATE("16.11.2014","%d.%m.%Y.")),
(4, "Poljska tura", "Mirovna tura", STR_TO_DATE("01.01.2015","%d.%m.%Y."), STR_TO_DATE("04.09.2015","%d.%m.%Y.")),
(5, "Ukrainska tura", "Vojna tura", STR_TO_DATE("24.02.2022","%d.%m.%Y."), STR_TO_DATE("30.10.2022","%d.%m.%Y.")),
(6, "2. Afganistanska tura", "Mirovna tura", STR_TO_DATE("01.12.2010","%d.%m.%Y."), STR_TO_DATE("16.11.2014","%d.%m.%Y.")),
(7, "Južnoafrička tura", "Mirovna tura", STR_TO_DATE("04.10.2013","%d.%m.%Y."), STR_TO_DATE("13.09.2014","%d.%m.%Y.")),
(8, "Taiwanska tura", "Mirovna tura", STR_TO_DATE("08.06.2019","%d.%m.%Y."), STR_TO_DATE("15.07.2020","%d.%m.%Y.")),
(9, "Južno Koreanska tura", "Mirovna tura", STR_TO_DATE("24.11.2009","%d.%m.%Y."), STR_TO_DATE("16.02.2011","%d.%m.%Y.")),
(10, "Bosanskohercegovačka tura", "Mirovna tura", STR_TO_DATE("13.10.2010","%d.%m.%Y."), STR_TO_DATE("16.11.2012","%d.%m.%Y.")),
(11, "Venezuelanksa tura", "Vojna tura", STR_TO_DATE("26.09.2015","%d.%m.%Y."), STR_TO_DATE("16.08.2017","%d.%m.%Y.")),
(12, "Norveška tura", "Mirovna tura", STR_TO_DATE("01.04.2016","%d.%m.%Y."), STR_TO_DATE("23.04.2018","%d.%m.%Y.")),
(13, "Švicarska tura ", "Mirovna tura", STR_TO_DATE("07.05.2006","%d.%m.%Y."), STR_TO_DATE("20.11.2009","%d.%m.%Y.")),
(14, "SAD tura", "Mirovna tura", STR_TO_DATE("01.12.2012","%d.%m.%Y."), STR_TO_DATE("28.09.2013","%d.%m.%Y."));



INSERT INTO misija VALUES
 ( 3001 , "UNAVEM III" , STR_TO_DATE("7.12.1996.", "%d.%m.%Y.") , STR_TO_DATE("24.6.2003.", "%d.%m.%Y.") , 29 , 10 , null, 5507101 ),
 ( 3002 , "UNAVEM II" , STR_TO_DATE("18.11.1995.", "%d.%m.%Y.") , STR_TO_DATE("20.2.2022.", "%d.%m.%Y.") , 20 , 10 , null, 6541048 ),
 ( 3003 , "UNTAET" , STR_TO_DATE("17.3.1997.", "%d.%m.%Y.") , STR_TO_DATE("6.5.1992.", "%d.%m.%Y.") , 36 , 7 , null, 3855871 ),
 ( 3004 , "UNMISET" , STR_TO_DATE("23.5.2016.", "%d.%m.%Y.") , STR_TO_DATE("3.9.1999.", "%d.%m.%Y.") , 19 , 12 , null, 1680718 ),
 ( 3005 , "UNMIT" , STR_TO_DATE("14.7.2005.", "%d.%m.%Y.") , STR_TO_DATE("11.3.2001.", "%d.%m.%Y.") , 38 , 1 , null, 6079519 ),
 ( 3006 , "UNCRO" , STR_TO_DATE("1.2.2001.", "%d.%m.%Y.") , STR_TO_DATE("17.3.1992.", "%d.%m.%Y.") , 27 , 13 , null, 3381107 ),
 ( 3007 , "UNFICYP" , STR_TO_DATE("13.9.2017.", "%d.%m.%Y.") , STR_TO_DATE("11.12.2018.", "%d.%m.%Y.") , 22 , 13 , null, 5970893 ),
 ( 3008 , "MONUA" , STR_TO_DATE("27.10.2004.", "%d.%m.%Y.") , STR_TO_DATE("24.8.2030.", "%d.%m.%Y.") , 28 , 7 , null, 6807180 ),
 ( 3009 , "MINURCA" , STR_TO_DATE("15.7.2010.", "%d.%m.%Y.") , STR_TO_DATE("23.10.2032.", "%d.%m.%Y.") , 27 , 10 , null, 2975836 ),
 ( 3010 , "MONUC UN" , STR_TO_DATE("22.6.2029.", "%d.%m.%Y.") , STR_TO_DATE("18.1.1997.", "%d.%m.%Y.") , 41 , 2 , null, 8709357 ),
 ( 3011 , "UNYOM" , STR_TO_DATE("5.3.2010.", "%d.%m.%Y.") , STR_TO_DATE("22.1.2023.", "%d.%m.%Y.") , 20 , 11 , null, 9916296 ),
 ( 3012 , "MINURCA" , STR_TO_DATE("24.5.2025.", "%d.%m.%Y.") , STR_TO_DATE("9.8.2022.", "%d.%m.%Y.") , 31 , 14 , null, 5019551 ),
 ( 3013 , "UNOMIG" , STR_TO_DATE("17.3.2013.", "%d.%m.%Y.") , STR_TO_DATE("14.11.2004.", "%d.%m.%Y.") , 32 , 4 , null, 2062168 ),
 ( 3014 , "UNMIL" , STR_TO_DATE("9.2.2002.", "%d.%m.%Y.") , STR_TO_DATE("7.1.2029.", "%d.%m.%Y.") , 21 , 13 , null, 8728552 ),
 ( 3015 , "UNMOGIP" , STR_TO_DATE("8.8.2018.", "%d.%m.%Y.") , STR_TO_DATE("7.7.2006.", "%d.%m.%Y.") , 23 , 4 , null, 3318084 ),
 ( 3016 , "MINURCAT" , STR_TO_DATE("7.11.2021.", "%d.%m.%Y.") , STR_TO_DATE("21.4.2004.", "%d.%m.%Y.") , 34 , 8 , null, 1692847 ),
 ( 3017 , "UNAMID" , STR_TO_DATE("17.12.1999.", "%d.%m.%Y.") , STR_TO_DATE("14.3.1994.", "%d.%m.%Y.") , 39 , 8 , null, 8843818 ),
 ( 3018 , "UNAMSIL" , STR_TO_DATE("4.8.2026.", "%d.%m.%Y.") , STR_TO_DATE("20.2.1994.", "%d.%m.%Y.") , 27 , 4 , null, 3493087 ),
 ( 3019 , "UNASOG" , STR_TO_DATE("23.3.2001.", "%d.%m.%Y.") , STR_TO_DATE("3.5.2012.", "%d.%m.%Y.") , 34 , 5 , null, 2149934 ),
 ( 3020 , "UNPROFOR" , STR_TO_DATE("1.6.1995.", "%d.%m.%Y.") , STR_TO_DATE("1.12.2022.", "%d.%m.%Y.") , 28 , 1 , null, 5557034 ),
 ( 3021 , "MINUGUA" , STR_TO_DATE("6.3.2005.", "%d.%m.%Y.") , STR_TO_DATE("23.6.1995.", "%d.%m.%Y.") , 21 , 12 , null, 4525460 ),
 ( 3022 , "UNOMIL" , STR_TO_DATE("2.3.2014.", "%d.%m.%Y.") , STR_TO_DATE("14.10.2033.", "%d.%m.%Y.") , 41 , 7 , null, 4644302 ),
 ( 3023 , "UNTMIH" , STR_TO_DATE("7.12.2019.", "%d.%m.%Y.") , STR_TO_DATE("15.3.2034.", "%d.%m.%Y.") , 27 , 11 , null, 6720729 ),
 ( 3024 , "UNMIBH" , STR_TO_DATE("21.3.1999.", "%d.%m.%Y.") , STR_TO_DATE("19.9.2027.", "%d.%m.%Y.") , 26 , 12 , null, 2760791 ),
 ( 3025 , "ONUSAL" , STR_TO_DATE("9.3.2009.", "%d.%m.%Y.") , STR_TO_DATE("11.1.1999.", "%d.%m.%Y.") , 20 , 12 , null, 2505324 ),
 ( 3026 , "MINOPUH UN" , STR_TO_DATE("23.5.2026.", "%d.%m.%Y.") , STR_TO_DATE("20.1.1996.", "%d.%m.%Y.") , 34 , 13 , null, 8658669 ),
 ( 3027 , "UNMIH" , STR_TO_DATE("1.12.1995.", "%d.%m.%Y.") , STR_TO_DATE("24.11.2003.", "%d.%m.%Y.") , 17 , 14 , null, 2674440 ),
 ( 3028 , "MONUA" , STR_TO_DATE("14.3.2003.", "%d.%m.%Y.") , STR_TO_DATE("8.6.2023.", "%d.%m.%Y.") , 18 , 6 , null, 8566407 ),
 ( 3029 , "UNAMSIL" , STR_TO_DATE("25.2.1996.", "%d.%m.%Y.") , STR_TO_DATE("11.1.2001.", "%d.%m.%Y.") , 21 , 12 , null, 8550255 ),
 ( 3030 , "UNAMSIL" , STR_TO_DATE("14.11.1992.", "%d.%m.%Y.") , STR_TO_DATE("27.1.2028.", "%d.%m.%Y.") , 19 , 5 , null, 9865296 ),
 ( 3031 , "UNMIH" , STR_TO_DATE("21.7.1997.", "%d.%m.%Y.") , STR_TO_DATE("11.8.2014.", "%d.%m.%Y.") , 29 , 2 , null, 7109438 ),
 ( 3032 , "ONUC" , STR_TO_DATE("12.3.2014.", "%d.%m.%Y.") , STR_TO_DATE("2.8.2004.", "%d.%m.%Y.") , 27 , 5 , null, 1903659 ),
 ( 3033 , "UNOCI" , STR_TO_DATE("2.11.2030.", "%d.%m.%Y.") , STR_TO_DATE("24.2.1995.", "%d.%m.%Y.") , 17 , 13 , null, 611531 ),
 ( 3034 , "UNSMIH" , STR_TO_DATE("25.5.2019.", "%d.%m.%Y.") , STR_TO_DATE("22.7.2009.", "%d.%m.%Y.") , 20 , 6 , null, 3860340 ),
 ( 3035 , "UNMOP" , STR_TO_DATE("19.7.2022.", "%d.%m.%Y.") , STR_TO_DATE("3.3.2023.", "%d.%m.%Y.") , 24 , 7 , null, 5264104 ),
 ( 3036 , "UNMIK" , STR_TO_DATE("24.10.2001.", "%d.%m.%Y.") , STR_TO_DATE("28.12.2004.", "%d.%m.%Y.") , 36 , 3 , null, 473290 ),
 ( 3037 , "UNMOGIP" , STR_TO_DATE("19.8.2026.", "%d.%m.%Y.") , STR_TO_DATE("26.4.2004.", "%d.%m.%Y.") , 30 , 10 , null, 7519572 ),
 ( 3038 , "UNMISET" , STR_TO_DATE("9.9.2002.", "%d.%m.%Y.") , STR_TO_DATE("11.9.2027.", "%d.%m.%Y.") , 24 , 1 , null, 9840396 ),
 ( 3039 , "UNGOMAP" , STR_TO_DATE("19.9.2009.", "%d.%m.%Y.") , STR_TO_DATE("13.1.2026.", "%d.%m.%Y.") , 28 , 11 , null, 9966801 ),
 ( 3040 , "UNAMIC" , STR_TO_DATE("16.11.2017.", "%d.%m.%Y.") , STR_TO_DATE("28.10.2018.", "%d.%m.%Y.") , 36 , 8 , null, 172465 ),
 ( 3041 , "UNOCI" , STR_TO_DATE("23.11.1993.", "%d.%m.%Y.") , STR_TO_DATE("16.12.1998.", "%d.%m.%Y.") , 22 , 5 , null, 7220839 ),
 ( 3042 , "UNOMSIL" , STR_TO_DATE("11.12.2005.", "%d.%m.%Y.") , STR_TO_DATE("28.6.2011.", "%d.%m.%Y.") , 33 , 8 , null, 3998984 ),
 ( 3043 , "UNIPOM" , STR_TO_DATE("19.1.1995.", "%d.%m.%Y.") , STR_TO_DATE("4.1.2001.", "%d.%m.%Y.") , 40 , 6 , null, 6122253 ),
 ( 3044 , "UNTAC" , STR_TO_DATE("12.9.2012.", "%d.%m.%Y.") , STR_TO_DATE("20.3.2007.", "%d.%m.%Y.") , 31 , 10 , null, 3957457 ),
 ( 3045 , "DOMREP" , STR_TO_DATE("21.7.2001.", "%d.%m.%Y.") , STR_TO_DATE("15.7.2032.", "%d.%m.%Y.") , 16 , 13 , null, 1087331 ),
 ( 3046 , "UNSF" , STR_TO_DATE("8.4.2001.", "%d.%m.%Y.") , STR_TO_DATE("28.5.1994.", "%d.%m.%Y.") , 36 , 11 , null, 853626 ),
 ( 3047 , "MONUA" , STR_TO_DATE("24.7.2017.", "%d.%m.%Y.") , STR_TO_DATE("1.10.2013.", "%d.%m.%Y.") , 25 , 9 , null, 6286138 ),
 ( 3048 , "UNOGIL" , STR_TO_DATE("17.8.2030.", "%d.%m.%Y.") , STR_TO_DATE("3.5.2029.", "%d.%m.%Y.") , 40 , 10 , null, 8778437 ),
 ( 3049 , "UNPREDEP" , STR_TO_DATE("22.9.2009.", "%d.%m.%Y.") , STR_TO_DATE("7.11.1994.", "%d.%m.%Y.") , 21 , 1 , null, 6568915 ),
 ( 3050 , "UNPREDEP" , STR_TO_DATE("11.5.2018.", "%d.%m.%Y.") , STR_TO_DATE("14.5.2033.", "%d.%m.%Y.") , 24 , 14 , null, 8606804 ),
 ( 3051 , "UNOMUR" , STR_TO_DATE("26.10.2004.", "%d.%m.%Y.") , STR_TO_DATE("2.8.2032.", "%d.%m.%Y.") , 22 , 8 , null, 2569626 ),
 ( 3052 , "UNAMIR" , STR_TO_DATE("3.9.2024.", "%d.%m.%Y.") , STR_TO_DATE("17.8.2022.", "%d.%m.%Y.") , 32 , 5 , null, 1502835 ),
 ( 3053 , "UNOSOM I" , STR_TO_DATE("17.7.1993.", "%d.%m.%Y.") , STR_TO_DATE("16.5.2028.", "%d.%m.%Y.") , 22 , 11 , null, 1358647 ),
 ( 3054 , "UNOGIL" , STR_TO_DATE("25.6.2017.", "%d.%m.%Y.") , STR_TO_DATE("10.2.2007.", "%d.%m.%Y.") , 40 , 11 , null, 8713394 ),
 ( 3055 , "UNAMSIL" , STR_TO_DATE("6.2.2017.", "%d.%m.%Y.") , STR_TO_DATE("22.7.2033.", "%d.%m.%Y.") , 31 , 5 , null, 7138853 );

INSERT INTO osoblje_na_misiji VALUES
 ( 4000 , 10631 , 3029 ),
 ( 4001 , 10709 , 3005 ),
 ( 4002 , 10588 , 3011 ),
 ( 4003 , 10981 , 3037 ),
 ( 4004 , 10440 , 3016 ),
 ( 4005 , 10573 , 3043 ),
 ( 4006 , 10510 , 3010 ),
 ( 4007 , 10611 , 3014 ),
 ( 4008 , 10893 , 3028 ),
 ( 4009 , 10661 , 3028 ),
 ( 4010 , 10921 , 3018 ),
 ( 4011 , 10298 , 3023 ),
 ( 4012 , 10463 , 3051 ),
 ( 4013 , 10879 , 3003 ),
 ( 4014 , 10839 , 3042 ),
 ( 4015 , 10586 , 3026 ),
 ( 4016 , 10247 , 3053 ),
 ( 4017 , 10244 , 3038 ),
 ( 4018 , 10009 , 3047 ),
 ( 4019 , 10476 , 3055 ),
 ( 4020 , 10686 , 3043 ),
 ( 4021 , 10354 , 3047 ),
 ( 4022 , 10655 , 3023 ),
 ( 4023 , 10929 , 3036 ),
 ( 4024 , 10322 , 3042 ),
 ( 4025 , 10316 , 3017 ),
 ( 4026 , 10436 , 3042 ),
 ( 4027 , 10828 , 3004 ),
 ( 4028 , 10200 , 3040 ),
 ( 4029 , 10511 , 3001 ),
 ( 4030 , 10900 , 3024 ),
 ( 4031 , 10882 , 3045 ),
 ( 4032 , 10069 , 3047 ),
 ( 4033 , 10365 , 3017 ),
 ( 4034 , 10901 , 3032 ),
 ( 4035 , 10923 , 3047 ),
 ( 4036 , 10375 , 3036 ),
 ( 4037 , 10021 , 3034 ),
 ( 4038 , 10383 , 3021 ),
 ( 4039 , 10005 , 3032 ),
 ( 4040 , 10894 , 3008 ),
 ( 4041 , 10217 , 3047 ),
 ( 4042 , 10642 , 3049 ),
 ( 4043 , 10543 , 3037 ),
 ( 4044 , 10847 , 3001 ),
 ( 4045 , 10408 , 3030 ),
 ( 4046 , 10309 , 3029 ),
 ( 4047 , 10953 , 3017 ),
 ( 4048 , 10392 , 3019 ),
 ( 4049 , 10808 , 3010 ),
 ( 4050 , 10250 , 3046 ),
 ( 4051 , 10202 , 3054 ),
 ( 4052 , 10359 , 3022 ),
 ( 4053 , 10046 , 3035 ),
 ( 4054 , 10496 , 3001 ),
 ( 4055 , 10608 , 3028 ),
 ( 4056 , 10137 , 3054 ),
 ( 4057 , 10389 , 3005 ),
 ( 4058 , 10287 , 3015 ),
 ( 4059 , 10285 , 3017 ),
 ( 4060 , 10446 , 3029 ),
 ( 4061 , 10783 , 3019 ),
 ( 4062 , 10601 , 3038 ),
 ( 4063 , 10254 , 3041 ),
 ( 4064 , 10599 , 3003 ),
 ( 4065 , 10457 , 3037 ),
 ( 4066 , 10244 , 3026 ),
 ( 4067 , 10787 , 3005 ),
 ( 4068 , 10207 , 3024 ),
 ( 4069 , 10793 , 3036 ),
 ( 4070 , 10548 , 3042 ),
 ( 4071 , 10510 , 3027 ),
 ( 4072 , 10643 , 3040 ),
 ( 4073 , 10688 , 3041 ),
 ( 4074 , 10696 , 3012 ),
 ( 4075 , 10978 , 3026 ),
 ( 4076 , 10911 , 3042 ),
 ( 4077 , 10376 , 3035 ),
 ( 4078 , 10633 , 3003 ),
 ( 4079 , 10768 , 3021 ),
 ( 4080 , 10987 , 3001 ),
 ( 4081 , 10847 , 3032 ),
 ( 4082 , 10501 , 3008 ),
 ( 4083 , 10348 , 3030 ),
 ( 4084 , 10655 , 3008 ),
 ( 4085 , 10830 , 3055 ),
 ( 4086 , 10890 , 3013 ),
 ( 4087 , 10516 , 3010 ),
 ( 4088 , 10205 , 3008 ),
 ( 4089 , 10080 , 3011 ),
 ( 4090 , 10443 , 3006 ),
 ( 4091 , 10566 , 3009 ),
 ( 4092 , 10561 , 3034 ),
 ( 4093 , 10307 , 3040 ),
 ( 4094 , 10539 , 3024 ),
 ( 4095 , 10612 , 3035 ),
 ( 4096 , 10362 , 3001 ),
 ( 4097 , 10632 , 3049 ),
 ( 4098 , 10070 , 3006 ),
 ( 4099 , 10757 , 3043 );

INSERT INTO osoblje_na_turi VALUES
 ( 8001 , 10916 , 5 , STR_TO_DATE("24.6.2024.", "%d.%m.%Y.") , STR_TO_DATE("8.11.2011.", "%d.%m.%Y.") ),
 ( 8002 , 10439 , 8 , STR_TO_DATE("6.11.2009.", "%d.%m.%Y.") , STR_TO_DATE("14.11.2030.", "%d.%m.%Y.") ),
 ( 8003 , 10772 , 7 , STR_TO_DATE("7.1.1999.", "%d.%m.%Y.") , STR_TO_DATE("16.3.2012.", "%d.%m.%Y.") ),
 ( 8004 , 10287 , 13 , STR_TO_DATE("12.11.2014.", "%d.%m.%Y.") , STR_TO_DATE("11.11.2001.", "%d.%m.%Y.") ),
 ( 8005 , 10610 , 4 , STR_TO_DATE("25.10.1993.", "%d.%m.%Y.") , STR_TO_DATE("15.8.2008.", "%d.%m.%Y.") ),
 ( 8006 , 10659 , 4 , STR_TO_DATE("20.4.2000.", "%d.%m.%Y.") , STR_TO_DATE("20.9.2015.", "%d.%m.%Y.") ),
 ( 8007 , 10141 , 2 , STR_TO_DATE("8.4.1996.", "%d.%m.%Y.") , STR_TO_DATE("23.2.2002.", "%d.%m.%Y.") ),
 ( 8008 , 10461 , 4 , STR_TO_DATE("27.9.1997.", "%d.%m.%Y.") , STR_TO_DATE("15.12.2000.", "%d.%m.%Y.") ),
 ( 8009 , 10048 , 7 , STR_TO_DATE("3.7.2012.", "%d.%m.%Y.") , STR_TO_DATE("12.7.2013.", "%d.%m.%Y.") ),
 ( 8010 , 10302 , 11 , STR_TO_DATE("13.11.2010.", "%d.%m.%Y.") , STR_TO_DATE("23.4.2010.", "%d.%m.%Y.") ),
 ( 8011 , 10617 , 3 , STR_TO_DATE("20.4.1994.", "%d.%m.%Y.") , STR_TO_DATE("11.9.2026.", "%d.%m.%Y.") ),
 ( 8012 , 10081 , 1 , STR_TO_DATE("25.2.2008.", "%d.%m.%Y.") , STR_TO_DATE("17.5.2014.", "%d.%m.%Y.") ),
 ( 8013 , 10730 , 4 , STR_TO_DATE("14.6.2013.", "%d.%m.%Y.") , STR_TO_DATE("13.3.2015.", "%d.%m.%Y.") ),
 ( 8014 , 10294 , 7 , STR_TO_DATE("15.2.2021.", "%d.%m.%Y.") , STR_TO_DATE("7.10.2004.", "%d.%m.%Y.") ),
 ( 8015 , 10508 , 14 , STR_TO_DATE("12.10.2008.", "%d.%m.%Y.") , STR_TO_DATE("9.9.2010.", "%d.%m.%Y.") ),
 ( 8016 , 10325 , 7 , STR_TO_DATE("14.11.2021.", "%d.%m.%Y.") , STR_TO_DATE("27.5.2001.", "%d.%m.%Y.") ),
 ( 8017 , 10002 , 12 , STR_TO_DATE("3.6.2015.", "%d.%m.%Y.") , STR_TO_DATE("10.2.1997.", "%d.%m.%Y.") ),
 ( 8018 , 10538 , 8 , STR_TO_DATE("26.5.2000.", "%d.%m.%Y.") , STR_TO_DATE("20.9.2006.", "%d.%m.%Y.") ),
 ( 8019 , 10680 , 9 , STR_TO_DATE("27.1.2005.", "%d.%m.%Y.") , STR_TO_DATE("1.7.2001.", "%d.%m.%Y.") ),
 ( 8020 , 10155 , 2 , STR_TO_DATE("14.3.2020.", "%d.%m.%Y.") , STR_TO_DATE("4.9.2013.", "%d.%m.%Y.") ),
 ( 8021 , 10862 , 8 , STR_TO_DATE("9.2.2022.", "%d.%m.%Y.") , STR_TO_DATE("26.2.2026.", "%d.%m.%Y.") ),
 ( 8022 , 10685 , 14 , STR_TO_DATE("27.10.2011.", "%d.%m.%Y.") , STR_TO_DATE("13.6.1999.", "%d.%m.%Y.") ),
 ( 8023 , 10247 , 11 , STR_TO_DATE("16.2.2028.", "%d.%m.%Y.") , STR_TO_DATE("22.8.2005.", "%d.%m.%Y.") ),
 ( 8024 , 10012 , 6 , STR_TO_DATE("25.5.2006.", "%d.%m.%Y.") , STR_TO_DATE("14.11.2027.", "%d.%m.%Y.") ),
 ( 8025 , 10443 , 1 , STR_TO_DATE("17.5.2011.", "%d.%m.%Y.") , STR_TO_DATE("28.12.2023.", "%d.%m.%Y.") ),
 ( 8026 , 10568 , 1 , STR_TO_DATE("16.9.1997.", "%d.%m.%Y.") , STR_TO_DATE("11.1.2018.", "%d.%m.%Y.") ),
 ( 8027 , 10195 , 5 , STR_TO_DATE("11.12.2020.", "%d.%m.%Y.") , STR_TO_DATE("9.11.2013.", "%d.%m.%Y.") ),
 ( 8028 , 10339 , 5 , STR_TO_DATE("7.6.2029.", "%d.%m.%Y.") , STR_TO_DATE("24.6.2008.", "%d.%m.%Y.") ),
 ( 8029 , 10157 , 13 , STR_TO_DATE("25.6.2004.", "%d.%m.%Y.") , STR_TO_DATE("3.9.1999.", "%d.%m.%Y.") ),
 ( 8030 , 10825 , 10 , STR_TO_DATE("11.9.2002.", "%d.%m.%Y.") , STR_TO_DATE("11.1.2012.", "%d.%m.%Y.") ),
 ( 8031 , 10296 , 10 , STR_TO_DATE("10.8.2004.", "%d.%m.%Y.") , STR_TO_DATE("26.10.2008.", "%d.%m.%Y.") ),
 ( 8032 , 10245 , 4 , STR_TO_DATE("25.12.2002.", "%d.%m.%Y.") , STR_TO_DATE("4.12.2020.", "%d.%m.%Y.") ),
 ( 8033 , 10701 , 5 , STR_TO_DATE("8.6.1994.", "%d.%m.%Y.") , STR_TO_DATE("5.8.2025.", "%d.%m.%Y.") ),
 ( 8034 , 10666 , 13 , STR_TO_DATE("28.12.1997.", "%d.%m.%Y.") , STR_TO_DATE("27.10.2006.", "%d.%m.%Y.") ),
 ( 8035 , 10817 , 14 , STR_TO_DATE("21.1.2015.", "%d.%m.%Y.") , STR_TO_DATE("3.10.2003.", "%d.%m.%Y.") ),
 ( 8036 , 10201 , 5 , STR_TO_DATE("20.8.2026.", "%d.%m.%Y.") , STR_TO_DATE("2.5.2005.", "%d.%m.%Y.") ),
 ( 8037 , 10574 , 11 , STR_TO_DATE("22.4.1995.", "%d.%m.%Y.") , STR_TO_DATE("22.8.2017.", "%d.%m.%Y.") ),
 ( 8038 , 10181 , 10 , STR_TO_DATE("15.8.1998.", "%d.%m.%Y.") , STR_TO_DATE("15.3.1995.", "%d.%m.%Y.") ),
 ( 8039 , 10494 , 9 , STR_TO_DATE("5.3.2030.", "%d.%m.%Y.") , STR_TO_DATE("28.5.2001.", "%d.%m.%Y.") ),
 ( 8040 , 10698 , 12 , STR_TO_DATE("9.10.2014.", "%d.%m.%Y.") , STR_TO_DATE("25.12.1998.", "%d.%m.%Y.") ),
 ( 8041 , 10527 , 14 , STR_TO_DATE("14.6.1999.", "%d.%m.%Y.") , STR_TO_DATE("9.6.2004.", "%d.%m.%Y.") ),
 ( 8042 , 10426 , 8 , STR_TO_DATE("6.6.2024.", "%d.%m.%Y.") , STR_TO_DATE("14.7.2030.", "%d.%m.%Y.") ),
 ( 8043 , 10676 , 7 , STR_TO_DATE("3.10.1997.", "%d.%m.%Y.") , STR_TO_DATE("16.3.2015.", "%d.%m.%Y.") ),
 ( 8044 , 10890 , 2 , STR_TO_DATE("3.8.2021.", "%d.%m.%Y.") , STR_TO_DATE("14.7.2024.", "%d.%m.%Y.") ),
 ( 8045 , 10367 , 10 , STR_TO_DATE("13.4.2017.", "%d.%m.%Y.") , STR_TO_DATE("7.10.2000.", "%d.%m.%Y.") ),
 ( 8046 , 10856 , 6 , STR_TO_DATE("1.12.2002.", "%d.%m.%Y.") , STR_TO_DATE("25.10.2023.", "%d.%m.%Y.") ),
 ( 8047 , 10572 , 1 , STR_TO_DATE("6.8.1996.", "%d.%m.%Y.") , STR_TO_DATE("12.10.2019.", "%d.%m.%Y.") ),
 ( 8048 , 10620 , 9 , STR_TO_DATE("27.11.2009.", "%d.%m.%Y.") , STR_TO_DATE("5.10.2029.", "%d.%m.%Y.") ),
 ( 8049 , 10415 , 4 , STR_TO_DATE("28.4.1996.", "%d.%m.%Y.") , STR_TO_DATE("22.8.2002.", "%d.%m.%Y.") ),
 ( 8050 , 10199 , 1 , STR_TO_DATE("23.9.2001.", "%d.%m.%Y.") , STR_TO_DATE("14.1.2019.", "%d.%m.%Y.") ),
 ( 8051 , 10131 , 2 , STR_TO_DATE("3.4.2022.", "%d.%m.%Y.") , STR_TO_DATE("6.7.2026.", "%d.%m.%Y.") ),
 ( 8052 , 10376 , 2 , STR_TO_DATE("11.10.2026.", "%d.%m.%Y.") , STR_TO_DATE("15.10.2022.", "%d.%m.%Y.") ),
 ( 8053 , 10310 , 11 , STR_TO_DATE("22.7.2014.", "%d.%m.%Y.") , STR_TO_DATE("12.4.2007.", "%d.%m.%Y.") ),
 ( 8054 , 10052 , 12 , STR_TO_DATE("15.3.2028.", "%d.%m.%Y.") , STR_TO_DATE("13.7.2018.", "%d.%m.%Y.") ),
 ( 8055 , 10861 , 13 , STR_TO_DATE("27.10.2020.", "%d.%m.%Y.") , STR_TO_DATE("14.10.2026.", "%d.%m.%Y.") ),
 ( 8056 , 10895 , 1 , STR_TO_DATE("13.5.2001.", "%d.%m.%Y.") , STR_TO_DATE("10.2.2023.", "%d.%m.%Y.") ),
 ( 8057 , 10001 , 4 , STR_TO_DATE("16.11.2009.", "%d.%m.%Y.") , STR_TO_DATE("17.1.2026.", "%d.%m.%Y.") ),
 ( 8058 , 10760 , 13 , STR_TO_DATE("1.8.2011.", "%d.%m.%Y.") , STR_TO_DATE("11.5.2022.", "%d.%m.%Y.") ),
 ( 8059 , 10698 , 3 , STR_TO_DATE("9.5.2000.", "%d.%m.%Y.") , STR_TO_DATE("1.7.2022.", "%d.%m.%Y.") ),
 ( 8060 , 10023 , 1 , STR_TO_DATE("2.10.1991.", "%d.%m.%Y.") , STR_TO_DATE("22.12.1993.", "%d.%m.%Y.") ),
 ( 8061 , 10817 , 13 , STR_TO_DATE("3.10.2026.", "%d.%m.%Y.") , STR_TO_DATE("18.1.2004.", "%d.%m.%Y.") ),
 ( 8062 , 10731 , 13 , STR_TO_DATE("3.2.2025.", "%d.%m.%Y.") , STR_TO_DATE("7.3.2015.", "%d.%m.%Y.") ),
 ( 8063 , 10784 , 4 , STR_TO_DATE("24.9.2013.", "%d.%m.%Y.") , STR_TO_DATE("22.11.2017.", "%d.%m.%Y.") ),
 ( 8064 , 10659 , 10 , STR_TO_DATE("16.2.2002.", "%d.%m.%Y.") , STR_TO_DATE("11.9.2000.", "%d.%m.%Y.") ),
 ( 8065 , 10478 , 2 , STR_TO_DATE("2.12.1993.", "%d.%m.%Y.") , STR_TO_DATE("6.11.2024.", "%d.%m.%Y.") ),
 ( 8066 , 10374 , 4 , STR_TO_DATE("14.3.2027.", "%d.%m.%Y.") , STR_TO_DATE("24.8.2006.", "%d.%m.%Y.") ),
 ( 8067 , 10497 , 3 , STR_TO_DATE("9.4.2021.", "%d.%m.%Y.") , STR_TO_DATE("20.6.2007.", "%d.%m.%Y.") ),
 ( 8068 , 10216 , 13 , STR_TO_DATE("17.8.2024.", "%d.%m.%Y.") , STR_TO_DATE("9.9.2018.", "%d.%m.%Y.") ),
 ( 8069 , 10568 , 6 , STR_TO_DATE("13.1.1998.", "%d.%m.%Y.") , STR_TO_DATE("21.8.2025.", "%d.%m.%Y.") ),
 ( 8070 , 10256 , 11 , STR_TO_DATE("20.12.1991.", "%d.%m.%Y.") , STR_TO_DATE("8.8.2004.", "%d.%m.%Y.") ),
 ( 8071 , 10512 , 14 , STR_TO_DATE("25.5.2015.", "%d.%m.%Y.") , STR_TO_DATE("6.8.2026.", "%d.%m.%Y.") ),
 ( 8072 , 10030 , 8 , STR_TO_DATE("8.12.2018.", "%d.%m.%Y.") , STR_TO_DATE("2.8.2003.", "%d.%m.%Y.") ),
 ( 8073 , 10209 , 11 , STR_TO_DATE("16.5.2001.", "%d.%m.%Y.") , STR_TO_DATE("2.5.2030.", "%d.%m.%Y.") ),
 ( 8074 , 10004 , 8 , STR_TO_DATE("5.8.2017.", "%d.%m.%Y.") , STR_TO_DATE("25.6.2015.", "%d.%m.%Y.") ),
 ( 8075 , 10472 , 5 , STR_TO_DATE("2.3.1996.", "%d.%m.%Y.") , STR_TO_DATE("8.6.1998.", "%d.%m.%Y.") ),
 ( 8076 , 10257 , 7 , STR_TO_DATE("27.11.2023.", "%d.%m.%Y.") , STR_TO_DATE("15.3.2026.", "%d.%m.%Y.") ),
 ( 8077 , 10436 , 6 , STR_TO_DATE("25.1.1999.", "%d.%m.%Y.") , STR_TO_DATE("4.4.2001.", "%d.%m.%Y.") ),
 ( 8078 , 10782 , 1 , STR_TO_DATE("28.4.2016.", "%d.%m.%Y.") , STR_TO_DATE("3.8.2010.", "%d.%m.%Y.") ),
 ( 8079 , 10478 , 14 , STR_TO_DATE("19.4.2029.", "%d.%m.%Y.") , STR_TO_DATE("5.5.2017.", "%d.%m.%Y.") ),
 ( 8080 , 10937 , 14 , STR_TO_DATE("8.8.1999.", "%d.%m.%Y.") , STR_TO_DATE("10.1.2009.", "%d.%m.%Y.") ),
 ( 8081 , 10761 , 3 , STR_TO_DATE("14.6.1999.", "%d.%m.%Y.") , STR_TO_DATE("13.6.2015.", "%d.%m.%Y.") ),
 ( 8082 , 10989 , 10 , STR_TO_DATE("11.1.2014.", "%d.%m.%Y.") , STR_TO_DATE("8.12.2016.", "%d.%m.%Y.") ),
 ( 8083 , 10223 , 8 , STR_TO_DATE("15.7.2012.", "%d.%m.%Y.") , STR_TO_DATE("20.1.2012.", "%d.%m.%Y.") ),
 ( 8084 , 10537 , 2 , STR_TO_DATE("7.5.2004.", "%d.%m.%Y.") , STR_TO_DATE("13.4.1999.", "%d.%m.%Y.") ),
 ( 8085 , 10585 , 1 , STR_TO_DATE("7.9.2023.", "%d.%m.%Y.") , STR_TO_DATE("4.6.2019.", "%d.%m.%Y.") ),
 ( 8086 , 10424 , 14 , STR_TO_DATE("2.12.2028.", "%d.%m.%Y.") , STR_TO_DATE("11.9.2006.", "%d.%m.%Y.") ),
 ( 8087 , 10404 , 7 , STR_TO_DATE("25.1.2006.", "%d.%m.%Y.") , STR_TO_DATE("8.7.2022.", "%d.%m.%Y.") ),
 ( 8088 , 10785 , 1 , STR_TO_DATE("7.1.2029.", "%d.%m.%Y.") , STR_TO_DATE("15.9.2002.", "%d.%m.%Y.") ),
 ( 8089 , 10236 , 2 , STR_TO_DATE("13.9.2007.", "%d.%m.%Y.") , STR_TO_DATE("10.6.2030.", "%d.%m.%Y.") ),
 ( 8090 , 10857 , 8 , STR_TO_DATE("23.4.2027.", "%d.%m.%Y.") , STR_TO_DATE("14.5.1994.", "%d.%m.%Y.") ),
 ( 8091 , 10732 , 8 , STR_TO_DATE("5.7.2028.", "%d.%m.%Y.") , STR_TO_DATE("22.8.2009.", "%d.%m.%Y.") ),
 ( 8092 , 10082 , 11 , STR_TO_DATE("13.1.1994.", "%d.%m.%Y.") , STR_TO_DATE("9.8.2026.", "%d.%m.%Y.") ),
 ( 8093 , 10658 , 2 , STR_TO_DATE("8.10.2027.", "%d.%m.%Y.") , STR_TO_DATE("13.6.1995.", "%d.%m.%Y.") ),
 ( 8094 , 10751 , 4 , STR_TO_DATE("19.4.1997.", "%d.%m.%Y.") , STR_TO_DATE("13.8.2014.", "%d.%m.%Y.") ),
 ( 8095 , 10611 , 8 , STR_TO_DATE("27.3.2018.", "%d.%m.%Y.") , STR_TO_DATE("16.8.2006.", "%d.%m.%Y.") ),
 ( 8096 , 10553 , 6 , STR_TO_DATE("14.10.2018.", "%d.%m.%Y.") , STR_TO_DATE("8.8.2027.", "%d.%m.%Y.") ),
 ( 8097 , 10166 , 4 , STR_TO_DATE("13.10.2005.", "%d.%m.%Y.") , STR_TO_DATE("28.7.2020.", "%d.%m.%Y.") ),
 ( 8098 , 10378 , 11 , STR_TO_DATE("9.1.2000.", "%d.%m.%Y.") , STR_TO_DATE("25.11.2014.", "%d.%m.%Y.") ),
 ( 8099 , 10509 , 5 , STR_TO_DATE("12.1.1996.", "%d.%m.%Y.") , STR_TO_DATE("1.12.2013.", "%d.%m.%Y.") ),
 ( 8100 , 10673 , 9 , STR_TO_DATE("20.3.2007.", "%d.%m.%Y.") , STR_TO_DATE("21.10.1993.", "%d.%m.%Y.") );




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

INSERT INTO vozilo_na_misiji VALUES
 ( 9000 , 2020 , 6 , 3019 ),
 ( 9001 , 2016 , 6 , 3005 ),
 ( 9002 , 2006 , 5 , 3033 ),
 ( 9003 , 2006 , 1 , 3047 ),
 ( 9004 , 2001 , 1 , 3002 ),
 ( 9005 , 2019 , 1 , 3022 ),
 ( 9006 , 2012 , 2 , 3043 ),
 ( 9007 , 2000 , 1 , 3010 ),
 ( 9008 , 2016 , 4 , 3009 ),
 ( 9009 , 2005 , 5 , 3012 ),
 ( 9010 , 2014 , 2 , 3048 ),
 ( 9011 , 2013 , 2 , 3027 ),
 ( 9012 , 2006 , 2 , 3051 ),
 ( 9013 , 2018 , 1 , 3018 ),
 ( 9014 , 2013 , 3 , 3003 ),
 ( 9015 , 2020 , 3 , 3045 ),
 ( 9016 , 2018 , 3 , 3006 ),
 ( 9017 , 2004 , 6 , 3029 ),
 ( 9018 , 2004 , 7 , 3045 ),
 ( 9019 , 2000 , 2 , 3013 ),
 ( 9020 , 2011 , 6 , 3052 ),
 ( 9021 , 2001 , 2 , 3016 ),
 ( 9022 , 2010 , 6 , 3007 ),
 ( 9023 , 2007 , 3 , 3049 ),
 ( 9024 , 2012 , 5 , 3021 ),
 ( 9025 , 2020 , 4 , 3001 ),
 ( 9026 , 2005 , 5 , 3021 ),
 ( 9027 , 2006 , 6 , 3015 ),
 ( 9028 , 2002 , 7 , 3020 ),
 ( 9029 , 2019 , 4 , 3023 );

INSERT INTO vozilo_na_turi VALUES
 ( 7001 , 2007 , 10 , 8052 , 1 ),
 ( 7002 , 2001 , 10 , 8044 , 9 ),
 ( 7003 , 2013 , 5 , 8002 , 7 ),
 ( 7004 , 2016 , 12 , 8020 , 4 ),
 ( 7005 , 2003 , 5 , 8074 , 9 ),
 ( 7006 , 2019 , 4 , 8061 , 17 ),
 ( 7007 , 2015 , 9 , 8046 , 4 ),
 ( 7008 , 2007 , 3 , 8036 , 9 ),
 ( 7009 , 2005 , 10 , 8084 , 3 ),
 ( 7010 , 2000 , 6 , 8003 , 6 ),
 ( 7011 , 2012 , 6 , 8064 , 8 ),
 ( 7012 , 2019 , 4 , 8034 , 10 ),
 ( 7013 , 2013 , 12 , 8095 , 8 ),
 ( 7014 , 2000 , 13 , 8048 , 7 ),
 ( 7015 , 2004 , 10 , 8079 , 12 ),
 ( 7016 , 2020 , 5 , 8065 , 1 ),
 ( 7017 , 2008 , 13 , 8035 , 4 ),
 ( 7018 , 2000 , 14 , 8070 , 12 ),
 ( 7019 , 2009 , 7 , 8025 , 12 ),
 ( 7020 , 2012 , 5 , 8075 , 8 ),
 ( 7021 , 2017 , 7 , 8072 , 11 ),
 ( 7022 , 2011 , 8 , 8016 , 17 ),
 ( 7023 , 2020 , 10 , 8069 , 10 ),
 ( 7024 , 2008 , 4 , 8034 , 10 ),
 ( 7025 , 2004 , 3 , 8021 , 13 ),
 ( 7026 , 2008 , 7 , 8005 , 2 ),
 ( 7027 , 2004 , 14 , 8098 , 4 ),
 ( 7028 , 2005 , 11 , 8027 , 4 ),
 ( 7029 , 2008 , 8 , 8035 , 2 ),
 ( 7030 , 2009 , 4 , 8068 , 6 );

INSERT INTO popravak VALUES
 ( 6001 , 9019 , "Vozilu je potrebna kompletna restauracija" , STR_TO_DATE("2.11.1992.", "%d.%m.%Y.") , STR_TO_DATE("9.3.2024.", "%d.%m.%Y.") , 235475 ),
 ( 6002 , 9018 , "Potrebni mali popravci" , STR_TO_DATE("14.11.2030.", "%d.%m.%Y.") , STR_TO_DATE("25.3.2026.", "%d.%m.%Y.") , 429969 ),
 ( 6003 , 9005 , "Popravci na rubu neisplativosti" , STR_TO_DATE("9.3.1993.", "%d.%m.%Y.") , STR_TO_DATE("12.12.2023.", "%d.%m.%Y.") , 374594 ),
 ( 6004 , 9006 , "Popravci na rubu neisplativosti" , STR_TO_DATE("10.2.2027.", "%d.%m.%Y.") , STR_TO_DATE("24.3.2025.", "%d.%m.%Y.") , 303429 ),
 ( 6005 , 9009 , "Vozilu je potrebna kompletna restauracija" , STR_TO_DATE("14.10.2015.", "%d.%m.%Y.") , STR_TO_DATE("19.1.2008.", "%d.%m.%Y.") , 299849 ),
 ( 6006 , 9003 , "Popravci na rubu neisplativosti" , STR_TO_DATE("22.7.2028.", "%d.%m.%Y.") , STR_TO_DATE("17.12.2018.", "%d.%m.%Y.") , 472183 ),
 ( 6007 , 9017 , "Manja šteta na oklopu i manji popravci" , STR_TO_DATE("25.12.2017.", "%d.%m.%Y.") , STR_TO_DATE("23.9.2007.", "%d.%m.%Y.") , 345516 ),
 ( 6008 , 9003 , "Popravci na rubu neisplativosti" , STR_TO_DATE("18.3.2030.", "%d.%m.%Y.") , STR_TO_DATE("3.7.2005.", "%d.%m.%Y.") , 339466 ),
 ( 6009 , 9016 , "Vozilo nije u voznome stanju" , STR_TO_DATE("5.3.2022.", "%d.%m.%Y.") , STR_TO_DATE("11.8.2006.", "%d.%m.%Y.") , 202165 ),
 ( 6010 , 9012 , "Vozilo nije u voznome stanju" , STR_TO_DATE("18.8.1996.", "%d.%m.%Y.") , STR_TO_DATE("2.12.2019.", "%d.%m.%Y.") , 247772 ),
 ( 6011 , 9019 , "Popravci na rubu neisplativosti" , STR_TO_DATE("23.6.2024.", "%d.%m.%Y.") , STR_TO_DATE("18.7.2005.", "%d.%m.%Y.") , 253430 ),
 ( 6012 , 9003 , "Vozilu je potrebna kompletna restauracija" , STR_TO_DATE("14.9.2024.", "%d.%m.%Y.") , STR_TO_DATE("7.9.2029.", "%d.%m.%Y.") , 267460 ),
 ( 6013 , 9005 , "Popravci na rubu neisplativosti" , STR_TO_DATE("13.2.1997.", "%d.%m.%Y.") , STR_TO_DATE("17.6.1999.", "%d.%m.%Y.") , 367066 ),
 ( 6014 , 9006 , "Manja šteta na oklopu i manji popravci" , STR_TO_DATE("20.10.2028.", "%d.%m.%Y.") , STR_TO_DATE("6.9.2004.", "%d.%m.%Y.") , 356967 ),
 ( 6015 , 9007 , "Popravci na rubu neisplativosti" , STR_TO_DATE("13.8.2004.", "%d.%m.%Y.") , STR_TO_DATE("8.2.2001.", "%d.%m.%Y.") , 482278 ),
 ( 6016 , 9020 , "Potrebni mali popravci" , STR_TO_DATE("1.9.2008.", "%d.%m.%Y.") , STR_TO_DATE("28.5.2011.", "%d.%m.%Y.") , 324646 ),
 ( 6017 , 9018 , "Vozilo nije u voznome stanju" , STR_TO_DATE("28.10.2030.", "%d.%m.%Y.") , STR_TO_DATE("21.2.2027.", "%d.%m.%Y.") , 220281 ),
 ( 6018 , 9006 , "Manja šteta na oklopu i manji popravci" , STR_TO_DATE("9.1.2003.", "%d.%m.%Y.") , STR_TO_DATE("12.12.1994.", "%d.%m.%Y.") , 213060 ),
 ( 6019 , 9004 , "Potrebni mali popravci" , STR_TO_DATE("14.3.2022.", "%d.%m.%Y.") , STR_TO_DATE("1.2.2007.", "%d.%m.%Y.") , 277448 ),
 ( 6020 , 9016 , "Popravci na rubu neisplativosti" , STR_TO_DATE("3.2.2029.", "%d.%m.%Y.") , STR_TO_DATE("5.12.2020.", "%d.%m.%Y.") , 441037 );



INSERT INTO oprema VALUES
(1301, "HS Produkt HS", "Samokres", 40000),
(1302, "HS Produkt SF", "Samokres", 20000),
(1303, "Heckler & Koch USP", "Samokres", 10000),
(1304, "Heckler & Koch MP7", "Strojnica", 80),
(1305, "Heckler & Koch UMP", "Strojnica", 100),
(1306, "Heckler & Koch MP5", "Strojnica", 100),
(1307, "ERO", "Strojnica", 500),
(1308, "HS Produkt VHS-2", "Jurišna strojnica", 20000),
(1309, "HS Produkt VHS", "Jurišna strojnica", 7800),
(1310, "Heckler & Koch G-36", "Jurišna strojnica", 750),
(1311, "Heckler & Koch HK416", "Jurišna strojnica", 250),
(1312, "FN F2000", "Jurišna strojnica", 100),
(1313, "Zastava M70", "Jurišna strojnica", 88640),
(1314, "PM md. 63/65", "Jurišna strojnica", 3420),
(1315, "FN Minimi", "Puškostrojnica", 100),
(1316, "FN MAG", "Puškostrojnica", 400),
(1317, "Ultimax 100", "Puškostrojnica", 100),
(1318, "Heckler & Koch HK21", "Puškostrojnica", 300),
(1319, "Zastava M84", "Puškostrojnica", 1400),
(1320, "Browning M2", "Puškostrojnica", 700),
(1321, "Heckler & Koch HK417", "Snajperska puška", 250),
(1322, "Remington M40", "Snajperska puška", 70),
(1323, "SAKO TRG-42", "Snajperska puška", 240),
(1324, "MACS M3", "Snajperska puška", 20),
(1325, "Barrett M82", "Snajperska puška", 24),
(1326, "RT-20", "Snajperska puška", 4),
(1327, "Franchi SPAS-12", "Sačmarica", 100),
(1328, "Benelli M4 Super 90", "Sačmarica", 250),
(1329, "Heckler & Koch AG36", "Bacač granata", 300),
(1330, "RBG-6", "Bacač granata", 124),
(1331, "Mk 19 bacač granata", "Bacač granata", 92),
(1332, "Spike LR2", "Protuoklopno naoružanje || ATGM", 16),
(1333, "FGM-148 Javelin", "Protuoklopno naoružanje || ATGM", 5),
(1334, "BGM-71 TOW-2", "Protuoklopno naoružanje || ATGM", 134),
(1335, "9K115-2 Metis-M", "Protuoklopno naoružanje || ATGM", 54),
(1336, "9M113 Konkurs", "Protuoklopno naoružanje || ATGM", 42),
(1337, "9M111 Fagot", "Protuoklopno naoružanje || ATGM", 119),
(1338, "9M14 Maljutka", "Protuoklopno naoružanje || ATGM", 216),
(1339, "RPG-22", "Protuoklopno naoružanje || RPG", 300),
(1340, "AT4", "Protuoklopno naoružanje || RPG", 55),
(1341, "M57", "Minobacač", 69),
(1342, "M96", "Minobacač", 69),
(1343, "M75", "Minobacač", 43),
(1344, "Thales SSARF", "Daljinometar", 20),
(1345, "Safran Jim Compact", "Daljinometar", 30),
(1346, "SAGEM Sigma 30", "Oprema za navigaciju", 20),
(1347, "Kongsberg EriTac", "Oprema za komunikaciju", 10),
(1348, "Saab Giraffe M85", "Oprema za komunikaciju", 2),
(1349, "Aeronautics Orbiter", "UAV || Letjelica", 6),
(1350, "Elbit Skylark", "UAV || Letjelica", 20),
(1351, "DJI Matrice 600", "UAV || Dron", 15),
(1352, "DJI Mavic 2", "UAV || Dron", 10),
(1353, "Med-Eng EOD 9 Odjelo", "Protueksplozivna oprema", 5),
(1354, "DOK-ING MV-4 Robot/Čistač mina", "Protueksplozivna oprema", 4),
(1355, "Telerob tEODor Robot", "Protueksplozivna oprema", 2),
(1356, "Alaska vojni šatori", "Prijenosna struktura", 50),
(1357, "Role 2B / Vojna terenska bolnica", "Prijenosna struktura", 1),
(1358, "ACH balistična kaciga", "Osobna zaštitna oprema", 5000),
(1359, "Kroko vojna pancirka", "Osobna zaštitna oprema", 5000),
(1360, "Standardna vojna uniforma", "Osobna zaštitna oprema", 2000),
(1361, "Veliki vojni ruksak", "Ruksak", 1100),
(1362, "Mali vojni ruksak", "Ruksak", 1920),
(1363, "Vojne čizme Jelen", "Osobna zaštitna oprema", 2500);



INSERT INTO izdana_oprema VALUES
 ( 5001 , 1311 , 4002 , 1 ),
 ( 5003 , 1303 , 4004 , 1 ),
 ( 5005 , 1318 , 4006 , 1 ),
 ( 5007 , 1358 , 4008 , 1 ),
 ( 5009 , 1362 , 4010 , 1 ),
 ( 5011 , 1315 , 4012 , 1 ),
 ( 5013 , 1328 , 4014 , 1 ),
 ( 5015 , 1348 , 4016 , 1 ),
 ( 5017 , 1341 , 4018 , 1 ),
 ( 5019 , 1310 , 4020 , 1 ),
 ( 5021 , 1315 , 4022 , 1 ),
 ( 5023 , 1320 , 4024 , 1 ),
 ( 5025 , 1339 , 4026 , 1 ),
 ( 5027 , 1325 , 4028 , 1 ),
 ( 5029 , 1327 , 4030 , 1 ),
 ( 5031 , 1324 , 4032 , 1 ),
 ( 5033 , 1303 , 4034 , 1 ),
 ( 5035 , 1325 , 4036 , 1 ),
 ( 5037 , 1359 , 4038 , 1 ),
 ( 5039 , 1305 , 4040 , 1 ),
 ( 5041 , 1315 , 4042 , 1 ),
 ( 5043 , 1353 , 4044 , 1 ),
 ( 5045 , 1310 , 4046 , 1 ),
 ( 5047 , 1311 , 4048 , 1 ),
 ( 5049 , 1337 , 4050 , 1 ),
 ( 5051 , 1325 , 4052 , 1 ),
 ( 5053 , 1306 , 4054 , 1 ),
 ( 5055 , 1346 , 4056 , 1 ),
 ( 5057 , 1341 , 4058 , 1 ),
 ( 5059 , 1363 , 4060 , 1 ),
 ( 5061 , 1344 , 4062 , 1 ),
 ( 5063 , 1345 , 4064 , 1 ),
 ( 5065 , 1313 , 4066 , 1 ),
 ( 5067 , 1342 , 4068 , 1 ),
 ( 5069 , 1317 , 4070 , 1 ),
 ( 5071 , 1360 , 4072 , 1 ),
 ( 5073 , 1358 , 4074 , 1 ),
 ( 5075 , 1356 , 4076 , 1 ),
 ( 5077 , 1341 , 4078 , 1 ),
 ( 5079 , 1326 , 4080 , 1 ),
 ( 5081 , 1301 , 4082 , 1 ),
 ( 5083 , 1325 , 4084 , 1 ),
 ( 5085 , 1360 , 4086 , 1 ),
 ( 5087 , 1323 , 4088 , 1 ),
 ( 5089 , 1334 , 4090 , 1 ),
 ( 5091 , 1312 , 4092 , 1 ),
 ( 5093 , 1335 , 4094 , 1 ),
 ( 5095 , 1327 , 4096 , 1 ),
 ( 5097 , 1360 , 4098 , 1 ),
 ( 5099 , 1315 , 4000 , 1 ),
 ( 5101 , 1317 , 4002 , 1 ),
 ( 5103 , 1363 , 4004 , 1 ),
 ( 5105 , 1325 , 4006 , 1 ),
 ( 5107 , 1356 , 4008 , 1 ),
 ( 5109 , 1359 , 4010 , 1 ),
 ( 5111 , 1322 , 4012 , 1 ),
 ( 5113 , 1332 , 4014 , 1 ),
 ( 5115 , 1351 , 4016 , 1 ),
 ( 5117 , 1337 , 4018 , 1 ),
 ( 5119 , 1362 , 4020 , 1 ),
 ( 5121 , 1317 , 4022 , 1 ),
 ( 5123 , 1323 , 4024 , 1 ),
 ( 5125 , 1352 , 4026 , 1 ),
 ( 5127 , 1344 , 4028 , 1 ),
 ( 5129 , 1321 , 4030 , 1 ),
 ( 5131 , 1301 , 4032 , 1 ),
 ( 5133 , 1318 , 4034 , 1 ),
 ( 5135 , 1315 , 4036 , 1 ),
 ( 5137 , 1360 , 4038 , 1 ),
 ( 5139 , 1309 , 4040 , 1 ),
 ( 5141 , 1358 , 4042 , 1 ),
 ( 5143 , 1337 , 4044 , 1 ),
 ( 5145 , 1349 , 4046 , 1 ),
 ( 5147 , 1305 , 4048 , 1 ),
 ( 5149 , 1344 , 4050 , 1 ),
 ( 5151 , 1350 , 4052 , 1 ),
 ( 5153 , 1328 , 4054 , 1 ),
 ( 5155 , 1351 , 4056 , 1 ),
 ( 5157 , 1310 , 4058 , 1 ),
 ( 5159 , 1332 , 4060 , 1 ),
 ( 5161 , 1316 , 4062 , 1 ),
 ( 5163 , 1326 , 4064 , 1 ),
 ( 5165 , 1339 , 4066 , 1 ),
 ( 5167 , 1314 , 4068 , 1 ),
 ( 5169 , 1362 , 4070 , 1 ),
 ( 5171 , 1312 , 4072 , 1 ),
 ( 5173 , 1325 , 4074 , 1 ),
 ( 5175 , 1349 , 4076 , 1 ),
 ( 5177 , 1349 , 4078 , 1 ),
 ( 5179 , 1323 , 4080 , 1 ),
 ( 5181 , 1337 , 4082 , 1 ),
 ( 5183 , 1328 , 4084 , 1 ),
 ( 5185 , 1331 , 4086 , 1 ),
 ( 5187 , 1311 , 4088 , 1 ),
 ( 5189 , 1355 , 4090 , 1 ),
 ( 5191 , 1354 , 4092 , 1 ),
 ( 5193 , 1340 , 4094 , 1 ),
 ( 5195 , 1358 , 4096 , 1 ),
 ( 5197 , 1321 , 4098 , 1 ),
 ( 5199 , 1324 , 4000 , 1 );



INSERT INTO trening VALUES
 ( 1100 , STR_TO_DATE("20.7.1991.  4:9:55", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("14.7.1991.  2:14:36", "%d.%m.%Y. %H:%i:%s") , 35 , ""),
 ( 1101 , STR_TO_DATE("27.2.1995.  6:15:59", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("5.8.1999.  23:16:47", "%d.%m.%Y. %H:%i:%s") , 18 , ""),
 ( 1102 , STR_TO_DATE("22.5.1997.  4:31:41", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("5.11.2000.  3:48:37", "%d.%m.%Y. %H:%i:%s") , 27 , ""),
 ( 1103 , STR_TO_DATE("9.6.1994.  23:25:56", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("22.4.1993.  23:23:29", "%d.%m.%Y. %H:%i:%s") , 23 , ""),
 ( 1104 , STR_TO_DATE("19.11.1993.  4:43:36", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("25.10.1999.  17:37:18", "%d.%m.%Y. %H:%i:%s") , 39 ,"" ),
 ( 1105 , STR_TO_DATE("5.8.1998.  19:35:30", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("13.8.1991.  11:25:21", "%d.%m.%Y. %H:%i:%s") , 25 , ""),
 ( 1106 , STR_TO_DATE("19.1.1996.  12:5:20", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("22.10.1998.  20:43:49", "%d.%m.%Y. %H:%i:%s") , 21 , ""),
 ( 1107 , STR_TO_DATE("2.5.1994.  11:18:29", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("19.1.1992.  22:23:59", "%d.%m.%Y. %H:%i:%s") , 38 , ""),
 ( 1108 , STR_TO_DATE("1.1.1996.  23:42:3", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("28.8.1992.  10:30:35", "%d.%m.%Y. %H:%i:%s") , 34 , ""),
 ( 1109 , STR_TO_DATE("21.6.1993.  23:55:36", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("1.6.1991.  14:56:42", "%d.%m.%Y. %H:%i:%s") , 30 ,"" ),
 ( 1110 , STR_TO_DATE("20.1.1992.  1:37:10", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("7.1.2000.  18:45:6", "%d.%m.%Y. %H:%i:%s") , 40 , ""),
 ( 1111 , STR_TO_DATE("12.8.1995.  19:48:17", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("21.9.1991.  15:4:3", "%d.%m.%Y. %H:%i:%s") , 29 , ""),
 ( 1112 , STR_TO_DATE("16.10.1991.  16:57:7", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("3.5.1998.  21:3:38", "%d.%m.%Y. %H:%i:%s") , 17 , ""),
 ( 1113 , STR_TO_DATE("20.5.1995.  20:28:58", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("5.12.1996.  12:50:1", "%d.%m.%Y. %H:%i:%s") , 37 , ""),
 ( 1114 , STR_TO_DATE("21.11.1997.  16:23:43", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("12.4.1992.  22:10:22", "%d.%m.%Y. %H:%i:%s") , 29 ,"" ),
 ( 1115 , STR_TO_DATE("12.11.1996.  6:21:9", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("2.5.1999.  14:44:2", "%d.%m.%Y. %H:%i:%s") , 41 ,"" ),
 ( 1116 , STR_TO_DATE("20.3.1994.  8:8:50", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("14.7.1995.  8:5:55", "%d.%m.%Y. %H:%i:%s") , 41 , ""),
 ( 1117 , STR_TO_DATE("18.1.1998.  19:16:34", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("1.10.1996.  12:37:13", "%d.%m.%Y. %H:%i:%s") , 41 , ""),
 ( 1118 , STR_TO_DATE("23.10.1996.  5:17:41", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("28.2.2000.  9:25:56", "%d.%m.%Y. %H:%i:%s") , 22 ,"" ),
 ( 1119 , STR_TO_DATE("15.5.1993.  22:56:17", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("23.1.2000.  6:1:44", "%d.%m.%Y. %H:%i:%s") , 41 , ""),
 ( 1120 , STR_TO_DATE("27.10.1992.  21:7:48", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("16.8.1992.  5:30:37", "%d.%m.%Y. %H:%i:%s") , 23 , ""),
 ( 1121 , STR_TO_DATE("20.5.1994.  9:8:49", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("2.11.2000.  13:35:57", "%d.%m.%Y. %H:%i:%s") , 22 ,"" ),
 ( 1122 , STR_TO_DATE("5.7.1995.  22:40:32", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("6.12.1991.  11:2:9", "%d.%m.%Y. %H:%i:%s") , 41 , ""),
 ( 1123 , STR_TO_DATE("20.4.1996.  3:52:12", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("5.8.1993.  6:14:51", "%d.%m.%Y. %H:%i:%s") , 39 , ""),
 ( 1124 , STR_TO_DATE("1.2.1998.  9:25:31", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("17.11.1994.  9:30:11", "%d.%m.%Y. %H:%i:%s") , 23 , ""),
 ( 1125 , STR_TO_DATE("28.8.1998.  9:16:47", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("21.6.1991.  14:33:47", "%d.%m.%Y. %H:%i:%s") , 35 , ""),
 ( 1126 , STR_TO_DATE("7.1.1994.  15:20:27", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("13.10.1996.  13:23:6", "%d.%m.%Y. %H:%i:%s") , 41 , ""),
 ( 1127 , STR_TO_DATE("16.6.1998.  3:33:10", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("28.5.2000.  12:4:16", "%d.%m.%Y. %H:%i:%s") , 28 ,"" ),
 ( 1128 , STR_TO_DATE("4.4.2000.  13:2:15", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("2.5.1992.  1:51:5", "%d.%m.%Y. %H:%i:%s") , 39 , ""),
 ( 1129 , STR_TO_DATE("23.12.1994.  11:9:8", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("6.5.2000.  23:43:55", "%d.%m.%Y. %H:%i:%s") , 20 , ""),
 ( 1130 , STR_TO_DATE("16.10.2000.  3:56:34", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("27.5.2000.  6:21:30", "%d.%m.%Y. %H:%i:%s") , 26 , ""),
 ( 1131 , STR_TO_DATE("19.7.1998.  23:52:10", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("9.1.2000.  7:20:0", "%d.%m.%Y. %H:%i:%s") , 31 , ""),
 ( 1132 , STR_TO_DATE("25.4.1996.  23:10:57", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("8.3.2000.  8:54:27", "%d.%m.%Y. %H:%i:%s") , 40 , ""),
 ( 1133 , STR_TO_DATE("28.10.1994.  21:39:14", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("20.4.1994.  18:12:41", "%d.%m.%Y. %H:%i:%s") , 40 ,"" ),
 ( 1134 , STR_TO_DATE("4.3.1991.  11:25:59", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("16.3.1998.  5:35:19", "%d.%m.%Y. %H:%i:%s") , 34 ,"" ),
 ( 1135 , STR_TO_DATE("13.5.1998.  23:25:6", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("20.8.1991.  4:19:41", "%d.%m.%Y. %H:%i:%s") , 30 , ""),
 ( 1136 , STR_TO_DATE("15.3.1991.  21:30:22", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("19.1.1991.  5:48:10", "%d.%m.%Y. %H:%i:%s") , 36 , ""),
 ( 1137 , STR_TO_DATE("22.5.1993.  11:55:28", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("12.2.1995.  16:58:45", "%d.%m.%Y. %H:%i:%s") , 27 ,"" ),
 ( 1138 , STR_TO_DATE("26.2.1997.  7:17:39", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("12.5.1996.  23:40:8", "%d.%m.%Y. %H:%i:%s") , 40 , ""),
 ( 1139 , STR_TO_DATE("26.2.1997.  14:36:47", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("22.9.1996.  10:5:50", "%d.%m.%Y. %H:%i:%s") , 41 ,"" ),
 ( 1140 , STR_TO_DATE("23.5.1995.  22:23:54", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("9.8.1993.  15:6:12", "%d.%m.%Y. %H:%i:%s") , 40 ,"" ),
 ( 1141 , STR_TO_DATE("5.5.1996.  6:14:47", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("3.3.2000.  6:36:38", "%d.%m.%Y. %H:%i:%s") , 17 , ""),
 ( 1142 , STR_TO_DATE("4.12.1993.  14:23:23", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("23.11.1996.  9:30:29", "%d.%m.%Y. %H:%i:%s") , 41 ,"" ),
 ( 1143 , STR_TO_DATE("25.9.1994.  3:50:8", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("11.7.1992.  16:38:58", "%d.%m.%Y. %H:%i:%s") , 17 , ""),
 ( 1144 , STR_TO_DATE("14.10.2000.  3:28:3", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("6.8.1998.  14:46:54", "%d.%m.%Y. %H:%i:%s") , 41 , ""),
 ( 1145 , STR_TO_DATE("7.11.1999.  22:26:4", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("20.3.2000.  19:58:33", "%d.%m.%Y. %H:%i:%s") , 18 ,"" ),
 ( 1146 , STR_TO_DATE("19.2.1998.  1:37:15", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("23.7.1998.  7:32:23", "%d.%m.%Y. %H:%i:%s") , 23 , ""),
 ( 1147 , STR_TO_DATE("12.6.1991.  11:19:55", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("28.2.1999.  14:48:19", "%d.%m.%Y. %H:%i:%s") , 33 , ""),
 ( 1148 , STR_TO_DATE("12.9.1994.  5:28:31", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("13.10.1994.  12:26:38", "%d.%m.%Y. %H:%i:%s") , 19 ,"" ),
 ( 1149 , STR_TO_DATE("6.9.1991.  6:14:44", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("27.12.1999.  5:17:57", "%d.%m.%Y. %H:%i:%s") , 34 , ""),
 ( 1150 , STR_TO_DATE("16.6.1991.  12:57:7", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("16.4.1999.  15:59:44", "%d.%m.%Y. %H:%i:%s") , 17 , ""),
 ( 1151 , STR_TO_DATE("12.11.1992.  16:36:7", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("10.5.1997.  22:52:18", "%d.%m.%Y. %H:%i:%s") , 41 , ""),
 ( 1152 , STR_TO_DATE("18.12.1997.  16:30:51", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("8.1.1993.  19:0:52", "%d.%m.%Y. %H:%i:%s") , 41 , ""),
 ( 1153 , STR_TO_DATE("23.2.1995.  11:23:13", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("19.11.1993.  3:35:37", "%d.%m.%Y. %H:%i:%s") , 27 ,"" ),
 ( 1154 , STR_TO_DATE("13.5.1999.  6:56:6", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("20.10.1997.  22:40:16", "%d.%m.%Y. %H:%i:%s") , 28 , ""),
 ( 1155 , STR_TO_DATE("16.9.1997.  19:46:42", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("15.1.1997.  7:32:50", "%d.%m.%Y. %H:%i:%s") , 41 , ""),
 ( 1156 , STR_TO_DATE("7.4.1996.  20:9:5", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("20.12.1994.  11:6:50", "%d.%m.%Y. %H:%i:%s") , 23 , ""),
 ( 1157 , STR_TO_DATE("8.10.1998.  22:51:15", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("23.3.1993.  1:40:43", "%d.%m.%Y. %H:%i:%s") , 27 , ""),
 ( 1158 , STR_TO_DATE("10.1.1991.  23:33:32", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("2.6.1995.  8:18:50", "%d.%m.%Y. %H:%i:%s") , 34 , ""),
 ( 1159 , STR_TO_DATE("11.3.1993.  4:28:8", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("17.1.1991.  3:33:45", "%d.%m.%Y. %H:%i:%s") , 23 , ""),
 ( 1160 , STR_TO_DATE("17.3.1996.  2:27:22", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("12.9.1995.  11:21:31", "%d.%m.%Y. %H:%i:%s") , 34 ,"" ),
 ( 1161 , STR_TO_DATE("26.2.1995.  16:20:34", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("8.9.1991.  22:15:42", "%d.%m.%Y. %H:%i:%s") , 29 ,"" ),
 ( 1162 , STR_TO_DATE("1.7.1998.  8:39:0", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("6.6.1992.  1:53:50", "%d.%m.%Y. %H:%i:%s") , 18 , ""),
 ( 1163 , STR_TO_DATE("23.8.1992.  16:30:29", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("1.2.1996.  6:37:15", "%d.%m.%Y. %H:%i:%s") , 30 , ""),
 ( 1164 , STR_TO_DATE("12.6.1992.  7:10:53", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("11.11.1993.  12:25:26", "%d.%m.%Y. %H:%i:%s") , 32 ,"" ),
 ( 1165 , STR_TO_DATE("6.4.1993.  8:22:41", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("19.9.1996.  4:25:15", "%d.%m.%Y. %H:%i:%s") , 27 , ""),
 ( 1166 , STR_TO_DATE("18.12.1996.  17:59:58", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("2.1.1994.  23:6:41", "%d.%m.%Y. %H:%i:%s") , 34 , ""),
 ( 1167 , STR_TO_DATE("21.11.1994.  21:21:53", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("27.6.1992.  2:55:20", "%d.%m.%Y. %H:%i:%s") , 23 , ""),
 ( 1168 , STR_TO_DATE("11.8.1999.  19:22:16", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("17.8.1995.  19:12:44", "%d.%m.%Y. %H:%i:%s") , 30 ,"" ),
 ( 1169 , STR_TO_DATE("17.10.2000.  5:5:4", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("18.4.1995.  6:15:2", "%d.%m.%Y. %H:%i:%s") , 23 , ""),
 ( 1170 , STR_TO_DATE("11.10.1997.  9:20:43", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("27.1.1992.  2:18:19", "%d.%m.%Y. %H:%i:%s") , 17 , ""),
 ( 1171 , STR_TO_DATE("19.9.1991.  18:7:9", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("27.12.1996.  12:47:10", "%d.%m.%Y. %H:%i:%s") , 31 , ""),
 ( 1172 , STR_TO_DATE("23.6.1994.  13:16:23", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("23.10.1994.  4:31:11", "%d.%m.%Y. %H:%i:%s") , 21 , ""),
 ( 1173 , STR_TO_DATE("8.7.1995.  20:2:22", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("14.2.1998.  11:58:54", "%d.%m.%Y. %H:%i:%s") , 17 , ""),
 ( 1174 , STR_TO_DATE("21.1.1992.  4:33:2", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("25.1.2000.  1:50:14", "%d.%m.%Y. %H:%i:%s") , 34 , ""),
 ( 1175 , STR_TO_DATE("17.4.1999.  15:36:55", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("26.4.1992.  14:48:20", "%d.%m.%Y. %H:%i:%s") , 17 ,"" ),
 ( 1176 , STR_TO_DATE("11.8.1997.  6:55:33", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("22.8.1993.  5:17:41", "%d.%m.%Y. %H:%i:%s") , 23 ,"" ),
 ( 1177 , STR_TO_DATE("20.12.1997.  8:8:9", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("1.11.1993.  9:14:9", "%d.%m.%Y. %H:%i:%s") , 33 , ""),
 ( 1178 , STR_TO_DATE("4.2.1992.  12:48:4", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("26.12.1999.  6:53:23", "%d.%m.%Y. %H:%i:%s") , 28 , ""),
 ( 1179 , STR_TO_DATE("18.8.1998.  20:3:1", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("26.11.1991.  16:37:9", "%d.%m.%Y. %H:%i:%s") , 39 , ""),
 ( 1180 , STR_TO_DATE("21.12.1998.  11:21:2", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("10.9.1991.  17:46:43", "%d.%m.%Y. %H:%i:%s") , 23 ,"" ),
 ( 1181 , STR_TO_DATE("21.8.1993.  12:2:34", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("19.5.2000.  13:28:31", "%d.%m.%Y. %H:%i:%s") , 40 ,"" ),
 ( 1182 , STR_TO_DATE("8.7.1994.  4:1:4", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("18.3.1994.  18:59:39", "%d.%m.%Y. %H:%i:%s") , 35 , ""),
 ( 1183 , STR_TO_DATE("21.11.1998.  23:42:5", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("26.11.1993.  14:19:40", "%d.%m.%Y. %H:%i:%s") , 23 ,"" ),
 ( 1184 , STR_TO_DATE("7.2.1995.  13:7:52", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("22.10.1998.  23:52:4", "%d.%m.%Y. %H:%i:%s") , 31 , ""),
 ( 1185 , STR_TO_DATE("10.12.1995.  17:10:58", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("16.12.1995.  17:25:29", "%d.%m.%Y. %H:%i:%s") , 23 ,"" ),
 ( 1186 , STR_TO_DATE("1.2.2000.  13:15:16", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("16.10.1992.  18:46:37", "%d.%m.%Y. %H:%i:%s") , 32 , ""),
 ( 1187 , STR_TO_DATE("21.8.1991.  16:23:30", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("1.3.1995.  22:56:27", "%d.%m.%Y. %H:%i:%s") , 17 , ""),
 ( 1188 , STR_TO_DATE("11.9.1991.  6:52:17", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("15.9.1994.  18:9:25", "%d.%m.%Y. %H:%i:%s") , 41 , ""),
 ( 1189 , STR_TO_DATE("15.2.1993.  3:39:53", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("1.9.1999.  15:25:59", "%d.%m.%Y. %H:%i:%s") , 20 , ""),
 ( 1190 , STR_TO_DATE("5.6.1998.  11:14:52", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("1.6.2000.  16:14:1", "%d.%m.%Y. %H:%i:%s") , 31 , ""),
 ( 1191 , STR_TO_DATE("5.5.1997.  23:32:1", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("20.1.1993.  4:49:19", "%d.%m.%Y. %H:%i:%s") , 33 , ""),
 ( 1192 , STR_TO_DATE("8.7.1999.  7:42:45", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("18.4.1998.  18:13:31", "%d.%m.%Y. %H:%i:%s") , 29 , ""),
 ( 1193 , STR_TO_DATE("21.10.1998.  3:12:39", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("16.10.1995.  2:37:37", "%d.%m.%Y. %H:%i:%s") , 30 ,"" ),
 ( 1194 , STR_TO_DATE("6.4.1999.  1:53:1", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("23.8.1994.  17:13:30", "%d.%m.%Y. %H:%i:%s") , 17 , ""),
 ( 1195 , STR_TO_DATE("13.2.1991.  6:30:50", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("10.3.1999.  23:18:35", "%d.%m.%Y. %H:%i:%s") , 41 ,"" ),
 ( 1196 , STR_TO_DATE("28.10.1994.  21:13:0", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("13.10.1992.  13:21:47", "%d.%m.%Y. %H:%i:%s") , 22 ,"" ),
 ( 1197 , STR_TO_DATE("15.12.1999.  10:8:59", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("5.4.1998.  1:46:44", "%d.%m.%Y. %H:%i:%s") , 40 ,"" ),
 ( 1198 , STR_TO_DATE("4.9.2000.  6:42:53", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("20.6.1993.  7:38:53", "%d.%m.%Y. %H:%i:%s") , 16 ,"" ),
 ( 1199 , STR_TO_DATE("4.8.1997.  16:42:15", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("3.9.1992.  9:4:47", "%d.%m.%Y. %H:%i:%s") , 23 ,"" );


INSERT INTO osoblje_na_treningu VALUES
 ( 1201 , 10893 , 1162 , 1 ),
 ( 1202 , 10453 , 1169 , 6 ),
 ( 1203 , 10887 , 1195 , 9 ),
 ( 1204 , 10595 , 1199 , 3 ),
 ( 1205 , 10875 , 1129 , 3 ),
 ( 1206 , 10862 , 1154 , 1 ),
 ( 1207 , 10879 , 1174 , 6 ),
 ( 1208 , 10430 , 1130 , 5 ),
 ( 1209 , 10718 , 1112 , 7 ),
 ( 1210 , 10518 , 1139 , 5 ),
 ( 1211 , 10684 , 1198 , 6 ),
 ( 1212 , 10286 , 1122 , 7 ),
 ( 1213 , 10625 , 1169 , 2 ),
 ( 1214 , 10956 , 1148 , 3 ),
 ( 1215 , 10692 , 1199 , 8 ),
 ( 1216 , 10854 , 1178 , 2 ),
 ( 1217 , 10061 , 1166 , 10 ),
 ( 1218 , 10601 , 1162 , 1 ),
 ( 1219 , 10809 , 1132 , 3 ),
 ( 1220 , 10082 , 1167 , 5 ),
 ( 1221 , 10520 , 1177 , 3 ),
 ( 1222 , 10782 , 1164 , 9 ),
 ( 1223 , 10805 , 1182 , 10 ),
 ( 1224 , 10287 , 1110 , 7 ),
 ( 1225 , 10580 , 1122 , 6 ),
 ( 1226 , 10570 , 1183 , 1 ),
 ( 1227 , 10534 , 1104 , 2 ),
 ( 1228 , 10849 , 1134 , 5 ),
 ( 1229 , 10996 , 1113 , 2 ),
 ( 1230 , 10420 , 1128 , 1 ),
 ( 1231 , 10751 , 1198 , 4 ),
 ( 1232 , 10217 , 1177 , 1 ),
 ( 1233 , 10834 , 1128 , 5 ),
 ( 1234 , 10149 , 1179 , 6 ),
 ( 1235 , 10803 , 1113 , 4 ),
 ( 1236 , 10826 , 1140 , 1 ),
 ( 1237 , 10756 , 1185 , 10 ),
 ( 1238 , 10143 , 1132 , 7 ),
 ( 1239 , 10511 , 1101 , 7 ),
 ( 1240 , 10138 , 1174 , 1 ),
 ( 1241 , 10864 , 1148 , 4 ),
 ( 1242 , 10193 , 1167 , 5 ),
 ( 1243 , 10802 , 1137 , 8 ),
 ( 1244 , 10129 , 1138 , 9 ),
 ( 1245 , 10650 , 1100 , 10 ),
 ( 1246 , 10787 , 1159 , 4 ),
 ( 1247 , 10643 , 1106 , 6 ),
 ( 1248 , 10254 , 1178 , 8 ),
 ( 1249 , 10364 , 1126 , 2 ),
 ( 1250 , 10408 , 1154 , 8 ),
 ( 1251 , 10090 , 1132 , 7 ),
 ( 1252 , 10127 , 1183 , 3 ),
 ( 1253 , 10462 , 1109 , 9 ),
 ( 1254 , 10220 , 1135 , 10 ),
 ( 1255 , 10524 , 1129 , 1 ),
 ( 1256 , 10198 , 1129 , 4 ),
 ( 1257 , 10859 , 1199 , 7 ),
 ( 1258 , 10834 , 1100 , 6 ),
 ( 1259 , 10857 , 1106 , 4 ),
 ( 1260 , 10640 , 1177 , 9 ),
 ( 1261 , 10855 , 1186 , 2 ),
 ( 1262 , 10435 , 1159 , 4 ),
 ( 1263 , 10450 , 1142 , 5 ),
 ( 1264 , 10425 , 1100 , 5 ),
 ( 1265 , 10026 , 1154 , 8 ),
 ( 1266 , 10975 , 1161 , 10 ),
 ( 1267 , 10102 , 1127 , 1 ),
 ( 1268 , 10200 , 1172 , 4 ),
 ( 1269 , 10049 , 1174 , 7 ),
 ( 1270 , 10202 , 1144 , 3 ),
 ( 1271 , 10575 , 1165 , 10 ),
 ( 1272 , 10433 , 1107 , 9 ),
 ( 1273 , 10514 , 1145 , 6 ),
 ( 1274 , 10655 , 1131 , 4 ),
 ( 1275 , 10158 , 1108 , 6 ),
 ( 1276 , 10200 , 1177 , 10 ),
 ( 1277 , 10390 , 1145 , 9 ),
 ( 1278 , 10454 , 1175 , 10 ),
 ( 1279 , 10294 , 1128 , 2 ),
 ( 1280 , 10401 , 1153 , 5 ),
 ( 1281 , 10111 , 1197 , 9 ),
 ( 1282 , 10396 , 1174 , 2 ),
 ( 1283 , 10138 , 1198 , 9 ),
 ( 1284 , 10739 , 1161 , 8 ),
 ( 1285 , 10200 , 1167 , 4 ),
 ( 1286 , 10007 , 1137 , 9 ),
 ( 1287 , 10546 , 1188 , 5 ),
 ( 1288 , 10783 , 1153 , 8 ),
 ( 1289 , 10422 , 1100 , 9 ),
 ( 1290 , 10519 , 1129 , 1 ),
 ( 1291 , 10481 , 1107 , 9 ),
 ( 1292 , 10260 , 1164 , 10 ),
 ( 1293 , 10006 , 1193 , 2 ),
 ( 1294 , 10613 , 1108 , 7 ),
 ( 1295 , 10453 , 1148 , 10 ),
 ( 1296 , 10286 , 1175 , 8 ),
 ( 1297 , 10347 , 1104 , 10 ),
 ( 1298 , 10881 , 1165 , 4 ),
 ( 1299 , 10249 , 1170 , 6 ),
 ( 1300 , 10569 , 1138 , 9 );



INSERT INTO lijecenje VALUES
 ( 1000 , 10036 , "Izliječen" , STR_TO_DATE("28.12.2000.", "%d.%m.%Y.") , STR_TO_DATE("15.3.2021.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 44187 ),
 ( 1001 , 10207 , "U tijeku" , STR_TO_DATE("7.4.1996.", "%d.%m.%Y.") , STR_TO_DATE("15.6.2021.", "%d.%m.%Y.") , "Slabo ozljieđen" , 76427 ),
 ( 1002 , 10251 , "U tijeku" , STR_TO_DATE("11.2.2013.", "%d.%m.%Y.") , STR_TO_DATE("21.11.2022.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 44531 ),
 ( 1003 , 10846 , "U tijeku" , STR_TO_DATE("10.10.2008.", "%d.%m.%Y.") , STR_TO_DATE("20.2.2021.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 99963 ),
 ( 1004 , 10037 , "Izliječen" , STR_TO_DATE("13.11.2007.", "%d.%m.%Y.") , STR_TO_DATE("22.5.2022.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 23204 ),
 ( 1005 , 10212 , "Izliječen" , STR_TO_DATE("13.5.1998.", "%d.%m.%Y.") , STR_TO_DATE("15.7.2022.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 25238 ),
 ( 1006 , 10983 , "Izliječen" , STR_TO_DATE("15.7.1993.", "%d.%m.%Y.") , STR_TO_DATE("27.7.2022.", "%d.%m.%Y.") , "Slabo ozljieđen" , 28933 ),
 ( 1007 , 10562 , "Izliječen" , STR_TO_DATE("15.2.2001.", "%d.%m.%Y.") , STR_TO_DATE("17.12.2022.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 37088 ),
 ( 1008 , 10211 , "U tijeku" , STR_TO_DATE("14.4.1997.", "%d.%m.%Y.") , STR_TO_DATE("19.3.2020.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 29812 ),
 ( 1009 , 10971 , "Izliječen" , STR_TO_DATE("16.5.2010.", "%d.%m.%Y.") , STR_TO_DATE("28.8.2020.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 36829 ),
 ( 1010 , 10205 , "U tijeku" , STR_TO_DATE("5.10.1992.", "%d.%m.%Y.") , STR_TO_DATE("5.11.2020.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 10338 ),
 ( 1011 , 10437 , "Izliječen" , STR_TO_DATE("4.2.2012.", "%d.%m.%Y.") , STR_TO_DATE("10.10.2021.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 34986 ),
 ( 1012 , 10877 , "U tijeku" , STR_TO_DATE("28.4.2004.", "%d.%m.%Y.") , STR_TO_DATE("15.2.2020.", "%d.%m.%Y.") , "Slabo ozljieđen" , 40438 ),
 ( 1013 , 10287 , "Izliječen" , STR_TO_DATE("18.1.1994.", "%d.%m.%Y.") , STR_TO_DATE("16.4.2022.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 35555 ),
 ( 1014 , 10710 , "Izliječen" , STR_TO_DATE("14.7.2008.", "%d.%m.%Y.") , STR_TO_DATE("6.4.2020.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 75837 ),
 ( 1015 , 10009 , "Izliječen" , STR_TO_DATE("28.4.2001.", "%d.%m.%Y.") , STR_TO_DATE("1.8.2021.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 51694 ),
 ( 1016 , 10184 , "U tijeku" , STR_TO_DATE("20.10.1999.", "%d.%m.%Y.") , STR_TO_DATE("24.9.2020.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 53144 ),
 ( 1017 , 10060 , "Izliječen" , STR_TO_DATE("18.12.2018.", "%d.%m.%Y.") , STR_TO_DATE("28.1.2021.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 87816 ),
 ( 1018 , 10028 , "U tijeku" , STR_TO_DATE("20.9.2001.", "%d.%m.%Y.") , STR_TO_DATE("9.9.2021.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 12751 ),
 ( 1019 , 10091 , "U tijeku" , STR_TO_DATE("22.7.2003.", "%d.%m.%Y.") , STR_TO_DATE("27.6.2022.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 95740 ),
 ( 1020 , 10199 , "Izliječen" , STR_TO_DATE("18.9.2004.", "%d.%m.%Y.") , STR_TO_DATE("12.9.2020.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 36787 ),
 ( 1021 , 10390 , "Izliječen" , STR_TO_DATE("2.4.2007.", "%d.%m.%Y.") , STR_TO_DATE("14.4.2022.", "%d.%m.%Y.") , "Slabo ozljieđen" , 25904 ),
 ( 1022 , 10452 , "Izliječen" , STR_TO_DATE("12.5.2000.", "%d.%m.%Y.") , STR_TO_DATE("15.3.2021.", "%d.%m.%Y.") , "Slabo ozljieđen" , 59665 ),
 ( 1023 , 10833 , "Izliječen" , STR_TO_DATE("2.2.1994.", "%d.%m.%Y.") , STR_TO_DATE("10.4.2020.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 91379 ),
 ( 1024 , 10781 , "Izliječen" , STR_TO_DATE("10.1.2017.", "%d.%m.%Y.") , STR_TO_DATE("11.4.2021.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 40404 ),
 ( 1025 , 10103 , "U tijeku" , STR_TO_DATE("14.11.2013.", "%d.%m.%Y.") , STR_TO_DATE("2.9.2021.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 50174 ),
 ( 1026 , 10458 , "U tijeku" , STR_TO_DATE("13.4.2003.", "%d.%m.%Y.") , STR_TO_DATE("3.3.2020.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 72876 ),
 ( 1027 , 10319 , "U tijeku" , STR_TO_DATE("28.10.2017.", "%d.%m.%Y.") , STR_TO_DATE("14.10.2021.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 37601 ),
 ( 1028 , 10038 , "Izliječen" , STR_TO_DATE("14.10.2015.", "%d.%m.%Y.") , STR_TO_DATE("6.2.2020.", "%d.%m.%Y.") , "Slabo ozljieđen" , 85811 ),
 ( 1029 , 10131 , "Izliječen" , STR_TO_DATE("15.12.1995.", "%d.%m.%Y.") , STR_TO_DATE("28.10.2021.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 95168 ),
 ( 1030 , 10705 , "Izliječen" , STR_TO_DATE("2.10.2009.", "%d.%m.%Y.") , STR_TO_DATE("26.7.2022.", "%d.%m.%Y.") , "Slabo ozljieđen" , 23062 ),
 ( 1031 , 10670 , "U tijeku" , STR_TO_DATE("23.8.2001.", "%d.%m.%Y.") , STR_TO_DATE("23.1.2022.", "%d.%m.%Y.") , "Slabo ozljieđen" , 65569 ),
 ( 1032 , 10556 , "U tijeku" , STR_TO_DATE("11.9.1995.", "%d.%m.%Y.") , STR_TO_DATE("4.11.2020.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 1702 ),
 ( 1033 , 10279 , "U tijeku" , STR_TO_DATE("20.2.1993.", "%d.%m.%Y.") , STR_TO_DATE("20.8.2021.", "%d.%m.%Y.") , "Slabo ozljieđen" , 81207 ),
 ( 1034 , 10125 , "U tijeku" , STR_TO_DATE("23.2.2006.", "%d.%m.%Y.") , STR_TO_DATE("24.3.2021.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 68033 ),
 ( 1035 , 10598 , "Izliječen" , STR_TO_DATE("18.4.2010.", "%d.%m.%Y.") , STR_TO_DATE("2.3.2021.", "%d.%m.%Y.") , "Slabo ozljieđen" , 47818 ),
 ( 1036 , 10908 , "U tijeku" , STR_TO_DATE("27.11.2000.", "%d.%m.%Y.") , STR_TO_DATE("20.7.2021.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 65641 ),
 ( 1037 , 10726 , "U tijeku" , STR_TO_DATE("15.4.1997.", "%d.%m.%Y.") , STR_TO_DATE("14.5.2020.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 11239 ),
 ( 1038 , 10368 , "U tijeku" , STR_TO_DATE("1.8.2001.", "%d.%m.%Y.") , STR_TO_DATE("4.9.2022.", "%d.%m.%Y.") , "Slabo ozljieđen" , 86867 ),
 ( 1039 , 10715 , "Izliječen" , STR_TO_DATE("27.3.1999.", "%d.%m.%Y.") , STR_TO_DATE("5.9.2021.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 63292 ),
 ( 1040 , 10495 , "U tijeku" , STR_TO_DATE("23.2.1998.", "%d.%m.%Y.") , STR_TO_DATE("23.8.2021.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 17257 ),
 ( 1041 , 10297 , "Izliječen" , STR_TO_DATE("13.3.2017.", "%d.%m.%Y.") , STR_TO_DATE("28.4.2022.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 26778 ),
 ( 1042 , 10049 , "Izliječen" , STR_TO_DATE("18.5.1995.", "%d.%m.%Y.") , STR_TO_DATE("15.7.2021.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 22612 ),
 ( 1043 , 10444 , "U tijeku" , STR_TO_DATE("12.8.2014.", "%d.%m.%Y.") , STR_TO_DATE("25.7.2020.", "%d.%m.%Y.") , "Slabo ozljieđen" , 95383 ),
 ( 1044 , 10064 , "U tijeku" , STR_TO_DATE("12.12.2001.", "%d.%m.%Y.") , STR_TO_DATE("16.3.2021.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 28069 ),
 ( 1045 , 10478 , "Izliječen" , STR_TO_DATE("4.8.1999.", "%d.%m.%Y.") , STR_TO_DATE("24.8.2022.", "%d.%m.%Y.") , "Slabo ozljieđen" , 89446 ),
 ( 1046 , 10570 , "U tijeku" , STR_TO_DATE("9.1.2013.", "%d.%m.%Y.") , STR_TO_DATE("8.11.2020.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 40012 ),
 ( 1047 , 10580 , "Izliječen" , STR_TO_DATE("12.6.2010.", "%d.%m.%Y.") , STR_TO_DATE("22.5.2022.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 79188 ),
 ( 1048 , 10565 , "Izliječen" , STR_TO_DATE("21.6.2005.", "%d.%m.%Y.") , STR_TO_DATE("22.11.2021.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 99502 ),
 ( 1049 , 10765 , "Izliječen" , STR_TO_DATE("24.6.1990.", "%d.%m.%Y.") , STR_TO_DATE("26.8.2022.", "%d.%m.%Y.") , "Slabo ozljieđen" , 76841 ),
 ( 1050 , 10520 , "U tijeku" , STR_TO_DATE("6.9.1996.", "%d.%m.%Y.") , STR_TO_DATE("3.9.2020.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 63516 ),
 ( 1051 , 10710 , "U tijeku" , STR_TO_DATE("16.5.2020.", "%d.%m.%Y.") , STR_TO_DATE("11.12.2021.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 62502 ),
 ( 1052 , 10774 , "Izliječen" , STR_TO_DATE("4.9.2012.", "%d.%m.%Y.") , STR_TO_DATE("18.9.2022.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 76037 ),
 ( 1053 , 10253 , "Izliječen" , STR_TO_DATE("28.3.1996.", "%d.%m.%Y.") , STR_TO_DATE("27.4.2020.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 25300 ),
 ( 1054 , 10135 , "U tijeku" , STR_TO_DATE("1.2.2002.", "%d.%m.%Y.") , STR_TO_DATE("17.10.2021.", "%d.%m.%Y.") , "Slabo ozljieđen" , 3371 ),
 ( 1055 , 10012 , "U tijeku" , STR_TO_DATE("11.7.1991.", "%d.%m.%Y.") , STR_TO_DATE("15.2.2021.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 12259 ),
 ( 1056 , 10264 , "Izliječen" , STR_TO_DATE("26.3.2017.", "%d.%m.%Y.") , STR_TO_DATE("4.12.2022.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 74708 ),
 ( 1057 , 10220 , "U tijeku" , STR_TO_DATE("5.7.2000.", "%d.%m.%Y.") , STR_TO_DATE("1.4.2021.", "%d.%m.%Y.") , "Slabo ozljieđen" , 22970 ),
 ( 1058 , 10601 , "U tijeku" , STR_TO_DATE("1.9.2017.", "%d.%m.%Y.") , STR_TO_DATE("12.9.2020.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 95920 ),
 ( 1059 , 10591 , "U tijeku" , STR_TO_DATE("12.12.2015.", "%d.%m.%Y.") , STR_TO_DATE("11.6.2020.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 57331 ),
 ( 1060 , 10956 , "U tijeku" , STR_TO_DATE("4.3.2006.", "%d.%m.%Y.") , STR_TO_DATE("9.12.2021.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 4316 ),
 ( 1061 , 10360 , "Izliječen" , STR_TO_DATE("25.5.2009.", "%d.%m.%Y.") , STR_TO_DATE("14.1.2022.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 69323 ),
 ( 1062 , 10802 , "U tijeku" , STR_TO_DATE("22.11.2012.", "%d.%m.%Y.") , STR_TO_DATE("15.6.2020.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 67088 ),
 ( 1063 , 10945 , "U tijeku" , STR_TO_DATE("6.4.1994.", "%d.%m.%Y.") , STR_TO_DATE("8.8.2022.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 51062 ),
 ( 1064 , 10324 , "U tijeku" , STR_TO_DATE("10.1.2001.", "%d.%m.%Y.") , STR_TO_DATE("5.10.2022.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 84510 ),
 ( 1065 , 10071 , "Izliječen" , STR_TO_DATE("26.4.2007.", "%d.%m.%Y.") , STR_TO_DATE("26.2.2021.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 4680 ),
 ( 1066 , 10400 , "U tijeku" , STR_TO_DATE("27.3.1993.", "%d.%m.%Y.") , STR_TO_DATE("2.12.2020.", "%d.%m.%Y.") , "Slabo ozljieđen" , 49730 ),
 ( 1067 , 10670 , "U tijeku" , STR_TO_DATE("22.1.2005.", "%d.%m.%Y.") , STR_TO_DATE("22.7.2021.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 31761 ),
 ( 1068 , 10810 , "U tijeku" , STR_TO_DATE("26.8.1993.", "%d.%m.%Y.") , STR_TO_DATE("17.4.2021.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 46534 ),
 ( 1069 , 10675 , "Izliječen" , STR_TO_DATE("2.10.1999.", "%d.%m.%Y.") , STR_TO_DATE("25.4.2021.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 79375 ),
 ( 1070 , 10551 , "Izliječen" , STR_TO_DATE("17.12.1992.", "%d.%m.%Y.") , STR_TO_DATE("18.12.2021.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 42729 ),
 ( 1071 , 10349 , "U tijeku" , STR_TO_DATE("18.10.1999.", "%d.%m.%Y.") , STR_TO_DATE("10.3.2020.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 44447 ),
 ( 1072 , 10793 , "U tijeku" , STR_TO_DATE("6.8.2013.", "%d.%m.%Y.") , STR_TO_DATE("26.1.2020.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 11195 ),
 ( 1073 , 10771 , "U tijeku" , STR_TO_DATE("14.3.1999.", "%d.%m.%Y.") , STR_TO_DATE("27.6.2020.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 80277 ),
 ( 1074 , 10054 , "U tijeku" , STR_TO_DATE("12.10.1997.", "%d.%m.%Y.") , STR_TO_DATE("13.8.2021.", "%d.%m.%Y.") , "Slabo ozljieđen" , 25089 ),
 ( 1075 , 10069 , "Izliječen" , STR_TO_DATE("8.7.2004.", "%d.%m.%Y.") , STR_TO_DATE("22.9.2020.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 22210 ),
 ( 1076 , 10608 , "Izliječen" , STR_TO_DATE("18.4.2011.", "%d.%m.%Y.") , STR_TO_DATE("9.10.2021.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 94000 ),
 ( 1077 , 10303 , "U tijeku" , STR_TO_DATE("27.8.1996.", "%d.%m.%Y.") , STR_TO_DATE("17.6.2022.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 19832 ),
 ( 1078 , 10743 , "U tijeku" , STR_TO_DATE("24.12.1993.", "%d.%m.%Y.") , STR_TO_DATE("17.1.2020.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 85614 ),
 ( 1079 , 10318 , "U tijeku" , STR_TO_DATE("23.10.1995.", "%d.%m.%Y.") , STR_TO_DATE("27.11.2020.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 44960 ),
 ( 1080 , 10063 , "Izliječen" , STR_TO_DATE("19.12.1993.", "%d.%m.%Y.") , STR_TO_DATE("1.2.2022.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 72726 ),
 ( 1081 , 10895 , "Izliječen" , STR_TO_DATE("25.8.1998.", "%d.%m.%Y.") , STR_TO_DATE("14.9.2021.", "%d.%m.%Y.") , "Slabo ozljieđen" , 78550 ),
 ( 1082 , 10479 , "Izliječen" , STR_TO_DATE("19.3.2007.", "%d.%m.%Y.") , STR_TO_DATE("6.4.2020.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 8210 ),
 ( 1083 , 10152 , "U tijeku" , STR_TO_DATE("6.11.1992.", "%d.%m.%Y.") , STR_TO_DATE("11.10.2022.", "%d.%m.%Y.") , "Slabo ozljieđen" , 87272 ),
 ( 1084 , 10599 , "U tijeku" , STR_TO_DATE("7.2.1996.", "%d.%m.%Y.") , STR_TO_DATE("15.5.2020.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 93596 ),
 ( 1085 , 10949 , "U tijeku" , STR_TO_DATE("12.3.2003.", "%d.%m.%Y.") , STR_TO_DATE("28.7.2021.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 61973 ),
 ( 1086 , 10733 , "U tijeku" , STR_TO_DATE("23.10.2000.", "%d.%m.%Y.") , STR_TO_DATE("24.9.2021.", "%d.%m.%Y.") , "Slabo ozljieđen" , 75353 ),
 ( 1087 , 10476 , "U tijeku" , STR_TO_DATE("8.5.2007.", "%d.%m.%Y.") , STR_TO_DATE("8.11.2020.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 42388 ),
 ( 1088 , 10644 , "Izliječen" , STR_TO_DATE("25.7.2002.", "%d.%m.%Y.") , STR_TO_DATE("14.7.2021.", "%d.%m.%Y.") , "Slabo ozljieđen" , 59091 ),
 ( 1089 , 10804 , "U tijeku" , STR_TO_DATE("12.6.1993.", "%d.%m.%Y.") , STR_TO_DATE("5.8.2020.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 93125 ),
 ( 1090 , 10774 , "U tijeku" , STR_TO_DATE("3.6.1998.", "%d.%m.%Y.") , STR_TO_DATE("23.9.2020.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 37634 ),
 ( 1091 , 10931 , "Izliječen" , STR_TO_DATE("1.10.2020.", "%d.%m.%Y.") , STR_TO_DATE("3.7.2022.", "%d.%m.%Y.") , "Slabo ozljieđen" , 48252 ),
 ( 1092 , 10800 , "Izliječen" , STR_TO_DATE("3.9.2016.", "%d.%m.%Y.") , STR_TO_DATE("5.5.2022.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 61445 ),
 ( 1093 , 10331 , "Izliječen" , STR_TO_DATE("1.10.2006.", "%d.%m.%Y.") , STR_TO_DATE("16.2.2020.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 39044 ),
 ( 1094 , 10732 , "Izliječen" , STR_TO_DATE("10.1.2005.", "%d.%m.%Y.") , STR_TO_DATE("17.8.2021.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 6441 ),
 ( 1095 , 10248 , "U tijeku" , STR_TO_DATE("20.7.2002.", "%d.%m.%Y.") , STR_TO_DATE("13.9.2022.", "%d.%m.%Y.") , "Slabo ozljieđen" , 38758 ),
 ( 1096 , 10882 , "Izliječen" , STR_TO_DATE("10.9.1993.", "%d.%m.%Y.") , STR_TO_DATE("3.8.2022.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 27482 ),
 ( 1097 , 10920 , "Izliječen" , STR_TO_DATE("24.10.2010.", "%d.%m.%Y.") , STR_TO_DATE("17.6.2021.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 27244 ),
 ( 1098 , 10982 , "U tijeku" , STR_TO_DATE("11.3.2004.", "%d.%m.%Y.") , STR_TO_DATE("28.12.2022.", "%d.%m.%Y.") , "Ozbiljno ozlijeđen" , 50406 ),
 ( 1099 , 10677 , "U tijeku" , STR_TO_DATE("12.5.2009.", "%d.%m.%Y.") , STR_TO_DATE("19.5.2020.", "%d.%m.%Y.") , "Srednje ozlijeđen" , 11246 );







-- UPITI:

-- Prikaži id, ime i prezime 10 osoba koje su imale najveći performans na treningu, a preduvjet za njihovo pojavljivanje na listi
-- je da su bile na barem jednoj misiji koja u svom intervalu održavanja ima najmanje jedan dan u 12. mjesecu.


SELECT os.id, ime, prezime
FROM osoblje_na_treningu AS o
INNER JOIN trening AS t
	ON o.id_trening = t.id
INNER JOIN osoblje AS os
	ON os.id = o.id_osoblje
INNER JOIN osoblje_na_misiji AS om
	ON om.id_osoblje = os.id
INNER JOIN misija AS m
	ON om.id_misija = m.id
WHERE 12 - MONTH(m.vrijeme_pocetka) <= TIMESTAMPDIFF(MONTH, m.vrijeme_pocetka, m.vrijeme_kraja)
ORDER BY performans DESC
LIMIT 10;




-- Prikaži id, ime, prezime i cin osobe koja je bila odgovorna za vozilo vrste "Gusjenična oklopna vozila"
-- koje je bilo na najviše popravaka.


SELECT ime, prezime, cin
FROM
	(SELECT ime, prezime, cin, COUNT(*) AS broj_popravka
	FROM popravak AS p
	INNER JOIN vozilo_na_misiji AS vm
		ON p.id_vozilo_na_misiji = vm.id
	INNER JOIN vozila AS v
		ON v.id = vm.id_vozilo
	INNER JOIN vozilo_na_turi AS vt
		ON vt.id_vozilo = v.id
	INNER JOIN osoblje AS o
		ON o.id = vt.id_odgovorni
	WHERE v.vrsta = "Gusjenična oklopna vozila"
	GROUP BY v.id) AS l
    ORDER BY broj_popravka DESC
    LIMIT 1;



-- Prikazi naziv ture kod koje je izdano najmanje opreme

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



 -- Prikaži ukupni proracun sektora koji ima drugi najveci broj osoblja koji nisu bili na lijecenju niti jedanput te koji su sudjelovali
 -- na najmanje jednom treningu ciji datum pocetka nije bio prije 23 godinu dana od sada.


SELECT ukupni_proracun
FROM
	(SELECT ukupni_proracun, COUNT(*) AS br_osoblja_uvjeti
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




 -- Prikaži nazive misija i njene lokacije, ali samo za misije u kojima je sudjelovalo osoblje starije
 -- od 31 godinu i koje je bilo odgovorno za najmanje jedno vozilo u nekoj turi.

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
-- jan
-- navedi sva imena i prezimena ozlijedenih vojnika na misiji kojima lijecenje kosta vise od 500 i manje od 5000
select o.id,o.ime,o.prezime
from osoblje_na_misiji as onm
inner join osoblje as o 
on onm.id_osoblje= o.id
inner join lijecenje as l
on l.id_osoblje = o.id
where l.trosak_lijecenja>10000;

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

-- Hrvatska ratna mornarica
-- nabroji sva vozila na popravku koja su ujedno i na misiji te ih nabroji koliko ih je
select sum(ukupna_kolicina) as totalni_br
from vozila as v
inner join vozilo_na_misiji as vnm
on v.id=vnm.id_vozilo
inner join misija as m
on m.id=vnm.id_misija
where m.naziv="UNOCI";

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
-- svi idevi osoblja krvne grupe 0+ koje je na lijecenju i u sektoru je "Hrvatska kopnena vojska"
Select l.id_osoblje, o.ime, o.prezime
from lijecenje as l
inner join osoblje as o
on l.id_osoblje= o.id
inner join sektor as s
on s.id=o.id_sektor
where o.krvna_grupa="0+" and s.naziv="Hrvatska kopnena vojska";
