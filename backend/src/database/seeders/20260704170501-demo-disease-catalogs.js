'use strict';
const crypto = require('crypto');

/** @type {import('sequelize-cli').Seeder} */
module.exports = {
  async up(queryInterface) {
    const now = new Date();

    await queryInterface.bulkInsert('DiseaseCatalogs', [
      {
        id: crypto.randomUUID(),
        name: 'Diabetes',
        classification: 'Tipo 1',
        description: 'Enfermedad crónica que afecta la forma en que el cuerpo procesa la glucosa.',
        created_at: now,
        updated_at: now
      },
      {
        id: crypto.randomUUID(),
        name: 'Diabetes',
        classification: 'Tipo 2',
        description: 'Trastorno metabólico con resistencia a la insulina y niveles elevados de glucosa.',
        created_at: now,
        updated_at: now
      },
      {
        id: crypto.randomUUID(),
        name: 'Hipertensión',
        classification: 'Cardiovascular',
        description: 'Presión arterial alta sostenida que requiere control periódico.',
        created_at: now,
        updated_at: now
      },
      {
        id: crypto.randomUUID(),
        name: 'Asma',
        classification: 'Respiratoria',
        description: 'Inflamación crónica de las vías respiratorias con episodios de dificultad respiratoria.',
        created_at: now,
        updated_at: now
      }
    ], {});
  },

  async down(queryInterface) {
    await queryInterface.bulkDelete('DiseaseCatalogs', null, {});
  }
};
