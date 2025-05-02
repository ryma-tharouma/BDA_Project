// Afficher tous les voyages effectués en date du 01-01-2025 (préciser les détails de chaque voyage)

db.voyages.find({ date: new Date("2025-01-01") }).forEach(voyage => {
  print(`Voyage ID: ${voyage._id}`);
  print(`Date: ${voyage.date}`);
  print(`Heure de début: ${voyage.heure_debut}`);
  print(`Durée: ${voyage.duree} minutes`);
  print(`Sens: ${voyage.sens}`);
  print(`Nombre de voyageurs: ${voyage.nb_voyageurs}`);
  print(`Observation: ${voyage.observation}`);
  print(`Navette ID: ${voyage.navette._id}`);
  print(`Marque: ${voyage.navette.marque}`);
  print(`Année: ${voyage.navette.annee}`);
  print(`Moyen de transport: ${voyage.navette.moyen_transport.type}`);
  print(`Ligne ID: ${voyage.navette.ligne_id}`);
  print("-------------------------------");
});

// Dans  une  collection  BON-Voyage,  récupérer  tous  les  voyages  (numéro,  numLigne,  date, heure, sens) 
// n’ayant enregistré aucun problème, préciser le moyen de transport, le numéro de la navette associés au voyage.

db.voyages.aggregate([
    {
      $match: { observation: "RAS" }   // Garder uniquement les voyages sans problème
    },
    {
      $project: {
        _id: 1,                          // numéro du voyage
        numLigne: "$navette.ligne_id",    // ligne associée à la navette
        date: 1,                         // date du voyage
        heure_debut: 1,                  // heure de début
        sens: 1,                         // sens (Aller / Retour)
        moyen_transport: "$navette.moyen_transport.code",  // code du moyen de transport
        numNavette: "$navette._id"        // numéro de la navette
      }
    },
    {
      $out: "BON-Voyage"                 // Sauvegarder directement dans une nouvelle collection BON-Voyage
    }
]);


// Augmenter de 100, le nombre de voyageurs sur tous les voyages effectués par métro avant 
// la date du 15 janvier 2025.
db.voyages.updateMany(
    {
      "navette.moyen_transport.code": "MET",
      date: { $lt: "2025-01-15" }
    },
    {
      $inc: { nb_voyageurs: 100 }
    }
  );
  
// Récupérer dans une nouvelle collection Ligne-Voyages, les numéros de lignes et le nombre 
// total de  voyages effectués  (par  ligne). La  collection  devra  être ordonnée par  ordre 
// décroissant du nombre de voyages. Afficher le contenu de la collection.

db.voyages.aggregate([
    {
      $group: {
        _id: "$navette.ligne_id",   // grouper par numéro de ligne
        total_voyages: { $sum: 1 }   // compter le nombre de voyages
      }
    },
    {
      $sort: { total_voyages: -1 }   // trier en ordre décroissant
    },
    {
      $out: "Ligne-Voyages"          // stocker le résultat dans la collection Ligne-Voyages
    }
  ]);

  
// Reprendre la 3ème requête à l’aide du paradigme Map-Reduce

var mapFunction = function() {
    emit(this.navette.ligne_id, 1);
  };
var reduceFunction = function(key, values) {
return Array.sum(values);
};
db.voyages.mapReduce(
    mapFunction,
    reduceFunction,
    {
      out: { replace: "Ligne-Voyages-MapReduce" }
    }
);
db["Ligne-Voyages-MapReduce"].find().sort({ value: -1 });
