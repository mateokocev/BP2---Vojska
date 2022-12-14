DROP DATABASE IF EXISTS vojska;
CREATE DATABASE vojska;
USE vojska;


CREATE TABLE sektor(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(60) NOT NULL,
    datum_osnivanja DATE NOT NULL,
    opis TEXT NOT NULL,
    ukupni_proracun DECIMAL(12,2) NOT NULL,
    CHECK(ukupni_proracun >= 0)
);
 -- DROP TABLE sektor;



CREATE TABLE lokacija(
    id INTEGER PRIMARY KEY,
    id_sektor INTEGER,
    naziv VARCHAR(60) NOT NULL,
    zemljopisna_duzina DECIMAL(10, 7) NOT NULL,
    zemljopisna_sirina DECIMAL(10, 7) NOT NULL,
    UNIQUE(zemljopisna_duzina, zemljopisna_sirina),
    FOREIGN KEY (id_sektor) REFERENCES sektor(id)
);
-- DROP TABLE lokacija;



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
    trosak_misije NUMERIC(15, 2) NOT NULL,
    CHECK(trosak_misije >= 0),
    FOREIGN KEY (id_lokacija) REFERENCES lokacija(id),
    FOREIGN KEY (id_tura) REFERENCES tura(id) ON DELETE CASCADE
);
-- DROP TABLE misija;


CREATE TABLE osoblje_na_misiji(
    id INTEGER PRIMARY KEY,
    id_osoblje INTEGER NOT NULL,
    id_misija INTEGER NOT NULL,
    FOREIGN KEY (id_osoblje) REFERENCES osoblje(id) ON DELETE CASCADE,
    FOREIGN KEY (id_misija) REFERENCES misija(id) ON DELETE CASCADE
);
-- DROP TABLE osoblje_na_misiji;



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



CREATE TABLE vozila(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(60) NOT NULL,
    vrsta VARCHAR(50) NOT NULL,
    ukupna_kolicina INTEGER NOT NULL,
    kapacitet INTEGER NOT NULL,
    CHECK(ukupna_kolicina > 0 AND kapacitet > 0)

);
-- DROP TABLE vozila;



CREATE TABLE vozilo_na_misiji(
    id INTEGER PRIMARY KEY,
    id_vozilo INTEGER NOT NULL,
    kolicina INTEGER NOT NULL,
    id_misija INTEGER NOT NULL,
    CHECK(kolicina > 0),
    FOREIGN KEY (id_vozilo) REFERENCES vozila(id) ON DELETE CASCADE,
    FOREIGN KEY (id_misija) REFERENCES misija(id) ON DELETE CASCADE
);
-- DROP TABLE vozilo_na_misiji;



CREATE TABLE vozilo_na_turi(
    id INTEGER PRIMARY KEY,
    id_vozilo INTEGER,
    id_tura INTEGER,
    id_odgovorni INTEGER NOT NULL,
    kolicina INTEGER,
    CHECK(kolicina > 0),
    FOREIGN KEY (id_vozilo) REFERENCES vozila(id) ON DELETE CASCADE,
    FOREIGN KEY (id_tura) REFERENCES tura(id) ON DELETE CASCADE,
    FOREIGN KEY (id_odgovorni) REFERENCES osoblje_na_turi(id)
);
-- DROP TABLE vozilo_na_turi;



CREATE TABLE popravak(
    id INTEGER PRIMARY KEY,
    id_vozilo_na_misiji INTEGER NOT NULL,
    opis_stete TEXT NOT NULL,
    pocetak_popravka DATETIME NOT NULL,
    kraj_popravka DATETIME,
    trosak_popravka NUMERIC(15,2) NOT NULL,
    CHECK(trosak_popravka >= 0),
    FOREIGN KEY (id_vozilo_na_misiji) REFERENCES vozilo_na_misiji(id) ON DELETE CASCADE
);
-- DROP TABLE popravak;



CREATE TABLE oprema(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(50) NOT NULL,
    vrsta VARCHAR(50) NOT NULL,
    ukupna_kolicina INTEGER NOT NULL,
    CHECK(ukupna_kolicina > 0) 
);
-- DROP TABLE oprema;



CREATE TABLE izdana_oprema(
    id INTEGER PRIMARY KEY,
    id_oprema INTEGER NOT NULL,
    id_osoblje_na_misiji INTEGER NOT NULL,
    izdana_kolicina INTEGER DEFAULT 1,          -- stavit konkretne vrijednost. ne default!!!
    CHECK(izdana_kolicina > 0),
    FOREIGN KEY (id_oprema) REFERENCES oprema(id) ON DELETE CASCADE,
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
	FOREIGN KEY (id_osoblje) REFERENCES osoblje(id) ON DELETE CASCADE,
	FOREIGN KEY (id_trening) REFERENCES trening(id) ON DELETE CASCADE
);
-- DROP TABLE osoblje_na_treningu;


CREATE TABLE lijecenje(
    id INTEGER PRIMARY KEY,
    id_osoblje INTEGER,
    status_lijecenja TEXT NOT NULL,  
    pocetak_lijecenja DATETIME NOT NULL,
    kraj_lijecenja DATETIME,
    opis_ozljede TEXT NOT NULL,
    trosak_lijecenja NUMERIC(15,2),
    CHECK(trosak_lijecenja >= 0),
    FOREIGN KEY (id_osoblje) REFERENCES osoblje(id) ON DELETE CASCADE
);
-- DROP TABLE lijecenje;






-- OKIDA??I:

																															    /*
Datum po??etka ture ne mo??e biti ve??i ili jednak od datuma kraja ture.
Idemo ih uspore??ivat samo uz uvjet da kraj nije NULL.              
U slu??aju da je kraj NULL to zna??i da je tura jo?? uvijek u tijeku. Rije?? je o UPDATE-u.                                                              */

DROP TRIGGER IF EXISTS u_tura_vrijeme;

DELIMITER //
CREATE TRIGGER u_tura_vrijeme
    BEFORE UPDATE ON tura
    FOR EACH ROW
BEGIN
    IF new.vrijeme_pocetka >= new.vrijeme_kraja AND new.vrijeme_kraja != NULL THEN
	SIGNAL SQLSTATE '40000'
        SET MESSAGE_TEXT = 'Neispravno je uneseno vrijeme pocetka ili/i kraja misije';
    END IF;
END//
DELIMITER ;

		
                                                                                                                                  /*
Datum po??etka misije ne mo??e biti ve??i ili jednak od datuma kraja misije.
Idemo ih uspore??ivat samo uz uvjet da kraj nije NULL.              
U slu??aju da je kraj NULL to zna??i da je misija jo?? uvijek u tijeku. Rije?? je o UPDATE-u.                                                             */

DROP TRIGGER IF EXISTS u_mis_vrijeme;

DELIMITER //
CREATE TRIGGER u_mis_vrijeme
    BEFORE UPDATE ON misija
    FOR EACH ROW
BEGIN
    IF new.vrijeme_pocetka >= new.vrijeme_kraja AND new.vrijeme_kraja != NULL THEN
	SIGNAL SQLSTATE '40000'
        SET MESSAGE_TEXT = 'Neispravno je uneseno vrijeme pocetka ili/i kraja misije';
    END IF;
END//
DELIMITER ;



																																	  /*
Datum po??etka sudjelovanja osoblja na turi ne mo??e biti ve??i ili jednak od datuma kraja sudjelovanja.
Idemo ih uspore??ivat samo uz uvjet da kraj nije NULL.              
U slu??aju da je kraj NULL to zna??i da osoba jo?? uvijek sudjeluje u turi. Rije?? je o UPDATE-u.                                                              */

DROP TRIGGER IF EXISTS u_ont_vrijeme;

DELIMITER //
CREATE TRIGGER u_ont_vrijeme
    BEFORE UPDATE ON osoblje_na_turi
    FOR EACH ROW
BEGIN
	IF new.datum_pocetka >= new.datum_kraja AND new.datum_kraja != NULL THEN
		SIGNAL SQLSTATE '40000'
                SET MESSAGE_TEXT = 'Neispravno je uneseno vrijeme pocetka ili/i kraja sudjelovanja osoblja na turi!';
        END IF;
END//
DELIMITER ;



																																	/*
Datum po??etka popravka ne mo??e biti ve??i ili jednak od datuma kraja popravka.
Idemo ih uspore??ivat samo uz uvjet da kraj nije NULL.              
U slu??aju da je kraj NULL to zna??i da je popravak jo?? uvijek u tijeku. Rije?? je o INSERT-u.                                                            */

DROP TRIGGER IF EXISTS i_po_vrijeme;

DELIMITER //
CREATE TRIGGER i_po_vrijeme
    BEFORE INSERT ON popravak
    FOR EACH ROW
BEGIN
	IF new.pocetak_popravka >= new.kraj_popravka AND new.kraj_popravka != NULL THEN
		SIGNAL SQLSTATE '40000'
                SET MESSAGE_TEXT = 'Neispravno je uneseno vrijeme pocetka ili/i kraja popravka!';
        END IF;
END//
DELIMITER ;



																																 /*
Datum po??etka treninga ne mo??e biti ve??i ili jednak od datuma kraja treninga te trening bi najmanje trebao trajat 20 min.
Rije?? o INSERT-u.                                                                                                                */

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



                                                                                                                                    /*
Datum po??etka lijecenja ne mo??e biti ve??i ili jednak od datuma kraja lije??enja kada je rije?? o INSERT-u. 
Idemo ih uspore??ivat samo uz uvjet da kraj nije NULL.
U slu??aju je datum kraja lije??enja NULL to zna??i da je lije??enje jo?? uvijek u tijeku.                                                */

DROP TRIGGER IF EXISTS i_li_vrijeme;                                                                                                      

DELIMITER //
CREATE TRIGGER li_vrijeme
    BEFORE INSERT ON lijecenje
    FOR EACH ROW
BEGIN
    IF new.pocetak_lijecenja >= new.kraj_lijecenja AND new.kraj_lijecenja != NULL THEN
	 SIGNAL SQLSTATE '40000'
         SET MESSAGE_TEXT = 'Neispravno je uneseno vrijeme pocetka ili/i kraja lijecenja!';
    END IF;
END//
DELIMITER ;




																																	/*
Napraviti okida?? koji ??e u slu??aju da korisnik unese opremu koja je ve?? une??ena zbrojit koli??inu opreme.
Npr u skladi??tu ve?? postoji (1330, "RBG-6", "Baca?? granata", 124) te korisnik unosi (1370, "RBG-6", "Baca?? granata", 6).
To je "nepotrebno" te stoga okida?? pridodaje dodatnu koli??inu onoj ve?? postoje??oj tj (1330, "RBG-6", "Baca?? granata", 130).         */

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
        DELETE FROM oprema WHERE id = new.id;
    END IF;
END//
DELIMITER ;



																																	/*
Prati se da zbroj koli??ine ??eljene izdane opreme ne bude ve??i od sveukupne mogu??e koli??ine opreme tijekom INSERT-a.
Prati se da u odre??enom razdoblju tj. misiji to ne bude prekora??eno. 																			*/

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



																																	/*
Prati se da zbroj izdane koli??ine ne bude ve??i od sveukupne mogu??e koli??ine opreme tijekom UPDATE-a
Prati se da u odre??enom razdoblju tj. misiji to ne bude prekora??eno.																*/

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





