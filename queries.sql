-- 10. Lister tous les voyages (num, date, moyen de transport, navette) ayant enregistré un quelconque 
-- problème (panne, retard, accident, ...) 

SELECT 
    v.numVoyage,
    TO_CHAR(v.date_voyage, 'DD-MM-YYYY') AS date_voyage,
    DEREF(DEREF(v.voyage_navette).codeMT).codeMT AS moyen_transport_code,
    DEREF(v.voyage_navette).numNavette AS navette_num
FROM Voyage v
WHERE LOWER(v.observation) LIKE '%probleme%'
   OR LOWER(v.observation) LIKE '%panne%'
   OR LOWER(v.observation) LIKE '%retard%'
   OR LOWER(v.observation) LIKE '%accident%';

-- 11. Lister toutes les lignes (numéro, début et fin) comportant une station principale

SELECT l.codeLigne, 
     DEREF(l.stationDepart).nom_station AS station_depart,
     DEREF(l.stationArrivee).nom_station AS station_arrivee
FROM Ligne l
WHERE DEREF(l.stationDepart).principale = 'TRUE'
    OR DEREF(l.stationArrivee).principale = 'TRUE';
