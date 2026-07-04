const { DataTypes } = require('sequelize');
const BaseEntity = require('./base.entity');

class UserDisease extends BaseEntity {
  static initModel(sequelize) {
    super.init(
      {
        user_id: {
          type: DataTypes.UUID,
          allowNull: false
        },
        disease_catalog_id: {
          type: DataTypes.UUID,
          allowNull: false
        },
        notes: {
          type: DataTypes.TEXT,
          allowNull: true
        },
        diagnosed_at: {
          type: DataTypes.DATEONLY,
          allowNull: true
        }
      },
      {
        sequelize,
        modelName: 'UserDisease',
        tableName: 'UserDiseases'
      }
    );
  }

  static associate(models) {
    this.belongsTo(models.User, { foreignKey: 'user_id', as: 'user' });
    this.belongsTo(models.DiseaseCatalog, { foreignKey: 'disease_catalog_id', as: 'diseaseCatalog' });
  }
}

module.exports = UserDisease;
