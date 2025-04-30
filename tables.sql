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
NESTED TABLE Station_Ligne_Arrivee STORE AS Station_Ligne_Arrivee_NT;
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
NESTED TABLE navette_voyage STORE AS navette_voyage_NT;
/

CREATE TABLE Voyage OF tVoyage (
    PRIMARY KEY (numVoyage),
    CONSTRAINT fk_voyage_navette FOREIGN KEY (voyage_navette) REFERENCES Navette
);
/

-- Check constraints 
--  typeMt VARCHAR2(3), -- Métro, Tram, Bus, Train
ALTER TABLE MoyenTransport ADD CONSTRAINT chk_typeMt CHECK (typeMt IN ('MET', 'TRA', 'TRN', 'BUS'));
-- ouverture < fermeture
ALTER TABLE MoyenTransport ADD CONSTRAINT chk_ouverture_fermeture CHECK (heure_ouverture < heure_fermeture);
-- principale boolean, -- true or false
ALTER TABLE Station ADD CONSTRAINT chk_principale CHECK (principale IN ('0', '1', 'TRUE', 'FALSE'));
-- sens char(1), -- 'A' ou 'R' 
ALTER TABLE Voyage ADD CONSTRAINT chk_sens CHECK (sens IN ('A', 'R'));
-- Ligne1 != Ligne2
ALTER TABLE Troncon ADD CONSTRAINT chk_ligne1_ligne2 CHECK (Ligne1 != Ligne2);
-- station1 != station2
ALTER TABLE Troncon ADD CONSTRAINT chk_station1_station2 CHECK (station1 != station2);

