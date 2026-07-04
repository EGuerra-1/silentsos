'use strict';
const crypto = require('crypto');
const { ids } = require('./20250411223350-demo-users');

module.exports = {
  async up(queryInterface) {
    await queryInterface.bulkInsert('EmergencyContacts', [
      {
        id: crypto.randomUUID(),
        user_id: ids.userId,
        full_name: 'María López',
        cellphone: '1112223333',
        relationship: 'Mother',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: crypto.randomUUID(),
        user_id: ids.userId,
        full_name: 'Carlos Pérez',
        cellphone: '4445556666',
        relationship: 'Brother',
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        id: crypto.randomUUID(),
        user_id: ids.adminId,
        full_name: 'Ana García',
        cellphone: '7778889999',
        relationship: 'Sister',
        created_at: new Date(),
        updated_at: new Date()
      }
    ]);
  },

  async down(queryInterface) {
    await queryInterface.bulkDelete('EmergencyContacts', null, {});
  }
};
