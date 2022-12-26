-- MATEOVI TRIGGERI

-- TRIGGER za popravljanje datuma učlanjenja
DELIMITER //
CREATE TRIGGER legalno_u_vojski
    AFTER INSERT ON osoblje
    FOR EACH ROW
BEGIN
    IF new.datum_rodenja > new.datum_uclanjenja THEN
    
        SET new.datum_uclanjenja = DATE_ADD(new.datum_uclanjenja, INTERVAL 18 YEAR);
        
        dodaj_dok_legalno: LOOP
            IF TIMESTAMPDIFF(YEAR, new.datum_uclanjenja, new.datum_rodenja) > 18 THEN
                LEAVE dodaj_dok_legalno;
            END IF;
            SET new.datum_uclanjenja = DATE_ADD(new.datum_uclanjenja, INTERVAL 3 YEAR);
        END LOOP;
    END IF;

        
END //
DELIMITER ;
