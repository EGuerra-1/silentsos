'use strict';
const crypto = require('crypto');

const adminId = crypto.randomUUID();
const userId = crypto.randomUUID();

module.exports = {
  async up(queryInterface) {
    await queryInterface.bulkInsert('Users', [
      {
        id: adminId,
        full_name: 'Administrador Principal',
        email: 'admin@gmail.com',
        rol: 'admin',
        cellphone: '1234567890',
        password: '$2b$10$Yajn1J3r13tAGSYnlMSGkuZ.Be6WBv.Y2vzXv50z9IiZZM6Ty8k3S',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: userId,
        full_name: 'Usuario Común',
        email: 'user@gmail.com',
        rol: 'user',
        cellphone: '0987654321',
        password: '$2b$10$Yajn1J3r13tAGSYnlMSGkuZ.Be6WBv.Y2vzXv50z9IiZZM6Ty8k3S',
        created_at: new Date(),
        updated_at: new Date()
      }
    ]);
  },

  async down(queryInterface) {
    await queryInterface.bulkDelete('Users', null, {});
  },

  ids: { adminId, userId }
};
