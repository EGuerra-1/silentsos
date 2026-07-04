// src/models/base.entity.js
const { Model, DataTypes } = require('sequelize');

class BaseEntity extends Model {
  /**
   * Método init para inicializar el modelo con atributos y opciones estándar.
   */
  static init(attrs, options) {
    // Atributos base para todos los modelos: UUID en vez de integer autoincrement.
    const baseAttrs = {
      id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,  // Genera un UUID v4 desde Sequelize
        primaryKey: true,
        allowNull: false
      }
      // Si necesitas otros atributos "globales", agrégalos aquí
    };

    // Combinas los atributos del modelo hijo con los atributos base
    super.init(
      { ...baseAttrs, ...attrs },
      {
        timestamps: true,         // crea created_at y updated_at
        paranoid: true,           // activa soft delete → deleted_at
        createdAt: 'created_at',  // renombre de columna
        updatedAt: 'updated_at',
        deletedAt: 'deleted_at',
        ...options
      }
    );
  }
}

module.exports = BaseEntity;