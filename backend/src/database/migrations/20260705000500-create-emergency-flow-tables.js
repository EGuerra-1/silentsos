'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('Emergencies', {
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
      type: {
        type: Sequelize.ENUM('medical', 'general'),
        allowNull: false
      },
      call_mode: {
        type: Sequelize.ENUM('single_context', 'interactive'),
        allowNull: false
      },
      status: {
        type: Sequelize.ENUM(
          'PENDING',
          'ANALYZING',
          'TRIAGE_GENERATED',
          'AUDIO_GENERATED',
          'CALL_STARTED',
          'SMS_SENT',
          'COMPLETED',
          'FAILED'
        ),
        allowNull: false,
        defaultValue: 'PENDING'
      },
      priority: {
        type: Sequelize.STRING(50),
        allowNull: true
      },
      latitude: {
        type: Sequelize.DECIMAL(10, 7),
        allowNull: true
      },
      longitude: {
        type: Sequelize.DECIMAL(10, 7),
        allowNull: true
      },
      address: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      image_url: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      video_url: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      context_text: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      audio_url: {
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

    await queryInterface.addIndex('Emergencies', ['user_id'], {
      name: 'emergencies_user_id_idx'
    });
    await queryInterface.addIndex('Emergencies', ['status'], {
      name: 'emergencies_status_idx'
    });
    await queryInterface.addIndex('Emergencies', ['type'], {
      name: 'emergencies_type_idx'
    });

    await queryInterface.createTable('Triages', {
      id: {
        allowNull: false,
        primaryKey: true,
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4
      },
      emergency_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'Emergencies',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      level: {
        type: Sequelize.STRING(50),
        allowNull: false
      },
      severity: {
        type: Sequelize.STRING(50),
        allowNull: false
      },
      injuries: {
        type: Sequelize.JSONB,
        allowNull: true
      },
      symptoms: {
        type: Sequelize.JSONB,
        allowNull: true
      },
      requires_ambulance: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false
      },
      summary: {
        type: Sequelize.TEXT,
        allowNull: false
      },
      source: {
        type: Sequelize.STRING(50),
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

    await queryInterface.addIndex('Triages', ['emergency_id'], {
      name: 'triages_emergency_id_idx'
    });

    await queryInterface.createTable('CallHistories', {
      id: {
        allowNull: false,
        primaryKey: true,
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4
      },
      emergency_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'Emergencies',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      twilio_call_sid: {
        type: Sequelize.STRING(64),
        allowNull: true
      },
      mode: {
        type: Sequelize.ENUM('single_context', 'interactive'),
        allowNull: false
      },
      status: {
        type: Sequelize.STRING(50),
        allowNull: false,
        defaultValue: 'queued'
      },
      started_at: {
        type: Sequelize.DATE,
        allowNull: true
      },
      ended_at: {
        type: Sequelize.DATE,
        allowNull: true
      },
      details: {
        type: Sequelize.JSONB,
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

    await queryInterface.addIndex('CallHistories', ['emergency_id'], {
      name: 'call_histories_emergency_id_idx'
    });
    await queryInterface.addIndex('CallHistories', ['twilio_call_sid'], {
      name: 'call_histories_twilio_call_sid_idx'
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable('CallHistories');
    await queryInterface.dropTable('Triages');
    await queryInterface.dropTable('Emergencies');

    await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_Emergencies_type";');
    await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_Emergencies_call_mode";');
    await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_Emergencies_status";');
    await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_CallHistories_mode";');
  }
};
