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

-- 12. Lister les navettes avec le plus de voyages en janvier 2025

SELECT 
    DEREF(v.voyage_navette).numNavette AS num_navette,
    DEREF(DEREF(v.voyage_navette).codeMT).typeMt AS type_transport,
    DEREF(v.voyage_navette).annee AS annee_mise_service,
    COUNT(*) AS nombre_voyages
FROM 
    Voyage v
WHERE 
    v.date_voyage BETWEEN TO_DATE('01-01-2025', 'DD-MM-YYYY') 
                      AND TO_DATE('31-01-2025', 'DD-MM-YYYY')
GROUP BY 
    DEREF(v.voyage_navette).numNavette,
    DEREF(DEREF(v.voyage_navette).codeMT).typeMt,
    DEREF(v.voyage_navette).annee
HAVING 
    COUNT(*) = (
        SELECT MAX(voyage_count)
        FROM (
            SELECT COUNT(*) as voyage_count
            FROM Voyage v2
            WHERE v2.date_voyage BETWEEN TO_DATE('01-01-2025', 'DD-MM-YYYY') 
                                    AND TO_DATE('31-01-2025', 'DD-MM-YYYY')
            GROUP BY DEREF(v2.voyage_navette).numNavette
        )
    );

SELECT 
    s.codeStation,
    s.nom_station,
    LISTAGG(DEREF(l.Ligne_MoyenTransport).typeMt, ', ') 
        WITHIN GROUP (ORDER BY DEREF(l.Ligne_MoyenTransport).typeMt) as moyens_transport
FROM 
    Station s,
    Ligne l
WHERE 
    (DEREF(l.stationDepart) = s OR DEREF(l.stationArrivee) = s)
GROUP BY 
    s.codeStation,
    s.nom_station
HAVING 
    COUNT(DISTINCT DEREF(l.Ligne_MoyenTransport).typeMt) >= 2;



