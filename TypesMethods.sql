-- Removed invalid ENUM type definition
-- Use VARCHAR2(3) directly in object types

-- 1. First define collection type references (forward declarations)
Create type tMoyenTransport;
/
Create type tLigne;
/
Create type tStation;
/
Create type tNavette;
/
Create type tVoyage;
/
Create type tTroncon;
/

-- 2. Define nested collection types
Create or replace type t_set_ref_lignes as table of ref tLigne;
/
Create or replace type t_set_ref_voyage as table of ref tVoyage;
/
Create or replace type t_set_ref_navette as table of ref tNavette;
/
Create or replace type t_set_ref_troncon as table of ref tTroncon;
/

-- 3. Define object types with proper relationships
CREATE OR REPLACE TYPE tMoyenTransport AS OBJECT (
    codeMT VARCHAR2(50),
    typeMt VARCHAR2(3), -- Métro, Tram, Bus, Train
    heure_ouverture VARCHAR2(5), -- ouverture < fermeture
    heure_fermeture VARCHAR2(5),
    nb_moyen_voyageurs NUMBER,
    MoyenTransport_Ligne t_set_ref_lignes,
    MoyenTransport_Navette t_set_ref_navette
) NOT FINAL;
/

Create or replace type tStation as object (
    codeStation integer,
    nom_station varchar2(50),
    longitude number,
    latitude number,
    principale varchar2(5), -- 'TRUE' or 'FALSE'
    Station_Ligne_Depart t_set_ref_lignes,
    Station_Ligne_Arrivee t_set_ref_lignes,
    station_troncon ref tTroncon,
    MEMBER PROCEDURE changerNomStation -- Changer le nom de la station
)NOT FINAL; -- NOT FINAL means this type can be extended
/

CREATE OR REPLACE TYPE tLigne AS OBJECT (
    codeLigne VARCHAR2(50),
    stationDepart ref tStation,
    stationArrivee ref tStation,
    Ligne_MoyenTransport ref tMoyenTransport,
    ligne_navette t_set_ref_navette,
    ligne_troncon t_set_ref_troncon
)NOT FINAL;
/

Create or replace type tTroncon as object(
    numTroncon integer,
    longueur integer,
    Ligne1 ref tLigne, -- Ligne1 != Ligne2 
    Ligne2 ref tLigne,
    station1 ref tStation,
    station2 ref tStation
);
/

Create or replace type tNavette as object(
    numNavette integer,
    marque varchar2(20),
    annee integer,
    codeMT ref tMoyenTransport,
    navette_voyage t_set_ref_voyage,
    navette_ligne ref tLigne
)NOT FINAL;
/

Create or replace type tVoyage as object(
    numVoyage integer,
    date_voyage date,
    heureDebut date,
    duree integer,
    sens char(1), -- 'A' ou 'R'
    nbVoyageurs integer,
    observation varchar2(100),
    voyage_navette ref tNavette
);
/

-- 4. Add member functions and procedures with proper declarations first

-- Navette function to calculate total voyages
ALTER TYPE tNavette ADD MEMBER FUNCTION totalVoyages RETURN NUMBER CASCADE;

CREATE OR REPLACE TYPE BODY tNavette AS 
    MEMBER FUNCTION totalVoyages RETURN NUMBER IS
        total NUMBER := 0;
    BEGIN
        SELECT COUNT(*) INTO total
        FROM TABLE(navette_voyage);
        RETURN total;
    END;
END;
/

-- pour chaque ligne la liste des navettes qui lui sont affectées
-- Calculer pour une ligne (de numéro donné), le nombre de voyages effectués durant une période (Exemple : du 01-01-2025 au 15-02-2025). 
ALTER TYPE tLigne ADD MEMBER FUNCTION getNavettesParLigne RETURN SYS_REFCURSOR CASCADE;

ALTER TYPE tLigne ADD MEMBER FUNCTION getNombreVoyages(p_date_debut DATE, p_date_fin DATE) RETURN NUMBER CASCADE;