INSERT INTO sektor VALUES
(1, "Hrvatska kopnena vojska", STR_TO_DATE("28.05.1991.", "%d.%m.%Y."), "Najbrojnija je grana Oru??anih snaga Republike Hrvatske, ??ija je uloga i namjena promicanje i za??tita vitalnih nacionalnih interesa Republike Hrvatske, obrana suvereniteta i teritorijalne cjelovitosti dr??ave. Temeljna zada??a je sprije??iti prodor agresora u dubinu teritorija, sa??uvati vitalne strategijske objekte, osigurati mobilizaciju ratnog sastava i pobijediti agresora. Nositeljica je i organizatorica kopnene obrane Republike Hrvatske.", 4324000000.00),
(2, "Hrvatska ratna mornarica", STR_TO_DATE("12.09.1991.", "%d.%m.%Y."), "Uloga i namjena HRM-e  je ??tititi integritet i suverenitet Republike Hrvatske na moru i s mora. Nositeljica je i organizatorica pomorske obrane Republike Hrvatske", 2876000000.00),
(3, "Hrvatsko ratno zrakoplovstvo", STR_TO_DATE("12.12.1991.", "%d.%m.%Y."), "Osnovna zada??a HRZ-a je osiguranje suverenosti zra??nog prostora Republike Hrvatske te pru??anje zrakoplovne potpore drugim granama u provedbi njihovih zada??a u zdru??enim operacijama. Nositelj je i organizator integriranog sustava protuzra??ne obrane Republike Hrvatske.", 3622000000.00),
(4, "Hrvatska vojna policija", STR_TO_DATE("24.08.1991.", "%d.%m.%Y."), "Vojna policija Oru??anih snaga Republike Hrvatske (VP OSRH) pru??a potporu Ministarstvu obrane i Oru??anim snagama Republike Hrvatske obavljanjem namjenskih vojnopolicijskih poslova u miru i ratu te borbenih zada??a u ratu.", 1822000000.00);



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
 ( 10001 , 3 , "Jagoda" , "Lu??i??" , "Pozornik" , STR_TO_DATE("5.3.1968.", "%d.%m.%Y.") , STR_TO_DATE("21.3.2002.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10002 , 3 , "Arabela" , "Herceg" , "Skupnik" , STR_TO_DATE("1.10.1967.", "%d.%m.%Y.") , STR_TO_DATE("20.10.2013.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10003 , 1 , "Vilim" , "Grguri??" , "Skupnik" , STR_TO_DATE("30.10.1956.", "%d.%m.%Y.") , STR_TO_DATE("3.2.2016.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10004 , 2 , "Julija" , "Kova??i??" , "Narednik" , STR_TO_DATE("5.5.1970.", "%d.%m.%Y.") , STR_TO_DATE("8.9.1993.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10005 , 1 , "An??ela" , "Klari??" , "Narednik" , STR_TO_DATE("28.11.1961.", "%d.%m.%Y.") , STR_TO_DATE("18.5.1995.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10006 , 1 , "Donata" , "Vukeli??" , "Razvodnik" , STR_TO_DATE("8.10.1956.", "%d.%m.%Y.") , STR_TO_DATE("18.1.2005.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10007 , 4 , "Matija" , "Peri??" , "Poru??nik" , STR_TO_DATE("24.12.1952.", "%d.%m.%Y.") , STR_TO_DATE("4.11.1995.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10008 , 3 , "Sabina" , "Stani??" , "Pukovnik" , STR_TO_DATE("28.3.1962.", "%d.%m.%Y.") , STR_TO_DATE("13.1.2014.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10009 , 4 , "Alaia" , "Bo??i??" , "Skupnik" , STR_TO_DATE("20.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("13.5.1992.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10010 , 2 , "Damjan" , "Bla??evi??" , "Pozornik" , STR_TO_DATE("24.7.1956.", "%d.%m.%Y.") , STR_TO_DATE("28.7.2005.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10011 , 2 , "Malija" , "??imuni??" , "Brigadir" , STR_TO_DATE("11.5.1955.", "%d.%m.%Y.") , STR_TO_DATE("26.3.2012.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10012 , 1 , "Anamarija" , "Mandi??" , "Pozornik" , STR_TO_DATE("24.3.1957.", "%d.%m.%Y.") , STR_TO_DATE("16.10.2008.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10013 , 2 , "Janko" , "Perkovi??" , "Skupnik" , STR_TO_DATE("13.2.1967.", "%d.%m.%Y.") , STR_TO_DATE("4.3.1996.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10014 , 2 , "Korina" , "Babi??" , "Pozornik" , STR_TO_DATE("17.10.1969.", "%d.%m.%Y.") , STR_TO_DATE("14.12.1999.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10015 , 4 , "Toni" , "Vukeli??" , "Brigadir" , STR_TO_DATE("5.9.1967.", "%d.%m.%Y.") , STR_TO_DATE("3.7.2004.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10016 , 3 , "Nora" , "Mari??" , "Brigadir" , STR_TO_DATE("4.5.1956.", "%d.%m.%Y.") , STR_TO_DATE("18.8.1998.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10017 , 3 , "Jana" , "??imi??" , "Pozornik" , STR_TO_DATE("7.2.1952.", "%d.%m.%Y.") , STR_TO_DATE("20.5.2004.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10018 , 4 , "Elio" , "Horvat" , "Narednik" , STR_TO_DATE("29.4.1955.", "%d.%m.%Y.") , STR_TO_DATE("25.8.1999.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10019 , 3 , "Melanija" , "Horvat" , "Skupnik" , STR_TO_DATE("25.7.1967.", "%d.%m.%Y.") , STR_TO_DATE("27.6.1994.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10020 , 1 , "Isla" , "Pavli??" , "Poru??nik" , STR_TO_DATE("1.10.1966.", "%d.%m.%Y.") , STR_TO_DATE("19.5.2003.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10021 , 4 , "Emberli" , "Filipovi??" , "Pukovnik" , STR_TO_DATE("16.9.1970.", "%d.%m.%Y.") , STR_TO_DATE("8.3.2017.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10022 , 2 , "Desa" , "Jovanovi??" , "Satnik" , STR_TO_DATE("20.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("26.2.1997.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10023 , 2 , "Kalen" , "Kati??" , "Skupnik" , STR_TO_DATE("21.1.1963.", "%d.%m.%Y.") , STR_TO_DATE("22.3.2014.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10024 , 4 , "Alijah" , "??imuni??" , "Pozornik" , STR_TO_DATE("6.10.1954.", "%d.%m.%Y.") , STR_TO_DATE("28.6.1996.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10025 , 4 , "Iva" , "Lon??ar" , "Poru??nik" , STR_TO_DATE("30.4.1952.", "%d.%m.%Y.") , STR_TO_DATE("8.9.1993.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10026 , 1 , "Siri" , "Kova??i??" , "Bojnik" , STR_TO_DATE("24.6.1962.", "%d.%m.%Y.") , STR_TO_DATE("23.2.2013.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10027 , 3 , "Ilko" , "Novak" , "Razvodnik" , STR_TO_DATE("12.5.1968.", "%d.%m.%Y.") , STR_TO_DATE("25.11.2007.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10028 , 1 , "Martina" , "Kova??i??" , "Pozornik" , STR_TO_DATE("9.10.1967.", "%d.%m.%Y.") , STR_TO_DATE("7.5.2006.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10029 , 1 , "Aldo" , "Jankovi??" , "Satnik" , STR_TO_DATE("14.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("8.3.2017.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10030 , 3 , "Emelina" , "??imuni??" , "Razvodnik" , STR_TO_DATE("29.5.1958.", "%d.%m.%Y.") , STR_TO_DATE("13.5.2012.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10031 , 1 , "Esmeralda" , "Ru??i??" , "Pukovnik" , STR_TO_DATE("1.9.1953.", "%d.%m.%Y.") , STR_TO_DATE("26.2.2015.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10032 , 3 , "Ela" , "Kova??i??" , "Satnik" , STR_TO_DATE("8.7.1970.", "%d.%m.%Y.") , STR_TO_DATE("20.7.1995.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10033 , 1 , "Karina" , "??imi??" , "Pozornik" , STR_TO_DATE("7.7.1951.", "%d.%m.%Y.") , STR_TO_DATE("21.2.2013.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10034 , 2 , "Lara" , "Grgi??" , "Razvodnik" , STR_TO_DATE("28.4.1968.", "%d.%m.%Y.") , STR_TO_DATE("25.7.2013.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10035 , 2 , "Anatea" , "Lon??ari??" , "Skupnik" , STR_TO_DATE("8.2.1954.", "%d.%m.%Y.") , STR_TO_DATE("28.1.2005.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10036 , 2 , "Nova" , "Buri??" , "Narednik" , STR_TO_DATE("31.7.1968.", "%d.%m.%Y.") , STR_TO_DATE("24.8.2007.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10037 , 1 , "Marjan" , "Marjanovi??" , "Narednik" , STR_TO_DATE("30.10.1968.", "%d.%m.%Y.") , STR_TO_DATE("31.1.1995.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10038 , 2 , "Mirna" , "??ur??evi??" , "Pozornik" , STR_TO_DATE("27.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("3.12.2012.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10039 , 2 , "Slavica" , "Cvitkovi??" , "Pozornik" , STR_TO_DATE("11.5.1969.", "%d.%m.%Y.") , STR_TO_DATE("5.11.1998.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10040 , 2 , "Dorotej" , "Luki??" , "Pukovnik" , STR_TO_DATE("6.5.1956.", "%d.%m.%Y.") , STR_TO_DATE("21.9.2006.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10041 , 3 , "Dragutin" , "Novakovi??" , "Razvodnik" , STR_TO_DATE("17.5.1960.", "%d.%m.%Y.") , STR_TO_DATE("9.5.2000.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10042 , 2 , "Denis" , "Varga" , "Brigadir" , STR_TO_DATE("7.5.1967.", "%d.%m.%Y.") , STR_TO_DATE("14.10.2002.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10043 , 1 , "Milana" , "Horvat" , "Poru??nik" , STR_TO_DATE("11.6.1955.", "%d.%m.%Y.") , STR_TO_DATE("30.10.2017.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10044 , 3 , "Gvena" , "Varga" , "Pukovnik" , STR_TO_DATE("25.9.1963.", "%d.%m.%Y.") , STR_TO_DATE("2.8.2011.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10045 , 1 , "Penelopa" , "Grguri??" , "Bojnik" , STR_TO_DATE("19.2.1968.", "%d.%m.%Y.") , STR_TO_DATE("7.11.1998.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10046 , 4 , "Zarija" , "Marjanovi??" , "Narednik" , STR_TO_DATE("26.5.1955.", "%d.%m.%Y.") , STR_TO_DATE("7.3.2015.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10047 , 3 , "??eljkica" , "Matijevi??" , "Pozornik" , STR_TO_DATE("4.1.1962.", "%d.%m.%Y.") , STR_TO_DATE("31.7.2006.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10048 , 3 , "Julija" , "Ivanovi??" , "Poru??nik" , STR_TO_DATE("7.10.1965.", "%d.%m.%Y.") , STR_TO_DATE("27.1.2007.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10049 , 1 , "Dijana" , "Vukovi??" , "Poru??nik" , STR_TO_DATE("11.12.1969.", "%d.%m.%Y.") , STR_TO_DATE("8.12.2015.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10050 , 4 , "Lili" , "Jozi??" , "Pukovnik" , STR_TO_DATE("2.5.1955.", "%d.%m.%Y.") , STR_TO_DATE("22.1.2014.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10051 , 3 , "Jaro" , "Lu??i??" , "Poru??nik" , STR_TO_DATE("19.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("9.4.2003.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10052 , 3 , "Aleks" , "Lu??i??" , "Brigadir" , STR_TO_DATE("23.2.1967.", "%d.%m.%Y.") , STR_TO_DATE("26.12.2006.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10053 , 2 , "Elie" , "Gali??" , "Pukovnik" , STR_TO_DATE("2.3.1966.", "%d.%m.%Y.") , STR_TO_DATE("24.6.2018.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10054 , 4 , "Mihaela" , "Novak" , "Bojnik" , STR_TO_DATE("1.7.1969.", "%d.%m.%Y.") , STR_TO_DATE("20.8.1994.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10055 , 1 , "Matea" , "Sever" , "Poru??nik" , STR_TO_DATE("7.9.1958.", "%d.%m.%Y.") , STR_TO_DATE("16.1.2016.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10056 , 4 , "Antun" , "Bari??i??" , "Razvodnik" , STR_TO_DATE("17.10.1951.", "%d.%m.%Y.") , STR_TO_DATE("23.4.2018.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10057 , 4 , "Rhea" , "??ivkovi??" , "Narednik" , STR_TO_DATE("22.9.1964.", "%d.%m.%Y.") , STR_TO_DATE("28.2.1996.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10058 , 2 , "Mario" , "??imi??" , "Bojnik" , STR_TO_DATE("12.3.1951.", "%d.%m.%Y.") , STR_TO_DATE("10.8.1990.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10059 , 1 , "Jolena" , "??imuni??" , "Brigadir" , STR_TO_DATE("13.12.1961.", "%d.%m.%Y.") , STR_TO_DATE("14.2.2016.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10060 , 3 , "Dorotea" , "Kova??evi??" , "Poru??nik" , STR_TO_DATE("23.10.1968.", "%d.%m.%Y.") , STR_TO_DATE("30.4.2019.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10061 , 2 , "Nika" , "Juri??i??" , "Skupnik" , STR_TO_DATE("16.6.1960.", "%d.%m.%Y.") , STR_TO_DATE("18.12.2007.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10062 , 2 , "Sla??ana" , "Abramovi??" , "Pukovnik" , STR_TO_DATE("12.6.1970.", "%d.%m.%Y.") , STR_TO_DATE("22.4.1993.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10063 , 4 , "Ela" , "Grguri??" , "Brigadir" , STR_TO_DATE("28.11.1961.", "%d.%m.%Y.") , STR_TO_DATE("27.1.1994.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10064 , 4 , "Oto" , "Jankovi??" , "Poru??nik" , STR_TO_DATE("21.5.1966.", "%d.%m.%Y.") , STR_TO_DATE("14.10.1994.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10065 , 1 , "Alicija" , "Marjanovi??" , "Skupnik" , STR_TO_DATE("2.12.1954.", "%d.%m.%Y.") , STR_TO_DATE("14.3.1997.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10066 , 3 , "Nala" , "Tomi??" , "Razvodnik" , STR_TO_DATE("26.3.1958.", "%d.%m.%Y.") , STR_TO_DATE("31.5.2001.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10067 , 3 , "Zoi" , "Ivan??i??" , "Bojnik" , STR_TO_DATE("30.3.1968.", "%d.%m.%Y.") , STR_TO_DATE("15.10.2018.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10068 , 2 , "Magda" , "Peri??" , "Pukovnik" , STR_TO_DATE("10.1.1969.", "%d.%m.%Y.") , STR_TO_DATE("3.12.2017.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10069 , 4 , "Sendi" , "Popovi??" , "Skupnik" , STR_TO_DATE("5.9.1951.", "%d.%m.%Y.") , STR_TO_DATE("20.6.2020.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10070 , 3 , "Manda" , "Vidakovi??" , "Brigadir" , STR_TO_DATE("11.9.1958.", "%d.%m.%Y.") , STR_TO_DATE("8.10.2008.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10071 , 4 , "Harmina" , "Kne??evi??" , "Satnik" , STR_TO_DATE("29.5.1951.", "%d.%m.%Y.") , STR_TO_DATE("3.3.2005.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10072 , 1 , "Leon" , "Ru??i??" , "Skupnik" , STR_TO_DATE("8.4.1956.", "%d.%m.%Y.") , STR_TO_DATE("5.5.1991.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10073 , 4 , "Elana" , "Mandi??" , "Poru??nik" , STR_TO_DATE("27.1.1950.", "%d.%m.%Y.") , STR_TO_DATE("22.5.2002.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10074 , 4 , "Sendi" , "??imuni??" , "Poru??nik" , STR_TO_DATE("9.1.1950.", "%d.%m.%Y.") , STR_TO_DATE("24.12.2018.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10075 , 4 , "Lilika" , "Varga" , "Brigadir" , STR_TO_DATE("29.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("5.9.1992.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10076 , 3 , "Mihael" , "Kati??" , "Poru??nik" , STR_TO_DATE("21.10.1964.", "%d.%m.%Y.") , STR_TO_DATE("30.6.2005.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10077 , 1 , "Elivija" , "Peri??" , "Pukovnik" , STR_TO_DATE("23.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("25.1.2016.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10078 , 4 , "Goranka" , "Brki??" , "Bojnik" , STR_TO_DATE("26.3.1959.", "%d.%m.%Y.") , STR_TO_DATE("15.4.1999.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10079 , 1 , "Leonardo" , "Bili??" , "Bojnik" , STR_TO_DATE("21.6.1966.", "%d.%m.%Y.") , STR_TO_DATE("22.12.1990.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10080 , 4 , "Alora" , "Maru??i??" , "Satnik" , STR_TO_DATE("23.4.1960.", "%d.%m.%Y.") , STR_TO_DATE("12.3.2010.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10081 , 3 , "Sandi" , "Juri??" , "Pukovnik" , STR_TO_DATE("23.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("30.11.2016.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10082 , 1 , "Eta" , "Mati??" , "Razvodnik" , STR_TO_DATE("28.11.1950.", "%d.%m.%Y.") , STR_TO_DATE("13.12.2002.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10083 , 1 , "??ime" , "Klari??" , "Brigadir" , STR_TO_DATE("25.11.1968.", "%d.%m.%Y.") , STR_TO_DATE("21.7.2010.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10084 , 3 , "Azalea" , "Grguri??" , "Brigadir" , STR_TO_DATE("20.12.1950.", "%d.%m.%Y.") , STR_TO_DATE("8.5.2003.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10085 , 2 , "Amaja" , "Matkovi??" , "Poru??nik" , STR_TO_DATE("18.10.1970.", "%d.%m.%Y.") , STR_TO_DATE("6.7.2000.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10086 , 4 , "Lola" , "Filipovi??" , "Skupnik" , STR_TO_DATE("11.4.1950.", "%d.%m.%Y.") , STR_TO_DATE("25.2.2006.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10087 , 3 , "Sun??ana" , "Novakovi??" , "Satnik" , STR_TO_DATE("29.4.1956.", "%d.%m.%Y.") , STR_TO_DATE("22.1.2015.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10088 , 2 , "Kai" , "Luki??" , "Pukovnik" , STR_TO_DATE("27.1.1958.", "%d.%m.%Y.") , STR_TO_DATE("1.6.1996.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10089 , 2 , "Severina" , "Kralj" , "Brigadir" , STR_TO_DATE("2.5.1960.", "%d.%m.%Y.") , STR_TO_DATE("4.1.2017.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10090 , 2 , "Tihana" , "Vrdoljak" , "Pukovnik" , STR_TO_DATE("8.5.1957.", "%d.%m.%Y.") , STR_TO_DATE("12.6.2000.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10091 , 1 , "Julijana" , "Luki??" , "Bojnik" , STR_TO_DATE("11.5.1967.", "%d.%m.%Y.") , STR_TO_DATE("21.7.1991.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10092 , 3 , "Cvijeta" , "Ivankovi??" , "Pukovnik" , STR_TO_DATE("11.5.1969.", "%d.%m.%Y.") , STR_TO_DATE("22.3.2013.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10093 , 3 , "Viena" , "Matijevi??" , "Skupnik" , STR_TO_DATE("23.6.1960.", "%d.%m.%Y.") , STR_TO_DATE("13.9.1994.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10094 , 3 , "Zoi" , "Mati??" , "Razvodnik" , STR_TO_DATE("4.3.1954.", "%d.%m.%Y.") , STR_TO_DATE("11.5.2018.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10095 , 2 , "Teresa" , "Butkovi??" , "Brigadir" , STR_TO_DATE("24.9.1964.", "%d.%m.%Y.") , STR_TO_DATE("16.6.1990.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10096 , 2 , "Jadranko" , "Perkovi??" , "Pozornik" , STR_TO_DATE("21.2.1951.", "%d.%m.%Y.") , STR_TO_DATE("16.11.2020.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10097 , 2 , "Slaven" , "Dujmovi??" , "Razvodnik" , STR_TO_DATE("21.12.1970.", "%d.%m.%Y.") , STR_TO_DATE("30.11.2002.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10098 , 3 , "Alana" , "Jovanovi??" , "Skupnik" , STR_TO_DATE("14.2.1966.", "%d.%m.%Y.") , STR_TO_DATE("17.5.2010.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10099 , 2 , "Antun" , "Bili??" , "Bojnik" , STR_TO_DATE("8.4.1969.", "%d.%m.%Y.") , STR_TO_DATE("4.9.2018.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10100 , 4 , "Barbara" , "Jeli??" , "Pozornik" , STR_TO_DATE("5.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("17.12.2009.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10101 , 3 , "Liv" , "Perkovi??" , "Pukovnik" , STR_TO_DATE("27.11.1951.", "%d.%m.%Y.") , STR_TO_DATE("4.10.1991.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10102 , 2 , "Zoe" , "Pavli??" , "Narednik" , STR_TO_DATE("8.9.1969.", "%d.%m.%Y.") , STR_TO_DATE("14.4.2018.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10103 , 4 , "Zvjezdana" , "Jeli??" , "Bojnik" , STR_TO_DATE("14.6.1966.", "%d.%m.%Y.") , STR_TO_DATE("11.4.2013.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10104 , 3 , "Zarija" , "Mandi??" , "Brigadir" , STR_TO_DATE("24.5.1965.", "%d.%m.%Y.") , STR_TO_DATE("26.9.2019.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10105 , 2 , "Teo" , "Lon??ar" , "Brigadir" , STR_TO_DATE("13.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("11.2.1992.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10106 , 4 , "Levi" , "Buri??" , "Razvodnik" , STR_TO_DATE("4.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("20.9.1994.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10107 , 1 , "Oto" , "Popovi??" , "Pozornik" , STR_TO_DATE("28.2.1970.", "%d.%m.%Y.") , STR_TO_DATE("30.12.1991.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10108 , 1 , "Emil" , "Bo??njak" , "Bojnik" , STR_TO_DATE("7.5.1958.", "%d.%m.%Y.") , STR_TO_DATE("5.6.2011.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10109 , 3 , "Valentin" , "Brajkovi??" , "Brigadir" , STR_TO_DATE("16.8.1964.", "%d.%m.%Y.") , STR_TO_DATE("31.3.2006.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10110 , 1 , "Mae" , "Tomi??" , "Razvodnik" , STR_TO_DATE("14.6.1960.", "%d.%m.%Y.") , STR_TO_DATE("25.10.2020.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10111 , 3 , "Josipa" , "Posavec" , "Bojnik" , STR_TO_DATE("27.5.1964.", "%d.%m.%Y.") , STR_TO_DATE("28.3.2020.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10112 , 1 , "Siri" , "??imuni??" , "Bojnik" , STR_TO_DATE("9.4.1960.", "%d.%m.%Y.") , STR_TO_DATE("1.8.1994.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10113 , 2 , "Leonardo" , "Mandi??" , "Narednik" , STR_TO_DATE("6.7.1960.", "%d.%m.%Y.") , STR_TO_DATE("26.9.1993.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10114 , 2 , "Lena" , "??imunovi??" , "Pozornik" , STR_TO_DATE("29.12.1959.", "%d.%m.%Y.") , STR_TO_DATE("9.5.2003.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10115 , 1 , "David" , "Lu??i??" , "Skupnik" , STR_TO_DATE("8.6.1951.", "%d.%m.%Y.") , STR_TO_DATE("13.8.2005.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10116 , 1 , "Jaro" , "Krznari??" , "Satnik" , STR_TO_DATE("5.4.1953.", "%d.%m.%Y.") , STR_TO_DATE("25.9.1991.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10117 , 4 , "Demi" , "Jovanovi??" , "Satnik" , STR_TO_DATE("27.4.1965.", "%d.%m.%Y.") , STR_TO_DATE("28.11.2002.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10118 , 2 , "Adela" , "Kolari??" , "Satnik" , STR_TO_DATE("17.12.1963.", "%d.%m.%Y.") , STR_TO_DATE("8.2.2008.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10119 , 3 , "Katarina" , "Matkovi??" , "Pozornik" , STR_TO_DATE("31.7.1962.", "%d.%m.%Y.") , STR_TO_DATE("9.7.2009.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10120 , 2 , "Vada" , "Kova??i??" , "Pukovnik" , STR_TO_DATE("17.12.1953.", "%d.%m.%Y.") , STR_TO_DATE("6.11.2009.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10121 , 4 , "Neven" , "??ari??" , "Skupnik" , STR_TO_DATE("6.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("28.8.2002.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10122 , 4 , "Jolena" , "Horvat" , "Poru??nik" , STR_TO_DATE("11.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("17.2.1997.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10123 , 4 , "Dragica" , "Kova??evi??" , "Brigadir" , STR_TO_DATE("18.8.1959.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2004.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10124 , 4 , "Arijela" , "Rukavina" , "Satnik" , STR_TO_DATE("16.1.1967.", "%d.%m.%Y.") , STR_TO_DATE("10.3.2016.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10125 , 2 , "Martina" , "Babi??" , "Brigadir" , STR_TO_DATE("2.1.1970.", "%d.%m.%Y.") , STR_TO_DATE("10.7.1998.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10126 , 3 , "Jasmina" , "Novosel" , "Poru??nik" , STR_TO_DATE("13.3.1956.", "%d.%m.%Y.") , STR_TO_DATE("17.6.2004.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10127 , 3 , "Mila" , "Perkovi??" , "Bojnik" , STR_TO_DATE("1.4.1962.", "%d.%m.%Y.") , STR_TO_DATE("17.7.2012.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10128 , 1 , "Ezra" , "Posavec" , "Razvodnik" , STR_TO_DATE("7.7.1960.", "%d.%m.%Y.") , STR_TO_DATE("24.12.2004.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10129 , 2 , "Maksima" , "Crnkovi??" , "Bojnik" , STR_TO_DATE("11.2.1970.", "%d.%m.%Y.") , STR_TO_DATE("23.12.2013.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10130 , 4 , "Zola" , "??imunovi??" , "Razvodnik" , STR_TO_DATE("21.10.1968.", "%d.%m.%Y.") , STR_TO_DATE("20.9.2012.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10131 , 4 , "Penelopa" , "Sever" , "Pukovnik" , STR_TO_DATE("30.11.1957.", "%d.%m.%Y.") , STR_TO_DATE("27.1.1997.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10132 , 2 , "Leona" , "Ivankovi??" , "Pozornik" , STR_TO_DATE("22.10.1950.", "%d.%m.%Y.") , STR_TO_DATE("19.12.1993.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10133 , 4 , "Kiana" , "Klari??" , "Razvodnik" , STR_TO_DATE("29.3.1967.", "%d.%m.%Y.") , STR_TO_DATE("27.1.1994.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10134 , 2 , "Kali" , "Dragi??evi??" , "Pukovnik" , STR_TO_DATE("21.10.1953.", "%d.%m.%Y.") , STR_TO_DATE("26.1.2006.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10135 , 4 , "Tomislava" , "Jeli??" , "Satnik" , STR_TO_DATE("12.11.1959.", "%d.%m.%Y.") , STR_TO_DATE("22.9.1991.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10136 , 2 , "Manuel" , "??ur??evi??" , "Satnik" , STR_TO_DATE("25.5.1958.", "%d.%m.%Y.") , STR_TO_DATE("5.10.2002.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10137 , 3 , "Nia" , "Juri??" , "Pozornik" , STR_TO_DATE("28.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("27.1.2004.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10138 , 3 , "Ksaver" , "Buri??" , "Poru??nik" , STR_TO_DATE("30.6.1963.", "%d.%m.%Y.") , STR_TO_DATE("26.5.2016.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10139 , 2 , "Jerko" , "Mitrovi??" , "Razvodnik" , STR_TO_DATE("4.3.1951.", "%d.%m.%Y.") , STR_TO_DATE("22.2.2012.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10140 , 4 , "Tina" , "Petrovi??" , "Bojnik" , STR_TO_DATE("18.9.1962.", "%d.%m.%Y.") , STR_TO_DATE("23.5.2012.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10141 , 2 , "Severino" , "Bo??i??" , "Bojnik" , STR_TO_DATE("25.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("30.4.2020.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10142 , 3 , "Lika" , "Kralj" , "Brigadir" , STR_TO_DATE("6.6.1953.", "%d.%m.%Y.") , STR_TO_DATE("14.9.2004.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10143 , 1 , "Darko" , "Ivankovi??" , "Poru??nik" , STR_TO_DATE("28.3.1957.", "%d.%m.%Y.") , STR_TO_DATE("28.5.2004.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10144 , 1 , "Jada" , "Dujmovi??" , "Skupnik" , STR_TO_DATE("17.5.1961.", "%d.%m.%Y.") , STR_TO_DATE("5.5.1998.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10145 , 1 , "Aleksandra" , "Jozi??" , "Poru??nik" , STR_TO_DATE("14.12.1952.", "%d.%m.%Y.") , STR_TO_DATE("12.9.2007.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10146 , 4 , "Marcel" , "Kolari??" , "Satnik" , STR_TO_DATE("11.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("19.1.2002.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10147 , 3 , "Romea" , "Markovi??" , "Bojnik" , STR_TO_DATE("15.12.1965.", "%d.%m.%Y.") , STR_TO_DATE("5.12.2010.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10148 , 1 , "Dunja" , "Kova??i??" , "Skupnik" , STR_TO_DATE("9.7.1961.", "%d.%m.%Y.") , STR_TO_DATE("19.6.1999.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10149 , 1 , "Sun??ana" , "Dujmovi??" , "Bojnik" , STR_TO_DATE("9.2.1970.", "%d.%m.%Y.") , STR_TO_DATE("17.11.2017.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10150 , 3 , "Divna" , "Gali??" , "Brigadir" , STR_TO_DATE("20.3.1959.", "%d.%m.%Y.") , STR_TO_DATE("1.7.2001.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10151 , 4 , "Mikaela" , "Bla??evi??" , "Razvodnik" , STR_TO_DATE("7.1.1965.", "%d.%m.%Y.") , STR_TO_DATE("22.4.1992.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10152 , 4 , "Natalija" , "Jankovi??" , "Bojnik" , STR_TO_DATE("22.12.1958.", "%d.%m.%Y.") , STR_TO_DATE("29.4.1993.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10153 , 1 , "Oskar" , "Perkovi??" , "Bojnik" , STR_TO_DATE("11.3.1952.", "%d.%m.%Y.") , STR_TO_DATE("3.10.2015.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10154 , 2 , "Estela" , "Bla??evi??" , "Narednik" , STR_TO_DATE("3.4.1957.", "%d.%m.%Y.") , STR_TO_DATE("23.12.2003.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10155 , 2 , "Koraljka" , "Kova??" , "Brigadir" , STR_TO_DATE("4.6.1966.", "%d.%m.%Y.") , STR_TO_DATE("25.3.2008.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10156 , 3 , "Hai" , "Vidakovi??" , "Satnik" , STR_TO_DATE("16.10.1969.", "%d.%m.%Y.") , STR_TO_DATE("6.2.2013.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10157 , 2 , "Hada" , "Mari??" , "Pozornik" , STR_TO_DATE("10.2.1960.", "%d.%m.%Y.") , STR_TO_DATE("20.10.2018.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10158 , 2 , "Alea" , "Jeli??" , "Razvodnik" , STR_TO_DATE("21.12.1965.", "%d.%m.%Y.") , STR_TO_DATE("28.4.2007.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10159 , 2 , "Serena" , "Kne??evi??" , "Pukovnik" , STR_TO_DATE("18.12.1955.", "%d.%m.%Y.") , STR_TO_DATE("8.12.2017.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10160 , 2 , "Amaia" , "Rukavina" , "Pukovnik" , STR_TO_DATE("27.7.1966.", "%d.%m.%Y.") , STR_TO_DATE("29.5.2010.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10161 , 1 , "Ivano" , "Mileti??" , "Bojnik" , STR_TO_DATE("28.6.1953.", "%d.%m.%Y.") , STR_TO_DATE("7.11.2009.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10162 , 3 , "Briela" , "Jakovljevi??" , "Skupnik" , STR_TO_DATE("31.8.1965.", "%d.%m.%Y.") , STR_TO_DATE("13.10.1995.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10163 , 3 , "Tristan" , "??uri??" , "Pukovnik" , STR_TO_DATE("16.1.1958.", "%d.%m.%Y.") , STR_TO_DATE("19.8.1997.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10164 , 1 , "Nikolina" , "Gali??" , "Poru??nik" , STR_TO_DATE("9.10.1953.", "%d.%m.%Y.") , STR_TO_DATE("5.7.1990.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10165 , 3 , "Rohan" , "Kova??i??" , "Razvodnik" , STR_TO_DATE("11.4.1966.", "%d.%m.%Y.") , STR_TO_DATE("22.7.1992.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10166 , 4 , "Liam" , "??imunovi??" , "Pukovnik" , STR_TO_DATE("5.5.1960.", "%d.%m.%Y.") , STR_TO_DATE("22.12.2008.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10167 , 2 , "Kaja" , "Brajkovi??" , "Satnik" , STR_TO_DATE("16.10.1966.", "%d.%m.%Y.") , STR_TO_DATE("11.8.1993.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10168 , 2 , "Vada" , "Kralj" , "Pozornik" , STR_TO_DATE("22.2.1956.", "%d.%m.%Y.") , STR_TO_DATE("20.5.2018.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10169 , 1 , "Sumka" , "Grguri??" , "Narednik" , STR_TO_DATE("4.11.1951.", "%d.%m.%Y.") , STR_TO_DATE("3.6.2008.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10170 , 4 , "Toni" , "Vukovi??" , "Razvodnik" , STR_TO_DATE("27.10.1966.", "%d.%m.%Y.") , STR_TO_DATE("26.12.2016.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10171 , 3 , "Loreta" , "??ur??evi??" , "Satnik" , STR_TO_DATE("1.3.1958.", "%d.%m.%Y.") , STR_TO_DATE("28.5.2014.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10172 , 2 , "Martina" , "Kne??evi??" , "Narednik" , STR_TO_DATE("21.2.1967.", "%d.%m.%Y.") , STR_TO_DATE("10.10.2013.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10173 , 1 , "Martina" , "Josipovi??" , "Razvodnik" , STR_TO_DATE("2.11.1968.", "%d.%m.%Y.") , STR_TO_DATE("30.6.1999.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10174 , 3 , "Klementina" , "Jankovi??" , "Razvodnik" , STR_TO_DATE("13.4.1962.", "%d.%m.%Y.") , STR_TO_DATE("11.10.1991.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10175 , 3 , "Lile" , "Cindri??" , "Poru??nik" , STR_TO_DATE("29.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.6.1990.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10176 , 2 , "Eliza" , "Vukovi??" , "Satnik" , STR_TO_DATE("1.2.1966.", "%d.%m.%Y.") , STR_TO_DATE("18.3.2004.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10177 , 4 , "??eljkica" , "Vidovi??" , "Brigadir" , STR_TO_DATE("29.1.1969.", "%d.%m.%Y.") , STR_TO_DATE("16.5.2016.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10178 , 3 , "Franko" , "Butkovi??" , "Skupnik" , STR_TO_DATE("18.11.1967.", "%d.%m.%Y.") , STR_TO_DATE("1.4.1993.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10179 , 2 , "Pepa" , "Nikoli??" , "Brigadir" , STR_TO_DATE("1.7.1970.", "%d.%m.%Y.") , STR_TO_DATE("5.9.2018.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10180 , 3 , "Mauro" , "Kne??evi??" , "Brigadir" , STR_TO_DATE("4.6.1962.", "%d.%m.%Y.") , STR_TO_DATE("31.7.2013.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10181 , 1 , "Salema" , "Bla??evi??" , "Bojnik" , STR_TO_DATE("27.11.1951.", "%d.%m.%Y.") , STR_TO_DATE("9.12.2009.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10182 , 1 , "Adam" , "??imunovi??" , "Narednik" , STR_TO_DATE("7.3.1960.", "%d.%m.%Y.") , STR_TO_DATE("10.5.2011.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10183 , 3 , "Leonida" , "Vidakovi??" , "Pukovnik" , STR_TO_DATE("22.4.1956.", "%d.%m.%Y.") , STR_TO_DATE("12.12.2018.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10184 , 3 , "Bara" , "Perkovi??" , "Razvodnik" , STR_TO_DATE("11.3.1958.", "%d.%m.%Y.") , STR_TO_DATE("28.6.2013.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10185 , 2 , "Delila" , "Dragi??evi??" , "Brigadir" , STR_TO_DATE("14.7.1955.", "%d.%m.%Y.") , STR_TO_DATE("11.11.2013.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10186 , 4 , "Davina" , "Peri??" , "Pukovnik" , STR_TO_DATE("28.12.1957.", "%d.%m.%Y.") , STR_TO_DATE("11.3.1996.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10187 , 2 , "Leonid" , "Markovi??" , "Pozornik" , STR_TO_DATE("16.11.1952.", "%d.%m.%Y.") , STR_TO_DATE("8.11.2015.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10188 , 1 , "Siena" , "Bo??i??" , "Satnik" , STR_TO_DATE("4.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("7.12.2020.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10189 , 1 , "Anabela" , "Ba??i??" , "Pozornik" , STR_TO_DATE("18.5.1966.", "%d.%m.%Y.") , STR_TO_DATE("3.8.2020.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10190 , 4 , "Bela" , "Varga" , "Brigadir" , STR_TO_DATE("16.12.1960.", "%d.%m.%Y.") , STR_TO_DATE("1.9.1993.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10191 , 1 , "Amir" , "Bo??i??" , "Poru??nik" , STR_TO_DATE("8.9.1965.", "%d.%m.%Y.") , STR_TO_DATE("19.11.2010.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10192 , 2 , "??ina" , "Perkovi??" , "Brigadir" , STR_TO_DATE("25.8.1953.", "%d.%m.%Y.") , STR_TO_DATE("26.3.1997.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10193 , 3 , "Rubi" , "Grguri??" , "Pukovnik" , STR_TO_DATE("16.2.1954.", "%d.%m.%Y.") , STR_TO_DATE("12.2.2002.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10194 , 3 , "Daniel" , "Brajkovi??" , "Satnik" , STR_TO_DATE("11.8.1956.", "%d.%m.%Y.") , STR_TO_DATE("30.9.1997.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10195 , 2 , "Karmela" , "Crnkovi??" , "Pozornik" , STR_TO_DATE("14.10.1958.", "%d.%m.%Y.") , STR_TO_DATE("28.8.1998.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10196 , 3 , "Filip" , "Pavlovi??" , "Satnik" , STR_TO_DATE("2.1.1951.", "%d.%m.%Y.") , STR_TO_DATE("10.4.2003.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10197 , 1 , "Kaila" , "Matkovi??" , "Brigadir" , STR_TO_DATE("16.10.1962.", "%d.%m.%Y.") , STR_TO_DATE("18.4.2000.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10198 , 4 , "Princa" , "Luki??" , "Brigadir" , STR_TO_DATE("23.4.1966.", "%d.%m.%Y.") , STR_TO_DATE("15.11.2003.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10199 , 2 , "Roberta" , "Grgi??" , "Razvodnik" , STR_TO_DATE("31.1.1954.", "%d.%m.%Y.") , STR_TO_DATE("29.12.1993.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10200 , 1 , "Ediza" , "Mikuli??" , "Brigadir" , STR_TO_DATE("11.9.1964.", "%d.%m.%Y.") , STR_TO_DATE("20.6.2013.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10201 , 1 , "Janko" , "Kova??" , "Bojnik" , STR_TO_DATE("20.11.1968.", "%d.%m.%Y.") , STR_TO_DATE("17.11.2017.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10202 , 4 , "Gema" , "Pavlovi??" , "Narednik" , STR_TO_DATE("24.1.1969.", "%d.%m.%Y.") , STR_TO_DATE("28.3.1998.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10203 , 3 , "Filip" , "Vrdoljak" , "Brigadir" , STR_TO_DATE("20.12.1962.", "%d.%m.%Y.") , STR_TO_DATE("6.9.2017.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10204 , 2 , "Iris" , "Vu??kovi??" , "Pukovnik" , STR_TO_DATE("12.4.1967.", "%d.%m.%Y.") , STR_TO_DATE("26.6.2006.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10205 , 4 , "Miranda" , "Crnkovi??" , "Razvodnik" , STR_TO_DATE("10.11.1952.", "%d.%m.%Y.") , STR_TO_DATE("9.6.2006.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10206 , 2 , "Paola" , "Petrovi??" , "Narednik" , STR_TO_DATE("2.5.1969.", "%d.%m.%Y.") , STR_TO_DATE("23.11.1995.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10207 , 4 , "Pavle" , "Mandi??" , "Satnik" , STR_TO_DATE("17.12.1967.", "%d.%m.%Y.") , STR_TO_DATE("22.7.2020.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10208 , 2 , "Karolina" , "??ari??" , "Brigadir" , STR_TO_DATE("3.7.1961.", "%d.%m.%Y.") , STR_TO_DATE("15.1.2005.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10209 , 4 , "Marija" , "Kralj" , "Narednik" , STR_TO_DATE("10.12.1951.", "%d.%m.%Y.") , STR_TO_DATE("29.4.1998.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10210 , 2 , "Levi" , "Filipovi??" , "Poru??nik" , STR_TO_DATE("8.7.1965.", "%d.%m.%Y.") , STR_TO_DATE("6.6.2003.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10211 , 2 , "Nikol" , "Mandi??" , "Pukovnik" , STR_TO_DATE("27.2.1968.", "%d.%m.%Y.") , STR_TO_DATE("11.1.1994.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10212 , 3 , "Kai" , "Novosel" , "Poru??nik" , STR_TO_DATE("17.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("1.6.2012.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10213 , 2 , "Eva" , "Bo??njak" , "Pukovnik" , STR_TO_DATE("2.11.1961.", "%d.%m.%Y.") , STR_TO_DATE("5.10.2011.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10214 , 2 , "Leonardo" , "Abramovi??" , "Poru??nik" , STR_TO_DATE("25.9.1951.", "%d.%m.%Y.") , STR_TO_DATE("2.1.2000.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10215 , 2 , "Tim" , "Kne??evi??" , "Brigadir" , STR_TO_DATE("15.7.1960.", "%d.%m.%Y.") , STR_TO_DATE("16.1.1998.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10216 , 2 , "Ela" , "??imi??" , "Brigadir" , STR_TO_DATE("21.8.1967.", "%d.%m.%Y.") , STR_TO_DATE("30.5.1999.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10217 , 4 , "Aleksandra" , "Jeli??" , "Narednik" , STR_TO_DATE("4.6.1961.", "%d.%m.%Y.") , STR_TO_DATE("5.8.1994.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10218 , 2 , "Tim" , "??ivkovi??" , "Pukovnik" , STR_TO_DATE("26.7.1958.", "%d.%m.%Y.") , STR_TO_DATE("20.10.2009.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10219 , 3 , "Simon" , "Bari??i??" , "Satnik" , STR_TO_DATE("27.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("27.4.1992.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10220 , 3 , "Ita" , "Jankovi??" , "Poru??nik" , STR_TO_DATE("2.12.1956.", "%d.%m.%Y.") , STR_TO_DATE("8.11.2000.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10221 , 1 , "Armina" , "Maru??i??" , "Pukovnik" , STR_TO_DATE("25.11.1951.", "%d.%m.%Y.") , STR_TO_DATE("29.4.2005.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10222 , 3 , "Mara" , "Ru??i??" , "Pukovnik" , STR_TO_DATE("4.7.1957.", "%d.%m.%Y.") , STR_TO_DATE("15.10.2005.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10223 , 4 , "Lada" , "Lon??ar" , "Brigadir" , STR_TO_DATE("7.12.1957.", "%d.%m.%Y.") , STR_TO_DATE("16.3.2015.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10224 , 2 , "Florenca" , "Novosel" , "Bojnik" , STR_TO_DATE("23.10.1959.", "%d.%m.%Y.") , STR_TO_DATE("10.12.2000.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10225 , 2 , "Dalia" , "Peri??" , "Brigadir" , STR_TO_DATE("9.2.1969.", "%d.%m.%Y.") , STR_TO_DATE("30.8.2005.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10226 , 4 , "Samara" , "Novakovi??" , "Narednik" , STR_TO_DATE("5.12.1962.", "%d.%m.%Y.") , STR_TO_DATE("12.6.1990.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10227 , 1 , "Kiara" , "??imunovi??" , "Pukovnik" , STR_TO_DATE("27.5.1961.", "%d.%m.%Y.") , STR_TO_DATE("27.10.1994.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10228 , 3 , "Aziel" , "Tomi??" , "Pozornik" , STR_TO_DATE("17.8.1969.", "%d.%m.%Y.") , STR_TO_DATE("19.2.2001.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10229 , 3 , "Levi" , "Kolari??" , "Skupnik" , STR_TO_DATE("21.5.1964.", "%d.%m.%Y.") , STR_TO_DATE("9.5.2012.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10230 , 1 , "Liam" , "Grgi??" , "Poru??nik" , STR_TO_DATE("14.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("13.2.2010.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10231 , 4 , "Luna" , "Maru??i??" , "Bojnik" , STR_TO_DATE("9.7.1961.", "%d.%m.%Y.") , STR_TO_DATE("19.12.1997.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10232 , 4 , "Marica" , "Horvat" , "Poru??nik" , STR_TO_DATE("17.8.1961.", "%d.%m.%Y.") , STR_TO_DATE("1.3.2019.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10233 , 2 , "Gvena" , "Vrdoljak" , "Pozornik" , STR_TO_DATE("24.2.1950.", "%d.%m.%Y.") , STR_TO_DATE("20.4.1995.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10234 , 3 , "Ivo" , "Abramovi??" , "Skupnik" , STR_TO_DATE("6.1.1968.", "%d.%m.%Y.") , STR_TO_DATE("24.9.2009.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10235 , 2 , "Oli" , "Vu??kovi??" , "Satnik" , STR_TO_DATE("13.12.1965.", "%d.%m.%Y.") , STR_TO_DATE("14.1.2015.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10236 , 4 , "Alija" , "Markovi??" , "Brigadir" , STR_TO_DATE("18.9.1970.", "%d.%m.%Y.") , STR_TO_DATE("23.8.2004.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10237 , 4 , "Mira" , "Ru??i??" , "Satnik" , STR_TO_DATE("7.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("12.6.2005.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10238 , 1 , "Maca" , "Tomi??" , "Skupnik" , STR_TO_DATE("9.4.1960.", "%d.%m.%Y.") , STR_TO_DATE("23.11.2001.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10239 , 4 , "Franjo" , "Lon??ar" , "Brigadir" , STR_TO_DATE("31.10.1954.", "%d.%m.%Y.") , STR_TO_DATE("28.9.1991.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10240 , 1 , "Ante" , "Pavli??" , "Pozornik" , STR_TO_DATE("19.1.1966.", "%d.%m.%Y.") , STR_TO_DATE("21.12.2000.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10241 , 1 , "Loreta" , "Bo??njak" , "Pukovnik" , STR_TO_DATE("22.5.1970.", "%d.%m.%Y.") , STR_TO_DATE("23.3.2011.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10242 , 3 , "Amber" , "Sever" , "Poru??nik" , STR_TO_DATE("6.8.1968.", "%d.%m.%Y.") , STR_TO_DATE("28.3.2015.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10243 , 1 , "Josipa" , "Pavlovi??" , "Brigadir" , STR_TO_DATE("15.11.1953.", "%d.%m.%Y.") , STR_TO_DATE("9.9.2019.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10244 , 3 , "Dejan" , "Posavec" , "Poru??nik" , STR_TO_DATE("8.4.1968.", "%d.%m.%Y.") , STR_TO_DATE("23.12.2000.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10245 , 3 , "Miroslava" , "Jakovljevi??" , "Narednik" , STR_TO_DATE("19.4.1967.", "%d.%m.%Y.") , STR_TO_DATE("28.9.2017.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10246 , 2 , "Sre??ko" , "Bari??i??" , "Razvodnik" , STR_TO_DATE("29.7.1966.", "%d.%m.%Y.") , STR_TO_DATE("28.1.1994.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10247 , 1 , "Mio" , "Kne??evi??" , "Pukovnik" , STR_TO_DATE("15.5.1959.", "%d.%m.%Y.") , STR_TO_DATE("10.12.2005.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10248 , 1 , "Kina" , "Juki??" , "Skupnik" , STR_TO_DATE("3.1.1955.", "%d.%m.%Y.") , STR_TO_DATE("24.10.1997.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10249 , 3 , "Zakarija" , "??ivkovi??" , "Satnik" , STR_TO_DATE("24.10.1957.", "%d.%m.%Y.") , STR_TO_DATE("19.1.2015.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10250 , 2 , "Sanja" , "Grgi??" , "Skupnik" , STR_TO_DATE("27.2.1970.", "%d.%m.%Y.") , STR_TO_DATE("16.11.2004.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10251 , 2 , "Oli" , "Crnkovi??" , "Brigadir" , STR_TO_DATE("23.2.1953.", "%d.%m.%Y.") , STR_TO_DATE("17.10.1995.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10252 , 2 , "Greta" , "Juki??" , "Pozornik" , STR_TO_DATE("10.2.1952.", "%d.%m.%Y.") , STR_TO_DATE("27.12.2013.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10253 , 1 , "Nata??a" , "Novosel" , "Satnik" , STR_TO_DATE("20.8.1957.", "%d.%m.%Y.") , STR_TO_DATE("26.5.2013.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10254 , 2 , "Tereza" , "Babi??" , "Brigadir" , STR_TO_DATE("9.2.1954.", "%d.%m.%Y.") , STR_TO_DATE("11.12.2007.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10255 , 3 , "Elora" , "Kolari??" , "Bojnik" , STR_TO_DATE("27.6.1961.", "%d.%m.%Y.") , STR_TO_DATE("22.6.2006.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10256 , 2 , "Lejla" , "Tomi??" , "Poru??nik" , STR_TO_DATE("11.7.1957.", "%d.%m.%Y.") , STR_TO_DATE("28.5.1993.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10257 , 2 , "Romea" , "Mari??" , "Pozornik" , STR_TO_DATE("25.4.1956.", "%d.%m.%Y.") , STR_TO_DATE("30.6.1990.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10258 , 4 , "Ane" , "Jozi??" , "Pukovnik" , STR_TO_DATE("2.2.1960.", "%d.%m.%Y.") , STR_TO_DATE("20.10.2008.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10259 , 2 , "Simona" , "Crnkovi??" , "Skupnik" , STR_TO_DATE("14.10.1960.", "%d.%m.%Y.") , STR_TO_DATE("4.3.1999.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10260 , 3 , "Irena" , "Petrovi??" , "Skupnik" , STR_TO_DATE("22.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("10.9.2014.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10261 , 1 , "Marina" , "Juri??" , "Satnik" , STR_TO_DATE("11.5.1950.", "%d.%m.%Y.") , STR_TO_DATE("25.12.2014.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10262 , 4 , "Mirijam" , "Pavlovi??" , "Skupnik" , STR_TO_DATE("10.11.1952.", "%d.%m.%Y.") , STR_TO_DATE("12.8.1994.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10263 , 3 , "Magda" , "Bla??evi??" , "Razvodnik" , STR_TO_DATE("7.12.1968.", "%d.%m.%Y.") , STR_TO_DATE("22.12.2008.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10264 , 4 , "Lovorka" , "Lon??ar" , "Satnik" , STR_TO_DATE("30.4.1951.", "%d.%m.%Y.") , STR_TO_DATE("11.1.1998.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10265 , 1 , "Jara" , "Tomi??" , "Narednik" , STR_TO_DATE("27.10.1961.", "%d.%m.%Y.") , STR_TO_DATE("8.2.2012.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10266 , 1 , "Disa" , "Ivanovi??" , "Satnik" , STR_TO_DATE("13.4.1961.", "%d.%m.%Y.") , STR_TO_DATE("21.11.1999.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10267 , 4 , "Simon" , "Mitrovi??" , "Narednik" , STR_TO_DATE("22.2.1963.", "%d.%m.%Y.") , STR_TO_DATE("10.1.2017.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10268 , 2 , "Anastasija" , "Dragi??evi??" , "Poru??nik" , STR_TO_DATE("30.8.1964.", "%d.%m.%Y.") , STR_TO_DATE("10.8.2013.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10269 , 1 , "Breta" , "Babi??" , "Bojnik" , STR_TO_DATE("25.3.1969.", "%d.%m.%Y.") , STR_TO_DATE("29.1.2016.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10270 , 4 , "Barbara" , "Jurkovi??" , "Skupnik" , STR_TO_DATE("2.2.1964.", "%d.%m.%Y.") , STR_TO_DATE("28.6.2008.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10271 , 3 , "Noela" , "Horvat" , "Bojnik" , STR_TO_DATE("12.8.1951.", "%d.%m.%Y.") , STR_TO_DATE("10.6.2011.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10272 , 1 , "Leandro" , "Mileti??" , "Bojnik" , STR_TO_DATE("29.3.1963.", "%d.%m.%Y.") , STR_TO_DATE("25.7.2014.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10273 , 1 , "Dra??enka" , "Bari??i??" , "Brigadir" , STR_TO_DATE("15.4.1969.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2010.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10274 , 3 , "Lora" , "??ari??" , "Skupnik" , STR_TO_DATE("12.5.1957.", "%d.%m.%Y.") , STR_TO_DATE("20.11.2005.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10275 , 4 , "Jakov" , "Bili??" , "Razvodnik" , STR_TO_DATE("25.10.1965.", "%d.%m.%Y.") , STR_TO_DATE("30.10.1996.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10276 , 1 , "Monika" , "??imunovi??" , "Pukovnik" , STR_TO_DATE("26.9.1955.", "%d.%m.%Y.") , STR_TO_DATE("2.1.2005.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10277 , 3 , "Azalea" , "Tomi??" , "Razvodnik" , STR_TO_DATE("3.4.1957.", "%d.%m.%Y.") , STR_TO_DATE("15.6.2018.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10278 , 1 , "Ramona" , "Novakovi??" , "Narednik" , STR_TO_DATE("10.4.1962.", "%d.%m.%Y.") , STR_TO_DATE("9.4.1992.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10279 , 4 , "Romina" , "Krznari??" , "Poru??nik" , STR_TO_DATE("18.2.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.3.1992.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10280 , 4 , "Rubika" , "Bla??evi??" , "Narednik" , STR_TO_DATE("8.7.1965.", "%d.%m.%Y.") , STR_TO_DATE("20.10.1998.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10281 , 1 , "Nova" , "Dujmovi??" , "Pozornik" , STR_TO_DATE("4.1.1950.", "%d.%m.%Y.") , STR_TO_DATE("11.4.2017.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10282 , 3 , "Darinka" , "??uri??" , "Bojnik" , STR_TO_DATE("16.8.1964.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2004.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10283 , 4 , "Nika" , "Pavlovi??" , "Poru??nik" , STR_TO_DATE("13.7.1969.", "%d.%m.%Y.") , STR_TO_DATE("2.5.2008.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10284 , 4 , "Lada" , "Grubi??i??" , "Satnik" , STR_TO_DATE("24.2.1967.", "%d.%m.%Y.") , STR_TO_DATE("27.11.2018.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10285 , 4 , "Nikolina" , "Pavi??" , "Pukovnik" , STR_TO_DATE("28.12.1968.", "%d.%m.%Y.") , STR_TO_DATE("5.5.2002.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10286 , 4 , "Loreta" , "Cindri??" , "Satnik" , STR_TO_DATE("3.4.1957.", "%d.%m.%Y.") , STR_TO_DATE("24.11.2020.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10287 , 2 , "??aklina" , "Vukeli??" , "Poru??nik" , STR_TO_DATE("2.11.1968.", "%d.%m.%Y.") , STR_TO_DATE("4.4.1992.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10288 , 1 , "Mara" , "Filipovi??" , "Skupnik" , STR_TO_DATE("14.12.1953.", "%d.%m.%Y.") , STR_TO_DATE("19.8.2015.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10289 , 2 , "Hrvojka" , "Jur??evi??" , "Pozornik" , STR_TO_DATE("26.2.1959.", "%d.%m.%Y.") , STR_TO_DATE("21.2.2004.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10290 , 4 , "Naja" , "Antunovi??" , "Pozornik" , STR_TO_DATE("10.8.1961.", "%d.%m.%Y.") , STR_TO_DATE("18.6.2003.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10291 , 3 , "Delila" , "Vukeli??" , "Pukovnik" , STR_TO_DATE("5.8.1968.", "%d.%m.%Y.") , STR_TO_DATE("13.6.2009.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10292 , 3 , "Eli" , "Mikuli??" , "Narednik" , STR_TO_DATE("5.4.1968.", "%d.%m.%Y.") , STR_TO_DATE("22.2.2013.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10293 , 3 , "David" , "Kne??evi??" , "Skupnik" , STR_TO_DATE("7.8.1959.", "%d.%m.%Y.") , STR_TO_DATE("6.5.2014.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10294 , 1 , "Artemisa" , "Dragi??evi??" , "Razvodnik" , STR_TO_DATE("13.2.1960.", "%d.%m.%Y.") , STR_TO_DATE("29.3.1997.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10295 , 3 , "Ante" , "Juki??" , "Bojnik" , STR_TO_DATE("28.3.1950.", "%d.%m.%Y.") , STR_TO_DATE("8.3.2008.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10296 , 2 , "Evica" , "Mandi??" , "Pukovnik" , STR_TO_DATE("15.7.1952.", "%d.%m.%Y.") , STR_TO_DATE("15.6.2015.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10297 , 2 , "Edita" , "Petkovi??" , "Razvodnik" , STR_TO_DATE("19.3.1961.", "%d.%m.%Y.") , STR_TO_DATE("27.6.2015.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10298 , 3 , "Janko" , "Posavec" , "Razvodnik" , STR_TO_DATE("24.7.1952.", "%d.%m.%Y.") , STR_TO_DATE("3.6.1996.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10299 , 1 , "Andrija" , "Vukeli??" , "Skupnik" , STR_TO_DATE("30.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("28.1.1999.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10300 , 1 , "Amaja" , "Mandi??" , "Brigadir" , STR_TO_DATE("3.11.1957.", "%d.%m.%Y.") , STR_TO_DATE("20.2.2006.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10301 , 3 , "Bosiljka" , "Vu??kovi??" , "Brigadir" , STR_TO_DATE("31.12.1951.", "%d.%m.%Y.") , STR_TO_DATE("11.11.2012.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10302 , 1 , "Benjamin" , "Stani??" , "Pukovnik" , STR_TO_DATE("28.2.1964.", "%d.%m.%Y.") , STR_TO_DATE("27.6.2009.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10303 , 1 , "Gvena" , "Nikoli??" , "Narednik" , STR_TO_DATE("17.11.1950.", "%d.%m.%Y.") , STR_TO_DATE("9.5.2009.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10304 , 1 , "Leana" , "Luki??" , "Pozornik" , STR_TO_DATE("3.12.1970.", "%d.%m.%Y.") , STR_TO_DATE("15.10.1994.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10305 , 1 , "Naja" , "Vidakovi??" , "Razvodnik" , STR_TO_DATE("19.11.1969.", "%d.%m.%Y.") , STR_TO_DATE("30.10.1992.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10306 , 3 , "Jura" , "Grgi??" , "Narednik" , STR_TO_DATE("12.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("15.7.2005.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10307 , 2 , "Evelin" , "Buri??" , "Brigadir" , STR_TO_DATE("7.12.1964.", "%d.%m.%Y.") , STR_TO_DATE("22.3.2008.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10308 , 3 , "Iko" , "Perkovi??" , "Bojnik" , STR_TO_DATE("20.1.1960.", "%d.%m.%Y.") , STR_TO_DATE("18.11.2008.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10309 , 1 , "Desa" , "Juri??i??" , "Pukovnik" , STR_TO_DATE("24.2.1959.", "%d.%m.%Y.") , STR_TO_DATE("9.2.1990.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10310 , 2 , "Klarisa" , "Juri??i??" , "Bojnik" , STR_TO_DATE("12.2.1952.", "%d.%m.%Y.") , STR_TO_DATE("15.8.1996.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10311 , 2 , "Ben" , "Klari??" , "Narednik" , STR_TO_DATE("7.7.1965.", "%d.%m.%Y.") , STR_TO_DATE("9.7.1990.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10312 , 2 , "Tristan" , "Popovi??" , "Brigadir" , STR_TO_DATE("3.7.1952.", "%d.%m.%Y.") , STR_TO_DATE("18.10.2017.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10313 , 1 , "Kata" , "Mitrovi??" , "Satnik" , STR_TO_DATE("23.3.1959.", "%d.%m.%Y.") , STR_TO_DATE("28.10.2015.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10314 , 2 , "Lobel" , "Perkovi??" , "Pozornik" , STR_TO_DATE("3.7.1964.", "%d.%m.%Y.") , STR_TO_DATE("18.3.1992.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10315 , 1 , "Leonid" , "Martinovi??" , "Razvodnik" , STR_TO_DATE("22.2.1951.", "%d.%m.%Y.") , STR_TO_DATE("25.12.2010.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10316 , 4 , "Bruna" , "??imunovi??" , "Skupnik" , STR_TO_DATE("11.3.1965.", "%d.%m.%Y.") , STR_TO_DATE("29.1.1995.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10317 , 1 , "Ljerka" , "Crnkovi??" , "Skupnik" , STR_TO_DATE("3.3.1960.", "%d.%m.%Y.") , STR_TO_DATE("15.7.2015.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10318 , 4 , "Romina" , "Vrdoljak" , "Skupnik" , STR_TO_DATE("25.8.1960.", "%d.%m.%Y.") , STR_TO_DATE("8.4.1991.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10319 , 3 , "Adela" , "Josipovi??" , "Razvodnik" , STR_TO_DATE("22.12.1957.", "%d.%m.%Y.") , STR_TO_DATE("22.4.2016.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10320 , 3 , "Lucijano" , "Petkovi??" , "Satnik" , STR_TO_DATE("22.3.1967.", "%d.%m.%Y.") , STR_TO_DATE("5.7.2012.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10321 , 2 , "Kiana" , "Lu??i??" , "Narednik" , STR_TO_DATE("16.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("24.12.2013.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10322 , 2 , "Irena" , "Butkovi??" , "Skupnik" , STR_TO_DATE("15.10.1962.", "%d.%m.%Y.") , STR_TO_DATE("11.4.2010.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10323 , 3 , "Martea" , "Pavlovi??" , "Pozornik" , STR_TO_DATE("15.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("14.9.2018.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10324 , 2 , "Dajana" , "Kne??evi??" , "Pukovnik" , STR_TO_DATE("4.4.1952.", "%d.%m.%Y.") , STR_TO_DATE("1.5.2017.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10325 , 4 , "Lav" , "Lon??ar" , "Pozornik" , STR_TO_DATE("21.7.1956.", "%d.%m.%Y.") , STR_TO_DATE("20.3.2018.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10326 , 1 , "Siri" , "Kolari??" , "Pozornik" , STR_TO_DATE("1.9.1961.", "%d.%m.%Y.") , STR_TO_DATE("6.7.2020.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10327 , 4 , "Olga" , "Kolari??" , "Narednik" , STR_TO_DATE("18.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("27.6.1999.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10328 , 3 , "Denisa" , "Mikuli??" , "Poru??nik" , STR_TO_DATE("12.3.1961.", "%d.%m.%Y.") , STR_TO_DATE("4.2.2000.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10329 , 2 , "Lucijano" , "Vukeli??" , "Narednik" , STR_TO_DATE("7.5.1967.", "%d.%m.%Y.") , STR_TO_DATE("25.12.2003.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10330 , 2 , "Rivka" , "Kova??i??" , "Pozornik" , STR_TO_DATE("15.5.1966.", "%d.%m.%Y.") , STR_TO_DATE("1.12.2004.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10331 , 1 , "Madison" , "Petkovi??" , "Razvodnik" , STR_TO_DATE("5.7.1959.", "%d.%m.%Y.") , STR_TO_DATE("13.5.2006.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10332 , 1 , "Aida" , "Bili??" , "Pozornik" , STR_TO_DATE("8.5.1961.", "%d.%m.%Y.") , STR_TO_DATE("10.8.2013.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10333 , 2 , "Julijan" , "Juri??" , "Poru??nik" , STR_TO_DATE("25.9.1954.", "%d.%m.%Y.") , STR_TO_DATE("11.11.1991.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10334 , 4 , "Florenca" , "Klari??" , "Razvodnik" , STR_TO_DATE("26.4.1950.", "%d.%m.%Y.") , STR_TO_DATE("25.6.2003.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10335 , 2 , "Ada" , "Grguri??" , "Razvodnik" , STR_TO_DATE("15.12.1956.", "%d.%m.%Y.") , STR_TO_DATE("20.2.2018.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10336 , 2 , "Greta" , "Bili??" , "Poru??nik" , STR_TO_DATE("14.1.1964.", "%d.%m.%Y.") , STR_TO_DATE("31.8.1991.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10337 , 3 , "Alea" , "Bari??i??" , "Poru??nik" , STR_TO_DATE("29.10.1959.", "%d.%m.%Y.") , STR_TO_DATE("26.6.2017.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10338 , 1 , "Kina" , "Kralj" , "Skupnik" , STR_TO_DATE("2.2.1963.", "%d.%m.%Y.") , STR_TO_DATE("20.5.1992.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10339 , 1 , "Jolena" , "Novakovi??" , "Bojnik" , STR_TO_DATE("1.1.1957.", "%d.%m.%Y.") , STR_TO_DATE("20.1.2000.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10340 , 4 , "Margareta" , "Radi??" , "Poru??nik" , STR_TO_DATE("3.1.1960.", "%d.%m.%Y.") , STR_TO_DATE("22.12.2005.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10341 , 3 , "Natalija" , "??imunovi??" , "Pozornik" , STR_TO_DATE("11.5.1956.", "%d.%m.%Y.") , STR_TO_DATE("23.3.1999.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10342 , 1 , "Katja" , "Grguri??" , "Narednik" , STR_TO_DATE("10.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("11.1.2008.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10343 , 3 , "Sla??ana" , "Kova??evi??" , "Razvodnik" , STR_TO_DATE("24.2.1964.", "%d.%m.%Y.") , STR_TO_DATE("1.12.1992.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10344 , 1 , "Leksi" , "Jankovi??" , "Brigadir" , STR_TO_DATE("18.3.1962.", "%d.%m.%Y.") , STR_TO_DATE("27.12.1996.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10345 , 2 , "Pavel" , "Popovi??" , "Narednik" , STR_TO_DATE("16.6.1956.", "%d.%m.%Y.") , STR_TO_DATE("13.10.2016.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10346 , 2 , "Vigo" , "Bo??i??" , "Brigadir" , STR_TO_DATE("10.4.1951.", "%d.%m.%Y.") , STR_TO_DATE("6.3.2020.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10347 , 3 , "Elanija" , "Kralj" , "Skupnik" , STR_TO_DATE("29.12.1958.", "%d.%m.%Y.") , STR_TO_DATE("18.4.2013.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10348 , 3 , "Lidija" , "Mati??" , "Narednik" , STR_TO_DATE("25.12.1968.", "%d.%m.%Y.") , STR_TO_DATE("2.6.1995.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10349 , 1 , "Etna" , "Bari??i??" , "Poru??nik" , STR_TO_DATE("12.10.1951.", "%d.%m.%Y.") , STR_TO_DATE("20.8.2007.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10350 , 1 , "Filipa" , "Pavli??" , "Pozornik" , STR_TO_DATE("6.8.1956.", "%d.%m.%Y.") , STR_TO_DATE("9.1.2017.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10351 , 4 , "Ton??ica" , "Dragi??evi??" , "Brigadir" , STR_TO_DATE("21.11.1969.", "%d.%m.%Y.") , STR_TO_DATE("28.4.2010.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10352 , 1 , "Ljudevit" , "Crnkovi??" , "Bojnik" , STR_TO_DATE("8.3.1968.", "%d.%m.%Y.") , STR_TO_DATE("28.2.1998.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10353 , 4 , "Andrija" , "Vukeli??" , "Satnik" , STR_TO_DATE("26.3.1961.", "%d.%m.%Y.") , STR_TO_DATE("29.5.2011.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10354 , 4 , "Romea" , "??imuni??" , "Pozornik" , STR_TO_DATE("22.8.1954.", "%d.%m.%Y.") , STR_TO_DATE("25.4.1994.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10355 , 2 , "Slaven" , "??uri??" , "Brigadir" , STR_TO_DATE("26.10.1969.", "%d.%m.%Y.") , STR_TO_DATE("29.5.2017.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10356 , 4 , "Agata" , "Filipovi??" , "Skupnik" , STR_TO_DATE("11.3.1954.", "%d.%m.%Y.") , STR_TO_DATE("29.6.1991.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10357 , 4 , "Rea" , "Kralj" , "Skupnik" , STR_TO_DATE("2.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("20.1.2000.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10358 , 3 , "Daniel" , "??uri??" , "Skupnik" , STR_TO_DATE("18.2.1952.", "%d.%m.%Y.") , STR_TO_DATE("26.7.1993.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10359 , 2 , "Matej" , "Buri??" , "Poru??nik" , STR_TO_DATE("18.3.1954.", "%d.%m.%Y.") , STR_TO_DATE("3.12.1998.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10360 , 2 , "??eljkica" , "Abramovi??" , "Poru??nik" , STR_TO_DATE("10.2.1968.", "%d.%m.%Y.") , STR_TO_DATE("30.6.2000.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10361 , 3 , "Beata" , "Novak" , "Brigadir" , STR_TO_DATE("23.9.1957.", "%d.%m.%Y.") , STR_TO_DATE("13.6.1991.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10362 , 1 , "Elora" , "Jurkovi??" , "Narednik" , STR_TO_DATE("18.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("24.9.1998.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10363 , 1 , "Koa" , "Matkovi??" , "Bojnik" , STR_TO_DATE("4.1.1951.", "%d.%m.%Y.") , STR_TO_DATE("2.1.2009.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10364 , 3 , "Parka" , "??ari??" , "Bojnik" , STR_TO_DATE("23.10.1967.", "%d.%m.%Y.") , STR_TO_DATE("18.7.2016.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10365 , 3 , "Judita" , "Buri??" , "Pukovnik" , STR_TO_DATE("25.4.1952.", "%d.%m.%Y.") , STR_TO_DATE("12.6.1992.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10366 , 2 , "Ofelia" , "Horvat" , "Poru??nik" , STR_TO_DATE("18.3.1961.", "%d.%m.%Y.") , STR_TO_DATE("13.3.2005.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10367 , 1 , "Noel" , "Bla??evi??" , "Skupnik" , STR_TO_DATE("28.2.1959.", "%d.%m.%Y.") , STR_TO_DATE("6.8.2002.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10368 , 3 , "Malija" , "Mileti??" , "Bojnik" , STR_TO_DATE("12.8.1967.", "%d.%m.%Y.") , STR_TO_DATE("29.7.2006.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10369 , 1 , "Igor" , "Lovri??" , "Pozornik" , STR_TO_DATE("15.6.1957.", "%d.%m.%Y.") , STR_TO_DATE("13.7.2000.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10370 , 4 , "Sofija" , "Bo??njak" , "Bojnik" , STR_TO_DATE("3.6.1954.", "%d.%m.%Y.") , STR_TO_DATE("10.7.2019.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10371 , 1 , "Alesia" , "Buri??" , "Brigadir" , STR_TO_DATE("20.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("26.5.2011.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10372 , 2 , "Sa??a" , "Antunovi??" , "Satnik" , STR_TO_DATE("14.11.1961.", "%d.%m.%Y.") , STR_TO_DATE("7.10.2009.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10373 , 4 , "Igor" , "Jur??evi??" , "Bojnik" , STR_TO_DATE("4.6.1966.", "%d.%m.%Y.") , STR_TO_DATE("10.7.2004.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10374 , 2 , "Lili" , "Golubi??" , "Razvodnik" , STR_TO_DATE("15.1.1950.", "%d.%m.%Y.") , STR_TO_DATE("12.5.2002.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10375 , 2 , "Filip" , "Kova??" , "Razvodnik" , STR_TO_DATE("15.7.1959.", "%d.%m.%Y.") , STR_TO_DATE("9.7.2002.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10376 , 3 , "Cecilija" , "Babi??" , "Pozornik" , STR_TO_DATE("11.8.1958.", "%d.%m.%Y.") , STR_TO_DATE("6.12.1999.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10377 , 3 , "Pavao" , "??uri??" , "Brigadir" , STR_TO_DATE("5.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("19.3.2011.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10378 , 3 , "Elizabeta" , "Babi??" , "Pozornik" , STR_TO_DATE("27.4.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2009.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10379 , 3 , "Paisa" , "Klari??" , "Pukovnik" , STR_TO_DATE("24.5.1965.", "%d.%m.%Y.") , STR_TO_DATE("26.3.2004.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10380 , 3 , "Ema" , "Vu??kovi??" , "Satnik" , STR_TO_DATE("6.8.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.11.2000.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10381 , 3 , "Zoja" , "Brajkovi??" , "Pozornik" , STR_TO_DATE("10.7.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.6.2012.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10382 , 1 , "Melkiot" , "??ari??" , "Brigadir" , STR_TO_DATE("20.1.1951.", "%d.%m.%Y.") , STR_TO_DATE("6.8.2017.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10383 , 1 , "Rina" , "Vukeli??" , "Razvodnik" , STR_TO_DATE("14.12.1962.", "%d.%m.%Y.") , STR_TO_DATE("21.4.2015.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10384 , 4 , "Roberta" , "Matkovi??" , "Poru??nik" , STR_TO_DATE("3.1.1967.", "%d.%m.%Y.") , STR_TO_DATE("25.10.2000.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10385 , 2 , "Gloria" , "??imunovi??" , "Bojnik" , STR_TO_DATE("20.2.1963.", "%d.%m.%Y.") , STR_TO_DATE("18.1.2001.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10386 , 4 , "Elivija" , "Mitrovi??" , "Skupnik" , STR_TO_DATE("8.11.1956.", "%d.%m.%Y.") , STR_TO_DATE("18.2.2011.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10387 , 2 , "Bela" , "Jankovi??" , "Pozornik" , STR_TO_DATE("28.7.1961.", "%d.%m.%Y.") , STR_TO_DATE("12.7.2016.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10388 , 3 , "??imun" , "Buri??" , "Razvodnik" , STR_TO_DATE("1.7.1951.", "%d.%m.%Y.") , STR_TO_DATE("11.12.2014.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10389 , 3 , "Izak" , "Markovi??" , "Skupnik" , STR_TO_DATE("20.4.1960.", "%d.%m.%Y.") , STR_TO_DATE("18.3.2011.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10390 , 1 , "Princa" , "Vukeli??" , "Bojnik" , STR_TO_DATE("31.10.1958.", "%d.%m.%Y.") , STR_TO_DATE("15.5.2010.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10391 , 1 , "Lukas" , "Vu??kovi??" , "Bojnik" , STR_TO_DATE("9.3.1969.", "%d.%m.%Y.") , STR_TO_DATE("1.4.2007.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10392 , 1 , "Stjepan" , "Bari??i??" , "Brigadir" , STR_TO_DATE("6.2.1954.", "%d.%m.%Y.") , STR_TO_DATE("30.6.1995.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10393 , 2 , "Valerija" , "Petrovi??" , "Skupnik" , STR_TO_DATE("17.7.1965.", "%d.%m.%Y.") , STR_TO_DATE("14.1.2016.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10394 , 2 , "Marcel" , "Novosel" , "Narednik" , STR_TO_DATE("6.3.1965.", "%d.%m.%Y.") , STR_TO_DATE("12.10.2000.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10395 , 4 , "Lora" , "??imuni??" , "Brigadir" , STR_TO_DATE("15.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("29.3.2009.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10396 , 2 , "Samuel" , "Posavec" , "Narednik" , STR_TO_DATE("21.5.1967.", "%d.%m.%Y.") , STR_TO_DATE("19.1.2012.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10397 , 2 , "Lea" , "??ari??" , "Pozornik" , STR_TO_DATE("26.3.1955.", "%d.%m.%Y.") , STR_TO_DATE("3.4.2005.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10398 , 3 , "Michelle" , "Lon??ar" , "Razvodnik" , STR_TO_DATE("26.9.1966.", "%d.%m.%Y.") , STR_TO_DATE("26.2.2019.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10399 , 1 , "Antonija" , "Kova??i??" , "Skupnik" , STR_TO_DATE("18.10.1965.", "%d.%m.%Y.") , STR_TO_DATE("14.1.2000.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10400 , 2 , "Mirna" , "Vidovi??" , "Satnik" , STR_TO_DATE("11.5.1953.", "%d.%m.%Y.") , STR_TO_DATE("7.7.1992.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10401 , 3 , "Ivano" , "Matijevi??" , "Bojnik" , STR_TO_DATE("24.1.1965.", "%d.%m.%Y.") , STR_TO_DATE("23.12.2012.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10402 , 4 , "Dragutin" , "??ur??evi??" , "Brigadir" , STR_TO_DATE("10.6.1954.", "%d.%m.%Y.") , STR_TO_DATE("30.12.2015.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10403 , 4 , "Klementina" , "Martinovi??" , "Poru??nik" , STR_TO_DATE("23.1.1950.", "%d.%m.%Y.") , STR_TO_DATE("5.12.2001.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10404 , 1 , "Nevena" , "Vidakovi??" , "Pozornik" , STR_TO_DATE("14.8.1964.", "%d.%m.%Y.") , STR_TO_DATE("6.1.2019.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10405 , 4 , "Josipa" , "Peri??" , "Bojnik" , STR_TO_DATE("4.8.1957.", "%d.%m.%Y.") , STR_TO_DATE("8.2.2018.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10406 , 2 , "Lilia" , "Juri??i??" , "Pukovnik" , STR_TO_DATE("22.1.1959.", "%d.%m.%Y.") , STR_TO_DATE("22.1.1993.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10407 , 1 , "Madison" , "Jakovljevi??" , "Narednik" , STR_TO_DATE("15.12.1965.", "%d.%m.%Y.") , STR_TO_DATE("19.6.2005.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10408 , 2 , "Valentin" , "Radi??" , "Bojnik" , STR_TO_DATE("25.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("17.5.2006.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10409 , 1 , "David" , "Sever" , "Satnik" , STR_TO_DATE("18.9.1953.", "%d.%m.%Y.") , STR_TO_DATE("10.8.1998.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10410 , 1 , "Lea" , "Vrdoljak" , "Skupnik" , STR_TO_DATE("11.6.1953.", "%d.%m.%Y.") , STR_TO_DATE("29.8.1994.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10411 , 4 , "Olja" , "Novosel" , "Brigadir" , STR_TO_DATE("30.4.1956.", "%d.%m.%Y.") , STR_TO_DATE("5.9.2009.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10412 , 1 , "Zola" , "Babi??" , "Bojnik" , STR_TO_DATE("27.5.1959.", "%d.%m.%Y.") , STR_TO_DATE("29.5.2014.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10413 , 1 , "Siena" , "Josipovi??" , "Poru??nik" , STR_TO_DATE("9.8.1960.", "%d.%m.%Y.") , STR_TO_DATE("13.9.1992.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10414 , 1 , "Emil" , "Novakovi??" , "Bojnik" , STR_TO_DATE("28.7.1958.", "%d.%m.%Y.") , STR_TO_DATE("11.8.2003.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10415 , 3 , "Savana" , "Lon??ar" , "Skupnik" , STR_TO_DATE("19.5.1963.", "%d.%m.%Y.") , STR_TO_DATE("11.7.1997.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10416 , 3 , "Ramona" , "Vidakovi??" , "Satnik" , STR_TO_DATE("5.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("4.2.2018.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10417 , 2 , "Krista" , "Butkovi??" , "Poru??nik" , STR_TO_DATE("2.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("25.11.2008.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10418 , 4 , "Goranka" , "Bla??evi??" , "Pozornik" , STR_TO_DATE("5.9.1953.", "%d.%m.%Y.") , STR_TO_DATE("26.1.1991.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10419 , 2 , "Kre??imir" , "??uri??" , "Pukovnik" , STR_TO_DATE("12.7.1965.", "%d.%m.%Y.") , STR_TO_DATE("2.1.2003.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10420 , 1 , "Jura" , "Butkovi??" , "Poru??nik" , STR_TO_DATE("14.1.1954.", "%d.%m.%Y.") , STR_TO_DATE("3.5.2002.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10421 , 4 , "Dora" , "Grgi??" , "Razvodnik" , STR_TO_DATE("1.7.1951.", "%d.%m.%Y.") , STR_TO_DATE("25.1.2008.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10422 , 2 , "Mara" , "Bo??njak" , "Narednik" , STR_TO_DATE("7.2.1953.", "%d.%m.%Y.") , STR_TO_DATE("2.8.2018.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10423 , 3 , "Rubika" , "Kne??evi??" , "Pukovnik" , STR_TO_DATE("24.10.1961.", "%d.%m.%Y.") , STR_TO_DATE("22.12.2015.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10424 , 3 , "Dora" , "Mitrovi??" , "Skupnik" , STR_TO_DATE("30.3.1959.", "%d.%m.%Y.") , STR_TO_DATE("8.10.1991.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10425 , 3 , "Lora" , "Antunovi??" , "Brigadir" , STR_TO_DATE("12.12.1961.", "%d.%m.%Y.") , STR_TO_DATE("23.2.2003.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10426 , 3 , "Marlin" , "Pavli??" , "Skupnik" , STR_TO_DATE("15.4.1970.", "%d.%m.%Y.") , STR_TO_DATE("3.12.1998.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10427 , 3 , "Karina" , "Jankovi??" , "Pukovnik" , STR_TO_DATE("4.9.1951.", "%d.%m.%Y.") , STR_TO_DATE("8.5.1999.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10428 , 4 , "Arav" , "Bo??i??" , "Bojnik" , STR_TO_DATE("13.1.1954.", "%d.%m.%Y.") , STR_TO_DATE("11.12.2013.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10429 , 2 , "Mateo" , "Bili??" , "Razvodnik" , STR_TO_DATE("18.10.1958.", "%d.%m.%Y.") , STR_TO_DATE("4.3.2007.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10430 , 4 , "Aurelia" , "Bla??evi??" , "Narednik" , STR_TO_DATE("30.4.1961.", "%d.%m.%Y.") , STR_TO_DATE("7.1.2018.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10431 , 4 , "Kendra" , "Ivanovi??" , "Pozornik" , STR_TO_DATE("29.8.1951.", "%d.%m.%Y.") , STR_TO_DATE("1.1.1997.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10432 , 3 , "Andrija" , "Antunovi??" , "Brigadir" , STR_TO_DATE("11.12.1968.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2010.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10433 , 2 , "Chaja" , "Mikuli??" , "Brigadir" , STR_TO_DATE("7.11.1969.", "%d.%m.%Y.") , STR_TO_DATE("12.8.2000.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10434 , 3 , "Dunja" , "Cindri??" , "Pukovnik" , STR_TO_DATE("7.6.1952.", "%d.%m.%Y.") , STR_TO_DATE("14.3.2007.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10435 , 3 , "Dorotej" , "Ivankovi??" , "Skupnik" , STR_TO_DATE("6.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("23.6.2001.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10436 , 3 , "Adela" , "Ru??i??" , "Pukovnik" , STR_TO_DATE("15.3.1959.", "%d.%m.%Y.") , STR_TO_DATE("13.10.2003.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10437 , 2 , "Sara" , "Mileti??" , "Poru??nik" , STR_TO_DATE("15.5.1963.", "%d.%m.%Y.") , STR_TO_DATE("12.12.2012.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10438 , 4 , "Eta" , "Radi??" , "Satnik" , STR_TO_DATE("30.11.1964.", "%d.%m.%Y.") , STR_TO_DATE("10.6.2001.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10439 , 2 , "Eli" , "Ivanovi??" , "Pozornik" , STR_TO_DATE("9.12.1964.", "%d.%m.%Y.") , STR_TO_DATE("2.7.1996.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10440 , 2 , "Dina" , "Vidakovi??" , "Pozornik" , STR_TO_DATE("26.11.1954.", "%d.%m.%Y.") , STR_TO_DATE("25.11.2000.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10441 , 4 , "Karolina" , "Jozi??" , "Skupnik" , STR_TO_DATE("15.2.1957.", "%d.%m.%Y.") , STR_TO_DATE("27.3.2003.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10442 , 2 , "Patrik" , "Grgi??" , "Poru??nik" , STR_TO_DATE("1.2.1958.", "%d.%m.%Y.") , STR_TO_DATE("26.12.2017.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10443 , 1 , "Ljerka" , "Jurkovi??" , "Skupnik" , STR_TO_DATE("29.7.1953.", "%d.%m.%Y.") , STR_TO_DATE("11.9.2008.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10444 , 4 , "Marcel" , "Posavec" , "Brigadir" , STR_TO_DATE("23.7.1959.", "%d.%m.%Y.") , STR_TO_DATE("18.11.1999.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10445 , 1 , "Lucija" , "Kralj" , "Bojnik" , STR_TO_DATE("23.8.1967.", "%d.%m.%Y.") , STR_TO_DATE("14.12.2010.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10446 , 1 , "Ivan" , "??imuni??" , "Bojnik" , STR_TO_DATE("3.11.1962.", "%d.%m.%Y.") , STR_TO_DATE("23.6.2001.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10447 , 2 , "Franciska" , "Nikoli??" , "Pukovnik" , STR_TO_DATE("3.8.1962.", "%d.%m.%Y.") , STR_TO_DATE("19.4.1995.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10448 , 2 , "Rajna" , "Bo??i??" , "Bojnik" , STR_TO_DATE("18.5.1963.", "%d.%m.%Y.") , STR_TO_DATE("3.9.2010.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10449 , 4 , "Mada" , "Mari??" , "Bojnik" , STR_TO_DATE("17.7.1970.", "%d.%m.%Y.") , STR_TO_DATE("27.1.2005.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10450 , 2 , "Eva" , "Jovanovi??" , "Satnik" , STR_TO_DATE("7.9.1950.", "%d.%m.%Y.") , STR_TO_DATE("16.10.1993.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10451 , 2 , "Ela" , "Buri??" , "Skupnik" , STR_TO_DATE("5.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("16.7.2000.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10452 , 1 , "Naja" , "Filipovi??" , "Pozornik" , STR_TO_DATE("10.12.1965.", "%d.%m.%Y.") , STR_TO_DATE("21.8.2009.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10453 , 2 , "Paisa" , "Mikuli??" , "Narednik" , STR_TO_DATE("29.4.1960.", "%d.%m.%Y.") , STR_TO_DATE("20.1.2019.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10454 , 4 , "Tia" , "Rukavina" , "Narednik" , STR_TO_DATE("1.10.1952.", "%d.%m.%Y.") , STR_TO_DATE("19.6.2003.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10455 , 3 , "Toni" , "Bla??evi??" , "Pozornik" , STR_TO_DATE("7.5.1969.", "%d.%m.%Y.") , STR_TO_DATE("30.9.2008.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10456 , 3 , "Tiana" , "Golubi??" , "Pukovnik" , STR_TO_DATE("18.1.1956.", "%d.%m.%Y.") , STR_TO_DATE("9.7.2018.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10457 , 3 , "Juda" , "Ru??i??" , "Skupnik" , STR_TO_DATE("25.3.1963.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2014.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10458 , 2 , "Ezra" , "Rukavina" , "Bojnik" , STR_TO_DATE("3.3.1970.", "%d.%m.%Y.") , STR_TO_DATE("7.3.1992.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10459 , 4 , "Lucijano" , "Jovanovi??" , "Skupnik" , STR_TO_DATE("11.4.1968.", "%d.%m.%Y.") , STR_TO_DATE("21.11.2009.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10460 , 3 , "Karlo" , "Marjanovi??" , "Razvodnik" , STR_TO_DATE("24.10.1960.", "%d.%m.%Y.") , STR_TO_DATE("24.11.2015.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10461 , 1 , "Viktor" , "Vu??kovi??" , "Pozornik" , STR_TO_DATE("27.6.1961.", "%d.%m.%Y.") , STR_TO_DATE("24.5.1990.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10462 , 4 , "Anabela" , "Lon??ari??" , "Satnik" , STR_TO_DATE("16.8.1960.", "%d.%m.%Y.") , STR_TO_DATE("21.10.2011.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10463 , 3 , "Magdalena" , "Maru??i??" , "Pozornik" , STR_TO_DATE("15.9.1965.", "%d.%m.%Y.") , STR_TO_DATE("22.6.1995.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10464 , 1 , "Hara" , "Lovri??" , "Pukovnik" , STR_TO_DATE("11.6.1958.", "%d.%m.%Y.") , STR_TO_DATE("24.8.2015.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10465 , 4 , "Gabrijel" , "Mikuli??" , "Razvodnik" , STR_TO_DATE("9.6.1951.", "%d.%m.%Y.") , STR_TO_DATE("21.11.1990.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10466 , 3 , "Moli" , "Novosel" , "Narednik" , STR_TO_DATE("4.11.1969.", "%d.%m.%Y.") , STR_TO_DATE("20.2.1991.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10467 , 3 , "Izak" , "Tomi??" , "Bojnik" , STR_TO_DATE("8.8.1962.", "%d.%m.%Y.") , STR_TO_DATE("29.7.1996.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10468 , 1 , "??iril" , "Mitrovi??" , "Narednik" , STR_TO_DATE("18.7.1964.", "%d.%m.%Y.") , STR_TO_DATE("27.12.2015.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10469 , 1 , "Aden" , "Horvat" , "Narednik" , STR_TO_DATE("9.5.1958.", "%d.%m.%Y.") , STR_TO_DATE("28.3.1990.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10470 , 2 , "Briela" , "Mikuli??" , "Bojnik" , STR_TO_DATE("8.3.1958.", "%d.%m.%Y.") , STR_TO_DATE("20.3.2015.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10471 , 3 , "Eliana" , "Crnkovi??" , "Poru??nik" , STR_TO_DATE("14.2.1953.", "%d.%m.%Y.") , STR_TO_DATE("4.10.1999.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10472 , 3 , "Duje" , "Markovi??" , "Brigadir" , STR_TO_DATE("19.11.1966.", "%d.%m.%Y.") , STR_TO_DATE("3.2.1994.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10473 , 2 , "Desa" , "Juki??" , "Pozornik" , STR_TO_DATE("5.5.1956.", "%d.%m.%Y.") , STR_TO_DATE("11.2.2015.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10474 , 4 , "Stjepan" , "Kati??" , "Brigadir" , STR_TO_DATE("11.3.1954.", "%d.%m.%Y.") , STR_TO_DATE("18.12.2014.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10475 , 2 , "Hrvojka" , "Grubi??i??" , "Pukovnik" , STR_TO_DATE("21.8.1967.", "%d.%m.%Y.") , STR_TO_DATE("7.7.1992.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10476 , 2 , "Janko" , "Posavec" , "Razvodnik" , STR_TO_DATE("13.4.1952.", "%d.%m.%Y.") , STR_TO_DATE("12.2.2020.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10477 , 3 , "Krsto" , "??imunovi??" , "Narednik" , STR_TO_DATE("13.10.1961.", "%d.%m.%Y.") , STR_TO_DATE("18.2.1992.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10478 , 1 , "Marcela" , "Kova??i??" , "Razvodnik" , STR_TO_DATE("10.7.1956.", "%d.%m.%Y.") , STR_TO_DATE("24.9.1998.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10479 , 4 , "Elana" , "Herceg" , "Pozornik" , STR_TO_DATE("24.7.1956.", "%d.%m.%Y.") , STR_TO_DATE("5.2.1990.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10480 , 4 , "Jan" , "Ba??i??" , "Brigadir" , STR_TO_DATE("12.10.1955.", "%d.%m.%Y.") , STR_TO_DATE("27.4.1999.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10481 , 3 , "Roman" , "Ivan??i??" , "Skupnik" , STR_TO_DATE("13.10.1966.", "%d.%m.%Y.") , STR_TO_DATE("16.6.2014.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10482 , 2 , "Nikolina" , "Krznari??" , "Satnik" , STR_TO_DATE("12.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("26.3.2009.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10483 , 1 , "Ozren" , "Posavec" , "Poru??nik" , STR_TO_DATE("21.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("23.1.2014.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10484 , 3 , "Nina" , "Jovanovi??" , "Poru??nik" , STR_TO_DATE("28.5.1955.", "%d.%m.%Y.") , STR_TO_DATE("15.11.2008.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10485 , 2 , "Lejla" , "Lovri??" , "Brigadir" , STR_TO_DATE("22.9.1957.", "%d.%m.%Y.") , STR_TO_DATE("10.4.2018.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10486 , 4 , "Paisa" , "Martinovi??" , "Poru??nik" , STR_TO_DATE("8.10.1964.", "%d.%m.%Y.") , STR_TO_DATE("5.6.2001.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10487 , 2 , "Slavica" , "Ivan??i??" , "Bojnik" , STR_TO_DATE("6.2.1963.", "%d.%m.%Y.") , STR_TO_DATE("5.3.2011.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10488 , 1 , "Matilda" , "Abramovi??" , "Pukovnik" , STR_TO_DATE("15.9.1959.", "%d.%m.%Y.") , STR_TO_DATE("1.9.2005.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10489 , 4 , "Mislav" , "Mati??" , "Poru??nik" , STR_TO_DATE("7.2.1957.", "%d.%m.%Y.") , STR_TO_DATE("16.12.2019.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10490 , 3 , "Mihael" , "Gali??" , "Poru??nik" , STR_TO_DATE("19.12.1955.", "%d.%m.%Y.") , STR_TO_DATE("20.12.2017.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10491 , 4 , "Julijana" , "Peri??" , "Razvodnik" , STR_TO_DATE("8.5.1960.", "%d.%m.%Y.") , STR_TO_DATE("23.1.1995.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10492 , 3 , "Ilijana" , "Petrovi??" , "Pukovnik" , STR_TO_DATE("27.6.1961.", "%d.%m.%Y.") , STR_TO_DATE("8.4.2015.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10493 , 2 , "Olga" , "Petkovi??" , "Brigadir" , STR_TO_DATE("2.6.1951.", "%d.%m.%Y.") , STR_TO_DATE("1.6.2004.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10494 , 2 , "Evona" , "Buri??" , "Skupnik" , STR_TO_DATE("9.4.1959.", "%d.%m.%Y.") , STR_TO_DATE("17.3.1994.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10495 , 2 , "Estela" , "Posavec" , "Pozornik" , STR_TO_DATE("22.6.1959.", "%d.%m.%Y.") , STR_TO_DATE("29.9.1992.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10496 , 1 , "Rea" , "Golubi??" , "Narednik" , STR_TO_DATE("29.4.1955.", "%d.%m.%Y.") , STR_TO_DATE("21.7.1990.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10497 , 3 , "Olga" , "Bla??evi??" , "Brigadir" , STR_TO_DATE("28.6.1959.", "%d.%m.%Y.") , STR_TO_DATE("11.7.1991.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10498 , 1 , "Kila" , "Pavli??" , "Pukovnik" , STR_TO_DATE("27.11.1959.", "%d.%m.%Y.") , STR_TO_DATE("16.8.2011.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10499 , 2 , "Bruno" , "Mitrovi??" , "Pozornik" , STR_TO_DATE("15.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("21.8.2011.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10500 , 3 , "Edita" , "Jur??evi??" , "Brigadir" , STR_TO_DATE("3.11.1953.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2011.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10501 , 4 , "Anatea" , "Josipovi??" , "Bojnik" , STR_TO_DATE("17.12.1966.", "%d.%m.%Y.") , STR_TO_DATE("31.5.1991.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10502 , 4 , "Branimir" , "Lovri??" , "Poru??nik" , STR_TO_DATE("10.11.1959.", "%d.%m.%Y.") , STR_TO_DATE("5.4.2001.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10503 , 3 , "Denis" , "Maru??i??" , "Narednik" , STR_TO_DATE("16.11.1965.", "%d.%m.%Y.") , STR_TO_DATE("5.11.2014.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10504 , 2 , "Neda" , "Grubi??i??" , "Brigadir" , STR_TO_DATE("27.11.1965.", "%d.%m.%Y.") , STR_TO_DATE("5.2.2004.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10505 , 3 , "Melani" , "Josipovi??" , "Pukovnik" , STR_TO_DATE("20.1.1960.", "%d.%m.%Y.") , STR_TO_DATE("30.5.2013.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10506 , 1 , "Boris" , "Matijevi??" , "Satnik" , STR_TO_DATE("12.7.1963.", "%d.%m.%Y.") , STR_TO_DATE("6.11.2008.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10507 , 4 , "Stefanija" , "Dragi??evi??" , "Poru??nik" , STR_TO_DATE("14.10.1952.", "%d.%m.%Y.") , STR_TO_DATE("22.11.2012.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10508 , 3 , "Eva" , "Gali??" , "Razvodnik" , STR_TO_DATE("27.10.1966.", "%d.%m.%Y.") , STR_TO_DATE("27.9.2020.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10509 , 3 , "Hara" , "Jozi??" , "Skupnik" , STR_TO_DATE("2.11.1967.", "%d.%m.%Y.") , STR_TO_DATE("11.2.1994.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10510 , 1 , "Kristina" , "Jur??evi??" , "Satnik" , STR_TO_DATE("18.9.1951.", "%d.%m.%Y.") , STR_TO_DATE("24.6.2010.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10511 , 2 , "Gabrijel" , "Lon??ari??" , "Bojnik" , STR_TO_DATE("5.12.1958.", "%d.%m.%Y.") , STR_TO_DATE("14.4.2002.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10512 , 4 , "Donat" , "Horvat" , "Skupnik" , STR_TO_DATE("8.4.1952.", "%d.%m.%Y.") , STR_TO_DATE("21.4.2013.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10513 , 1 , "Talia" , "Antunovi??" , "Pukovnik" , STR_TO_DATE("14.1.1965.", "%d.%m.%Y.") , STR_TO_DATE("25.6.1993.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10514 , 2 , "Dante" , "??osi??" , "Satnik" , STR_TO_DATE("23.11.1954.", "%d.%m.%Y.") , STR_TO_DATE("19.12.2005.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10515 , 1 , "Lorena" , "Juri??i??" , "Poru??nik" , STR_TO_DATE("6.4.1965.", "%d.%m.%Y.") , STR_TO_DATE("21.3.2001.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10516 , 2 , "Siera" , "Babi??" , "Satnik" , STR_TO_DATE("13.10.1960.", "%d.%m.%Y.") , STR_TO_DATE("31.5.1992.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10517 , 4 , "Ivan" , "Kova??evi??" , "Poru??nik" , STR_TO_DATE("17.2.1965.", "%d.%m.%Y.") , STR_TO_DATE("5.8.1990.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10518 , 3 , "Dejan" , "Filipovi??" , "Satnik" , STR_TO_DATE("13.5.1961.", "%d.%m.%Y.") , STR_TO_DATE("28.9.1999.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10519 , 1 , "Karina" , "Buri??" , "Poru??nik" , STR_TO_DATE("25.3.1958.", "%d.%m.%Y.") , STR_TO_DATE("12.9.2012.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10520 , 2 , "Adriana" , "Babi??" , "Brigadir" , STR_TO_DATE("27.12.1962.", "%d.%m.%Y.") , STR_TO_DATE("21.9.1996.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10521 , 2 , "Ermina" , "Bo??njak" , "Bojnik" , STR_TO_DATE("25.3.1963.", "%d.%m.%Y.") , STR_TO_DATE("10.8.2003.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10522 , 4 , "Maris" , "Brajkovi??" , "Narednik" , STR_TO_DATE("12.10.1958.", "%d.%m.%Y.") , STR_TO_DATE("12.2.2005.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10523 , 2 , "Aleksandra" , "Horvat" , "Pozornik" , STR_TO_DATE("8.3.1968.", "%d.%m.%Y.") , STR_TO_DATE("22.3.2000.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10524 , 3 , "Aurora" , "Vukovi??" , "Brigadir" , STR_TO_DATE("9.2.1969.", "%d.%m.%Y.") , STR_TO_DATE("13.9.2007.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10525 , 4 , "Filip" , "Abramovi??" , "Pozornik" , STR_TO_DATE("28.6.1966.", "%d.%m.%Y.") , STR_TO_DATE("11.12.2007.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10526 , 1 , "??ak" , "Kova??i??" , "Pozornik" , STR_TO_DATE("27.5.1958.", "%d.%m.%Y.") , STR_TO_DATE("20.12.2019.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10527 , 2 , "Khalesi" , "Nikoli??" , "Brigadir" , STR_TO_DATE("16.2.1957.", "%d.%m.%Y.") , STR_TO_DATE("3.12.1995.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10528 , 4 , "Maksima" , "Juri??" , "Satnik" , STR_TO_DATE("1.2.1959.", "%d.%m.%Y.") , STR_TO_DATE("21.7.2019.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10529 , 3 , "Lobel" , "Mari??" , "Pukovnik" , STR_TO_DATE("22.9.1965.", "%d.%m.%Y.") , STR_TO_DATE("17.11.2002.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10530 , 1 , "Maksima" , "Dujmovi??" , "Poru??nik" , STR_TO_DATE("7.1.1956.", "%d.%m.%Y.") , STR_TO_DATE("16.12.2020.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10531 , 3 , "Maksim" , "Martinovi??" , "Razvodnik" , STR_TO_DATE("14.10.1956.", "%d.%m.%Y.") , STR_TO_DATE("1.5.2012.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10532 , 2 , "Adonis" , "Novak" , "Poru??nik" , STR_TO_DATE("22.4.1964.", "%d.%m.%Y.") , STR_TO_DATE("29.4.1999.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10533 , 3 , "Esmeralda" , "Vidovi??" , "Pozornik" , STR_TO_DATE("3.10.1960.", "%d.%m.%Y.") , STR_TO_DATE("8.6.2012.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10534 , 3 , "Zakarija" , "Juri??" , "Satnik" , STR_TO_DATE("25.6.1965.", "%d.%m.%Y.") , STR_TO_DATE("28.9.2000.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10535 , 1 , "Lika" , "Petkovi??" , "Skupnik" , STR_TO_DATE("3.1.1955.", "%d.%m.%Y.") , STR_TO_DATE("6.10.2000.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10536 , 3 , "Zarija" , "Lovri??" , "Poru??nik" , STR_TO_DATE("30.11.1962.", "%d.%m.%Y.") , STR_TO_DATE("7.11.1991.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10537 , 4 , "Valentina" , "Tomi??" , "Razvodnik" , STR_TO_DATE("4.3.1954.", "%d.%m.%Y.") , STR_TO_DATE("18.12.2005.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10538 , 3 , "Dmitar" , "Vidovi??" , "Poru??nik" , STR_TO_DATE("30.11.1962.", "%d.%m.%Y.") , STR_TO_DATE("14.4.2006.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10539 , 4 , "Roman" , "Martinovi??" , "Bojnik" , STR_TO_DATE("7.6.1970.", "%d.%m.%Y.") , STR_TO_DATE("16.5.2006.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10540 , 1 , "Aleksa" , "Pavi??" , "Pozornik" , STR_TO_DATE("28.6.1958.", "%d.%m.%Y.") , STR_TO_DATE("15.7.1996.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10541 , 4 , "Severina" , "??imuni??" , "Pozornik" , STR_TO_DATE("7.9.1960.", "%d.%m.%Y.") , STR_TO_DATE("18.2.1997.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10542 , 2 , "Aziel" , "??ari??" , "Brigadir" , STR_TO_DATE("14.12.1970.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2007.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10543 , 4 , "Marisol" , "Popovi??" , "Razvodnik" , STR_TO_DATE("16.9.1950.", "%d.%m.%Y.") , STR_TO_DATE("5.2.2015.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10544 , 1 , "Aria" , "Kati??" , "Razvodnik" , STR_TO_DATE("26.6.1956.", "%d.%m.%Y.") , STR_TO_DATE("18.7.2000.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10545 , 4 , "Zoe" , "??ari??" , "Skupnik" , STR_TO_DATE("28.9.1968.", "%d.%m.%Y.") , STR_TO_DATE("14.9.1995.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10546 , 2 , "Sandi" , "Bla??evi??" , "Bojnik" , STR_TO_DATE("21.3.1950.", "%d.%m.%Y.") , STR_TO_DATE("9.6.1999.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10547 , 4 , "Magda" , "Bo??njak" , "Satnik" , STR_TO_DATE("10.11.1951.", "%d.%m.%Y.") , STR_TO_DATE("23.1.2008.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10548 , 1 , "??ime" , "Bo??njak" , "Poru??nik" , STR_TO_DATE("14.12.1959.", "%d.%m.%Y.") , STR_TO_DATE("17.3.1997.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10549 , 1 , "Rajna" , "??imi??" , "Pukovnik" , STR_TO_DATE("21.7.1962.", "%d.%m.%Y.") , STR_TO_DATE("23.7.1997.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10550 , 1 , "Marina" , "Matijevi??" , "Narednik" , STR_TO_DATE("29.10.1951.", "%d.%m.%Y.") , STR_TO_DATE("30.1.2003.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10551 , 4 , "Ognjen" , "??imunovi??" , "Pukovnik" , STR_TO_DATE("30.3.1960.", "%d.%m.%Y.") , STR_TO_DATE("6.5.1990.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10552 , 2 , "Adelina" , "Pavi??" , "Razvodnik" , STR_TO_DATE("12.11.1957.", "%d.%m.%Y.") , STR_TO_DATE("8.3.2000.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10553 , 2 , "Franka" , "Mari??" , "Skupnik" , STR_TO_DATE("15.3.1969.", "%d.%m.%Y.") , STR_TO_DATE("10.10.2000.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10554 , 3 , "Jakov" , "Vukovi??" , "Razvodnik" , STR_TO_DATE("18.11.1964.", "%d.%m.%Y.") , STR_TO_DATE("4.7.2016.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10555 , 1 , "Kila" , "Posavec" , "Narednik" , STR_TO_DATE("26.2.1960.", "%d.%m.%Y.") , STR_TO_DATE("24.1.2013.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10556 , 4 , "Budimir" , "Mitrovi??" , "Narednik" , STR_TO_DATE("10.10.1969.", "%d.%m.%Y.") , STR_TO_DATE("1.3.2018.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10557 , 3 , "Mariam" , "Jur??evi??" , "Pozornik" , STR_TO_DATE("9.2.1950.", "%d.%m.%Y.") , STR_TO_DATE("29.4.2013.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10558 , 3 , "Iko" , "Buri??" , "Skupnik" , STR_TO_DATE("16.11.1952.", "%d.%m.%Y.") , STR_TO_DATE("5.9.2012.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10559 , 2 , "Eme" , "Jeli??" , "Pukovnik" , STR_TO_DATE("29.9.1961.", "%d.%m.%Y.") , STR_TO_DATE("11.3.2008.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10560 , 2 , "??ime" , "Babi??" , "Poru??nik" , STR_TO_DATE("21.6.1962.", "%d.%m.%Y.") , STR_TO_DATE("25.12.2012.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10561 , 2 , "Paisa" , "Ivanovi??" , "Bojnik" , STR_TO_DATE("21.9.1962.", "%d.%m.%Y.") , STR_TO_DATE("28.12.2012.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10562 , 1 , "Adrian" , "Filipovi??" , "Razvodnik" , STR_TO_DATE("31.7.1969.", "%d.%m.%Y.") , STR_TO_DATE("20.1.2018.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10563 , 2 , "Mikaela" , "Posavec" , "Bojnik" , STR_TO_DATE("28.7.1961.", "%d.%m.%Y.") , STR_TO_DATE("1.10.1995.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10564 , 1 , "Violeta" , "Klari??" , "Skupnik" , STR_TO_DATE("24.12.1969.", "%d.%m.%Y.") , STR_TO_DATE("6.10.2005.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10565 , 2 , "Vincent" , "Juri??" , "Razvodnik" , STR_TO_DATE("18.6.1961.", "%d.%m.%Y.") , STR_TO_DATE("26.3.2019.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10566 , 2 , "Natan" , "Petrovi??" , "Poru??nik" , STR_TO_DATE("20.2.1951.", "%d.%m.%Y.") , STR_TO_DATE("6.10.2018.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10567 , 1 , "Kamari" , "Ba??i??" , "Pukovnik" , STR_TO_DATE("21.11.1965.", "%d.%m.%Y.") , STR_TO_DATE("23.5.2011.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10568 , 2 , "Milena" , "Golubi??" , "Satnik" , STR_TO_DATE("26.9.1966.", "%d.%m.%Y.") , STR_TO_DATE("31.1.2004.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10569 , 3 , "Franciska" , "Perkovi??" , "Razvodnik" , STR_TO_DATE("4.10.1954.", "%d.%m.%Y.") , STR_TO_DATE("24.3.2008.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10570 , 3 , "Viktoria" , "??imuni??" , "Pozornik" , STR_TO_DATE("17.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("26.4.2011.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10571 , 2 , "Valentino" , "Jakovljevi??" , "Bojnik" , STR_TO_DATE("13.1.1959.", "%d.%m.%Y.") , STR_TO_DATE("27.11.2014.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10572 , 3 , "Pavao" , "Lon??ar" , "Skupnik" , STR_TO_DATE("20.4.1970.", "%d.%m.%Y.") , STR_TO_DATE("28.11.1998.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10573 , 4 , "Ferdinand" , "Popovi??" , "Bojnik" , STR_TO_DATE("31.3.1966.", "%d.%m.%Y.") , STR_TO_DATE("21.8.2019.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10574 , 4 , "Princa" , "Lu??i??" , "Skupnik" , STR_TO_DATE("30.11.1956.", "%d.%m.%Y.") , STR_TO_DATE("16.7.2009.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10575 , 4 , "Bonie" , "Vukovi??" , "Poru??nik" , STR_TO_DATE("16.6.1958.", "%d.%m.%Y.") , STR_TO_DATE("26.7.2001.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10576 , 2 , "Paisa" , "Brki??" , "Bojnik" , STR_TO_DATE("13.2.1950.", "%d.%m.%Y.") , STR_TO_DATE("2.6.2016.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10577 , 2 , "Borisa" , "Golubi??" , "Pukovnik" , STR_TO_DATE("27.11.1960.", "%d.%m.%Y.") , STR_TO_DATE("29.5.1995.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10578 , 3 , "Samira" , "Jur??evi??" , "Pozornik" , STR_TO_DATE("28.3.1957.", "%d.%m.%Y.") , STR_TO_DATE("2.4.1992.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10579 , 3 , "Krista" , "Jakovljevi??" , "Pukovnik" , STR_TO_DATE("17.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("16.1.1991.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10580 , 1 , "Fiona" , "??ivkovi??" , "Satnik" , STR_TO_DATE("5.2.1958.", "%d.%m.%Y.") , STR_TO_DATE("25.12.1997.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10581 , 3 , "Ita" , "Peri??" , "Razvodnik" , STR_TO_DATE("20.2.1953.", "%d.%m.%Y.") , STR_TO_DATE("21.3.2007.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10582 , 1 , "Janko" , "Novakovi??" , "Pukovnik" , STR_TO_DATE("4.7.1957.", "%d.%m.%Y.") , STR_TO_DATE("28.2.1995.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10583 , 4 , "Tomislav" , "Dragi??evi??" , "Narednik" , STR_TO_DATE("17.12.1964.", "%d.%m.%Y.") , STR_TO_DATE("10.3.1992.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10584 , 3 , "Princa" , "Varga" , "Bojnik" , STR_TO_DATE("5.9.1970.", "%d.%m.%Y.") , STR_TO_DATE("26.3.1997.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10585 , 2 , "Denisa" , "Nikoli??" , "Brigadir" , STR_TO_DATE("12.1.1958.", "%d.%m.%Y.") , STR_TO_DATE("19.3.2002.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10586 , 3 , "Kain" , "Pavi??" , "Brigadir" , STR_TO_DATE("20.3.1963.", "%d.%m.%Y.") , STR_TO_DATE("2.2.2016.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10587 , 3 , "Ivo" , "Ba??i??" , "Narednik" , STR_TO_DATE("7.10.1950.", "%d.%m.%Y.") , STR_TO_DATE("29.3.2003.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10588 , 2 , "Dora" , "Bili??" , "Pozornik" , STR_TO_DATE("19.12.1963.", "%d.%m.%Y.") , STR_TO_DATE("7.11.2005.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10589 , 3 , "Petra" , "Lu??i??" , "Narednik" , STR_TO_DATE("6.6.1957.", "%d.%m.%Y.") , STR_TO_DATE("26.8.2010.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10590 , 4 , "Eli" , "Buri??" , "Razvodnik" , STR_TO_DATE("26.9.1952.", "%d.%m.%Y.") , STR_TO_DATE("18.11.2011.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10591 , 2 , "Martin" , "Ivankovi??" , "Pukovnik" , STR_TO_DATE("30.3.1959.", "%d.%m.%Y.") , STR_TO_DATE("1.12.2001.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10592 , 2 , "Klo" , "Brajkovi??" , "Razvodnik" , STR_TO_DATE("29.7.1959.", "%d.%m.%Y.") , STR_TO_DATE("8.11.1994.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10593 , 4 , "Benjamin" , "Crnkovi??" , "Narednik" , STR_TO_DATE("21.9.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.8.2007.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10594 , 3 , "Leonardo" , "Matkovi??" , "Brigadir" , STR_TO_DATE("2.7.1957.", "%d.%m.%Y.") , STR_TO_DATE("23.3.1995.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10595 , 3 , "Rita" , "Posavec" , "Brigadir" , STR_TO_DATE("30.9.1967.", "%d.%m.%Y.") , STR_TO_DATE("16.5.2018.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10596 , 1 , "Kre??imir" , "Babi??" , "Skupnik" , STR_TO_DATE("2.6.1957.", "%d.%m.%Y.") , STR_TO_DATE("30.3.2003.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10597 , 4 , "Franka" , "??imi??" , "Skupnik" , STR_TO_DATE("2.6.1962.", "%d.%m.%Y.") , STR_TO_DATE("31.5.1994.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10598 , 2 , "Tihana" , "Jozi??" , "Pukovnik" , STR_TO_DATE("26.6.1968.", "%d.%m.%Y.") , STR_TO_DATE("18.1.1990.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10599 , 3 , "Nadia" , "Mileti??" , "Narednik" , STR_TO_DATE("15.2.1965.", "%d.%m.%Y.") , STR_TO_DATE("23.9.2016.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10600 , 1 , "Vita" , "Filipovi??" , "Bojnik" , STR_TO_DATE("7.6.1964.", "%d.%m.%Y.") , STR_TO_DATE("18.12.1999.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10601 , 4 , "Ada" , "Dragi??evi??" , "Razvodnik" , STR_TO_DATE("26.1.1950.", "%d.%m.%Y.") , STR_TO_DATE("15.2.2006.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10602 , 2 , "Korina" , "Mitrovi??" , "Razvodnik" , STR_TO_DATE("8.7.1955.", "%d.%m.%Y.") , STR_TO_DATE("21.11.2014.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10603 , 1 , "Marjan" , "Pavlovi??" , "Satnik" , STR_TO_DATE("25.5.1956.", "%d.%m.%Y.") , STR_TO_DATE("27.7.2016.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10604 , 1 , "Leandro" , "??imunovi??" , "Bojnik" , STR_TO_DATE("1.6.1970.", "%d.%m.%Y.") , STR_TO_DATE("16.12.1997.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10605 , 3 , "Tiago" , "??ur??evi??" , "Poru??nik" , STR_TO_DATE("26.10.1953.", "%d.%m.%Y.") , STR_TO_DATE("25.2.1999.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10606 , 1 , "Khalesi" , "Sever" , "Bojnik" , STR_TO_DATE("4.1.1958.", "%d.%m.%Y.") , STR_TO_DATE("17.2.1996.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10607 , 3 , "Miroslava" , "Jur??evi??" , "Skupnik" , STR_TO_DATE("12.7.1968.", "%d.%m.%Y.") , STR_TO_DATE("3.2.2004.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10608 , 3 , "Aleksandra" , "Grubi??i??" , "Razvodnik" , STR_TO_DATE("24.5.1964.", "%d.%m.%Y.") , STR_TO_DATE("11.7.2011.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10609 , 1 , "Dani" , "Dujmovi??" , "Narednik" , STR_TO_DATE("5.4.1951.", "%d.%m.%Y.") , STR_TO_DATE("4.8.2008.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10610 , 3 , "Elana" , "Tomi??" , "Razvodnik" , STR_TO_DATE("13.1.1950.", "%d.%m.%Y.") , STR_TO_DATE("6.11.2018.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10611 , 1 , "Nia" , "Ivanovi??" , "Pukovnik" , STR_TO_DATE("9.7.1967.", "%d.%m.%Y.") , STR_TO_DATE("1.10.2013.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10612 , 4 , "Marcela" , "??imunovi??" , "Narednik" , STR_TO_DATE("10.7.1958.", "%d.%m.%Y.") , STR_TO_DATE("1.9.1992.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10613 , 1 , "Aron" , "Vidakovi??" , "Satnik" , STR_TO_DATE("10.6.1960.", "%d.%m.%Y.") , STR_TO_DATE("11.11.2012.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10614 , 1 , "Simon" , "Martinovi??" , "Bojnik" , STR_TO_DATE("5.3.1963.", "%d.%m.%Y.") , STR_TO_DATE("14.3.2013.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10615 , 4 , "Rina" , "Mandi??" , "Razvodnik" , STR_TO_DATE("4.10.1961.", "%d.%m.%Y.") , STR_TO_DATE("20.4.2012.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10616 , 2 , "Ivo" , "Mileti??" , "Narednik" , STR_TO_DATE("26.9.1963.", "%d.%m.%Y.") , STR_TO_DATE("12.6.2004.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10617 , 2 , "Iris" , "Marjanovi??" , "Satnik" , STR_TO_DATE("13.3.1967.", "%d.%m.%Y.") , STR_TO_DATE("15.1.2003.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10618 , 2 , "Goga" , "Perkovi??" , "Satnik" , STR_TO_DATE("28.1.1968.", "%d.%m.%Y.") , STR_TO_DATE("23.3.2006.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10619 , 4 , "Lilia" , "??ivkovi??" , "Narednik" , STR_TO_DATE("24.12.1963.", "%d.%m.%Y.") , STR_TO_DATE("24.5.2001.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10620 , 4 , "Ada" , "Grgi??" , "Poru??nik" , STR_TO_DATE("29.12.1956.", "%d.%m.%Y.") , STR_TO_DATE("18.2.1992.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10621 , 3 , "Augustin" , "Bari??i??" , "Narednik" , STR_TO_DATE("22.4.1959.", "%d.%m.%Y.") , STR_TO_DATE("30.9.2005.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10622 , 3 , "Mariam" , "Kova??" , "Pukovnik" , STR_TO_DATE("28.5.1963.", "%d.%m.%Y.") , STR_TO_DATE("20.3.2006.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10623 , 3 , "Sandi" , "??imunovi??" , "Bojnik" , STR_TO_DATE("21.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("15.1.1995.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10624 , 3 , "Elena" , "Filipovi??" , "Pukovnik" , STR_TO_DATE("18.5.1964.", "%d.%m.%Y.") , STR_TO_DATE("19.2.2020.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10625 , 3 , "Aria" , "??imuni??" , "Razvodnik" , STR_TO_DATE("30.3.1950.", "%d.%m.%Y.") , STR_TO_DATE("11.10.2014.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10626 , 1 , "Boris" , "Josipovi??" , "Bojnik" , STR_TO_DATE("19.11.1950.", "%d.%m.%Y.") , STR_TO_DATE("5.6.2005.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10627 , 1 , "Moreno" , "Vu??kovi??" , "Pukovnik" , STR_TO_DATE("25.9.1968.", "%d.%m.%Y.") , STR_TO_DATE("22.4.2005.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10628 , 4 , "Remi" , "Mari??" , "Brigadir" , STR_TO_DATE("2.9.1965.", "%d.%m.%Y.") , STR_TO_DATE("31.8.1994.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10629 , 3 , "Marlin" , "Mari??" , "Poru??nik" , STR_TO_DATE("5.8.1965.", "%d.%m.%Y.") , STR_TO_DATE("22.10.2019.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10630 , 2 , "Nova" , "Mitrovi??" , "Razvodnik" , STR_TO_DATE("8.10.1970.", "%d.%m.%Y.") , STR_TO_DATE("24.6.2011.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10631 , 1 , "Sendi" , "??uri??" , "Narednik" , STR_TO_DATE("11.3.1953.", "%d.%m.%Y.") , STR_TO_DATE("26.11.2009.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10632 , 4 , "Zakarija" , "Brki??" , "Narednik" , STR_TO_DATE("28.2.1970.", "%d.%m.%Y.") , STR_TO_DATE("2.7.2014.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10633 , 1 , "Martea" , "Stani??" , "Narednik" , STR_TO_DATE("4.9.1952.", "%d.%m.%Y.") , STR_TO_DATE("13.7.2009.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10634 , 3 , "Kira" , "Petrovi??" , "Razvodnik" , STR_TO_DATE("4.3.1956.", "%d.%m.%Y.") , STR_TO_DATE("9.11.2015.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10635 , 2 , "Liv" , "Bla??evi??" , "Brigadir" , STR_TO_DATE("25.6.1963.", "%d.%m.%Y.") , STR_TO_DATE("31.1.2003.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10636 , 1 , "Amaris" , "??osi??" , "Razvodnik" , STR_TO_DATE("12.6.1953.", "%d.%m.%Y.") , STR_TO_DATE("16.10.2000.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10637 , 1 , "Edita" , "Klari??" , "Narednik" , STR_TO_DATE("23.1.1964.", "%d.%m.%Y.") , STR_TO_DATE("6.3.2015.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10638 , 1 , "Slavica" , "Matijevi??" , "Narednik" , STR_TO_DATE("3.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("22.3.2018.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10639 , 2 , "Elaina" , "Mati??" , "Razvodnik" , STR_TO_DATE("2.6.1963.", "%d.%m.%Y.") , STR_TO_DATE("11.10.1999.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10640 , 2 , "Rebeka" , "Markovi??" , "Brigadir" , STR_TO_DATE("16.6.1964.", "%d.%m.%Y.") , STR_TO_DATE("29.8.2016.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10641 , 4 , "Leona" , "Novak" , "Pukovnik" , STR_TO_DATE("3.8.1964.", "%d.%m.%Y.") , STR_TO_DATE("12.11.1995.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10642 , 1 , "Dajana" , "Novakovi??" , "Pukovnik" , STR_TO_DATE("18.2.1969.", "%d.%m.%Y.") , STR_TO_DATE("8.3.2009.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10643 , 3 , "Goran" , "Jeli??" , "Skupnik" , STR_TO_DATE("27.2.1968.", "%d.%m.%Y.") , STR_TO_DATE("2.7.2008.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10644 , 2 , "Kali" , "Horvat" , "Skupnik" , STR_TO_DATE("27.2.1966.", "%d.%m.%Y.") , STR_TO_DATE("27.9.2000.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10645 , 2 , "Lea" , "Lon??ari??" , "Pukovnik" , STR_TO_DATE("21.1.1970.", "%d.%m.%Y.") , STR_TO_DATE("2.4.2012.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10646 , 2 , "Madelin" , "Babi??" , "Skupnik" , STR_TO_DATE("24.9.1959.", "%d.%m.%Y.") , STR_TO_DATE("25.5.1990.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10647 , 4 , "Marcel" , "Dragi??evi??" , "Pukovnik" , STR_TO_DATE("4.11.1956.", "%d.%m.%Y.") , STR_TO_DATE("12.5.2003.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10648 , 1 , "Kai" , "Antunovi??" , "Poru??nik" , STR_TO_DATE("21.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("30.4.2013.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10649 , 4 , "Samira" , "Jankovi??" , "Satnik" , STR_TO_DATE("16.6.1960.", "%d.%m.%Y.") , STR_TO_DATE("10.7.1999.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10650 , 1 , "Brigita" , "Lovri??" , "Pukovnik" , STR_TO_DATE("16.4.1955.", "%d.%m.%Y.") , STR_TO_DATE("10.5.1994.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10651 , 2 , "Elena" , "Brki??" , "Pozornik" , STR_TO_DATE("27.3.1960.", "%d.%m.%Y.") , STR_TO_DATE("18.4.2014.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10652 , 2 , "Lilika" , "Kova??" , "Brigadir" , STR_TO_DATE("13.8.1954.", "%d.%m.%Y.") , STR_TO_DATE("22.11.2006.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10653 , 1 , "Gustav" , "Peri??" , "Narednik" , STR_TO_DATE("24.2.1950.", "%d.%m.%Y.") , STR_TO_DATE("9.8.1990.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10654 , 2 , "Vanesa" , "Jozi??" , "Pozornik" , STR_TO_DATE("15.11.1959.", "%d.%m.%Y.") , STR_TO_DATE("8.12.2010.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10655 , 4 , "Mariam" , "Cindri??" , "Satnik" , STR_TO_DATE("28.9.1959.", "%d.%m.%Y.") , STR_TO_DATE("1.5.2005.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10656 , 2 , "Jakov" , "Vukovi??" , "Brigadir" , STR_TO_DATE("17.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("23.2.2000.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10657 , 1 , "Hai" , "Horvat" , "Pozornik" , STR_TO_DATE("17.12.1951.", "%d.%m.%Y.") , STR_TO_DATE("1.3.2002.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10658 , 4 , "Anamarija" , "Jur??evi??" , "Narednik" , STR_TO_DATE("31.3.1962.", "%d.%m.%Y.") , STR_TO_DATE("13.5.1995.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10659 , 1 , "Gisela" , "Peri??" , "Brigadir" , STR_TO_DATE("25.10.1969.", "%d.%m.%Y.") , STR_TO_DATE("5.10.2019.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10660 , 3 , "Toni" , "Popovi??" , "Poru??nik" , STR_TO_DATE("12.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("16.1.2019.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10661 , 2 , "Sebastijan" , "Brki??" , "Narednik" , STR_TO_DATE("20.8.1960.", "%d.%m.%Y.") , STR_TO_DATE("10.10.2005.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10662 , 3 , "Maris" , "Krznari??" , "Poru??nik" , STR_TO_DATE("16.8.1961.", "%d.%m.%Y.") , STR_TO_DATE("14.3.1991.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10663 , 1 , "Franciska" , "Nikoli??" , "Satnik" , STR_TO_DATE("20.4.1961.", "%d.%m.%Y.") , STR_TO_DATE("28.1.2019.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10664 , 4 , "Rajna" , "Mati??" , "Pukovnik" , STR_TO_DATE("22.10.1950.", "%d.%m.%Y.") , STR_TO_DATE("10.10.1994.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10665 , 3 , "Evica" , "Vidakovi??" , "Skupnik" , STR_TO_DATE("9.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("1.12.2004.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10666 , 1 , "Elena" , "Kova??evi??" , "Pozornik" , STR_TO_DATE("24.8.1953.", "%d.%m.%Y.") , STR_TO_DATE("29.9.1991.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10667 , 3 , "Dajana" , "Krznari??" , "Poru??nik" , STR_TO_DATE("13.9.1957.", "%d.%m.%Y.") , STR_TO_DATE("22.9.2002.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10668 , 1 , "Oliver" , "Juri??" , "Razvodnik" , STR_TO_DATE("30.11.1959.", "%d.%m.%Y.") , STR_TO_DATE("9.10.1993.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10669 , 1 , "Leo" , "Posavec" , "Pukovnik" , STR_TO_DATE("17.2.1956.", "%d.%m.%Y.") , STR_TO_DATE("16.5.1990.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10670 , 1 , "Stela" , "Sever" , "Pukovnik" , STR_TO_DATE("25.7.1966.", "%d.%m.%Y.") , STR_TO_DATE("9.2.1995.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10671 , 3 , "Lenon" , "Pavlovi??" , "Brigadir" , STR_TO_DATE("21.11.1954.", "%d.%m.%Y.") , STR_TO_DATE("7.4.1998.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10672 , 4 , "Dana" , "Radi??" , "Satnik" , STR_TO_DATE("30.4.1955.", "%d.%m.%Y.") , STR_TO_DATE("9.9.2004.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10673 , 4 , "Rea" , "Juri??i??" , "Bojnik" , STR_TO_DATE("30.6.1952.", "%d.%m.%Y.") , STR_TO_DATE("23.6.1996.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10674 , 1 , "Dajana" , "Vrdoljak" , "Skupnik" , STR_TO_DATE("16.8.1967.", "%d.%m.%Y.") , STR_TO_DATE("8.2.2001.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10675 , 3 , "Mauro" , "Rukavina" , "Poru??nik" , STR_TO_DATE("26.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("29.10.2014.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10676 , 4 , "Isla" , "Grguri??" , "Bojnik" , STR_TO_DATE("8.8.1962.", "%d.%m.%Y.") , STR_TO_DATE("22.6.2011.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10677 , 1 , "Dario" , "Lon??ari??" , "Skupnik" , STR_TO_DATE("9.12.1951.", "%d.%m.%Y.") , STR_TO_DATE("7.5.1996.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10678 , 1 , "Rosalia" , "Radi??" , "Pukovnik" , STR_TO_DATE("20.6.1965.", "%d.%m.%Y.") , STR_TO_DATE("1.1.2002.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10679 , 3 , "Branimir" , "Babi??" , "Pukovnik" , STR_TO_DATE("16.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("29.3.2011.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10680 , 2 , "Dalia" , "Buri??" , "Razvodnik" , STR_TO_DATE("14.12.1963.", "%d.%m.%Y.") , STR_TO_DATE("29.4.2012.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10681 , 4 , "Lilika" , "Kolari??" , "Pozornik" , STR_TO_DATE("5.10.1967.", "%d.%m.%Y.") , STR_TO_DATE("14.3.2007.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10682 , 4 , "Elivija" , "Ru??i??" , "Pukovnik" , STR_TO_DATE("17.12.1959.", "%d.%m.%Y.") , STR_TO_DATE("11.8.2004.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10683 , 2 , "Viktor" , "Crnkovi??" , "Razvodnik" , STR_TO_DATE("10.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("18.12.2002.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10684 , 1 , "Niko" , "Ivankovi??" , "Skupnik" , STR_TO_DATE("20.12.1970.", "%d.%m.%Y.") , STR_TO_DATE("18.11.2002.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10685 , 4 , "Natalija" , "Antunovi??" , "Narednik" , STR_TO_DATE("11.7.1967.", "%d.%m.%Y.") , STR_TO_DATE("10.11.1995.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10686 , 3 , "Ben" , "Perkovi??" , "Satnik" , STR_TO_DATE("13.11.1958.", "%d.%m.%Y.") , STR_TO_DATE("11.5.1995.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10687 , 3 , "Melkiot" , "Pavli??" , "Pozornik" , STR_TO_DATE("28.11.1959.", "%d.%m.%Y.") , STR_TO_DATE("8.9.2000.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10688 , 2 , "Vito" , "Juki??" , "Pukovnik" , STR_TO_DATE("11.10.1960.", "%d.%m.%Y.") , STR_TO_DATE("9.10.2001.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10689 , 2 , "Katarina" , "Lon??ar" , "Poru??nik" , STR_TO_DATE("15.12.1969.", "%d.%m.%Y.") , STR_TO_DATE("31.3.1996.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10690 , 1 , "Viktor" , "Ivan??i??" , "Brigadir" , STR_TO_DATE("7.5.1966.", "%d.%m.%Y.") , STR_TO_DATE("22.9.1998.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10691 , 1 , "Rebeka" , "Radi??" , "Poru??nik" , STR_TO_DATE("8.10.1960.", "%d.%m.%Y.") , STR_TO_DATE("25.1.2002.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10692 , 2 , "Bruno" , "Petrovi??" , "Narednik" , STR_TO_DATE("28.11.1951.", "%d.%m.%Y.") , STR_TO_DATE("25.3.2013.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10693 , 4 , "Nia" , "Stani??" , "Narednik" , STR_TO_DATE("14.3.1950.", "%d.%m.%Y.") , STR_TO_DATE("6.2.2000.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10694 , 2 , "Nives" , "Perkovi??" , "Pukovnik" , STR_TO_DATE("24.10.1968.", "%d.%m.%Y.") , STR_TO_DATE("9.12.2020.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10695 , 2 , "Dani" , "Markovi??" , "Poru??nik" , STR_TO_DATE("12.7.1965.", "%d.%m.%Y.") , STR_TO_DATE("21.11.2000.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10696 , 4 , "Marisol" , "??imi??" , "Razvodnik" , STR_TO_DATE("2.2.1959.", "%d.%m.%Y.") , STR_TO_DATE("12.10.2011.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10697 , 2 , "Estela" , "Vidovi??" , "Pozornik" , STR_TO_DATE("22.3.1968.", "%d.%m.%Y.") , STR_TO_DATE("25.4.2017.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10698 , 3 , "Mateo" , "Marjanovi??" , "Razvodnik" , STR_TO_DATE("18.6.1968.", "%d.%m.%Y.") , STR_TO_DATE("26.4.2012.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10699 , 3 , "Zelda" , "Sever" , "Brigadir" , STR_TO_DATE("21.7.1970.", "%d.%m.%Y.") , STR_TO_DATE("12.4.2002.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10700 , 1 , "Juna" , "Josipovi??" , "Brigadir" , STR_TO_DATE("18.8.1953.", "%d.%m.%Y.") , STR_TO_DATE("18.6.1993.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10701 , 2 , "Teodor" , "Pavli??" , "Poru??nik" , STR_TO_DATE("18.6.1950.", "%d.%m.%Y.") , STR_TO_DATE("8.2.2004.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10702 , 4 , "Kalisa" , "Jur??evi??" , "Poru??nik" , STR_TO_DATE("27.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("7.1.2007.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10703 , 1 , "Leona" , "Krznari??" , "Brigadir" , STR_TO_DATE("16.4.1959.", "%d.%m.%Y.") , STR_TO_DATE("5.11.2003.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10704 , 1 , "Ena" , "Kova??" , "Razvodnik" , STR_TO_DATE("8.7.1968.", "%d.%m.%Y.") , STR_TO_DATE("5.8.2011.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10705 , 2 , "Matej" , "Vidovi??" , "Poru??nik" , STR_TO_DATE("23.5.1950.", "%d.%m.%Y.") , STR_TO_DATE("15.9.2000.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10706 , 2 , "Arijana" , "Tomi??" , "Pukovnik" , STR_TO_DATE("3.2.1958.", "%d.%m.%Y.") , STR_TO_DATE("22.2.2007.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10707 , 3 , "Nikol" , "Juri??i??" , "Pozornik" , STR_TO_DATE("7.11.1954.", "%d.%m.%Y.") , STR_TO_DATE("30.6.1992.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10708 , 3 , "Krista" , "Juri??i??" , "Pukovnik" , STR_TO_DATE("31.3.1963.", "%d.%m.%Y.") , STR_TO_DATE("16.3.2011.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10709 , 2 , "Rosalia" , "Rukavina" , "Satnik" , STR_TO_DATE("3.6.1951.", "%d.%m.%Y.") , STR_TO_DATE("30.7.1993.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10710 , 2 , "Lenon" , "Ivanovi??" , "Bojnik" , STR_TO_DATE("25.12.1956.", "%d.%m.%Y.") , STR_TO_DATE("24.6.2011.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10711 , 1 , "Natalija" , "Vidovi??" , "Razvodnik" , STR_TO_DATE("5.4.1967.", "%d.%m.%Y.") , STR_TO_DATE("7.7.2000.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10712 , 3 , "??eljkica" , "Filipovi??" , "Poru??nik" , STR_TO_DATE("3.12.1963.", "%d.%m.%Y.") , STR_TO_DATE("25.11.2019.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10713 , 4 , "Maca" , "Jozi??" , "Pukovnik" , STR_TO_DATE("1.11.1957.", "%d.%m.%Y.") , STR_TO_DATE("4.1.2013.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10714 , 4 , "Moli" , "Kralj" , "Satnik" , STR_TO_DATE("11.6.1951.", "%d.%m.%Y.") , STR_TO_DATE("2.6.1993.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10715 , 3 , "Melanija" , "??imi??" , "Poru??nik" , STR_TO_DATE("3.3.1951.", "%d.%m.%Y.") , STR_TO_DATE("26.10.1992.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10716 , 2 , "Milena" , "Pavi??" , "Razvodnik" , STR_TO_DATE("3.1.1951.", "%d.%m.%Y.") , STR_TO_DATE("9.9.1994.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10717 , 3 , "Bria" , "Herceg" , "Razvodnik" , STR_TO_DATE("5.4.1957.", "%d.%m.%Y.") , STR_TO_DATE("31.5.2001.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10718 , 4 , "Elie" , "Petrovi??" , "Narednik" , STR_TO_DATE("16.10.1961.", "%d.%m.%Y.") , STR_TO_DATE("3.10.2009.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10719 , 4 , "Kruna" , "Maru??i??" , "Bojnik" , STR_TO_DATE("24.12.1950.", "%d.%m.%Y.") , STR_TO_DATE("26.4.2014.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10720 , 3 , "Gaj" , "Horvat" , "Poru??nik" , STR_TO_DATE("22.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("28.11.2012.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10721 , 1 , "Nira" , "Jurkovi??" , "Pozornik" , STR_TO_DATE("9.4.1969.", "%d.%m.%Y.") , STR_TO_DATE("21.8.2006.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10722 , 4 , "Harmina" , "Juri??i??" , "Pukovnik" , STR_TO_DATE("17.11.1969.", "%d.%m.%Y.") , STR_TO_DATE("1.9.2002.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10723 , 4 , "Rila" , "Jur??evi??" , "Narednik" , STR_TO_DATE("5.3.1961.", "%d.%m.%Y.") , STR_TO_DATE("3.5.1995.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10724 , 1 , "Alma" , "Ba??i??" , "Satnik" , STR_TO_DATE("8.8.1967.", "%d.%m.%Y.") , STR_TO_DATE("10.11.1997.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10725 , 4 , "Marina" , "Mikuli??" , "Poru??nik" , STR_TO_DATE("30.4.1959.", "%d.%m.%Y.") , STR_TO_DATE("4.1.2012.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10726 , 1 , "Beatrica" , "Ru??i??" , "Narednik" , STR_TO_DATE("10.8.1960.", "%d.%m.%Y.") , STR_TO_DATE("1.6.2004.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10727 , 1 , "Rhea" , "Lovri??" , "Skupnik" , STR_TO_DATE("8.8.1950.", "%d.%m.%Y.") , STR_TO_DATE("14.8.2013.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10728 , 3 , "Kristian" , "Jur??evi??" , "Pukovnik" , STR_TO_DATE("16.12.1962.", "%d.%m.%Y.") , STR_TO_DATE("2.12.1997.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10729 , 1 , "Santino" , "Tomi??" , "Skupnik" , STR_TO_DATE("4.3.1951.", "%d.%m.%Y.") , STR_TO_DATE("25.5.1999.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10730 , 3 , "Laura" , "Butkovi??" , "Razvodnik" , STR_TO_DATE("30.9.1960.", "%d.%m.%Y.") , STR_TO_DATE("4.6.1992.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10731 , 1 , "Roman" , "Ivanovi??" , "Razvodnik" , STR_TO_DATE("2.6.1966.", "%d.%m.%Y.") , STR_TO_DATE("21.12.1990.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10732 , 4 , "Fabijan" , "Pavi??" , "Skupnik" , STR_TO_DATE("16.10.1954.", "%d.%m.%Y.") , STR_TO_DATE("15.8.2018.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10733 , 3 , "Belen" , "Herceg" , "Skupnik" , STR_TO_DATE("31.12.1958.", "%d.%m.%Y.") , STR_TO_DATE("11.1.2008.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10734 , 2 , "Makena" , "Radi??" , "Poru??nik" , STR_TO_DATE("7.4.1953.", "%d.%m.%Y.") , STR_TO_DATE("22.3.2009.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10735 , 3 , "Kina" , "Pavli??" , "Brigadir" , STR_TO_DATE("8.12.1961.", "%d.%m.%Y.") , STR_TO_DATE("2.10.2016.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10736 , 1 , "Oto" , "Novak" , "Bojnik" , STR_TO_DATE("26.2.1950.", "%d.%m.%Y.") , STR_TO_DATE("13.6.1998.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10737 , 4 , "Izaija" , "Grubi??i??" , "Pukovnik" , STR_TO_DATE("24.7.1966.", "%d.%m.%Y.") , STR_TO_DATE("16.2.1990.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10738 , 4 , "Ofelia" , "Vu??kovi??" , "Satnik" , STR_TO_DATE("21.3.1956.", "%d.%m.%Y.") , STR_TO_DATE("19.7.2019.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10739 , 3 , "Vanja" , "Nikoli??" , "Skupnik" , STR_TO_DATE("2.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("2.8.1996.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10740 , 2 , "Luela" , "Herceg" , "Razvodnik" , STR_TO_DATE("21.10.1969.", "%d.%m.%Y.") , STR_TO_DATE("22.7.2015.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10741 , 1 , "Estela" , "Kolari??" , "Pozornik" , STR_TO_DATE("6.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("3.4.2000.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10742 , 4 , "Mela" , "??imi??" , "Pozornik" , STR_TO_DATE("4.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("27.9.2002.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10743 , 2 , "Filipa" , "??osi??" , "Razvodnik" , STR_TO_DATE("30.1.1969.", "%d.%m.%Y.") , STR_TO_DATE("7.4.2015.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10744 , 2 , "Roman" , "Bari??i??" , "Brigadir" , STR_TO_DATE("18.11.1952.", "%d.%m.%Y.") , STR_TO_DATE("22.3.2017.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10745 , 3 , "Rhea" , "Mitrovi??" , "Bojnik" , STR_TO_DATE("21.2.1965.", "%d.%m.%Y.") , STR_TO_DATE("23.4.2019.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10746 , 3 , "Korina" , "Jeli??" , "Razvodnik" , STR_TO_DATE("16.11.1967.", "%d.%m.%Y.") , STR_TO_DATE("5.8.1992.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10747 , 1 , "Damir" , "Matkovi??" , "Poru??nik" , STR_TO_DATE("3.3.1968.", "%d.%m.%Y.") , STR_TO_DATE("21.9.2010.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10748 , 2 , "Nova" , "Sever" , "Poru??nik" , STR_TO_DATE("9.12.1967.", "%d.%m.%Y.") , STR_TO_DATE("8.8.1999.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10749 , 1 , "Evan??elika" , "Cindri??" , "Pukovnik" , STR_TO_DATE("10.2.1968.", "%d.%m.%Y.") , STR_TO_DATE("9.2.2013.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10750 , 1 , "Anemari" , "Grguri??" , "Pukovnik" , STR_TO_DATE("1.5.1966.", "%d.%m.%Y.") , STR_TO_DATE("28.5.2010.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10751 , 2 , "Bartola" , "Pavi??" , "Pozornik" , STR_TO_DATE("28.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("11.5.2002.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10752 , 1 , "Pavel" , "Jovanovi??" , "Pozornik" , STR_TO_DATE("2.9.1959.", "%d.%m.%Y.") , STR_TO_DATE("6.9.2011.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10753 , 1 , "Evina" , "Nikoli??" , "Pukovnik" , STR_TO_DATE("4.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("15.4.2016.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10754 , 2 , "Lea" , "Novak" , "Narednik" , STR_TO_DATE("30.4.1967.", "%d.%m.%Y.") , STR_TO_DATE("11.12.1995.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10755 , 4 , "Lina" , "Nikoli??" , "Pukovnik" , STR_TO_DATE("25.1.1963.", "%d.%m.%Y.") , STR_TO_DATE("23.2.2020.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10756 , 1 , "Matea" , "Novak" , "Bojnik" , STR_TO_DATE("15.2.1964.", "%d.%m.%Y.") , STR_TO_DATE("22.11.2008.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10757 , 4 , "Tara" , "Rukavina" , "Poru??nik" , STR_TO_DATE("6.6.1964.", "%d.%m.%Y.") , STR_TO_DATE("11.12.2020.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10758 , 3 , "Davina" , "??ur??evi??" , "Poru??nik" , STR_TO_DATE("10.1.1954.", "%d.%m.%Y.") , STR_TO_DATE("10.7.2002.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10759 , 1 , "Jolena" , "Lon??ari??" , "Skupnik" , STR_TO_DATE("25.3.1957.", "%d.%m.%Y.") , STR_TO_DATE("22.1.2004.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10760 , 2 , "Vincent" , "Petkovi??" , "Pukovnik" , STR_TO_DATE("3.8.1962.", "%d.%m.%Y.") , STR_TO_DATE("6.3.1997.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10761 , 3 , "Evica" , "Jovanovi??" , "Bojnik" , STR_TO_DATE("27.7.1950.", "%d.%m.%Y.") , STR_TO_DATE("20.7.2002.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10762 , 2 , "Emili" , "Vukovi??" , "Pukovnik" , STR_TO_DATE("7.7.1959.", "%d.%m.%Y.") , STR_TO_DATE("19.1.1997.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10763 , 2 , "Marisol" , "Pavi??" , "Satnik" , STR_TO_DATE("20.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("18.1.2017.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10764 , 1 , "Natalija" , "Horvat" , "Brigadir" , STR_TO_DATE("9.1.1962.", "%d.%m.%Y.") , STR_TO_DATE("3.3.2006.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10765 , 3 , "Maca" , "Mileti??" , "Skupnik" , STR_TO_DATE("26.5.1957.", "%d.%m.%Y.") , STR_TO_DATE("13.10.2005.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10766 , 1 , "Alana" , "Brki??" , "Brigadir" , STR_TO_DATE("24.4.1969.", "%d.%m.%Y.") , STR_TO_DATE("15.11.2019.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10767 , 3 , "Salema" , "Grgi??" , "Skupnik" , STR_TO_DATE("25.9.1958.", "%d.%m.%Y.") , STR_TO_DATE("3.6.2008.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10768 , 3 , "Bruno" , "Juri??i??" , "Satnik" , STR_TO_DATE("10.5.1955.", "%d.%m.%Y.") , STR_TO_DATE("9.8.2009.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10769 , 4 , "Dorotej" , "Varga" , "Pozornik" , STR_TO_DATE("11.3.1958.", "%d.%m.%Y.") , STR_TO_DATE("31.10.1996.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10770 , 4 , "Sa??a" , "Varga" , "Bojnik" , STR_TO_DATE("3.12.1958.", "%d.%m.%Y.") , STR_TO_DATE("24.6.2005.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10771 , 2 , "Viena" , "??osi??" , "Pozornik" , STR_TO_DATE("14.12.1970.", "%d.%m.%Y.") , STR_TO_DATE("17.10.2017.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10772 , 4 , "Izaija" , "Jurkovi??" , "Pukovnik" , STR_TO_DATE("4.1.1958.", "%d.%m.%Y.") , STR_TO_DATE("26.6.1992.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10773 , 4 , "Ivor" , "Vukovi??" , "Bojnik" , STR_TO_DATE("5.10.1964.", "%d.%m.%Y.") , STR_TO_DATE("17.6.1994.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10774 , 1 , "Beta" , "??imuni??" , "Brigadir" , STR_TO_DATE("13.4.1950.", "%d.%m.%Y.") , STR_TO_DATE("9.6.1990.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10775 , 3 , "Moli" , "Posavec" , "Pukovnik" , STR_TO_DATE("12.11.1961.", "%d.%m.%Y.") , STR_TO_DATE("9.4.1990.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10776 , 3 , "Adam" , "Popovi??" , "Narednik" , STR_TO_DATE("4.6.1964.", "%d.%m.%Y.") , STR_TO_DATE("24.9.2003.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10777 , 1 , "Gema" , "Ivanovi??" , "Pozornik" , STR_TO_DATE("16.12.1963.", "%d.%m.%Y.") , STR_TO_DATE("29.12.2014.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10778 , 1 , "Goran" , "Vrdoljak" , "Bojnik" , STR_TO_DATE("16.5.1959.", "%d.%m.%Y.") , STR_TO_DATE("14.6.2008.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10779 , 2 , "Mila" , "Dragi??evi??" , "Satnik" , STR_TO_DATE("15.11.1954.", "%d.%m.%Y.") , STR_TO_DATE("20.9.2011.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10780 , 4 , "Alesia" , "??imunovi??" , "Pozornik" , STR_TO_DATE("1.5.1965.", "%d.%m.%Y.") , STR_TO_DATE("11.3.2009.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10781 , 3 , "Julijan" , "Dujmovi??" , "Skupnik" , STR_TO_DATE("11.4.1956.", "%d.%m.%Y.") , STR_TO_DATE("24.4.2003.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10782 , 2 , "Miroslava" , "??imuni??" , "Narednik" , STR_TO_DATE("22.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("5.9.2007.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10783 , 2 , "Hada" , "Novak" , "Narednik" , STR_TO_DATE("9.9.1950.", "%d.%m.%Y.") , STR_TO_DATE("23.9.2005.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10784 , 3 , "??iril" , "Vu??kovi??" , "Brigadir" , STR_TO_DATE("1.12.1951.", "%d.%m.%Y.") , STR_TO_DATE("23.4.1998.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10785 , 1 , "Mihaela" , "Sever" , "Pozornik" , STR_TO_DATE("10.11.1950.", "%d.%m.%Y.") , STR_TO_DATE("5.4.2006.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10786 , 2 , "Lucija" , "Tomi??" , "Pukovnik" , STR_TO_DATE("5.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("30.7.2008.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10787 , 1 , "Mauro" , "Abramovi??" , "Brigadir" , STR_TO_DATE("8.4.1970.", "%d.%m.%Y.") , STR_TO_DATE("20.10.2019.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10788 , 4 , "Leksi" , "Grgi??" , "Pozornik" , STR_TO_DATE("12.11.1968.", "%d.%m.%Y.") , STR_TO_DATE("6.8.2011.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10789 , 4 , "Dragica" , "Jovanovi??" , "Satnik" , STR_TO_DATE("23.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("30.4.2000.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10790 , 3 , "Frida" , "Kati??" , "Poru??nik" , STR_TO_DATE("13.5.1950.", "%d.%m.%Y.") , STR_TO_DATE("30.9.1993.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10791 , 2 , "Paisa" , "Ivankovi??" , "Poru??nik" , STR_TO_DATE("25.3.1953.", "%d.%m.%Y.") , STR_TO_DATE("2.7.1994.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10792 , 1 , "Bo??idar" , "Novosel" , "Razvodnik" , STR_TO_DATE("28.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("16.12.2011.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10793 , 1 , "Franjo" , "Antunovi??" , "Pukovnik" , STR_TO_DATE("10.9.1965.", "%d.%m.%Y.") , STR_TO_DATE("10.8.1993.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10794 , 3 , "Florijan" , "Filipovi??" , "Skupnik" , STR_TO_DATE("10.12.1963.", "%d.%m.%Y.") , STR_TO_DATE("26.8.1999.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10795 , 2 , "Siri" , "Jakovljevi??" , "Pozornik" , STR_TO_DATE("12.7.1958.", "%d.%m.%Y.") , STR_TO_DATE("18.6.2006.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10796 , 1 , "Eva" , "Novakovi??" , "Pozornik" , STR_TO_DATE("25.7.1970.", "%d.%m.%Y.") , STR_TO_DATE("19.5.2008.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10797 , 2 , "Serena" , "Tomi??" , "Brigadir" , STR_TO_DATE("18.12.1956.", "%d.%m.%Y.") , STR_TO_DATE("9.11.2016.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10798 , 2 , "Adam" , "Jakovljevi??" , "Poru??nik" , STR_TO_DATE("11.4.1966.", "%d.%m.%Y.") , STR_TO_DATE("10.2.2012.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10799 , 2 , "Jerko" , "Matkovi??" , "Pozornik" , STR_TO_DATE("29.10.1954.", "%d.%m.%Y.") , STR_TO_DATE("5.5.1992.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10800 , 3 , "Zaria" , "??ari??" , "Narednik" , STR_TO_DATE("1.3.1954.", "%d.%m.%Y.") , STR_TO_DATE("4.11.2015.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10801 , 2 , "Renata" , "Juri??i??" , "Poru??nik" , STR_TO_DATE("12.4.1961.", "%d.%m.%Y.") , STR_TO_DATE("9.12.2017.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10802 , 2 , "Neo" , "Popovi??" , "Pukovnik" , STR_TO_DATE("17.12.1952.", "%d.%m.%Y.") , STR_TO_DATE("25.10.1995.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10803 , 4 , "Amira" , "Mikuli??" , "Poru??nik" , STR_TO_DATE("11.8.1967.", "%d.%m.%Y.") , STR_TO_DATE("12.6.2005.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10804 , 1 , "Jordan" , "??ari??" , "Brigadir" , STR_TO_DATE("16.1.1954.", "%d.%m.%Y.") , STR_TO_DATE("10.12.2020.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10805 , 1 , "Vera" , "??imunovi??" , "Brigadir" , STR_TO_DATE("2.1.1953.", "%d.%m.%Y.") , STR_TO_DATE("29.12.2019.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10806 , 4 , "Emil" , "Matijevi??" , "Poru??nik" , STR_TO_DATE("13.8.1959.", "%d.%m.%Y.") , STR_TO_DATE("6.4.1995.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10807 , 1 , "Lea" , "Marjanovi??" , "Pozornik" , STR_TO_DATE("20.9.1964.", "%d.%m.%Y.") , STR_TO_DATE("3.7.1999.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10808 , 2 , "Samanta" , "Jakovljevi??" , "Narednik" , STR_TO_DATE("16.3.1966.", "%d.%m.%Y.") , STR_TO_DATE("26.12.2011.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10809 , 3 , "An??eo" , "Pavli??" , "Razvodnik" , STR_TO_DATE("28.2.1967.", "%d.%m.%Y.") , STR_TO_DATE("11.5.1996.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10810 , 1 , "Gloria" , "Radi??" , "Satnik" , STR_TO_DATE("28.2.1961.", "%d.%m.%Y.") , STR_TO_DATE("2.6.1991.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10811 , 4 , "Renato" , "Butkovi??" , "Poru??nik" , STR_TO_DATE("25.6.1964.", "%d.%m.%Y.") , STR_TO_DATE("15.1.1991.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10812 , 1 , "Jara" , "??osi??" , "Pozornik" , STR_TO_DATE("2.5.1970.", "%d.%m.%Y.") , STR_TO_DATE("27.8.2019.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10813 , 1 , "Antonio" , "??uri??" , "Bojnik" , STR_TO_DATE("14.7.1952.", "%d.%m.%Y.") , STR_TO_DATE("10.4.1997.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10814 , 1 , "Dorian" , "Ba??i??" , "Narednik" , STR_TO_DATE("5.5.1953.", "%d.%m.%Y.") , STR_TO_DATE("5.12.2004.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10815 , 3 , "Moreno" , "Antunovi??" , "Poru??nik" , STR_TO_DATE("20.6.1950.", "%d.%m.%Y.") , STR_TO_DATE("14.2.2000.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10816 , 1 , "Brigita" , "Crnkovi??" , "Pozornik" , STR_TO_DATE("29.3.1966.", "%d.%m.%Y.") , STR_TO_DATE("12.11.2013.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10817 , 3 , "Aliza" , "??imunovi??" , "Razvodnik" , STR_TO_DATE("14.9.1955.", "%d.%m.%Y.") , STR_TO_DATE("11.9.2010.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10818 , 2 , "Milica" , "??ivkovi??" , "Satnik" , STR_TO_DATE("15.9.1955.", "%d.%m.%Y.") , STR_TO_DATE("14.2.2016.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10819 , 2 , "Zoja" , "Bili??" , "Skupnik" , STR_TO_DATE("26.12.1962.", "%d.%m.%Y.") , STR_TO_DATE("28.2.1993.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10820 , 3 , "Tatjana" , "Krznari??" , "Skupnik" , STR_TO_DATE("10.4.1967.", "%d.%m.%Y.") , STR_TO_DATE("8.3.2020.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10821 , 4 , "Siri" , "Bo??i??" , "Bojnik" , STR_TO_DATE("22.6.1955.", "%d.%m.%Y.") , STR_TO_DATE("29.4.2013.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10822 , 2 , "Lina" , "Kralj" , "Skupnik" , STR_TO_DATE("16.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("24.3.1990.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10823 , 4 , "Noela" , "Ba??i??" , "Pozornik" , STR_TO_DATE("16.6.1970.", "%d.%m.%Y.") , STR_TO_DATE("17.6.1991.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10824 , 4 , "Lorena" , "Matkovi??" , "Bojnik" , STR_TO_DATE("13.8.1969.", "%d.%m.%Y.") , STR_TO_DATE("16.4.2011.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10825 , 2 , "Severino" , "Pavlovi??" , "Bojnik" , STR_TO_DATE("10.1.1963.", "%d.%m.%Y.") , STR_TO_DATE("24.7.2001.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10826 , 1 , "Magnolija" , "Buri??" , "Pukovnik" , STR_TO_DATE("16.7.1969.", "%d.%m.%Y.") , STR_TO_DATE("26.1.2017.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10827 , 3 , "Moli" , "Novosel" , "Pozornik" , STR_TO_DATE("20.9.1961.", "%d.%m.%Y.") , STR_TO_DATE("4.8.1995.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10828 , 3 , "Viktor" , "Mitrovi??" , "Poru??nik" , STR_TO_DATE("29.4.1968.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2003.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10829 , 3 , "Nora" , "Pavli??" , "Brigadir" , STR_TO_DATE("26.6.1966.", "%d.%m.%Y.") , STR_TO_DATE("30.10.2019.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10830 , 1 , "Lucija" , "??imuni??" , "Brigadir" , STR_TO_DATE("22.5.1956.", "%d.%m.%Y.") , STR_TO_DATE("20.10.2008.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10831 , 2 , "Nadia" , "Maru??i??" , "Pukovnik" , STR_TO_DATE("30.6.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2003.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10832 , 4 , "Lora" , "Vukovi??" , "Pozornik" , STR_TO_DATE("4.5.1962.", "%d.%m.%Y.") , STR_TO_DATE("6.6.1996.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10833 , 1 , "Evina" , "Petkovi??" , "Razvodnik" , STR_TO_DATE("25.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("6.2.1992.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10834 , 1 , "Nikola" , "Vidakovi??" , "Narednik" , STR_TO_DATE("17.11.1968.", "%d.%m.%Y.") , STR_TO_DATE("8.1.1993.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10835 , 2 , "Marta" , "Mileti??" , "Narednik" , STR_TO_DATE("2.10.1960.", "%d.%m.%Y.") , STR_TO_DATE("25.3.2014.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10836 , 4 , "Lika" , "Dragi??evi??" , "Narednik" , STR_TO_DATE("2.5.1954.", "%d.%m.%Y.") , STR_TO_DATE("24.3.2007.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10837 , 3 , "Zoe" , "Mikuli??" , "Narednik" , STR_TO_DATE("22.6.1965.", "%d.%m.%Y.") , STR_TO_DATE("7.4.2002.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10838 , 4 , "Simona" , "Bari??i??" , "Pozornik" , STR_TO_DATE("28.2.1970.", "%d.%m.%Y.") , STR_TO_DATE("25.2.2003.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10839 , 1 , "Tim" , "Peri??" , "Brigadir" , STR_TO_DATE("22.9.1954.", "%d.%m.%Y.") , STR_TO_DATE("10.8.2015.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10840 , 3 , "Teo" , "Vrdoljak" , "Satnik" , STR_TO_DATE("4.7.1967.", "%d.%m.%Y.") , STR_TO_DATE("4.1.2006.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10841 , 4 , "Ariel" , "Bari??i??" , "Satnik" , STR_TO_DATE("28.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("9.8.2000.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10842 , 3 , "Alen" , "Tomi??" , "Narednik" , STR_TO_DATE("23.7.1970.", "%d.%m.%Y.") , STR_TO_DATE("10.6.2019.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10843 , 3 , "Nira" , "??ur??evi??" , "Bojnik" , STR_TO_DATE("4.12.1967.", "%d.%m.%Y.") , STR_TO_DATE("6.10.2019.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10844 , 2 , "Kate" , "Petrovi??" , "Poru??nik" , STR_TO_DATE("22.9.1951.", "%d.%m.%Y.") , STR_TO_DATE("28.7.1990.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10845 , 4 , "Galilea" , "Mari??" , "Brigadir" , STR_TO_DATE("13.9.1966.", "%d.%m.%Y.") , STR_TO_DATE("11.4.2008.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10846 , 1 , "Kiana" , "Lon??ar" , "Pozornik" , STR_TO_DATE("24.11.1964.", "%d.%m.%Y.") , STR_TO_DATE("15.2.2020.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10847 , 4 , "Aida" , "Radi??" , "Narednik" , STR_TO_DATE("15.3.1963.", "%d.%m.%Y.") , STR_TO_DATE("17.11.2001.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10848 , 1 , "Adelina" , "Matijevi??" , "Razvodnik" , STR_TO_DATE("16.4.1953.", "%d.%m.%Y.") , STR_TO_DATE("28.5.2008.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10849 , 3 , "Elaina" , "Novosel" , "Pozornik" , STR_TO_DATE("20.2.1954.", "%d.%m.%Y.") , STR_TO_DATE("21.6.2008.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10850 , 3 , "Korina" , "Buri??" , "Poru??nik" , STR_TO_DATE("29.1.1956.", "%d.%m.%Y.") , STR_TO_DATE("16.1.2003.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10851 , 4 , "Velina" , "Marjanovi??" , "Poru??nik" , STR_TO_DATE("10.5.1959.", "%d.%m.%Y.") , STR_TO_DATE("29.11.2010.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10852 , 2 , "Marija" , "Mileti??" , "Bojnik" , STR_TO_DATE("10.6.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.2.1993.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10853 , 1 , "Karmen" , "Mandi??" , "Poru??nik" , STR_TO_DATE("1.5.1969.", "%d.%m.%Y.") , STR_TO_DATE("11.10.1993.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10854 , 1 , "Artemisa" , "Brajkovi??" , "Pukovnik" , STR_TO_DATE("5.2.1967.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2000.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10855 , 2 , "Kamila" , "Kralj" , "Satnik" , STR_TO_DATE("2.7.1963.", "%d.%m.%Y.") , STR_TO_DATE("24.2.2001.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10856 , 4 , "Goran" , "Krznari??" , "Brigadir" , STR_TO_DATE("26.7.1951.", "%d.%m.%Y.") , STR_TO_DATE("14.7.2013.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10857 , 4 , "Slaven" , "Matkovi??" , "Skupnik" , STR_TO_DATE("10.9.1963.", "%d.%m.%Y.") , STR_TO_DATE("24.9.2008.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10858 , 3 , "Hada" , "Kralj" , "Brigadir" , STR_TO_DATE("30.12.1957.", "%d.%m.%Y.") , STR_TO_DATE("8.8.2002.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10859 , 2 , "Nikol" , "Kralj" , "Skupnik" , STR_TO_DATE("26.2.1956.", "%d.%m.%Y.") , STR_TO_DATE("4.7.2001.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10860 , 1 , "Kenia" , "Dujmovi??" , "Skupnik" , STR_TO_DATE("17.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("2.6.1997.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10861 , 4 , "Fran" , "Perkovi??" , "Poru??nik" , STR_TO_DATE("10.1.1969.", "%d.%m.%Y.") , STR_TO_DATE("3.5.2010.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10862 , 2 , "Lovorka" , "Peri??" , "Poru??nik" , STR_TO_DATE("1.12.1968.", "%d.%m.%Y.") , STR_TO_DATE("1.7.2013.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10863 , 3 , "Vito" , "Kne??evi??" , "Narednik" , STR_TO_DATE("28.5.1968.", "%d.%m.%Y.") , STR_TO_DATE("4.2.2014.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10864 , 2 , "Fernand" , "Luki??" , "Poru??nik" , STR_TO_DATE("16.8.1955.", "%d.%m.%Y.") , STR_TO_DATE("11.5.2002.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10865 , 4 , "Breta" , "Perkovi??" , "Razvodnik" , STR_TO_DATE("7.3.1956.", "%d.%m.%Y.") , STR_TO_DATE("19.4.2011.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10866 , 3 , "Skila" , "Lovri??" , "Razvodnik" , STR_TO_DATE("10.4.1954.", "%d.%m.%Y.") , STR_TO_DATE("10.5.1997.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10867 , 4 , "Gabrijela" , "Markovi??" , "Razvodnik" , STR_TO_DATE("29.10.1952.", "%d.%m.%Y.") , STR_TO_DATE("18.10.2009.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10868 , 4 , "Lilia" , "Posavec" , "Pukovnik" , STR_TO_DATE("14.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("19.12.2006.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10869 , 1 , "Elanija" , "Sever" , "Razvodnik" , STR_TO_DATE("20.1.1961.", "%d.%m.%Y.") , STR_TO_DATE("7.5.2018.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10870 , 1 , "Ernest" , "Luki??" , "Poru??nik" , STR_TO_DATE("5.12.1966.", "%d.%m.%Y.") , STR_TO_DATE("21.7.2002.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10871 , 2 , "Amber" , "Sever" , "Pozornik" , STR_TO_DATE("12.1.1966.", "%d.%m.%Y.") , STR_TO_DATE("24.3.2009.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10872 , 4 , "Kiara" , "Gali??" , "Narednik" , STR_TO_DATE("10.10.1958.", "%d.%m.%Y.") , STR_TO_DATE("20.7.2011.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10873 , 2 , "Ivan" , "Jovanovi??" , "Poru??nik" , STR_TO_DATE("11.11.1965.", "%d.%m.%Y.") , STR_TO_DATE("3.3.2010.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10874 , 2 , "Theodora" , "Mileti??" , "Narednik" , STR_TO_DATE("23.1.1955.", "%d.%m.%Y.") , STR_TO_DATE("15.7.1994.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10875 , 3 , "Emberli" , "Peri??" , "Brigadir" , STR_TO_DATE("3.5.1964.", "%d.%m.%Y.") , STR_TO_DATE("22.11.1996.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10876 , 2 , "Rubi" , "Kralj" , "Brigadir" , STR_TO_DATE("18.9.1957.", "%d.%m.%Y.") , STR_TO_DATE("5.4.2005.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10877 , 3 , "Majin" , "??ur??evi??" , "Satnik" , STR_TO_DATE("21.9.1954.", "%d.%m.%Y.") , STR_TO_DATE("7.11.2010.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10878 , 2 , "Nala" , "Martinovi??" , "Skupnik" , STR_TO_DATE("1.7.1966.", "%d.%m.%Y.") , STR_TO_DATE("5.10.1995.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10879 , 3 , "Avi" , "Vukeli??" , "Bojnik" , STR_TO_DATE("4.4.1951.", "%d.%m.%Y.") , STR_TO_DATE("4.9.2006.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10880 , 3 , "Adam" , "Matkovi??" , "Narednik" , STR_TO_DATE("22.7.1958.", "%d.%m.%Y.") , STR_TO_DATE("5.9.1999.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10881 , 3 , "Bosiljka" , "??imunovi??" , "Satnik" , STR_TO_DATE("17.1.1957.", "%d.%m.%Y.") , STR_TO_DATE("19.1.2016.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10882 , 2 , "Jema" , "Pavi??" , "Narednik" , STR_TO_DATE("22.4.1957.", "%d.%m.%Y.") , STR_TO_DATE("10.11.1993.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10883 , 3 , "Brigita" , "Lovri??" , "Satnik" , STR_TO_DATE("23.10.1962.", "%d.%m.%Y.") , STR_TO_DATE("28.12.2010.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10884 , 4 , "Anabela" , "??ari??" , "Poru??nik" , STR_TO_DATE("10.11.1952.", "%d.%m.%Y.") , STR_TO_DATE("1.5.1998.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10885 , 1 , "Lili" , "Ba??i??" , "Brigadir" , STR_TO_DATE("8.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("20.7.2018.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10886 , 1 , "Oleg" , "Klari??" , "Satnik" , STR_TO_DATE("25.6.1970.", "%d.%m.%Y.") , STR_TO_DATE("9.3.1991.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10887 , 2 , "Harmina" , "Mandi??" , "Pozornik" , STR_TO_DATE("12.12.1967.", "%d.%m.%Y.") , STR_TO_DATE("24.6.1990.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10888 , 4 , "Fredo" , "??osi??" , "Pukovnik" , STR_TO_DATE("13.11.1961.", "%d.%m.%Y.") , STR_TO_DATE("26.1.2017.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10889 , 2 , "Selena" , "Matijevi??" , "Brigadir" , STR_TO_DATE("12.6.1968.", "%d.%m.%Y.") , STR_TO_DATE("1.9.1992.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10890 , 4 , "Antea" , "Vukovi??" , "Razvodnik" , STR_TO_DATE("14.3.1965.", "%d.%m.%Y.") , STR_TO_DATE("17.6.2019.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10891 , 3 , "Hrvoje" , "Vukovi??" , "Poru??nik" , STR_TO_DATE("2.10.1964.", "%d.%m.%Y.") , STR_TO_DATE("16.3.1992.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10892 , 2 , "Cecilija" , "Josipovi??" , "Pukovnik" , STR_TO_DATE("31.1.1956.", "%d.%m.%Y.") , STR_TO_DATE("18.3.2016.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10893 , 2 , "Leonardo" , "Mari??" , "Poru??nik" , STR_TO_DATE("16.4.1952.", "%d.%m.%Y.") , STR_TO_DATE("1.7.2016.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10894 , 3 , "Linda" , "??imi??" , "Satnik" , STR_TO_DATE("18.7.1950.", "%d.%m.%Y.") , STR_TO_DATE("17.11.1997.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10895 , 4 , "Marin" , "Bari??i??" , "Razvodnik" , STR_TO_DATE("1.3.1956.", "%d.%m.%Y.") , STR_TO_DATE("2.4.2006.", "%d.%m.%Y.") , "Mrtav" , "A-" ),
 ( 10896 , 4 , "Remi" , "Crnkovi??" , "Skupnik" , STR_TO_DATE("26.3.1955.", "%d.%m.%Y.") , STR_TO_DATE("7.6.2005.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10897 , 4 , "Aleksandra" , "Ba??i??" , "Poru??nik" , STR_TO_DATE("17.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("4.9.2004.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10898 , 3 , "Anastasija" , "Mari??" , "Narednik" , STR_TO_DATE("17.4.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2014.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10899 , 4 , "Maksima" , "Kova??i??" , "Pozornik" , STR_TO_DATE("8.2.1970.", "%d.%m.%Y.") , STR_TO_DATE("15.5.2012.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10900 , 3 , "Emili" , "??imi??" , "Skupnik" , STR_TO_DATE("30.9.1953.", "%d.%m.%Y.") , STR_TO_DATE("12.12.2009.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10901 , 3 , "Matej" , "Kova??" , "Brigadir" , STR_TO_DATE("1.1.1967.", "%d.%m.%Y.") , STR_TO_DATE("15.5.1994.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10902 , 3 , "Jerko" , "Novosel" , "Narednik" , STR_TO_DATE("25.12.1954.", "%d.%m.%Y.") , STR_TO_DATE("14.12.2002.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10903 , 4 , "Biserka" , "Crnkovi??" , "Bojnik" , STR_TO_DATE("16.5.1963.", "%d.%m.%Y.") , STR_TO_DATE("16.9.2011.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10904 , 1 , "Rita" , "Gali??" , "Pozornik" , STR_TO_DATE("4.7.1963.", "%d.%m.%Y.") , STR_TO_DATE("24.11.2006.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10905 , 4 , "Ivana" , "Ivanovi??" , "Narednik" , STR_TO_DATE("1.5.1970.", "%d.%m.%Y.") , STR_TO_DATE("13.12.1994.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10906 , 3 , "Ognjen" , "Krznari??" , "Skupnik" , STR_TO_DATE("18.2.1954.", "%d.%m.%Y.") , STR_TO_DATE("1.2.1992.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10907 , 1 , "Ofelia" , "Grgi??" , "Pukovnik" , STR_TO_DATE("8.11.1957.", "%d.%m.%Y.") , STR_TO_DATE("1.9.2008.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10908 , 3 , "Rea" , "Filipovi??" , "Pozornik" , STR_TO_DATE("4.12.1958.", "%d.%m.%Y.") , STR_TO_DATE("31.1.1999.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10909 , 2 , "Klementina" , "Lovri??" , "Razvodnik" , STR_TO_DATE("18.1.1967.", "%d.%m.%Y.") , STR_TO_DATE("30.12.1995.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10910 , 2 , "Itzela" , "Mati??" , "Poru??nik" , STR_TO_DATE("10.2.1963.", "%d.%m.%Y.") , STR_TO_DATE("26.9.1999.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10911 , 4 , "Rebeka" , "??ur??evi??" , "Razvodnik" , STR_TO_DATE("10.4.1956.", "%d.%m.%Y.") , STR_TO_DATE("2.2.2001.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10912 , 4 , "Gordan" , "Markovi??" , "Narednik" , STR_TO_DATE("24.8.1962.", "%d.%m.%Y.") , STR_TO_DATE("26.5.2011.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10913 , 1 , "Goran" , "Cindri??" , "Satnik" , STR_TO_DATE("20.2.1952.", "%d.%m.%Y.") , STR_TO_DATE("20.10.2014.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10914 , 4 , "Emir" , "Jakovljevi??" , "Poru??nik" , STR_TO_DATE("13.1.1968.", "%d.%m.%Y.") , STR_TO_DATE("25.9.1990.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10915 , 4 , "Imani" , "Jozi??" , "Bojnik" , STR_TO_DATE("17.6.1963.", "%d.%m.%Y.") , STR_TO_DATE("17.5.2001.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10916 , 2 , "Karla" , "Crnkovi??" , "Pozornik" , STR_TO_DATE("14.12.1961.", "%d.%m.%Y.") , STR_TO_DATE("12.5.2020.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10917 , 4 , "Karmen" , "Vidakovi??" , "Satnik" , STR_TO_DATE("12.11.1957.", "%d.%m.%Y.") , STR_TO_DATE("26.1.2000.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10918 , 2 , "Lilia" , "Vu??kovi??" , "Poru??nik" , STR_TO_DATE("3.12.1967.", "%d.%m.%Y.") , STR_TO_DATE("5.8.2002.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10919 , 2 , "Ton??ica" , "Grubi??i??" , "Narednik" , STR_TO_DATE("9.7.1950.", "%d.%m.%Y.") , STR_TO_DATE("29.3.2010.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10920 , 3 , "Franka" , "Gali??" , "Pozornik" , STR_TO_DATE("17.9.1970.", "%d.%m.%Y.") , STR_TO_DATE("1.5.2003.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10921 , 2 , "??eljkica" , "Matijevi??" , "Pukovnik" , STR_TO_DATE("8.3.1969.", "%d.%m.%Y.") , STR_TO_DATE("13.5.1990.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10922 , 2 , "Karina" , "Gali??" , "Brigadir" , STR_TO_DATE("6.9.1966.", "%d.%m.%Y.") , STR_TO_DATE("3.3.1995.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10923 , 4 , "Ira" , "Lon??ar" , "Brigadir" , STR_TO_DATE("14.7.1956.", "%d.%m.%Y.") , STR_TO_DATE("8.3.2014.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10924 , 4 , "Tihana" , "Juri??i??" , "Bojnik" , STR_TO_DATE("7.7.1950.", "%d.%m.%Y.") , STR_TO_DATE("18.8.2005.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10925 , 3 , "Vanja" , "Ba??i??" , "Satnik" , STR_TO_DATE("26.9.1967.", "%d.%m.%Y.") , STR_TO_DATE("20.10.1996.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10926 , 1 , "Mikaela" , "Peri??" , "Poru??nik" , STR_TO_DATE("13.10.1961.", "%d.%m.%Y.") , STR_TO_DATE("26.8.2000.", "%d.%m.%Y.") , "Neaktivan" , "B+" ),
 ( 10927 , 3 , "Janica" , "Jozi??" , "Pozornik" , STR_TO_DATE("8.2.1956.", "%d.%m.%Y.") , STR_TO_DATE("3.5.2013.", "%d.%m.%Y.") , "Aktivan" , "AB-" ),
 ( 10928 , 4 , "Korina" , "Sever" , "Narednik" , STR_TO_DATE("13.6.1953.", "%d.%m.%Y.") , STR_TO_DATE("19.12.2015.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10929 , 2 , "Vigo" , "Krznari??" , "Skupnik" , STR_TO_DATE("7.7.1955.", "%d.%m.%Y.") , STR_TO_DATE("5.1.2007.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10930 , 4 , "Chaja" , "Josipovi??" , "Skupnik" , STR_TO_DATE("21.9.1970.", "%d.%m.%Y.") , STR_TO_DATE("5.9.2011.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10931 , 1 , "Zorka" , "??uri??" , "Narednik" , STR_TO_DATE("3.2.1966.", "%d.%m.%Y.") , STR_TO_DATE("5.11.2011.", "%d.%m.%Y.") , "Neaktivan" , "A-" ),
 ( 10932 , 4 , "Ferdinand" , "Jovanovi??" , "Narednik" , STR_TO_DATE("4.10.1966.", "%d.%m.%Y.") , STR_TO_DATE("16.12.2020.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10933 , 1 , "Elio" , "Posavec" , "Bojnik" , STR_TO_DATE("3.6.1964.", "%d.%m.%Y.") , STR_TO_DATE("14.10.2005.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10934 , 4 , "Alijah" , "Butkovi??" , "Pukovnik" , STR_TO_DATE("14.7.1967.", "%d.%m.%Y.") , STR_TO_DATE("12.9.2015.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10935 , 3 , "Ezra" , "Jovanovi??" , "Narednik" , STR_TO_DATE("21.7.1955.", "%d.%m.%Y.") , STR_TO_DATE("8.9.2005.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10936 , 4 , "Neven" , "Kova??" , "Bojnik" , STR_TO_DATE("10.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("22.10.2019.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10937 , 2 , "??eljko" , "Luki??" , "Skupnik" , STR_TO_DATE("27.6.1963.", "%d.%m.%Y.") , STR_TO_DATE("21.2.2013.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10938 , 2 , "Oliver" , "Mari??" , "Pozornik" , STR_TO_DATE("26.12.1966.", "%d.%m.%Y.") , STR_TO_DATE("3.12.1999.", "%d.%m.%Y.") , "Mrtav" , "0+" ),
 ( 10939 , 2 , "Teo" , "Posavec" , "Satnik" , STR_TO_DATE("27.4.1962.", "%d.%m.%Y.") , STR_TO_DATE("8.3.1997.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10940 , 3 , "Damir" , "Petrovi??" , "Razvodnik" , STR_TO_DATE("17.4.1950.", "%d.%m.%Y.") , STR_TO_DATE("17.6.1995.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10941 , 2 , "Zara" , "Filipovi??" , "Brigadir" , STR_TO_DATE("20.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("19.8.2019.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10942 , 3 , "Zahra" , "Kova??evi??" , "Poru??nik" , STR_TO_DATE("17.4.1970.", "%d.%m.%Y.") , STR_TO_DATE("2.3.2016.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10943 , 2 , "Penelopa" , "Horvat" , "Skupnik" , STR_TO_DATE("30.6.1953.", "%d.%m.%Y.") , STR_TO_DATE("3.7.2003.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10944 , 2 , "??eljka" , "Jakovljevi??" , "Narednik" , STR_TO_DATE("8.6.1952.", "%d.%m.%Y.") , STR_TO_DATE("15.1.2010.", "%d.%m.%Y.") , "Mrtav" , "A+" ),
 ( 10945 , 2 , "Ljerka" , "Ivankovi??" , "Narednik" , STR_TO_DATE("1.7.1954.", "%d.%m.%Y.") , STR_TO_DATE("28.12.2013.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10946 , 2 , "Marta" , "Kati??" , "Poru??nik" , STR_TO_DATE("10.8.1969.", "%d.%m.%Y.") , STR_TO_DATE("24.10.2020.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10947 , 3 , "Dragica" , "Bo??njak" , "Poru??nik" , STR_TO_DATE("6.12.1956.", "%d.%m.%Y.") , STR_TO_DATE("29.3.2012.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10948 , 1 , "Mina" , "Tomi??" , "Pozornik" , STR_TO_DATE("15.4.1968.", "%d.%m.%Y.") , STR_TO_DATE("1.5.2014.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10949 , 4 , "Katalina" , "??imuni??" , "Narednik" , STR_TO_DATE("27.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("18.10.2010.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10950 , 2 , "Jaka" , "Bo??njak" , "Bojnik" , STR_TO_DATE("3.3.1953.", "%d.%m.%Y.") , STR_TO_DATE("1.3.2001.", "%d.%m.%Y.") , "Aktivan" , "B-" ),
 ( 10951 , 2 , "Lidija" , "Popovi??" , "Satnik" , STR_TO_DATE("1.8.1960.", "%d.%m.%Y.") , STR_TO_DATE("17.12.2015.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10952 , 3 , "Jura" , "Ivankovi??" , "Skupnik" , STR_TO_DATE("24.9.1958.", "%d.%m.%Y.") , STR_TO_DATE("7.12.1996.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10953 , 3 , "Anamarija" , "Vu??kovi??" , "Pozornik" , STR_TO_DATE("17.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("11.2.2016.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10954 , 2 , "Damjan" , "Petrovi??" , "Satnik" , STR_TO_DATE("30.5.1961.", "%d.%m.%Y.") , STR_TO_DATE("26.12.2017.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10955 , 3 , "Eli" , "Matkovi??" , "Narednik" , STR_TO_DATE("24.11.1963.", "%d.%m.%Y.") , STR_TO_DATE("5.10.2002.", "%d.%m.%Y.") , "Umirovljen" , "0+" ),
 ( 10956 , 4 , "Tristan" , "Ba??i??" , "Razvodnik" , STR_TO_DATE("5.2.1963.", "%d.%m.%Y.") , STR_TO_DATE("2.3.2016.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10957 , 4 , "Lea" , "Gali??" , "Pukovnik" , STR_TO_DATE("16.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("6.12.2015.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10958 , 2 , "Erik" , "Dujmovi??" , "Satnik" , STR_TO_DATE("20.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("4.12.2015.", "%d.%m.%Y.") , "Umirovljen" , "AB+" ),
 ( 10959 , 1 , "Lovorka" , "Vukeli??" , "Pukovnik" , STR_TO_DATE("19.5.1964.", "%d.%m.%Y.") , STR_TO_DATE("20.6.2018.", "%d.%m.%Y.") , "Umirovljen" , "A+" ),
 ( 10960 , 4 , "Kristina" , "Mari??" , "Poru??nik" , STR_TO_DATE("19.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("12.9.2010.", "%d.%m.%Y.") , "Mrtav" , "0-" ),
 ( 10961 , 1 , "Regina" , "Bo??i??" , "Razvodnik" , STR_TO_DATE("8.12.1965.", "%d.%m.%Y.") , STR_TO_DATE("2.1.1990.", "%d.%m.%Y.") , "Mrtav" , "B+" ),
 ( 10962 , 3 , "Ante" , "Kralj" , "Pukovnik" , STR_TO_DATE("1.10.1953.", "%d.%m.%Y.") , STR_TO_DATE("23.1.2019.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10963 , 3 , "Jeremija" , "Pavli??" , "Skupnik" , STR_TO_DATE("8.1.1964.", "%d.%m.%Y.") , STR_TO_DATE("14.2.1996.", "%d.%m.%Y.") , "Aktivan" , "AB+" ),
 ( 10964 , 2 , "Dr??islav" , "Luki??" , "Satnik" , STR_TO_DATE("3.5.1970.", "%d.%m.%Y.") , STR_TO_DATE("3.3.2004.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10965 , 2 , "Imani" , "Cvitkovi??" , "Satnik" , STR_TO_DATE("5.5.1956.", "%d.%m.%Y.") , STR_TO_DATE("10.3.2007.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10966 , 1 , "Teresa" , "Golubi??" , "Poru??nik" , STR_TO_DATE("24.8.1961.", "%d.%m.%Y.") , STR_TO_DATE("10.1.1998.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10967 , 1 , "Fredo" , "Bo??i??" , "Brigadir" , STR_TO_DATE("23.9.1960.", "%d.%m.%Y.") , STR_TO_DATE("12.2.2017.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10968 , 1 , "Krunoslav" , "Marjanovi??" , "Pozornik" , STR_TO_DATE("11.9.1958.", "%d.%m.%Y.") , STR_TO_DATE("5.4.2007.", "%d.%m.%Y.") , "Neaktivan" , "B-" ),
 ( 10969 , 1 , "Sven" , "Maru??i??" , "Pozornik" , STR_TO_DATE("25.2.1956.", "%d.%m.%Y.") , STR_TO_DATE("4.1.2012.", "%d.%m.%Y.") , "Umirovljen" , "AB-" ),
 ( 10970 , 4 , "Iris" , "Krznari??" , "Poru??nik" , STR_TO_DATE("30.6.1956.", "%d.%m.%Y.") , STR_TO_DATE("25.6.1990.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10971 , 1 , "Moreno" , "Babi??" , "Pukovnik" , STR_TO_DATE("28.6.1960.", "%d.%m.%Y.") , STR_TO_DATE("15.5.2001.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10972 , 4 , "Vladimir" , "Jovanovi??" , "Brigadir" , STR_TO_DATE("5.10.1966.", "%d.%m.%Y.") , STR_TO_DATE("16.4.1995.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10973 , 4 , "Dea" , "??ivkovi??" , "Brigadir" , STR_TO_DATE("7.9.1954.", "%d.%m.%Y.") , STR_TO_DATE("10.7.2009.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10974 , 2 , "Siri" , "Golubi??" , "Razvodnik" , STR_TO_DATE("20.6.1959.", "%d.%m.%Y.") , STR_TO_DATE("17.8.2005.", "%d.%m.%Y.") , "Umirovljen" , "A-" ),
 ( 10975 , 1 , "Anabela" , "??ur??evi??" , "Brigadir" , STR_TO_DATE("31.1.1970.", "%d.%m.%Y.") , STR_TO_DATE("7.4.2010.", "%d.%m.%Y.") , "Mrtav" , "AB+" ),
 ( 10976 , 1 , "Elina" , "Kati??" , "Pozornik" , STR_TO_DATE("5.10.1959.", "%d.%m.%Y.") , STR_TO_DATE("15.12.2000.", "%d.%m.%Y.") , "Neaktivan" , "A+" ),
 ( 10977 , 3 , "Otta" , "Buri??" , "Skupnik" , STR_TO_DATE("24.4.1966.", "%d.%m.%Y.") , STR_TO_DATE("10.11.2012.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10978 , 2 , "Selina" , "Lon??ari??" , "Narednik" , STR_TO_DATE("11.3.1967.", "%d.%m.%Y.") , STR_TO_DATE("15.6.1994.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10979 , 1 , "Severino" , "Vidakovi??" , "Bojnik" , STR_TO_DATE("28.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("10.2.2008.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10980 , 4 , "Ezekiel" , "Mitrovi??" , "Pukovnik" , STR_TO_DATE("6.10.1964.", "%d.%m.%Y.") , STR_TO_DATE("15.5.1993.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10981 , 3 , "Nikolina" , "Cindri??" , "Narednik" , STR_TO_DATE("12.8.1962.", "%d.%m.%Y.") , STR_TO_DATE("8.4.2010.", "%d.%m.%Y.") , "Aktivan" , "B+" ),
 ( 10982 , 4 , "Emil" , "Vukovi??" , "Razvodnik" , STR_TO_DATE("19.11.1952.", "%d.%m.%Y.") , STR_TO_DATE("1.1.2016.", "%d.%m.%Y.") , "Neaktivan" , "0+" ),
 ( 10983 , 4 , "Sumka" , "Jeli??" , "Pukovnik" , STR_TO_DATE("5.2.1953.", "%d.%m.%Y.") , STR_TO_DATE("21.3.2011.", "%d.%m.%Y.") , "Umirovljen" , "0-" ),
 ( 10984 , 1 , "Anamarija" , "Mari??" , "Razvodnik" , STR_TO_DATE("23.10.1955.", "%d.%m.%Y.") , STR_TO_DATE("5.7.1993.", "%d.%m.%Y.") , "Aktivan" , "A-" ),
 ( 10985 , 4 , "Rahela" , "Vidakovi??" , "Pukovnik" , STR_TO_DATE("2.10.1958.", "%d.%m.%Y.") , STR_TO_DATE("19.7.2012.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10986 , 1 , "Dijana" , "Radi??" , "Poru??nik" , STR_TO_DATE("7.11.1968.", "%d.%m.%Y.") , STR_TO_DATE("20.12.2018.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10987 , 2 , "Lovro" , "Jurkovi??" , "Brigadir" , STR_TO_DATE("15.8.1962.", "%d.%m.%Y.") , STR_TO_DATE("19.9.2017.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10988 , 4 , "Leonida" , "Lon??ari??" , "Bojnik" , STR_TO_DATE("28.3.1962.", "%d.%m.%Y.") , STR_TO_DATE("10.5.1991.", "%d.%m.%Y.") , "Aktivan" , "A+" ),
 ( 10989 , 2 , "Eva" , "Abramovi??" , "Pozornik" , STR_TO_DATE("24.1.1966.", "%d.%m.%Y.") , STR_TO_DATE("11.5.1997.", "%d.%m.%Y.") , "Neaktivan" , "AB-" ),
 ( 10990 , 1 , "Evona" , "Crnkovi??" , "Skupnik" , STR_TO_DATE("8.1.1951.", "%d.%m.%Y.") , STR_TO_DATE("20.5.2020.", "%d.%m.%Y.") , "Mrtav" , "B-" ),
 ( 10991 , 2 , "Aida" , "??ari??" , "Pozornik" , STR_TO_DATE("14.4.1960.", "%d.%m.%Y.") , STR_TO_DATE("2.6.2010.", "%d.%m.%Y.") , "Aktivan" , "0-" ),
 ( 10992 , 2 , "Katarina" , "Radi??" , "Pukovnik" , STR_TO_DATE("4.11.1956.", "%d.%m.%Y.") , STR_TO_DATE("27.12.1994.", "%d.%m.%Y.") , "Umirovljen" , "B-" ),
 ( 10993 , 4 , "Lana" , "Krznari??" , "Satnik" , STR_TO_DATE("15.8.1958.", "%d.%m.%Y.") , STR_TO_DATE("20.9.1993.", "%d.%m.%Y.") , "Neaktivan" , "0-" ),
 ( 10994 , 2 , "Oskar" , "Matkovi??" , "Skupnik" , STR_TO_DATE("17.6.1970.", "%d.%m.%Y.") , STR_TO_DATE("15.4.2014.", "%d.%m.%Y.") , "Aktivan" , "0+" ),
 ( 10995 , 3 , "Bena" , "Markovi??" , "Pozornik" , STR_TO_DATE("26.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("25.11.2003.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10996 , 3 , "Marina" , "Marjanovi??" , "Skupnik" , STR_TO_DATE("27.3.1952.", "%d.%m.%Y.") , STR_TO_DATE("19.6.2003.", "%d.%m.%Y.") , "Neaktivan" , "AB+" ),
 ( 10997 , 1 , "Felicija" , "Herceg" , "Pozornik" , STR_TO_DATE("10.1.1958.", "%d.%m.%Y.") , STR_TO_DATE("29.4.2007.", "%d.%m.%Y.") , "Umirovljen" , "B+" ),
 ( 10998 , 3 , "Bo??ana" , "Gali??" , "Narednik" , STR_TO_DATE("1.6.1968.", "%d.%m.%Y.") , STR_TO_DATE("19.10.1995.", "%d.%m.%Y.") , "Mrtav" , "AB-" ),
 ( 10999 , 3 , "admin" , "admin" , "Razvodnik" , STR_TO_DATE("4.9.1955.", "%d.%m.%Y.") , STR_TO_DATE("24.11.1995.", "%d.%m.%Y.") , "Pokojan u du??i" , "A+" );





INSERT INTO tura VALUES
(1, "Indijska i Pakistanska tura", "Mirovna tura", STR_TO_DATE("01.08.2008","%d.%m.%Y."), STR_TO_DATE("04.11.2021","%d.%m.%Y.")),
(2, "1. Afganistanska tura", "Vojna tura", STR_TO_DATE("01.10.2008","%d.%m.%Y."), STR_TO_DATE("15.04.2009","%d.%m.%Y.")),
(3, "Gr??ka tura", "Vojna tura", STR_TO_DATE("01.12.2010","%d.%m.%Y."), STR_TO_DATE("16.11.2014","%d.%m.%Y.")),
(4, "Poljska tura", "Mirovna tura", STR_TO_DATE("01.01.2015","%d.%m.%Y."), STR_TO_DATE("04.09.2015","%d.%m.%Y.")),
(5, "Ukrainska tura", "Vojna tura", STR_TO_DATE("24.02.2022","%d.%m.%Y."), STR_TO_DATE("30.10.2022","%d.%m.%Y.")),
(6, "2. Afganistanska tura", "Mirovna tura", STR_TO_DATE("01.12.2010","%d.%m.%Y."), STR_TO_DATE("16.11.2014","%d.%m.%Y.")),
(7, "Ju??noafri??ka tura", "Mirovna tura", STR_TO_DATE("04.10.2013","%d.%m.%Y."), STR_TO_DATE("13.09.2014","%d.%m.%Y.")),
(8, "Taiwanska tura", "Mirovna tura", STR_TO_DATE("08.06.2019","%d.%m.%Y."), STR_TO_DATE("15.07.2020","%d.%m.%Y.")),
(9, "Ju??no Koreanska tura", "Mirovna tura", STR_TO_DATE("24.11.2009","%d.%m.%Y."), STR_TO_DATE("16.02.2011","%d.%m.%Y.")),
(10, "Bosanskohercegova??ka tura", "Mirovna tura", STR_TO_DATE("13.10.2010","%d.%m.%Y."), STR_TO_DATE("16.11.2012","%d.%m.%Y.")),
(11, "Venezuelanksa tura", "Vojna tura", STR_TO_DATE("26.09.2015","%d.%m.%Y."), STR_TO_DATE("16.08.2017","%d.%m.%Y.")),
(12, "Norve??ka tura", "Mirovna tura", STR_TO_DATE("01.04.2016","%d.%m.%Y."), STR_TO_DATE("23.04.2018","%d.%m.%Y.")),
(13, "??vicarska tura ", "Mirovna tura", STR_TO_DATE("07.05.2006","%d.%m.%Y."), STR_TO_DATE("20.11.2009","%d.%m.%Y.")),
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
(2000,"Patria AMV","Kota??na oklopna vozila",158,3),
(2001,"International MaxxPro","Kota??na oklopna vozila",40,5),
(2002,"Oshkosh M-ATV","Kota??na oklopna vozila",172,5),
(2003,"HMMWV","Kota??na oklopna vozila",112,4),
(2004,"Iveco LMV","Kota??na oklopna vozila",14,4),
(2005,"BOV","Kota??na oklopna vozila",84,6),

(2006,"M2 Bradley","Gusjeni??na oklopna vozila",67,5),
(2007,"BVP M-80A","Gusjeni??na oklopna vozila",128,4),
(2008,"M-84","Gusjeni??na oklopna vozila",78,4),

(2009,"RTOP-11 Kralj Petar Kre??imir IV.","Mornarica",1,50),
(2010,"RTOP-12 Kralj Dmitar Zvonimir","Mornarica",1,20),
(2011,"RTOP-21 ??ibenik","Mornarica",1,35),
(2012,"RTOP-41 Vukovar","Mornarica",1,36),
(2013,"RTOP-42 Dubrovnik","Mornarica",1,42),
(2014,"Lovac mina LM-51 Kor??ula","Mornarica",1,55),

(2015,"Dassault Rafale","Borbeni avioni",12,2),
(2016,"Mikojan-Gurjevi?? MiG-21","Borbeni avioni",7,1),

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
 ( 6007 , 9017 , "Manja ??teta na oklopu i manji popravci" , STR_TO_DATE("25.12.2017.", "%d.%m.%Y.") , STR_TO_DATE("23.9.2007.", "%d.%m.%Y.") , 345516 ),
 ( 6008 , 9003 , "Popravci na rubu neisplativosti" , STR_TO_DATE("18.3.2030.", "%d.%m.%Y.") , STR_TO_DATE("3.7.2005.", "%d.%m.%Y.") , 339466 ),
 ( 6009 , 9016 , "Vozilo nije u voznome stanju" , STR_TO_DATE("5.3.2022.", "%d.%m.%Y.") , STR_TO_DATE("11.8.2006.", "%d.%m.%Y.") , 202165 ),
 ( 6010 , 9012 , "Vozilo nije u voznome stanju" , STR_TO_DATE("18.8.1996.", "%d.%m.%Y.") , STR_TO_DATE("2.12.2019.", "%d.%m.%Y.") , 247772 ),
 ( 6011 , 9019 , "Popravci na rubu neisplativosti" , STR_TO_DATE("23.6.2024.", "%d.%m.%Y.") , STR_TO_DATE("18.7.2005.", "%d.%m.%Y.") , 253430 ),
 ( 6012 , 9003 , "Vozilu je potrebna kompletna restauracija" , STR_TO_DATE("14.9.2024.", "%d.%m.%Y.") , STR_TO_DATE("7.9.2029.", "%d.%m.%Y.") , 267460 ),
 ( 6013 , 9005 , "Popravci na rubu neisplativosti" , STR_TO_DATE("13.2.1997.", "%d.%m.%Y.") , STR_TO_DATE("17.6.1999.", "%d.%m.%Y.") , 367066 ),
 ( 6014 , 9006 , "Manja ??teta na oklopu i manji popravci" , STR_TO_DATE("20.10.2028.", "%d.%m.%Y.") , STR_TO_DATE("6.9.2004.", "%d.%m.%Y.") , 356967 ),
 ( 6015 , 9007 , "Popravci na rubu neisplativosti" , STR_TO_DATE("13.8.2004.", "%d.%m.%Y.") , STR_TO_DATE("8.2.2001.", "%d.%m.%Y.") , 482278 ),
 ( 6016 , 9020 , "Potrebni mali popravci" , STR_TO_DATE("1.9.2008.", "%d.%m.%Y.") , STR_TO_DATE("28.5.2011.", "%d.%m.%Y.") , 324646 ),
 ( 6017 , 9018 , "Vozilo nije u voznome stanju" , STR_TO_DATE("28.10.2030.", "%d.%m.%Y.") , STR_TO_DATE("21.2.2027.", "%d.%m.%Y.") , 220281 ),
 ( 6018 , 9006 , "Manja ??teta na oklopu i manji popravci" , STR_TO_DATE("9.1.2003.", "%d.%m.%Y.") , STR_TO_DATE("12.12.1994.", "%d.%m.%Y.") , 213060 ),
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
(1308, "HS Produkt VHS-2", "Juri??na strojnica", 20000),
(1309, "HS Produkt VHS", "Juri??na strojnica", 7800),
(1310, "Heckler & Koch G-36", "Juri??na strojnica", 750),
(1311, "Heckler & Koch HK416", "Juri??na strojnica", 250),
(1312, "FN F2000", "Juri??na strojnica", 100),
(1313, "Zastava M70", "Juri??na strojnica", 88640),
(1314, "PM md. 63/65", "Juri??na strojnica", 3420),
(1315, "FN Minimi", "Pu??kostrojnica", 100),
(1316, "FN MAG", "Pu??kostrojnica", 400),
(1317, "Ultimax 100", "Pu??kostrojnica", 100),
(1318, "Heckler & Koch HK21", "Pu??kostrojnica", 300),
(1319, "Zastava M84", "Pu??kostrojnica", 1400),
(1320, "Browning M2", "Pu??kostrojnica", 700),
(1321, "Heckler & Koch HK417", "Snajperska pu??ka", 250),
(1322, "Remington M40", "Snajperska pu??ka", 70),
(1323, "SAKO TRG-42", "Snajperska pu??ka", 240),
(1324, "MACS M3", "Snajperska pu??ka", 20),
(1325, "Barrett M82", "Snajperska pu??ka", 24),
(1326, "RT-20", "Snajperska pu??ka", 4),
(1327, "Franchi SPAS-12", "Sa??marica", 100),
(1328, "Benelli M4 Super 90", "Sa??marica", 250),
(1329, "Heckler & Koch AG36", "Baca?? granata", 300),
(1330, "RBG-6", "Baca?? granata", 124),
(1331, "Mk 19 baca?? granata", "Baca?? granata", 92),
(1332, "Spike LR2", "Protuoklopno naoru??anje || ATGM", 16),
(1333, "FGM-148 Javelin", "Protuoklopno naoru??anje || ATGM", 5),
(1334, "BGM-71 TOW-2", "Protuoklopno naoru??anje || ATGM", 134),
(1335, "9K115-2 Metis-M", "Protuoklopno naoru??anje || ATGM", 54),
(1336, "9M113 Konkurs", "Protuoklopno naoru??anje || ATGM", 42),
(1337, "9M111 Fagot", "Protuoklopno naoru??anje || ATGM", 119),
(1338, "9M14 Maljutka", "Protuoklopno naoru??anje || ATGM", 216),
(1339, "RPG-22", "Protuoklopno naoru??anje || RPG", 300),
(1340, "AT4", "Protuoklopno naoru??anje || RPG", 55),
(1341, "M57", "Minobaca??", 69),
(1342, "M96", "Minobaca??", 69),
(1343, "M75", "Minobaca??", 43),
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
(1354, "DOK-ING MV-4 Robot/??ista?? mina", "Protueksplozivna oprema", 4),
(1355, "Telerob tEODor Robot", "Protueksplozivna oprema", 2),
(1356, "Alaska vojni ??atori", "Prijenosna struktura", 50),
(1357, "Role 2B / Vojna terenska bolnica", "Prijenosna struktura", 1),
(1358, "ACH balisti??na kaciga", "Osobna za??titna oprema", 5000),
(1359, "Kroko vojna pancirka", "Osobna za??titna oprema", 5000),
(1360, "Standardna vojna uniforma", "Osobna za??titna oprema", 2000),
(1361, "Veliki vojni ruksak", "Ruksak", 1100),
(1362, "Mali vojni ruksak", "Ruksak", 1920),
(1363, "Vojne ??izme Jelen", "Osobna za??titna oprema", 2500);



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
 ( 1000 , 10036 , "Izlije??en" , STR_TO_DATE("28.12.2000.", "%d.%m.%Y.") , STR_TO_DATE("15.3.2021.", "%d.%m.%Y.") , "Srednje ozlije??en" , 44187 ),
 ( 1001 , 10207 , "U tijeku" , STR_TO_DATE("7.4.1996.", "%d.%m.%Y.") , STR_TO_DATE("15.6.2021.", "%d.%m.%Y.") , "Slabo ozljie??en" , 76427 ),
 ( 1002 , 10251 , "U tijeku" , STR_TO_DATE("11.2.2013.", "%d.%m.%Y.") , STR_TO_DATE("21.11.2022.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 44531 ),
 ( 1003 , 10846 , "U tijeku" , STR_TO_DATE("10.10.2008.", "%d.%m.%Y.") , STR_TO_DATE("20.2.2021.", "%d.%m.%Y.") , "Srednje ozlije??en" , 99963 ),
 ( 1004 , 10037 , "Izlije??en" , STR_TO_DATE("13.11.2007.", "%d.%m.%Y.") , STR_TO_DATE("22.5.2022.", "%d.%m.%Y.") , "Srednje ozlije??en" , 23204 ),
 ( 1005 , 10212 , "Izlije??en" , STR_TO_DATE("13.5.1998.", "%d.%m.%Y.") , STR_TO_DATE("15.7.2022.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 25238 ),
 ( 1006 , 10983 , "Izlije??en" , STR_TO_DATE("15.7.1993.", "%d.%m.%Y.") , STR_TO_DATE("27.7.2022.", "%d.%m.%Y.") , "Slabo ozljie??en" , 28933 ),
 ( 1007 , 10562 , "Izlije??en" , STR_TO_DATE("15.2.2001.", "%d.%m.%Y.") , STR_TO_DATE("17.12.2022.", "%d.%m.%Y.") , "Srednje ozlije??en" , 37088 ),
 ( 1008 , 10211 , "U tijeku" , STR_TO_DATE("14.4.1997.", "%d.%m.%Y.") , STR_TO_DATE("19.3.2020.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 29812 ),
 ( 1009 , 10971 , "Izlije??en" , STR_TO_DATE("16.5.2010.", "%d.%m.%Y.") , STR_TO_DATE("28.8.2020.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 36829 ),
 ( 1010 , 10205 , "U tijeku" , STR_TO_DATE("5.10.1992.", "%d.%m.%Y.") , STR_TO_DATE("5.11.2020.", "%d.%m.%Y.") , "Srednje ozlije??en" , 10338 ),
 ( 1011 , 10437 , "Izlije??en" , STR_TO_DATE("4.2.2012.", "%d.%m.%Y.") , STR_TO_DATE("10.10.2021.", "%d.%m.%Y.") , "Srednje ozlije??en" , 34986 ),
 ( 1012 , 10877 , "U tijeku" , STR_TO_DATE("28.4.2004.", "%d.%m.%Y.") , STR_TO_DATE("15.2.2020.", "%d.%m.%Y.") , "Slabo ozljie??en" , 40438 ),
 ( 1013 , 10287 , "Izlije??en" , STR_TO_DATE("18.1.1994.", "%d.%m.%Y.") , STR_TO_DATE("16.4.2022.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 35555 ),
 ( 1014 , 10710 , "Izlije??en" , STR_TO_DATE("14.7.2008.", "%d.%m.%Y.") , STR_TO_DATE("6.4.2020.", "%d.%m.%Y.") , "Srednje ozlije??en" , 75837 ),
 ( 1015 , 10009 , "Izlije??en" , STR_TO_DATE("28.4.2001.", "%d.%m.%Y.") , STR_TO_DATE("1.8.2021.", "%d.%m.%Y.") , "Srednje ozlije??en" , 51694 ),
 ( 1016 , 10184 , "U tijeku" , STR_TO_DATE("20.10.1999.", "%d.%m.%Y.") , STR_TO_DATE("24.9.2020.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 53144 ),
 ( 1017 , 10060 , "Izlije??en" , STR_TO_DATE("18.12.2018.", "%d.%m.%Y.") , STR_TO_DATE("28.1.2021.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 87816 ),
 ( 1018 , 10028 , "U tijeku" , STR_TO_DATE("20.9.2001.", "%d.%m.%Y.") , STR_TO_DATE("9.9.2021.", "%d.%m.%Y.") , "Srednje ozlije??en" , 12751 ),
 ( 1019 , 10091 , "U tijeku" , STR_TO_DATE("22.7.2003.", "%d.%m.%Y.") , STR_TO_DATE("27.6.2022.", "%d.%m.%Y.") , "Srednje ozlije??en" , 95740 ),
 ( 1020 , 10199 , "Izlije??en" , STR_TO_DATE("18.9.2004.", "%d.%m.%Y.") , STR_TO_DATE("12.9.2020.", "%d.%m.%Y.") , "Srednje ozlije??en" , 36787 ),
 ( 1021 , 10390 , "Izlije??en" , STR_TO_DATE("2.4.2007.", "%d.%m.%Y.") , STR_TO_DATE("14.4.2022.", "%d.%m.%Y.") , "Slabo ozljie??en" , 25904 ),
 ( 1022 , 10452 , "Izlije??en" , STR_TO_DATE("12.5.2000.", "%d.%m.%Y.") , STR_TO_DATE("15.3.2021.", "%d.%m.%Y.") , "Slabo ozljie??en" , 59665 ),
 ( 1023 , 10833 , "Izlije??en" , STR_TO_DATE("2.2.1994.", "%d.%m.%Y.") , STR_TO_DATE("10.4.2020.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 91379 ),
 ( 1024 , 10781 , "Izlije??en" , STR_TO_DATE("10.1.2017.", "%d.%m.%Y.") , STR_TO_DATE("11.4.2021.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 40404 ),
 ( 1025 , 10103 , "U tijeku" , STR_TO_DATE("14.11.2013.", "%d.%m.%Y.") , STR_TO_DATE("2.9.2021.", "%d.%m.%Y.") , "Srednje ozlije??en" , 50174 ),
 ( 1026 , 10458 , "U tijeku" , STR_TO_DATE("13.4.2003.", "%d.%m.%Y.") , STR_TO_DATE("3.3.2020.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 72876 ),
 ( 1027 , 10319 , "U tijeku" , STR_TO_DATE("28.10.2017.", "%d.%m.%Y.") , STR_TO_DATE("14.10.2021.", "%d.%m.%Y.") , "Srednje ozlije??en" , 37601 ),
 ( 1028 , 10038 , "Izlije??en" , STR_TO_DATE("14.10.2015.", "%d.%m.%Y.") , STR_TO_DATE("6.2.2020.", "%d.%m.%Y.") , "Slabo ozljie??en" , 85811 ),
 ( 1029 , 10131 , "Izlije??en" , STR_TO_DATE("15.12.1995.", "%d.%m.%Y.") , STR_TO_DATE("28.10.2021.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 95168 ),
 ( 1030 , 10705 , "Izlije??en" , STR_TO_DATE("2.10.2009.", "%d.%m.%Y.") , STR_TO_DATE("26.7.2022.", "%d.%m.%Y.") , "Slabo ozljie??en" , 23062 ),
 ( 1031 , 10670 , "U tijeku" , STR_TO_DATE("23.8.2001.", "%d.%m.%Y.") , STR_TO_DATE("23.1.2022.", "%d.%m.%Y.") , "Slabo ozljie??en" , 65569 ),
 ( 1032 , 10556 , "U tijeku" , STR_TO_DATE("11.9.1995.", "%d.%m.%Y.") , STR_TO_DATE("4.11.2020.", "%d.%m.%Y.") , "Srednje ozlije??en" , 1702 ),
 ( 1033 , 10279 , "U tijeku" , STR_TO_DATE("20.2.1993.", "%d.%m.%Y.") , STR_TO_DATE("20.8.2021.", "%d.%m.%Y.") , "Slabo ozljie??en" , 81207 ),
 ( 1034 , 10125 , "U tijeku" , STR_TO_DATE("23.2.2006.", "%d.%m.%Y.") , STR_TO_DATE("24.3.2021.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 68033 ),
 ( 1035 , 10598 , "Izlije??en" , STR_TO_DATE("18.4.2010.", "%d.%m.%Y.") , STR_TO_DATE("2.3.2021.", "%d.%m.%Y.") , "Slabo ozljie??en" , 47818 ),
 ( 1036 , 10908 , "U tijeku" , STR_TO_DATE("27.11.2000.", "%d.%m.%Y.") , STR_TO_DATE("20.7.2021.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 65641 ),
 ( 1037 , 10726 , "U tijeku" , STR_TO_DATE("15.4.1997.", "%d.%m.%Y.") , STR_TO_DATE("14.5.2020.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 11239 ),
 ( 1038 , 10368 , "U tijeku" , STR_TO_DATE("1.8.2001.", "%d.%m.%Y.") , STR_TO_DATE("4.9.2022.", "%d.%m.%Y.") , "Slabo ozljie??en" , 86867 ),
 ( 1039 , 10715 , "Izlije??en" , STR_TO_DATE("27.3.1999.", "%d.%m.%Y.") , STR_TO_DATE("5.9.2021.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 63292 ),
 ( 1040 , 10495 , "U tijeku" , STR_TO_DATE("23.2.1998.", "%d.%m.%Y.") , STR_TO_DATE("23.8.2021.", "%d.%m.%Y.") , "Srednje ozlije??en" , 17257 ),
 ( 1041 , 10297 , "Izlije??en" , STR_TO_DATE("13.3.2017.", "%d.%m.%Y.") , STR_TO_DATE("28.4.2022.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 26778 ),
 ( 1042 , 10049 , "Izlije??en" , STR_TO_DATE("18.5.1995.", "%d.%m.%Y.") , STR_TO_DATE("15.7.2021.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 22612 ),
 ( 1043 , 10444 , "U tijeku" , STR_TO_DATE("12.8.2014.", "%d.%m.%Y.") , STR_TO_DATE("25.7.2020.", "%d.%m.%Y.") , "Slabo ozljie??en" , 95383 ),
 ( 1044 , 10064 , "U tijeku" , STR_TO_DATE("12.12.2001.", "%d.%m.%Y.") , STR_TO_DATE("16.3.2021.", "%d.%m.%Y.") , "Srednje ozlije??en" , 28069 ),
 ( 1045 , 10478 , "Izlije??en" , STR_TO_DATE("4.8.1999.", "%d.%m.%Y.") , STR_TO_DATE("24.8.2022.", "%d.%m.%Y.") , "Slabo ozljie??en" , 89446 ),
 ( 1046 , 10570 , "U tijeku" , STR_TO_DATE("9.1.2013.", "%d.%m.%Y.") , STR_TO_DATE("8.11.2020.", "%d.%m.%Y.") , "Srednje ozlije??en" , 40012 ),
 ( 1047 , 10580 , "Izlije??en" , STR_TO_DATE("12.6.2010.", "%d.%m.%Y.") , STR_TO_DATE("22.5.2022.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 79188 ),
 ( 1048 , 10565 , "Izlije??en" , STR_TO_DATE("21.6.2005.", "%d.%m.%Y.") , STR_TO_DATE("22.11.2021.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 99502 ),
 ( 1049 , 10765 , "Izlije??en" , STR_TO_DATE("24.6.1990.", "%d.%m.%Y.") , STR_TO_DATE("26.8.2022.", "%d.%m.%Y.") , "Slabo ozljie??en" , 76841 ),
 ( 1050 , 10520 , "U tijeku" , STR_TO_DATE("6.9.1996.", "%d.%m.%Y.") , STR_TO_DATE("3.9.2020.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 63516 ),
 ( 1051 , 10710 , "U tijeku" , STR_TO_DATE("16.5.2020.", "%d.%m.%Y.") , STR_TO_DATE("11.12.2021.", "%d.%m.%Y.") , "Srednje ozlije??en" , 62502 ),
 ( 1052 , 10774 , "Izlije??en" , STR_TO_DATE("4.9.2012.", "%d.%m.%Y.") , STR_TO_DATE("18.9.2022.", "%d.%m.%Y.") , "Srednje ozlije??en" , 76037 ),
 ( 1053 , 10253 , "Izlije??en" , STR_TO_DATE("28.3.1996.", "%d.%m.%Y.") , STR_TO_DATE("27.4.2020.", "%d.%m.%Y.") , "Srednje ozlije??en" , 25300 ),
 ( 1054 , 10135 , "U tijeku" , STR_TO_DATE("1.2.2002.", "%d.%m.%Y.") , STR_TO_DATE("17.10.2021.", "%d.%m.%Y.") , "Slabo ozljie??en" , 3371 ),
 ( 1055 , 10012 , "U tijeku" , STR_TO_DATE("11.7.1991.", "%d.%m.%Y.") , STR_TO_DATE("15.2.2021.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 12259 ),
 ( 1056 , 10264 , "Izlije??en" , STR_TO_DATE("26.3.2017.", "%d.%m.%Y.") , STR_TO_DATE("4.12.2022.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 74708 ),
 ( 1057 , 10220 , "U tijeku" , STR_TO_DATE("5.7.2000.", "%d.%m.%Y.") , STR_TO_DATE("1.4.2021.", "%d.%m.%Y.") , "Slabo ozljie??en" , 22970 ),
 ( 1058 , 10601 , "U tijeku" , STR_TO_DATE("1.9.2017.", "%d.%m.%Y.") , STR_TO_DATE("12.9.2020.", "%d.%m.%Y.") , "Srednje ozlije??en" , 95920 ),
 ( 1059 , 10591 , "U tijeku" , STR_TO_DATE("12.12.2015.", "%d.%m.%Y.") , STR_TO_DATE("11.6.2020.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 57331 ),
 ( 1060 , 10956 , "U tijeku" , STR_TO_DATE("4.3.2006.", "%d.%m.%Y.") , STR_TO_DATE("9.12.2021.", "%d.%m.%Y.") , "Srednje ozlije??en" , 4316 ),
 ( 1061 , 10360 , "Izlije??en" , STR_TO_DATE("25.5.2009.", "%d.%m.%Y.") , STR_TO_DATE("14.1.2022.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 69323 ),
 ( 1062 , 10802 , "U tijeku" , STR_TO_DATE("22.11.2012.", "%d.%m.%Y.") , STR_TO_DATE("15.6.2020.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 67088 ),
 ( 1063 , 10945 , "U tijeku" , STR_TO_DATE("6.4.1994.", "%d.%m.%Y.") , STR_TO_DATE("8.8.2022.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 51062 ),
 ( 1064 , 10324 , "U tijeku" , STR_TO_DATE("10.1.2001.", "%d.%m.%Y.") , STR_TO_DATE("5.10.2022.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 84510 ),
 ( 1065 , 10071 , "Izlije??en" , STR_TO_DATE("26.4.2007.", "%d.%m.%Y.") , STR_TO_DATE("26.2.2021.", "%d.%m.%Y.") , "Srednje ozlije??en" , 4680 ),
 ( 1066 , 10400 , "U tijeku" , STR_TO_DATE("27.3.1993.", "%d.%m.%Y.") , STR_TO_DATE("2.12.2020.", "%d.%m.%Y.") , "Slabo ozljie??en" , 49730 ),
 ( 1067 , 10670 , "U tijeku" , STR_TO_DATE("22.1.2005.", "%d.%m.%Y.") , STR_TO_DATE("22.7.2021.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 31761 ),
 ( 1068 , 10810 , "U tijeku" , STR_TO_DATE("26.8.1993.", "%d.%m.%Y.") , STR_TO_DATE("17.4.2021.", "%d.%m.%Y.") , "Srednje ozlije??en" , 46534 ),
 ( 1069 , 10675 , "Izlije??en" , STR_TO_DATE("2.10.1999.", "%d.%m.%Y.") , STR_TO_DATE("25.4.2021.", "%d.%m.%Y.") , "Srednje ozlije??en" , 79375 ),
 ( 1070 , 10551 , "Izlije??en" , STR_TO_DATE("17.12.1992.", "%d.%m.%Y.") , STR_TO_DATE("18.12.2021.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 42729 ),
 ( 1071 , 10349 , "U tijeku" , STR_TO_DATE("18.10.1999.", "%d.%m.%Y.") , STR_TO_DATE("10.3.2020.", "%d.%m.%Y.") , "Srednje ozlije??en" , 44447 ),
 ( 1072 , 10793 , "U tijeku" , STR_TO_DATE("6.8.2013.", "%d.%m.%Y.") , STR_TO_DATE("26.1.2020.", "%d.%m.%Y.") , "Srednje ozlije??en" , 11195 ),
 ( 1073 , 10771 , "U tijeku" , STR_TO_DATE("14.3.1999.", "%d.%m.%Y.") , STR_TO_DATE("27.6.2020.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 80277 ),
 ( 1074 , 10054 , "U tijeku" , STR_TO_DATE("12.10.1997.", "%d.%m.%Y.") , STR_TO_DATE("13.8.2021.", "%d.%m.%Y.") , "Slabo ozljie??en" , 25089 ),
 ( 1075 , 10069 , "Izlije??en" , STR_TO_DATE("8.7.2004.", "%d.%m.%Y.") , STR_TO_DATE("22.9.2020.", "%d.%m.%Y.") , "Srednje ozlije??en" , 22210 ),
 ( 1076 , 10608 , "Izlije??en" , STR_TO_DATE("18.4.2011.", "%d.%m.%Y.") , STR_TO_DATE("9.10.2021.", "%d.%m.%Y.") , "Srednje ozlije??en" , 94000 ),
 ( 1077 , 10303 , "U tijeku" , STR_TO_DATE("27.8.1996.", "%d.%m.%Y.") , STR_TO_DATE("17.6.2022.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 19832 ),
 ( 1078 , 10743 , "U tijeku" , STR_TO_DATE("24.12.1993.", "%d.%m.%Y.") , STR_TO_DATE("17.1.2020.", "%d.%m.%Y.") , "Srednje ozlije??en" , 85614 ),
 ( 1079 , 10318 , "U tijeku" , STR_TO_DATE("23.10.1995.", "%d.%m.%Y.") , STR_TO_DATE("27.11.2020.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 44960 ),
 ( 1080 , 10063 , "Izlije??en" , STR_TO_DATE("19.12.1993.", "%d.%m.%Y.") , STR_TO_DATE("1.2.2022.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 72726 ),
 ( 1081 , 10895 , "Izlije??en" , STR_TO_DATE("25.8.1998.", "%d.%m.%Y.") , STR_TO_DATE("14.9.2021.", "%d.%m.%Y.") , "Slabo ozljie??en" , 78550 ),
 ( 1082 , 10479 , "Izlije??en" , STR_TO_DATE("19.3.2007.", "%d.%m.%Y.") , STR_TO_DATE("6.4.2020.", "%d.%m.%Y.") , "Srednje ozlije??en" , 8210 ),
 ( 1083 , 10152 , "U tijeku" , STR_TO_DATE("6.11.1992.", "%d.%m.%Y.") , STR_TO_DATE("11.10.2022.", "%d.%m.%Y.") , "Slabo ozljie??en" , 87272 ),
 ( 1084 , 10599 , "U tijeku" , STR_TO_DATE("7.2.1996.", "%d.%m.%Y.") , STR_TO_DATE("15.5.2020.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 93596 ),
 ( 1085 , 10949 , "U tijeku" , STR_TO_DATE("12.3.2003.", "%d.%m.%Y.") , STR_TO_DATE("28.7.2021.", "%d.%m.%Y.") , "Srednje ozlije??en" , 61973 ),
 ( 1086 , 10733 , "U tijeku" , STR_TO_DATE("23.10.2000.", "%d.%m.%Y.") , STR_TO_DATE("24.9.2021.", "%d.%m.%Y.") , "Slabo ozljie??en" , 75353 ),
 ( 1087 , 10476 , "U tijeku" , STR_TO_DATE("8.5.2007.", "%d.%m.%Y.") , STR_TO_DATE("8.11.2020.", "%d.%m.%Y.") , "Srednje ozlije??en" , 42388 ),
 ( 1088 , 10644 , "Izlije??en" , STR_TO_DATE("25.7.2002.", "%d.%m.%Y.") , STR_TO_DATE("14.7.2021.", "%d.%m.%Y.") , "Slabo ozljie??en" , 59091 ),
 ( 1089 , 10804 , "U tijeku" , STR_TO_DATE("12.6.1993.", "%d.%m.%Y.") , STR_TO_DATE("5.8.2020.", "%d.%m.%Y.") , "Srednje ozlije??en" , 93125 ),
 ( 1090 , 10774 , "U tijeku" , STR_TO_DATE("3.6.1998.", "%d.%m.%Y.") , STR_TO_DATE("23.9.2020.", "%d.%m.%Y.") , "Srednje ozlije??en" , 37634 ),
 ( 1091 , 10931 , "Izlije??en" , STR_TO_DATE("1.10.2020.", "%d.%m.%Y.") , STR_TO_DATE("3.7.2022.", "%d.%m.%Y.") , "Slabo ozljie??en" , 48252 ),
 ( 1092 , 10800 , "Izlije??en" , STR_TO_DATE("3.9.2016.", "%d.%m.%Y.") , STR_TO_DATE("5.5.2022.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 61445 ),
 ( 1093 , 10331 , "Izlije??en" , STR_TO_DATE("1.10.2006.", "%d.%m.%Y.") , STR_TO_DATE("16.2.2020.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 39044 ),
 ( 1094 , 10732 , "Izlije??en" , STR_TO_DATE("10.1.2005.", "%d.%m.%Y.") , STR_TO_DATE("17.8.2021.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 6441 ),
 ( 1095 , 10248 , "U tijeku" , STR_TO_DATE("20.7.2002.", "%d.%m.%Y.") , STR_TO_DATE("13.9.2022.", "%d.%m.%Y.") , "Slabo ozljie??en" , 38758 ),
 ( 1096 , 10882 , "Izlije??en" , STR_TO_DATE("10.9.1993.", "%d.%m.%Y.") , STR_TO_DATE("3.8.2022.", "%d.%m.%Y.") , "Srednje ozlije??en" , 27482 ),
 ( 1097 , 10920 , "Izlije??en" , STR_TO_DATE("24.10.2010.", "%d.%m.%Y.") , STR_TO_DATE("17.6.2021.", "%d.%m.%Y.") , "Srednje ozlije??en" , 27244 ),
 ( 1098 , 10982 , "U tijeku" , STR_TO_DATE("11.3.2004.", "%d.%m.%Y.") , STR_TO_DATE("28.12.2022.", "%d.%m.%Y.") , "Ozbiljno ozlije??en" , 50406 ),
 ( 1099 , 10677 , "U tijeku" , STR_TO_DATE("12.5.2009.", "%d.%m.%Y.") , STR_TO_DATE("19.5.2020.", "%d.%m.%Y.") , "Srednje ozlije??en" , 11246 );







-- UPITI:

-- Prika??i id, ime i prezime 10 osoba koje su imale najve??i performans na treningu, a preduvjet za njihovo pojavljivanje na listi
-- je da su bile na barem jednoj misiji koja u svom intervalu odr??avanja ima najmanje jedan dan u 12. mjesecu.


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




-- Prika??i id, ime, prezime i cin osobe koja je bila odgovorna za vozilo vrste "Helikopteri"
-- koje je bilo na najvi??e popravaka.


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
	INNER JOIN osoblje_na_turi AS ot
		ON ot.id = vt.id_odgovorni
	INNER JOIN osoblje AS o
		ON o.id = ot.id_osoblje
	WHERE v.vrsta = "Helikopteri"
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



 -- Prika??i ukupni proracun sektora koji ima drugi najveci broj osoblja koji nisu bili na lijecenju niti jedanput te koji su sudjelovali
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




 -- Prika??i nazive misija i njene lokacije, ali samo za misije u kojima je sudjelovalo osoblje starije
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



SELECT SUM(kol_d_opreme) AS br_d_opreme 
	FROM
	(SELECT (ukupna_kolicina - izdana_kolicina) AS kol_d_opreme
	FROM oprema
	INNER JOIN izdana_oprema
	ON oprema.id = izdana_oprema.id_oprema
	UNION
	SELECT ukupna_kolicina AS kol_d_opreme
	FROM oprema
	WHERE id NOT IN (SELECT id_oprema FROM izdana_oprema)) AS l;




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



/*
SELECT ukupna_kolicina AS kol_d_opreme
FROM oprema
WHERE id NOT IN (SELECT id_oprema FROM izdana_oprema)
UNION
SELECT (ukupna_kolicina - izdana_kolicina) AS kol_d_opreme
FROM oprema
INNER JOIN
(SELECT id_oprema, izdana_kolicina
FROM izdana_oprema
INNER JOIN
(SELECT *
FROM
(SELECT osoblje_na_misiji.id AS id_onm, vrijeme_pocetka, vrijeme_kraja
FROM misija
INNER JOIN osoblje_na_misiji
ON misija.id = osoblje_na_misiji.id_misija) AS e
WHERE (DATETIME(vrijeme_pocetka) > DATETIME(datum_poc) AND DATETIME(vrijeme_pocetka) < DATETIME(datum_kr)) 
   OR (DATETIME(vrijeme_kraja) > DATETIME(datum_poc) AND DATETIME(vrijeme_kraja) < DATETIME(datum_kr))) AS l
ON izdana_oprema.id_osoblje_na_misiji = l.id_onm) AS n
ON oprema.id = n.id_oprema
UNION
;
*/

-- PROCEDURE:

-- Ispisati koliki je broj osoblja, vozila, opreme trenuta??no dostupno(3 vrijednosti) u danom intervalu (dva datuma
-- koje korisnik izabere kao ulazne argumente)
/*
DROP FUNCTION IF EXISTS d_osoblje;

DELIMITER //
CREATE FUNCTION d_osoblje(datum_p DATETIME, datum_k DATETIME) RETURNS INTEGER
DETERMINISTIC
BEGIN
    DECLARE br_d_osoblje INTEGER;

    SELECT COUNT(*) INTO br_d_osoblje
	FROM osoblje
	WHERE id NOT IN
	(SELECT id_osoblje
	FROM osoblje_na_turi
	WHERE (datum_p > datum_pocetka AND datum_p < datum_kraja)
    OR (datum_k > datum_pocetka AND datum_k < datum_kraja));

    RETURN br_d_osoblje;
END//
DELIMITER ;

-- Provjera
SELECT d_osoblje(STR_TO_DATE("1.10.1991.  12:37:13", "%d.%m.%Y. %H:%i:%s"), 
STR_TO_DATE("1.10.2013.  12:37:13", "%d.%m.%Y. %H:%i:%s")) AS broj_dostupnog_osoblja
FROM DUAL;


 
DROP FUNCTION IF EXISTS d_vozila;

DELIMITER //
CREATE FUNCTION d_vozila(datum_p DATETIME, datum_k DATETIME) RETURNS INTEGER
DETERMINISTIC
BEGIN
    DECLARE br_d_vozila INTEGER;
    DECLARE nisu_u_vnt INTEGER;

	SELECT SUM(ukupna_kolicina) INTO nisu_u_vnt
    FROM vozila
    WHERE id NOT IN (SELECT id_vozilo FROM vozilo_na_turi);
    

    SELECT COUNT(*) INTO br_d_vozila
	FROM vozila
	WHERE id NOT IN
	(SELECT id_vozilo
	FROM vozilo_na_turi
    INNER JOIN tura
    ON tura.id = vozilo_na_turi.id_tura
	WHERE (datum_p > vrijeme_pocetka AND datum_p < vrijeme_kraja)
    OR (datum_k > vrijeme_pocetka AND datum_k < vrijeme_kraja));

    RETURN br_d_vozila;
END//
DELIMITER ;

-- Provjera
SELECT d_vozila(STR_TO_DATE("1.10.1991.  12:37:13", "%d.%m.%Y. %H:%i:%s"), 
STR_TO_DATE("1.10.2013.  12:37:13", "%d.%m.%Y. %H:%i:%s")) AS broj_dostupnih_vozila
FROM DUAL;



SELECT *
FROM popravak
WHERE 
*/

/*
DROP PROCEDURE IF EXISTS br_ovo;

DELIMITER //
CREATE PROCEDURE br_ovo(IN datum_poc DATETIME, IN datum_kr DATETIME, OUT d_osoblje INTEGER, OUT d_vozila INTEGER, OUT d_oprema INTEGER)
BEGIN

	SELECT SUM(kol_d_opreme) AS br_d_opreme INTO d_oprema
	FROM
	(SELECT (ukupna_kolicina - izdana_kolicina) AS kol_d_opreme
	FROM oprema
	INNER JOIN izdana_oprema
	ON oprema.id = izdana_oprema.id_oprema
	UNION
	SELECT ukupna_kolicina AS kol_d_opreme
	FROM oprema
	WHERE id NOT IN (SELECT id_oprema FROM izdana_oprema)) AS l;
    
	SET rezultat = a + b;

END //
DELIMITER ;

CALL br_ovo(, ,@s_os, @s_vo, @s_op);
SELECT @s_os AS br_dostupnog_osoblja, @s_vo AS br_dostupnih_vozila, @s_op AS br_dostupne_opreme FROM DUAL;

*/



/*
Za dva vremenski intervala (pojedini ??e biti odre??en s dvije datumske vrijednosti) se mora odrediti  pojedina??ni 
ukupni tro??ak za misije, ukupni tro??ak za popravak, ukupni tro??ak za lije??enje te usporedit. 
Ispis treba biti u obliku:
	Vremensko razdoblje od 1.10.1991. do 11.07.1998. ima manji tro??ak kada je rije?? o misijama u usporedbi s razdobljem od 23.04.1997. do 2.12.2001..
    Vremensko razdoblje od 23.04.1997. do 2.12.2001. ima manji tro??ak kada je rije?? o popravcima u usporedbi s razdobljem od 1.10.1991. do 11.07.1998..
    Vremensko razdoblje od 1.10.1991. do  11.07.1998. ima manji tro??ak kada je rije?? lije??enju u usporedbi s razdobljem od 23.04.1997. do 2.12.2001..
*/

/*
DROP PROCEDURE IF EXISTS usporedba;

DELIMITER //
CREATE PROCEDURE usporedba(IN datum_poc DATETIME, IN datum_kr DATETIME, OUT rez_misija VARCHAR(200), OUT rez_popravci VARCHAR(200), OUT rez_lijecenje VARCHAR(200))
BEGIN

	SELECT *
    FROM popravak
    WHERE datum_poc > pocetak_popravka AND datum_poc < kraj_popravka;

END //
DELIMITER ;

*/













/*
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
"Eliza" , "Vukovi??"
select * from login;
*/
