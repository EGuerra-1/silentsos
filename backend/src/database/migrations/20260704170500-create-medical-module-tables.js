'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('DiseaseCatalogs', {
      id: {
        allowNull: false,
        primaryKey: true,
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4
      },
      name: {
        type: Sequelize.STRING(250),
        allowNull: false
      },
      classification: {
        type: Sequelize.STRING(100),
        allowNull: false
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      created_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.fn('NOW')
      },
      updated_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.fn('NOW')
      },
      deleted_at: {
        allowNull: true,
        type: Sequelize.DATE
      }
    });

    await queryInterface.addConstraint('DiseaseCatalogs', {
      fields: ['name', 'classification'],
      type: 'unique',
      name: 'disease_catalogs_name_classification_unique'
    });

    await queryInterface.createTable('UserDiseases', {
      id: {
        allowNull: false,
        primaryKey: true,
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4
      },
      user_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'Users',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      disease_catalog_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'DiseaseCatalogs',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'RESTRICT'
      },
      notes: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      diagnosed_at: {
        type: Sequelize.DATEONLY,
        allowNull: true
      },
      created_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.fn('NOW')
      },
      updated_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.fn('NOW')
      },
      deleted_at: {
        allowNull: true,
        type: Sequelize.DATE
      }
    });

    await queryInterface.addIndex('UserDiseases', ['user_id'], {
      name: 'user_diseases_user_id_idx'
    });
    await queryInterface.addIndex('UserDiseases', ['disease_catalog_id'], {
      name: 'user_diseases_disease_catalog_id_idx'
    });

    await queryInterface.createTable('MedicationPlans', {
      id: {
        allowNull: false,
        primaryKey: true,
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4
      },
      user_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'Users',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      status: {
        type: Sequelize.ENUM('active', 'inactive'),
        allowNull: false,
        defaultValue: 'active'
      },
      title: {
        type: Sequelize.STRING(250),
        allowNull: true
      },
      created_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.fn('NOW')
      },
      updated_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.fn('NOW')
      },
      deleted_at: {
        allowNull: true,
        type: Sequelize.DATE
      }
    });

    await queryInterface.addIndex('MedicationPlans', ['user_id'], {
      name: 'medication_plans_user_id_idx'
    });
    await queryInterface.addIndex('MedicationPlans', ['status'], {
      name: 'medication_plans_status_idx'
    });

    await queryInterface.createTable('MedicationVersions', {
      id: {
        allowNull: false,
        primaryKey: true,
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4
      },
      medication_plan_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'MedicationPlans',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      version: {
        type: Sequelize.INTEGER,
        allowNull: false
      },
      name: {
        type: Sequelize.STRING(250),
        allowNull: false
      },
      dose: {
        type: Sequelize.STRING(100),
        allowNull: false
      },
      unit: {
        type: Sequelize.STRING(50),
        allowNull: false
      },
      frequency: {
        type: Sequelize.STRING(100),
        allowNull: false
      },
      observations: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      valid_from: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.fn('NOW')
      },
      valid_to: {
        type: Sequelize.DATE,
        allowNull: true
      },
      is_current: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true
      },
      created_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.fn('NOW')
      },
      updated_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.fn('NOW')
      },
      deleted_at: {
        allowNull: true,
        type: Sequelize.DATE
      }
    });

    await queryInterface.addConstraint('MedicationVersions', {
      fields: ['medication_plan_id', 'version'],
      type: 'unique',
      name: 'medication_versions_plan_version_unique'
    });
    await queryInterface.addIndex('MedicationVersions', ['medication_plan_id'], {
      name: 'medication_versions_plan_id_idx'
    });
    await queryInterface.addIndex('MedicationVersions', ['is_current'], {
      name: 'medication_versions_is_current_idx'
    });

    await queryInterface.createTable('MedicationSchedules', {
      id: {
        allowNull: false,
        primaryKey: true,
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4
      },
      medication_version_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'MedicationVersions',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      time_of_day: {
        type: Sequelize.TIME,
        allowNull: false
      },
      notes: {
        type: Sequelize.STRING(250),
        allowNull: true
      },
      created_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.fn('NOW')
      },
      updated_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.fn('NOW')
      },
      deleted_at: {
        allowNull: true,
        type: Sequelize.DATE
      }
    });

    await queryInterface.addIndex('MedicationSchedules', ['medication_version_id'], {
      name: 'medication_schedules_version_id_idx'
    });

    await queryInterface.createTable('MedicationConsumptionHistories', {
      id: {
        allowNull: false,
        primaryKey: true,
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4
      },
      medication_plan_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'MedicationPlans',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      medication_version_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'MedicationVersions',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      scheduled_time: {
        type: Sequelize.TIME,
        allowNull: true
      },
      consumed_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.fn('NOW')
      },
      status: {
        type: Sequelize.ENUM('consumed', 'skipped', 'missed'),
        allowNull: false,
        defaultValue: 'consumed'
      },
      observations: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      created_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.fn('NOW')
      },
      updated_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.fn('NOW')
      },
      deleted_at: {
        allowNull: true,
        type: Sequelize.DATE
      }
    });

    await queryInterface.addIndex('MedicationConsumptionHistories', ['medication_plan_id'], {
      name: 'medication_consumption_histories_plan_id_idx'
    });
    await queryInterface.addIndex('MedicationConsumptionHistories', ['consumed_at'], {
      name: 'medication_consumption_histories_consumed_at_idx'
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable('MedicationConsumptionHistories');
    await queryInterface.dropTable('MedicationSchedules');
    await queryInterface.dropTable('MedicationVersions');
    await queryInterface.dropTable('MedicationPlans');
    await queryInterface.dropTable('UserDiseases');
    await queryInterface.dropTable('DiseaseCatalogs');
    await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_MedicationPlans_status";');
    await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_MedicationConsumptionHistories_status";');
  }
};
