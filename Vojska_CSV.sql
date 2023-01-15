DROP DATABASE IF EXISTS vojska;
CREATE DATABASE vojska;
USE vojska;


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
	ADD CONSTRAINT ck_duzsir UNIQUE(zemljopisna_duzina, zemljopisna_sirina),
        ADD CONSTRAINT ck_naziv UNIQUE(naziv);
	

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
    ishod TEXT,   
    trosak_misije NUMERIC(15, 2) NOT NULL,
    FOREIGN KEY (id_lokacija) REFERENCES lokacija(id) ON DELETE CASCADE,
    FOREIGN KEY (id_tura) REFERENCES tura(id) ON DELETE CASCADE
);
-- DROP TABLE misija;

ALTER TABLE misija
	ADD CONSTRAINT ck_trosak CHECK(trosak_misije>=0),
    ADD CONSTRAINT naziv_misija_ck UNIQUE(naziv);


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
    kapacitet INTEGER NOT NULL

);
-- DROP TABLE vozila;
ALTER TABLE vozila
	ADD CONSTRAINT ck_uk_kolicina CHECK(ukupna_kolicina>0),
    ADD CONSTRAINT ck_kapacitet CHECK(kapacitet>0);


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


CREATE TABLE oprema(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(50) NOT NULL,
    vrsta VARCHAR(50) NOT NULL,
    ukupna_kolicina INTEGER NOT NULL
);
-- DROP TABLE oprema;
ALTER TABLE oprema
	ADD CONSTRAINT ck_uk_kolicina1 CHECK(ukupna_kolicina>0);


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

CREATE TABLE trening(
    id INTEGER PRIMARY KEY,
    vrijeme_pocetka DATETIME NOT NULL,
    vrijeme_kraja DATETIME NOT NULL,
    id_lokacija INTEGER NOT NULL,
    FOREIGN KEY (id_lokacija) REFERENCES lokacija(id) ON DELETE CASCADE
);
-- DROP TABLE trening;


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


-- OKIDAČI:
	
 -- DK   

/*
Datum početka ture ne može biti veći ili jednak od datuma kraja ture. U slučaju da je kraj NULL to 
znači da je tura još uvijek u tijeku. Riječ je o UPDATE-u. 
*/

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



/*
Datum početka misije ne može biti veći ili jednak od datuma kraja misije. U slučaju da je kraj NULL to 
znači da je misija još uvijek u tijeku. Riječ je o UPDATE-u.    
*/

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




/*
Datum početka sudjelovanja osoblja na turi ne može biti veći ili jednak od datuma kraja sudjelovanja. U slučaju 
da je kraj NULL to znači da osoba još uvijek sudjeluje u turi. Riječ je o UPDATE-u.  
*/

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




/*
Datum početka popravka ne može biti veći ili jednak od datuma kraja popravka. U slučaju da je kraj NULL to 
znači da je popravak još uvijek u tijeku. Riječ je o INSERT-u. 
*/

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



/*
Datum početka treninga ne može biti veći ili jednak od datuma kraja treninga te trening bi najmanje
trebao trajat 20 minuta. Riječ je o INSERT-u.  
*/

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
Datum početka liječenja ne može biti veći ili jednak od datuma kraja liječenja kada je 
riječ o INSERT-u. U slučaju je datum kraja liječenja NULL to znači da je liječenje još uvijek u tijeku.    
*/

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




/*
Prati se da zbroj količine željene izdane opreme ne bude veći od sveukupne moguće količine opreme tijekom INSERT-a. 
Prati se da u određenom razdoblju tj. misiji to ne bude prekoračeno. 
*/

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
Prati se da zbroj izdane količine ne bude veći od sveukupne moguće količine opreme tijekom UPDATE-a. 
Prati se da u određenom razdoblju tj. misiji to ne bude prekoračeno.
*/

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
	IF NEW.vrijeme_kraja != NULL THEN
		UPDATE osoblje
			SET status_osoblja = "Neaktivan" WHERE id IN (SELECT id_osoblje FROM osoblje_na_turi WHERE id_tura = NEW.id AND datum_kraja IS NULL);
	END IF;
