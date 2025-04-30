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
