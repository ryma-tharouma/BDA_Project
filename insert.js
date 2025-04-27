const observations = ["RAS", "Retard", "Panne", "Accident"];
const moyens_transport = [
  { code: "MET", type: "Métro", heure_ouverture: "06:00", heure_fermeture: "23:00", nb_moyen_voyageurs: 90000 },
  { code: "BUS", type: "Bus", heure_ouverture: "05:30", heure_fermeture: "22:00", nb_moyen_voyageurs: 40000 },
  { code: "TRA", type: "Tramway", heure_ouverture: "07:00", heure_fermeture: "21:00", nb_moyen_voyageurs: 30000 },
  { code: "TRN", type: "Train", heure_ouverture: "05:00", heure_fermeture: "23:00", nb_moyen_voyageurs: 60000 }
];

const navettes = [
  { _id: "N001", marque: "Alstom", annee: 2022, ligne_id: "M001", moyen_transport: moyens_transport[0] },
  { _id: "N002", marque: "Mercedes", annee: 2021, ligne_id: "B001", moyen_transport: moyens_transport[1] },
  { _id: "N003", marque: "CAF", annee: 2023, ligne_id: "T001", moyen_transport: moyens_transport[2] },
  { _id: "N004", marque: "Bombardier", annee: 2020, ligne_id: "R001", moyen_transport: moyens_transport[3] }
];

let voyages = [];
let idCounter = 1;

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

// Maintenant insère tous ces voyages dans MongoDB
db.voyages.insertMany(voyages);
