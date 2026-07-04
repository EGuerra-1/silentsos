const { DataTypes } = require('sequelize');
const BaseEntity = require('./base.entity');

class DiseaseCatalog extends BaseEntity {
  static initModel(sequelize) {
    super.init(
      {
        name: {
          type: DataTypes.STRING(250),
          allowNull: false
        },
        classification: {
          type: DataTypes.STRING(100),
          allowNull: false
        },
        description: {
          type: DataTypes.TEXT,
          allowNull: true
        }
      },
      {
        sequelize,
        modelName: 'DiseaseCatalog',
        tableName: 'DiseaseCatalogs'
      }
    );
  }

  static associate(models) {
    this.hasMany(models.UserDisease, { foreignKey: 'disease_catalog_id', as: 'userDiseases' });
  }
}

module.exports = DiseaseCatalog;
