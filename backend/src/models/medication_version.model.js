const { DataTypes } = require('sequelize');
const BaseEntity = require('./base.entity');

class MedicationVersion extends BaseEntity {
  static initModel(sequelize) {
    super.init(
      {
        medication_plan_id: {
          type: DataTypes.UUID,
          allowNull: false
        },
        version: {
          type: DataTypes.INTEGER,
          allowNull: false
        },
        name: {
          type: DataTypes.STRING(250),
          allowNull: false
        },
        dose: {
          type: DataTypes.STRING(100),
          allowNull: false
        },
        unit: {
          type: DataTypes.STRING(50),
          allowNull: false
        },
        frequency: {
          type: DataTypes.STRING(100),
          allowNull: false
        },
        observations: {
          type: DataTypes.TEXT,
          allowNull: true
        },
        valid_from: {
          type: DataTypes.DATE,
          allowNull: false,
          defaultValue: DataTypes.NOW
        },
        valid_to: {
          type: DataTypes.DATE,
          allowNull: true
        },
        is_current: {
          type: DataTypes.BOOLEAN,
          allowNull: false,
          defaultValue: true
        }
      },
      {
        sequelize,
        modelName: 'MedicationVersion',
        tableName: 'MedicationVersions'
      }
    );
  }

  static associate(models) {
    this.belongsTo(models.MedicationPlan, { foreignKey: 'medication_plan_id', as: 'plan' });
    this.hasMany(models.MedicationSchedule, { foreignKey: 'medication_version_id', as: 'schedules' });
    this.hasMany(models.MedicationConsumptionHistory, { foreignKey: 'medication_version_id', as: 'consumptions' });
  }
}

module.exports = MedicationVersion;
