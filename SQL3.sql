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
    nom varchar2(50),
    longitude number,
    latitude number,
    principale boolean, -- true or false
    Station_Ligne_Depart t_set_ref_lignes,
    Station_Ligne_Arrivee t_set_ref_lignes,
    station_troncon t_set_ref_troncon
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
            SELECT l.codeLigne, n.numNavette
            FROM Ligne l
            LEFT JOIN TABLE(l.ligne_navette) ln ON REF(ln) = REF(n)
            LEFT JOIN Navette n ON REF(n) = VALUE(ln);
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

-- Station method to change station name
ALTER TYPE tStation ADD MEMBER PROCEDURE changerNomStation(p_nouveau_nom VARCHAR2);
/
CREATE OR REPLACE TYPE BODY tStation AS 
    MEMBER PROCEDURE changerNomStation(p_nouveau_nom VARCHAR2) IS
    BEGIN
        -- Update the station name
        self.nom := p_nouveau_nom;
        
        -- Note: To update references in other objects would require
        -- database-level UPDATE statements which can't be done directly in this procedure
    END changerNomStation;
END;
/

-- MoyenTransport method to get voyages on a specific date
ALTER TYPE tMoyenTransport ADD MEMBER FUNCTION getNombreVoyages(p_date DATE) RETURN NUMBER;
/
CREATE OR REPLACE TYPE BODY tMoyenTransport AS 
    MEMBER FUNCTION getNombreVoyages(p_date DATE) RETURN NUMBER IS
        total NUMBER := 0;
        totalVoyageurs NUMBER := 0;
    BEGIN
        -- Count voyages for this mode of transport on the given date
        SELECT COUNT(*), SUM(v.nbVoyageurs)
        INTO total, totalVoyageurs
        FROM Voyage v, Navette n
        WHERE v.date_voyage = p_date
        AND v.voyage_navette = REF(n)
        AND n.codeMT = REF(SELF);
        
        DBMS_OUTPUT.PUT_LINE('Total voyages: ' || total || ', Total voyageurs: ' || totalVoyageurs);
        RETURN total;
    END getNombreVoyages;
END;
/

-- 5. Tables
CREATE TABLE MoyenTransport OF tMoyenTransport (
    PRIMARY KEY (codeMT)
)
NESTED TABLE MoyenTransport_Ligne STORE AS MoyenTransport_Ligne_NT
NESTED TABLE MoyenTransport_Navette STORE AS MoyenTransport_Navette_NT;
/

CREATE TABLE Station OF tStation (
    PRIMARY KEY (codeStation)
)
NESTED TABLE Station_Ligne_Depart STORE AS Station_Ligne_Depart_NT
NESTED TABLE Station_Ligne_Arrivee STORE AS Station_Ligne_Arrivee_NT
NESTED TABLE station_troncon STORE AS station_troncon_NT;
/

CREATE TABLE Ligne OF tLigne (
    PRIMARY KEY (codeLigne)
)
NESTED TABLE ligne_navette STORE AS ligne_navette_NT
NESTED TABLE ligne_troncon STORE AS ligne_troncon_NT;
/

CREATE TABLE Troncon OF tTroncon (
    PRIMARY KEY (numTroncon),
    CONSTRAINT fk_troncon_ligne1 FOREIGN KEY (Ligne1) REFERENCES Ligne,
    CONSTRAINT fk_troncon_ligne2 FOREIGN KEY (Ligne2) REFERENCES Ligne,
    CONSTRAINT fk_troncon_station1 FOREIGN KEY (station1) REFERENCES Station,
    CONSTRAINT fk_troncon_station2 FOREIGN KEY (station2) REFERENCES Station
);
/

CREATE TABLE Navette OF tNavette (
    PRIMARY KEY (numNavette),
    CONSTRAINT fk_navette_moyen_transport FOREIGN KEY (codeMT) REFERENCES MoyenTransport
)
NESTED TABLE navette_voyage STORE AS navette_voyage_NT
NESTED TABLE navette_ligne STORE AS navette_ligne_NT;
/

CREATE TABLE Voyage OF tVoyage (
    PRIMARY KEY (numVoyage),
    CONSTRAINT fk_voyage_navette FOREIGN KEY (voyage_navette) REFERENCES Navette
);
/

-- Check constraints 
-- ouverture < fermeture
ALTER TABLE MoyenTransport ADD CONSTRAINT chk_ouverture_fermeture CHECK (heure_ouverture < heure_fermeture);
-- principale boolean, -- true or false
ALTER TABLE Station ADD CONSTRAINT chk_principale CHECK (principale IN (0, 1));
-- sens char(1), -- 'A' ou 'R' 
ALTER TABLE Voyage ADD CONSTRAINT chk_sens CHECK (sens IN ('A', 'R'));
-- Ligne1 != Ligne2
ALTER TABLE Troncon ADD CONSTRAINT chk_ligne1_ligne2 CHECK (Ligne1 != Ligne2);
-- station1 != station2
ALTER TABLE Troncon ADD CONSTRAINT chk_station1_station2 CHECK (station1 != station2);





-- 6. Insert sample data

-- 7. Les requetes