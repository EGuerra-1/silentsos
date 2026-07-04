const { DataTypes } = require('sequelize');
const BaseEntity = require('./base.entity');

class MedicationPlan extends BaseEntity {
  static initModel(sequelize) {
    super.init(
      {
        user_id: {
          type: DataTypes.UUID,
          allowNull: false
        },
        status: {
          type: DataTypes.ENUM('active', 'inactive'),
          allowNull: false,
          defaultValue: 'active'
        },
        title: {
          type: DataTypes.STRING(250),
          allowNull: true
        }
      },
      {
        sequelize,
        modelName: 'MedicationPlan',
        tableName: 'MedicationPlans'
      }
    );
  }

  static associate(models) {
    this.belongsTo(models.User, { foreignKey: 'user_id', as: 'user' });
    this.hasMany(models.MedicationVersion, { foreignKey: 'medication_plan_id', as: 'versions' });
    this.hasMany(models.MedicationConsumptionHistory, { foreignKey: 'medication_plan_id', as: 'consumptions' });
  }
}

module.exports = MedicationPlan;
