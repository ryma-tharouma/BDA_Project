-- Insérer 4 moyens de transport
INSERT INTO MoyenTransport VALUES (
    tMoyenTransport('MET', 'MET', '06:00', '23:00', 80000, t_set_ref_lignes(), t_set_ref_navette())
);
INSERT INTO MoyenTransport VALUES (
    tMoyenTransport('BUS', 'BUS', '05:30', '22:00', 40000, t_set_ref_lignes(), t_set_ref_navette())
);
INSERT INTO MoyenTransport VALUES (
    tMoyenTransport('TRA', 'TRA', '07:00', '21:00', 30000, t_set_ref_lignes(), t_set_ref_navette())
);
INSERT INTO MoyenTransport VALUES (
    tMoyenTransport('TRN', 'TRN', '05:00', '23:00', 60000, t_set_ref_lignes(), t_set_ref_navette())
);

-- Insérer les stations
INSERT INTO Station VALUES (
    tStation(1, 'Cite U', 3.172, 36.712, 'TRUE', t_set_ref_lignes(), t_set_ref_lignes(), NULL)
);
INSERT INTO Station VALUES (
    tStation(2, 'Hai El Badr', 3.180, 36.720, 'FALSE', t_set_ref_lignes(), t_set_ref_lignes(), NULL)
);
INSERT INTO Station VALUES (
    tStation(3, 'El Harrach', 3.190, 36.725, 'FALSE', t_set_ref_lignes(), t_set_ref_lignes(), NULL)
);
INSERT INTO Station VALUES (
    tStation(4, 'Univ', 3.200, 36.730, 'TRUE', t_set_ref_lignes(), t_set_ref_lignes(), NULL)
);
INSERT INTO Station VALUES (
    tStation(99, 'BEZ', 3.200, 36.750, 'TRUE', t_set_ref_lignes(), t_set_ref_lignes(), NULL)
);


-- Insertion of line details
INSERT INTO Ligne VALUES (
    tLigne(
        'M001',
        (SELECT REF(s) FROM Station  s WHERE s.codeStation = 1),
        (SELECT REF(s) FROM Station  s WHERE s.codeStation = 4),
        (SELECT REF(mt) FROM MoyenTransport mt WHERE mt.codeMT = 'MET'),
        t_set_ref_navette(),
        t_set_ref_troncon()
    )
);

INSERT INTO Ligne VALUES (
    tLigne(
        'B001',
        (SELECT REF(s) FROM Station  s WHERE s.codeStation = 2),
        (SELECT REF(s) FROM Station  s WHERE s.codeStation = 3),
        (SELECT REF(mt) FROM MoyenTransport mt WHERE mt.codeMT = 'BUS'),
        t_set_ref_navette(),
        t_set_ref_troncon()
    )
);

INSERT INTO Ligne VALUES (
    tLigne(
        'T099',
        (SELECT REF(s) FROM Station s WHERE s.codeStation = 99),
        (SELECT REF(s) FROM Station s WHERE s.codeStation = 2),
        (SELECT REF(mt) FROM MoyenTransport mt WHERE mt.codeMT = 'TRA'),
        t_set_ref_navette(),
        t_set_ref_troncon()
    )
);

-- Insertion of segment details
INSERT INTO Troncon VALUES (
    tTroncon(
        1,
        2,
        (SELECT REF(l) FROM Ligne l WHERE l.codeLigne = 'M001'),
        NULL,
        (SELECT REF(s) FROM Station  s WHERE s.codeStation = 1),
        (SELECT REF(s) FROM Station  s WHERE s.codeStation = 2)
    )
);

INSERT INTO Troncon VALUES (
    tTroncon(
        2,
        3,
        (SELECT REF(l) FROM Ligne l WHERE l.codeLigne = 'M001'),
        NULL,
        (SELECT REF(s) FROM Station  s WHERE s.codeStation = 2),
        (SELECT REF(s) FROM Station  s WHERE s.codeStation = 4)
    )
);

-- Insertion of shuttle details
INSERT INTO Navette VALUES (
    tNavette(
        1,
        'Irisbus',
        2022,
        (SELECT REF(mt) FROM MoyenTransport mt WHERE mt.codeMT = 'MET'),
        t_set_ref_voyage(),
        (SELECT REF(l) FROM Ligne l WHERE l.codeLigne = 'M001')
    )
);

INSERT INTO Navette VALUES (
    tNavette(
        2,
        'Mercedes',
        2020,
        (SELECT REF(mt) FROM MoyenTransport mt WHERE mt.codeMT = 'BUS'),
        t_set_ref_voyage(),
        (SELECT REF(l) FROM Ligne l WHERE l.codeLigne = 'B001')
    )
);

INSERT INTO Navette VALUES (
    tNavette(
        3,
        'Setram',
        2023,
        (SELECT REF(mt) FROM MoyenTransport mt WHERE mt.codeMT = 'TRA'),
        t_set_ref_voyage(),
        (SELECT REF(l) FROM Ligne l WHERE l.codeLigne = 'T099')
    )
);

