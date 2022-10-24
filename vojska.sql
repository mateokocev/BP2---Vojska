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
    allegiance VARCHAR(50) NOT NULL,
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


CREATE TABLE trening(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(50) NOT NULL,
    vrijeme_pocetka DATETIME NOT NULL,
    vrijeme_kraja DATETIME NOT NULL
);
DROP TABLE trening;


CREATE TABLE misija(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(50) NOT NULL,
    vrijeme_pocetka DATE NOT NULL,
    vrijeme_kraja DATE NOT NULL,
    lokacija_misije VARCHAR(50) NOT NULL,
    ishod TEXT NOT NULL,
    trosak_misije NUMERIC(15, 2) NOT NULL
);
DROP TABLE misija;


-- OSOBLJE NA MISIJI
CREATE TABLE onm(
    id INTEGER PRIMARY KEY,
    id_osoblje INTEGER,
    id_misija INTEGER,
    rating INTEGER,
    FOREIGN KEY (id_osoblje) REFERENCES osoblje(id),
    FOREIGN KEY (id_misija) REFERENCES misija(id)
);
DROP TABLE onm;


-- OSOBLJE NA TRENINGU
CREATE TABLE ont(
    id INTEGER PRIMARY KEY,
    id_osoblje INTEGER,
    id_trening INTEGER,
    rating INTEGER,
    FOREIGN KEY (id_osoblje) REFERENCES osoblje(id),
    FOREIGN KEY (id_trening) REFERENCES trening(id)
);
DROP TABLE ont;


-- VOZILO NA MISIJI
CREATE TABLE vnm(
    id INTEGER PRIMARY KEY,
    id_vozilo INTEGER,
    id_misija INTEGER,
    FOREIGN KEY (id_vozilo) REFERENCES vozila(id),
    FOREIGN KEY (id_misija) REFERENCES misija(id)
);
DROP TABLE vnm;


-- VOZILO NA TRENINGU
CREATE TABLE vnt(
    id INTEGER PRIMARY KEY,
    id_vozilo INTEGER,
    id_trening INTEGER,
    FOREIGN KEY (id_vozilo) REFERENCES vozila(id),
    FOREIGN KEY (id_trening) REFERENCES trening(id)
);
DROP TABLE vnt;


CREATE TABLE popravak(
    id INTEGER PRIMARY KEY,
    id_vnm INTEGER,
    id_vnt INTEGER,
    opis_stete TEXT NOT NULL,
    ishod TEXT NOT NULL,
    datum DATE NOT NULL,
    FOREIGN KEY (id_vnm) REFERENCES vnm(id),
    FOREIGN KEY (id_vnt) REFERENCES vnt(id)
);
DROP TABLE popravak;



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
