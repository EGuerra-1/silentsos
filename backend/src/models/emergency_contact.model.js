const { DataTypes } = require('sequelize');
const BaseEntity = require('./base.entity');

class EmergencyContact extends BaseEntity {
    static initModel(sequelize) {
        super.init(
            {
                user_id: {
                    type: DataTypes.UUID,
                    allowNull: false
                },
                full_name: {
                    type: DataTypes.STRING(250),
                    allowNull: false
                },
                cellphone: {
                    type: DataTypes.STRING(20),
                    allowNull: false
                },
                relationship: {
                    type: DataTypes.STRING(100),
                    allowNull: false
                }
            },
            {
                sequelize,
                modelName: 'EmergencyContact',
                tableName: 'EmergencyContacts'
            }
        );
    }

    static associate(models) {
        this.belongsTo(models.User, { foreignKey: 'user_id', as: 'user' });
    }
}

module.exports = EmergencyContact;
