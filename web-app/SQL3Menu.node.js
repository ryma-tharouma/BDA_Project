const fs = require('fs');
const path = require('path');
const readline = require('readline');
const oracledb = require('oracledb');

try {
  oracledb.initOracleClient({ libDir: 'C:\\oracle\\instantclient_11_2' }); // Replace with your Instant Client path
  console.log('Oracle Client initialized successfully.');
} catch (err) {
  console.error('Error initializing Oracle Client:', err);
}

// Oracle DB connection configuration
const dbConfig = {
  user: 'sys', // Use SYS for privileged operations
  password: 'your_sys_password', // Replace with your SYS password
  connectString: 'localhost:1521/xe', // Use the correct service name
  privilege: oracledb.SYSDBA, // Required for SYS user
};

// Path to the SQL3 folder
const sqlFolderPath = path.join(__dirname, '..', 'SQL3');
const deleteFilePath = path.join(sqlFolderPath, 'Delete.sql');

// Function to execute the Delete.sql file
async function executeDeleteFile() {
  if (!fs.existsSync(deleteFilePath)) {
    console.log('Delete.sql file not found. Skipping cleanup.');
    return;
  }

  const sqlContent = fs.readFileSync(deleteFilePath, 'utf8');
  const sqlStatements = sqlContent.split(';').map(stmt => stmt.trim()).filter(stmt => stmt);

  try {
    const connection = await oracledb.getConnection(dbConfig);
    console.log('Executing Delete.sql...');

    for (const statement of sqlStatements) {
      try {
        console.log(`Executing: ${statement}`);
        await connection.execute(statement);
      } catch (err) {
        console.error(`Error executing statement: ${statement}\n${err.message}`);
      }
    }

    console.log('Cleanup completed successfully.');
    await connection.close();
  } catch (err) {
    console.error('Error executing Delete.sql:', err);
  }
}

// Define the menu order manually
const menuFiles = [
  'TableSpace_user.sql',
  'TypesMethods.sql',
  'tables.sql',
  'inserts.sql',
  'MethodsExecution.sql',
  'queries.sql',
];

// Main function to execute the menu
async function main() {
  await executeDeleteFile(); // Execute Delete.sql before showing the menu

  // Generate menu
  console.log('SQL Operations Menu:');
  menuFiles.forEach((file, index) => {
    console.log(`${index + 1}. ${file}`);
  });

  // Prompt user to select a file
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  rl.question('\nEnter the number of the file to execute: ', async answer => {
    const fileIndex = parseInt(answer) - 1;
    const selectedFile = menuFiles[fileIndex];

    if (!selectedFile) {
      console.error('Invalid selection. Exiting.');
      rl.close();
      return;
    }

    const filePath = path.join(sqlFolderPath, selectedFile);
    const sqlContent = fs.readFileSync(filePath, 'utf8');

    try {
      // Connect to Oracle DB
      const connection = await oracledb.getConnection(dbConfig);
      console.log(`Executing ${selectedFile}...`);

      // Split the SQL file into individual statements
      const sqlStatements = sqlContent.split(';').map(stmt => stmt.trim()).filter(stmt => stmt);

      // Execute each statement
      for (const statement of sqlStatements) {
        console.log(`Executing: ${statement}`);
        await connection.execute(statement);
      }

      console.log('Execution completed successfully.');
      await connection.close();
    } catch (err) {
      console.error('Error executing SQL:', err);
    } finally {
      rl.close();
    }
  });
}

// Run the main function
main();