END//
DELIMITER ;



-- Ovaj trigger postavlja datum_kraja osoblja na turi na isti datum kraja ko i tura koja je završila samo ako to osoblje na turi ima datum_kraja NULL tj. nije se povuklo prije kraja ture i ostalo je tijekom cijele ture
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


-- kada vojnik ide na misiju poslužuje se tom osoblju na misiji osnovnu opremu, imamo funkciju koja provjerava dostupne id-eve te ih vraca u trigger kako bi mogli izvesti uspjesan insert. Također ima 
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
/* OVAJ TRIGGER POKRENUTI NAKON BAZE PODATAKA INACE NECE RADITI
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
DELIMITER ; */
-- SELECT * FROM izdana_oprema;
-- INSERT INTO osoblje_na_misiji VALUES (4100, 10631, 3016);

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


-- Provjerava je li osoblje koje se salje na misiju uopce dostupno s time da broji koliko ima aktivnih misija tj. koliko misija kojima je datum kraja na NULL
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



LOAD DATA INFILE 'D:/ZABAZE/BP2---Vojska/CSV/sektor.csv' INTO TABLE sektor
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, naziv, datum_osnivanja, opis, ukupni_proracun)
SET datum_osnivanja = STR_TO_DATE(datum_osnivanja, '%Y-%m-%d');


LOAD DATA INFILE 'D:/ZABAZE/BP2---Vojska/CSV/lokacija.csv' INTO TABLE lokacija
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


LOAD DATA INFILE 'D:/ZABAZE/BP2---Vojska/CSV/osoblje.csv' INTO TABLE osoblje
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,id_sektor,ime,prezime,cin,datum_rodenja,datum_uclanjenja,status_osoblja,krvna_grupa,ocjena)
SET datum_rodenja = STR_TO_DATE(datum_rodenja, '%Y-%m-%d'), datum_uclanjenja = STR_TO_DATE(datum_uclanjenja, '%Y-%m-%d');

LOAD DATA INFILE 'D:/ZABAZE/BP2---Vojska/CSV/tura.csv' INTO TABLE tura
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,naziv,vrsta_ture,vrijeme_pocetka,vrijeme_kraja)
SET vrijeme_pocetka = STR_TO_DATE(vrijeme_pocetka, '%Y-%m-%d %H:%i:%s'), vrijeme_kraja = STR_TO_DATE(vrijeme_kraja, '%Y-%m-%d %H:%i:%s');

LOAD DATA INFILE 'D:/ZABAZE/BP2---Vojska/CSV/misija.csv' INTO TABLE misija
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,naziv,vrijeme_pocetka,vrijeme_kraja,id_lokacija,id_tura,ishod,trosak_misije)
SET vrijeme_pocetka = STR_TO_DATE(vrijeme_pocetka, '%Y-%m-%d %H:%i:%s'), vrijeme_kraja = STR_TO_DATE(vrijeme_kraja, '%Y-%m-%d %H:%i:%s');

LOAD DATA INFILE 'D:/ZABAZE/BP2---Vojska/CSV/osoblje_na_misiji.csv' INTO TABLE osoblje_na_misiji
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,id_osoblje,id_misija);

LOAD DATA INFILE 'D:/ZABAZE/BP2---Vojska/CSV/osoblje_na_turi.csv' INTO TABLE osoblje_na_turi
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,id_osoblje,id_tura,datum_pocetka,datum_kraja)
SET datum_pocetka = STR_TO_DATE(datum_pocetka, '%Y-%m-%d %H:%i:%s'), datum_kraja = STR_TO_DATE(datum_kraja, '%Y-%m-%d %H:%i:%s');

