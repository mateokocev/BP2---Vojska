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


CREATE TABLE sektor(
    id INTEGER PRIMARY KEY,
    naziv VARCHAR(60) NOT NULL
);
DROP TABLE sektor;



CREATE TABLE lokacija(
    id INTEGER PRIMARY KEY,
    id_sektor INTEGER,
    naziv VARCHAR(60) NOT NULL
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


CREATE TABLE proracun(
    id INTEGER PRIMARY KEY,
    iznos NUMERIC(9, 2) NOT NULL,
    namjena TEXT NOT NULL
);
DROP TABLE proracun;




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
    ishod TEXT NOT NULL
);
DROP TABLE misija;