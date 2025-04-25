MoyenTransport(
    codeMT,
    type,
    heure_ouverture,
    heure_fermeture,
    nb_moyen_voyageurs
)

Station(
    codeStation,
    nom,
    principale,
    longitude,
    latitude
    numTroncon*
)

Ligne(
    codeLigne,
    codeMT*,
    stationDepart*,
    stationArrivee*,
)

Troncon(
    numTroncon,
    longueur,
    Ligne1*,
    Ligne2*,
)


Navette(
    numNavette,
    marque,
    annee,
    codeMT*
)

Voyage(
    numVoyage,
    date_voyage,
    heureDebut,
    duree,
    sens,
    nbVoyageurs,
    observation,
)

LigneNavette(
    numNavette*,
    codeLigne*,
)

VoyageNavette(
    numVoyage*,
    numNavette*
)