LOAD DATA INFILE 'D:/ZABAZE/BP2---Vojska/CSV/vozila.csv' INTO TABLE vozila
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,naziv,vrsta,ukupna_kolicina,kapacitet);


LOAD DATA INFILE 'D:/ZABAZE/BP2---Vojska/CSV/vozilo_na_misiji.csv' INTO TABLE vozilo_na_misiji
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,id_vozilo,kolicina,id_misija);


LOAD DATA INFILE 'D:/ZABAZE/BP2---Vojska/CSV/vozilo_na_turi.csv' INTO TABLE vozilo_na_turi
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,id_vozilo,id_tura,id_odgovorni,kolicina);
LOAD DATA INFILE 'D:/ZABAZE/BP2---Vojska/CSV/popravak.csv' INTO TABLE popravak
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,id_vozilo_na_misiji,opis_stete,pocetak_popravka,kraj_popravka,trosak_popravka)
SET pocetak_popravka = STR_TO_DATE(pocetak_popravka, '%Y-%m-%d %H:%i:%s'), kraj_popravka = STR_TO_DATE(kraj_popravka, '%Y-%m-%d %H:%i:%s');


LOAD DATA INFILE 'D:/ZABAZE/BP2---Vojska/CSV/oprema.csv' INTO TABLE oprema
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,naziv,vrsta,ukupna_kolicina);


LOAD DATA INFILE 'D:/ZABAZE/BP2---Vojska/CSV/izdana_oprema.csv' INTO TABLE izdana_oprema
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,id_oprema,id_osoblje_na_misiji,izdana_kolicina);


LOAD DATA INFILE 'D:/ZABAZE/BP2---Vojska/CSV/trening.csv' INTO TABLE trening
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,vrijeme_pocetka,vrijeme_kraja,id_lokacija)
SET vrijeme_pocetka = STR_TO_DATE(vrijeme_pocetka, '%Y-%m-%d %H:%i:%s'), vrijeme_kraja = STR_TO_DATE(vrijeme_kraja, '%Y-%m-%d %H:%i:%s');


LOAD DATA INFILE 'D:/ZABAZE/BP2---Vojska/CSV/osoblje_na_treningu.csv' INTO TABLE osoblje_na_treningu
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,id_osoblje,id_trening,performans);


LOAD DATA INFILE 'D:/ZABAZE/BP2---Vojska/CSV/lijecenje.csv' INTO TABLE lijecenje
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,id_osoblje,status_lijecenja,pocetak_lijecenja,kraj_lijecenja,opis_ozljede,trosak_lijecenja)
SET pocetak_lijecenja = STR_TO_DATE(pocetak_lijecenja, '%Y-%m-%d %H:%i:%s'), kraj_lijecenja = STR_TO_DATE(kraj_lijecenja, '%Y-%m-%d %H:%i:%s');





-- UPITI (& POGLEDI):

-- DK
/*
Prikaži id, ime i prezime 10 osoba koje su imale najveći performans na treningu, a preduvjet za njihovo pojavljivanje 
na listi je da su bile na barem jednoj misiji koja u svom intervalu održavanja ima najmanje jedan dan u 12. mjesecu.
*/	

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


/*
Prikaži id, ime, prezime i čin osobe koja je bila odgovorna za vozilo vrste "Helikopteri" koje je bilo na najviše popravaka.
*/

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



/*
Prikaži naziv ture kod koje je izdano najmanje opreme.
*/

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



/*
Prikaži ukupni proračun sektora koji ima drugi najveći broj osoblja koji nisu bili na liječenju niti jedanput 
te koji su sudjelovali na najmanje jednom treningu čiji datum početka nije bio prije 23 godinu dana od sada.
*/

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



/*
Prikaži nazive misija i njene lokacije, ali samo za misije u kojima je sudjelovalo osoblje starije od 31 godinu 
i koje je bilo odgovorno za najmanje jedno vozilo u nekoj turi.
*/

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



