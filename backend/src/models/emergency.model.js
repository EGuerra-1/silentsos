const { DataTypes } = require('sequelize');
const BaseEntity = require('./base.entity');

class Emergency extends BaseEntity {
  static initModel(sequelize) {
    super.init(
      {
        user_id: {
          type: DataTypes.UUID,
          allowNull: false
        },
        type: {
          type: DataTypes.ENUM('medical', 'general'),
          allowNull: false
        },
        call_mode: {
          type: DataTypes.ENUM('single_context', 'interactive'),
          allowNull: false
        },
        status: {
          type: DataTypes.ENUM(
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
          type: DataTypes.STRING(50),
          allowNull: true
        },
        latitude: {
          type: DataTypes.DECIMAL(10, 7),
          allowNull: true
        },
        longitude: {
          type: DataTypes.DECIMAL(10, 7),
          allowNull: true
        },
        address: {
          type: DataTypes.TEXT,
          allowNull: true
        },
        image_url: {
          type: DataTypes.TEXT,
          allowNull: true
        },
        front_image_url: {
          type: DataTypes.TEXT,
          allowNull: true
        },
        back_image_url: {
          type: DataTypes.TEXT,
          allowNull: true
        },
        video_url: {
          type: DataTypes.TEXT,
          allowNull: true
        },
        context_text: {
          type: DataTypes.TEXT,
          allowNull: true
        },
        description: {
          type: DataTypes.TEXT,
          allowNull: true
        },
        audio_url: {
          type: DataTypes.TEXT,
          allowNull: true
        }
      },
      {
        sequelize,
        modelName: 'Emergency',
        tableName: 'Emergencies'
      }
    );
  }

  static associate(models) {
    this.belongsTo(models.User, { foreignKey: 'user_id', as: 'user' });
    this.hasOne(models.Triage, { foreignKey: 'emergency_id', as: 'triage' });
    this.hasMany(models.CallHistory, { foreignKey: 'emergency_id', as: 'callHistories' });
  }
}

module.exports = Emergency;
