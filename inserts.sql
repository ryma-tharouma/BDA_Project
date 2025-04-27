INSERT INTO MoyenTransport VALUES (
    'MET', 'Métro', '06:00', '23:00', 80000,
    t_set_ref_lignes(), t_set_ref_navette()
);

INSERT INTO MoyenTransport VALUES (
    'BUS', 'Bus', '05:30', '22:00', 40000,
    t_set_ref_lignes(), t_set_ref_navette()
);

INSERT INTO MoyenTransport VALUES (
    'TRA', 'Tramway', '07:00', '21:00', 30000,
    t_set_ref_lignes(), t_set_ref_navette()
);

INSERT INTO MoyenTransport VALUES (
    'TRN', 'Train', '05:00', '23:00', 60000,
    t_set_ref_lignes(), t_set_ref_navette()
);


INSERT INTO Station VALUES (
    1, 'S001', 3.172, 36.712, 1,
    t_set_ref_lignes(), t_set_ref_lignes(), NULL
);

INSERT INTO Station VALUES (
    2, 'S002', 3.180, 36.720, 0,
    t_set_ref_lignes(), t_set_ref_lignes(), NULL
);

INSERT INTO Station VALUES (
    3, 'S003', 3.190, 36.725, 0,
    t_set_ref_lignes(), t_set_ref_lignes(), NULL
);

INSERT INTO Station VALUES (
    4, 'S004', 3.200, 36.730, 1,
    t_set_ref_lignes(), t_set_ref_lignes(), NULL
);


INSERT INTO Ligne VALUES (
    'M001',
    (SELECT REF(s) FROM StationTable s WHERE s.codeStation = 1),
    (SELECT REF(s) FROM StationTable s WHERE s.codeStation = 4),
    (SELECT REF(mt) FROM MoyenTransport mt WHERE mt.codeMT = 'MET'),
    t_set_ref_navette(),
    t_set_ref_troncon()
);

INSERT INTO Ligne VALUES (
    'B001',
    (SELECT REF(s) FROM StationTable s WHERE s.codeStation = 2),
    (SELECT REF(s) FROM StationTable s WHERE s.codeStation = 3),
    (SELECT REF(mt) FROM MoyenTransport mt WHERE mt.codeMT = 'BUS'),
    t_set_ref_navette(),
    t_set_ref_troncon()
);


INSERT INTO Troncon VALUES (
    1,
    2,
    (SELECT REF(l) FROM LigneTable l WHERE l.codeLigne = 'M001'),
    NULL,
    (SELECT REF(s) FROM StationTable s WHERE s.codeStation = 1),
    (SELECT REF(s) FROM StationTable s WHERE s.codeStation = 2)
);

INSERT INTO Troncon VALUES (
    2,
    3,
    (SELECT REF(l) FROM LigneTable l WHERE l.codeLigne = 'M001'),
    NULL,
    (SELECT REF(s) FROM StationTable s WHERE s.codeStation = 2),
    (SELECT REF(s) FROM StationTable s WHERE s.codeStation = 4)
);

INSERT INTO Navette VALUES (
    1,
    'Irisbus',
    2022,
    (SELECT REF(mt) FROM MoyenTransport mt WHERE mt.codeMT = 'MET'),
    t_set_ref_voyage(),
    (SELECT REF(l) FROM LigneTable l WHERE l.codeLigne = 'M001')
);

INSERT INTO Navette VALUES (
    2,
    'Mercedes',
    2020,
    (SELECT REF(mt) FROM MoyenTransport mt WHERE mt.codeMT = 'BUS'),
    t_set_ref_voyage(),
    (SELECT REF(l) FROM LigneTable l WHERE l.codeLigne = 'B001')
);



INSERT INTO Voyage VALUES (
    1,
    DATE '2025-01-01',
    DATE '2025-01-01 08:00:00',
    45,
    'A',
    120,
    'RAS',
    (SELECT REF(n) FROM NavetteTable n WHERE n.numNavette = 1)
);

INSERT INTO Voyage VALUES (
    2,
    DATE '2025-01-01',
    DATE '2025-01-01 10:00:00',
    50,
    'R',
    90,
    'Retard',
    (SELECT REF(n) FROM NavetteTable n WHERE n.numNavette = 1)
);