/*
Treba se napraviti pogled koji će prikazat dodatne podatke vezane uz turu. Treba se prikazat od koliko se misija 
ta tura sastoji, koliki je trošak ture, broj osoblja koji je sudjelovao, broj opreme koji je određen za tu turu 
te broj vozila koji je određen za tu turu. Ovi dodatni prikazi će biti za ture koje sadrže barem jedan od navedenih podataka.
*/

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



/*
Treba se napraviti pogled koji će prikazat dodatne podatke vezane uz misiju. Treba se prikazat koliki 
je trošak misije, broj osoblja koji je sudjelovao, broj opreme koji je određen za tu misiju te broj 
vozila koji je određen za tu misiju. Ovi dodatni prikazi će biti za misije koje sadrže barem jedan od navedenih podataka.
*/

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



/*
Treba se napraviti pogled koji će prikazat koliko je puta pojedina osoba bila na treningu, misiji i liječenju.
*/

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




-- JB

-- navedi sva imena i prezimena ozlijedenih vojnika na misiji kojima lijecenje kosta vise od 10000
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

-- nabroji sva vozila na popravku koja su ujedno i na misiji "Vitez" te ih nabroji koliko ih je
select sum(ukupna_kolicina) as totalni_br
from vozila as v
inner join vozilo_na_misiji as vnm
on v.id=vnm.id_vozilo
inner join misija as m
on m.id=vnm.id_misija
where m.naziv="Vitez";

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


-- pogled koji nam prikazuje sve ture koje imaju kolicinu vozila vecu od 10

CREATE VIEW puno_vozila AS
SELECT t.naziv, vnt.kolicina
FROM tura as t
JOIN vozilo_na_turi as vnt ON t.id = vnt.id_tura
HAVING vnt.kolicina > 10;

-- pogled koji ima svo osoblje na misiji cija je ocjena 5
CREATE VIEW visoke_ocjene	 AS
SELECT ime,prezime,ocjena
FROM osoblje AS o
JOIN osoblje_na_misiji AS onm ON o.id = onm.id_osoblje
HAVING ocjena = 5;





-- FUNKCIJE:

-- DK
/*
Treba napraviti funkciju koja računa ukupan trošak.
*/

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


/*
Treba napraviti funkciju koja računa koliko je novca ostalo "viška" iz proračuna.
*/

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



/*
Funkcija koja vraća broj osoblja koje je imalo uvijek perofrmans na treningu viši od 6 te da nikad nisu bili na liječenju.
*/

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
Za određeni id osoblja treba se dati tekstualni odgovor u čemu je sve osoba sujelovala.  Npr. "Arabela Herceg 
je sudjelovala u najmanje jednoj/m: treningu i lijecenju." Moguće je više kombinacija, a najduža je 
npr "Arabela Herceg je sudjelovao/la u najmanje jednoj: turi, misiji,treningu i lijecenju." U slučaju da osoba 
nije sudjelovala još uvijek u ničemu bit će ispisano npr "Arabela Herceg nije sudjelovao/la ni u jednoj: turi, 
misiji,treningu ili lijecenju."
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
Performans na treningu može bit od 1 do 10 ([1,10]). Želi se pratiti za pojedini performans 
koliko je puta osoblje po određenim činom imalo taj performans. Ne treba prikazat čin čije 
osoblje nikad nije bilo dio te skupine performansa. Format treba izgledat kao:
performans   cinovi_i_br_zadanog_performansa
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
DROP FUNCTION IF EXISTS broj_osoblja_u_sektoru;

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
DELIMITER ;
SELECT prosjecna_ocjena_po_sektoru() AS rezultat;





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
/*
Za određeni id_osoblja treba vratit koliko je sati proveo/la na misiji, na treningu a koliko na liječenju.
*/

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