-- Then implement in a single body
CREATE OR REPLACE TYPE BODY tLigne AS

  MEMBER FUNCTION getNavettesParLigne RETURN SYS_REFCURSOR IS
    lignes_navettes SYS_REFCURSOR;
    r_navette tNavette;
    r_ref     REF tNavette;
    temp_tab  SYS_REFCURSOR;
  BEGIN
    FOR i IN 1 .. SELF.ligne_navette.COUNT LOOP
      SELECT DEREF(SELF.ligne_navette(i)) INTO r_navette FROM DUAL;
      DBMS_OUTPUT.PUT_LINE('Ligne: ' || SELF.codeLigne || ', Navette: ' || r_navette.numNavette);
    END LOOP;

    RETURN NULL; -- pas de curseur car on n'a pas de table cible
  END;

  MEMBER FUNCTION getNombreVoyages(p_date_debut DATE, p_date_fin DATE) RETURN NUMBER IS
    total NUMBER := 0;
    r_navette tNavette;
    r_voyage  tVoyage;
  BEGIN
    FOR i IN 1 .. SELF.ligne_navette.COUNT LOOP
      SELECT DEREF(SELF.ligne_navette(i)) INTO r_navette FROM DUAL;
      IF r_navette.navette_voyage IS NOT NULL THEN
        FOR j IN 1 .. r_navette.navette_voyage.COUNT LOOP
          SELECT DEREF(r_navette.navette_voyage(j)) INTO r_voyage FROM DUAL;
          IF r_voyage.date_voyage BETWEEN p_date_debut AND p_date_fin THEN
            total := total + 1;
          END IF;
        END LOOP;
      END IF;
    END LOOP;
    RETURN total;
  END;

END;
/

-- Changer le nom de la station « BEZ » par « Univ » dans toutes les lignes/tronçons comportant cette station.
CREATE OR REPLACE TYPE BODY tStation AS 
    MEMBER PROCEDURE changerNomStation IS
    BEGIN
      -- Changer le nom de la station si elle est 'BEZ'
      IF SELF.nom_station = 'BEZ' THEN
        SELF.nom_station := 'Univ';
        DBMS_OUTPUT.PUT_LINE('Station name changed to: ' || SELF.nom_station);
      ELSE
        DBMS_OUTPUT.PUT_LINE('Aucune modification : la station n''est pas BEZ.');
      END IF;
    END;
END;
/

-- Calculer pour un moyen de transport donné (Exemple Métro), le nombre de voyages effectués  
-- à une date donnée (Exemple le 28-02-2025) et le nombre de voyageurs total. 
ALTER TYPE tMoyenTransport ADD MEMBER FUNCTION getNbrVoyagesVoyageurs(p_date DATE) RETURN NUMBER CASCADE;

CREATE OR REPLACE TYPE BODY tMoyenTransport AS
  MEMBER FUNCTION getNbrVoyagesVoyageurs(p_date DATE) RETURN NUMBER IS
    total NUMBER := 0;
    totalVoyageurs NUMBER := 0;
    r_navette tNavette;
    r_voyage  tVoyage;
  BEGIN
    FOR i IN 1 .. SELF.MoyenTransport_Navette.COUNT LOOP
      SELECT DEREF(SELF.MoyenTransport_Navette(i)) INTO r_navette FROM DUAL;

      IF r_navette.navette_voyage IS NOT NULL THEN
        FOR j IN 1 .. r_navette.navette_voyage.COUNT LOOP
          SELECT DEREF(r_navette.navette_voyage(j)) INTO r_voyage FROM DUAL;

          IF r_voyage.date_voyage = p_date THEN
            total := total + 1;
            totalVoyageurs := totalVoyageurs + r_voyage.nbVoyageurs;
          END IF;
        END LOOP;
      END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Total voyages: ' || total || ', Total voyageurs: ' || totalVoyageurs);
    RETURN total;
  END;
END;
/



-- Drop all types and their dependencies in reverse order of creation
-- BEGIN
--     FOR type_name IN (
--         SELECT 'tVoyage' AS type_name FROM dual UNION ALL
--         SELECT 'tNavette' FROM dual UNION ALL
--         SELECT 'tTroncon' FROM dual UNION ALL
--         SELECT 'tLigne' FROM dual UNION ALL
--         SELECT 'tStation' FROM dual UNION ALL
--         SELECT 'tMoyenTransport' FROM dual UNION ALL
--         SELECT 't_set_ref_troncon' FROM dual UNION ALL
--         SELECT 't_set_ref_navette' FROM dual UNION ALL
--         SELECT 't_set_ref_voyage' FROM dual UNION ALL
--         SELECT 't_set_ref_lignes' FROM dual
--     ) LOOP
--         BEGIN
--             EXECUTE IMMEDIATE 'DROP TYPE ' || type_name.type_name || ' FORCE';
--         EXCEPTION
--             WHEN OTHERS THEN
--                 IF SQLCODE != -4043 THEN
--                     RAISE;
--                 END IF;
--         END;
--     END LOOP;
-- END;
-- /

