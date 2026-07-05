const { DataTypes } = require('sequelize');
const BaseEntity = require('./base.entity');

class CallHistory extends BaseEntity {
  static initModel(sequelize) {
    super.init(
      {
        emergency_id: {
          type: DataTypes.UUID,
          allowNull: false
        },
        twilio_call_sid: {
          type: DataTypes.STRING(64),
          allowNull: true
        },
        mode: {
          type: DataTypes.ENUM('single_context', 'interactive'),
          allowNull: false
        },
        status: {
          type: DataTypes.STRING(50),
          allowNull: false,
          defaultValue: 'queued'
        },
        started_at: {
          type: DataTypes.DATE,
          allowNull: true
        },
        ended_at: {
          type: DataTypes.DATE,
          allowNull: true
        },
        details: {
          type: DataTypes.JSONB,
          allowNull: true
        }
      },
      {
        sequelize,
        modelName: 'CallHistory',
        tableName: 'CallHistories'
      }
    );
  }

  static associate(models) {
    this.belongsTo(models.Emergency, { foreignKey: 'emergency_id', as: 'emergency' });
  }
}

module.exports = CallHistory;