/*
Za određeni iznos novca se gleda da li bi taj novac mogao pokriti troškove najmanje pola misija te vraća odgovor 'DA' ili 'NE'
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
Treba ispisati koliki je broj osoblja, vozila, opreme trenutačno dostupno (3 vrijednosti) u danom 
intervalu (dva datuma koje korisnik izabere kao ulazne argumente.
*/

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
Za dva vremenski intervala (pojedini će biti određen s dvije datumske vrijednosti) se mora odrediti pojedinačni ukupni trošak za misije, 
ukupni trošak za popravak, ukupni trošak za liječenje te usporedit. Ispis treba biti u obliku:
	Vremensko razdoblje od 1.10.1991. do 11.07.1998. ima manji trošak kada je riječ o misijama u usporedbi s razdobljem od 23.04.1997. do 2.12.2001.
    Vremensko razdoblje od 23.04.1997. do 2.12.2001. ima manji trošak kada je riječ o popravcima u usporedbi s razdobljem od 1.10.1991. do 11.07.1998.
    Vremensko razdoblje od 1.10.1991. do  11.07.1998. ima manji trošak kada je riječ liječenju u usporedbi s razdobljem od 23.04.1997. do 2.12.2001.
*/

DROP PROCEDURE IF EXISTS usporedba;

