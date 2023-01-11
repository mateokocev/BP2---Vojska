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
    ocjena INTEGER NOT NULL,
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



-- OKIDAČI:
	
 -- DK   
    /*
Datum početka ture ne može biti veći ili jednak od datuma kraja ture.
Idemo ih uspoređivat samo uz uvjet da kraj nije NULL.              
U slučaju da je kraj NULL to znači da je tura još uvijek u tijeku. Riječ je o UPDATE-u.                                                              */

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
Datum početka misije ne može biti veći ili jednak od datuma kraja misije.
Idemo ih uspoređivat samo uz uvjet da kraj nije NULL.              
U slučaju da je kraj NULL to znači da je misija još uvijek u tijeku. Riječ je o UPDATE-u.                                                             */

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
Datum početka sudjelovanja osoblja na turi ne može biti veći ili jednak od datuma kraja sudjelovanja.
Idemo ih uspoređivat samo uz uvjet da kraj nije NULL.              
U slučaju da je kraj NULL to znači da osoba još uvijek sudjeluje u turi. Riječ je o UPDATE-u.                                                              */

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
Datum početka popravka ne može biti veći ili jednak od datuma kraja popravka.
Idemo ih uspoređivat samo uz uvjet da kraj nije NULL.              
U slučaju da je kraj NULL to znači da je popravak još uvijek u tijeku. Riječ je o INSERT-u.                                                            */

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
Datum početka treninga ne može biti veći ili jednak od datuma kraja treninga te trening bi najmanje trebao trajat 20 min.
Riječ o INSERT-u.                                                                                                                */
/*
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
*/


                                                                                                                                    /*
Datum početka lijecenja ne može biti veći ili jednak od datuma kraja liječenja kada je riječ o INSERT-u. 
Idemo ih uspoređivat samo uz uvjet da kraj nije NULL.
U slučaju je datum kraja liječenja NULL to znači da je liječenje još uvijek u tijeku.                                                */

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
Napraviti okidač koji će u slučaju da korisnik unese opremu koja je već unešena zbrojit količinu opreme.
Npr u skladištu već postoji (1330, "RBG-6", "Bacač granata", 124) te korisnik unosi (1370, "RBG-6", "Bacač granata", 6).
To je "nepotrebno" te stoga okidač pridodaje dodatnu količinu onoj već postojećoj tj (1330, "RBG-6", "Bacač granata", 130).         */

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
Prati se da zbroj količine željene izdane opreme ne bude veći od sveukupne moguće količine opreme tijekom INSERT-a.
Prati se da u određenom razdoblju tj. misiji to ne bude prekoračeno. 																			*/

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
Prati se da zbroj izdane količine ne bude veći od sveukupne moguće količine opreme tijekom UPDATE-a
Prati se da u određenom razdoblju tj. misiji to ne bude prekoračeno.																*/

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


-- MK

-- Ovaj trigger provjerava ako vojnik nije na aktivnoj turi, te ako nije, postavlja njegov status na "Neaktivan"
DELIMITER //
CREATE TRIGGER updtstatus_post_tura AFTER UPDATE ON tura
FOR EACH ROW
BEGIN
	IF tura.datum_kraja != NULL THEN
		UPDATE osoblje
			SET status_osoblja = "Neaktivan" WHERE id IN (SELECT id_osoblje FROM osoblje_na_turi WHERE id_tura = tura.id AND datum_kraja IS NULL);
	END IF;
END//
DELIMITER ;


-- Ovaj trigger postavlja datum_kraja osoblja na turi na isti datum kraja ko i tura koja je završila samo ako to osoblje na turi ima datum_kraja NULL tj. nije se povuklo prije kraja ture i ostalo je tijekom cijele ture
DELIMITER //
CREATE TRIGGER updtkraj_post_tura AFTER UPDATE ON tura
FOR EACH ROW
BEGIN
	IF tura.datum_kraja != NULL THEN
		UPDATE osoblje_na_turi 
			SET datum_kraja = tura.datum_kraja 
				WHERE id_tura = tura.id AND datum_kraja IS NULL;
	END IF;
END//
DELIMITER ;

/*
-- kada vojnik ide na misiju poslužuje se tom osoblju na misiji osnovnu opremu, imamo funkciju koja provjerava dostupne id-eve te ih vraca u trigger kako bi mogli izvesti uspjesan insert. Također ima 
DELIMITER //
CREATE FUNCTION dostupni_id_izdana_oprema() RETURNS INTEGER
DETERMINISTIC
BEGIN
    DECLARE id_dostupnost INTEGER DEFAULT 5000;
    DECLARE dostupan_id INTEGER;
    
    WHILE dostupan_id != NULL DO
        SET id_dostupnost = id_dostupnost + 1;
        
        SELECT id INTO dostupan_id
            FROM izdana_oprema
            WHERE id = id_dostupnost;
    END WHILE;
    
    RETURN id_dostupnost;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER minoprema_pre_misija AFTER INSERT ON osoblje_na_misiji
FOR EACH ROW
BEGIN
    DECLARE rand_samokres INTEGER;
	SELECT FLOOR(1001 + RAND() * (1003-1001)) INTO rand_samokres;
    
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
*/

-- promjena odgovornog za vozilo u slučaju ranog povlačenja iz ture. Uzme rezultat za novog odgovornog i spremi ga u @zamjena te ako nije null updatea id_odgovorni.
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

