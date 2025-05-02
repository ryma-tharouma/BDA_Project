// Constants for data generation
const observations = ["RAS", "Retard", "Panne", "Accident"];
const moyens_transport = [
  { code: "MET", type: "Métro", heure_ouverture: "06:00", heure_fermeture: "23:00", nb_moyen_voyageurs: 90000 },
  { code: "BUS", type: "Bus", heure_ouverture: "05:30", heure_fermeture: "22:00", nb_moyen_voyageurs: 40000 },
  { code: "TRA", type: "Tramway", heure_ouverture: "07:00", heure_fermeture: "21:00", nb_moyen_voyageurs: 30000 },
  { code: "TRN", type: "Train", heure_ouverture: "05:00", heure_fermeture: "23:00", nb_moyen_voyageurs: 60000 }
];

// Stations data
const stations = [
  { _id: "S001", nom: "Cité U", principale: true, longitude: 3.1751, latitude: 36.7128 },
  { _id: "S002", nom: "Centre Ville", principale: true, longitude: 3.1800, latitude: 36.7200 },
  { _id: "S003", nom: "Gare Centrale", principale: true, longitude: 3.1850, latitude: 36.7150 },
  { _id: "S004", nom: "Université", principale: false, longitude: 3.1900, latitude: 36.7100 },
  { _id: "S005", nom: "Aéroport", principale: true, longitude: 3.2000, latitude: 36.7000 }
];

// Lines data
const lignes = [
  { 
    _id: "M001", 
    station_depart_id: "S001", 
    station_arrivee_id: "S005",
    troncons_ids: ["T001", "T002", "T003"]
  },
  { 
    _id: "B001", 
    station_depart_id: "S002", 
    station_arrivee_id: "S003",
    troncons_ids: ["T004", "T005"]
  },
  { 
    _id: "T001", 
    station_depart_id: "S003", 
    station_arrivee_id: "S004",
    troncons_ids: ["T006", "T007"]
  },
  { 
    _id: "R001", 
    station_depart_id: "S001", 
    station_arrivee_id: "S003",
    troncons_ids: ["T008", "T009"]
  }
];

const navettes = [
  { _id: "N001", marque: "Alstom", annee: 2022, ligne_id: "M001", moyen_transport: moyens_transport[0] },
  { _id: "N002", marque: "Mercedes", annee: 2021, ligne_id: "B001", moyen_transport: moyens_transport[1] },
  { _id: "N003", marque: "CAF", annee: 2023, ligne_id: "T001", moyen_transport: moyens_transport[2] },
  { _id: "N004", marque: "Bombardier", annee: 2020, ligne_id: "R001", moyen_transport: moyens_transport[3] }
];

let voyages = [];
let idCounter = 1;

// Ajouter 3 voyages spécifiques avec observation "RAS"
const datesRAS = [
  new Date("2025-01-01"),
  new Date("2025-01-02"),
  new Date("2025-01-03")
];

for (let i = 0; i < 3; i++) {
  voyages.push({
    _id: "V" + idCounter.toString().padStart(4, "0"),
    date: datesRAS[i],
    heure_debut: "08:00",
    duree: 45,
    sens: "Aller",
    nb_voyageurs: 100,
    observation: "RAS",
    navette: {
      _id: navettes[0]._id,
      marque: navettes[0].marque,
      annee: navettes[0].annee,
      moyen_transport: navettes[0].moyen_transport,
      ligne_id: navettes[0].ligne_id
    }
  });
  idCounter++;
}

const startDate = new Date("2025-01-01");
const endDate = new Date("2025-03-01");

for (let d = startDate; d <= endDate; d.setDate(d.getDate() + 1)) {
  for (let navette of navettes) {
    // 2 voyages par jour par navette
    for (let i = 0; i < 2; i++) {
      voyages.push({
        _id: "V" + idCounter.toString().padStart(4, "0"),
        date: new Date(d),
        heure_debut: (8 + i * 2) + ":00",  // 08:00, 10:00, etc.
        duree: 40 + Math.floor(Math.random() * 20),  // durée entre 40-60 min
        sens: i % 2 === 0 ? "Aller" : "Retour",
        nb_voyageurs: 80 + Math.floor(Math.random() * 100), // entre 80 et 180
        observation: observations[Math.floor(Math.random() * observations.length)],
        navette: {
          _id: navette._id,
          marque: navette.marque,
          annee: navette.annee,
          moyen_transport: navette.moyen_transport,
          ligne_id: navette.ligne_id
        }
      });
      idCounter++;
    }
  }
}

// Insert all data
db.stations.insertMany(stations);
db.lignes.insertMany(lignes);
db.voyages.insertMany(voyages);


// insert these voyages into the collection, allowing MongoDB to auto-generate _id
const voyagesToInsert = [
  {
      date: new Date("2025-01-01"),
      nb_voyageurs: 12000, // Plus que le seuil de 10 000
      navette: {
          marque: "Alstom",
          annee: 2022,
          moyen_transport: { type: "Métro", code: "MET" },
          ligne_id: "M001"
      }
  },
  {
      date: new Date("2025-01-02"),
      nb_voyageurs: 13000, // Plus que le seuil de 10 000
      navette: {
          marque: "Alstom",
          annee: 2022,
          moyen_transport: { type: "Métro", code: "MET" },
          ligne_id: "M001"
      }
  },
  {
      date: new Date("2025-01-03"),
      nb_voyageurs: 15000, // Plus que le seuil de 10 000
      navette: {
          marque: "Alstom",
          annee: 2022,
          moyen_transport: { type: "Métro", code: "MET" },
          ligne_id: "M001"
      }
  }
];

// Insert these voyages into the collection, allowing MongoDB to auto-generate _id
db.voyages.insertMany(voyagesToInsert);