DELIMITER //
CREATE PROCEDURE usporedba(IN prvi_datum_p DATETIME, IN prvi_datum_k DATETIME, IN drugi_datum_p DATETIME, 
IN drugi_datum_k DATETIME, OUT txt_mi VARCHAR(200), OUT txt_po VARCHAR(200), OUT txt_li VARCHAR(200))
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
		SET txt_mi = CONCAT("Vremensko razdoblje od ", prvi_datum_p," do ", prvi_datum_k, " ima isti trošak kada je riječ o misijama u 
        usporedbi s razdobljem od ",  drugi_datum_p, " do ", drugi_datum_k);
	ELSEIF prvo_misija > drugo_misija THEN
		SET txt_mi = CONCAT("Vremensko razdoblje od ", prvi_datum_p," do ", prvi_datum_k, " ima veći trošak kada je riječ o misijama u 
        usporedbi s razdobljem od ",  drugi_datum_p, " do ", drugi_datum_k);
	ELSE
		SET txt_mi = CONCAT("Vremensko razdoblje od ", prvi_datum_p," do ", prvi_datum_k, " ima manji trošak kada je riječ o misijama u 
        usporedbi s razdobljem od ",  drugi_datum_p, " do ", drugi_datum_k);
	END IF;
    
    
	SELECT SUM(trosak_popravka) INTO prvo_popravak
    FROM popravak
    WHERE pocetak_popravka >= prvi_datum_p AND kraj_popravka <= prvi_datum_k;
    
    SELECT SUM(trosak_popravka) INTO drugo_popravak
    FROM popravak
    WHERE pocetak_popravka >= drugi_datum_p AND kraj_popravka <= drugi_datum_k;
    
    IF prvo_popravak = drugo_popravak THEN
		SET txt_po = CONCAT("Vremensko razdoblje od ", prvi_datum_p," do ", prvi_datum_k, " ima isti trošak kada je riječ o popravcima u 
        usporedbi s razdobljem od ",  drugi_datum_p, " do ", drugi_datum_k);
	ELSEIF prvo_popravak > drugo_popravak THEN
		SET txt_po = CONCAT("Vremensko razdoblje od ", prvi_datum_p," do ", prvi_datum_k, " ima veći trošak kada je riječ o popravcima u 
        usporedbi s razdobljem od ",  drugi_datum_p, " do ", drugi_datum_k);
	ELSE
		SET txt_po = CONCAT("Vremensko razdoblje od ", prvi_datum_p," do ", prvi_datum_k, " ima manji trošak kada je riječ o popravcima u 
        usporedbi s razdobljem od ",  drugi_datum_p, " do ", drugi_datum_k);
	END IF;
    
    
    SELECT SUM(trosak_lijecenja) INTO prvo_lijecenje
    FROM lijecenje
    WHERE pocetak_lijecenja >= prvi_datum_p AND kraj_lijecenja <= prvi_datum_k;

    SELECT SUM(trosak_lijecenja) INTO drugo_lijecenje
    FROM lijecenje
    WHERE pocetak_lijecenja >= drugi_datum_p AND kraj_lijecenja <= drugi_datum_k;

	IF prvo_lijecenje = drugo_lijecenje THEN
		SET txt_li = CONCAT("Vremensko razdoblje od ", prvi_datum_p," do ", prvi_datum_k, " ima isti trošak kada je riječ o lijecenju u 
        usporedbi s razdobljem od ",  drugi_datum_p, " do ", drugi_datum_k);
	ELSEIF prvo_lijecenje > drugo_lijecenje THEN
		SET txt_li = CONCAT("Vremensko razdoblje od ", prvi_datum_p," do ", prvi_datum_k, " ima veći trošak kada je riječ o lijecenju u 
        usporedbi s razdobljem od ",  drugi_datum_p, " do ", drugi_datum_k);
	ELSE
		SET txt_li = CONCAT("Vremensko razdoblje od ", prvi_datum_p," do ", prvi_datum_k, " ima manji trošak kada je riječ o lijecenju u 
        usporedbi s razdobljem od ",  drugi_datum_p, " do ", drugi_datum_k);
	END IF;

END //
DELIMITER ;

CALL usporedba(STR_TO_DATE("1.10.1991.  12:37:13", "%d.%m.%Y. %H:%i:%s"), STR_TO_DATE("1.10.2013.  12:37:13", "%d.%m.%Y. %H:%i:%s"), 
			   STR_TO_DATE("1.10.1995.  10:45:10", "%d.%m.%Y. %H:%i:%s"), STR_TO_DATE("1.10.2011.  19:37:16", "%d.%m.%Y. %H:%i:%s"),
               @usp_mi, @usp_po, @usp_li);
SELECT  @usp_mi AS rez_usporedbe_misija, @usp_po AS rez_usporedbe_popravci, @usp_li AS rez_usporedbe_lijecenje FROM DUAL;




/*
Treba odrediti koje misije su održane na području sjeverne polutke, a koje na području južne polutke. Prilikom navoda 
se koristi naziv misije. Format mora bit sličan: 
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
CALL promjena_statusa_osoblja(10024, "Mrtav");


-- procedura za pogledati svo aktivno osoblje koje se trenutno nalazi na misiji preko jednostavnog upita koji spaja nekoliko tablica sa inner joinom


DELIMITER //
CREATE PROCEDURE svo_osoblje_na_misiji()
BEGIN
	SELECT o.*, m.naziv AS naziv_misije, l.naziv AS naziv_lokacije
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
CALL provjera_promocija_sniženje_cin(10893);




-- promjeni status osoblja ako nije bio na treningu ili na turi u zadnjih godinu dana

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



-- Svo osoblje u određenom sektoru koje nije mrtvo 
DELIMITER //
CREATE PROCEDURE ukupno_osoblje_u_sektoru(IN p_id_sektor INT)
BEGIN
    SELECT COUNT(*)
    FROM osoblje
    WHERE id_sektor = p_id_sektor AND status_osoblja != 'Mrtav' OR status_osoblja != 'Umirovljen';
END//
DELIMITER ;

CALL ukupno_osoblje_u_sektoru(1);




-- --------------------------------------
-- TRANSAKCIJE --------------------------
-- --------------------------------------
SELECT @@autocommit;
SET AUTOCOMMIT = OFF;
SET AUTOCOMMIT = ON;
-- MK

-- Osnovna transakcija koja će updateati količinu ukupnog proračuna za određenu količinu koju će odrediti korisnik, select smo ubacili kako bi se korisnici mogli osigurati 

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

-- Primjer serializable transakcije koja se mogla poboljsati sa dodatnom tablicom za pračenje dugova i try/catch funkcijom ali pošto se bliži kraj bilo bi greška ići dodavati viška tablice

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
