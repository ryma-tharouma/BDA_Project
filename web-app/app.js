const express = require('express');
const { MongoClient } = require('mongodb');
const path = require('path');

const app = express();
const port = 3000;

// Set up EJS as the view engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Middleware
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

// MongoDB connection URL
const url = 'mongodb://localhost:27017';
const dbName = 'BDAProjet';

// Connect to MongoDB
async function connectToMongo() {
    try {
        const client = await MongoClient.connect(url);
        const db = client.db(dbName);
        return { client, db };
    } catch (err) {
        console.error('Error connecting to MongoDB:', err);
        throw err;
    }
}

// Routes
app.get('/', (req, res) => {
    res.render('index');
});

// Query routes
app.post('/query', async (req, res) => {
    const { queryType } = req.body;
    let result = [];
    let { client, db } = await connectToMongo();

    try {
        switch (queryType) {
            case '1':
                result = await db.collection('voyages')
                    .find({ date: new Date("2025-01-01") })
                    .toArray();
                break;
            case '2':
                result = await db.collection('voyages')
                    .aggregate([
                        { $match: { observation: "RAS" } },
                        { $project: {
                            _id: 1,
                            numLigne: "$navette.ligne_id",
                            date: 1,
                            heure_debut: 1,
                            sens: 1,
                            moyen_transport: "$navette.moyen_transport.code",
                            numNavette: "$navette._id"
                        }}
                    ]).toArray();
                break;
            case '3':
                result = await db.collection('voyages')
                    .aggregate([
                        { $group: {
                            _id: "$navette.ligne_id",
                            total_voyages: { $sum: 1 }
                        }},
                        { $sort: { total_voyages: -1 }}
                    ]).toArray();
                break;
            case '4':
                const updateResult = await db.collection('voyages')
                    .updateMany(
                        {
                            "navette.moyen_transport.code": "MET",
                            date: { $lt: new Date("2025-01-15") }
                        },
                        { $inc: { nb_voyageurs: 100 } }
                    );
                result = [{ modifiedCount: updateResult.modifiedCount }];
                break;
            case '5':
                try {
                    result = await db.collection('voyages')
                        .aggregate([
                            {
                                $group: {
                                    _id: "$navette.ligne_id",
                                    total_voyages: { $sum: 1 }
                                }
                            },
                            {
                                $sort: { _id: 1 }
                            },
                            {
                                $project: {
                                    _id: 0,
                                    ligne_id: "$_id",
                                    total_voyages: 1
                                }
                            }
                        ]).toArray();
                } catch (error) {
                    console.error('Query error:', error);
                    result = [{ error: 'Failed to execute query' }];
                }
                break;
            case '6':
                result = await db.collection('voyages')
                    .aggregate([
                        { $group: {
                            _id: {
                                navette_id: "$navette._id",
                                navette_marque: "$navette.marque",
                                moyen_transport: "$navette.moyen_transport.type"
                            },
                            nombre_voyages: { $sum: 1 }
                        }},
                        { $sort: { nombre_voyages: -1 }},
                        { $limit: 1 }
                    ]).toArray();
                break;
            case '7':
                const SEUIL = 1000;
                result = await db.collection('voyages')
                    .aggregate([
                        {
                            $group: {
                                _id: {
                                    date: { $dateToString: { format: "%Y-%m-%d", date: "$date" } },
                                    moyen_transport: "$navette.moyen_transport.type"
                                },
                                total_voyageurs: { $sum: "$nb_voyageurs" }
                            }
                        },
                        {
                            $match: {
                                total_voyageurs: { $gt: SEUIL }
                            }
                        },
                        {
                            $group: {
                                _id: "$_id.moyen_transport",
                                jours_depassement: {
                                    $push: {
                                        date: "$_id.date",
                                        total: "$total_voyageurs"
                                    }
                                },
                                nombre_jours: { $sum: 1 }
                            }
                        },
                        {
                            $project: {
                                _id: 0,
                                moyen_transport: "$_id",
                                jours_depassement: 1,
                                nombre_jours: 1
                            }
                        },
                        {
                            $sort: { nombre_jours: -1 }
                        }
                    ]).toArray();
                break;
        }
        res.render('result', { queryType, result });
    } catch (err) {
        console.error('Error executing query:', err);
        res.status(500).send('Error executing query');
    } finally {
        await client.close();
    }
});

// Start the server
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
}); 