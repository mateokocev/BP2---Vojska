-- SQLBook: Code
-- Active: 1665427321001@@127.0.0.1@3306@vojskajna
DROP DATABASE IF EXISTS vojska;

CREATE DATABASE vojska;
USE vojska;

CREATE TABLE osoblje(
    id INTEGER PRIMARY KEY,
    ime VARCHAR(50) NOT NULL,
    prezime VARCHAR(50) NOT NULL,
    cin VARCHAR(50) NOT NULL,
    datum_rodenja DATE NOT NULL,
    datum_uclanjenja DATE NOT NULL,
    status VARCHAR(50) NOT NULL
);
DROP TABLE osoblje;


CREATE TABLE rat(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(60) NOT NULL,
    datum_pocetka DATETIME NOT NULL,
    datum_kraja DATETIME NOT NULL,
    ishod TEXT NOT NULL,
);
DROP TABLE rat;


CREATE TABLE sektor(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(60) NOT NULL
);
DROP TABLE sektor;


CREATE TABLE lokacija(
    id INTEGER PRIMARY KEY,
    id_sektor INTEGER,
    naziv VARCHAR(60) NOT NULL,
    pripadnost VARCHAR(50) NOT NULL,
    FOREIGN KEY (id_sektor) REFERENCES sektor(id)
);
DROP TABLE lokacija;


CREATE TABLE vozila(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(60) NOT NULL,
    vrsta VARCHAR(50) NOT NULL,
    kapacitet INTEGER NOT NULL
);
DROP TABLE vozila;


CREATE TABLE oprema(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(50) NOT NULL,
    dostupna_kolicina INTEGER,
    vrsta VARCHAR(50) NOT NULL
);
DROP TABLE oprema;




CREATE TABLE misija(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(50) NOT NULL,
    vrijeme_pocetka DATETIME NOT NULL,
    vrijeme_kraja DATETIME NOT NULL,
    id_lokacija INTEGER NOT NULL,
    ishod TEXT NOT NULL,
    trosak_misije NUMERIC(15, 2) NOT NULL,
    FOREIGN KEY (id_lokacija) REFERENCES lokacija(id)
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
    ishod TEXT NOT NULL,
    datum DATE NOT NULL,
    FOREIGN KEY (id_vozilo_na_misiji) REFERENCES vozilo_na_misiji(id)
);
DROP TABLE popravak;



CREATE TABLE tura(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(50) NOT NULL,
    vrijeme_pocetka DATETIME NOT NULL,
    vrijeme_kraja DATETIME NOT NULL,
    id_baza INTEGER NOT NULL,
    trosak_ture NUMERIC(15, 2) NOT NULL,
    FOREIGN KEY (id_lokacija) REFERENCES lokacija(id)
);
DROP TABLE tura;


CREATE TABLE vozilo_na_turi(
    id INTEGER PRIMARY KEY,
    id_vozilo INTEGER,
    kolicina INTEGER,
    id_tura INTEGER,
    FOREIGN KEY (id_vozilo) REFERENCES vozila(id),
    FOREIGN KEY (id_tura) REFERENCES tura(id)
);
DROP TABLE vozilo_na_turi;




CREATE TABLE osoblje_na_turi(
    id INTEGER PRIMARY KEY,
    id_osoblje INTEGER,
    id_tura INTEGER,
    FOREIGN KEY (id_osoblje) REFERENCES osoblje(id),
    FOREIGN KEY (id_tura) REFERENCES tura(id)
);
DROP TABLE osoblje_na_turi;





INSERT INTO osoblje VALUES 
(1, 'Niko', 'Franjić', '', , , ''),
(2, 'Izidor', 'Sekicki', '', , , ''),
(3, 'Lejla', 'Klabot', '', , , ''),
(4, 'Toni', 'Kolar', '', , , ''),
(5, 'Neo', 'Zufić', '', , , ''),
(6, 'Momčilo', 'Petrović', '', , , ''),
(7, 'Suzana', 'Lantana', '', , , ''),
(8, 'Vjekoslav', 'Galović', '', , , ''),
(9, 'Neo', 'Hercog', '', , , ''),
(10, 'Leonardo', 'Lorenzijan', '', , , ''),
(11, 'Trpimir', 'Kolar', '', , , ''),
(12, 'Leo', 'Schewerc', '', , , ''),
(13, 'Filip', 'Grozlak', '', , , ''),
(14, 'Dean', 'Mirković', '', , , ''),
(15, 'Lena', 'Orak', '', , , ''),
(16, 'Marko', 'Selenberg', '', , , ''),
(17, 'Petra Ursato', '', '', , , ''),
(18, 'Robert', 'Kovačević', '', , , ''),
(19, 'Hrvoje', 'Natašević', '', , , ''),
(20, 'Mirko', 'Regan', '', , , ''),
(21, 'Francesco', 'Rossi', '', , , ''),
(22, 'Nino', 'Fratimirović', '', , , ''),
(23, 'Ines', 'Mijarkalec', '', , , ''),
(24, 'Vedran', 'Hercog', '', , , ''),
(25, 'Saša', 'Nikel', '', , , ''),
(26, 'Otto', 'Nikel', '', , , ''),
(27, 'Anes', 'Celić', '', , , ''),
(28, 'Borna', 'Fratarić', '', , , ''),
(29, 'Ugo', 'Nestle', '', , , ''),
(30, 'Jani', 'Zelkovčić', '', , , ''),
(31, 'Mateo', 'Hereg', '', , , ''),
(32, 'Lidija', 'Bafrić', '', , , ''),
(33, 'Greta', 'Nikša', '', , , ''),
(34, 'Hektor', 'Persa', '', , , ''),
(35, 'Zoran', 'Juko', '', , , ''),
(36, 'Milan', 'Bersan', '', , , ''),
(37, 'Leo', 'Krelović', '', , , ''),
(38, 'Marko', 'Katalin', '', , , ''),
(39, 'Orto', 'Muker', '', , , ''),
(40, 'David', 'Kovačević', '', , , '');
