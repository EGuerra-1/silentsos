const { DataTypes } = require('sequelize');
const BaseEntity = require('./base.entity');

class Triage extends BaseEntity {
  static initModel(sequelize) {
    super.init(
      {
        emergency_id: {
          type: DataTypes.UUID,
          allowNull: false
        },
        level: {
          type: DataTypes.STRING(50),
          allowNull: false
        },
        severity: {
          type: DataTypes.STRING(50),
          allowNull: false
        },
        injuries: {
          type: DataTypes.JSONB,
          allowNull: true
        },
        symptoms: {
          type: DataTypes.JSONB,
          allowNull: true
        },
        requires_ambulance: {
          type: DataTypes.BOOLEAN,
          allowNull: false,
          defaultValue: false
        },
        summary: {
          type: DataTypes.TEXT,
          allowNull: false
        },
        source: {
          type: DataTypes.STRING(50),
          allowNull: true
        }
      },
      {
        sequelize,
        modelName: 'Triage',
        tableName: 'Triages'
      }
    );
  }

  static associate(models) {
    this.belongsTo(models.Emergency, { foreignKey: 'emergency_id', as: 'emergency' });
  }
}

module.exports = Triage;
