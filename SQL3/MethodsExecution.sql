-- 1
SET SERVEROUTPUT ON;
DECLARE
    o_navette tNavette;
    total NUMBER;
BEGIN
    SELECT DEREF(REF(nav)) INTO o_navette
    FROM Navette nav
    WHERE nav.numNavette = 1;

    total := o_navette.totalVoyages();

    DBMS_OUTPUT.PUT_LINE('Nombre total de voyages : ' || total);
END;
/


-- 2
SET SERVEROUTPUT ON;

DECLARE
    r_ligne REF tLigne;
    o_ligne tLigne;
    dummy SYS_REFCURSOR;
BEGIN
    SELECT REF(l) INTO r_ligne FROM Ligne l WHERE l.codeLigne = 'M001';

    SELECT DEREF(r_ligne) INTO o_ligne FROM DUAL;

    dummy := o_ligne.getNavettesParLigne();
END;
/


-- 3
SET SERVEROUTPUT ON;

DECLARE
    r_ligne REF tLigne;
    o_ligne tLigne;
    total NUMBER;
BEGIN
    SELECT REF(l) INTO r_ligne FROM Ligne l WHERE l.codeLigne = 'M001';

    SELECT DEREF(r_ligne) INTO o_ligne FROM DUAL;

    total := o_ligne.getNombreVoyages(DATE '2025-01-01', DATE '2025-01-31');

    DBMS_OUTPUT.PUT_LINE('Nombre de voyages en janvier 2025 : ' || total);
END;
/

-- 4
SET SERVEROUTPUT ON;

DECLARE
    r_station REF tStation;
    o_station tStation;
BEGIN
    SELECT REF(s) INTO r_station FROM Station s WHERE s.nom_station = 'BEZ';

    SELECT DEREF(r_station) INTO o_station FROM DUAL;

    o_station.changerNomStation;
END;
/

-- 5

DECLARE
    r_mt REF tMoyenTransport;
    o_mt tMoyenTransport;
    total NUMBER;
BEGIN
    SELECT REF(mt) INTO r_mt FROM MoyenTransport mt WHERE mt.codeMT = 'MET';

    SELECT DEREF(r_mt) INTO o_mt FROM DUAL;

    total := o_mt.getNbrVoyagesVoyageurs(DATE '2025-01-01');

    DBMS_OUTPUT.PUT_LINE('Retour de la fonction (total voyages) : ' || total);
END;
/
