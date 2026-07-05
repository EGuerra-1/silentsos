// src/models/area.model.js
const { DataTypes } = require('sequelize');
const BaseEntity = require('./base.entity'); // Solo si usas una clase base

class User extends BaseEntity {
    static initModel(sequelize) {
        super.init(
            {
                full_name: {
                    type: DataTypes.STRING(250),
                    allowNull: false
                },
                email: {
                    type: DataTypes.STRING(250),
                    allowNull: true
                },
                rol: {
                    type: DataTypes.ENUM('admin', 'user'),
                    allowNull: false
                },
                cellphone: {
                    type: DataTypes.STRING(20),
                    allowNull: false
                },
                password: {
                    type: DataTypes.STRING(250),
                    allowNull: false
                }

            },
            {
                sequelize,
                modelName: 'User',
                tableName: 'Users'
            }
        );
    }
    static associate(models) {
        this.hasMany(models.EmergencyContact, { foreignKey: 'user_id', as: 'emergencyContacts' });
        this.hasMany(models.UserDisease, { foreignKey: 'user_id', as: 'userDiseases' });
        this.hasMany(models.MedicationPlan, { foreignKey: 'user_id', as: 'medicationPlans' });
        this.hasMany(models.Emergency, { foreignKey: 'user_id', as: 'emergencies' });
    }
}

module.exports = User;