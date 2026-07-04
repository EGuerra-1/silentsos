const { DataTypes } = require('sequelize');
const BaseEntity = require('./base.entity');

class MedicationSchedule extends BaseEntity {
  static initModel(sequelize) {
    super.init(
      {
        medication_version_id: {
          type: DataTypes.UUID,
          allowNull: false
        },
        time_of_day: {
          type: DataTypes.TIME,
          allowNull: false
        },
        notes: {
          type: DataTypes.STRING(250),
          allowNull: true
        }
      },
      {
        sequelize,
        modelName: 'MedicationSchedule',
        tableName: 'MedicationSchedules'
      }
    );
  }

  static associate(models) {
    this.belongsTo(models.MedicationVersion, { foreignKey: 'medication_version_id', as: 'version' });
  }
}

module.exports = MedicationSchedule;
