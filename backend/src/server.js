const app = require('./app');
const dotenv = require('dotenv');

dotenv.config(); // Carga variables de entorno desde .env

const PORT = process.env.API_PORT;

app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
});