/*
-- Provjerava je li osoblje koje se salje na misiju uopce dostupno s time da broji koliko ima aktivnih misija tj. koliko misija kojima je datum kraja na NULL
DELIMITER //
CREATE TRIGGER dostupnost_osoblja BEFORE INSERT ON osoblje_na_misiji
FOR EACH ROW
BEGIN
	
	SELECT COUNT(id) INTO @dostupan
        FROM osoblje_na_misiji AS onm
        INNER JOIN osoblje AS o ON onm.id_osoblje = o.id
        INNER JOIN osoblje_na_turi AS ont ON o.id = ont.id_osoblje
			WHERE onm.id_osoblje = NEW.id_osoblje AND ont.id_osoblje = NEW.id_osoblje AND onm.datum_kraja = NULL;
	IF @dostupan > 0 THEN
		SIGNAL SQLSTATE '40000'
			SET MESSAGE_TEXT = 'Osoblje nije dostupno za novu misiju';
	END IF;
END//
DELIMITER ;
*/



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
-- drop trigger kriptiranje;



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
 ( 10001 , 3 , "Jagoda" , "Lučić" , "Pozornik" , STR_TO_DATE("5.3.1968.", "%d.%m.%Y.") , STR_TO_DATE("21.3.2002.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 4 ),
 ( 10002 , 3 , "Arabela" , "Herceg" , "Skupnik" , STR_TO_DATE("1.10.1967.", "%d.%m.%Y.") , STR_TO_DATE("20.10.2013.", "%d.%m.%Y.") , "Mrtav" , "A-" , 3 ),
 ( 10003 , 1 , "Vilim" , "Grgurić" , "Skupnik" , STR_TO_DATE("30.10.1956.", "%d.%m.%Y.") , STR_TO_DATE("3.2.2016.", "%d.%m.%Y.") , "Mrtav" , "A+" , 2 ),
 ( 10004 , 2 , "Julija" , "Kovačić" , "Narednik" , STR_TO_DATE("5.5.1970.", "%d.%m.%Y.") , STR_TO_DATE("8.9.1993.", "%d.%m.%Y.") , "Mrtav" , "0-" , 1 ),
 ( 10005 , 1 , "Anđela" , "Klarić" , "Narednik" , STR_TO_DATE("28.11.1961.", "%d.%m.%Y.") , STR_TO_DATE("18.5.1995.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 3 ),
 ( 10006 , 1 , "Donata" , "Vukelić" , "Razvodnik" , STR_TO_DATE("8.10.1956.", "%d.%m.%Y.") , STR_TO_DATE("18.1.2005.", "%d.%m.%Y.") , "Mrtav" , "A-" , 2 ),
 ( 10007 , 4 , "Matija" , "Perić" , "Poručnik" , STR_TO_DATE("24.12.1952.", "%d.%m.%Y.") , STR_TO_DATE("4.11.1995.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 4 ),
 ( 10008 , 3 , "Sabina" , "Stanić" , "Pukovnik" , STR_TO_DATE("28.3.1962.", "%d.%m.%Y.") , STR_TO_DATE("13.1.2014.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 4 ),
 ( 10009 , 4 , "Alaia" , "Božić" , "Skupnik" , STR_TO_DATE("20.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("13.5.1992.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 2 ),
 ( 10010 , 2 , "Damjan" , "Blažević" , "Pozornik" , STR_TO_DATE("24.7.1956.", "%d.%m.%Y.") , STR_TO_DATE("28.7.2005.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 2 ),
 ( 10011 , 2 , "Malija" , "Šimunić" , "Brigadir" , STR_TO_DATE("11.5.1955.", "%d.%m.%Y.") , STR_TO_DATE("26.3.2012.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 3 ),
 ( 10012 , 1 , "Anamarija" , "Mandić" , "Pozornik" , STR_TO_DATE("24.3.1957.", "%d.%m.%Y.") , STR_TO_DATE("16.10.2008.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 1 ),
 ( 10013 , 2 , "Janko" , "Perković" , "Skupnik" , STR_TO_DATE("13.2.1967.", "%d.%m.%Y.") , STR_TO_DATE("4.3.1996.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 4 ),
 ( 10014 , 2 , "Korina" , "Babić" , "Pozornik" , STR_TO_DATE("17.10.1969.", "%d.%m.%Y.") , STR_TO_DATE("14.12.1999.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 5 ),
 ( 10015 , 4 , "Toni" , "Vukelić" , "Brigadir" , STR_TO_DATE("5.9.1967.", "%d.%m.%Y.") , STR_TO_DATE("3.7.2004.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 4 ),
 ( 10016 , 3 , "Nora" , "Marić" , "Brigadir" , STR_TO_DATE("4.5.1956.", "%d.%m.%Y.") , STR_TO_DATE("18.8.1998.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 5 ),
 ( 10017 , 3 , "Jana" , "Šimić" , "Pozornik" , STR_TO_DATE("7.2.1952.", "%d.%m.%Y.") , STR_TO_DATE("20.5.2004.", "%d.%m.%Y.") , "Mrtav" , "0+" , 4 ),
 ( 10018 , 4 , "Elio" , "Horvat" , "Narednik" , STR_TO_DATE("29.4.1955.", "%d.%m.%Y.") , STR_TO_DATE("25.8.1999.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 4 ),
 ( 10019 , 3 , "Melanija" , "Horvat" , "Skupnik" , STR_TO_DATE("25.7.1967.", "%d.%m.%Y.") , STR_TO_DATE("27.6.1994.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 3 ),
 ( 10020 , 1 , "Isla" , "Pavlić" , "Poručnik" , STR_TO_DATE("1.10.1966.", "%d.%m.%Y.") , STR_TO_DATE("19.5.2003.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 3 ),
 ( 10021 , 4 , "Emberli" , "Filipović" , "Pukovnik" , STR_TO_DATE("16.9.1970.", "%d.%m.%Y.") , STR_TO_DATE("8.3.2017.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 4 ),
 ( 10022 , 2 , "Desa" , "Jovanović" , "Satnik" , STR_TO_DATE("20.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("26.2.1997.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 2 ),
 ( 10023 , 2 , "Kalen" , "Katić" , "Skupnik" , STR_TO_DATE("21.1.1963.", "%d.%m.%Y.") , STR_TO_DATE("22.3.2014.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 3 ),
 ( 10024 , 4 , "Alijah" , "Šimunić" , "Pozornik" , STR_TO_DATE("6.10.1954.", "%d.%m.%Y.") , STR_TO_DATE("28.6.1996.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 4 ),
 ( 10025 , 4 , "Iva" , "Lončar" , "Poručnik" , STR_TO_DATE("30.4.1952.", "%d.%m.%Y.") , STR_TO_DATE("8.9.1993.", "%d.%m.%Y.") , "Aktivan" , "B+" , 4 ),
 ( 10026 , 1 , "Siri" , "Kovačić" , "Bojnik" , STR_TO_DATE("24.6.1962.", "%d.%m.%Y.") , STR_TO_DATE("23.2.2013.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 3 ),
 ( 10027 , 3 , "Ilko" , "Novak" , "Razvodnik" , STR_TO_DATE("12.5.1968.", "%d.%m.%Y.") , STR_TO_DATE("25.11.2007.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 3 ),
 ( 10028 , 1 , "Martina" , "Kovačić" , "Pozornik" , STR_TO_DATE("9.10.1967.", "%d.%m.%Y.") , STR_TO_DATE("7.5.2006.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 4 ),
 ( 10029 , 1 , "Aldo" , "Janković" , "Satnik" , STR_TO_DATE("14.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("8.3.2017.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 2 ),
 ( 10030 , 3 , "Emelina" , "Šimunić" , "Razvodnik" , STR_TO_DATE("29.5.1958.", "%d.%m.%Y.") , STR_TO_DATE("13.5.2012.", "%d.%m.%Y.") , "Aktivan" , "0+" , 3 ),
 ( 10031 , 1 , "Esmeralda" , "Ružić" , "Pukovnik" , STR_TO_DATE("1.9.1953.", "%d.%m.%Y.") , STR_TO_DATE("26.2.2015.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 4 ),
 ( 10032 , 3 , "Ela" , "Kovačić" , "Satnik" , STR_TO_DATE("8.7.1970.", "%d.%m.%Y.") , STR_TO_DATE("20.7.1995.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 3 ),
 ( 10033 , 1 , "Karina" , "Šimić" , "Pozornik" , STR_TO_DATE("7.7.1951.", "%d.%m.%Y.") , STR_TO_DATE("21.2.2013.", "%d.%m.%Y.") , "Umirovljen" , "AB-" , 2 ),
 ( 10034 , 2 , "Lara" , "Grgić" , "Razvodnik" , STR_TO_DATE("28.4.1968.", "%d.%m.%Y.") , STR_TO_DATE("25.7.2013.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 1 ),
 ( 10035 , 2 , "Anatea" , "Lončarić" , "Skupnik" , STR_TO_DATE("8.2.1954.", "%d.%m.%Y.") , STR_TO_DATE("28.1.2005.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 4 ),
 ( 10036 , 2 , "Nova" , "Burić" , "Narednik" , STR_TO_DATE("31.7.1968.", "%d.%m.%Y.") , STR_TO_DATE("24.8.2007.", "%d.%m.%Y.") , "Mrtav" , "0+" , 1 ),
 ( 10037 , 1 , "Marjan" , "Marjanović" , "Narednik" , STR_TO_DATE("30.10.1968.", "%d.%m.%Y.") , STR_TO_DATE("31.1.1995.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 1 ),
 ( 10038 , 2 , "Mirna" , "Đurđević" , "Pozornik" , STR_TO_DATE("27.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("3.12.2012.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 2 ),
 ( 10039 , 2 , "Slavica" , "Cvitković" , "Pozornik" , STR_TO_DATE("11.5.1969.", "%d.%m.%Y.") , STR_TO_DATE("5.11.1998.", "%d.%m.%Y.") , "Mrtav" , "0+" , 4 ),
 ( 10040 , 2 , "Dorotej" , "Lukić" , "Pukovnik" , STR_TO_DATE("6.5.1956.", "%d.%m.%Y.") , STR_TO_DATE("21.9.2006.", "%d.%m.%Y.") , "Mrtav" , "A-" , 2 ),
 ( 10041 , 3 , "Dragutin" , "Novaković" , "Razvodnik" , STR_TO_DATE("17.5.1960.", "%d.%m.%Y.") , STR_TO_DATE("9.5.2000.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 5 ),
 ( 10042 , 2 , "Denis" , "Varga" , "Brigadir" , STR_TO_DATE("7.5.1967.", "%d.%m.%Y.") , STR_TO_DATE("14.10.2002.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 1 ),
 ( 10043 , 1 , "Milana" , "Horvat" , "Poručnik" , STR_TO_DATE("11.6.1955.", "%d.%m.%Y.") , STR_TO_DATE("30.10.2017.", "%d.%m.%Y.") , "Aktivan" , "A-" , 4 ),
 ( 10044 , 3 , "Gvena" , "Varga" , "Pukovnik" , STR_TO_DATE("25.9.1963.", "%d.%m.%Y.") , STR_TO_DATE("2.8.2011.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 5 ),
 ( 10045 , 1 , "Penelopa" , "Grgurić" , "Bojnik" , STR_TO_DATE("19.2.1968.", "%d.%m.%Y.") , STR_TO_DATE("7.11.1998.", "%d.%m.%Y.") , "Mrtav" , "A-" , 4 ),
 ( 10046 , 4 , "Zarija" , "Marjanović" , "Narednik" , STR_TO_DATE("26.5.1955.", "%d.%m.%Y.") , STR_TO_DATE("7.3.2015.", "%d.%m.%Y.") , "Mrtav" , "0+" , 5 ),
 ( 10047 , 3 , "Željkica" , "Matijević" , "Pozornik" , STR_TO_DATE("4.1.1962.", "%d.%m.%Y.") , STR_TO_DATE("31.7.2006.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 5 ),
 ( 10048 , 3 , "Julija" , "Ivanović" , "Poručnik" , STR_TO_DATE("7.10.1965.", "%d.%m.%Y.") , STR_TO_DATE("27.1.2007.", "%d.%m.%Y.") , "Mrtav" , "0-" , 2 ),
 ( 10049 , 1 , "Dijana" , "Vuković" , "Poručnik" , STR_TO_DATE("11.12.1969.", "%d.%m.%Y.") , STR_TO_DATE("8.12.2015.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 5 ),
 ( 10050 , 4 , "Lili" , "Jozić" , "Pukovnik" , STR_TO_DATE("2.5.1955.", "%d.%m.%Y.") , STR_TO_DATE("22.1.2014.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 1 ),
 ( 10051 , 3 , "Jaro" , "Lučić" , "Poručnik" , STR_TO_DATE("19.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("9.4.2003.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 2 ),
 ( 10052 , 3 , "Aleks" , "Lučić" , "Brigadir" , STR_TO_DATE("23.2.1967.", "%d.%m.%Y.") , STR_TO_DATE("26.12.2006.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 4 ),
 ( 10053 , 2 , "Elie" , "Galić" , "Pukovnik" , STR_TO_DATE("2.3.1966.", "%d.%m.%Y.") , STR_TO_DATE("24.6.2018.", "%d.%m.%Y.") , "Mrtav" , "B-" , 2 ),
 ( 10054 , 4 , "Mihaela" , "Novak" , "Bojnik" , STR_TO_DATE("1.7.1969.", "%d.%m.%Y.") , STR_TO_DATE("20.8.1994.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 4 ),
 ( 10055 , 1 , "Matea" , "Sever" , "Poručnik" , STR_TO_DATE("7.9.1958.", "%d.%m.%Y.") , STR_TO_DATE("16.1.2016.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 4 ),
 ( 10056 , 4 , "Antun" , "Barišić" , "Razvodnik" , STR_TO_DATE("17.10.1951.", "%d.%m.%Y.") , STR_TO_DATE("23.4.2018.", "%d.%m.%Y.") , "Aktivan" , "A+" , 2 ),
 ( 10057 , 4 , "Rhea" , "Živković" , "Narednik" , STR_TO_DATE("22.9.1964.", "%d.%m.%Y.") , STR_TO_DATE("28.2.1996.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 1 ),
 ( 10058 , 2 , "Mario" , "Šimić" , "Bojnik" , STR_TO_DATE("12.3.1951.", "%d.%m.%Y.") , STR_TO_DATE("10.8.1990.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 5 ),
 ( 10059 , 1 , "Jolena" , "Šimunić" , "Brigadir" , STR_TO_DATE("13.12.1961.", "%d.%m.%Y.") , STR_TO_DATE("14.2.2016.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 5 ),
 ( 10060 , 3 , "Dorotea" , "Kovačević" , "Poručnik" , STR_TO_DATE("23.10.1968.", "%d.%m.%Y.") , STR_TO_DATE("30.4.2019.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 1 ),
 ( 10061 , 2 , "Nika" , "Jurišić" , "Skupnik" , STR_TO_DATE("16.6.1960.", "%d.%m.%Y.") , STR_TO_DATE("18.12.2007.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 4 ),
 ( 10062 , 2 , "Slađana" , "Abramović" , "Pukovnik" , STR_TO_DATE("12.6.1970.", "%d.%m.%Y.") , STR_TO_DATE("22.4.1993.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 1 ),
 ( 10063 , 4 , "Ela" , "Grgurić" , "Brigadir" , STR_TO_DATE("28.11.1961.", "%d.%m.%Y.") , STR_TO_DATE("27.1.1994.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 3 ),
 ( 10064 , 4 , "Oto" , "Janković" , "Poručnik" , STR_TO_DATE("21.5.1966.", "%d.%m.%Y.") , STR_TO_DATE("14.10.1994.", "%d.%m.%Y.") , "Aktivan" , "A-" , 1 ),
 ( 10065 , 1 , "Alicija" , "Marjanović" , "Skupnik" , STR_TO_DATE("2.12.1954.", "%d.%m.%Y.") , STR_TO_DATE("14.3.1997.", "%d.%m.%Y.") , "Aktivan" , "0-" , 2 ),
 ( 10066 , 3 , "Nala" , "Tomić" , "Razvodnik" , STR_TO_DATE("26.3.1958.", "%d.%m.%Y.") , STR_TO_DATE("31.5.2001.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 2 ),
 ( 10067 , 3 , "Zoi" , "Ivančić" , "Bojnik" , STR_TO_DATE("30.3.1968.", "%d.%m.%Y.") , STR_TO_DATE("15.10.2018.", "%d.%m.%Y.") , "Aktivan" , "0+" , 5 ),
 ( 10068 , 2 , "Magda" , "Perić" , "Pukovnik" , STR_TO_DATE("10.1.1969.", "%d.%m.%Y.") , STR_TO_DATE("3.12.2017.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 4 ),
 ( 10069 , 4 , "Sendi" , "Popović" , "Skupnik" , STR_TO_DATE("5.9.1951.", "%d.%m.%Y.") , STR_TO_DATE("20.6.2020.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 3 ),
 ( 10070 , 3 , "Manda" , "Vidaković" , "Brigadir" , STR_TO_DATE("11.9.1958.", "%d.%m.%Y.") , STR_TO_DATE("8.10.2008.", "%d.%m.%Y.") , "Mrtav" , "0-" , 5 ),
 ( 10071 , 4 , "Harmina" , "Knežević" , "Satnik" , STR_TO_DATE("29.5.1951.", "%d.%m.%Y.") , STR_TO_DATE("3.3.2005.", "%d.%m.%Y.") , "Aktivan" , "B-" , 3 ),
 ( 10072 , 1 , "Leon" , "Ružić" , "Skupnik" , STR_TO_DATE("8.4.1956.", "%d.%m.%Y.") , STR_TO_DATE("5.5.1991.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 3 ),
 ( 10073 , 4 , "Elana" , "Mandić" , "Poručnik" , STR_TO_DATE("27.1.1950.", "%d.%m.%Y.") , STR_TO_DATE("22.5.2002.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 3 ),
 ( 10074 , 4 , "Sendi" , "Šimunić" , "Poručnik" , STR_TO_DATE("9.1.1950.", "%d.%m.%Y.") , STR_TO_DATE("24.12.2018.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 1 ),
 ( 10075 , 4 , "Lilika" , "Varga" , "Brigadir" , STR_TO_DATE("29.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("5.9.1992.", "%d.%m.%Y.") , "Mrtav" , "0+" , 2 ),
 ( 10076 , 3 , "Mihael" , "Katić" , "Poručnik" , STR_TO_DATE("21.10.1964.", "%d.%m.%Y.") , STR_TO_DATE("30.6.2005.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 3 ),
 ( 10077 , 1 , "Elivija" , "Perić" , "Pukovnik" , STR_TO_DATE("23.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("25.1.2016.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 5 ),
 ( 10078 , 4 , "Goranka" , "Brkić" , "Bojnik" , STR_TO_DATE("26.3.1959.", "%d.%m.%Y.") , STR_TO_DATE("15.4.1999.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 4 ),
 ( 10079 , 1 , "Leonardo" , "Bilić" , "Bojnik" , STR_TO_DATE("21.6.1966.", "%d.%m.%Y.") , STR_TO_DATE("22.12.1990.", "%d.%m.%Y.") , "Mrtav" , "B+" , 4 ),
 ( 10080 , 4 , "Alora" , "Marušić" , "Satnik" , STR_TO_DATE("23.4.1960.", "%d.%m.%Y.") , STR_TO_DATE("12.3.2010.", "%d.%m.%Y.") , "Mrtav" , "B+" , 1 ),
 ( 10081 , 3 , "Sandi" , "Jurić" , "Pukovnik" , STR_TO_DATE("23.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("30.11.2016.", "%d.%m.%Y.") , "Mrtav" , "A+" , 4 ),
 ( 10082 , 1 , "Eta" , "Matić" , "Razvodnik" , STR_TO_DATE("28.11.1950.", "%d.%m.%Y.") , STR_TO_DATE("13.12.2002.", "%d.%m.%Y.") , "Aktivan" , "0+" , 4 ),
 ( 10083 , 1 , "Šime" , "Klarić" , "Brigadir" , STR_TO_DATE("25.11.1968.", "%d.%m.%Y.") , STR_TO_DATE("21.7.2010.", "%d.%m.%Y.") , "Aktivan" , "A-" , 5 ),
 ( 10084 , 3 , "Azalea" , "Grgurić" , "Brigadir" , STR_TO_DATE("20.12.1950.", "%d.%m.%Y.") , STR_TO_DATE("8.5.2003.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 1 ),
 ( 10085 , 2 , "Amaja" , "Matković" , "Poručnik" , STR_TO_DATE("18.10.1970.", "%d.%m.%Y.") , STR_TO_DATE("6.7.2000.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 1 ),
 ( 10086 , 4 , "Lola" , "Filipović" , "Skupnik" , STR_TO_DATE("11.4.1950.", "%d.%m.%Y.") , STR_TO_DATE("25.2.2006.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 2 ),
 ( 10087 , 3 , "Sunčana" , "Novaković" , "Satnik" , STR_TO_DATE("29.4.1956.", "%d.%m.%Y.") , STR_TO_DATE("22.1.2015.", "%d.%m.%Y.") , "Mrtav" , "A-" , 5 ),
 ( 10088 , 2 , "Kai" , "Lukić" , "Pukovnik" , STR_TO_DATE("27.1.1958.", "%d.%m.%Y.") , STR_TO_DATE("1.6.1996.", "%d.%m.%Y.") , "Mrtav" , "B-" , 4 ),
 ( 10089 , 2 , "Severina" , "Kralj" , "Brigadir" , STR_TO_DATE("2.5.1960.", "%d.%m.%Y.") , STR_TO_DATE("4.1.2017.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 5 ),
 ( 10090 , 2 , "Tihana" , "Vrdoljak" , "Pukovnik" , STR_TO_DATE("8.5.1957.", "%d.%m.%Y.") , STR_TO_DATE("12.6.2000.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 1 ),
 ( 10091 , 1 , "Julijana" , "Lukić" , "Bojnik" , STR_TO_DATE("11.5.1967.", "%d.%m.%Y.") , STR_TO_DATE("21.7.1991.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 4 ),
 ( 10092 , 3 , "Cvijeta" , "Ivanković" , "Pukovnik" , STR_TO_DATE("11.5.1969.", "%d.%m.%Y.") , STR_TO_DATE("22.3.2013.", "%d.%m.%Y.") , "Mrtav" , "0-" , 3 ),
 ( 10093 , 3 , "Viena" , "Matijević" , "Skupnik" , STR_TO_DATE("23.6.1960.", "%d.%m.%Y.") , STR_TO_DATE("13.9.1994.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 2 ),
 ( 10094 , 3 , "Zoi" , "Matić" , "Razvodnik" , STR_TO_DATE("4.3.1954.", "%d.%m.%Y.") , STR_TO_DATE("11.5.2018.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 2 ),
 ( 10095 , 2 , "Teresa" , "Butković" , "Brigadir" , STR_TO_DATE("24.9.1964.", "%d.%m.%Y.") , STR_TO_DATE("16.6.1990.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 3 ),
 ( 10096 , 2 , "Jadranko" , "Perković" , "Pozornik" , STR_TO_DATE("21.2.1951.", "%d.%m.%Y.") , STR_TO_DATE("16.11.2020.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 2 ),
 ( 10097 , 2 , "Slaven" , "Dujmović" , "Razvodnik" , STR_TO_DATE("21.12.1970.", "%d.%m.%Y.") , STR_TO_DATE("30.11.2002.", "%d.%m.%Y.") , "Aktivan" , "B+" , 5 ),
 ( 10098 , 3 , "Alana" , "Jovanović" , "Skupnik" , STR_TO_DATE("14.2.1966.", "%d.%m.%Y.") , STR_TO_DATE("17.5.2010.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 4 ),
 ( 10099 , 2 , "Antun" , "Bilić" , "Bojnik" , STR_TO_DATE("8.4.1969.", "%d.%m.%Y.") , STR_TO_DATE("4.9.2018.", "%d.%m.%Y.") , "Mrtav" , "B+" , 3 ),
 ( 10100 , 4 , "Barbara" , "Jelić" , "Pozornik" , STR_TO_DATE("5.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("17.12.2009.", "%d.%m.%Y.") , "Aktivan" , "A+" , 3 ),
 ( 10101 , 3 , "Liv" , "Perković" , "Pukovnik" , STR_TO_DATE("27.11.1951.", "%d.%m.%Y.") , STR_TO_DATE("4.10.1991.", "%d.%m.%Y.") , "Aktivan" , "0+" , 1 ),
 ( 10102 , 2 , "Zoe" , "Pavlić" , "Narednik" , STR_TO_DATE("8.9.1969.", "%d.%m.%Y.") , STR_TO_DATE("14.4.2018.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 2 ),
 ( 10103 , 4 , "Zvjezdana" , "Jelić" , "Bojnik" , STR_TO_DATE("14.6.1966.", "%d.%m.%Y.") , STR_TO_DATE("11.4.2013.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 2 ),
 ( 10104 , 3 , "Zarija" , "Mandić" , "Brigadir" , STR_TO_DATE("24.5.1965.", "%d.%m.%Y.") , STR_TO_DATE("26.9.2019.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 5 ),
 ( 10105 , 2 , "Teo" , "Lončar" , "Brigadir" , STR_TO_DATE("13.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("11.2.1992.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 1 ),
 ( 10106 , 4 , "Levi" , "Burić" , "Razvodnik" , STR_TO_DATE("4.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("20.9.1994.", "%d.%m.%Y.") , "Mrtav" , "0+" , 3 ),
 ( 10107 , 1 , "Oto" , "Popović" , "Pozornik" , STR_TO_DATE("28.2.1970.", "%d.%m.%Y.") , STR_TO_DATE("30.12.1991.", "%d.%m.%Y.") , "Aktivan" , "B+" , 1 ),
 ( 10108 , 1 , "Emil" , "Bošnjak" , "Bojnik" , STR_TO_DATE("7.5.1958.", "%d.%m.%Y.") , STR_TO_DATE("5.6.2011.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 5 ),
 ( 10109 , 3 , "Valentin" , "Brajković" , "Brigadir" , STR_TO_DATE("16.8.1964.", "%d.%m.%Y.") , STR_TO_DATE("31.3.2006.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 4 ),
 ( 10110 , 1 , "Mae" , "Tomić" , "Razvodnik" , STR_TO_DATE("14.6.1960.", "%d.%m.%Y.") , STR_TO_DATE("25.10.2020.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 2 ),
 ( 10111 , 3 , "Josipa" , "Posavec" , "Bojnik" , STR_TO_DATE("27.5.1964.", "%d.%m.%Y.") , STR_TO_DATE("28.3.2020.", "%d.%m.%Y.") , "Mrtav" , "0-" , 2 ),
 ( 10112 , 1 , "Siri" , "Šimunić" , "Bojnik" , STR_TO_DATE("9.4.1960.", "%d.%m.%Y.") , STR_TO_DATE("1.8.1994.", "%d.%m.%Y.") , "Aktivan" , "0+" , 3 ),
 ( 10113 , 2 , "Leonardo" , "Mandić" , "Narednik" , STR_TO_DATE("6.7.1960.", "%d.%m.%Y.") , STR_TO_DATE("26.9.1993.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 5 ),
 ( 10114 , 2 , "Lena" , "Šimunović" , "Pozornik" , STR_TO_DATE("29.12.1959.", "%d.%m.%Y.") , STR_TO_DATE("9.5.2003.", "%d.%m.%Y.") , "Mrtav" , "B-" , 5 ),
 ( 10115 , 1 , "David" , "Lučić" , "Skupnik" , STR_TO_DATE("8.6.1951.", "%d.%m.%Y.") , STR_TO_DATE("13.8.2005.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 3 ),
 ( 10116 , 1 , "Jaro" , "Krznarić" , "Satnik" , STR_TO_DATE("5.4.1953.", "%d.%m.%Y.") , STR_TO_DATE("25.9.1991.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 2 ),
 ( 10117 , 4 , "Demi" , "Jovanović" , "Satnik" , STR_TO_DATE("27.4.1965.", "%d.%m.%Y.") , STR_TO_DATE("28.11.2002.", "%d.%m.%Y.") , "Mrtav" , "0+" , 1 ),
 ( 10118 , 2 , "Adela" , "Kolarić" , "Satnik" , STR_TO_DATE("17.12.1963.", "%d.%m.%Y.") , STR_TO_DATE("8.2.2008.", "%d.%m.%Y.") , "Aktivan" , "B-" , 2 ),
 ( 10119 , 3 , "Katarina" , "Matković" , "Pozornik" , STR_TO_DATE("31.7.1962.", "%d.%m.%Y.") , STR_TO_DATE("9.7.2009.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 2 ),
 ( 10120 , 2 , "Vada" , "Kovačić" , "Pukovnik" , STR_TO_DATE("17.12.1953.", "%d.%m.%Y.") , STR_TO_DATE("6.11.2009.", "%d.%m.%Y.") , "Mrtav" , "0+" , 2 ),
 ( 10121 , 4 , "Neven" , "Šarić" , "Skupnik" , STR_TO_DATE("6.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("28.8.2002.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 4 ),
 ( 10122 , 4 , "Jolena" , "Horvat" , "Poručnik" , STR_TO_DATE("11.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("17.2.1997.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 2 ),
 ( 10123 , 4 , "Dragica" , "Kovačević" , "Brigadir" , STR_TO_DATE("18.8.1959.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2004.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 5 ),
 ( 10124 , 4 , "Arijela" , "Rukavina" , "Satnik" , STR_TO_DATE("16.1.1967.", "%d.%m.%Y.") , STR_TO_DATE("10.3.2016.", "%d.%m.%Y.") , "Aktivan" , "0+" , 2 ),
 ( 10125 , 2 , "Martina" , "Babić" , "Brigadir" , STR_TO_DATE("2.1.1970.", "%d.%m.%Y.") , STR_TO_DATE("10.7.1998.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 4 ),
 ( 10126 , 3 , "Jasmina" , "Novosel" , "Poručnik" , STR_TO_DATE("13.3.1956.", "%d.%m.%Y.") , STR_TO_DATE("17.6.2004.", "%d.%m.%Y.") , "Aktivan" , "A-" , 5 ),
 ( 10127 , 3 , "Mila" , "Perković" , "Bojnik" , STR_TO_DATE("1.4.1962.", "%d.%m.%Y.") , STR_TO_DATE("17.7.2012.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 1 ),
 ( 10128 , 1 , "Romeo" , "Šajina" , "Razvodnik" , STR_TO_DATE("7.7.1960.", "%d.%m.%Y.") , STR_TO_DATE("24.12.2004.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 4 ),
 ( 10129 , 2 , "Maksima" , "Crnković" , "Bojnik" , STR_TO_DATE("11.2.1970.", "%d.%m.%Y.") , STR_TO_DATE("23.12.2013.", "%d.%m.%Y.") , "Aktivan" , "B-" , 5 ),
 ( 10130 , 4 , "Zola" , "Šimunović" , "Razvodnik" , STR_TO_DATE("21.10.1968.", "%d.%m.%Y.") , STR_TO_DATE("20.9.2012.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 2 ),
 ( 10131 , 4 , "Penelopa" , "Sever" , "Pukovnik" , STR_TO_DATE("30.11.1957.", "%d.%m.%Y.") , STR_TO_DATE("27.1.1997.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 2 ),
 ( 10132 , 2 , "Goran" , "Oreški" , "General" , STR_TO_DATE("22.10.1950.", "%d.%m.%Y.") , STR_TO_DATE("19.12.1993.", "%d.%m.%Y.") , "Aktivan" , "A-" , 5 ),
 ( 10133 , 4 , "Kiana" , "Klarić" , "Razvodnik" , STR_TO_DATE("29.3.1967.", "%d.%m.%Y.") , STR_TO_DATE("27.1.1994.", "%d.%m.%Y.") , "Mrtav" , "0+" , 1 ),
 ( 10134 , 2 , "Kali" , "Dragičević" , "Pukovnik" , STR_TO_DATE("21.10.1953.", "%d.%m.%Y.") , STR_TO_DATE("26.1.2006.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 1 ),
 ( 10135 , 4 , "Tomislava" , "Jelić" , "Satnik" , STR_TO_DATE("12.11.1959.", "%d.%m.%Y.") , STR_TO_DATE("22.9.1991.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 4 ),
 ( 10136 , 2 , "Manuel" , "Đurđević" , "Satnik" , STR_TO_DATE("25.5.1958.", "%d.%m.%Y.") , STR_TO_DATE("5.10.2002.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 4 ),
 ( 10137 , 3 , "Nia" , "Jurić" , "Pozornik" , STR_TO_DATE("28.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("27.1.2004.", "%d.%m.%Y.") , "Aktivan" , "A-" , 3 ),
 ( 10138 , 3 , "Ksaver" , "Burić" , "Poručnik" , STR_TO_DATE("30.6.1963.", "%d.%m.%Y.") , STR_TO_DATE("26.5.2016.", "%d.%m.%Y.") , "Aktivan" , "A+" , 3 ),
 ( 10139 , 2 , "Jerko" , "Mitrović" , "Razvodnik" , STR_TO_DATE("4.3.1951.", "%d.%m.%Y.") , STR_TO_DATE("22.2.2012.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 4 ),
 ( 10140 , 4 , "Jan" , "Božac" , "Bojnik" , STR_TO_DATE("18.9.1962.", "%d.%m.%Y.") , STR_TO_DATE("23.5.2012.", "%d.%m.%Y.") , "Pokojan" , "A+" , 4 ),
 ( 10141 , 2 , "Severino" , "Božić" , "Bojnik" , STR_TO_DATE("25.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("30.4.2020.", "%d.%m.%Y.") , "Aktivan" , "A-" , 4 ),
 ( 10142 , 3 , "Lika" , "Kralj" , "Brigadir" , STR_TO_DATE("6.6.1953.", "%d.%m.%Y.") , STR_TO_DATE("14.9.2004.", "%d.%m.%Y.") , "Aktivan" , "B+" , 5 ),
 ( 10143 , 1 , "Darko" , "Ivanković" , "Poručnik" , STR_TO_DATE("28.3.1957.", "%d.%m.%Y.") , STR_TO_DATE("28.5.2004.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 3 ),
 ( 10144 , 1 , "Jada" , "Dujmović" , "Skupnik" , STR_TO_DATE("17.5.1961.", "%d.%m.%Y.") , STR_TO_DATE("5.5.1998.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 2 ),
 ( 10145 , 1 , "Aleksandra" , "Jozić" , "Poručnik" , STR_TO_DATE("14.12.1952.", "%d.%m.%Y.") , STR_TO_DATE("12.9.2007.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 5 ),
 ( 10146 , 4 , "Marcel" , "Kolarić" , "Satnik" , STR_TO_DATE("11.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("19.1.2002.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 5 ),
 ( 10147 , 3 , "Romea" , "Marković" , "Bojnik" , STR_TO_DATE("15.12.1965.", "%d.%m.%Y.") , STR_TO_DATE("5.12.2010.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 3 ),
 ( 10148 , 1 , "Dunja" , "Kovačić" , "Skupnik" , STR_TO_DATE("9.7.1961.", "%d.%m.%Y.") , STR_TO_DATE("19.6.1999.", "%d.%m.%Y.") , "Aktivan" , "B+" , 4 ),
 ( 10149 , 1 , "Sunčana" , "Dujmović" , "Bojnik" , STR_TO_DATE("9.2.1970.", "%d.%m.%Y.") , STR_TO_DATE("17.11.2017.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 2 ),
 ( 10150 , 3 , "Divna" , "Galić" , "Brigadir" , STR_TO_DATE("20.3.1959.", "%d.%m.%Y.") , STR_TO_DATE("1.7.2001.", "%d.%m.%Y.") , "Aktivan" , "0+" , 5 ),
 ( 10151 , 4 , "Mikaela" , "Blažević" , "Razvodnik" , STR_TO_DATE("7.1.1965.", "%d.%m.%Y.") , STR_TO_DATE("22.4.1992.", "%d.%m.%Y.") , "Mrtav" , "B-" , 1 ),
 ( 10152 , 4 , "Natalija" , "Janković" , "Bojnik" , STR_TO_DATE("22.12.1958.", "%d.%m.%Y.") , STR_TO_DATE("29.4.1993.", "%d.%m.%Y.") , "Mrtav" , "A-" , 1 ),
 ( 10153 , 1 , "Oskar" , "Perković" , "Bojnik" , STR_TO_DATE("11.3.1952.", "%d.%m.%Y.") , STR_TO_DATE("3.10.2015.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 1 ),
 ( 10154 , 2 , "Estela" , "Blažević" , "Narednik" , STR_TO_DATE("3.4.1957.", "%d.%m.%Y.") , STR_TO_DATE("23.12.2003.", "%d.%m.%Y.") , "Mrtav" , "A-" , 1 ),
 ( 10155 , 2 , "Koraljka" , "Kovač" , "Brigadir" , STR_TO_DATE("4.6.1966.", "%d.%m.%Y.") , STR_TO_DATE("25.3.2008.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 5 ),
 ( 10156 , 3 , "Hai" , "Vidaković" , "Satnik" , STR_TO_DATE("16.10.1969.", "%d.%m.%Y.") , STR_TO_DATE("6.2.2013.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 5 ),
 ( 10157 , 2 , "Hada" , "Marić" , "Pozornik" , STR_TO_DATE("10.2.1960.", "%d.%m.%Y.") , STR_TO_DATE("20.10.2018.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 5 ),
 ( 10158 , 2 , "Alea" , "Jelić" , "Razvodnik" , STR_TO_DATE("21.12.1965.", "%d.%m.%Y.") , STR_TO_DATE("28.4.2007.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 5 ),
 ( 10159 , 2 , "Serena" , "Knežević" , "Pukovnik" , STR_TO_DATE("18.12.1955.", "%d.%m.%Y.") , STR_TO_DATE("8.12.2017.", "%d.%m.%Y.") , "Mrtav" , "0-" , 3 ),
 ( 10160 , 2 , "Amaia" , "Rukavina" , "Pukovnik" , STR_TO_DATE("27.7.1966.", "%d.%m.%Y.") , STR_TO_DATE("29.5.2010.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 1 ),
 ( 10161 , 1 , "Ivano" , "Miletić" , "Bojnik" , STR_TO_DATE("28.6.1953.", "%d.%m.%Y.") , STR_TO_DATE("7.11.2009.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 2 ),
 ( 10162 , 3 , "Briela" , "Jakovljević" , "Skupnik" , STR_TO_DATE("31.8.1965.", "%d.%m.%Y.") , STR_TO_DATE("13.10.1995.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 2 ),
 ( 10163 , 3 , "Tristan" , "Đurić" , "Pukovnik" , STR_TO_DATE("16.1.1958.", "%d.%m.%Y.") , STR_TO_DATE("19.8.1997.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 4 ),
 ( 10164 , 1 , "Nikolina" , "Galić" , "Poručnik" , STR_TO_DATE("9.10.1953.", "%d.%m.%Y.") , STR_TO_DATE("5.7.1990.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 5 ),
 ( 10165 , 3 , "Rohan" , "Kovačić" , "Razvodnik" , STR_TO_DATE("11.4.1966.", "%d.%m.%Y.") , STR_TO_DATE("22.7.1992.", "%d.%m.%Y.") , "Aktivan" , "0+" , 5 ),
 ( 10166 , 4 , "Liam" , "Šimunović" , "Pukovnik" , STR_TO_DATE("5.5.1960.", "%d.%m.%Y.") , STR_TO_DATE("22.12.2008.", "%d.%m.%Y.") , "Mrtav" , "0-" , 2 ),
 ( 10167 , 2 , "Kaja" , "Brajković" , "Satnik" , STR_TO_DATE("16.10.1966.", "%d.%m.%Y.") , STR_TO_DATE("11.8.1993.", "%d.%m.%Y.") , "Umirovljen" , "AB-" , 5 ),
 ( 10168 , 2 , "Vada" , "Kralj" , "Pozornik" , STR_TO_DATE("22.2.1956.", "%d.%m.%Y.") , STR_TO_DATE("20.5.2018.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 4 ),
 ( 10169 , 1 , "Sumka" , "Grgurić" , "Narednik" , STR_TO_DATE("4.11.1951.", "%d.%m.%Y.") , STR_TO_DATE("3.6.2008.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 4 ),
 ( 10170 , 4 , "Toni" , "Vuković" , "Razvodnik" , STR_TO_DATE("27.10.1966.", "%d.%m.%Y.") , STR_TO_DATE("26.12.2016.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 1 ),
 ( 10171 , 3 , "Loreta" , "Đurđević" , "Satnik" , STR_TO_DATE("1.3.1958.", "%d.%m.%Y.") , STR_TO_DATE("28.5.2014.", "%d.%m.%Y.") , "Mrtav" , "A+" , 4 ),
 ( 10172 , 2 , "Martina" , "Knežević" , "Narednik" , STR_TO_DATE("21.2.1967.", "%d.%m.%Y.") , STR_TO_DATE("10.10.2013.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 3 ),
 ( 10173 , 1 , "Martina" , "Josipović" , "Razvodnik" , STR_TO_DATE("2.11.1968.", "%d.%m.%Y.") , STR_TO_DATE("30.6.1999.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 1 ),
 ( 10174 , 3 , "Klementina" , "Janković" , "Razvodnik" , STR_TO_DATE("13.4.1962.", "%d.%m.%Y.") , STR_TO_DATE("11.10.1991.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 3 ),
 ( 10175 , 3 , "Lile" , "Cindrić" , "Poručnik" , STR_TO_DATE("29.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.6.1990.", "%d.%m.%Y.") , "Mrtav" , "0+" , 2 ),
 ( 10176 , 2 , "Eliza" , "Vuković" , "Satnik" , STR_TO_DATE("1.2.1966.", "%d.%m.%Y.") , STR_TO_DATE("18.3.2004.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 4 ),
 ( 10177 , 4 , "Željkica" , "Vidović" , "Brigadir" , STR_TO_DATE("29.1.1969.", "%d.%m.%Y.") , STR_TO_DATE("16.5.2016.", "%d.%m.%Y.") , "Mrtav" , "0-" , 4 ),
 ( 10178 , 3 , "Franko" , "Butković" , "Skupnik" , STR_TO_DATE("18.11.1967.", "%d.%m.%Y.") , STR_TO_DATE("1.4.1993.", "%d.%m.%Y.") , "Mrtav" , "0-" , 1 ),
 ( 10179 , 2 , "Pepa" , "Nikolić" , "Brigadir" , STR_TO_DATE("1.7.1970.", "%d.%m.%Y.") , STR_TO_DATE("5.9.2018.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 3 ),
 ( 10180 , 3 , "Mauro" , "Knežević" , "Brigadir" , STR_TO_DATE("4.6.1962.", "%d.%m.%Y.") , STR_TO_DATE("31.7.2013.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 3 ),
 ( 10181 , 1 , "Salema" , "Blažević" , "Bojnik" , STR_TO_DATE("27.11.1951.", "%d.%m.%Y.") , STR_TO_DATE("9.12.2009.", "%d.%m.%Y.") , "Mrtav" , "A-" , 4 ),
 ( 10182 , 1 , "Adam" , "Šimunović" , "Narednik" , STR_TO_DATE("7.3.1960.", "%d.%m.%Y.") , STR_TO_DATE("10.5.2011.", "%d.%m.%Y.") , "Mrtav" , "A+" , 3 ),
 ( 10183 , 3 , "Leonida" , "Vidaković" , "Pukovnik" , STR_TO_DATE("22.4.1956.", "%d.%m.%Y.") , STR_TO_DATE("12.12.2018.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 5 ),
 ( 10184 , 3 , "Bara" , "Perković" , "Razvodnik" , STR_TO_DATE("11.3.1958.", "%d.%m.%Y.") , STR_TO_DATE("28.6.2013.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 5 ),
 ( 10185 , 2 , "Delila" , "Dragičević" , "Brigadir" , STR_TO_DATE("14.7.1955.", "%d.%m.%Y.") , STR_TO_DATE("11.11.2013.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 4 ),
 ( 10186 , 4 , "Davina" , "Perić" , "Pukovnik" , STR_TO_DATE("28.12.1957.", "%d.%m.%Y.") , STR_TO_DATE("11.3.1996.", "%d.%m.%Y.") , "Aktivan" , "0+" , 4 ),
 ( 10187 , 2 , "Leonid" , "Marković" , "Pozornik" , STR_TO_DATE("16.11.1952.", "%d.%m.%Y.") , STR_TO_DATE("8.11.2015.", "%d.%m.%Y.") , "Aktivan" , "A-" , 2 ),
 ( 10188 , 1 , "Siena" , "Božić" , "Satnik" , STR_TO_DATE("4.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("7.12.2020.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 1 ),
 ( 10189 , 1 , "Anabela" , "Bašić" , "Pozornik" , STR_TO_DATE("18.5.1966.", "%d.%m.%Y.") , STR_TO_DATE("3.8.2020.", "%d.%m.%Y.") , "Mrtav" , "B-" , 5 ),
 ( 10190 , 4 , "Bela" , "Varga" , "Brigadir" , STR_TO_DATE("16.12.1960.", "%d.%m.%Y.") , STR_TO_DATE("1.9.1993.", "%d.%m.%Y.") , "Aktivan" , "0-" , 2 ),
 ( 10191 , 1 , "Amir" , "Božić" , "Poručnik" , STR_TO_DATE("8.9.1965.", "%d.%m.%Y.") , STR_TO_DATE("19.11.2010.", "%d.%m.%Y.") , "Mrtav" , "0+" , 5 ),
 ( 10192 , 2 , "Đina" , "Perković" , "Brigadir" , STR_TO_DATE("25.8.1953.", "%d.%m.%Y.") , STR_TO_DATE("26.3.1997.", "%d.%m.%Y.") , "Aktivan" , "B+" , 1 ),
 ( 10193 , 3 , "Rubi" , "Grgurić" , "Pukovnik" , STR_TO_DATE("16.2.1954.", "%d.%m.%Y.") , STR_TO_DATE("12.2.2002.", "%d.%m.%Y.") , "Mrtav" , "0+" , 3 ),
 ( 10194 , 3 , "Daniel" , "Brajković" , "Satnik" , STR_TO_DATE("11.8.1956.", "%d.%m.%Y.") , STR_TO_DATE("30.9.1997.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 3 ),
 ( 10195 , 2 , "Karmela" , "Crnković" , "Pozornik" , STR_TO_DATE("14.10.1958.", "%d.%m.%Y.") , STR_TO_DATE("28.8.1998.", "%d.%m.%Y.") , "Mrtav" , "A+" , 1 ),
 ( 10196 , 3 , "Filip" , "Pavlović" , "Satnik" , STR_TO_DATE("2.1.1951.", "%d.%m.%Y.") , STR_TO_DATE("10.4.2003.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 2 ),
 ( 10197 , 1 , "Kaila" , "Matković" , "Brigadir" , STR_TO_DATE("16.10.1962.", "%d.%m.%Y.") , STR_TO_DATE("18.4.2000.", "%d.%m.%Y.") , "Mrtav" , "B+" , 4 ),
 ( 10198 , 4 , "Princa" , "Lukić" , "Brigadir" , STR_TO_DATE("23.4.1966.", "%d.%m.%Y.") , STR_TO_DATE("15.11.2003.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 5 ),
 ( 10199 , 2 , "Roberta" , "Grgić" , "Razvodnik" , STR_TO_DATE("31.1.1954.", "%d.%m.%Y.") , STR_TO_DATE("29.12.1993.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 2 ),
 ( 10200 , 1 , "Ediza" , "Mikulić" , "Brigadir" , STR_TO_DATE("11.9.1964.", "%d.%m.%Y.") , STR_TO_DATE("20.6.2013.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 4 ),
 ( 10201 , 1 , "Janko" , "Kovač" , "Bojnik" , STR_TO_DATE("20.11.1968.", "%d.%m.%Y.") , STR_TO_DATE("17.11.2017.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 5 ),
 ( 10202 , 4 , "Gema" , "Pavlović" , "Narednik" , STR_TO_DATE("24.1.1969.", "%d.%m.%Y.") , STR_TO_DATE("28.3.1998.", "%d.%m.%Y.") , "Aktivan" , "B+" , 2 ),
 ( 10203 , 3 , "Filip" , "Vrdoljak" , "Brigadir" , STR_TO_DATE("20.12.1962.", "%d.%m.%Y.") , STR_TO_DATE("6.9.2017.", "%d.%m.%Y.") , "Mrtav" , "B-" , 5 ),
 ( 10204 , 2 , "Iris" , "Vučković" , "Pukovnik" , STR_TO_DATE("12.4.1967.", "%d.%m.%Y.") , STR_TO_DATE("26.6.2006.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 3 ),
 ( 10205 , 4 , "Miranda" , "Crnković" , "Razvodnik" , STR_TO_DATE("10.11.1952.", "%d.%m.%Y.") , STR_TO_DATE("9.6.2006.", "%d.%m.%Y.") , "Mrtav" , "A-" , 3 ),
 ( 10206 , 2 , "Paola" , "Petrović" , "Narednik" , STR_TO_DATE("2.5.1969.", "%d.%m.%Y.") , STR_TO_DATE("23.11.1995.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 3 ),
 ( 10207 , 4 , "Pavle" , "Mandić" , "Satnik" , STR_TO_DATE("17.12.1967.", "%d.%m.%Y.") , STR_TO_DATE("22.7.2020.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 2 ),
 ( 10208 , 2 , "Karolina" , "Šarić" , "Brigadir" , STR_TO_DATE("3.7.1961.", "%d.%m.%Y.") , STR_TO_DATE("15.1.2005.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 1 ),
 ( 10209 , 4 , "Marija" , "Kralj" , "Narednik" , STR_TO_DATE("10.12.1951.", "%d.%m.%Y.") , STR_TO_DATE("29.4.1998.", "%d.%m.%Y.") , "Mrtav" , "A-" , 2 ),
 ( 10210 , 2 , "Levi" , "Filipović" , "Poručnik" , STR_TO_DATE("8.7.1965.", "%d.%m.%Y.") , STR_TO_DATE("6.6.2003.", "%d.%m.%Y.") , "Aktivan" , "0-" , 1 ),
 ( 10211 , 2 , "Nikol" , "Mandić" , "Pukovnik" , STR_TO_DATE("27.2.1968.", "%d.%m.%Y.") , STR_TO_DATE("11.1.1994.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 4 ),
 ( 10212 , 3 , "Kai" , "Novosel" , "Poručnik" , STR_TO_DATE("17.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("1.6.2012.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 1 ),
 ( 10213 , 2 , "Eva" , "Bošnjak" , "Pukovnik" , STR_TO_DATE("2.11.1961.", "%d.%m.%Y.") , STR_TO_DATE("5.10.2011.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 4 ),
 ( 10214 , 2 , "Leonardo" , "Abramović" , "Poručnik" , STR_TO_DATE("25.9.1951.", "%d.%m.%Y.") , STR_TO_DATE("2.1.2000.", "%d.%m.%Y.") , "Mrtav" , "B-" , 1 ),
 ( 10215 , 2 , "Tim" , "Knežević" , "Brigadir" , STR_TO_DATE("15.7.1960.", "%d.%m.%Y.") , STR_TO_DATE("16.1.1998.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 5 ),
 ( 10216 , 2 , "Ela" , "Šimić" , "Brigadir" , STR_TO_DATE("21.8.1967.", "%d.%m.%Y.") , STR_TO_DATE("30.5.1999.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 4 ),
 ( 10217 , 4 , "Aleksandra" , "Jelić" , "Narednik" , STR_TO_DATE("4.6.1961.", "%d.%m.%Y.") , STR_TO_DATE("5.8.1994.", "%d.%m.%Y.") , "Aktivan" , "B-" , 3 ),
 ( 10218 , 2 , "Tim" , "Živković" , "Pukovnik" , STR_TO_DATE("26.7.1958.", "%d.%m.%Y.") , STR_TO_DATE("20.10.2009.", "%d.%m.%Y.") , "Mrtav" , "A-" , 4 ),
 ( 10219 , 3 , "Simon" , "Barišić" , "Satnik" , STR_TO_DATE("27.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("27.4.1992.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 1 ),
 ( 10220 , 3 , "Ita" , "Janković" , "Poručnik" , STR_TO_DATE("2.12.1956.", "%d.%m.%Y.") , STR_TO_DATE("8.11.2000.", "%d.%m.%Y.") , "Aktivan" , "0-" , 1 ),
 ( 10221 , 1 , "Armina" , "Marušić" , "Pukovnik" , STR_TO_DATE("25.11.1951.", "%d.%m.%Y.") , STR_TO_DATE("29.4.2005.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 5 ),
 ( 10222 , 3 , "Mara" , "Ružić" , "Pukovnik" , STR_TO_DATE("4.7.1957.", "%d.%m.%Y.") , STR_TO_DATE("15.10.2005.", "%d.%m.%Y.") , "Aktivan" , "0+" , 4 ),
 ( 10223 , 4 , "Lada" , "Lončar" , "Brigadir" , STR_TO_DATE("7.12.1957.", "%d.%m.%Y.") , STR_TO_DATE("16.3.2015.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 2 ),
 ( 10224 , 2 , "Florenca" , "Novosel" , "Bojnik" , STR_TO_DATE("23.10.1959.", "%d.%m.%Y.") , STR_TO_DATE("10.12.2000.", "%d.%m.%Y.") , "Aktivan" , "0-" , 4 ),
 ( 10225 , 2 , "Dalia" , "Perić" , "Brigadir" , STR_TO_DATE("9.2.1969.", "%d.%m.%Y.") , STR_TO_DATE("30.8.2005.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 4 ),
 ( 10226 , 4 , "Samara" , "Novaković" , "Narednik" , STR_TO_DATE("5.12.1962.", "%d.%m.%Y.") , STR_TO_DATE("12.6.1990.", "%d.%m.%Y.") , "Mrtav" , "B+" , 3 ),
 ( 10227 , 1 , "Kiara" , "Šimunović" , "Pukovnik" , STR_TO_DATE("27.5.1961.", "%d.%m.%Y.") , STR_TO_DATE("27.10.1994.", "%d.%m.%Y.") , "Mrtav" , "A+" , 2 ),
 ( 10228 , 3 , "Aziel" , "Tomić" , "Pozornik" , STR_TO_DATE("17.8.1969.", "%d.%m.%Y.") , STR_TO_DATE("19.2.2001.", "%d.%m.%Y.") , "Mrtav" , "B+" , 1 ),
 ( 10229 , 3 , "Levi" , "Kolarić" , "Skupnik" , STR_TO_DATE("21.5.1964.", "%d.%m.%Y.") , STR_TO_DATE("9.5.2012.", "%d.%m.%Y.") , "Umirovljen" , "AB-" , 1 ),
 ( 10230 , 1 , "Liam" , "Grgić" , "Poručnik" , STR_TO_DATE("14.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("13.2.2010.", "%d.%m.%Y.") , "Mrtav" , "A-" , 3 ),
 ( 10231 , 4 , "Luna" , "Marušić" , "Bojnik" , STR_TO_DATE("9.7.1961.", "%d.%m.%Y.") , STR_TO_DATE("19.12.1997.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 3 ),
 ( 10232 , 4 , "Marica" , "Horvat" , "Poručnik" , STR_TO_DATE("17.8.1961.", "%d.%m.%Y.") , STR_TO_DATE("1.3.2019.", "%d.%m.%Y.") , "Aktivan" , "A+" , 1 ),
 ( 10233 , 2 , "Gvena" , "Vrdoljak" , "Pozornik" , STR_TO_DATE("24.2.1950.", "%d.%m.%Y.") , STR_TO_DATE("20.4.1995.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 1 ),
 ( 10234 , 3 , "Ivo" , "Abramović" , "Skupnik" , STR_TO_DATE("6.1.1968.", "%d.%m.%Y.") , STR_TO_DATE("24.9.2009.", "%d.%m.%Y.") , "Mrtav" , "B+" , 3 ),
 ( 10235 , 2 , "Oli" , "Vučković" , "Satnik" , STR_TO_DATE("13.12.1965.", "%d.%m.%Y.") , STR_TO_DATE("14.1.2015.", "%d.%m.%Y.") , "Aktivan" , "B+" , 3 ),
 ( 10236 , 4 , "Alija" , "Marković" , "Brigadir" , STR_TO_DATE("18.9.1970.", "%d.%m.%Y.") , STR_TO_DATE("23.8.2004.", "%d.%m.%Y.") , "Aktivan" , "A-" , 4 ),
 ( 10237 , 4 , "Mira" , "Ružić" , "Satnik" , STR_TO_DATE("7.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("12.6.2005.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 5 ),
 ( 10238 , 1 , "Maca" , "Tomić" , "Skupnik" , STR_TO_DATE("9.4.1960.", "%d.%m.%Y.") , STR_TO_DATE("23.11.2001.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 1 ),
 ( 10239 , 4 , "Franjo" , "Lončar" , "Brigadir" , STR_TO_DATE("31.10.1954.", "%d.%m.%Y.") , STR_TO_DATE("28.9.1991.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 4 ),
 ( 10240 , 1 , "Ante" , "Pavlić" , "Pozornik" , STR_TO_DATE("19.1.1966.", "%d.%m.%Y.") , STR_TO_DATE("21.12.2000.", "%d.%m.%Y.") , "Mrtav" , "A-" , 1 ),
 ( 10241 , 1 , "Loreta" , "Bošnjak" , "Pukovnik" , STR_TO_DATE("22.5.1970.", "%d.%m.%Y.") , STR_TO_DATE("23.3.2011.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 3 ),
 ( 10242 , 3 , "Amber" , "Sever" , "Poručnik" , STR_TO_DATE("6.8.1968.", "%d.%m.%Y.") , STR_TO_DATE("28.3.2015.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 3 ),
 ( 10243 , 1 , "Josipa" , "Pavlović" , "Brigadir" , STR_TO_DATE("15.11.1953.", "%d.%m.%Y.") , STR_TO_DATE("9.9.2019.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 3 ),
 ( 10244 , 3 , "Dejan" , "Posavec" , "Poručnik" , STR_TO_DATE("8.4.1968.", "%d.%m.%Y.") , STR_TO_DATE("23.12.2000.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 3 ),
 ( 10245 , 3 , "Miroslava" , "Jakovljević" , "Narednik" , STR_TO_DATE("19.4.1967.", "%d.%m.%Y.") , STR_TO_DATE("28.9.2017.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 5 ),
 ( 10246 , 2 , "Srećko" , "Barišić" , "Razvodnik" , STR_TO_DATE("29.7.1966.", "%d.%m.%Y.") , STR_TO_DATE("28.1.1994.", "%d.%m.%Y.") , "Aktivan" , "B+" , 5 ),
 ( 10247 , 1 , "Mio" , "Knežević" , "Pukovnik" , STR_TO_DATE("15.5.1959.", "%d.%m.%Y.") , STR_TO_DATE("10.12.2005.", "%d.%m.%Y.") , "Mrtav" , "0-" , 1 ),
 ( 10248 , 1 , "Kina" , "Jukić" , "Skupnik" , STR_TO_DATE("3.1.1955.", "%d.%m.%Y.") , STR_TO_DATE("24.10.1997.", "%d.%m.%Y.") , "Mrtav" , "A-" , 1 ),
 ( 10249 , 3 , "Zakarija" , "Živković" , "Satnik" , STR_TO_DATE("24.10.1957.", "%d.%m.%Y.") , STR_TO_DATE("19.1.2015.", "%d.%m.%Y.") , "Aktivan" , "0-" , 1 ),
 ( 10250 , 2 , "Sanja" , "Grgić" , "Skupnik" , STR_TO_DATE("27.2.1970.", "%d.%m.%Y.") , STR_TO_DATE("16.11.2004.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 2 ),
 ( 10251 , 2 , "Oli" , "Crnković" , "Brigadir" , STR_TO_DATE("23.2.1953.", "%d.%m.%Y.") , STR_TO_DATE("17.10.1995.", "%d.%m.%Y.") , "Mrtav" , "B-" , 1 ),
 ( 10252 , 2 , "Greta" , "Jukić" , "Pozornik" , STR_TO_DATE("10.2.1952.", "%d.%m.%Y.") , STR_TO_DATE("27.12.2013.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 4 ),
 ( 10253 , 1 , "Nataša" , "Novosel" , "Satnik" , STR_TO_DATE("20.8.1957.", "%d.%m.%Y.") , STR_TO_DATE("26.5.2013.", "%d.%m.%Y.") , "Mrtav" , "0-" , 1 ),
 ( 10254 , 2 , "Tereza" , "Babić" , "Brigadir" , STR_TO_DATE("9.2.1954.", "%d.%m.%Y.") , STR_TO_DATE("11.12.2007.", "%d.%m.%Y.") , "Aktivan" , "A-" , 4 ),
 ( 10255 , 3 , "Elora" , "Kolarić" , "Bojnik" , STR_TO_DATE("27.6.1961.", "%d.%m.%Y.") , STR_TO_DATE("22.6.2006.", "%d.%m.%Y.") , "Aktivan" , "B-" , 3 ),
 ( 10256 , 2 , "Lejla" , "Tomić" , "Poručnik" , STR_TO_DATE("11.7.1957.", "%d.%m.%Y.") , STR_TO_DATE("28.5.1993.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 2 ),
 ( 10257 , 2 , "Romea" , "Marić" , "Pozornik" , STR_TO_DATE("25.4.1956.", "%d.%m.%Y.") , STR_TO_DATE("30.6.1990.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 2 ),
 ( 10258 , 4 , "Ane" , "Jozić" , "Pukovnik" , STR_TO_DATE("2.2.1960.", "%d.%m.%Y.") , STR_TO_DATE("20.10.2008.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 3 ),
 ( 10259 , 2 , "Simona" , "Crnković" , "Skupnik" , STR_TO_DATE("14.10.1960.", "%d.%m.%Y.") , STR_TO_DATE("4.3.1999.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 3 ),
 ( 10260 , 3 , "Irena" , "Petrović" , "Skupnik" , STR_TO_DATE("22.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("10.9.2014.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 3 ),
 ( 10261 , 1 , "Marina" , "Jurić" , "Satnik" , STR_TO_DATE("11.5.1950.", "%d.%m.%Y.") , STR_TO_DATE("25.12.2014.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 5 ),
 ( 10262 , 4 , "Mirijam" , "Pavlović" , "Skupnik" , STR_TO_DATE("10.11.1952.", "%d.%m.%Y.") , STR_TO_DATE("12.8.1994.", "%d.%m.%Y.") , "Aktivan" , "A+" , 4 ),
 ( 10263 , 3 , "Magda" , "Blažević" , "Razvodnik" , STR_TO_DATE("7.12.1968.", "%d.%m.%Y.") , STR_TO_DATE("22.12.2008.", "%d.%m.%Y.") , "Aktivan" , "B+" , 1 ),
 ( 10264 , 4 , "Lovorka" , "Lončar" , "Satnik" , STR_TO_DATE("30.4.1951.", "%d.%m.%Y.") , STR_TO_DATE("11.1.1998.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 1 ),
 ( 10265 , 1 , "Jara" , "Tomić" , "Narednik" , STR_TO_DATE("27.10.1961.", "%d.%m.%Y.") , STR_TO_DATE("8.2.2012.", "%d.%m.%Y.") , "Aktivan" , "A+" , 3 ),
 ( 10266 , 1 , "Disa" , "Ivanović" , "Satnik" , STR_TO_DATE("13.4.1961.", "%d.%m.%Y.") , STR_TO_DATE("21.11.1999.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 5 ),
 ( 10267 , 4 , "Simon" , "Mitrović" , "Narednik" , STR_TO_DATE("22.2.1963.", "%d.%m.%Y.") , STR_TO_DATE("10.1.2017.", "%d.%m.%Y.") , "Aktivan" , "B-" , 1 ),
 ( 10268 , 2 , "Anastasija" , "Dragičević" , "Poručnik" , STR_TO_DATE("30.8.1964.", "%d.%m.%Y.") , STR_TO_DATE("10.8.2013.", "%d.%m.%Y.") , "Neaktivan" , "AB-",2 ),
 ( 10269 , 1 , "Breta" , "Babić" , "Bojnik" , STR_TO_DATE("25.3.1969.", "%d.%m.%Y.") , STR_TO_DATE("29.1.2016.", "%d.%m.%Y.") , "Aktivan" , "0-" , 2 ),
 ( 10270 , 4 , "Barbara" , "Jurković" , "Skupnik" , STR_TO_DATE("2.2.1964.", "%d.%m.%Y.") , STR_TO_DATE("28.6.2008.", "%d.%m.%Y.") , "Mrtav" , "A-" , 2 ),
 ( 10271 , 3 , "Noela" , "Horvat" , "Bojnik" , STR_TO_DATE("12.8.1951.", "%d.%m.%Y.") , STR_TO_DATE("10.6.2011.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 4 ),
 ( 10272 , 1 , "Leandro" , "Miletić" , "Bojnik" , STR_TO_DATE("29.3.1963.", "%d.%m.%Y.") , STR_TO_DATE("25.7.2014.", "%d.%m.%Y.") , "Mrtav" , "B-" , 4 ),
 ( 10273 , 1 , "Draženka" , "Barišić" , "Brigadir" , STR_TO_DATE("15.4.1969.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2010.", "%d.%m.%Y.") , "Mrtav" , "A-" , 2 ),
 ( 10274 , 3 , "Lora" , "Šarić" , "Skupnik" , STR_TO_DATE("12.5.1957.", "%d.%m.%Y.") , STR_TO_DATE("20.11.2005.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 3 ),
 ( 10275 , 4 , "Jakov" , "Bilić" , "Razvodnik" , STR_TO_DATE("25.10.1965.", "%d.%m.%Y.") , STR_TO_DATE("30.10.1996.", "%d.%m.%Y.") , "Mrtav" , "B+" , 2 ),
 ( 10276 , 1 , "Monika" , "Šimunović" , "Pukovnik" , STR_TO_DATE("26.9.1955.", "%d.%m.%Y.") , STR_TO_DATE("2.1.2005.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 2 ),
 ( 10277 , 3 , "Azalea" , "Tomić" , "Razvodnik" , STR_TO_DATE("3.4.1957.", "%d.%m.%Y.") , STR_TO_DATE("15.6.2018.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 4 ),
 ( 10278 , 1 , "Ramona" , "Novaković" , "Narednik" , STR_TO_DATE("10.4.1962.", "%d.%m.%Y.") , STR_TO_DATE("9.4.1992.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 4 ),
 ( 10279 , 4 , "Romina" , "Krznarić" , "Poručnik" , STR_TO_DATE("18.2.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.3.1992.", "%d.%m.%Y.") , "Mrtav" , "A+" , 4 ),
 ( 10280 , 4 , "Rubika" , "Blažević" , "Narednik" , STR_TO_DATE("8.7.1965.", "%d.%m.%Y.") , STR_TO_DATE("20.10.1998.", "%d.%m.%Y.") , "Mrtav" , "0+" , 2 ),
 ( 10281 , 1 , "Nova" , "Dujmović" , "Pozornik" , STR_TO_DATE("4.1.1950.", "%d.%m.%Y.") , STR_TO_DATE("11.4.2017.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 1 ),
 ( 10282 , 3 , "Darinka" , "Đurić" , "Bojnik" , STR_TO_DATE("16.8.1964.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2004.", "%d.%m.%Y.") , "Mrtav" , "0+" , 5 ),
 ( 10283 , 4 , "Nika" , "Pavlović" , "Poručnik" , STR_TO_DATE("13.7.1969.", "%d.%m.%Y.") , STR_TO_DATE("2.5.2008.", "%d.%m.%Y.") , "Aktivan" , "0+" , 5 ),
 ( 10284 , 4 , "Lada" , "Grubišić" , "Satnik" , STR_TO_DATE("24.2.1967.", "%d.%m.%Y.") , STR_TO_DATE("27.11.2018.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 3 ),
 ( 10285 , 4 , "Nikolina" , "Pavić" , "Pukovnik" , STR_TO_DATE("28.12.1968.", "%d.%m.%Y.") , STR_TO_DATE("5.5.2002.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 4 ),
 ( 10286 , 4 , "Loreta" , "Cindrić" , "Satnik" , STR_TO_DATE("3.4.1957.", "%d.%m.%Y.") , STR_TO_DATE("24.11.2020.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 5 ),
 ( 10287 , 2 , "Žaklina" , "Vukelić" , "Poručnik" , STR_TO_DATE("2.11.1968.", "%d.%m.%Y.") , STR_TO_DATE("4.4.1992.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 2 ),
 ( 10288 , 1 , "Mara" , "Filipović" , "Skupnik" , STR_TO_DATE("14.12.1953.", "%d.%m.%Y.") , STR_TO_DATE("19.8.2015.", "%d.%m.%Y.") , "Mrtav" , "A+" , 3 ),
 ( 10289 , 2 , "Hrvojka" , "Jurčević" , "Pozornik" , STR_TO_DATE("26.2.1959.", "%d.%m.%Y.") , STR_TO_DATE("21.2.2004.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 2 ),
 ( 10290 , 4 , "Naja" , "Antunović" , "Pozornik" , STR_TO_DATE("10.8.1961.", "%d.%m.%Y.") , STR_TO_DATE("18.6.2003.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 1 ),
 ( 10291 , 3 , "Delila" , "Vukelić" , "Pukovnik" , STR_TO_DATE("5.8.1968.", "%d.%m.%Y.") , STR_TO_DATE("13.6.2009.", "%d.%m.%Y.") , "Mrtav" , "0+" , 5 ),
 ( 10292 , 3 , "Eli" , "Mikulić" , "Narednik" , STR_TO_DATE("5.4.1968.", "%d.%m.%Y.") , STR_TO_DATE("22.2.2013.", "%d.%m.%Y.") , "Mrtav" , "B-" , 4 ),
 ( 10293 , 3 , "David" , "Knežević" , "Skupnik" , STR_TO_DATE("7.8.1959.", "%d.%m.%Y.") , STR_TO_DATE("6.5.2014.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 3 ),
 ( 10294 , 1 , "Artemisa" , "Dragičević" , "Razvodnik" , STR_TO_DATE("13.2.1960.", "%d.%m.%Y.") , STR_TO_DATE("29.3.1997.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 4 ),
 ( 10295 , 3 , "Ante" , "Jukić" , "Bojnik" , STR_TO_DATE("28.3.1950.", "%d.%m.%Y.") , STR_TO_DATE("8.3.2008.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 3 ),
 ( 10296 , 2 , "Evica" , "Mandić" , "Pukovnik" , STR_TO_DATE("15.7.1952.", "%d.%m.%Y.") , STR_TO_DATE("15.6.2015.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 3 ),
 ( 10297 , 2 , "Edita" , "Petković" , "Razvodnik" , STR_TO_DATE("19.3.1961.", "%d.%m.%Y.") , STR_TO_DATE("27.6.2015.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 5 ),
 ( 10298 , 3 , "Janko" , "Posavec" , "Razvodnik" , STR_TO_DATE("24.7.1952.", "%d.%m.%Y.") , STR_TO_DATE("3.6.1996.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 5 ),
 ( 10299 , 1 , "Andrija" , "Vukelić" , "Skupnik" , STR_TO_DATE("30.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("28.1.1999.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 2 ),
 ( 10300 , 1 , "Amaja" , "Mandić" , "Brigadir" , STR_TO_DATE("3.11.1957.", "%d.%m.%Y.") , STR_TO_DATE("20.2.2006.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 3 ),
 ( 10301 , 3 , "Bosiljka" , "Vučković" , "Brigadir" , STR_TO_DATE("31.12.1951.", "%d.%m.%Y.") , STR_TO_DATE("11.11.2012.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 2 ),
 ( 10302 , 1 , "Benjamin" , "Stanić" , "Pukovnik" , STR_TO_DATE("28.2.1964.", "%d.%m.%Y.") , STR_TO_DATE("27.6.2009.", "%d.%m.%Y.") , "Mrtav" , "A-" , 3 ),
 ( 10303 , 1 , "Gvena" , "Nikolić" , "Narednik" , STR_TO_DATE("17.11.1950.", "%d.%m.%Y.") , STR_TO_DATE("9.5.2009.", "%d.%m.%Y.") , "Aktivan" , "A-" , 5 ),
 ( 10304 , 1 , "Leana" , "Lukić" , "Pozornik" , STR_TO_DATE("3.12.1970.", "%d.%m.%Y.") , STR_TO_DATE("15.10.1994.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 5 ),
 ( 10305 , 1 , "Naja" , "Vidaković" , "Razvodnik" , STR_TO_DATE("19.11.1969.", "%d.%m.%Y.") , STR_TO_DATE("30.10.1992.", "%d.%m.%Y.") , "Aktivan" , "A+" , 4 ),
 ( 10306 , 3 , "Jura" , "Grgić" , "Narednik" , STR_TO_DATE("12.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("15.7.2005.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 5 ),
 ( 10307 , 2 , "Evelin" , "Burić" , "Brigadir" , STR_TO_DATE("7.12.1964.", "%d.%m.%Y.") , STR_TO_DATE("22.3.2008.", "%d.%m.%Y.") , "Mrtav" , "B+" , 3 ),
 ( 10308 , 3 , "Iko" , "Perković" , "Bojnik" , STR_TO_DATE("20.1.1960.", "%d.%m.%Y.") , STR_TO_DATE("18.11.2008.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 1 ),
 ( 10309 , 1 , "Desa" , "Jurišić" , "Pukovnik" , STR_TO_DATE("24.2.1959.", "%d.%m.%Y.") , STR_TO_DATE("9.2.1990.", "%d.%m.%Y.") , "Umirovljen" , "AB-" , 3 ),
 ( 10310 , 2 , "Klarisa" , "Jurišić" , "Bojnik" , STR_TO_DATE("12.2.1952.", "%d.%m.%Y.") , STR_TO_DATE("15.8.1996.", "%d.%m.%Y.") , "Aktivan" , "0-" , 3 ),
 ( 10311 , 2 , "Ben" , "Klarić" , "Narednik" , STR_TO_DATE("7.7.1965.", "%d.%m.%Y.") , STR_TO_DATE("9.7.1990.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 4 ),
 ( 10312 , 2 , "Tristan" , "Popović" , "Brigadir" , STR_TO_DATE("3.7.1952.", "%d.%m.%Y.") , STR_TO_DATE("18.10.2017.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 2 ),
 ( 10313 , 1 , "Kata" , "Mitrović" , "Satnik" , STR_TO_DATE("23.3.1959.", "%d.%m.%Y.") , STR_TO_DATE("28.10.2015.", "%d.%m.%Y.") , "Mrtav" , "0+" , 4 ),
 ( 10314 , 2 , "Lobel" , "Perković" , "Pozornik" , STR_TO_DATE("3.7.1964.", "%d.%m.%Y.") , STR_TO_DATE("18.3.1992.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 3 ),
 ( 10315 , 1 , "Leonid" , "Martinović" , "Razvodnik" , STR_TO_DATE("22.2.1951.", "%d.%m.%Y.") , STR_TO_DATE("25.12.2010.", "%d.%m.%Y.") , "Aktivan" , "A+" , 2 ),
 ( 10316 , 4 , "Bruna" , "Šimunović" , "Skupnik" , STR_TO_DATE("11.3.1965.", "%d.%m.%Y.") , STR_TO_DATE("29.1.1995.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 5 ),
 ( 10317 , 1 , "Ljerka" , "Crnković" , "Skupnik" , STR_TO_DATE("3.3.1960.", "%d.%m.%Y.") , STR_TO_DATE("15.7.2015.", "%d.%m.%Y.") , "Umirovljen" , "AB-" , 1 ),
 ( 10318 , 4 , "Romina" , "Vrdoljak" , "Skupnik" , STR_TO_DATE("25.8.1960.", "%d.%m.%Y.") , STR_TO_DATE("8.4.1991.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 4 ),
 ( 10319 , 3 , "Adela" , "Josipović" , "Razvodnik" , STR_TO_DATE("22.12.1957.", "%d.%m.%Y.") , STR_TO_DATE("22.4.2016.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 4 ),
 ( 10320 , 3 , "Lucijano" , "Petković" , "Satnik" , STR_TO_DATE("22.3.1967.", "%d.%m.%Y.") , STR_TO_DATE("5.7.2012.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 4 ),
 ( 10321 , 2 , "Kiana" , "Lučić" , "Narednik" , STR_TO_DATE("16.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("24.12.2013.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 3 ),
 ( 10322 , 2 , "Irena" , "Butković" , "Skupnik" , STR_TO_DATE("15.10.1962.", "%d.%m.%Y.") , STR_TO_DATE("11.4.2010.", "%d.%m.%Y.") , "Mrtav" , "A-" , 4 ),
 ( 10323 , 3 , "Martea" , "Pavlović" , "Pozornik" , STR_TO_DATE("15.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("14.9.2018.", "%d.%m.%Y.") , "Mrtav" , "B+" , 3 ),
 ( 10324 , 2 , "Dajana" , "Knežević" , "Pukovnik" , STR_TO_DATE("4.4.1952.", "%d.%m.%Y.") , STR_TO_DATE("1.5.2017.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 2 ),
 ( 10325 , 4 , "Lav" , "Lončar" , "Pozornik" , STR_TO_DATE("21.7.1956.", "%d.%m.%Y.") , STR_TO_DATE("20.3.2018.", "%d.%m.%Y.") , "Aktivan" , "0+" , 5 ),
 ( 10326 , 1 , "Siri" , "Kolarić" , "Pozornik" , STR_TO_DATE("1.9.1961.", "%d.%m.%Y.") , STR_TO_DATE("6.7.2020.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 2 ),
 ( 10327 , 4 , "Olga" , "Kolarić" , "Narednik" , STR_TO_DATE("18.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("27.6.1999.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 5 ),
 ( 10328 , 3 , "Denisa" , "Mikulić" , "Poručnik" , STR_TO_DATE("12.3.1961.", "%d.%m.%Y.") , STR_TO_DATE("4.2.2000.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 4 ),
 ( 10329 , 2 , "Lucijano" , "Vukelić" , "Narednik" , STR_TO_DATE("7.5.1967.", "%d.%m.%Y.") , STR_TO_DATE("25.12.2003.", "%d.%m.%Y.") , "Aktivan" , "A+" , 4 ),
 ( 10330 , 2 , "Rivka" , "Kovačić" , "Pozornik" , STR_TO_DATE("15.5.1966.", "%d.%m.%Y.") , STR_TO_DATE("1.12.2004.", "%d.%m.%Y.") , "Mrtav" , "0-" , 2 ),
 ( 10331 , 1 , "Madison" , "Petković" , "Razvodnik" , STR_TO_DATE("5.7.1959.", "%d.%m.%Y.") , STR_TO_DATE("13.5.2006.", "%d.%m.%Y.") , "Aktivan" , "B-" , 2 ),
 ( 10332 , 1 , "Aida" , "Bilić" , "Pozornik" , STR_TO_DATE("8.5.1961.", "%d.%m.%Y.") , STR_TO_DATE("10.8.2013.", "%d.%m.%Y.") , "Mrtav" , "0+" , 2 ),
 ( 10333 , 2 , "Julijan" , "Jurić" , "Poručnik" , STR_TO_DATE("25.9.1954.", "%d.%m.%Y.") , STR_TO_DATE("11.11.1991.", "%d.%m.%Y.") , "Aktivan" , "0+" , 1 ),
 ( 10334 , 4 , "Florenca" , "Klarić" , "Razvodnik" , STR_TO_DATE("26.4.1950.", "%d.%m.%Y.") , STR_TO_DATE("25.6.2003.", "%d.%m.%Y.") , "Mrtav" , "B-" , 1 ),
 ( 10335 , 2 , "Ada" , "Grgurić" , "Razvodnik" , STR_TO_DATE("15.12.1956.", "%d.%m.%Y.") , STR_TO_DATE("20.2.2018.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 2 ),
 ( 10336 , 2 , "Greta" , "Bilić" , "Poručnik" , STR_TO_DATE("14.1.1964.", "%d.%m.%Y.") , STR_TO_DATE("31.8.1991.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 3 ),
 ( 10337 , 3 , "Alea" , "Barišić" , "Poručnik" , STR_TO_DATE("29.10.1959.", "%d.%m.%Y.") , STR_TO_DATE("26.6.2017.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 4 ),
 ( 10338 , 1 , "Kina" , "Kralj" , "Skupnik" , STR_TO_DATE("2.2.1963.", "%d.%m.%Y.") , STR_TO_DATE("20.5.1992.", "%d.%m.%Y.") , "Mrtav" , "0-" , 3 ),
 ( 10339 , 1 , "Jolena" , "Novaković" , "Bojnik" , STR_TO_DATE("1.1.1957.", "%d.%m.%Y.") , STR_TO_DATE("20.1.2000.", "%d.%m.%Y.") , "Aktivan" , "A-" , 4 ),
 ( 10340 , 4 , "Margareta" , "Radić" , "Poručnik" , STR_TO_DATE("3.1.1960.", "%d.%m.%Y.") , STR_TO_DATE("22.12.2005.", "%d.%m.%Y.") , "Aktivan" , "0+" , 4 ),
 ( 10341 , 3 , "Natalija" , "Šimunović" , "Pozornik" , STR_TO_DATE("11.5.1956.", "%d.%m.%Y.") , STR_TO_DATE("23.3.1999.", "%d.%m.%Y.") , "Aktivan" , "A+" , 3 ),
 ( 10342 , 1 , "Katja" , "Grgurić" , "Narednik" , STR_TO_DATE("10.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("11.1.2008.", "%d.%m.%Y.") , "Aktivan" , "B-" , 1 ),
 ( 10343 , 3 , "Slađana" , "Kovačević" , "Razvodnik" , STR_TO_DATE("24.2.1964.", "%d.%m.%Y.") , STR_TO_DATE("1.12.1992.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 2 ),
 ( 10344 , 1 , "Leksi" , "Janković" , "Brigadir" , STR_TO_DATE("18.3.1962.", "%d.%m.%Y.") , STR_TO_DATE("27.12.1996.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 2 ),
 ( 10345 , 2 , "Pavel" , "Popović" , "Narednik" , STR_TO_DATE("16.6.1956.", "%d.%m.%Y.") , STR_TO_DATE("13.10.2016.", "%d.%m.%Y.") , "Aktivan" , "A+" , 2 ),
 ( 10346 , 2 , "Vigo" , "Božić" , "Brigadir" , STR_TO_DATE("10.4.1951.", "%d.%m.%Y.") , STR_TO_DATE("6.3.2020.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 4 ),
 ( 10347 , 3 , "Elanija" , "Kralj" , "Skupnik" , STR_TO_DATE("29.12.1958.", "%d.%m.%Y.") , STR_TO_DATE("18.4.2013.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 1 ),
 ( 10348 , 3 , "Lidija" , "Matić" , "Narednik" , STR_TO_DATE("25.12.1968.", "%d.%m.%Y.") , STR_TO_DATE("2.6.1995.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 2 ),
 ( 10349 , 1 , "Etna" , "Barišić" , "Poručnik" , STR_TO_DATE("12.10.1951.", "%d.%m.%Y.") , STR_TO_DATE("20.8.2007.", "%d.%m.%Y.") , "Aktivan" , "A-" , 4 ),
 ( 10350 , 1 , "Filipa" , "Pavlić" , "Pozornik" , STR_TO_DATE("6.8.1956.", "%d.%m.%Y.") , STR_TO_DATE("9.1.2017.", "%d.%m.%Y.") , "Aktivan" , "B+" , 4 ),
 ( 10351 , 4 , "Tončica" , "Dragičević" , "Brigadir" , STR_TO_DATE("21.11.1969.", "%d.%m.%Y.") , STR_TO_DATE("28.4.2010.", "%d.%m.%Y.") , "Mrtav" , "0+" , 4 ),
 ( 10352 , 1 , "Ljudevit" , "Crnković" , "Bojnik" , STR_TO_DATE("8.3.1968.", "%d.%m.%Y.") , STR_TO_DATE("28.2.1998.", "%d.%m.%Y.") , "Aktivan" , "B+" , 1 ),
 ( 10353 , 4 , "Andrija" , "Vukelić" , "Satnik" , STR_TO_DATE("26.3.1961.", "%d.%m.%Y.") , STR_TO_DATE("29.5.2011.", "%d.%m.%Y.") , "Mrtav" , "A-" , 3 ),
 ( 10354 , 4 , "Romea" , "Šimunić" , "Pozornik" , STR_TO_DATE("22.8.1954.", "%d.%m.%Y.") , STR_TO_DATE("25.4.1994.", "%d.%m.%Y.") , "Mrtav" , "B-" , 1 ),
 ( 10355 , 2 , "Slaven" , "Đurić" , "Brigadir" , STR_TO_DATE("26.10.1969.", "%d.%m.%Y.") , STR_TO_DATE("29.5.2017.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 1 ),
 ( 10356 , 4 , "Agata" , "Filipović" , "Skupnik" , STR_TO_DATE("11.3.1954.", "%d.%m.%Y.") , STR_TO_DATE("29.6.1991.", "%d.%m.%Y.") , "Mrtav" , "B-" , 4 ),
 ( 10357 , 4 , "Rea" , "Kralj" , "Skupnik" , STR_TO_DATE("2.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("20.1.2000.", "%d.%m.%Y.") , "Aktivan" , "A-" , 4 ),
 ( 10358 , 3 , "Daniel" , "Đurić" , "Skupnik" , STR_TO_DATE("18.2.1952.", "%d.%m.%Y.") , STR_TO_DATE("26.7.1993.", "%d.%m.%Y.") , "Aktivan" , "A+" , 3 ),
 ( 10359 , 2 , "Matej" , "Burić" , "Poručnik" , STR_TO_DATE("18.3.1954.", "%d.%m.%Y.") , STR_TO_DATE("3.12.1998.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 3 ),
 ( 10360 , 2 , "Željkica" , "Abramović" , "Poručnik" , STR_TO_DATE("10.2.1968.", "%d.%m.%Y.") , STR_TO_DATE("30.6.2000.", "%d.%m.%Y.") , "Mrtav" , "A-" , 3 ),
 ( 10361 , 3 , "Beata" , "Novak" , "Brigadir" , STR_TO_DATE("23.9.1957.", "%d.%m.%Y.") , STR_TO_DATE("13.6.1991.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 2 ),
 ( 10362 , 1 , "Elora" , "Jurković" , "Narednik" , STR_TO_DATE("18.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("24.9.1998.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 3 ),
 ( 10363 , 1 , "Koa" , "Matković" , "Bojnik" , STR_TO_DATE("4.1.1951.", "%d.%m.%Y.") , STR_TO_DATE("2.1.2009.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 3 ),
 ( 10364 , 3 , "Parka" , "Šarić" , "Bojnik" , STR_TO_DATE("23.10.1967.", "%d.%m.%Y.") , STR_TO_DATE("18.7.2016.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 1 ),
 ( 10365 , 3 , "Judita" , "Burić" , "Pukovnik" , STR_TO_DATE("25.4.1952.", "%d.%m.%Y.") , STR_TO_DATE("12.6.1992.", "%d.%m.%Y.") , "Mrtav" , "0+" , 3 ),
 ( 10366 , 2 , "Ofelia" , "Horvat" , "Poručnik" , STR_TO_DATE("18.3.1961.", "%d.%m.%Y.") , STR_TO_DATE("13.3.2005.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 3 ),
 ( 10367 , 1 , "Noel" , "Blažević" , "Skupnik" , STR_TO_DATE("28.2.1959.", "%d.%m.%Y.") , STR_TO_DATE("6.8.2002.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 2 ),
 ( 10368 , 3 , "Malija" , "Miletić" , "Bojnik" , STR_TO_DATE("12.8.1967.", "%d.%m.%Y.") , STR_TO_DATE("29.7.2006.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 2 ),
 ( 10369 , 1 , "Igor" , "Lovrić" , "Pozornik" , STR_TO_DATE("15.6.1957.", "%d.%m.%Y.") , STR_TO_DATE("13.7.2000.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 2 ),
 ( 10370 , 4 , "Sofija" , "Bošnjak" , "Bojnik" , STR_TO_DATE("3.6.1954.", "%d.%m.%Y.") , STR_TO_DATE("10.7.2019.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 1 ),
 ( 10371 , 1 , "Alesia" , "Burić" , "Brigadir" , STR_TO_DATE("20.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("26.5.2011.", "%d.%m.%Y.") , "Mrtav" , "A+" , 4 ),
 ( 10372 , 2 , "Saša" , "Antunović" , "Satnik" , STR_TO_DATE("14.11.1961.", "%d.%m.%Y.") , STR_TO_DATE("7.10.2009.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 5 ),
 ( 10373 , 4 , "Igor" , "Jurčević" , "Bojnik" , STR_TO_DATE("4.6.1966.", "%d.%m.%Y.") , STR_TO_DATE("10.7.2004.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 4 ),
 ( 10374 , 2 , "Lili" , "Golubić" , "Razvodnik" , STR_TO_DATE("15.1.1950.", "%d.%m.%Y.") , STR_TO_DATE("12.5.2002.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 5 ),
 ( 10375 , 2 , "Filip" , "Kovač" , "Razvodnik" , STR_TO_DATE("15.7.1959.", "%d.%m.%Y.") , STR_TO_DATE("9.7.2002.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 1 ),
 ( 10376 , 3 , "Cecilija" , "Babić" , "Pozornik" , STR_TO_DATE("11.8.1958.", "%d.%m.%Y.") , STR_TO_DATE("6.12.1999.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 5 ),
 ( 10377 , 3 , "Pavao" , "Đurić" , "Brigadir" , STR_TO_DATE("5.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("19.3.2011.", "%d.%m.%Y.") , "Aktivan" , "A+" , 1 ),
 ( 10378 , 3 , "Elizabeta" , "Babić" , "Pozornik" , STR_TO_DATE("27.4.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2009.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 1 ),
 ( 10379 , 3 , "Paisa" , "Klarić" , "Pukovnik" , STR_TO_DATE("24.5.1965.", "%d.%m.%Y.") , STR_TO_DATE("26.3.2004.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 4 ),
 ( 10380 , 3 , "Ema" , "Vučković" , "Satnik" , STR_TO_DATE("6.8.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.11.2000.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 5 ),
 ( 10381 , 3 , "Zoja" , "Brajković" , "Pozornik" , STR_TO_DATE("10.7.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.6.2012.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 2 ),
 ( 10382 , 1 , "Melkiot" , "Šarić" , "Brigadir" , STR_TO_DATE("20.1.1951.", "%d.%m.%Y.") , STR_TO_DATE("6.8.2017.", "%d.%m.%Y.") , "Mrtav" , "B-" , 3 ),
 ( 10383 , 1 , "Rina" , "Vukelić" , "Razvodnik" , STR_TO_DATE("14.12.1962.", "%d.%m.%Y.") , STR_TO_DATE("21.4.2015.", "%d.%m.%Y.") , "Mrtav" , "0-" , 5 ),
 ( 10384 , 4 , "Roberta" , "Matković" , "Poručnik" , STR_TO_DATE("3.1.1967.", "%d.%m.%Y.") , STR_TO_DATE("25.10.2000.", "%d.%m.%Y.") , "Mrtav" , "A+" , 4 ),
 ( 10385 , 2 , "Gloria" , "Šimunović" , "Bojnik" , STR_TO_DATE("20.2.1963.", "%d.%m.%Y.") , STR_TO_DATE("18.1.2001.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 2 ),
 ( 10386 , 4 , "Elivija" , "Mitrović" , "Skupnik" , STR_TO_DATE("8.11.1956.", "%d.%m.%Y.") , STR_TO_DATE("18.2.2011.", "%d.%m.%Y.") , "Aktivan" , "A+" , 5 ),
 ( 10387 , 2 , "Bela" , "Janković" , "Pozornik" , STR_TO_DATE("28.7.1961.", "%d.%m.%Y.") , STR_TO_DATE("12.7.2016.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 3 ),
 ( 10388 , 3 , "Šimun" , "Burić" , "Razvodnik" , STR_TO_DATE("1.7.1951.", "%d.%m.%Y.") , STR_TO_DATE("11.12.2014.", "%d.%m.%Y.") , "Aktivan" , "A-" , 1 ),
 ( 10389 , 3 , "Izak" , "Marković" , "Skupnik" , STR_TO_DATE("20.4.1960.", "%d.%m.%Y.") , STR_TO_DATE("18.3.2011.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 1 ),
 ( 10390 , 1 , "Princa" , "Vukelić" , "Bojnik" , STR_TO_DATE("31.10.1958.", "%d.%m.%Y.") , STR_TO_DATE("15.5.2010.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 5 ),
 ( 10391 , 1 , "Lukas" , "Vučković" , "Bojnik" , STR_TO_DATE("9.3.1969.", "%d.%m.%Y.") , STR_TO_DATE("1.4.2007.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 3 ),
 ( 10392 , 1 , "Stjepan" , "Barišić" , "Brigadir" , STR_TO_DATE("6.2.1954.", "%d.%m.%Y.") , STR_TO_DATE("30.6.1995.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 1 ),
 ( 10393 , 2 , "Valerija" , "Petrović" , "Skupnik" , STR_TO_DATE("17.7.1965.", "%d.%m.%Y.") , STR_TO_DATE("14.1.2016.", "%d.%m.%Y.") , "Mrtav" , "0-" , 1 ),
 ( 10394 , 2 , "Marcel" , "Novosel" , "Narednik" , STR_TO_DATE("6.3.1965.", "%d.%m.%Y.") , STR_TO_DATE("12.10.2000.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 4 ),
 ( 10395 , 4 , "Lora" , "Šimunić" , "Brigadir" , STR_TO_DATE("15.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("29.3.2009.", "%d.%m.%Y.") , "Aktivan" , "0+" , 1 ),
 ( 10396 , 2 , "Samuel" , "Posavec" , "Narednik" , STR_TO_DATE("21.5.1967.", "%d.%m.%Y.") , STR_TO_DATE("19.1.2012.", "%d.%m.%Y.") , "Aktivan" , "A+" , 1 ),
 ( 10397 , 2 , "Lea" , "Šarić" , "Pozornik" , STR_TO_DATE("26.3.1955.", "%d.%m.%Y.") , STR_TO_DATE("3.4.2005.", "%d.%m.%Y.") , "Mrtav" , "A+" , 4 ),
 ( 10398 , 3 , "Michelle" , "Lončar" , "Razvodnik" , STR_TO_DATE("26.9.1966.", "%d.%m.%Y.") , STR_TO_DATE("26.2.2019.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 2 ),
 ( 10399 , 1 , "Antonija" , "Kovačić" , "Skupnik" , STR_TO_DATE("18.10.1965.", "%d.%m.%Y.") , STR_TO_DATE("14.1.2000.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 3 ),
 ( 10400 , 2 , "Mirna" , "Vidović" , "Satnik" , STR_TO_DATE("11.5.1953.", "%d.%m.%Y.") , STR_TO_DATE("7.7.1992.", "%d.%m.%Y.") , "Mrtav" , "A+" , 4 ),
 ( 10401 , 3 , "Ivano" , "Matijević" , "Bojnik" , STR_TO_DATE("24.1.1965.", "%d.%m.%Y.") , STR_TO_DATE("23.12.2012.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 2 ),
 ( 10402 , 4 , "Dragutin" , "Đurđević" , "Brigadir" , STR_TO_DATE("10.6.1954.", "%d.%m.%Y.") , STR_TO_DATE("30.12.2015.", "%d.%m.%Y.") , "Aktivan" , "B-" , 1 ),
 ( 10403 , 4 , "Klementina" , "Martinović" , "Poručnik" , STR_TO_DATE("23.1.1950.", "%d.%m.%Y.") , STR_TO_DATE("5.12.2001.", "%d.%m.%Y.") , "Mrtav" , "A+" , 4 ),
 ( 10404 , 1 , "Nevena" , "Vidaković" , "Pozornik" , STR_TO_DATE("14.8.1964.", "%d.%m.%Y.") , STR_TO_DATE("6.1.2019.", "%d.%m.%Y.") , "Aktivan" , "0+" , 3 ),
 ( 10405 , 4 , "Josipa" , "Perić" , "Bojnik" , STR_TO_DATE("4.8.1957.", "%d.%m.%Y.") , STR_TO_DATE("8.2.2018.", "%d.%m.%Y.") , "Mrtav" , "0-" , 5 ),
 ( 10406 , 2 , "Lilia" , "Jurišić" , "Pukovnik" , STR_TO_DATE("22.1.1959.", "%d.%m.%Y.") , STR_TO_DATE("22.1.1993.", "%d.%m.%Y.") , "Aktivan" , "0+" , 5 ),
 ( 10407 , 1 , "Madison" , "Jakovljević" , "Narednik" , STR_TO_DATE("15.12.1965.", "%d.%m.%Y.") , STR_TO_DATE("19.6.2005.", "%d.%m.%Y.") , "Aktivan" , "B-" , 5 ),
 ( 10408 , 2 , "Valentin" , "Radić" , "Bojnik" , STR_TO_DATE("25.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("17.5.2006.", "%d.%m.%Y.") , "Aktivan" , "A+" , 4 ),
 ( 10409 , 1 , "David" , "Sever" , "Satnik" , STR_TO_DATE("18.9.1953.", "%d.%m.%Y.") , STR_TO_DATE("10.8.1998.", "%d.%m.%Y.") , "Aktivan" , "0+" , 1 ),
 ( 10410 , 1 , "Lea" , "Vrdoljak" , "Skupnik" , STR_TO_DATE("11.6.1953.", "%d.%m.%Y.") , STR_TO_DATE("29.8.1994.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 1 ),
 ( 10411 , 4 , "Olja" , "Novosel" , "Brigadir" , STR_TO_DATE("30.4.1956.", "%d.%m.%Y.") , STR_TO_DATE("5.9.2009.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 1 ),
 ( 10412 , 1 , "Zola" , "Babić" , "Bojnik" , STR_TO_DATE("27.5.1959.", "%d.%m.%Y.") , STR_TO_DATE("29.5.2014.", "%d.%m.%Y.") , "Aktivan" , "A+" , 2 ),
 ( 10413 , 1 , "Siena" , "Josipović" , "Poručnik" , STR_TO_DATE("9.8.1960.", "%d.%m.%Y.") , STR_TO_DATE("13.9.1992.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 3 ),
 ( 10414 , 1 , "Emil" , "Novaković" , "Bojnik" , STR_TO_DATE("28.7.1958.", "%d.%m.%Y.") , STR_TO_DATE("11.8.2003.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 3 ),
 ( 10415 , 3 , "Savana" , "Lončar" , "Skupnik" , STR_TO_DATE("19.5.1963.", "%d.%m.%Y.") , STR_TO_DATE("11.7.1997.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 3 ),
 ( 10416 , 3 , "Ramona" , "Vidaković" , "Satnik" , STR_TO_DATE("5.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("4.2.2018.", "%d.%m.%Y.") , "Mrtav" , "B-" , 2 ),
 ( 10417 , 2 , "Krista" , "Butković" , "Poručnik" , STR_TO_DATE("2.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("25.11.2008.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 5 ),
 ( 10418 , 4 , "Goranka" , "Blažević" , "Pozornik" , STR_TO_DATE("5.9.1953.", "%d.%m.%Y.") , STR_TO_DATE("26.1.1991.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 3 ),
 ( 10419 , 2 , "Krešimir" , "Đurić" , "Pukovnik" , STR_TO_DATE("12.7.1965.", "%d.%m.%Y.") , STR_TO_DATE("2.1.2003.", "%d.%m.%Y.") , "Mrtav" , "B+" , 4 ),
 ( 10420 , 1 , "Jura" , "Butković" , "Poručnik" , STR_TO_DATE("14.1.1954.", "%d.%m.%Y.") , STR_TO_DATE("3.5.2002.", "%d.%m.%Y.") , "Umirovljen" , "AB-" , 1 ),
 ( 10421 , 4 , "Dora" , "Grgić" , "Razvodnik" , STR_TO_DATE("1.7.1951.", "%d.%m.%Y.") , STR_TO_DATE("25.1.2008.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 1 ),
 ( 10422 , 2 , "Mara" , "Bošnjak" , "Narednik" , STR_TO_DATE("7.2.1953.", "%d.%m.%Y.") , STR_TO_DATE("2.8.2018.", "%d.%m.%Y.") , "Umirovljen" , "AB-" , 1 ),
 ( 10423 , 3 , "Rubika" , "Knežević" , "Pukovnik" , STR_TO_DATE("24.10.1961.", "%d.%m.%Y.") , STR_TO_DATE("22.12.2015.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 3 ),
 ( 10424 , 3 , "Dora" , "Mitrović" , "Skupnik" , STR_TO_DATE("30.3.1959.", "%d.%m.%Y.") , STR_TO_DATE("8.10.1991.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 2 ),
 ( 10425 , 3 , "Lora" , "Antunović" , "Brigadir" , STR_TO_DATE("12.12.1961.", "%d.%m.%Y.") , STR_TO_DATE("23.2.2003.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 3 ),
 ( 10426 , 3 , "Marlin" , "Pavlić" , "Skupnik" , STR_TO_DATE("15.4.1970.", "%d.%m.%Y.") , STR_TO_DATE("3.12.1998.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 5 ),
 ( 10427 , 3 , "Karina" , "Janković" , "Pukovnik" , STR_TO_DATE("4.9.1951.", "%d.%m.%Y.") , STR_TO_DATE("8.5.1999.", "%d.%m.%Y.") , "Mrtav" , "A+" , 4 ),
 ( 10428 , 4 , "Arav" , "Božić" , "Bojnik" , STR_TO_DATE("13.1.1954.", "%d.%m.%Y.") , STR_TO_DATE("11.12.2013.", "%d.%m.%Y.") , "Aktivan" , "A-" , 5 ),
 ( 10429 , 2 , "Mateo" , "Bilić" , "Razvodnik" , STR_TO_DATE("18.10.1958.", "%d.%m.%Y.") , STR_TO_DATE("4.3.2007.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 5 ),
 ( 10430 , 4 , "Aurelia" , "Blažević" , "Narednik" , STR_TO_DATE("30.4.1961.", "%d.%m.%Y.") , STR_TO_DATE("7.1.2018.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 5 ),
 ( 10431 , 4 , "Kendra" , "Ivanović" , "Pozornik" , STR_TO_DATE("29.8.1951.", "%d.%m.%Y.") , STR_TO_DATE("1.1.1997.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 5 ),
 ( 10432 , 3 , "Andrija" , "Antunović" , "Brigadir" , STR_TO_DATE("11.12.1968.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2010.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 4 ),
 ( 10433 , 2 , "Chaja" , "Mikulić" , "Brigadir" , STR_TO_DATE("7.11.1969.", "%d.%m.%Y.") , STR_TO_DATE("12.8.2000.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 3 ),
 ( 10434 , 3 , "Dunja" , "Cindrić" , "Pukovnik" , STR_TO_DATE("7.6.1952.", "%d.%m.%Y.") , STR_TO_DATE("14.3.2007.", "%d.%m.%Y.") , "Mrtav" , "0-" , 2 ),
 ( 10435 , 3 , "Dorotej" , "Ivanković" , "Skupnik" , STR_TO_DATE("6.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("23.6.2001.", "%d.%m.%Y.") , "Mrtav" , "0-" , 1 ),
 ( 10436 , 3 , "Adela" , "Ružić" , "Pukovnik" , STR_TO_DATE("15.3.1959.", "%d.%m.%Y.") , STR_TO_DATE("13.10.2003.", "%d.%m.%Y.") , "Mrtav" , "B-" , 4 ),
 ( 10437 , 2 , "Sara" , "Miletić" , "Poručnik" , STR_TO_DATE("15.5.1963.", "%d.%m.%Y.") , STR_TO_DATE("12.12.2012.", "%d.%m.%Y.") , "Mrtav" , "0-" , 4 ),
 ( 10438 , 4 , "Eta" , "Radić" , "Satnik" , STR_TO_DATE("30.11.1964.", "%d.%m.%Y.") , STR_TO_DATE("10.6.2001.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 2 ),
 ( 10439 , 2 , "Eli" , "Ivanović" , "Pozornik" , STR_TO_DATE("9.12.1964.", "%d.%m.%Y.") , STR_TO_DATE("2.7.1996.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 3 ),
 ( 10440 , 2 , "Dina" , "Vidaković" , "Pozornik" , STR_TO_DATE("26.11.1954.", "%d.%m.%Y.") , STR_TO_DATE("25.11.2000.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 2 ),
 ( 10441 , 4 , "Karolina" , "Jozić" , "Skupnik" , STR_TO_DATE("15.2.1957.", "%d.%m.%Y.") , STR_TO_DATE("27.3.2003.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 5 ),
 ( 10442 , 2 , "Patrik" , "Grgić" , "Poručnik" , STR_TO_DATE("1.2.1958.", "%d.%m.%Y.") , STR_TO_DATE("26.12.2017.", "%d.%m.%Y.") , "Mrtav" , "B+" , 4 ),
 ( 10443 , 1 , "Ljerka" , "Jurković" , "Skupnik" , STR_TO_DATE("29.7.1953.", "%d.%m.%Y.") , STR_TO_DATE("11.9.2008.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 5 ),
 ( 10444 , 4 , "Marcel" , "Posavec" , "Brigadir" , STR_TO_DATE("23.7.1959.", "%d.%m.%Y.") , STR_TO_DATE("18.11.1999.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 1 ),
 ( 10445 , 1 , "Lucija" , "Kralj" , "Bojnik" , STR_TO_DATE("23.8.1967.", "%d.%m.%Y.") , STR_TO_DATE("14.12.2010.", "%d.%m.%Y.") , "Mrtav" , "A-" , 2 ),
 ( 10446 , 1 , "Ivan" , "Šimunić" , "Bojnik" , STR_TO_DATE("3.11.1962.", "%d.%m.%Y.") , STR_TO_DATE("23.6.2001.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 1 ),
 ( 10447 , 2 , "Franciska" , "Nikolić" , "Pukovnik" , STR_TO_DATE("3.8.1962.", "%d.%m.%Y.") , STR_TO_DATE("19.4.1995.", "%d.%m.%Y.") , "Aktivan" , "B-" , 5 ),
 ( 10448 , 2 , "Rajna" , "Božić" , "Bojnik" , STR_TO_DATE("18.5.1963.", "%d.%m.%Y.") , STR_TO_DATE("3.9.2010.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 4 ),
 ( 10449 , 4 , "Mada" , "Marić" , "Bojnik" , STR_TO_DATE("17.7.1970.", "%d.%m.%Y.") , STR_TO_DATE("27.1.2005.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 3 ),
 ( 10450 , 2 , "Eva" , "Jovanović" , "Satnik" , STR_TO_DATE("7.9.1950.", "%d.%m.%Y.") , STR_TO_DATE("16.10.1993.", "%d.%m.%Y.") , "Aktivan" , "0-" , 2 ),
 ( 10451 , 2 , "Ela" , "Burić" , "Skupnik" , STR_TO_DATE("5.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("16.7.2000.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 3 ),
 ( 10452 , 1 , "Naja" , "Filipović" , "Pozornik" , STR_TO_DATE("10.12.1965.", "%d.%m.%Y.") , STR_TO_DATE("21.8.2009.", "%d.%m.%Y.") , "Mrtav" , "0+" , 2 ),
 ( 10453 , 2 , "Paisa" , "Mikulić" , "Narednik" , STR_TO_DATE("29.4.1960.", "%d.%m.%Y.") , STR_TO_DATE("20.1.2019.", "%d.%m.%Y.") , "Aktivan" , "0-" , 3 ),
 ( 10454 , 4 , "Tia" , "Rukavina" , "Narednik" , STR_TO_DATE("1.10.1952.", "%d.%m.%Y.") , STR_TO_DATE("19.6.2003.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 2 ),
 ( 10455 , 3 , "Toni" , "Blažević" , "Pozornik" , STR_TO_DATE("7.5.1969.", "%d.%m.%Y.") , STR_TO_DATE("30.9.2008.", "%d.%m.%Y.") , "Mrtav" , "0+" , 4 ),
 ( 10456 , 3 , "Tiana" , "Golubić" , "Pukovnik" , STR_TO_DATE("18.1.1956.", "%d.%m.%Y.") , STR_TO_DATE("9.7.2018.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 2 ),
 ( 10457 , 3 , "Juda" , "Ružić" , "Skupnik" , STR_TO_DATE("25.3.1963.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2014.", "%d.%m.%Y.") , "Aktivan" , "0-" , 1 ),
 ( 10458 , 2 , "Ezra" , "Rukavina" , "Bojnik" , STR_TO_DATE("3.3.1970.", "%d.%m.%Y.") , STR_TO_DATE("7.3.1992.", "%d.%m.%Y.") , "Aktivan" , "B+" , 1 ),
 ( 10459 , 4 , "Lucijano" , "Jovanović" , "Skupnik" , STR_TO_DATE("11.4.1968.", "%d.%m.%Y.") , STR_TO_DATE("21.11.2009.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 1 ),
 ( 10460 , 3 , "Karlo" , "Marjanović" , "Razvodnik" , STR_TO_DATE("24.10.1960.", "%d.%m.%Y.") , STR_TO_DATE("24.11.2015.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 1 ),
 ( 10461 , 1 , "Viktor" , "Vučković" , "Pozornik" , STR_TO_DATE("27.6.1961.", "%d.%m.%Y.") , STR_TO_DATE("24.5.1990.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 5 ),
 ( 10462 , 4 , "Anabela" , "Lončarić" , "Satnik" , STR_TO_DATE("16.8.1960.", "%d.%m.%Y.") , STR_TO_DATE("21.10.2011.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 1 ),
 ( 10463 , 3 , "Magdalena" , "Marušić" , "Pozornik" , STR_TO_DATE("15.9.1965.", "%d.%m.%Y.") , STR_TO_DATE("22.6.1995.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 5 ),
 ( 10464 , 1 , "Hara" , "Lovrić" , "Pukovnik" , STR_TO_DATE("11.6.1958.", "%d.%m.%Y.") , STR_TO_DATE("24.8.2015.", "%d.%m.%Y.") , "Aktivan" , "0+" , 1 ),
 ( 10465 , 4 , "Gabrijel" , "Mikulić" , "Razvodnik" , STR_TO_DATE("9.6.1951.", "%d.%m.%Y.") , STR_TO_DATE("21.11.1990.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 5 ),
 ( 10466 , 3 , "Moli" , "Novosel" , "Narednik" , STR_TO_DATE("4.11.1969.", "%d.%m.%Y.") , STR_TO_DATE("20.2.1991.", "%d.%m.%Y.") , "Mrtav" , "0+" , 2 ),
 ( 10467 , 3 , "Izak" , "Tomić" , "Bojnik" , STR_TO_DATE("8.8.1962.", "%d.%m.%Y.") , STR_TO_DATE("29.7.1996.", "%d.%m.%Y.") , "Umirovljen" , "AB-" , 3 ),
 ( 10468 , 1 , "Ćiril" , "Mitrović" , "Narednik" , STR_TO_DATE("18.7.1964.", "%d.%m.%Y.") , STR_TO_DATE("27.12.2015.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 1 ),
 ( 10469 , 1 , "Aden" , "Horvat" , "Narednik" , STR_TO_DATE("9.5.1958.", "%d.%m.%Y.") , STR_TO_DATE("28.3.1990.", "%d.%m.%Y.") , "Aktivan" , "0+" , 4 ),
 ( 10470 , 2 , "Briela" , "Mikulić" , "Bojnik" , STR_TO_DATE("8.3.1958.", "%d.%m.%Y.") , STR_TO_DATE("20.3.2015.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 2 ),
 ( 10471 , 3 , "Eliana" , "Crnković" , "Poručnik" , STR_TO_DATE("14.2.1953.", "%d.%m.%Y.") , STR_TO_DATE("4.10.1999.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 4 ),
 ( 10472 , 3 , "Duje" , "Marković" , "Brigadir" , STR_TO_DATE("19.11.1966.", "%d.%m.%Y.") , STR_TO_DATE("3.2.1994.", "%d.%m.%Y.") , "Aktivan" , "A+" , 5 ),
 ( 10473 , 2 , "Desa" , "Jukić" , "Pozornik" , STR_TO_DATE("5.5.1956.", "%d.%m.%Y.") , STR_TO_DATE("11.2.2015.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 2 ),
 ( 10474 , 4 , "Stjepan" , "Katić" , "Brigadir" , STR_TO_DATE("11.3.1954.", "%d.%m.%Y.") , STR_TO_DATE("18.12.2014.", "%d.%m.%Y.") , "Aktivan" , "0+" , 2 ),
 ( 10475 , 2 , "Hrvojka" , "Grubišić" , "Pukovnik" , STR_TO_DATE("21.8.1967.", "%d.%m.%Y.") , STR_TO_DATE("7.7.1992.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 2 ),
 ( 10476 , 2 , "Janko" , "Posavec" , "Razvodnik" , STR_TO_DATE("13.4.1952.", "%d.%m.%Y.") , STR_TO_DATE("12.2.2020.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 4 ),
 ( 10477 , 3 , "Krsto" , "Šimunović" , "Narednik" , STR_TO_DATE("13.10.1961.", "%d.%m.%Y.") , STR_TO_DATE("18.2.1992.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 1 ),
 ( 10478 , 1 , "Marcela" , "Kovačić" , "Razvodnik" , STR_TO_DATE("10.7.1956.", "%d.%m.%Y.") , STR_TO_DATE("24.9.1998.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 4 ),
 ( 10479 , 4 , "Elana" , "Herceg" , "Pozornik" , STR_TO_DATE("24.7.1956.", "%d.%m.%Y.") , STR_TO_DATE("5.2.1990.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 2 ),
 ( 10480 , 4 , "Jan" , "Bašić" , "Brigadir" , STR_TO_DATE("12.10.1955.", "%d.%m.%Y.") , STR_TO_DATE("27.4.1999.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 1 ),
 ( 10481 , 3 , "Roman" , "Ivančić" , "Skupnik" , STR_TO_DATE("13.10.1966.", "%d.%m.%Y.") , STR_TO_DATE("16.6.2014.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 5 ),
 ( 10482 , 2 , "Nikolina" , "Krznarić" , "Satnik" , STR_TO_DATE("12.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("26.3.2009.", "%d.%m.%Y.") , "Aktivan" , "0-" , 3 ),
 ( 10483 , 1 , "Ozren" , "Posavec" , "Poručnik" , STR_TO_DATE("21.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("23.1.2014.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 4 ),
 ( 10484 , 3 , "Nina" , "Jovanović" , "Poručnik" , STR_TO_DATE("28.5.1955.", "%d.%m.%Y.") , STR_TO_DATE("15.11.2008.", "%d.%m.%Y.") , "Aktivan" , "A+" , 2 ),
 ( 10485 , 2 , "Lejla" , "Lovrić" , "Brigadir" , STR_TO_DATE("22.9.1957.", "%d.%m.%Y.") , STR_TO_DATE("10.4.2018.", "%d.%m.%Y.") , "Aktivan" , "A+" , 5 ),
 ( 10486 , 4 , "Paisa" , "Martinović" , "Poručnik" , STR_TO_DATE("8.10.1964.", "%d.%m.%Y.") , STR_TO_DATE("5.6.2001.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 3 ),
 ( 10487 , 2 , "Slavica" , "Ivančić" , "Bojnik" , STR_TO_DATE("6.2.1963.", "%d.%m.%Y.") , STR_TO_DATE("5.3.2011.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 5 ),
 ( 10488 , 1 , "Matilda" , "Abramović" , "Pukovnik" , STR_TO_DATE("15.9.1959.", "%d.%m.%Y.") , STR_TO_DATE("1.9.2005.", "%d.%m.%Y.") , "Mrtav" , "B-" , 5 ),
 ( 10489 , 4 , "Mislav" , "Matić" , "Poručnik" , STR_TO_DATE("7.2.1957.", "%d.%m.%Y.") , STR_TO_DATE("16.12.2019.", "%d.%m.%Y.") , "Mrtav" , "B-" , 4 ),
 ( 10490 , 3 , "Mihael" , "Galić" , "Poručnik" , STR_TO_DATE("19.12.1955.", "%d.%m.%Y.") , STR_TO_DATE("20.12.2017.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 1 ),
 ( 10491 , 4 , "Julijana" , "Perić" , "Razvodnik" , STR_TO_DATE("8.5.1960.", "%d.%m.%Y.") , STR_TO_DATE("23.1.1995.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 5 ),
 ( 10492 , 3 , "Ilijana" , "Petrović" , "Pukovnik" , STR_TO_DATE("27.6.1961.", "%d.%m.%Y.") , STR_TO_DATE("8.4.2015.", "%d.%m.%Y.") , "Mrtav" , "B+" , 4 ),
 ( 10493 , 2 , "Olga" , "Petković" , "Brigadir" , STR_TO_DATE("2.6.1951.", "%d.%m.%Y.") , STR_TO_DATE("1.6.2004.", "%d.%m.%Y.") , "Aktivan" , "A+" , 5 ),
 ( 10494 , 2 , "Evona" , "Burić" , "Skupnik" , STR_TO_DATE("9.4.1959.", "%d.%m.%Y.") , STR_TO_DATE("17.3.1994.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 1 ),
 ( 10495 , 2 , "Estela" , "Posavec" , "Pozornik" , STR_TO_DATE("22.6.1959.", "%d.%m.%Y.") , STR_TO_DATE("29.9.1992.", "%d.%m.%Y.") , "Mrtav" , "B-" , 2 ),
 ( 10496 , 1 , "Rea" , "Golubić" , "Narednik" , STR_TO_DATE("29.4.1955.", "%d.%m.%Y.") , STR_TO_DATE("21.7.1990.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 1 ),
 ( 10497 , 3 , "Olga" , "Blažević" , "Brigadir" , STR_TO_DATE("28.6.1959.", "%d.%m.%Y.") , STR_TO_DATE("11.7.1991.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 5 ),
 ( 10498 , 1 , "Kila" , "Pavlić" , "Pukovnik" , STR_TO_DATE("27.11.1959.", "%d.%m.%Y.") , STR_TO_DATE("16.8.2011.", "%d.%m.%Y.") , "Aktivan" , "B+" , 5 ),
 ( 10499 , 2 , "Bruno" , "Mitrović" , "Pozornik" , STR_TO_DATE("15.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("21.8.2011.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 1 ),
 ( 10500 , 3 , "Edita" , "Jurčević" , "Brigadir" , STR_TO_DATE("3.11.1953.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2011.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 3 ),
 ( 10501 , 4 , "Anatea" , "Josipović" , "Bojnik" , STR_TO_DATE("17.12.1966.", "%d.%m.%Y.") , STR_TO_DATE("31.5.1991.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 1 ),
 ( 10502 , 4 , "Branimir" , "Lovrić" , "Poručnik" , STR_TO_DATE("10.11.1959.", "%d.%m.%Y.") , STR_TO_DATE("5.4.2001.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 4 ),
 ( 10503 , 3 , "Denis" , "Marušić" , "Narednik" , STR_TO_DATE("16.11.1965.", "%d.%m.%Y.") , STR_TO_DATE("5.11.2014.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 3 ),
 ( 10504 , 2 , "Neda" , "Grubišić" , "Brigadir" , STR_TO_DATE("27.11.1965.", "%d.%m.%Y.") , STR_TO_DATE("5.2.2004.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 4 ),
 ( 10505 , 3 , "Melani" , "Josipović" , "Pukovnik" , STR_TO_DATE("20.1.1960.", "%d.%m.%Y.") , STR_TO_DATE("30.5.2013.", "%d.%m.%Y.") , "Aktivan" , "A-" , 4 ),
 ( 10506 , 1 , "Boris" , "Matijević" , "Satnik" , STR_TO_DATE("12.7.1963.", "%d.%m.%Y.") , STR_TO_DATE("6.11.2008.", "%d.%m.%Y.") , "Aktivan" , "A-" , 1 ),
 ( 10507 , 4 , "Stefanija" , "Dragičević" , "Poručnik" , STR_TO_DATE("14.10.1952.", "%d.%m.%Y.") , STR_TO_DATE("22.11.2012.", "%d.%m.%Y.") , "Umirovljen" , "AB-",5 ),
 ( 10508 , 3 , "Eva" , "Galić" , "Razvodnik" , STR_TO_DATE("27.10.1966.", "%d.%m.%Y.") , STR_TO_DATE("27.9.2020.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 3 ),
 ( 10509 , 3 , "Hara" , "Jozić" , "Skupnik" , STR_TO_DATE("2.11.1967.", "%d.%m.%Y.") , STR_TO_DATE("11.2.1994.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 2 ),
 ( 10510 , 1 , "Kristina" , "Jurčević" , "Satnik" , STR_TO_DATE("18.9.1951.", "%d.%m.%Y.") , STR_TO_DATE("24.6.2010.", "%d.%m.%Y.") , "Aktivan" , "A-" , 5 ),
 ( 10511 , 2 , "Gabrijel" , "Lončarić" , "Bojnik" , STR_TO_DATE("5.12.1958.", "%d.%m.%Y.") , STR_TO_DATE("14.4.2002.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 3 ),
 ( 10512 , 4 , "Donat" , "Horvat" , "Skupnik" , STR_TO_DATE("8.4.1952.", "%d.%m.%Y.") , STR_TO_DATE("21.4.2013.", "%d.%m.%Y.") , "Aktivan" , "0+" , 4 ),
 ( 10513 , 1 , "Talia" , "Antunović" , "Pukovnik" , STR_TO_DATE("14.1.1965.", "%d.%m.%Y.") , STR_TO_DATE("25.6.1993.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 5 ),
 ( 10514 , 2 , "Dante" , "Ćosić" , "Satnik" , STR_TO_DATE("23.11.1954.", "%d.%m.%Y.") , STR_TO_DATE("19.12.2005.", "%d.%m.%Y.") , "Aktivan" , "A-" , 4 ),
 ( 10515 , 1 , "Lorena" , "Jurišić" , "Poručnik" , STR_TO_DATE("6.4.1965.", "%d.%m.%Y.") , STR_TO_DATE("21.3.2001.", "%d.%m.%Y.") , "Mrtav" , "B+" , 5 ),
 ( 10516 , 2 , "Siera" , "Babić" , "Satnik" , STR_TO_DATE("13.10.1960.", "%d.%m.%Y.") , STR_TO_DATE("31.5.1992.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 5 ),
 ( 10517 , 4 , "Ivan" , "Kovačević" , "Poručnik" , STR_TO_DATE("17.2.1965.", "%d.%m.%Y.") , STR_TO_DATE("5.8.1990.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 5 ),
 ( 10518 , 3 , "Dejan" , "Filipović" , "Satnik" , STR_TO_DATE("13.5.1961.", "%d.%m.%Y.") , STR_TO_DATE("28.9.1999.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 3 ),
 ( 10519 , 1 , "Karina" , "Burić" , "Poručnik" , STR_TO_DATE("25.3.1958.", "%d.%m.%Y.") , STR_TO_DATE("12.9.2012.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 4 ),
 ( 10520 , 2 , "Adriana" , "Babić" , "Brigadir" , STR_TO_DATE("27.12.1962.", "%d.%m.%Y.") , STR_TO_DATE("21.9.1996.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 1 ),
 ( 10521 , 2 , "Ermina" , "Bošnjak" , "Bojnik" , STR_TO_DATE("25.3.1963.", "%d.%m.%Y.") , STR_TO_DATE("10.8.2003.", "%d.%m.%Y.") , "Mrtav" , "0+" , 2 ),
 ( 10522 , 4 , "Maris" , "Brajković" , "Narednik" , STR_TO_DATE("12.10.1958.", "%d.%m.%Y.") , STR_TO_DATE("12.2.2005.", "%d.%m.%Y.") , "Aktivan" , "A+" , 2 ),
 ( 10523 , 2 , "Aleksandra" , "Horvat" , "Pozornik" , STR_TO_DATE("8.3.1968.", "%d.%m.%Y.") , STR_TO_DATE("22.3.2000.", "%d.%m.%Y.") , "Umirovljen" , "AB-" , 1 ),
 ( 10524 , 3 , "Aurora" , "Vuković" , "Brigadir" , STR_TO_DATE("9.2.1969.", "%d.%m.%Y.") , STR_TO_DATE("13.9.2007.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 1 ),
 ( 10525 , 4 , "Filip" , "Abramović" , "Pozornik" , STR_TO_DATE("28.6.1966.", "%d.%m.%Y.") , STR_TO_DATE("11.12.2007.", "%d.%m.%Y.") , "Aktivan" , "0-" , 4 ),
 ( 10526 , 1 , "Žak" , "Kovačić" , "Pozornik" , STR_TO_DATE("27.5.1958.", "%d.%m.%Y.") , STR_TO_DATE("20.12.2019.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 4 ),
 ( 10527 , 2 , "Khalesi" , "Nikolić" , "Brigadir" , STR_TO_DATE("16.2.1957.", "%d.%m.%Y.") , STR_TO_DATE("3.12.1995.", "%d.%m.%Y.") , "Aktivan" , "0-" , 3 ),
 ( 10528 , 4 , "Maksima" , "Jurić" , "Satnik" , STR_TO_DATE("1.2.1959.", "%d.%m.%Y.") , STR_TO_DATE("21.7.2019.", "%d.%m.%Y.") , "Mrtav" , "A+" , 4 ),
 ( 10529 , 3 , "Lobel" , "Marić" , "Pukovnik" , STR_TO_DATE("22.9.1965.", "%d.%m.%Y.") , STR_TO_DATE("17.11.2002.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 4 ),
 ( 10530 , 1 , "Maksima" , "Dujmović" , "Poručnik" , STR_TO_DATE("7.1.1956.", "%d.%m.%Y.") , STR_TO_DATE("16.12.2020.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 2 ),
 ( 10531 , 3 , "Maksim" , "Martinović" , "Razvodnik" , STR_TO_DATE("14.10.1956.", "%d.%m.%Y.") , STR_TO_DATE("1.5.2012.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 2 ),
 ( 10532 , 2 , "Adonis" , "Novak" , "Poručnik" , STR_TO_DATE("22.4.1964.", "%d.%m.%Y.") , STR_TO_DATE("29.4.1999.", "%d.%m.%Y.") , "Aktivan" , "B-" , 2 ),
 ( 10533 , 3 , "Esmeralda" , "Vidović" , "Pozornik" , STR_TO_DATE("3.10.1960.", "%d.%m.%Y.") , STR_TO_DATE("8.6.2012.", "%d.%m.%Y.") , "Aktivan" , "0-" , 5 ),
 ( 10534 , 3 , "Zakarija" , "Jurić" , "Satnik" , STR_TO_DATE("25.6.1965.", "%d.%m.%Y.") , STR_TO_DATE("28.9.2000.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 2 ),
 ( 10535 , 1 , "Lika" , "Petković" , "Skupnik" , STR_TO_DATE("3.1.1955.", "%d.%m.%Y.") , STR_TO_DATE("6.10.2000.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 3 ),
 ( 10536 , 3 , "Zarija" , "Lovrić" , "Poručnik" , STR_TO_DATE("30.11.1962.", "%d.%m.%Y.") , STR_TO_DATE("7.11.1991.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 4 ),
 ( 10537 , 4 , "Valentina" , "Tomić" , "Razvodnik" , STR_TO_DATE("4.3.1954.", "%d.%m.%Y.") , STR_TO_DATE("18.12.2005.", "%d.%m.%Y.") , "Mrtav" , "0+" , 5 ),
 ( 10538 , 3 , "Dmitar" , "Vidović" , "Poručnik" , STR_TO_DATE("30.11.1962.", "%d.%m.%Y.") , STR_TO_DATE("14.4.2006.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 1 ),
 ( 10539 , 4 , "Roman" , "Martinović" , "Bojnik" , STR_TO_DATE("7.6.1970.", "%d.%m.%Y.") , STR_TO_DATE("16.5.2006.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 1 ),
 ( 10540 , 1 , "Aleksa" , "Pavić" , "Pozornik" , STR_TO_DATE("28.6.1958.", "%d.%m.%Y.") , STR_TO_DATE("15.7.1996.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 5 ),
 ( 10541 , 4 , "Severina" , "Šimunić" , "Pozornik" , STR_TO_DATE("7.9.1960.", "%d.%m.%Y.") , STR_TO_DATE("18.2.1997.", "%d.%m.%Y.") , "Aktivan" , "B-" , 2 ),
 ( 10542 , 2 , "Aziel" , "Šarić" , "Brigadir" , STR_TO_DATE("14.12.1970.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2007.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 3 ),
 ( 10543 , 4 , "Marisol" , "Popović" , "Razvodnik" , STR_TO_DATE("16.9.1950.", "%d.%m.%Y.") , STR_TO_DATE("5.2.2015.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 5 ),
 ( 10544 , 1 , "Aria" , "Katić" , "Razvodnik" , STR_TO_DATE("26.6.1956.", "%d.%m.%Y.") , STR_TO_DATE("18.7.2000.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 3 ),
 ( 10545 , 4 , "Zoe" , "Šarić" , "Skupnik" , STR_TO_DATE("28.9.1968.", "%d.%m.%Y.") , STR_TO_DATE("14.9.1995.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 1 ),
 ( 10546 , 2 , "Sandi" , "Blažević" , "Bojnik" , STR_TO_DATE("21.3.1950.", "%d.%m.%Y.") , STR_TO_DATE("9.6.1999.", "%d.%m.%Y.") , "Mrtav" , "A-" , 4 ),
 ( 10547 , 4 , "Magda" , "Bošnjak" , "Satnik" , STR_TO_DATE("10.11.1951.", "%d.%m.%Y.") , STR_TO_DATE("23.1.2008.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 5 ),
 ( 10548 , 1 , "Šime" , "Bošnjak" , "Poručnik" , STR_TO_DATE("14.12.1959.", "%d.%m.%Y.") , STR_TO_DATE("17.3.1997.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 3 ),
 ( 10549 , 1 , "Rajna" , "Šimić" , "Pukovnik" , STR_TO_DATE("21.7.1962.", "%d.%m.%Y.") , STR_TO_DATE("23.7.1997.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 5 ),
 ( 10550 , 1 , "Marina" , "Matijević" , "Narednik" , STR_TO_DATE("29.10.1951.", "%d.%m.%Y.") , STR_TO_DATE("30.1.2003.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 3 ),
 ( 10551 , 4 , "Ognjen" , "Šimunović" , "Pukovnik" , STR_TO_DATE("30.3.1960.", "%d.%m.%Y.") , STR_TO_DATE("6.5.1990.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 3 ),
 ( 10552 , 2 , "Adelina" , "Pavić" , "Razvodnik" , STR_TO_DATE("12.11.1957.", "%d.%m.%Y.") , STR_TO_DATE("8.3.2000.", "%d.%m.%Y.") , "Aktivan" , "B+" , 3 ),
 ( 10553 , 2 , "Franka" , "Marić" , "Skupnik" , STR_TO_DATE("15.3.1969.", "%d.%m.%Y.") , STR_TO_DATE("10.10.2000.", "%d.%m.%Y.") , "Aktivan" , "A-" , 4 ),
 ( 10554 , 3 , "Jakov" , "Vuković" , "Razvodnik" , STR_TO_DATE("18.11.1964.", "%d.%m.%Y.") , STR_TO_DATE("4.7.2016.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 2 ),
 ( 10555 , 1 , "Kila" , "Posavec" , "Narednik" , STR_TO_DATE("26.2.1960.", "%d.%m.%Y.") , STR_TO_DATE("24.1.2013.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 1 ),
 ( 10556 , 4 , "Budimir" , "Mitrović" , "Narednik" , STR_TO_DATE("10.10.1969.", "%d.%m.%Y.") , STR_TO_DATE("1.3.2018.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 4 ),
 ( 10557 , 3 , "Mariam" , "Jurčević" , "Pozornik" , STR_TO_DATE("9.2.1950.", "%d.%m.%Y.") , STR_TO_DATE("29.4.2013.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 2 ),
 ( 10558 , 3 , "Iko" , "Burić" , "Skupnik" , STR_TO_DATE("16.11.1952.", "%d.%m.%Y.") , STR_TO_DATE("5.9.2012.", "%d.%m.%Y.") , "Aktivan" , "0-" , 5 ),
 ( 10559 , 2 , "Eme" , "Jelić" , "Pukovnik" , STR_TO_DATE("29.9.1961.", "%d.%m.%Y.") , STR_TO_DATE("11.3.2008.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 2 ),
 ( 10560 , 2 , "Šime" , "Babić" , "Poručnik" , STR_TO_DATE("21.6.1962.", "%d.%m.%Y.") , STR_TO_DATE("25.12.2012.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 1 ),
 ( 10561 , 2 , "Paisa" , "Ivanović" , "Bojnik" , STR_TO_DATE("21.9.1962.", "%d.%m.%Y.") , STR_TO_DATE("28.12.2012.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 1 ),
 ( 10562 , 1 , "Adrian" , "Filipović" , "Razvodnik" , STR_TO_DATE("31.7.1969.", "%d.%m.%Y.") , STR_TO_DATE("20.1.2018.", "%d.%m.%Y.") , "Mrtav" , "0-" , 4 ),
 ( 10563 , 2 , "Mikaela" , "Posavec" , "Bojnik" , STR_TO_DATE("28.7.1961.", "%d.%m.%Y.") , STR_TO_DATE("1.10.1995.", "%d.%m.%Y.") , "Mrtav" , "A+" , 2 ),
 ( 10564 , 1 , "Violeta" , "Klarić" , "Skupnik" , STR_TO_DATE("24.12.1969.", "%d.%m.%Y.") , STR_TO_DATE("6.10.2005.", "%d.%m.%Y.") , "Mrtav" , "A+" , 5 ),
 ( 10565 , 2 , "Vincent" , "Jurić" , "Razvodnik" , STR_TO_DATE("18.6.1961.", "%d.%m.%Y.") , STR_TO_DATE("26.3.2019.", "%d.%m.%Y.") , "Aktivan" , "A-" , 3 ),
 ( 10566 , 2 , "Natan" , "Petrović" , "Poručnik" , STR_TO_DATE("20.2.1951.", "%d.%m.%Y.") , STR_TO_DATE("6.10.2018.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 5 ),
 ( 10567 , 1 , "Kamari" , "Bašić" , "Pukovnik" , STR_TO_DATE("21.11.1965.", "%d.%m.%Y.") , STR_TO_DATE("23.5.2011.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 4 ),
 ( 10568 , 2 , "Milena" , "Golubić" , "Satnik" , STR_TO_DATE("26.9.1966.", "%d.%m.%Y.") , STR_TO_DATE("31.1.2004.", "%d.%m.%Y.") , "Aktivan" , "0+" , 1 ),
 ( 10569 , 3 , "Franciska" , "Perković" , "Razvodnik" , STR_TO_DATE("4.10.1954.", "%d.%m.%Y.") , STR_TO_DATE("24.3.2008.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 1 ),
 ( 10570 , 3 , "Viktoria" , "Šimunić" , "Pozornik" , STR_TO_DATE("17.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("26.4.2011.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 1 ),
 ( 10571 , 2 , "Valentino" , "Jakovljević" , "Bojnik" , STR_TO_DATE("13.1.1959.", "%d.%m.%Y.") , STR_TO_DATE("27.11.2014.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 3 ),
 ( 10572 , 3 , "Pavao" , "Lončar" , "Skupnik" , STR_TO_DATE("20.4.1970.", "%d.%m.%Y.") , STR_TO_DATE("28.11.1998.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 5 ),
 ( 10573 , 4 , "Ferdinand" , "Popović" , "Bojnik" , STR_TO_DATE("31.3.1966.", "%d.%m.%Y.") , STR_TO_DATE("21.8.2019.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 1 ),
 ( 10574 , 4 , "Princa" , "Lučić" , "Skupnik" , STR_TO_DATE("30.11.1956.", "%d.%m.%Y.") , STR_TO_DATE("16.7.2009.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 1 ),
 ( 10575 , 4 , "Bonie" , "Vuković" , "Poručnik" , STR_TO_DATE("16.6.1958.", "%d.%m.%Y.") , STR_TO_DATE("26.7.2001.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 3 ),
 ( 10576 , 2 , "Paisa" , "Brkić" , "Bojnik" , STR_TO_DATE("13.2.1950.", "%d.%m.%Y.") , STR_TO_DATE("2.6.2016.", "%d.%m.%Y.") , "Mrtav" , "0-" , 2 ),
 ( 10577 , 2 , "Borisa" , "Golubić" , "Pukovnik" , STR_TO_DATE("27.11.1960.", "%d.%m.%Y.") , STR_TO_DATE("29.5.1995.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 5 ),
 ( 10578 , 3 , "Samira" , "Jurčević" , "Pozornik" , STR_TO_DATE("28.3.1957.", "%d.%m.%Y.") , STR_TO_DATE("2.4.1992.", "%d.%m.%Y.") , "Aktivan" , "A-" , 4 ),
 ( 10579 , 3 , "Krista" , "Jakovljević" , "Pukovnik" , STR_TO_DATE("17.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("16.1.1991.", "%d.%m.%Y.") , "Mrtav" , "0-" , 2 ),
 ( 10580 , 1 , "Fiona" , "Živković" , "Satnik" , STR_TO_DATE("5.2.1958.", "%d.%m.%Y.") , STR_TO_DATE("25.12.1997.", "%d.%m.%Y.") , "Mrtav" , "B+" , 1 ),
 ( 10581 , 3 , "Ita" , "Perić" , "Razvodnik" , STR_TO_DATE("20.2.1953.", "%d.%m.%Y.") , STR_TO_DATE("21.3.2007.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 5 ),
 ( 10582 , 1 , "Janko" , "Novaković" , "Pukovnik" , STR_TO_DATE("4.7.1957.", "%d.%m.%Y.") , STR_TO_DATE("28.2.1995.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 4 ),
 ( 10583 , 4 , "Tomislav" , "Dragičević" , "Narednik" , STR_TO_DATE("17.12.1964.", "%d.%m.%Y.") , STR_TO_DATE("10.3.1992.", "%d.%m.%Y.") , "Aktivan" , "0+" , 4 ),
 ( 10584 , 3 , "Princa" , "Varga" , "Bojnik" , STR_TO_DATE("5.9.1970.", "%d.%m.%Y.") , STR_TO_DATE("26.3.1997.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 4 ),
 ( 10585 , 2 , "Denisa" , "Nikolić" , "Brigadir" , STR_TO_DATE("12.1.1958.", "%d.%m.%Y.") , STR_TO_DATE("19.3.2002.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 2 ),
 ( 10586 , 3 , "Kain" , "Pavić" , "Brigadir" , STR_TO_DATE("20.3.1963.", "%d.%m.%Y.") , STR_TO_DATE("2.2.2016.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 3 ),
 ( 10587 , 3 , "Ivo" , "Bašić" , "Narednik" , STR_TO_DATE("7.10.1950.", "%d.%m.%Y.") , STR_TO_DATE("29.3.2003.", "%d.%m.%Y.") , "Mrtav" , "A-" , 3 ),
 ( 10588 , 2 , "Dora" , "Bilić" , "Pozornik" , STR_TO_DATE("19.12.1963.", "%d.%m.%Y.") , STR_TO_DATE("7.11.2005.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 1 ),
 ( 10589 , 3 , "Petra" , "Lučić" , "Narednik" , STR_TO_DATE("6.6.1957.", "%d.%m.%Y.") , STR_TO_DATE("26.8.2010.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 5 ),
 ( 10590 , 4 , "Eli" , "Burić" , "Razvodnik" , STR_TO_DATE("26.9.1952.", "%d.%m.%Y.") , STR_TO_DATE("18.11.2011.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 3 ),
 ( 10591 , 2 , "Martin" , "Ivanković" , "Pukovnik" , STR_TO_DATE("30.3.1959.", "%d.%m.%Y.") , STR_TO_DATE("1.12.2001.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 5 ),
 ( 10592 , 2 , "Klo" , "Brajković" , "Razvodnik" , STR_TO_DATE("29.7.1959.", "%d.%m.%Y.") , STR_TO_DATE("8.11.1994.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 2 ),
 ( 10593 , 4 , "Benjamin" , "Crnković" , "Narednik" , STR_TO_DATE("21.9.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.8.2007.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 4 ),
 ( 10594 , 3 , "Leonardo" , "Matković" , "Brigadir" , STR_TO_DATE("2.7.1957.", "%d.%m.%Y.") , STR_TO_DATE("23.3.1995.", "%d.%m.%Y.") , "Mrtav" , "0-" , 4 ),
 ( 10595 , 3 , "Rita" , "Posavec" , "Brigadir" , STR_TO_DATE("30.9.1967.", "%d.%m.%Y.") , STR_TO_DATE("16.5.2018.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 4 ),
 ( 10596 , 1 , "Krešimir" , "Babić" , "Skupnik" , STR_TO_DATE("2.6.1957.", "%d.%m.%Y.") , STR_TO_DATE("30.3.2003.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 5 ),
 ( 10597 , 4 , "Franka" , "Šimić" , "Skupnik" , STR_TO_DATE("2.6.1962.", "%d.%m.%Y.") , STR_TO_DATE("31.5.1994.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 3 ),
 ( 10598 , 2 , "Tihana" , "Jozić" , "Pukovnik" , STR_TO_DATE("26.6.1968.", "%d.%m.%Y.") , STR_TO_DATE("18.1.1990.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 1 ),
 ( 10599 , 3 , "Nadia" , "Miletić" , "Narednik" , STR_TO_DATE("15.2.1965.", "%d.%m.%Y.") , STR_TO_DATE("23.9.2016.", "%d.%m.%Y.") , "Umirovljen" , "AB-" , 5 ),
 ( 10600 , 1 , "Vita" , "Filipović" , "Bojnik" , STR_TO_DATE("7.6.1964.", "%d.%m.%Y.") , STR_TO_DATE("18.12.1999.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 3 ),
 ( 10601 , 4 , "Ada" , "Dragičević" , "Razvodnik" , STR_TO_DATE("26.1.1950.", "%d.%m.%Y.") , STR_TO_DATE("15.2.2006.", "%d.%m.%Y.") , "Mrtav" , "A+" , 4 ),
 ( 10602 , 2 , "Korina" , "Mitrović" , "Razvodnik" , STR_TO_DATE("8.7.1955.", "%d.%m.%Y.") , STR_TO_DATE("21.11.2014.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 3 ),
 ( 10603 , 1 , "Marjan" , "Pavlović" , "Satnik" , STR_TO_DATE("25.5.1956.", "%d.%m.%Y.") , STR_TO_DATE("27.7.2016.", "%d.%m.%Y.") , "Aktivan" , "B+" , 4 ),
 ( 10604 , 1 , "Leandro" , "Šimunović" , "Bojnik" , STR_TO_DATE("1.6.1970.", "%d.%m.%Y.") , STR_TO_DATE("16.12.1997.", "%d.%m.%Y.") , "Aktivan" , "A-" , 2 ),
 ( 10605 , 3 , "Tiago" , "Đurđević" , "Poručnik" , STR_TO_DATE("26.10.1953.", "%d.%m.%Y.") , STR_TO_DATE("25.2.1999.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 3 ),
 ( 10606 , 1 , "Khalesi" , "Sever" , "Bojnik" , STR_TO_DATE("4.1.1958.", "%d.%m.%Y.") , STR_TO_DATE("17.2.1996.", "%d.%m.%Y.") , "Aktivan" , "0-" , 2 ),
 ( 10607 , 3 , "Miroslava" , "Jurčević" , "Skupnik" , STR_TO_DATE("12.7.1968.", "%d.%m.%Y.") , STR_TO_DATE("3.2.2004.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 5 ),
 ( 10608 , 3 , "Aleksandra" , "Grubišić" , "Razvodnik" , STR_TO_DATE("24.5.1964.", "%d.%m.%Y.") , STR_TO_DATE("11.7.2011.", "%d.%m.%Y.") , "Mrtav" , "B+" , 4 ),
 ( 10609 , 1 , "Dani" , "Dujmović" , "Narednik" , STR_TO_DATE("5.4.1951.", "%d.%m.%Y.") , STR_TO_DATE("4.8.2008.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 5 ),
 ( 10610 , 3 , "Elana" , "Tomić" , "Razvodnik" , STR_TO_DATE("13.1.1950.", "%d.%m.%Y.") , STR_TO_DATE("6.11.2018.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 1 ),
 ( 10611 , 1 , "Nia" , "Ivanović" , "Pukovnik" , STR_TO_DATE("9.7.1967.", "%d.%m.%Y.") , STR_TO_DATE("1.10.2013.", "%d.%m.%Y.") , "Umirovljen" , "AB-" , 5 ),
 ( 10612 , 4 , "Marcela" , "Šimunović" , "Narednik" , STR_TO_DATE("10.7.1958.", "%d.%m.%Y.") , STR_TO_DATE("1.9.1992.", "%d.%m.%Y.") , "Mrtav" , "0+" , 2 ),
 ( 10613 , 1 , "Aron" , "Vidaković" , "Satnik" , STR_TO_DATE("10.6.1960.", "%d.%m.%Y.") , STR_TO_DATE("11.11.2012.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 1 ),
 ( 10614 , 1 , "Simon" , "Martinović" , "Bojnik" , STR_TO_DATE("5.3.1963.", "%d.%m.%Y.") , STR_TO_DATE("14.3.2013.", "%d.%m.%Y.") , "Mrtav" , "A+" , 2 ),
 ( 10615 , 4 , "Rina" , "Mandić" , "Razvodnik" , STR_TO_DATE("4.10.1961.", "%d.%m.%Y.") , STR_TO_DATE("20.4.2012.", "%d.%m.%Y.") , "Aktivan" , "B+" , 5 ),
 ( 10616 , 2 , "Ivo" , "Miletić" , "Narednik" , STR_TO_DATE("26.9.1963.", "%d.%m.%Y.") , STR_TO_DATE("12.6.2004.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 3 ),
 ( 10617 , 2 , "Iris" , "Marjanović" , "Satnik" , STR_TO_DATE("13.3.1967.", "%d.%m.%Y.") , STR_TO_DATE("15.1.2003.", "%d.%m.%Y.") , "Aktivan" , "0-" , 1 ),
 ( 10618 , 2 , "Goga" , "Perković" , "Satnik" , STR_TO_DATE("28.1.1968.", "%d.%m.%Y.") , STR_TO_DATE("23.3.2006.", "%d.%m.%Y.") , "Mrtav" , "B-" , 3 ),
 ( 10619 , 4 , "Lilia" , "Živković" , "Narednik" , STR_TO_DATE("24.12.1963.", "%d.%m.%Y.") , STR_TO_DATE("24.5.2001.", "%d.%m.%Y.") , "Mrtav" , "0+" , 5 ),
 ( 10620 , 4 , "Ada" , "Grgić" , "Poručnik" , STR_TO_DATE("29.12.1956.", "%d.%m.%Y.") , STR_TO_DATE("18.2.1992.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 5 ),
 ( 10621 , 3 , "Augustin" , "Barišić" , "Narednik" , STR_TO_DATE("22.4.1959.", "%d.%m.%Y.") , STR_TO_DATE("30.9.2005.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 5 ),
 ( 10622 , 3 , "Mariam" , "Kovač" , "Pukovnik" , STR_TO_DATE("28.5.1963.", "%d.%m.%Y.") , STR_TO_DATE("20.3.2006.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 4 ),
 ( 10623 , 3 , "Sandi" , "Šimunović" , "Bojnik" , STR_TO_DATE("21.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("15.1.1995.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 1 ),
 ( 10624 , 3 , "Elena" , "Filipović" , "Pukovnik" , STR_TO_DATE("18.5.1964.", "%d.%m.%Y.") , STR_TO_DATE("19.2.2020.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 4 ),
 ( 10625 , 3 , "Aria" , "Šimunić" , "Razvodnik" , STR_TO_DATE("30.3.1950.", "%d.%m.%Y.") , STR_TO_DATE("11.10.2014.", "%d.%m.%Y.") , "Umirovljen" , "AB-" , 5 ),
 ( 10626 , 1 , "Boris" , "Josipović" , "Bojnik" , STR_TO_DATE("19.11.1950.", "%d.%m.%Y.") , STR_TO_DATE("5.6.2005.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 3 ),
 ( 10627 , 1 , "Moreno" , "Vučković" , "Pukovnik" , STR_TO_DATE("25.9.1968.", "%d.%m.%Y.") , STR_TO_DATE("22.4.2005.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 4 ),
 ( 10628 , 4 , "Remi" , "Marić" , "Brigadir" , STR_TO_DATE("2.9.1965.", "%d.%m.%Y.") , STR_TO_DATE("31.8.1994.", "%d.%m.%Y.") , "Mrtav" , "B+" , 1 ),
 ( 10629 , 3 , "Marlin" , "Marić" , "Poručnik" , STR_TO_DATE("5.8.1965.", "%d.%m.%Y.") , STR_TO_DATE("22.10.2019.", "%d.%m.%Y.") , "Mrtav" , "A-" , 4 ),
 ( 10630 , 2 , "Nova" , "Mitrović" , "Razvodnik" , STR_TO_DATE("8.10.1970.", "%d.%m.%Y.") , STR_TO_DATE("24.6.2011.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 4 ),
 ( 10631 , 1 , "Sendi" , "Đurić" , "Narednik" , STR_TO_DATE("11.3.1953.", "%d.%m.%Y.") , STR_TO_DATE("26.11.2009.", "%d.%m.%Y.") , "Mrtav" , "B-" , 1 ),
 ( 10632 , 4 , "Zakarija" , "Brkić" , "Narednik" , STR_TO_DATE("28.2.1970.", "%d.%m.%Y.") , STR_TO_DATE("2.7.2014.", "%d.%m.%Y.") , "Aktivan" , "B-" , 4 ),
 ( 10633 , 1 , "Martea" , "Stanić" , "Narednik" , STR_TO_DATE("4.9.1952.", "%d.%m.%Y.") , STR_TO_DATE("13.7.2009.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 5 ),
 ( 10634 , 3 , "Kira" , "Petrović" , "Razvodnik" , STR_TO_DATE("4.3.1956.", "%d.%m.%Y.") , STR_TO_DATE("9.11.2015.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 2 ),
 ( 10635 , 2 , "Liv" , "Blažević" , "Brigadir" , STR_TO_DATE("25.6.1963.", "%d.%m.%Y.") , STR_TO_DATE("31.1.2003.", "%d.%m.%Y.") , "Aktivan" , "0-" , 4 ),
 ( 10636 , 1 , "Amaris" , "Ćosić" , "Razvodnik" , STR_TO_DATE("12.6.1953.", "%d.%m.%Y.") , STR_TO_DATE("16.10.2000.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 4 ),
 ( 10637 , 1 , "Edita" , "Klarić" , "Narednik" , STR_TO_DATE("23.1.1964.", "%d.%m.%Y.") , STR_TO_DATE("6.3.2015.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 5 ),
 ( 10638 , 1 , "Slavica" , "Matijević" , "Narednik" , STR_TO_DATE("3.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("22.3.2018.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 5 ),
 ( 10639 , 2 , "Elaina" , "Matić" , "Razvodnik" , STR_TO_DATE("2.6.1963.", "%d.%m.%Y.") , STR_TO_DATE("11.10.1999.", "%d.%m.%Y.") , "Mrtav" , "A-" , 3 ),
 ( 10640 , 2 , "Rebeka" , "Marković" , "Brigadir" , STR_TO_DATE("16.6.1964.", "%d.%m.%Y.") , STR_TO_DATE("29.8.2016.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 5 ),
 ( 10641 , 4 , "Leona" , "Novak" , "Pukovnik" , STR_TO_DATE("3.8.1964.", "%d.%m.%Y.") , STR_TO_DATE("12.11.1995.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 4 ),
 ( 10642 , 1 , "Dajana" , "Novaković" , "Pukovnik" , STR_TO_DATE("18.2.1969.", "%d.%m.%Y.") , STR_TO_DATE("8.3.2009.", "%d.%m.%Y.") , "Aktivan" , "0+" , 5 ),
 ( 10643 , 3 , "Goran" , "Jelić" , "Skupnik" , STR_TO_DATE("27.2.1968.", "%d.%m.%Y.") , STR_TO_DATE("2.7.2008.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 5 ),
 ( 10644 , 2 , "Kali" , "Horvat" , "Skupnik" , STR_TO_DATE("27.2.1966.", "%d.%m.%Y.") , STR_TO_DATE("27.9.2000.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 3 ),
 ( 10645 , 2 , "Lea" , "Lončarić" , "Pukovnik" , STR_TO_DATE("21.1.1970.", "%d.%m.%Y.") , STR_TO_DATE("2.4.2012.", "%d.%m.%Y.") , "Aktivan" , "0-" , 4 ),
 ( 10646 , 2 , "Madelin" , "Babić" , "Skupnik" , STR_TO_DATE("24.9.1959.", "%d.%m.%Y.") , STR_TO_DATE("25.5.1990.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 1 ),
 ( 10647 , 4 , "Marcel" , "Dragičević" , "Pukovnik" , STR_TO_DATE("4.11.1956.", "%d.%m.%Y.") , STR_TO_DATE("12.5.2003.", "%d.%m.%Y.") , "Aktivan" , "A+" , 2 ),
 ( 10648 , 1 , "Kai" , "Antunović" , "Poručnik" , STR_TO_DATE("21.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("30.4.2013.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 4 ),
 ( 10649 , 4 , "Samira" , "Janković" , "Satnik" , STR_TO_DATE("16.6.1960.", "%d.%m.%Y.") , STR_TO_DATE("10.7.1999.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 4 ),
 ( 10650 , 1 , "Brigita" , "Lovrić" , "Pukovnik" , STR_TO_DATE("16.4.1955.", "%d.%m.%Y.") , STR_TO_DATE("10.5.1994.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 2 ),
 ( 10651 , 2 , "Elena" , "Brkić" , "Pozornik" , STR_TO_DATE("27.3.1960.", "%d.%m.%Y.") , STR_TO_DATE("18.4.2014.", "%d.%m.%Y.") , "Mrtav" , "B-" , 2 ),
 ( 10652 , 2 , "Lilika" , "Kovač" , "Brigadir" , STR_TO_DATE("13.8.1954.", "%d.%m.%Y.") , STR_TO_DATE("22.11.2006.", "%d.%m.%Y.") , "Aktivan" , "A+" , 2 ),
 ( 10653 , 1 , "Gustav" , "Perić" , "Narednik" , STR_TO_DATE("24.2.1950.", "%d.%m.%Y.") , STR_TO_DATE("9.8.1990.", "%d.%m.%Y.") , "Mrtav" , "0+" , 2 ),
 ( 10654 , 2 , "Vanesa" , "Jozić" , "Pozornik" , STR_TO_DATE("15.11.1959.", "%d.%m.%Y.") , STR_TO_DATE("8.12.2010.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 2 ),
 ( 10655 , 4 , "Mariam" , "Cindrić" , "Satnik" , STR_TO_DATE("28.9.1959.", "%d.%m.%Y.") , STR_TO_DATE("1.5.2005.", "%d.%m.%Y.") , "Mrtav" , "A+" , 4 ),
 ( 10656 , 2 , "Jakov" , "Vuković" , "Brigadir" , STR_TO_DATE("17.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("23.2.2000.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 3 ),
 ( 10657 , 1 , "Hai" , "Horvat" , "Pozornik" , STR_TO_DATE("17.12.1951.", "%d.%m.%Y.") , STR_TO_DATE("1.3.2002.", "%d.%m.%Y.") , "Mrtav" , "A-" , 4 ),
 ( 10658 , 4 , "Anamarija" , "Jurčević" , "Narednik" , STR_TO_DATE("31.3.1962.", "%d.%m.%Y.") , STR_TO_DATE("13.5.1995.", "%d.%m.%Y.") , "Mrtav" , "B+" , 3 ),
 ( 10659 , 1 , "Gisela" , "Perić" , "Brigadir" , STR_TO_DATE("25.10.1969.", "%d.%m.%Y.") , STR_TO_DATE("5.10.2019.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 4 ),
 ( 10660 , 3 , "Toni" , "Popović" , "Poručnik" , STR_TO_DATE("12.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("16.1.2019.", "%d.%m.%Y.") , "Umirovljen" , "AB-" , 3 ),
 ( 10661 , 2 , "Sebastijan" , "Brkić" , "Narednik" , STR_TO_DATE("20.8.1960.", "%d.%m.%Y.") , STR_TO_DATE("10.10.2005.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 1 ),
 ( 10662 , 3 , "Maris" , "Krznarić" , "Poručnik" , STR_TO_DATE("16.8.1961.", "%d.%m.%Y.") , STR_TO_DATE("14.3.1991.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 2 ),
 ( 10663 , 1 , "Franciska" , "Nikolić" , "Satnik" , STR_TO_DATE("20.4.1961.", "%d.%m.%Y.") , STR_TO_DATE("28.1.2019.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 5 ),
 ( 10664 , 4 , "Rajna" , "Matić" , "Pukovnik" , STR_TO_DATE("22.10.1950.", "%d.%m.%Y.") , STR_TO_DATE("10.10.1994.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 2 ),
 ( 10665 , 3 , "Evica" , "Vidaković" , "Skupnik" , STR_TO_DATE("9.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("1.12.2004.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 2 ),
 ( 10666 , 1 , "Elena" , "Kovačević" , "Pozornik" , STR_TO_DATE("24.8.1953.", "%d.%m.%Y.") , STR_TO_DATE("29.9.1991.", "%d.%m.%Y.") , "Aktivan" , "A-" , 1 ),
 ( 10667 , 3 , "Dajana" , "Krznarić" , "Poručnik" , STR_TO_DATE("13.9.1957.", "%d.%m.%Y.") , STR_TO_DATE("22.9.2002.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 1 ),
 ( 10668 , 1 , "Oliver" , "Jurić" , "Razvodnik" , STR_TO_DATE("30.11.1959.", "%d.%m.%Y.") , STR_TO_DATE("9.10.1993.", "%d.%m.%Y.") , "Aktivan" , "A+" , 3 ),
 ( 10669 , 1 , "Leo" , "Posavec" , "Pukovnik" , STR_TO_DATE("17.2.1956.", "%d.%m.%Y.") , STR_TO_DATE("16.5.1990.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 5 ),
 ( 10670 , 1 , "Stela" , "Sever" , "Pukovnik" , STR_TO_DATE("25.7.1966.", "%d.%m.%Y.") , STR_TO_DATE("9.2.1995.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 5 ),
 ( 10671 , 3 , "Lenon" , "Pavlović" , "Brigadir" , STR_TO_DATE("21.11.1954.", "%d.%m.%Y.") , STR_TO_DATE("7.4.1998.", "%d.%m.%Y.") , "Mrtav" , "0-" , 1 ),
 ( 10672 , 4 , "Dana" , "Radić" , "Satnik" , STR_TO_DATE("30.4.1955.", "%d.%m.%Y.") , STR_TO_DATE("9.9.2004.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 4 ),
 ( 10673 , 4 , "Rea" , "Jurišić" , "Bojnik" , STR_TO_DATE("30.6.1952.", "%d.%m.%Y.") , STR_TO_DATE("23.6.1996.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 5 ),
 ( 10674 , 1 , "Dajana" , "Vrdoljak" , "Skupnik" , STR_TO_DATE("16.8.1967.", "%d.%m.%Y.") , STR_TO_DATE("8.2.2001.", "%d.%m.%Y.") , "Aktivan" , "A-" , 5 ),
 ( 10675 , 3 , "Mauro" , "Rukavina" , "Poručnik" , STR_TO_DATE("26.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("29.10.2014.", "%d.%m.%Y.") , "Aktivan" , "0+" , 3 ),
 ( 10676 , 4 , "Isla" , "Grgurić" , "Bojnik" , STR_TO_DATE("8.8.1962.", "%d.%m.%Y.") , STR_TO_DATE("22.6.2011.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 3 ),
 ( 10677 , 1 , "Dario" , "Lončarić" , "Skupnik" , STR_TO_DATE("9.12.1951.", "%d.%m.%Y.") , STR_TO_DATE("7.5.1996.", "%d.%m.%Y.") , "Aktivan" , "B-" , 1 ),
 ( 10678 , 1 , "Rosalia" , "Radić" , "Pukovnik" , STR_TO_DATE("20.6.1965.", "%d.%m.%Y.") , STR_TO_DATE("1.1.2002.", "%d.%m.%Y.") , "Mrtav" , "B-" , 5 ),
 ( 10679 , 3 , "Branimir" , "Babić" , "Pukovnik" , STR_TO_DATE("16.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("29.3.2011.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 5 ),
 ( 10680 , 2 , "Dalia" , "Burić" , "Razvodnik" , STR_TO_DATE("14.12.1963.", "%d.%m.%Y.") , STR_TO_DATE("29.4.2012.", "%d.%m.%Y.") , "Aktivan" , "B-" , 3 ),
 ( 10681 , 4 , "Lilika" , "Kolarić" , "Pozornik" , STR_TO_DATE("5.10.1967.", "%d.%m.%Y.") , STR_TO_DATE("14.3.2007.", "%d.%m.%Y.") , "Mrtav" , "B-" , 4 ),
 ( 10682 , 4 , "Elivija" , "Ružić" , "Pukovnik" , STR_TO_DATE("17.12.1959.", "%d.%m.%Y.") , STR_TO_DATE("11.8.2004.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 4 ),
 ( 10683 , 2 , "Viktor" , "Crnković" , "Razvodnik" , STR_TO_DATE("10.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("18.12.2002.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 1 ),
 ( 10684 , 1 , "Niko" , "Ivanković" , "Skupnik" , STR_TO_DATE("20.12.1970.", "%d.%m.%Y.") , STR_TO_DATE("18.11.2002.", "%d.%m.%Y.") , "Aktivan" , "B-" , 1 ),
 ( 10685 , 4 , "Natalija" , "Antunović" , "Narednik" , STR_TO_DATE("11.7.1967.", "%d.%m.%Y.") , STR_TO_DATE("10.11.1995.", "%d.%m.%Y.") , "Aktivan" , "A+" , 3 ),
 ( 10686 , 3 , "Ben" , "Perković" , "Satnik" , STR_TO_DATE("13.11.1958.", "%d.%m.%Y.") , STR_TO_DATE("11.5.1995.", "%d.%m.%Y.") , "Aktivan" , "0+" , 5 ),
 ( 10687 , 3 , "Melkiot" , "Pavlić" , "Pozornik" , STR_TO_DATE("28.11.1959.", "%d.%m.%Y.") , STR_TO_DATE("8.9.2000.", "%d.%m.%Y.") , "Mrtav" , "B-" , 4 ),
 ( 10688 , 2 , "Vito" , "Jukić" , "Pukovnik" , STR_TO_DATE("11.10.1960.", "%d.%m.%Y.") , STR_TO_DATE("9.10.2001.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 2 ),
 ( 10689 , 2 , "Katarina" , "Lončar" , "Poručnik" , STR_TO_DATE("15.12.1969.", "%d.%m.%Y.") , STR_TO_DATE("31.3.1996.", "%d.%m.%Y.") , "Aktivan" , "A+" , 5 ),
 ( 10690 , 1 , "Viktor" , "Ivančić" , "Brigadir" , STR_TO_DATE("7.5.1966.", "%d.%m.%Y.") , STR_TO_DATE("22.9.1998.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 1 ),
 ( 10691 , 1 , "Rebeka" , "Radić" , "Poručnik" , STR_TO_DATE("8.10.1960.", "%d.%m.%Y.") , STR_TO_DATE("25.1.2002.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 3 ),
 ( 10692 , 2 , "Bruno" , "Petrović" , "Narednik" , STR_TO_DATE("28.11.1951.", "%d.%m.%Y.") , STR_TO_DATE("25.3.2013.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 5 ),
 ( 10693 , 4 , "Nia" , "Stanić" , "Narednik" , STR_TO_DATE("14.3.1950.", "%d.%m.%Y.") , STR_TO_DATE("6.2.2000.", "%d.%m.%Y.") , "Aktivan" , "B-" , 4 ),
 ( 10694 , 2 , "Nives" , "Perković" , "Pukovnik" , STR_TO_DATE("24.10.1968.", "%d.%m.%Y.") , STR_TO_DATE("9.12.2020.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 5 ),
 ( 10695 , 2 , "Dani" , "Marković" , "Poručnik" , STR_TO_DATE("12.7.1965.", "%d.%m.%Y.") , STR_TO_DATE("21.11.2000.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 2 ),
 ( 10696 , 4 , "Marisol" , "Šimić" , "Razvodnik" , STR_TO_DATE("2.2.1959.", "%d.%m.%Y.") , STR_TO_DATE("12.10.2011.", "%d.%m.%Y.") , "Aktivan" , "0+" , 3 ),
 ( 10697 , 2 , "Estela" , "Vidović" , "Pozornik" , STR_TO_DATE("22.3.1968.", "%d.%m.%Y.") , STR_TO_DATE("25.4.2017.", "%d.%m.%Y.") , "Mrtav" , "A+" , 5 ),
 ( 10698 , 3 , "Mateo" , "Marjanović" , "Razvodnik" , STR_TO_DATE("18.6.1968.", "%d.%m.%Y.") , STR_TO_DATE("26.4.2012.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 1 ),
 ( 10699 , 3 , "Zelda" , "Sever" , "Brigadir" , STR_TO_DATE("21.7.1970.", "%d.%m.%Y.") , STR_TO_DATE("12.4.2002.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 2 ),
 ( 10700 , 1 , "Juna" , "Josipović" , "Brigadir" , STR_TO_DATE("18.8.1953.", "%d.%m.%Y.") , STR_TO_DATE("18.6.1993.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 1 ),
 ( 10701 , 2 , "Teodor" , "Pavlić" , "Poručnik" , STR_TO_DATE("18.6.1950.", "%d.%m.%Y.") , STR_TO_DATE("8.2.2004.", "%d.%m.%Y.") , "Aktivan" , "0-" , 1 ),
 ( 10702 , 4 , "Kalisa" , "Jurčević" , "Poručnik" , STR_TO_DATE("27.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("7.1.2007.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 3 ),
 ( 10703 , 1 , "Leona" , "Krznarić" , "Brigadir" , STR_TO_DATE("16.4.1959.", "%d.%m.%Y.") , STR_TO_DATE("5.11.2003.", "%d.%m.%Y.") , "Aktivan" , "0-" , 5 ),
 ( 10704 , 1 , "Ena" , "Kovač" , "Razvodnik" , STR_TO_DATE("8.7.1968.", "%d.%m.%Y.") , STR_TO_DATE("5.8.2011.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 2 ),
 ( 10705 , 2 , "Matej" , "Vidović" , "Poručnik" , STR_TO_DATE("23.5.1950.", "%d.%m.%Y.") , STR_TO_DATE("15.9.2000.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 5 ),
 ( 10706 , 2 , "Arijana" , "Tomić" , "Pukovnik" , STR_TO_DATE("3.2.1958.", "%d.%m.%Y.") , STR_TO_DATE("22.2.2007.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 1 ),
 ( 10707 , 3 , "Nikol" , "Jurišić" , "Pozornik" , STR_TO_DATE("7.11.1954.", "%d.%m.%Y.") , STR_TO_DATE("30.6.1992.", "%d.%m.%Y.") , "Aktivan" , "A-" , 2 ),
 ( 10708 , 3 , "Krista" , "Jurišić" , "Pukovnik" , STR_TO_DATE("31.3.1963.", "%d.%m.%Y.") , STR_TO_DATE("16.3.2011.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 3 ),
 ( 10709 , 2 , "Rosalia" , "Rukavina" , "Satnik" , STR_TO_DATE("3.6.1951.", "%d.%m.%Y.") , STR_TO_DATE("30.7.1993.", "%d.%m.%Y.") , "Mrtav" , "A-" , 5 ),
 ( 10710 , 2 , "Lenon" , "Ivanović" , "Bojnik" , STR_TO_DATE("25.12.1956.", "%d.%m.%Y.") , STR_TO_DATE("24.6.2011.", "%d.%m.%Y.") , "Aktivan" , "A+" , 4 ),
 ( 10711 , 1 , "Natalija" , "Vidović" , "Razvodnik" , STR_TO_DATE("5.4.1967.", "%d.%m.%Y.") , STR_TO_DATE("7.7.2000.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 3 ),
 ( 10712 , 3 , "Željkica" , "Filipović" , "Poručnik" , STR_TO_DATE("3.12.1963.", "%d.%m.%Y.") , STR_TO_DATE("25.11.2019.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 3 ),
 ( 10713 , 4 , "Maca" , "Jozić" , "Pukovnik" , STR_TO_DATE("1.11.1957.", "%d.%m.%Y.") , STR_TO_DATE("4.1.2013.", "%d.%m.%Y.") , "Aktivan" , "0-" , 5 ),
 ( 10714 , 4 , "Moli" , "Kralj" , "Satnik" , STR_TO_DATE("11.6.1951.", "%d.%m.%Y.") , STR_TO_DATE("2.6.1993.", "%d.%m.%Y.") , "Aktivan" , "A+" , 1 ),
 ( 10715 , 3 , "Melanija" , "Šimić" , "Poručnik" , STR_TO_DATE("3.3.1951.", "%d.%m.%Y.") , STR_TO_DATE("26.10.1992.", "%d.%m.%Y.") , "Aktivan" , "B-" , 1 ),
 ( 10716 , 2 , "Milena" , "Pavić" , "Razvodnik" , STR_TO_DATE("3.1.1951.", "%d.%m.%Y.") , STR_TO_DATE("9.9.1994.", "%d.%m.%Y.") , "Mrtav" , "0+" , 1 ),
 ( 10717 , 3 , "Bria" , "Herceg" , "Razvodnik" , STR_TO_DATE("5.4.1957.", "%d.%m.%Y.") , STR_TO_DATE("31.5.2001.", "%d.%m.%Y.") , "Aktivan" , "B-" , 4 ),
 ( 10718 , 4 , "Elie" , "Petrović" , "Narednik" , STR_TO_DATE("16.10.1961.", "%d.%m.%Y.") , STR_TO_DATE("3.10.2009.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 3 ),
 ( 10719 , 4 , "Kruna" , "Marušić" , "Bojnik" , STR_TO_DATE("24.12.1950.", "%d.%m.%Y.") , STR_TO_DATE("26.4.2014.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 3 ),
 ( 10720 , 3 , "Gaj" , "Horvat" , "Poručnik" , STR_TO_DATE("22.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("28.11.2012.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 3 ),
 ( 10721 , 1 , "Nira" , "Jurković" , "Pozornik" , STR_TO_DATE("9.4.1969.", "%d.%m.%Y.") , STR_TO_DATE("21.8.2006.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 3 ),
 ( 10722 , 4 , "Harmina" , "Jurišić" , "Pukovnik" , STR_TO_DATE("17.11.1969.", "%d.%m.%Y.") , STR_TO_DATE("1.9.2002.", "%d.%m.%Y.") , "Mrtav" , "0-" , 5 ),
 ( 10723 , 4 , "Rila" , "Jurčević" , "Narednik" , STR_TO_DATE("5.3.1961.", "%d.%m.%Y.") , STR_TO_DATE("3.5.1995.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 4 ),
 ( 10724 , 1 , "Alma" , "Bašić" , "Satnik" , STR_TO_DATE("8.8.1967.", "%d.%m.%Y.") , STR_TO_DATE("10.11.1997.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 1 ),
 ( 10725 , 4 , "Marina" , "Mikulić" , "Poručnik" , STR_TO_DATE("30.4.1959.", "%d.%m.%Y.") , STR_TO_DATE("4.1.2012.", "%d.%m.%Y.") , "Aktivan" , "0+" , 2 ),
 ( 10726 , 1 , "Beatrica" , "Ružić" , "Narednik" , STR_TO_DATE("10.8.1960.", "%d.%m.%Y.") , STR_TO_DATE("1.6.2004.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 4 ),
 ( 10727 , 1 , "Rhea" , "Lovrić" , "Skupnik" , STR_TO_DATE("8.8.1950.", "%d.%m.%Y.") , STR_TO_DATE("14.8.2013.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 2 ),
 ( 10728 , 3 , "Kristian" , "Jurčević" , "Pukovnik" , STR_TO_DATE("16.12.1962.", "%d.%m.%Y.") , STR_TO_DATE("2.12.1997.", "%d.%m.%Y.") , "Aktivan" , "A-" , 3 ),
 ( 10729 , 1 , "Santino" , "Tomić" , "Skupnik" , STR_TO_DATE("4.3.1951.", "%d.%m.%Y.") , STR_TO_DATE("25.5.1999.", "%d.%m.%Y.") , "Aktivan" , "B-" , 4 ),
 ( 10730 , 3 , "Laura" , "Butković" , "Razvodnik" , STR_TO_DATE("30.9.1960.", "%d.%m.%Y.") , STR_TO_DATE("4.6.1992.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 4 ),
 ( 10731 , 1 , "Roman" , "Ivanović" , "Razvodnik" , STR_TO_DATE("2.6.1966.", "%d.%m.%Y.") , STR_TO_DATE("21.12.1990.", "%d.%m.%Y.") , "Mrtav" , "A-" , 1 ),
 ( 10732 , 4 , "Fabijan" , "Pavić" , "Skupnik" , STR_TO_DATE("16.10.1954.", "%d.%m.%Y.") , STR_TO_DATE("15.8.2018.", "%d.%m.%Y.") , "Aktivan" , "A-" , 1 ),
 ( 10733 , 3 , "Belen" , "Herceg" , "Skupnik" , STR_TO_DATE("31.12.1958.", "%d.%m.%Y.") , STR_TO_DATE("11.1.2008.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 4 ),
 ( 10734 , 2 , "Makena" , "Radić" , "Poručnik" , STR_TO_DATE("7.4.1953.", "%d.%m.%Y.") , STR_TO_DATE("22.3.2009.", "%d.%m.%Y.") , "Aktivan" , "B-" , 4 ),
 ( 10735 , 3 , "Kina" , "Pavlić" , "Brigadir" , STR_TO_DATE("8.12.1961.", "%d.%m.%Y.") , STR_TO_DATE("2.10.2016.", "%d.%m.%Y.") , "Mrtav" , "0-" , 4 ),
 ( 10736 , 1 , "Oto" , "Novak" , "Bojnik" , STR_TO_DATE("26.2.1950.", "%d.%m.%Y.") , STR_TO_DATE("13.6.1998.", "%d.%m.%Y.") , "Mrtav" , "A-" , 5 ),
 ( 10737 , 4 , "Izaija" , "Grubišić" , "Pukovnik" , STR_TO_DATE("24.7.1966.", "%d.%m.%Y.") , STR_TO_DATE("16.2.1990.", "%d.%m.%Y.") , "Aktivan" , "A+" , 5 ),
 ( 10738 , 4 , "Ofelia" , "Vučković" , "Satnik" , STR_TO_DATE("21.3.1956.", "%d.%m.%Y.") , STR_TO_DATE("19.7.2019.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 1 ),
 ( 10739 , 3 , "Vanja" , "Nikolić" , "Skupnik" , STR_TO_DATE("2.1.1952.", "%d.%m.%Y.") , STR_TO_DATE("2.8.1996.", "%d.%m.%Y.") , "Mrtav" , "B+" , 5 ),
 ( 10740 , 2 , "Luela" , "Herceg" , "Razvodnik" , STR_TO_DATE("21.10.1969.", "%d.%m.%Y.") , STR_TO_DATE("22.7.2015.", "%d.%m.%Y.") , "Aktivan" , "B-" , 3 ),
 ( 10741 , 1 , "Estela" , "Kolarić" , "Pozornik" , STR_TO_DATE("6.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("3.4.2000.", "%d.%m.%Y.") , "Mrtav" , "A-" , 1 ),
 ( 10742 , 4 , "Mela" , "Šimić" , "Pozornik" , STR_TO_DATE("4.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("27.9.2002.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 2 ),
 ( 10743 , 2 , "Filipa" , "Ćosić" , "Razvodnik" , STR_TO_DATE("30.1.1969.", "%d.%m.%Y.") , STR_TO_DATE("7.4.2015.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 5 ),
 ( 10744 , 2 , "Roman" , "Barišić" , "Brigadir" , STR_TO_DATE("18.11.1952.", "%d.%m.%Y.") , STR_TO_DATE("22.3.2017.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 2 ),
 ( 10745 , 3 , "Rhea" , "Mitrović" , "Bojnik" , STR_TO_DATE("21.2.1965.", "%d.%m.%Y.") , STR_TO_DATE("23.4.2019.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 1 ),
 ( 10746 , 3 , "Korina" , "Jelić" , "Razvodnik" , STR_TO_DATE("16.11.1967.", "%d.%m.%Y.") , STR_TO_DATE("5.8.1992.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 3 ),
 ( 10747 , 1 , "Damir" , "Matković" , "Poručnik" , STR_TO_DATE("3.3.1968.", "%d.%m.%Y.") , STR_TO_DATE("21.9.2010.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 1 ),
 ( 10748 , 2 , "Nova" , "Sever" , "Poručnik" , STR_TO_DATE("9.12.1967.", "%d.%m.%Y.") , STR_TO_DATE("8.8.1999.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 2 ),
 ( 10749 , 1 , "Evanđelika" , "Cindrić" , "Pukovnik" , STR_TO_DATE("10.2.1968.", "%d.%m.%Y.") , STR_TO_DATE("9.2.2013.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 3 ),
 ( 10750 , 1 , "Anemari" , "Grgurić" , "Pukovnik" , STR_TO_DATE("1.5.1966.", "%d.%m.%Y.") , STR_TO_DATE("28.5.2010.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 4 ),
 ( 10751 , 2 , "Bartola" , "Pavić" , "Pozornik" , STR_TO_DATE("28.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("11.5.2002.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 2 ),
 ( 10752 , 1 , "Pavel" , "Jovanović" , "Pozornik" , STR_TO_DATE("2.9.1959.", "%d.%m.%Y.") , STR_TO_DATE("6.9.2011.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 3 ),
 ( 10753 , 1 , "Evina" , "Nikolić" , "Pukovnik" , STR_TO_DATE("4.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("15.4.2016.", "%d.%m.%Y.") , "Mrtav" , "B-" , 3 ),
 ( 10754 , 2 , "Lea" , "Novak" , "Narednik" , STR_TO_DATE("30.4.1967.", "%d.%m.%Y.") , STR_TO_DATE("11.12.1995.", "%d.%m.%Y.") , "Mrtav" , "B+" , 5 ),
 ( 10755 , 4 , "Lina" , "Nikolić" , "Pukovnik" , STR_TO_DATE("25.1.1963.", "%d.%m.%Y.") , STR_TO_DATE("23.2.2020.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 4 ),
 ( 10756 , 1 , "Matea" , "Novak" , "Bojnik" , STR_TO_DATE("15.2.1964.", "%d.%m.%Y.") , STR_TO_DATE("22.11.2008.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 2 ),
 ( 10757 , 4 , "Tara" , "Rukavina" , "Poručnik" , STR_TO_DATE("6.6.1964.", "%d.%m.%Y.") , STR_TO_DATE("11.12.2020.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 5 ),
 ( 10758 , 3 , "Davina" , "Đurđević" , "Poručnik" , STR_TO_DATE("10.1.1954.", "%d.%m.%Y.") , STR_TO_DATE("10.7.2002.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 4 ),
 ( 10759 , 1 , "Jolena" , "Lončarić" , "Skupnik" , STR_TO_DATE("25.3.1957.", "%d.%m.%Y.") , STR_TO_DATE("22.1.2004.", "%d.%m.%Y.") , "Aktivan" , "B-" , 4 ),
 ( 10760 , 2 , "Vincent" , "Petković" , "Pukovnik" , STR_TO_DATE("3.8.1962.", "%d.%m.%Y.") , STR_TO_DATE("6.3.1997.", "%d.%m.%Y.") , "Mrtav" , "B+" , 3 ),
 ( 10761 , 3 , "Evica" , "Jovanović" , "Bojnik" , STR_TO_DATE("27.7.1950.", "%d.%m.%Y.") , STR_TO_DATE("20.7.2002.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 4 ),
 ( 10762 , 2 , "Emili" , "Vuković" , "Pukovnik" , STR_TO_DATE("7.7.1959.", "%d.%m.%Y.") , STR_TO_DATE("19.1.1997.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 2 ),
 ( 10763 , 2 , "Marisol" , "Pavić" , "Satnik" , STR_TO_DATE("20.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("18.1.2017.", "%d.%m.%Y.") , "Aktivan" , "0+" , 3 ),
 ( 10764 , 1 , "Natalija" , "Horvat" , "Brigadir" , STR_TO_DATE("9.1.1962.", "%d.%m.%Y.") , STR_TO_DATE("3.3.2006.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 5 ),
 ( 10765 , 3 , "Maca" , "Miletić" , "Skupnik" , STR_TO_DATE("26.5.1957.", "%d.%m.%Y.") , STR_TO_DATE("13.10.2005.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 1 ),
 ( 10766 , 1 , "Alana" , "Brkić" , "Brigadir" , STR_TO_DATE("24.4.1969.", "%d.%m.%Y.") , STR_TO_DATE("15.11.2019.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 1 ),
 ( 10767 , 3 , "Salema" , "Grgić" , "Skupnik" , STR_TO_DATE("25.9.1958.", "%d.%m.%Y.") , STR_TO_DATE("3.6.2008.", "%d.%m.%Y.") , "Umirovljen" , "AB-" , 4 ),
 ( 10768 , 3 , "Bruno" , "Jurišić" , "Satnik" , STR_TO_DATE("10.5.1955.", "%d.%m.%Y.") , STR_TO_DATE("9.8.2009.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 5 ),
 ( 10769 , 4 , "Dorotej" , "Varga" , "Pozornik" , STR_TO_DATE("11.3.1958.", "%d.%m.%Y.") , STR_TO_DATE("31.10.1996.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 5 ),
 ( 10770 , 4 , "Saša" , "Varga" , "Bojnik" , STR_TO_DATE("3.12.1958.", "%d.%m.%Y.") , STR_TO_DATE("24.6.2005.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 4 ),
 ( 10771 , 2 , "Viena" , "Ćosić" , "Pozornik" , STR_TO_DATE("14.12.1970.", "%d.%m.%Y.") , STR_TO_DATE("17.10.2017.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 4 ),
 ( 10772 , 4 , "Izaija" , "Jurković" , "Pukovnik" , STR_TO_DATE("4.1.1958.", "%d.%m.%Y.") , STR_TO_DATE("26.6.1992.", "%d.%m.%Y.") , "Aktivan" , "A+" , 5 ),
 ( 10773 , 4 , "Ivor" , "Vuković" , "Bojnik" , STR_TO_DATE("5.10.1964.", "%d.%m.%Y.") , STR_TO_DATE("17.6.1994.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 3 ),
 ( 10774 , 1 , "Beta" , "Šimunić" , "Brigadir" , STR_TO_DATE("13.4.1950.", "%d.%m.%Y.") , STR_TO_DATE("9.6.1990.", "%d.%m.%Y.") , "Mrtav" , "A+" , 4 ),
 ( 10775 , 3 , "Moli" , "Posavec" , "Pukovnik" , STR_TO_DATE("12.11.1961.", "%d.%m.%Y.") , STR_TO_DATE("9.4.1990.", "%d.%m.%Y.") , "Aktivan" , "0+" , 4 ),
 ( 10776 , 3 , "Adam" , "Popović" , "Narednik" , STR_TO_DATE("4.6.1964.", "%d.%m.%Y.") , STR_TO_DATE("24.9.2003.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 4 ),
 ( 10777 , 1 , "Gema" , "Ivanović" , "Pozornik" , STR_TO_DATE("16.12.1963.", "%d.%m.%Y.") , STR_TO_DATE("29.12.2014.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 2 ),
 ( 10778 , 1 , "Goran" , "Vrdoljak" , "Bojnik" , STR_TO_DATE("16.5.1959.", "%d.%m.%Y.") , STR_TO_DATE("14.6.2008.", "%d.%m.%Y.") , "Mrtav" , "0+" , 4 ),
 ( 10779 , 2 , "Mila" , "Dragičević" , "Satnik" , STR_TO_DATE("15.11.1954.", "%d.%m.%Y.") , STR_TO_DATE("20.9.2011.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 1 ),
 ( 10780 , 4 , "Alesia" , "Šimunović" , "Pozornik" , STR_TO_DATE("1.5.1965.", "%d.%m.%Y.") , STR_TO_DATE("11.3.2009.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 1 ),
 ( 10781 , 3 , "Julijan" , "Dujmović" , "Skupnik" , STR_TO_DATE("11.4.1956.", "%d.%m.%Y.") , STR_TO_DATE("24.4.2003.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 4 ),
 ( 10782 , 2 , "Miroslava" , "Šimunić" , "Narednik" , STR_TO_DATE("22.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("5.9.2007.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 4 ),
 ( 10783 , 2 , "Hada" , "Novak" , "Narednik" , STR_TO_DATE("9.9.1950.", "%d.%m.%Y.") , STR_TO_DATE("23.9.2005.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 3 ),
 ( 10784 , 3 , "Ćiril" , "Vučković" , "Brigadir" , STR_TO_DATE("1.12.1951.", "%d.%m.%Y.") , STR_TO_DATE("23.4.1998.", "%d.%m.%Y.") , "Mrtav" , "B+" , 4 ),
 ( 10785 , 1 , "Mihaela" , "Sever" , "Pozornik" , STR_TO_DATE("10.11.1950.", "%d.%m.%Y.") , STR_TO_DATE("5.4.2006.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 3 ),
 ( 10786 , 2 , "Lucija" , "Tomić" , "Pukovnik" , STR_TO_DATE("5.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("30.7.2008.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 1 ),
 ( 10787 , 1 , "Mauro" , "Abramović" , "Brigadir" , STR_TO_DATE("8.4.1970.", "%d.%m.%Y.") , STR_TO_DATE("20.10.2019.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 5 ),
 ( 10788 , 4 , "Leksi" , "Grgić" , "Pozornik" , STR_TO_DATE("12.11.1968.", "%d.%m.%Y.") , STR_TO_DATE("6.8.2011.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 5 ),
 ( 10789 , 4 , "Dragica" , "Jovanović" , "Satnik" , STR_TO_DATE("23.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("30.4.2000.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 4 ),
 ( 10790 , 3 , "Frida" , "Katić" , "Poručnik" , STR_TO_DATE("13.5.1950.", "%d.%m.%Y.") , STR_TO_DATE("30.9.1993.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 5 ),
 ( 10791 , 2 , "Paisa" , "Ivanković" , "Poručnik" , STR_TO_DATE("25.3.1953.", "%d.%m.%Y.") , STR_TO_DATE("2.7.1994.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 2 ),
 ( 10792 , 1 , "Božidar" , "Novosel" , "Razvodnik" , STR_TO_DATE("28.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("16.12.2011.", "%d.%m.%Y.") , "Mrtav" , "A-" , 1 ),
 ( 10793 , 1 , "Franjo" , "Antunović" , "Pukovnik" , STR_TO_DATE("10.9.1965.", "%d.%m.%Y.") , STR_TO_DATE("10.8.1993.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 5 ),
 ( 10794 , 3 , "Florijan" , "Filipović" , "Skupnik" , STR_TO_DATE("10.12.1963.", "%d.%m.%Y.") , STR_TO_DATE("26.8.1999.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 2 ),
 ( 10795 , 2 , "Siri" , "Jakovljević" , "Pozornik" , STR_TO_DATE("12.7.1958.", "%d.%m.%Y.") , STR_TO_DATE("18.6.2006.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 5 ),
 ( 10796 , 1 , "Eva" , "Novaković" , "Pozornik" , STR_TO_DATE("25.7.1970.", "%d.%m.%Y.") , STR_TO_DATE("19.5.2008.", "%d.%m.%Y.") , "Aktivan" , "0+" , 3 ),
 ( 10797 , 2 , "Serena" , "Tomić" , "Brigadir" , STR_TO_DATE("18.12.1956.", "%d.%m.%Y.") , STR_TO_DATE("9.11.2016.", "%d.%m.%Y.") , "Mrtav" , "0-" , 5 ),
 ( 10798 , 2 , "Adam" , "Jakovljević" , "Poručnik" , STR_TO_DATE("11.4.1966.", "%d.%m.%Y.") , STR_TO_DATE("10.2.2012.", "%d.%m.%Y.") , "Mrtav" , "A-" , 5 ),
 ( 10799 , 2 , "Jerko" , "Matković" , "Pozornik" , STR_TO_DATE("29.10.1954.", "%d.%m.%Y.") , STR_TO_DATE("5.5.1992.", "%d.%m.%Y.") , "Mrtav" , "0+" , 3 ),
 ( 10800 , 3 , "Zaria" , "Šarić" , "Narednik" , STR_TO_DATE("1.3.1954.", "%d.%m.%Y.") , STR_TO_DATE("4.11.2015.", "%d.%m.%Y.") , "Mrtav" , "B-" , 3 ),
 ( 10801 , 2 , "Renata" , "Jurišić" , "Poručnik" , STR_TO_DATE("12.4.1961.", "%d.%m.%Y.") , STR_TO_DATE("9.12.2017.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 3 ),
 ( 10802 , 2 , "Neo" , "Popović" , "Pukovnik" , STR_TO_DATE("17.12.1952.", "%d.%m.%Y.") , STR_TO_DATE("25.10.1995.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 2 ),
 ( 10803 , 4 , "Amira" , "Mikulić" , "Poručnik" , STR_TO_DATE("11.8.1967.", "%d.%m.%Y.") , STR_TO_DATE("12.6.2005.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 5 ),
 ( 10804 , 1 , "Jordan" , "Šarić" , "Brigadir" , STR_TO_DATE("16.1.1954.", "%d.%m.%Y.") , STR_TO_DATE("10.12.2020.", "%d.%m.%Y.") , "Aktivan" , "0-" , 1 ),
 ( 10805 , 1 , "Vera" , "Šimunović" , "Brigadir" , STR_TO_DATE("2.1.1953.", "%d.%m.%Y.") , STR_TO_DATE("29.12.2019.", "%d.%m.%Y.") , "Aktivan" , "B-" , 3 ),
 ( 10806 , 4 , "Emil" , "Matijević" , "Poručnik" , STR_TO_DATE("13.8.1959.", "%d.%m.%Y.") , STR_TO_DATE("6.4.1995.", "%d.%m.%Y.") , "Mrtav" , "B-" , 3 ),
 ( 10807 , 1 , "Lea" , "Marjanović" , "Pozornik" , STR_TO_DATE("20.9.1964.", "%d.%m.%Y.") , STR_TO_DATE("3.7.1999.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 4 ),
 ( 10808 , 2 , "Samanta" , "Jakovljević" , "Narednik" , STR_TO_DATE("16.3.1966.", "%d.%m.%Y.") , STR_TO_DATE("26.12.2011.", "%d.%m.%Y.") , "Mrtav" , "A+" , 3 ),
 ( 10809 , 3 , "Anđeo" , "Pavlić" , "Razvodnik" , STR_TO_DATE("28.2.1967.", "%d.%m.%Y.") , STR_TO_DATE("11.5.1996.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 3 ),
 ( 10810 , 1 , "Gloria" , "Radić" , "Satnik" , STR_TO_DATE("28.2.1961.", "%d.%m.%Y.") , STR_TO_DATE("2.6.1991.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 2 ),
 ( 10811 , 4 , "Renato" , "Butković" , "Poručnik" , STR_TO_DATE("25.6.1964.", "%d.%m.%Y.") , STR_TO_DATE("15.1.1991.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 2 ),
 ( 10812 , 1 , "Jara" , "Ćosić" , "Pozornik" , STR_TO_DATE("2.5.1970.", "%d.%m.%Y.") , STR_TO_DATE("27.8.2019.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 3 ),
 ( 10813 , 1 , "Antonio" , "Đurić" , "Bojnik" , STR_TO_DATE("14.7.1952.", "%d.%m.%Y.") , STR_TO_DATE("10.4.1997.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 1 ),
 ( 10814 , 1 , "Dorian" , "Bašić" , "Narednik" , STR_TO_DATE("5.5.1953.", "%d.%m.%Y.") , STR_TO_DATE("5.12.2004.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 3 ),
 ( 10815 , 3 , "Moreno" , "Antunović" , "Poručnik" , STR_TO_DATE("20.6.1950.", "%d.%m.%Y.") , STR_TO_DATE("14.2.2000.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 3 ),
 ( 10816 , 1 , "Brigita" , "Crnković" , "Pozornik" , STR_TO_DATE("29.3.1966.", "%d.%m.%Y.") , STR_TO_DATE("12.11.2013.", "%d.%m.%Y.") , "Mrtav" , "0-" , 4 ),
 ( 10817 , 3 , "Aliza" , "Šimunović" , "Razvodnik" , STR_TO_DATE("14.9.1955.", "%d.%m.%Y.") , STR_TO_DATE("11.9.2010.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 2 ),
 ( 10818 , 2 , "Milica" , "Živković" , "Satnik" , STR_TO_DATE("15.9.1955.", "%d.%m.%Y.") , STR_TO_DATE("14.2.2016.", "%d.%m.%Y.") , "Aktivan" , "0-" , 2 ),
 ( 10819 , 2 , "Zoja" , "Bilić" , "Skupnik" , STR_TO_DATE("26.12.1962.", "%d.%m.%Y.") , STR_TO_DATE("28.2.1993.", "%d.%m.%Y.") , "Mrtav" , "B+" , 3 ),
 ( 10820 , 3 , "Tatjana" , "Krznarić" , "Skupnik" , STR_TO_DATE("10.4.1967.", "%d.%m.%Y.") , STR_TO_DATE("8.3.2020.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 5 ),
 ( 10821 , 4 , "Siri" , "Božić" , "Bojnik" , STR_TO_DATE("22.6.1955.", "%d.%m.%Y.") , STR_TO_DATE("29.4.2013.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 2 ),
 ( 10822 , 2 , "Lina" , "Kralj" , "Skupnik" , STR_TO_DATE("16.4.1963.", "%d.%m.%Y.") , STR_TO_DATE("24.3.1990.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 1 ),
 ( 10823 , 4 , "Noela" , "Bašić" , "Pozornik" , STR_TO_DATE("16.6.1970.", "%d.%m.%Y.") , STR_TO_DATE("17.6.1991.", "%d.%m.%Y.") , "Mrtav" , "0+" , 5 ),
 ( 10824 , 4 , "Lorena" , "Matković" , "Bojnik" , STR_TO_DATE("13.8.1969.", "%d.%m.%Y.") , STR_TO_DATE("16.4.2011.", "%d.%m.%Y.") , "Mrtav" , "B+" , 3 ),
 ( 10825 , 2 , "Severino" , "Pavlović" , "Bojnik" , STR_TO_DATE("10.1.1963.", "%d.%m.%Y.") , STR_TO_DATE("24.7.2001.", "%d.%m.%Y.") , "Mrtav" , "A+" , 4 ),
 ( 10826 , 1 , "Magnolija" , "Burić" , "Pukovnik" , STR_TO_DATE("16.7.1969.", "%d.%m.%Y.") , STR_TO_DATE("26.1.2017.", "%d.%m.%Y.") , "Mrtav" , "B+" , 1 ),
 ( 10827 , 3 , "Moli" , "Novosel" , "Pozornik" , STR_TO_DATE("20.9.1961.", "%d.%m.%Y.") , STR_TO_DATE("4.8.1995.", "%d.%m.%Y.") , "Mrtav" , "0+" , 5 ),
 ( 10828 , 3 , "Viktor" , "Mitrović" , "Poručnik" , STR_TO_DATE("29.4.1968.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2003.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 2 ),
 ( 10829 , 3 , "Nora" , "Pavlić" , "Brigadir" , STR_TO_DATE("26.6.1966.", "%d.%m.%Y.") , STR_TO_DATE("30.10.2019.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 1 ),
 ( 10830 , 1 , "Lucija" , "Šimunić" , "Brigadir" , STR_TO_DATE("22.5.1956.", "%d.%m.%Y.") , STR_TO_DATE("20.10.2008.", "%d.%m.%Y.") , "Aktivan" , "B+" , 1 ),
 ( 10831 , 2 , "Nadia" , "Marušić" , "Pukovnik" , STR_TO_DATE("30.6.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2003.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 5 ),
 ( 10832 , 4 , "Lora" , "Vuković" , "Pozornik" , STR_TO_DATE("4.5.1962.", "%d.%m.%Y.") , STR_TO_DATE("6.6.1996.", "%d.%m.%Y.") , "Aktivan" , "B+" , 1 ),
 ( 10833 , 1 , "Evina" , "Petković" , "Razvodnik" , STR_TO_DATE("25.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("6.2.1992.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 1 ),
 ( 10834 , 1 , "Nikola" , "Vidaković" , "Narednik" , STR_TO_DATE("17.11.1968.", "%d.%m.%Y.") , STR_TO_DATE("8.1.1993.", "%d.%m.%Y.") , "Mrtav" , "B+" , 3 ),
 ( 10835 , 2 , "Marta" , "Miletić" , "Narednik" , STR_TO_DATE("2.10.1960.", "%d.%m.%Y.") , STR_TO_DATE("25.3.2014.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 2 ),
 ( 10836 , 4 , "Lika" , "Dragičević" , "Narednik" , STR_TO_DATE("2.5.1954.", "%d.%m.%Y.") , STR_TO_DATE("24.3.2007.", "%d.%m.%Y.") , "Aktivan" , "B+" , 4 ),
 ( 10837 , 3 , "Zoe" , "Mikulić" , "Narednik" , STR_TO_DATE("22.6.1965.", "%d.%m.%Y.") , STR_TO_DATE("7.4.2002.", "%d.%m.%Y.") , "Aktivan" , "0-" , 2 ),
 ( 10838 , 4 , "Simona" , "Barišić" , "Pozornik" , STR_TO_DATE("28.2.1970.", "%d.%m.%Y.") , STR_TO_DATE("25.2.2003.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 1 ),
 ( 10839 , 1 , "Tim" , "Perić" , "Brigadir" , STR_TO_DATE("22.9.1954.", "%d.%m.%Y.") , STR_TO_DATE("10.8.2015.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 4 ),
 ( 10840 , 3 , "Teo" , "Vrdoljak" , "Satnik" , STR_TO_DATE("4.7.1967.", "%d.%m.%Y.") , STR_TO_DATE("4.1.2006.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 4 ),
 ( 10841 , 4 , "Ariel" , "Barišić" , "Satnik" , STR_TO_DATE("28.6.1967.", "%d.%m.%Y.") , STR_TO_DATE("9.8.2000.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 3 ),
 ( 10842 , 3 , "Alen" , "Tomić" , "Narednik" , STR_TO_DATE("23.7.1970.", "%d.%m.%Y.") , STR_TO_DATE("10.6.2019.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 2 ),
 ( 10843 , 3 , "Nira" , "Đurđević" , "Bojnik" , STR_TO_DATE("4.12.1967.", "%d.%m.%Y.") , STR_TO_DATE("6.10.2019.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 4 ),
 ( 10844 , 2 , "Kate" , "Petrović" , "Poručnik" , STR_TO_DATE("22.9.1951.", "%d.%m.%Y.") , STR_TO_DATE("28.7.1990.", "%d.%m.%Y.") , "Aktivan" , "B+" , 2 ),
 ( 10845 , 4 , "Galilea" , "Marić" , "Brigadir" , STR_TO_DATE("13.9.1966.", "%d.%m.%Y.") , STR_TO_DATE("11.4.2008.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 3 ),
 ( 10846 , 1 , "Kiana" , "Lončar" , "Pozornik" , STR_TO_DATE("24.11.1964.", "%d.%m.%Y.") , STR_TO_DATE("15.2.2020.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 3 ),
 ( 10847 , 4 , "Aida" , "Radić" , "Narednik" , STR_TO_DATE("15.3.1963.", "%d.%m.%Y.") , STR_TO_DATE("17.11.2001.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 2 ),
 ( 10848 , 1 , "Adelina" , "Matijević" , "Razvodnik" , STR_TO_DATE("16.4.1953.", "%d.%m.%Y.") , STR_TO_DATE("28.5.2008.", "%d.%m.%Y.") , "Mrtav" , "0+" , 4 ),
 ( 10849 , 3 , "Elaina" , "Novosel" , "Pozornik" , STR_TO_DATE("20.2.1954.", "%d.%m.%Y.") , STR_TO_DATE("21.6.2008.", "%d.%m.%Y.") , "Mrtav" , "B+" , 3 ),
 ( 10850 , 3 , "Korina" , "Burić" , "Poručnik" , STR_TO_DATE("29.1.1956.", "%d.%m.%Y.") , STR_TO_DATE("16.1.2003.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 3 ),
 ( 10851 , 4 , "Velina" , "Marjanović" , "Poručnik" , STR_TO_DATE("10.5.1959.", "%d.%m.%Y.") , STR_TO_DATE("29.11.2010.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 3 ),
 ( 10852 , 2 , "Marija" , "Miletić" , "Bojnik" , STR_TO_DATE("10.6.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.2.1993.", "%d.%m.%Y.") , "Aktivan" , "A-" , 4 ),
 ( 10853 , 1 , "Karmen" , "Mandić" , "Poručnik" , STR_TO_DATE("1.5.1969.", "%d.%m.%Y.") , STR_TO_DATE("11.10.1993.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 4 ),
 ( 10854 , 1 , "Artemisa" , "Brajković" , "Pukovnik" , STR_TO_DATE("5.2.1967.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2000.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 2 ),
 ( 10855 , 2 , "Kamila" , "Kralj" , "Satnik" , STR_TO_DATE("2.7.1963.", "%d.%m.%Y.") , STR_TO_DATE("24.2.2001.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 4 ),
 ( 10856 , 4 , "Goran" , "Krznarić" , "Brigadir" , STR_TO_DATE("26.7.1951.", "%d.%m.%Y.") , STR_TO_DATE("14.7.2013.", "%d.%m.%Y.") , "Aktivan" , "0-" , 2 ),
 ( 10857 , 4 , "Slaven" , "Matković" , "Skupnik" , STR_TO_DATE("10.9.1963.", "%d.%m.%Y.") , STR_TO_DATE("24.9.2008.", "%d.%m.%Y.") , "Aktivan" , "A+" , 4 ),
 ( 10858 , 3 , "Hada" , "Kralj" , "Brigadir" , STR_TO_DATE("30.12.1957.", "%d.%m.%Y.") , STR_TO_DATE("8.8.2002.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 4 ),
 ( 10859 , 2 , "Nikol" , "Kralj" , "Skupnik" , STR_TO_DATE("26.2.1956.", "%d.%m.%Y.") , STR_TO_DATE("4.7.2001.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 1 ),
 ( 10860 , 1 , "Kenia" , "Dujmović" , "Skupnik" , STR_TO_DATE("17.8.1963.", "%d.%m.%Y.") , STR_TO_DATE("2.6.1997.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 1 ),
 ( 10861 , 4 , "Fran" , "Perković" , "Poručnik" , STR_TO_DATE("10.1.1969.", "%d.%m.%Y.") , STR_TO_DATE("3.5.2010.", "%d.%m.%Y.") , "Mrtav" , "B-" , 5 ),
 ( 10862 , 2 , "Lovorka" , "Perić" , "Poručnik" , STR_TO_DATE("1.12.1968.", "%d.%m.%Y.") , STR_TO_DATE("1.7.2013.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 4 ),
 ( 10863 , 3 , "Vito" , "Knežević" , "Narednik" , STR_TO_DATE("28.5.1968.", "%d.%m.%Y.") , STR_TO_DATE("4.2.2014.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 2 ),
 ( 10864 , 2 , "Fernand" , "Lukić" , "Poručnik" , STR_TO_DATE("16.8.1955.", "%d.%m.%Y.") , STR_TO_DATE("11.5.2002.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 3 ),
 ( 10865 , 4 , "Breta" , "Perković" , "Razvodnik" , STR_TO_DATE("7.3.1956.", "%d.%m.%Y.") , STR_TO_DATE("19.4.2011.", "%d.%m.%Y.") , "Mrtav" , "0+" , 3 ),
 ( 10866 , 3 , "Skila" , "Lovrić" , "Razvodnik" , STR_TO_DATE("10.4.1954.", "%d.%m.%Y.") , STR_TO_DATE("10.5.1997.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 5 ),
 ( 10867 , 4 , "Gabrijela" , "Marković" , "Razvodnik" , STR_TO_DATE("29.10.1952.", "%d.%m.%Y.") , STR_TO_DATE("18.10.2009.", "%d.%m.%Y.") , "Aktivan" , "A-" , 1 ),
 ( 10868 , 4 , "Lilia" , "Posavec" , "Pukovnik" , STR_TO_DATE("14.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("19.12.2006.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 4 ),
 ( 10869 , 1 , "Elanija" , "Sever" , "Razvodnik" , STR_TO_DATE("20.1.1961.", "%d.%m.%Y.") , STR_TO_DATE("7.5.2018.", "%d.%m.%Y.") , "Aktivan" , "0+" , 4 ),
 ( 10870 , 1 , "Ernest" , "Lukić" , "Poručnik" , STR_TO_DATE("5.12.1966.", "%d.%m.%Y.") , STR_TO_DATE("21.7.2002.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 3 ),
 ( 10871 , 2 , "Amber" , "Sever" , "Pozornik" , STR_TO_DATE("12.1.1966.", "%d.%m.%Y.") , STR_TO_DATE("24.3.2009.", "%d.%m.%Y.") , "Mrtav" , "B+" , 2 ),
 ( 10872 , 4 , "Kiara" , "Galić" , "Narednik" , STR_TO_DATE("10.10.1958.", "%d.%m.%Y.") , STR_TO_DATE("20.7.2011.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 4 ),
 ( 10873 , 2 , "Ivan" , "Jovanović" , "Poručnik" , STR_TO_DATE("11.11.1965.", "%d.%m.%Y.") , STR_TO_DATE("3.3.2010.", "%d.%m.%Y.") , "Mrtav" , "A-" , 5 ),
 ( 10874 , 2 , "Theodora" , "Miletić" , "Narednik" , STR_TO_DATE("23.1.1955.", "%d.%m.%Y.") , STR_TO_DATE("15.7.1994.", "%d.%m.%Y.") , "Aktivan" , "A+" , 4 ),
 ( 10875 , 3 , "Emberli" , "Perić" , "Brigadir" , STR_TO_DATE("3.5.1964.", "%d.%m.%Y.") , STR_TO_DATE("22.11.1996.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 2 ),
 ( 10876 , 2 , "Rubi" , "Kralj" , "Brigadir" , STR_TO_DATE("18.9.1957.", "%d.%m.%Y.") , STR_TO_DATE("5.4.2005.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 3 ),
 ( 10877 , 3 , "Majin" , "Đurđević" , "Satnik" , STR_TO_DATE("21.9.1954.", "%d.%m.%Y.") , STR_TO_DATE("7.11.2010.", "%d.%m.%Y.") , "Aktivan" , "A+" , 1 ),
 ( 10878 , 2 , "Nala" , "Martinović" , "Skupnik" , STR_TO_DATE("1.7.1966.", "%d.%m.%Y.") , STR_TO_DATE("5.10.1995.", "%d.%m.%Y.") , "Mrtav" , "0-" , 3 ),
 ( 10879 , 3 , "Avi" , "Vukelić" , "Bojnik" , STR_TO_DATE("4.4.1951.", "%d.%m.%Y.") , STR_TO_DATE("4.9.2006.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 2 ),
 ( 10880 , 3 , "Adam" , "Matković" , "Narednik" , STR_TO_DATE("22.7.1958.", "%d.%m.%Y.") , STR_TO_DATE("5.9.1999.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 4 ),
 ( 10881 , 3 , "Bosiljka" , "Šimunović" , "Satnik" , STR_TO_DATE("17.1.1957.", "%d.%m.%Y.") , STR_TO_DATE("19.1.2016.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 2 ),
 ( 10882 , 2 , "Jema" , "Pavić" , "Narednik" , STR_TO_DATE("22.4.1957.", "%d.%m.%Y.") , STR_TO_DATE("10.11.1993.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 5 ),
 ( 10883 , 3 , "Brigita" , "Lovrić" , "Satnik" , STR_TO_DATE("23.10.1962.", "%d.%m.%Y.") , STR_TO_DATE("28.12.2010.", "%d.%m.%Y.") , "Aktivan" , "A-" , 5 ),
 ( 10884 , 4 , "Anabela" , "Šarić" , "Poručnik" , STR_TO_DATE("10.11.1952.", "%d.%m.%Y.") , STR_TO_DATE("1.5.1998.", "%d.%m.%Y.") , "Aktivan" , "A+" , 5 ),
 ( 10885 , 1 , "Lili" , "Bašić" , "Brigadir" , STR_TO_DATE("8.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("20.7.2018.", "%d.%m.%Y.") , "Mrtav" , "0-" , 5 ),
 ( 10886 , 1 , "Oleg" , "Klarić" , "Satnik" , STR_TO_DATE("25.6.1970.", "%d.%m.%Y.") , STR_TO_DATE("9.3.1991.", "%d.%m.%Y.") , "Mrtav" , "B+" , 5 ),
 ( 10887 , 2 , "Harmina" , "Mandić" , "Pozornik" , STR_TO_DATE("12.12.1967.", "%d.%m.%Y.") , STR_TO_DATE("24.6.1990.", "%d.%m.%Y.") , "Mrtav" , "A-" , 3 ),
 ( 10888 , 4 , "Fredo" , "Ćosić" , "Pukovnik" , STR_TO_DATE("13.11.1961.", "%d.%m.%Y.") , STR_TO_DATE("26.1.2017.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 3 ),
 ( 10889 , 2 , "Selena" , "Matijević" , "Brigadir" , STR_TO_DATE("12.6.1968.", "%d.%m.%Y.") , STR_TO_DATE("1.9.1992.", "%d.%m.%Y.") , "Mrtav" , "A+" , 1 ),
 ( 10890 , 4 , "Antea" , "Vuković" , "Razvodnik" , STR_TO_DATE("14.3.1965.", "%d.%m.%Y.") , STR_TO_DATE("17.6.2019.", "%d.%m.%Y.") , "Mrtav" , "A-" , 5 ),
 ( 10891 , 3 , "Hrvoje" , "Vuković" , "Poručnik" , STR_TO_DATE("2.10.1964.", "%d.%m.%Y.") , STR_TO_DATE("16.3.1992.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 3 ),
 ( 10892 , 2 , "Cecilija" , "Josipović" , "Pukovnik" , STR_TO_DATE("31.1.1956.", "%d.%m.%Y.") , STR_TO_DATE("18.3.2016.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 1 ),
 ( 10893 , 2 , "Leonardo" , "Marić" , "Poručnik" , STR_TO_DATE("16.4.1952.", "%d.%m.%Y.") , STR_TO_DATE("1.7.2016.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 3 ),
 ( 10894 , 3 , "Linda" , "Šimić" , "Satnik" , STR_TO_DATE("18.7.1950.", "%d.%m.%Y.") , STR_TO_DATE("17.11.1997.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 5 ),
 ( 10895 , 4 , "Marin" , "Barišić" , "Razvodnik" , STR_TO_DATE("1.3.1956.", "%d.%m.%Y.") , STR_TO_DATE("2.4.2006.", "%d.%m.%Y.") , "Mrtav" , "A-" , 4 ),
 ( 10896 , 4 , "Remi" , "Crnković" , "Skupnik" , STR_TO_DATE("26.3.1955.", "%d.%m.%Y.") , STR_TO_DATE("7.6.2005.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 2 ),
 ( 10897 , 4 , "Aleksandra" , "Bašić" , "Poručnik" , STR_TO_DATE("17.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("4.9.2004.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 1 ),
 ( 10898 , 3 , "Anastasija" , "Marić" , "Narednik" , STR_TO_DATE("17.4.1955.", "%d.%m.%Y.") , STR_TO_DATE("28.2.2014.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 5 ),
 ( 10899 , 4 , "Maksima" , "Kovačić" , "Pozornik" , STR_TO_DATE("8.2.1970.", "%d.%m.%Y.") , STR_TO_DATE("15.5.2012.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 1 ),
 ( 10900 , 3 , "Emili" , "Šimić" , "Skupnik" , STR_TO_DATE("30.9.1953.", "%d.%m.%Y.") , STR_TO_DATE("12.12.2009.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 3 ),
 ( 10901 , 3 , "Matej" , "Kovač" , "Brigadir" , STR_TO_DATE("1.1.1967.", "%d.%m.%Y.") , STR_TO_DATE("15.5.1994.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 1 ),
 ( 10902 , 3 , "Jerko" , "Novosel" , "Narednik" , STR_TO_DATE("25.12.1954.", "%d.%m.%Y.") , STR_TO_DATE("14.12.2002.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 1 ),
 ( 10903 , 4 , "Biserka" , "Crnković" , "Bojnik" , STR_TO_DATE("16.5.1963.", "%d.%m.%Y.") , STR_TO_DATE("16.9.2011.", "%d.%m.%Y.") , "Aktivan" , "A+" , 3 ),
 ( 10904 , 1 , "Rita" , "Galić" , "Pozornik" , STR_TO_DATE("4.7.1963.", "%d.%m.%Y.") , STR_TO_DATE("24.11.2006.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 4 ),
 ( 10905 , 4 , "Ivana" , "Ivanović" , "Narednik" , STR_TO_DATE("1.5.1970.", "%d.%m.%Y.") , STR_TO_DATE("13.12.1994.", "%d.%m.%Y.") , "Mrtav" , "0-" , 2 ),
 ( 10906 , 3 , "Ognjen" , "Krznarić" , "Skupnik" , STR_TO_DATE("18.2.1954.", "%d.%m.%Y.") , STR_TO_DATE("1.2.1992.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 5 ),
 ( 10907 , 1 , "Ofelia" , "Grgić" , "Pukovnik" , STR_TO_DATE("8.11.1957.", "%d.%m.%Y.") , STR_TO_DATE("1.9.2008.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 1 ),
 ( 10908 , 3 , "Rea" , "Filipović" , "Pozornik" , STR_TO_DATE("4.12.1958.", "%d.%m.%Y.") , STR_TO_DATE("31.1.1999.", "%d.%m.%Y.") , "Aktivan" , "0-" , 3 ),
 ( 10909 , 2 , "Klementina" , "Lovrić" , "Razvodnik" , STR_TO_DATE("18.1.1967.", "%d.%m.%Y.") , STR_TO_DATE("30.12.1995.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 1 ),
 ( 10910 , 2 , "Itzela" , "Matić" , "Poručnik" , STR_TO_DATE("10.2.1963.", "%d.%m.%Y.") , STR_TO_DATE("26.9.1999.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 4 ),
 ( 10911 , 4 , "Rebeka" , "Đurđević" , "Razvodnik" , STR_TO_DATE("10.4.1956.", "%d.%m.%Y.") , STR_TO_DATE("2.2.2001.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 1 ),
 ( 10912 , 4 , "Gordan" , "Marković" , "Narednik" , STR_TO_DATE("24.8.1962.", "%d.%m.%Y.") , STR_TO_DATE("26.5.2011.", "%d.%m.%Y.") , "Mrtav" , "A+" , 5 ),
 ( 10913 , 1 , "Goran" , "Cindrić" , "Satnik" , STR_TO_DATE("20.2.1952.", "%d.%m.%Y.") , STR_TO_DATE("20.10.2014.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 5 ),
 ( 10914 , 4 , "Emir" , "Jakovljević" , "Poručnik" , STR_TO_DATE("13.1.1968.", "%d.%m.%Y.") , STR_TO_DATE("25.9.1990.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 5 ),
 ( 10915 , 4 , "Imani" , "Jozić" , "Bojnik" , STR_TO_DATE("17.6.1963.", "%d.%m.%Y.") , STR_TO_DATE("17.5.2001.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 4 ),
 ( 10916 , 2 , "Karla" , "Crnković" , "Pozornik" , STR_TO_DATE("14.12.1961.", "%d.%m.%Y.") , STR_TO_DATE("12.5.2020.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 3 ),
 ( 10917 , 4 , "Karmen" , "Vidaković" , "Satnik" , STR_TO_DATE("12.11.1957.", "%d.%m.%Y.") , STR_TO_DATE("26.1.2000.", "%d.%m.%Y.") , "Aktivan" , "B+" , 5 ),
 ( 10918 , 2 , "Lilia" , "Vučković" , "Poručnik" , STR_TO_DATE("3.12.1967.", "%d.%m.%Y.") , STR_TO_DATE("5.8.2002.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 1 ),
 ( 10919 , 2 , "Tončica" , "Grubišić" , "Narednik" , STR_TO_DATE("9.7.1950.", "%d.%m.%Y.") , STR_TO_DATE("29.3.2010.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 5 ),
 ( 10920 , 3 , "Franka" , "Galić" , "Pozornik" , STR_TO_DATE("17.9.1970.", "%d.%m.%Y.") , STR_TO_DATE("1.5.2003.", "%d.%m.%Y.") , "Mrtav" , "B-" , 3 ),
 ( 10921 , 2 , "Željkica" , "Matijević" , "Pukovnik" , STR_TO_DATE("8.3.1969.", "%d.%m.%Y.") , STR_TO_DATE("13.5.1990.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 1 ),
 ( 10922 , 2 , "Karina" , "Galić" , "Brigadir" , STR_TO_DATE("6.9.1966.", "%d.%m.%Y.") , STR_TO_DATE("3.3.1995.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 3 ),
 ( 10923 , 4 , "Ira" , "Lončar" , "Brigadir" , STR_TO_DATE("14.7.1956.", "%d.%m.%Y.") , STR_TO_DATE("8.3.2014.", "%d.%m.%Y.") , "Aktivan" , "0-" , 3 ),
 ( 10924 , 4 , "Tihana" , "Jurišić" , "Bojnik" , STR_TO_DATE("7.7.1950.", "%d.%m.%Y.") , STR_TO_DATE("18.8.2005.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 3 ),
 ( 10925 , 3 , "Vanja" , "Bašić" , "Satnik" , STR_TO_DATE("26.9.1967.", "%d.%m.%Y.") , STR_TO_DATE("20.10.1996.", "%d.%m.%Y.") , "Mrtav" , "A+" , 5 ),
 ( 10926 , 1 , "Mikaela" , "Perić" , "Poručnik" , STR_TO_DATE("13.10.1961.", "%d.%m.%Y.") , STR_TO_DATE("26.8.2000.", "%d.%m.%Y.") , "Neaktivan" , "B+" , 3 ),
 ( 10927 , 3 , "Janica" , "Jozić" , "Pozornik" , STR_TO_DATE("8.2.1956.", "%d.%m.%Y.") , STR_TO_DATE("3.5.2013.", "%d.%m.%Y.") , "Aktivan" , "AB-" , 2 ),
 ( 10928 , 4 , "Korina" , "Sever" , "Narednik" , STR_TO_DATE("13.6.1953.", "%d.%m.%Y.") , STR_TO_DATE("19.12.2015.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 2 ),
 ( 10929 , 2 , "Vigo" , "Krznarić" , "Skupnik" , STR_TO_DATE("7.7.1955.", "%d.%m.%Y.") , STR_TO_DATE("5.1.2007.", "%d.%m.%Y.") , "Aktivan" , "A+" , 2 ),
 ( 10930 , 4 , "Chaja" , "Josipović" , "Skupnik" , STR_TO_DATE("21.9.1970.", "%d.%m.%Y.") , STR_TO_DATE("5.9.2011.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 4 ),
 ( 10931 , 1 , "Zorka" , "Đurić" , "Narednik" , STR_TO_DATE("3.2.1966.", "%d.%m.%Y.") , STR_TO_DATE("5.11.2011.", "%d.%m.%Y.") , "Neaktivan" , "A-" , 5 ),
 ( 10932 , 4 , "Ferdinand" , "Jovanović" , "Narednik" , STR_TO_DATE("4.10.1966.", "%d.%m.%Y.") , STR_TO_DATE("16.12.2020.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 2 ),
 ( 10933 , 1 , "Elio" , "Posavec" , "Bojnik" , STR_TO_DATE("3.6.1964.", "%d.%m.%Y.") , STR_TO_DATE("14.10.2005.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 3 ),
 ( 10934 , 4 , "Alijah" , "Butković" , "Pukovnik" , STR_TO_DATE("14.7.1967.", "%d.%m.%Y.") , STR_TO_DATE("12.9.2015.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 1 ),
 ( 10935 , 3 , "Ezra" , "Jovanović" , "Narednik" , STR_TO_DATE("21.7.1955.", "%d.%m.%Y.") , STR_TO_DATE("8.9.2005.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 1 ),
 ( 10936 , 4 , "Neven" , "Kovač" , "Bojnik" , STR_TO_DATE("10.9.1956.", "%d.%m.%Y.") , STR_TO_DATE("22.10.2019.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 5 ),
 ( 10937 , 2 , "Željko" , "Lukić" , "Skupnik" , STR_TO_DATE("27.6.1963.", "%d.%m.%Y.") , STR_TO_DATE("21.2.2013.", "%d.%m.%Y.") , "Aktivan" , "0+" , 1 ),
 ( 10938 , 2 , "Oliver" , "Marić" , "Pozornik" , STR_TO_DATE("26.12.1966.", "%d.%m.%Y.") , STR_TO_DATE("3.12.1999.", "%d.%m.%Y.") , "Mrtav" , "0+" , 3 ),
 ( 10939 , 2 , "Teo" , "Posavec" , "Satnik" , STR_TO_DATE("27.4.1962.", "%d.%m.%Y.") , STR_TO_DATE("8.3.1997.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 3 ),
 ( 10940 , 3 , "Damir" , "Petrović" , "Razvodnik" , STR_TO_DATE("17.4.1950.", "%d.%m.%Y.") , STR_TO_DATE("17.6.1995.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 1 ),
 ( 10941 , 2 , "Zara" , "Filipović" , "Brigadir" , STR_TO_DATE("20.6.1969.", "%d.%m.%Y.") , STR_TO_DATE("19.8.2019.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 2 ),
 ( 10942 , 3 , "Zahra" , "Kovačević" , "Poručnik" , STR_TO_DATE("17.4.1970.", "%d.%m.%Y.") , STR_TO_DATE("2.3.2016.", "%d.%m.%Y.") , "Aktivan" , "0+" , 3 ),
 ( 10943 , 2 , "Penelopa" , "Horvat" , "Skupnik" , STR_TO_DATE("30.6.1953.", "%d.%m.%Y.") , STR_TO_DATE("3.7.2003.", "%d.%m.%Y.") , "Mrtav" , "B-" , 5 ),
 ( 10944 , 2 , "Željka" , "Jakovljević" , "Narednik" , STR_TO_DATE("8.6.1952.", "%d.%m.%Y.") , STR_TO_DATE("15.1.2010.", "%d.%m.%Y.") , "Mrtav" , "A+" , 3 ),
 ( 10945 , 2 , "Ljerka" , "Ivanković" , "Narednik" , STR_TO_DATE("1.7.1954.", "%d.%m.%Y.") , STR_TO_DATE("28.12.2013.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 5 ),
 ( 10946 , 2 , "Marta" , "Katić" , "Poručnik" , STR_TO_DATE("10.8.1969.", "%d.%m.%Y.") , STR_TO_DATE("24.10.2020.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 1 ),
 ( 10947 , 3 , "Dragica" , "Bošnjak" , "Poručnik" , STR_TO_DATE("6.12.1956.", "%d.%m.%Y.") , STR_TO_DATE("29.3.2012.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 5 ),
 ( 10948 , 1 , "Mina" , "Tomić" , "Pozornik" , STR_TO_DATE("15.4.1968.", "%d.%m.%Y.") , STR_TO_DATE("1.5.2014.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 1 ),
 ( 10949 , 4 , "Katalina" , "Šimunić" , "Narednik" , STR_TO_DATE("27.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("18.10.2010.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 4 ),
 ( 10950 , 2 , "Jaka" , "Bošnjak" , "Bojnik" , STR_TO_DATE("3.3.1953.", "%d.%m.%Y.") , STR_TO_DATE("1.3.2001.", "%d.%m.%Y.") , "Aktivan" , "B-" , 5 ),
 ( 10951 , 2 , "Lidija" , "Popović" , "Satnik" , STR_TO_DATE("1.8.1960.", "%d.%m.%Y.") , STR_TO_DATE("17.12.2015.", "%d.%m.%Y.") , "Mrtav" , "B-" , 5 ),
 ( 10952 , 3 , "Jura" , "Ivanković" , "Skupnik" , STR_TO_DATE("24.9.1958.", "%d.%m.%Y.") , STR_TO_DATE("7.12.1996.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 2 ),
 ( 10953 , 3 , "Anamarija" , "Vučković" , "Pozornik" , STR_TO_DATE("17.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("11.2.2016.", "%d.%m.%Y.") , "Mrtav" , "B+" , 1 ),
 ( 10954 , 2 , "Damjan" , "Petrović" , "Satnik" , STR_TO_DATE("30.5.1961.", "%d.%m.%Y.") , STR_TO_DATE("26.12.2017.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 2 ),
 ( 10955 , 3 , "Eli" , "Matković" , "Narednik" , STR_TO_DATE("24.11.1963.", "%d.%m.%Y.") , STR_TO_DATE("5.10.2002.", "%d.%m.%Y.") , "Umirovljen" , "0+" , 1 ),
 ( 10956 , 4 , "Tristan" , "Bašić" , "Razvodnik" , STR_TO_DATE("5.2.1963.", "%d.%m.%Y.") , STR_TO_DATE("2.3.2016.", "%d.%m.%Y.") , "Aktivan" , "0-" , 2 ),
 ( 10957 , 4 , "Lea" , "Galić" , "Pukovnik" , STR_TO_DATE("16.11.1970.", "%d.%m.%Y.") , STR_TO_DATE("6.12.2015.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 2 ),
 ( 10958 , 2 , "Erik" , "Dujmović" , "Satnik" , STR_TO_DATE("20.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("4.12.2015.", "%d.%m.%Y.") , "Umirovljen" , "AB+" , 2 ),
 ( 10959 , 1 , "Lovorka" , "Vukelić" , "Pukovnik" , STR_TO_DATE("19.5.1964.", "%d.%m.%Y.") , STR_TO_DATE("20.6.2018.", "%d.%m.%Y.") , "Umirovljen" , "A+" , 2 ),
 ( 10960 , 4 , "Kristina" , "Marić" , "Poručnik" , STR_TO_DATE("19.8.1970.", "%d.%m.%Y.") , STR_TO_DATE("12.9.2010.", "%d.%m.%Y.") , "Mrtav" , "0-" , 3 ),
 ( 10961 , 1 , "Regina" , "Božić" , "Razvodnik" , STR_TO_DATE("8.12.1965.", "%d.%m.%Y.") , STR_TO_DATE("2.1.1990.", "%d.%m.%Y.") , "Mrtav" , "B+" , 1 ),
 ( 10962 , 3 , "Ante" , "Kralj" , "Pukovnik" , STR_TO_DATE("1.10.1953.", "%d.%m.%Y.") , STR_TO_DATE("23.1.2019.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 1 ),
 ( 10963 , 3 , "Jeremija" , "Pavlić" , "Skupnik" , STR_TO_DATE("8.1.1964.", "%d.%m.%Y.") , STR_TO_DATE("14.2.1996.", "%d.%m.%Y.") , "Aktivan" , "AB+" , 2 ),
 ( 10964 , 2 , "Držislav" , "Lukić" , "Satnik" , STR_TO_DATE("3.5.1970.", "%d.%m.%Y.") , STR_TO_DATE("3.3.2004.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 4 ),
 ( 10965 , 2 , "Imani" , "Cvitković" , "Satnik" , STR_TO_DATE("5.5.1956.", "%d.%m.%Y.") , STR_TO_DATE("10.3.2007.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 2 ),
 ( 10966 , 1 , "Teresa" , "Golubić" , "Poručnik" , STR_TO_DATE("24.8.1961.", "%d.%m.%Y.") , STR_TO_DATE("10.1.1998.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 5 ),
 ( 10967 , 1 , "Fredo" , "Božić" , "Brigadir" , STR_TO_DATE("23.9.1960.", "%d.%m.%Y.") , STR_TO_DATE("12.2.2017.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 3 ),
 ( 10968 , 1 , "Krunoslav" , "Marjanović" , "Pozornik" , STR_TO_DATE("11.9.1958.", "%d.%m.%Y.") , STR_TO_DATE("5.4.2007.", "%d.%m.%Y.") , "Neaktivan" , "B-" , 5 ),
 ( 10969 , 1 , "Sven" , "Marušić" , "Pozornik" , STR_TO_DATE("25.2.1956.", "%d.%m.%Y.") , STR_TO_DATE("4.1.2012.", "%d.%m.%Y.") , "Umirovljen" , "AB-" , 3 ),
 ( 10970 , 4 , "Iris" , "Krznarić" , "Poručnik" , STR_TO_DATE("30.6.1956.", "%d.%m.%Y.") , STR_TO_DATE("25.6.1990.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 2 ),
 ( 10971 , 1 , "Moreno" , "Babić" , "Pukovnik" , STR_TO_DATE("28.6.1960.", "%d.%m.%Y.") , STR_TO_DATE("15.5.2001.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 5 ),
 ( 10972 , 4 , "Vladimir" , "Jovanović" , "Brigadir" , STR_TO_DATE("5.10.1966.", "%d.%m.%Y.") , STR_TO_DATE("16.4.1995.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 1 ),
 ( 10973 , 4 , "Dea" , "Živković" , "Brigadir" , STR_TO_DATE("7.9.1954.", "%d.%m.%Y.") , STR_TO_DATE("10.7.2009.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 5 ),
 ( 10974 , 2 , "Siri" , "Golubić" , "Razvodnik" , STR_TO_DATE("20.6.1959.", "%d.%m.%Y.") , STR_TO_DATE("17.8.2005.", "%d.%m.%Y.") , "Umirovljen" , "A-" , 4 ),
 ( 10975 , 1 , "Anabela" , "Đurđević" , "Brigadir" , STR_TO_DATE("31.1.1970.", "%d.%m.%Y.") , STR_TO_DATE("7.4.2010.", "%d.%m.%Y.") , "Mrtav" , "AB+" , 1 ),
 ( 10976 , 1 , "Elina" , "Katić" , "Pozornik" , STR_TO_DATE("5.10.1959.", "%d.%m.%Y.") , STR_TO_DATE("15.12.2000.", "%d.%m.%Y.") , "Neaktivan" , "A+" , 5 ),
 ( 10977 , 3 , "Otta" , "Burić" , "Skupnik" , STR_TO_DATE("24.4.1966.", "%d.%m.%Y.") , STR_TO_DATE("10.11.2012.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 3 ),
 ( 10978 , 2 , "Selina" , "Lončarić" , "Narednik" , STR_TO_DATE("11.3.1967.", "%d.%m.%Y.") , STR_TO_DATE("15.6.1994.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 4 ),
 ( 10979 , 1 , "Severino" , "Vidaković" , "Bojnik" , STR_TO_DATE("28.2.1962.", "%d.%m.%Y.") , STR_TO_DATE("10.2.2008.", "%d.%m.%Y.") , "Aktivan" , "0-" , 1 ),
 ( 10980 , 4 , "Ezekiel" , "Mitrović" , "Pukovnik" , STR_TO_DATE("6.10.1964.", "%d.%m.%Y.") , STR_TO_DATE("15.5.1993.", "%d.%m.%Y.") , "Aktivan" , "A-" , 3 ),
 ( 10981 , 3 , "Nikolina" , "Cindrić" , "Narednik" , STR_TO_DATE("12.8.1962.", "%d.%m.%Y.") , STR_TO_DATE("8.4.2010.", "%d.%m.%Y.") , "Aktivan" , "B+" , 3 ),
 ( 10982 , 4 , "Emil" , "Vuković" , "Razvodnik" , STR_TO_DATE("19.11.1952.", "%d.%m.%Y.") , STR_TO_DATE("1.1.2016.", "%d.%m.%Y.") , "Neaktivan" , "0+" , 4 ),
 ( 10983 , 4 , "Sumka" , "Jelić" , "Pukovnik" , STR_TO_DATE("5.2.1953.", "%d.%m.%Y.") , STR_TO_DATE("21.3.2011.", "%d.%m.%Y.") , "Umirovljen" , "0-" , 2 ),
 ( 10984 , 1 , "Anamarija" , "Marić" , "Razvodnik" , STR_TO_DATE("23.10.1955.", "%d.%m.%Y.") , STR_TO_DATE("5.7.1993.", "%d.%m.%Y.") , "Aktivan" , "A-" , 3 ),
 ( 10985 , 4 , "Rahela" , "Vidaković" , "Pukovnik" , STR_TO_DATE("2.10.1958.", "%d.%m.%Y.") , STR_TO_DATE("19.7.2012.", "%d.%m.%Y.") , "Aktivan" , "A+" , 1 ),
 ( 10986 , 1 , "Dijana" , "Radić" , "Poručnik" , STR_TO_DATE("7.11.1968.", "%d.%m.%Y.") , STR_TO_DATE("20.12.2018.", "%d.%m.%Y.") , "Aktivan" , "0+" , 1 ),
 ( 10987 , 2 , "Lovro" , "Jurković" , "Brigadir" , STR_TO_DATE("15.8.1962.", "%d.%m.%Y.") , STR_TO_DATE("19.9.2017.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 2 ),
 ( 10988 , 4 , "Leonida" , "Lončarić" , "Bojnik" , STR_TO_DATE("28.3.1962.", "%d.%m.%Y.") , STR_TO_DATE("10.5.1991.", "%d.%m.%Y.") , "Aktivan" , "A+" , 1 ),
 ( 10989 , 2 , "Eva" , "Abramović" , "Pozornik" , STR_TO_DATE("24.1.1966.", "%d.%m.%Y.") , STR_TO_DATE("11.5.1997.", "%d.%m.%Y.") , "Neaktivan" , "AB-" , 1 ),
 ( 10990 , 1 , "Evona" , "Crnković" , "Skupnik" , STR_TO_DATE("8.1.1951.", "%d.%m.%Y.") , STR_TO_DATE("20.5.2020.", "%d.%m.%Y.") , "Mrtav" , "B-" , 4 ),
 ( 10991 , 2 , "Aida" , "Šarić" , "Pozornik" , STR_TO_DATE("14.4.1960.", "%d.%m.%Y.") , STR_TO_DATE("2.6.2010.", "%d.%m.%Y.") , "Aktivan" , "0-" , 2 ),
 ( 10992 , 2 , "Katarina" , "Radić" , "Pukovnik" , STR_TO_DATE("4.11.1956.", "%d.%m.%Y.") , STR_TO_DATE("27.12.1994.", "%d.%m.%Y.") , "Umirovljen" , "B-" , 4 ),
 ( 10993 , 4 , "Lana" , "Krznarić" , "Satnik" , STR_TO_DATE("15.8.1958.", "%d.%m.%Y.") , STR_TO_DATE("20.9.1993.", "%d.%m.%Y.") , "Neaktivan" , "0-" , 3 ),
 ( 10994 , 2 , "Oskar" , "Matković" , "Skupnik" , STR_TO_DATE("17.6.1970.", "%d.%m.%Y.") , STR_TO_DATE("15.4.2014.", "%d.%m.%Y.") , "Aktivan" , "0+" , 3 ),
 ( 10995 , 3 , "Bena" , "Marković" , "Pozornik" , STR_TO_DATE("26.11.1955.", "%d.%m.%Y.") , STR_TO_DATE("25.11.2003.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 3 ),
 ( 10996 , 3 , "Marina" , "Marjanović" , "Skupnik" , STR_TO_DATE("27.3.1952.", "%d.%m.%Y.") , STR_TO_DATE("19.6.2003.", "%d.%m.%Y.") , "Neaktivan" , "AB+" , 5 ),
 ( 10997 , 1 , "Felicija" , "Herceg" , "Pozornik" , STR_TO_DATE("10.1.1958.", "%d.%m.%Y.") , STR_TO_DATE("29.4.2007.", "%d.%m.%Y.") , "Umirovljen" , "B+" , 4 ),
 ( 10998 , 3 , "Božana" , "Galić" , "Narednik" , STR_TO_DATE("1.6.1968.", "%d.%m.%Y.") , STR_TO_DATE("19.10.1995.", "%d.%m.%Y.") , "Mrtav" , "AB-" , 1 ),
 ( 10999 , 3 , "admin" , "admin" , "General" , STR_TO_DATE("4.9.1955.", "%d.%m.%Y.") , STR_TO_DATE("24.11.1995.", "%d.%m.%Y.") , "Pokojan u duši" , "A+" , 30 );




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
 ( 1100 , STR_TO_DATE("20.7.1991.  4:9:55", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("14.7.1991.  2:14:36", "%d.%m.%Y. %H:%i:%s") , 35),
 ( 1101 , STR_TO_DATE("27.2.1995.  6:15:59", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("5.8.1999.  23:16:47", "%d.%m.%Y. %H:%i:%s") , 18),
 ( 1102 , STR_TO_DATE("22.5.1997.  4:31:41", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("5.11.2000.  3:48:37", "%d.%m.%Y. %H:%i:%s") , 27),
 ( 1103 , STR_TO_DATE("9.6.1994.  23:25:56", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("22.4.1993.  23:23:29", "%d.%m.%Y. %H:%i:%s") , 23),
 ( 1104 , STR_TO_DATE("19.11.1993.  4:43:36", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("25.10.1999.  17:37:18", "%d.%m.%Y. %H:%i:%s") , 39 ),
 ( 1105 , STR_TO_DATE("5.8.1998.  19:35:30", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("13.8.1991.  11:25:21", "%d.%m.%Y. %H:%i:%s") , 25),
 ( 1106 , STR_TO_DATE("19.1.1996.  12:5:20", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("22.10.1998.  20:43:49", "%d.%m.%Y. %H:%i:%s") , 21 ),
 ( 1107 , STR_TO_DATE("2.5.1994.  11:18:29", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("19.1.1992.  22:23:59", "%d.%m.%Y. %H:%i:%s") , 38 ),
 ( 1108 , STR_TO_DATE("1.1.1996.  23:42:3", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("28.8.1992.  10:30:35", "%d.%m.%Y. %H:%i:%s") , 34 ),
 ( 1109 , STR_TO_DATE("21.6.1993.  23:55:36", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("1.6.1991.  14:56:42", "%d.%m.%Y. %H:%i:%s") , 30  ),
 ( 1110 , STR_TO_DATE("20.1.1992.  1:37:10", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("7.1.2000.  18:45:6", "%d.%m.%Y. %H:%i:%s") , 40 ),
 ( 1111 , STR_TO_DATE("12.8.1995.  19:48:17", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("21.9.1991.  15:4:3", "%d.%m.%Y. %H:%i:%s") , 29 ),
 ( 1112 , STR_TO_DATE("16.10.1991.  16:57:7", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("3.5.1998.  21:3:38", "%d.%m.%Y. %H:%i:%s") , 17 ),
 ( 1113 , STR_TO_DATE("20.5.1995.  20:28:58", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("5.12.1996.  12:50:1", "%d.%m.%Y. %H:%i:%s") , 37 ),
 ( 1114 , STR_TO_DATE("21.11.1997.  16:23:43", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("12.4.1992.  22:10:22", "%d.%m.%Y. %H:%i:%s") , 29  ),
 ( 1115 , STR_TO_DATE("12.11.1996.  6:21:9", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("2.5.1999.  14:44:2", "%d.%m.%Y. %H:%i:%s") , 41  ),
 ( 1116 , STR_TO_DATE("20.3.1994.  8:8:50", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("14.7.1995.  8:5:55", "%d.%m.%Y. %H:%i:%s") , 41 ),
 ( 1117 , STR_TO_DATE("18.1.1998.  19:16:34", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("1.10.1996.  12:37:13", "%d.%m.%Y. %H:%i:%s") , 41 ),
 ( 1118 , STR_TO_DATE("23.10.1996.  5:17:41", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("28.2.2000.  9:25:56", "%d.%m.%Y. %H:%i:%s") , 22  ),
 ( 1119 , STR_TO_DATE("15.5.1993.  22:56:17", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("23.1.2000.  6:1:44", "%d.%m.%Y. %H:%i:%s") , 41 ),
 ( 1120 , STR_TO_DATE("27.10.1992.  21:7:48", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("16.8.1992.  5:30:37", "%d.%m.%Y. %H:%i:%s") , 23 ),
 ( 1121 , STR_TO_DATE("20.5.1994.  9:8:49", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("2.11.2000.  13:35:57", "%d.%m.%Y. %H:%i:%s") , 22  ),
 ( 1122 , STR_TO_DATE("5.7.1995.  22:40:32", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("6.12.1991.  11:2:9", "%d.%m.%Y. %H:%i:%s") , 41 ),
 ( 1123 , STR_TO_DATE("20.4.1996.  3:52:12", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("5.8.1993.  6:14:51", "%d.%m.%Y. %H:%i:%s") , 39 ),
 ( 1124 , STR_TO_DATE("1.2.1998.  9:25:31", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("17.11.1994.  9:30:11", "%d.%m.%Y. %H:%i:%s") , 23 ),
 ( 1125 , STR_TO_DATE("28.8.1998.  9:16:47", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("21.6.1991.  14:33:47", "%d.%m.%Y. %H:%i:%s") , 35 ),
 ( 1126 , STR_TO_DATE("7.1.1994.  15:20:27", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("13.10.1996.  13:23:6", "%d.%m.%Y. %H:%i:%s") , 41 ),
 ( 1127 , STR_TO_DATE("16.6.1998.  3:33:10", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("28.5.2000.  12:4:16", "%d.%m.%Y. %H:%i:%s") , 28  ),
 ( 1128 , STR_TO_DATE("4.4.2000.  13:2:15", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("2.5.1992.  1:51:5", "%d.%m.%Y. %H:%i:%s") , 39 ),
 ( 1129 , STR_TO_DATE("23.12.1994.  11:9:8", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("6.5.2000.  23:43:55", "%d.%m.%Y. %H:%i:%s") , 20 ),
 ( 1130 , STR_TO_DATE("16.10.2000.  3:56:34", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("27.5.2000.  6:21:30", "%d.%m.%Y. %H:%i:%s") , 26 ),
 ( 1131 , STR_TO_DATE("19.7.1998.  23:52:10", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("9.1.2000.  7:20:0", "%d.%m.%Y. %H:%i:%s") , 31 ),
 ( 1132 , STR_TO_DATE("25.4.1996.  23:10:57", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("8.3.2000.  8:54:27", "%d.%m.%Y. %H:%i:%s") , 40 ),
 ( 1133 , STR_TO_DATE("28.10.1994.  21:39:14", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("20.4.1994.  18:12:41", "%d.%m.%Y. %H:%i:%s") , 40  ),
 ( 1134 , STR_TO_DATE("4.3.1991.  11:25:59", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("16.3.1998.  5:35:19", "%d.%m.%Y. %H:%i:%s") , 34  ),
 ( 1135 , STR_TO_DATE("13.5.1998.  23:25:6", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("20.8.1991.  4:19:41", "%d.%m.%Y. %H:%i:%s") , 30 ),
 ( 1136 , STR_TO_DATE("15.3.1991.  21:30:22", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("19.1.1991.  5:48:10", "%d.%m.%Y. %H:%i:%s") , 36 ),
 ( 1137 , STR_TO_DATE("22.5.1993.  11:55:28", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("12.2.1995.  16:58:45", "%d.%m.%Y. %H:%i:%s") , 27  ),
 ( 1138 , STR_TO_DATE("26.2.1997.  7:17:39", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("12.5.1996.  23:40:8", "%d.%m.%Y. %H:%i:%s") , 40 ),
 ( 1139 , STR_TO_DATE("26.2.1997.  14:36:47", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("22.9.1996.  10:5:50", "%d.%m.%Y. %H:%i:%s") , 41  ),
 ( 1140 , STR_TO_DATE("23.5.1995.  22:23:54", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("9.8.1993.  15:6:12", "%d.%m.%Y. %H:%i:%s") , 40  ),
 ( 1141 , STR_TO_DATE("5.5.1996.  6:14:47", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("3.3.2000.  6:36:38", "%d.%m.%Y. %H:%i:%s") , 17 ),
 ( 1142 , STR_TO_DATE("4.12.1993.  14:23:23", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("23.11.1996.  9:30:29", "%d.%m.%Y. %H:%i:%s") , 41  ),
 ( 1143 , STR_TO_DATE("25.9.1994.  3:50:8", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("11.7.1992.  16:38:58", "%d.%m.%Y. %H:%i:%s") , 17 ),
 ( 1144 , STR_TO_DATE("14.10.2000.  3:28:3", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("6.8.1998.  14:46:54", "%d.%m.%Y. %H:%i:%s") , 41 ),
 ( 1145 , STR_TO_DATE("7.11.1999.  22:26:4", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("20.3.2000.  19:58:33", "%d.%m.%Y. %H:%i:%s") , 18  ),
 ( 1146 , STR_TO_DATE("19.2.1998.  1:37:15", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("23.7.1998.  7:32:23", "%d.%m.%Y. %H:%i:%s") , 23 ),
 ( 1147 , STR_TO_DATE("12.6.1991.  11:19:55", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("28.2.1999.  14:48:19", "%d.%m.%Y. %H:%i:%s") , 33 ),
 ( 1148 , STR_TO_DATE("12.9.1994.  5:28:31", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("13.10.1994.  12:26:38", "%d.%m.%Y. %H:%i:%s") , 19  ),
 ( 1149 , STR_TO_DATE("6.9.1991.  6:14:44", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("27.12.1999.  5:17:57", "%d.%m.%Y. %H:%i:%s") , 34 ),
 ( 1150 , STR_TO_DATE("16.6.1991.  12:57:7", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("16.4.1999.  15:59:44", "%d.%m.%Y. %H:%i:%s") , 17 ),
 ( 1151 , STR_TO_DATE("12.11.1992.  16:36:7", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("10.5.1997.  22:52:18", "%d.%m.%Y. %H:%i:%s") , 41 ),
 ( 1152 , STR_TO_DATE("18.12.1997.  16:30:51", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("8.1.1993.  19:0:52", "%d.%m.%Y. %H:%i:%s") , 41 ),
 ( 1153 , STR_TO_DATE("23.2.1995.  11:23:13", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("19.11.1993.  3:35:37", "%d.%m.%Y. %H:%i:%s") , 27  ),
 ( 1154 , STR_TO_DATE("13.5.1999.  6:56:6", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("20.10.1997.  22:40:16", "%d.%m.%Y. %H:%i:%s") , 28 ),
 ( 1155 , STR_TO_DATE("16.9.1997.  19:46:42", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("15.1.1997.  7:32:50", "%d.%m.%Y. %H:%i:%s") , 41 ),
 ( 1156 , STR_TO_DATE("7.4.1996.  20:9:5", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("20.12.1994.  11:6:50", "%d.%m.%Y. %H:%i:%s") , 23 ),
 ( 1157 , STR_TO_DATE("8.10.1998.  22:51:15", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("23.3.1993.  1:40:43", "%d.%m.%Y. %H:%i:%s") , 27 ),
 ( 1158 , STR_TO_DATE("10.1.1991.  23:33:32", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("2.6.1995.  8:18:50", "%d.%m.%Y. %H:%i:%s") , 34 ),
 ( 1159 , STR_TO_DATE("11.3.1993.  4:28:8", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("17.1.1991.  3:33:45", "%d.%m.%Y. %H:%i:%s") , 23 ),
 ( 1160 , STR_TO_DATE("17.3.1996.  2:27:22", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("12.9.1995.  11:21:31", "%d.%m.%Y. %H:%i:%s") , 34  ),
 ( 1161 , STR_TO_DATE("26.2.1995.  16:20:34", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("8.9.1991.  22:15:42", "%d.%m.%Y. %H:%i:%s") , 29  ),
 ( 1162 , STR_TO_DATE("1.7.1998.  8:39:0", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("6.6.1992.  1:53:50", "%d.%m.%Y. %H:%i:%s") , 18 ),
 ( 1163 , STR_TO_DATE("23.8.1992.  16:30:29", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("1.2.1996.  6:37:15", "%d.%m.%Y. %H:%i:%s") , 30 ),
 ( 1164 , STR_TO_DATE("12.6.1992.  7:10:53", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("11.11.1993.  12:25:26", "%d.%m.%Y. %H:%i:%s") , 32  ),
 ( 1165 , STR_TO_DATE("6.4.1993.  8:22:41", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("19.9.1996.  4:25:15", "%d.%m.%Y. %H:%i:%s") , 27 ),
 ( 1166 , STR_TO_DATE("18.12.1996.  17:59:58", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("2.1.1994.  23:6:41", "%d.%m.%Y. %H:%i:%s") , 34 ),
 ( 1167 , STR_TO_DATE("21.11.1994.  21:21:53", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("27.6.1992.  2:55:20", "%d.%m.%Y. %H:%i:%s") , 23 ),
 ( 1168 , STR_TO_DATE("11.8.1999.  19:22:16", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("17.8.1995.  19:12:44", "%d.%m.%Y. %H:%i:%s") , 30  ),
 ( 1169 , STR_TO_DATE("17.10.2000.  5:5:4", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("18.4.1995.  6:15:2", "%d.%m.%Y. %H:%i:%s") , 23 ),
 ( 1170 , STR_TO_DATE("11.10.1997.  9:20:43", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("27.1.1992.  2:18:19", "%d.%m.%Y. %H:%i:%s") , 17 ),
 ( 1171 , STR_TO_DATE("19.9.1991.  18:7:9", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("27.12.1996.  12:47:10", "%d.%m.%Y. %H:%i:%s") , 31 ),
 ( 1172 , STR_TO_DATE("23.6.1994.  13:16:23", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("23.10.1994.  4:31:11", "%d.%m.%Y. %H:%i:%s") , 21 ),
 ( 1173 , STR_TO_DATE("8.7.1995.  20:2:22", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("14.2.1998.  11:58:54", "%d.%m.%Y. %H:%i:%s") , 17 ),
 ( 1174 , STR_TO_DATE("21.1.1992.  4:33:2", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("25.1.2000.  1:50:14", "%d.%m.%Y. %H:%i:%s") , 34 ),
 ( 1175 , STR_TO_DATE("17.4.1999.  15:36:55", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("26.4.1992.  14:48:20", "%d.%m.%Y. %H:%i:%s") , 17  ),
 ( 1176 , STR_TO_DATE("11.8.1997.  6:55:33", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("22.8.1993.  5:17:41", "%d.%m.%Y. %H:%i:%s") , 23  ),
 ( 1177 , STR_TO_DATE("20.12.1997.  8:8:9", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("1.11.1993.  9:14:9", "%d.%m.%Y. %H:%i:%s") , 33 ),
 ( 1178 , STR_TO_DATE("4.2.1992.  12:48:4", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("26.12.1999.  6:53:23", "%d.%m.%Y. %H:%i:%s") , 28 ),
 ( 1179 , STR_TO_DATE("18.8.1998.  20:3:1", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("26.11.1991.  16:37:9", "%d.%m.%Y. %H:%i:%s") , 39 ),
 ( 1180 , STR_TO_DATE("21.12.1998.  11:21:2", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("10.9.1991.  17:46:43", "%d.%m.%Y. %H:%i:%s") , 23  ),
 ( 1181 , STR_TO_DATE("21.8.1993.  12:2:34", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("19.5.2000.  13:28:31", "%d.%m.%Y. %H:%i:%s") , 40  ),
 ( 1182 , STR_TO_DATE("8.7.1994.  4:1:4", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("18.3.1994.  18:59:39", "%d.%m.%Y. %H:%i:%s") , 35 ),
 ( 1183 , STR_TO_DATE("21.11.1998.  23:42:5", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("26.11.1993.  14:19:40", "%d.%m.%Y. %H:%i:%s") , 23  ),
 ( 1184 , STR_TO_DATE("7.2.1995.  13:7:52", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("22.10.1998.  23:52:4", "%d.%m.%Y. %H:%i:%s") , 31 ),
 ( 1185 , STR_TO_DATE("10.12.1995.  17:10:58", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("16.12.1995.  17:25:29", "%d.%m.%Y. %H:%i:%s") , 23  ),
 ( 1186 , STR_TO_DATE("1.2.2000.  13:15:16", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("16.10.1992.  18:46:37", "%d.%m.%Y. %H:%i:%s") , 32 ),
 ( 1187 , STR_TO_DATE("21.8.1991.  16:23:30", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("1.3.1995.  22:56:27", "%d.%m.%Y. %H:%i:%s") , 17 ),
 ( 1188 , STR_TO_DATE("11.9.1991.  6:52:17", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("15.9.1994.  18:9:25", "%d.%m.%Y. %H:%i:%s") , 41 ),
 ( 1189 , STR_TO_DATE("15.2.1993.  3:39:53", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("1.9.1999.  15:25:59", "%d.%m.%Y. %H:%i:%s") , 20 ),
 ( 1190 , STR_TO_DATE("5.6.1998.  11:14:52", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("1.6.2000.  16:14:1", "%d.%m.%Y. %H:%i:%s") , 31 ),
 ( 1191 , STR_TO_DATE("5.5.1997.  23:32:1", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("20.1.1993.  4:49:19", "%d.%m.%Y. %H:%i:%s") , 33 ),
 ( 1192 , STR_TO_DATE("8.7.1999.  7:42:45", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("18.4.1998.  18:13:31", "%d.%m.%Y. %H:%i:%s") , 29 ),
 ( 1193 , STR_TO_DATE("21.10.1998.  3:12:39", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("16.10.1995.  2:37:37", "%d.%m.%Y. %H:%i:%s") , 30  ),
 ( 1194 , STR_TO_DATE("6.4.1999.  1:53:1", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("23.8.1994.  17:13:30", "%d.%m.%Y. %H:%i:%s") , 17 ),
 ( 1195 , STR_TO_DATE("13.2.1991.  6:30:50", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("10.3.1999.  23:18:35", "%d.%m.%Y. %H:%i:%s") , 41  ),
 ( 1196 , STR_TO_DATE("28.10.1994.  21:13:0", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("13.10.1992.  13:21:47", "%d.%m.%Y. %H:%i:%s") , 22  ),
 ( 1197 , STR_TO_DATE("15.12.1999.  10:8:59", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("5.4.1998.  1:46:44", "%d.%m.%Y. %H:%i:%s") , 40  ),
 ( 1198 , STR_TO_DATE("4.9.2000.  6:42:53", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("20.6.1993.  7:38:53", "%d.%m.%Y. %H:%i:%s") , 16  ),
 ( 1199 , STR_TO_DATE("4.8.1997.  16:42:15", "%d.%m.%Y. %H:%i:%s") , STR_TO_DATE("3.9.1992.  9:4:47", "%d.%m.%Y. %H:%i:%s") , 23  );


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








-- FUNKCIJE:

-- DK
-- Funkcija vraca ukupni trosak

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



-- Funkcija racuna koliko je novca ostalo "viska" iz proracuna:

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



-- Funkcija koja vraća broj osoblja koje je imalo uvijek perofrmans na treningu viši od 6 te da nikad nisu bili na liječenju.

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


/*
Za određeni id osoblja treba se dati tekstualni odgovor u čemu je sve osoba sujelovala. 
Npr. "Arabela Herceg je sudjelovala u najmanje jednoj/m: treningu i lijecenju."
Moguće je više kombinacija, a najduža je npr "Arabela Herceg je sudjelovao/la u najmanje 
jednoj: turi, misiji,treningu i lijecenju." U slučaju da osoba nije sudjelovala još uvijek u ničemu bit će ispisano npr 
"Arabela Herceg nije sudjelovao/la ni u jednoj: turi, misiji,treningu ili lijecenju."
*/


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





/*
Performans na treningu može bit od 1 do 10 ([1,10]). Želi se pratiti koliki je bio broj osoblja po određenom činu s pojedinom
ocijenom performansa. Ne treba prikazat čin čije osoblje uopće nije dio tog performansa.
Format treba izgledat kao:
performans   cinovi_i_br_pojavljivanja
10            skupnik: 3 , brigadir: 3 , bojnik: 1 , pukovnik: 1 , poručnik: 2 , narednik: 2 
9             pozornik: 1 , narednik: 2 , bojnik: 3 , satnik: 1 , brigadir: 2 , poručnik: 2 , skupnik: 1 , razvodnik: 1 
...           ...
*/

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



-- MK

-- Jednostavna funkcija koja vraća broj osoblja u određenom sektoru
DELIMITER //
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

SELECT broj_osoblja_u_sektoru(1) AS broj_osoblja_u_sektoru;

-- Primjer funkcije koja koristi while loop, imamo varijable u koje cemo spremati potrebne podatke i imamo veliki varchar u koji će ići rezultat, sa jednostavnim while loopom smo prosli kroz sve id-eve sektora te u svakoj iteraciji vezali rezultat sa concatom
/*
DROP FUNCTION IF EXISTS prosjecna_ocjena_po_sektoru;

DELIMITER //
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
        GROUP BY id ASC
        LIMIT 1;

	WHILE p_id_sektor IS NOT NULL DO

		SELECT COUNT(*) INTO broj_osoblja 
			FROM osoblje 
				WHERE id_sektor = p_id_sektor;
		SELECT SUM(ocjena) INTO sum_ocjena 
			FROM osoblje 
				WHERE id_sektor = p_id_sektor;
                
		SET prosjek = sum_ocjena / broj_osoblja;

		SET rezultat = CONCAT(rezultat, 'Sektor ', (SELECT naziv FROM sektor AS s WHERE s.id =p_id_sektor LIMIT 1), ': ', prosjek);

		SELECT id INTO p_id_sektor
			FROM sektor WHERE id > p_id_sektor 
				ORDER BY id ASC
                LIMIT 1;
	END WHILE;
    
    RETURN rezultat;
END//
DELIMITER ;
SELECT prosjecna_ocjena_po_sektoru() AS rezultat;
*/







-- varijacija prijašnje funkcije samo što sam koristio kursor i repeat čisto za promjenu :) masu vremena su mi potrošila ova dva
DROP FUNCTION IF EXISTS trosak_misija_po_sektoru;

DELIMITER //
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

SELECT trosak_misija_po_sektoru();



-- primjer funkcije koja poziva drugu funkciju, jedna provjerava je li ta osoba na misiji tj. gleda postoji li ongoing misija gdje je ta osoba te vraca true or false
-- onda sa tom informacijom i provjerom dobi sa selekcijom u glavnoj funkciji odlućujemo je li dobar odabir za misiju :)
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

SELECT dostupnost_za_misiju(10360, 100) AS dostupnost_za_misiju;



-- PROCEDURE:
	
-- DK
-- Za određeni id_osoblja treba vratit koliko je sati proveo/la na misiji, na treningu a koliko na liječenju.

DROP PROCEDURE IF EXISTS sati_provedeno_osoblje;

DELIMITER //
CREATE PROCEDURE sati_provedeno_osoblje(IN id_os INTEGER, OUT misija_h INTEGER, OUT trening_h INTEGER, OUT lijecenje_h INTEGER)
DETERMINISTIC
BEGIN

	SELECT SUM(TIMESTAMPDIFF(DAY, vrijeme_pocetka, vrijeme_kraja)) INTO misija_h
    FROM misija
    INNER JOIN osoblje_na_misiji
    ON misija.id = osoblje_na_misiji.id_misija
    WHERE id_osoblje = id_os;
    
    SELECT IFNULL(misija_h, 0) INTO misija_h;
    
    SELECT SUM(TIMESTAMPDIFF(DAY, vrijeme_pocetka, vrijeme_kraja)) INTO trening_h
    FROM trening
    INNER JOIN osoblje_na_treningu
    ON trening.id = osoblje_na_treningu.id_trening
    WHERE id_osoblje = id_os;
    
    SELECT IFNULL(trening_h, 0) INTO trening_h;
    
    SELECT SUM(TIMESTAMPDIFF(DAY, pocetak_lijecenja, kraj_lijecenja)) INTO lijecenje_h
    FROM lijecenje
    WHERE id_osoblje = id_os;

	SELECT IFNULL(lijecenje_h, 0) INTO lijecenje_h;

END//
DELIMITER ;

CALL sati_provedeno_osoblje(10322, @h_m, @h_t, @h_l);
SELECT @h_m AS sati_provedeni_na_misiji, @h_t AS sati_provedeni_na_treningu, @h_l AS sati_provedeni_na_lijecenju FROM DUAL;  
     
     
     
  /*
  Za određeni iznos novca se gleda da li bi taj novac mogao pokriti troškove najmanje pola misija te vraća odgovor
  'DA' ili 'NE'
  */
     
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
     
     

            
            /*
Ispisati koliki je broj osoblja, vozila, opreme trenutačno dostupno(3 vrijednosti) u danom intervalu (dva datuma
koje korisnik izabere kao ulazne argumente          																				*/

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






/*
Za dva vremenski intervala (pojedini će biti određen s dvije datumske vrijednosti) se mora odrediti  pojedinačni 
ukupni trošak za misije, ukupni trošak za popravak, ukupni trošak za liječenje te usporedit. 
Ispis treba biti u obliku:
	Vremensko razdoblje od 1.10.1991. do 11.07.1998. ima manji trošak kada je riječ o misijama u usporedbi s razdobljem od 23.04.1997. do 2.12.2001..
    Vremensko razdoblje od 23.04.1997. do 2.12.2001. ima manji trošak kada je riječ o popravcima u usporedbi s razdobljem od 1.10.1991. do 11.07.1998..
    Vremensko razdoblje od 1.10.1991. do  11.07.1998. ima manji trošak kada je riječ liječenju u usporedbi s razdobljem od 23.04.1997. do 2.12.2001..
*/

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



/*
Treba odrediti koje misije su održane na području sjeverne polutke, a koje na području južne polutke. Prilikom 
navoda se koristi naziv misije. Format mora bit sličan: 
  Misije održane na sjevernoj polutci: naziv1, naziv2, ...
  Misije održane na južnoj polutci: naziv1, naziv2, ...
  Misije održane na ekvatoru: naziv1, naziv2, ...
*/

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



-- MK

-- jednostavna procedura za promjenu statusa osoblja. Ima 2 IN parametra jedan za ID i jedan za status te koristi jednostavnu update komandu da promjeni status
DELIMITER //
CREATE PROCEDURE promjena_statusa_osoblja(IN p_id_osoblje INT, IN p_status_osoblja VARCHAR(50))
BEGIN
	UPDATE osoblje
		SET status_osoblja = p_status_osoblja
			WHERE id = p_id_osoblje;
END//
DELIMITER ;



-- procedura za pogledati svo aktivno osoblje koje se trenutno nalazi na misiji preko jednostavnog upita koji spaja nekoliko tablica sa inner joinom
DROP PROCEDURE IF EXISTS svo_osoblje_na_misiji;

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

CALL svo_osoblje_na_misiji();


-- primjer procedure koji ovisno o performansi na zadnjem treningu povecava ocjenu ili ju smanjuje i onda preporucuje da osoblje dobije promociju ili ne
DELIMITER //
CREATE PROCEDURE provjera_promocija_sniženje_cin(IN p_id_osoblje INT)
BEGIN
    DECLARE p_ocjena INT;
    DECLARE p_performans INT;

    SELECT ocjena INTO p_ocjena
		FROM osoblje
			WHERE id = p_id_osoblje;
	
	SELECT performans INTO p_performans
        FROM osoblje_na_treningu
			WHERE id_osoblje = p_id_osoblje AND datum_kraja IS NOT NULL
			ORDER BY datum_pocetka DESC
			LIMIT 1;

    IF p_performans < 4 THEN
        SET p_ocjena = ocjena - 5;
    ELSEIF p_performans < 5 THEN
        SET p_ocjena = ocjena - 3;
    ELSEIF p_performans < 6 THEN
        SET p_ocjena = ocjena - 1;
    ELSEIF p_performans >= 9 THEN
        SET p_ocjena = ocjena + 5;
    ELSEIF p_performans >= 8 THEN
        SET p_ocjena = ocjena + 3;
    ELSEIF p_performans >= 7 THEN
        SET p_ocjena = ocjena + 1;
    END IF;

	IF p_ocjena < 1 THEN
		SET p_ocjena = 1;
		SIGNAL SQLSTATE '40000'
			SET MESSAGE_TEXT = 'Ocjena je prešla najniže prihvatljive razine te se preporućuje sniženje čina';
	ELSEIF p_ocjena > 5 THEN
		SET p_ocjena = 5;
		SIGNAL SQLSTATE '40000'
			SET MESSAGE_TEXT = 'Ocjena je prešla najvišu razinu te se preporućuje povečanje čina';
	ELSE
		UPDATE osoblje
			SET ocjena = p_ocjena
				WHERE id = p_id_osoblje;
	END IF;
END//
DELIMITER ;


-- promjeni status osoblja ako nije bio na treningu ili na turi u zadnjih godinu dana
DELIMITER //
CREATE PROCEDURE promjena_statusa_na_neaktivan()
BEGIN
    UPDATE osoblje
    SET status_osoblja = 'neaktivan'
    WHERE status_osoblja = 'aktivan' AND id NOT IN (SELECT id_osoblje FROM osoblje_na_turi WHERE datum_kraja > DATE_SUB(NOW(), INTERVAL 1 YEAR)) AND id NOT IN (SELECT id_osoblje FROM osoblje_na_treningu WHERE datum_kraja > DATE_SUB(NOW(), INTERVAL 1 YEAR));
END //
DELIMITER ;


-- Svo osoblje u određenom sektoru koje nije mrtvo 
DELIMITER //
CREATE PROCEDURE ukupno_osoblje_u_sektoru(IN p_id_sektor INT)
BEGIN
    SELECT COUNT(*)
    FROM osoblje
    WHERE id_sektor = p_id_sektor;
END//
DELIMITER ;

CALL ukupno_osoblje_u_sektoru(1);