const express = require('express');
const { MongoClient } = require('mongodb');
const oracledb = require('oracledb');
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

// Oracle connection configuration
const oracleConfig = {
    user: 'system',
    password: 'oracle',
    connectString: 'localhost:1521/XEPDB1'
};

// Initialize Oracle connection pool
async function initializeOracle() {
    try {
        await oracledb.createPool(oracleConfig);
        console.log('Oracle connection pool created');
    } catch (err) {
        console.error('Error creating Oracle connection pool:', err);
        throw err;
    }
}

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

// Initialize Oracle on startup
initializeOracle();

// Routes
app.get('/', (req, res) => {
    res.render('index');
});

// Query routes
app.post('/query', async (req, res) => {
    const { queryType, dbType } = req.body;
    let result = [];

    try {
        if (dbType === 'mongodb') {
            let { client, db } = await connectToMongo();
            try {
                // MongoDB queries
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
                        result = await db.collection('voyages')
                            .aggregate([
                                { $group: {
                                    _id: "$navette.ligne_id",
                                    total_voyages: { $sum: 1 }
                                }},
                                { $sort: { total_voyages: -1 }}
                            ]).toArray();
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
                res.render('result', { queryType, result, dbType: 'mongodb' });
            } finally {
                await client.close();
            }
        } else if (dbType === 'oracle') {
            // Oracle queries
            let connection;
            try {
                connection = await oracledb.getConnection();
                
                switch (queryType) {
                    case '1':
                        // Query 10: List all trips with problems
                        result = await connection.execute(`
                            SELECT 
                                v.numVoyage,
                                TO_CHAR(v.date_voyage, 'DD-MM-YYYY') AS date_voyage,
                                DEREF(DEREF(v.voyage_navette).codeMT).codeMT AS moyen_transport_code,
                                DEREF(v.voyage_navette).numNavette AS navette_num
                            FROM Voyage v
                            WHERE LOWER(v.observation) LIKE '%probleme%'
                               OR LOWER(v.observation) LIKE '%panne%'
                               OR LOWER(v.observation) LIKE '%retard%'
                               OR LOWER(v.observation) LIKE '%accident%'
                        `, [], { outFormat: oracledb.OUT_FORMAT_OBJECT });
                        result = result.rows;
                        break;
                    case '2':
                        // Query 11: List lines with main stations
                        result = await connection.execute(`
                            SELECT l.codeLigne, 
                                 DEREF(l.stationDepart).nom_station AS station_depart,
                                 DEREF(l.stationArrivee).nom_station AS station_arrivee
                            FROM Ligne l
                            WHERE DEREF(l.stationDepart).principale = 'TRUE'
                                OR DEREF(l.stationArrivee).principale = 'TRUE'
                        `, [], { outFormat: oracledb.OUT_FORMAT_OBJECT });
                        result = result.rows;
                        break;
                    case '3':
                        // Query 12: Navettes with maximum trips in January 2025
                        result = await connection.execute(`
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
                                )
                        `, [], { outFormat: oracledb.OUT_FORMAT_OBJECT });
                        result = result.rows;
                        break;
                    case '4':
                        // Query 13: Stations with at least 2 transport means
                        result = await connection.execute(`
                            SELECT 
                                s.codeStation,
                                s.nom_station,
                                LISTAGG(DEREF(l.Ligne_MoyenTransport).typeMt, ', ') 
                                    WITHIN GROUP (ORDER BY DEREF(l.Ligne_MoyenTransport).typeMt) AS moyens_transport
                            FROM 
                                Station s,
                                Ligne l
                            WHERE 
                                s.codeStation = DEREF(l.stationDepart).codeStation
                                OR s.codeStation = DEREF(l.stationArrivee).codeStation
                            GROUP BY 
                                s.codeStation,
                                s.nom_station
                            HAVING 
                                COUNT(DISTINCT DEREF(l.Ligne_MoyenTransport).typeMt) >= 2
                        `, [], { outFormat: oracledb.OUT_FORMAT_OBJECT });
                        result = result.rows;
                        break;
                }
                res.render('result', { queryType, result, dbType: 'oracle' });
            } finally {
                if (connection) {
                    await connection.close();
                }
            }
        }
    } catch (err) {
        console.error('Error executing query:', err);
        res.status(500).send('Error executing query');
    }
});

// Start the server
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
}); 