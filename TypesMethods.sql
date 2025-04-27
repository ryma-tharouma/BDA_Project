-- Enum type definition
CREATE TYPE mood AS ENUM ('MET', 'BUS', 'TRA', 'TRN');

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
    type VARCHAR2(50),
    heure_ouverture VARCHAR2(5), -- ouverture < fermeture
    heure_fermeture VARCHAR2(5),
    nb_moyen_voyageurs NUMBER,
    MoyenTransport_Ligne t_set_ref_lignes,
    MoyenTransport_Navette t_set_ref_navette
);
/

Create or replace type tStation as object(
    codeStation integer,
    nom_station varchar2(50),
    longitude number,
    latitude number,
    principale boolean, -- true or false
    Station_Ligne_Depart t_set_ref_lignes,
    Station_Ligne_Arrivee t_set_ref_lignes,
    station_troncon ref tTroncon,
);
/

CREATE OR REPLACE TYPE tLigne AS OBJECT (
    codeLigne VARCHAR2(50),
    stationDepart ref tStation,
    stationArrivee ref tStation,
    Ligne_MoyenTransport ref tMoyenTransport,
    ligne_navette t_set_ref_navette,
    ligne_troncon t_set_ref_troncon
);
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
);
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
ALTER TYPE tNavette ADD MEMBER FUNCTION totalVoyages RETURN NUMBER;
/
CREATE OR REPLACE TYPE BODY tNavette AS 
    MEMBER FUNCTION totalVoyages RETURN NUMBER IS
        total NUMBER := 0;
    BEGIN
        SELECT COUNT(*) INTO total
        FROM TABLE(navette_voyage);
        RETURN total;
    END totalVoyages;
END;
/

-- pour chaque ligne la liste des navettes qui lui sont affectées
-- Calculer pour une ligne (de numéro donné), le nombre de voyages effectués durant une période (Exemple : du 01-01-2025 au 15-02-2025). 
ALTER TYPE tLigne ADD MEMBER FUNCTION getNavettesParLigne RETURN SYS_REFCURSOR;

ALTER TYPE tLigne ADD MEMBER FUNCTION getNombreVoyages(p_date_debut DATE, p_date_fin DATE) RETURN NUMBER;
/
-- Then implement in a single body
CREATE OR REPLACE TYPE BODY tLigne AS 
    MEMBER FUNCTION getNavettesParLigne RETURN SYS_REFCURSOR IS  -- SYS_REFCURSOR is a cursor type in Oracle
            lignes_navettes SYS_REFCURSOR;
    BEGIN
        OPEN lignes_navettes FOR
            SELECT SELF.codeLigne AS codeLigne, 
                DEREF(ln).numNavette AS numNavette
            FROM TABLE(SELF.ligne_navette) ln;
        RETURN lignes_navettes;
    END getNavettesParLigne;

    MEMBER FUNCTION getNombreVoyages(p_date_debut DATE, p_date_fin DATE) RETURN NUMBER IS
        total NUMBER := 0;
    BEGIN
        SELECT COUNT(*) INTO total
        FROM Voyage v
        WHERE v.date_voyage BETWEEN p_date_debut AND p_date_fin
        AND v.voyage_navette IN (
            SELECT REF(n)
            FROM Navette n, TABLE(self.ligne_navette) ln
            WHERE REF(n) = VALUE(ln)
        );
        RETURN total;
    END getNombreVoyages;
END;
/

-- Changer le nom de la station « BEZ » par « Univ » dans toutes les lignes/tronçons comportant cette station.
ALTER TYPE tStation ADD MEMBER PROCEDURE changerNomStation();
/
CREATE OR REPLACE TYPE BODY tStation AS 
    MEMBER PROCEDURE changerNomStation(p_nouveau_nom VARCHAR2) IS
    BEGIN
        -- Update the station name
        UPDATE StationTable s
        SET value(s).nom_station = 'Univ'
        WHERE value(s).nom_station = 'BEZ';
        DBMS_OUTPUT.PUT_LINE('Station name changed to: ' || p_nouveau_nom);
    END changerNomStation;
END;
/

-- Calculer pour un moyen de transport donné (Exemple Métro), le nombre de voyages effectués  
-- à une date donnée (Exemple le 28-02-2025) et le nombre de voyageurs total. 
ALTER TYPE tMoyenTransport ADD MEMBER FUNCTION getNbrVoyagesVoyageurs(p_date DATE) RETURN NUMBER;
/
CREATE OR REPLACE TYPE BODY tMoyenTransport AS 
    MEMBER FUNCTION getNbrVoyagesVoyageurs(p_date DATE) RETURN NUMBER IS
        total NUMBER := 0;
        totalVoyageurs NUMBER := 0;
    BEGIN
        -- Dérouler les navettes de ce moyen de transport et accéder à leurs voyages
        SELECT COUNT(*), SUM(DEREF(v).nbVoyageurs)
        INTO total, totalVoyageurs
        FROM TABLE(SELF.MoyenTransport_Navette) n,
             TABLE(DEREF(n).navette_voyage) v
        WHERE DEREF(v).date_voyage = p_date
          AND DEREF(n).codeMT = REF(SELF);
        
        DBMS_OUTPUT.PUT_LINE('Total voyages: ' || total || ', Total voyageurs: ' || totalVoyageurs);
        
        RETURN total;
    END getNbrVoyagesVoyageurs;
END;
/

