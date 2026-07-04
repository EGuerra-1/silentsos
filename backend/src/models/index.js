
// src/models/index.js
const fs = require('fs');
const path = require('path');
const { Sequelize } = require('sequelize');
const config = require('../config/database')[process.env.NODE_ENV || 'development'];

// Instancia de sequelize
const sequelize = new Sequelize(
  config.database,
  config.username,
  config.password,
  {
    host: config.host,
    dialect: config.dialect,
    port: config.port,
    logging: false
  }
);

const db = {};

// Lee todos los archivos del directorio actual
fs.readdirSync(__dirname)
  .filter((file) => {
    // Filtra para obtener solo archivos .model.js y
    // descarta index.js (u otros archivos que no sean modelos)
    return (
      file !== path.basename(__filename) &&
      file.endsWith('.model.js')
    );
  })
  .forEach((file) => {
    const modelClass = require(path.join(__dirname, file));
    
    // Verificamos que exista el método initModel
    if (typeof modelClass.initModel === 'function') {
      // Inicializamos el modelo
      modelClass.initModel(sequelize);
      
      // Guardamos el modelo en 'db' usando su nombre de clase
      // Por convención, Sequelize usa modelClass.name para "Area", etc.
      db[modelClass.name] = modelClass;
    }
  });

// Si tus modelos tienen un método associate(db), 
// llama aquí a la asociación después de cargarlos
Object.keys(db).forEach((modelName) => {
  if (typeof db[modelName].associate === 'function') {
    db[modelName].associate(db);
  }
});

// Agregamos las referencias de sequelize y Sequelize
db.sequelize = sequelize;
db.Sequelize = Sequelize;

module.exports = db;
