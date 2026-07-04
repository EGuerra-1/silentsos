
const { Op } = require("sequelize");

/**
 * getPaginatedQuery
 * ------------------------------------------------------------
 * Esta función centraliza la lógica de paginación, filtrado,
 * ordenamiento, agrupación y relaciones en Sequelize, permitiendo
 * su reutilización en cualquier controlador de forma eficiente.
 *
 * @param {Object} config Configuración personalizada para cada consulta.
 * @returns {Object|Array} Resultado paginado o completo según configuración.
 */
const getPaginatedQuery = async ({
  model,               // 📌 Modelo de Sequelize (ej: User, Producto, etc.)
  page = 1,            // 📌 Página actual (default: 1)
  size = 10,           // 📌 Tamaño de página (registros por página)
  sortField = "created_at",  // 📌 Campo por el cual ordenar
  sortDirection = "DESC",   // 📌 Dirección del ordenamiento: ASC o DESC
  filters = {},        // 📌 Objeto con filtros para `where`
  fields = "",         // 📌 Campos específicos a devolver (ej: "id,nombre")
  includeModels = [],  // 📌 Modelos relacionados (relaciones Sequelize)
  group = null,        // 📌 Agrupamiento (group by) si aplica
  ComboBox = false,    // 📌 Si es true, ignora paginación (para dropdowns o select)
  noModels = false,    // 📌 Si es true, no se incluyen modelos relacionados
  additionalOptions = {} // 📌 Otras opciones que quieras pasar (ej: having, raw)
}) => {

  // 🧮 Parseo seguro de números y valores por defecto
  const currentPage = Math.max(parseInt(page) || 1, 1);
  const pageSize = parseInt(size) || 10;

  // 🎯 Calcular offset solo si no es ComboBox
  const offset = ComboBox ? null : (currentPage - 1) * pageSize;
  const limit = ComboBox ? null : pageSize;

  // 🔃 Construcción de orden dinámico
  const order = [[
    sortField,
    sortDirection.toUpperCase() === "ASC" ? "ASC" : "DESC"
  ]];

  // 🔎 Selección de campos: si no se pasan, se excluyen los metadata por defecto
  const attributes = fields
    ? fields.split(",")
    : { exclude: ["created_at", "updated_at", "deleted_at"] };

  // 🧩 Opciones base para la consulta Sequelize
  const options = {
    where: filters,                     // 🎯 Filtros dinámicos
    attributes,                         // 🧬 Campos a devolver
    include: noModels ? [] : includeModels, // 🔗 Relaciones JOIN
    order,                              // ↕ Ordenamiento
    limit,                              // 🔢 Límite de registros
    offset,                             // ⏩ Desplazamiento
    distinct: true,                     // 🧠 Necesario para evitar conteos incorrectos con JOINs
    ...additionalOptions,               // ⚙️ Extra configs (ej: raw, having, etc.)
  };

  /**
   * 🧠 Caso especial: si hay agrupación (`GROUP BY`), Sequelize no puede
   * usar `findAndCountAll` correctamente, por lo tanto:
   * - usamos `findAll`
   * - y aplicamos el conteo + paginación manualmente
   */
  if (group) {
    options.group = group;

    const allResults = await model.findAll(options);
    const totalItems = allResults.length;
    const paginatedItems = ComboBox ? allResults : allResults.slice(offset, offset + limit);

    return {
      meta: {
        totalItems,
        totalPages: Math.ceil(totalItems / pageSize),
        currentPage,
        perPage: pageSize,
      },
      data: paginatedItems,
    };
  }

  /**
   * 🧾 Caso especial ComboBox (ej: autocomplete o selects): sin paginación
   */
  if (ComboBox) {
    const allItems = await model.findAll(options);
    return allItems;
  }

  /**
   * 🚀 Consulta principal con paginación: `findAndCountAll` devuelve:
   * - rows: los datos paginados
   * - count: el total de registros sin limit/offset
   */
  const { count, rows } = await model.findAndCountAll(options);

  return {
    meta: {
      totalItems: count,
      totalPages: Math.ceil(count / pageSize),
      currentPage,
      perPage: pageSize,
    },
    data: rows,
  };
};

module.exports = { getPaginatedQuery };