-- Insertion of trip details
INSERT INTO Voyage VALUES (
    tVoyage(
        1,
        DATE '2025-01-01',
        TO_DATE('2025-01-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        45,
        'A',
        120,
        'RAS',
        (SELECT REF(n) FROM Navette n WHERE n.numNavette = 1)
    )
);

INSERT INTO Voyage VALUES (
    tVoyage(
        2,
        DATE '2025-01-01',
        TO_DATE('2025-01-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        50,
        'R',
        90,
        'Retard',
        (SELECT REF(n) FROM Navette n WHERE n.numNavette = 1)
    )
);

INSERT INTO Voyage VALUES (
    tVoyage(
        999,
        DATE '2025-02-28',
        TO_DATE('2025-02-28 09:30:00', 'YYYY-MM-DD HH24:MI:SS'),
        45,
        'A',
        110,
        'RAS',
        (SELECT REF(n) FROM Navette n WHERE n.numNavette = 3)
    )
);

-- update t_set_ref_voyage pour chaque navette 
UPDATE Navette n
SET n.navette_voyage = t_set_ref_voyage(
    (SELECT REF(v) FROM Voyage v WHERE v.numVoyage = 1 AND v.voyage_navette = REF(n)),
    (SELECT REF(v) FROM Voyage v WHERE v.numVoyage = 2 AND v.voyage_navette = REF(n))
)
WHERE n.numNavette = 1;

UPDATE Navette n
SET n.navette_voyage = t_set_ref_voyage(
    (SELECT REF(v) FROM Voyage v WHERE v.numVoyage = 999 AND v.voyage_navette = REF(n))
)
WHERE n.numNavette = 3;

-- update pour chaque ligen t_set_ref_navette() t_set_ref_troncon()
UPDATE Ligne l
SET l.ligne_navette = t_set_ref_navette(
    (SELECT REF(n) FROM Navette n WHERE n.navette_ligne = REF(l) AND ROWNUM = 1)
),
l.ligne_troncon = t_set_ref_troncon(
    (SELECT REF(t) FROM Troncon t WHERE (t.Ligne1 = REF(l) OR t.Ligne2 = REF(l)) AND ROWNUM = 1)
)
WHERE l.codeLigne = 'M001';

UPDATE Ligne l
SET l.ligne_navette = t_set_ref_navette(
    (SELECT REF(n) FROM Navette n WHERE n.navette_ligne = REF(l))
),
l.ligne_troncon = t_set_ref_troncon(
    (SELECT REF(t) FROM Troncon t WHERE t.Ligne1 = REF(l) OR t.Ligne2 = REF(l))
)
WHERE l.codeLigne = 'B001';

UPDATE Ligne l
SET l.ligne_navette = t_set_ref_navette(
    (SELECT REF(n) FROM Navette n WHERE n.navette_ligne = REF(l))
),
l.ligne_troncon = t_set_ref_troncon(
    (SELECT REF(t) FROM Troncon t WHERE t.Ligne1 = REF(l) OR t.Ligne2 = REF(l))
)
WHERE l.codeLigne = 'T099';

-- update pour chaque station t_set_ref_ligne() t_set_ref_navette()
UPDATE Station s
SET s.station_ligne_depart = t_set_ref_lignes(
    (SELECT REF(l) FROM Ligne l WHERE l.stationDepart = REF(s))
),
s.station_ligne_arrivee = t_set_ref_lignes(
    (SELECT REF(l) FROM Ligne l WHERE l.stationArrivee = REF(s))
),
s.station_troncon = (SELECT REF(t) FROM Troncon t WHERE t.station1 = REF(s) AND ROWNUM = 1)
WHERE s.codeStation IN (1, 2, 3, 4, 99);

-- update pour chaque troncon t_set_ref_ligne() t_set_ref_station()
UPDATE Troncon t
SET t.Ligne1 = (SELECT REF(l) FROM Ligne l WHERE l.codeLigne = 'M001'),
    t.Ligne2 = (SELECT REF(l) FROM Ligne l WHERE l.codeLigne = 'B001'),
    t.station1 = (SELECT REF(s) FROM Station s WHERE s.codeStation = 1),
    t.station2 = (SELECT REF(s) FROM Station s WHERE s.codeStation = 2)
WHERE t.numTroncon = 1;

UPDATE Troncon t
SET t.Ligne1 = (SELECT REF(l) FROM Ligne l WHERE l.codeLigne = 'M001'),
    t.Ligne2 = (SELECT REF(l) FROM Ligne l WHERE l.codeLigne = 'B001'),
    t.station1 = (SELECT REF(s) FROM Station s WHERE s.codeStation = 1),
    t.station2 = (SELECT REF(s) FROM Station s WHERE s.codeStation = 2)
WHERE t.numTroncon = 2;


-- update pour chaque moyen de transport t_set_ref_ligne() t_set_ref_navette()
UPDATE MoyenTransport mt
SET mt.MoyenTransport_Ligne = t_set_ref_lignes(
    (SELECT REF(l) FROM Ligne l WHERE l.Ligne_MoyenTransport = REF(mt))
),
mt.MoyenTransport_Navette = t_set_ref_navette(
    (SELECT REF(n) FROM Navette n WHERE n.codeMT = REF(mt))
)
WHERE mt.codeMT IN ('MET', 'BUS', 'TRA', 'TRN');
