'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.addColumn('Emergencies', 'front_image_url', {
      type: Sequelize.TEXT,
      allowNull: true,
      after: 'image_url'
    });

    await queryInterface.addColumn('Emergencies', 'back_image_url', {
      type: Sequelize.TEXT,
      allowNull: true,
      after: 'front_image_url'
    });
  },

  async down(queryInterface) {
    await queryInterface.removeColumn('Emergencies', 'front_image_url');
    await queryInterface.removeColumn('Emergencies', 'back_image_url');
  }
};
