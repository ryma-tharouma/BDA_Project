-- 10. Lister tous les voyages (num, date, moyen de transport, navette) ayant enregistré un quelconque 
-- problème (panne, retard, accident, ...) 

SELECT v.numVoyage, 
        v.date_voyage, 
        DEREF(v.voyage_navette).codeMT, 
        DEREF(v.voyage_navette).numNavette
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
WHERE DEREF(l.stationDepart).principale = 1
    OR DEREF(l.stationArrivee).principale = 1;
