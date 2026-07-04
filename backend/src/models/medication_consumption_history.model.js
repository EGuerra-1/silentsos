const { DataTypes } = require('sequelize');
const BaseEntity = require('./base.entity');

class MedicationConsumptionHistory extends BaseEntity {
  static initModel(sequelize) {
    super.init(
      {
        medication_plan_id: {
          type: DataTypes.UUID,
          allowNull: false
        },
        medication_version_id: {
          type: DataTypes.UUID,
          allowNull: false
        },
        scheduled_time: {
          type: DataTypes.TIME,
          allowNull: true
        },
        consumed_at: {
          type: DataTypes.DATE,
          allowNull: false,
          defaultValue: DataTypes.NOW
        },
        status: {
          type: DataTypes.ENUM('consumed', 'skipped', 'missed'),
          allowNull: false,
          defaultValue: 'consumed'
        },
        observations: {
          type: DataTypes.TEXT,
          allowNull: true
        }
      },
      {
        sequelize,
        modelName: 'MedicationConsumptionHistory',
        tableName: 'MedicationConsumptionHistories'
      }
    );
  }

  static associate(models) {
    this.belongsTo(models.MedicationPlan, { foreignKey: 'medication_plan_id', as: 'plan' });
    this.belongsTo(models.MedicationVersion, { foreignKey: 'medication_version_id', as: 'version' });
  }
}

module.exports = MedicationConsumptionHistory;
