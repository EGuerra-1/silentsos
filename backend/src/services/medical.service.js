const { Op } = require('sequelize');
const {
  sequelize,
  DiseaseCatalog,
  UserDisease,
  MedicationPlan,
  MedicationVersion,
  MedicationSchedule,
  MedicationConsumptionHistory
} = require('../models');

class MedicalService {
  // Ordena versiones y horarios para entregar respuestas estables al cliente.
  static normalizeMedicationPlan(plan) {
    if (!plan) return plan;
    if (Array.isArray(plan.versions)) {
      plan.versions.sort((a, b) => b.version - a.version);
      for (const version of plan.versions) {
        if (Array.isArray(version.schedules)) {
          version.schedules.sort((a, b) => String(a.time_of_day).localeCompare(String(b.time_of_day)));
        }
      }
    }
    return plan;
  }

  async getDiseaseCatalogs() {
    return DiseaseCatalog.findAll({
      order: [
        ['classification', 'ASC'],
        ['name', 'ASC']
      ]
    });
  }

  // Persiste enfermedad ligada al usuario autenticado.
  async createUserDisease(userId, payload) {
    return UserDisease.create({
      user_id: userId,
      disease_catalog_id: payload.disease_catalog_id,
      notes: payload.notes || null,
      diagnosed_at: payload.diagnosed_at || null
    });
  }

  async getUserDiseases(userId) {
    return UserDisease.findAll({
      where: { user_id: userId },
      include: [
        {
          model: DiseaseCatalog,
          as: 'diseaseCatalog',
          attributes: ['id', 'name', 'classification', 'description']
        }
      ],
      order: [['created_at', 'DESC']]
    });
  }

  // Permite edición solo sobre registros del propio usuario.
  async updateUserDisease(userId, userDiseaseId, payload) {
    const userDisease = await UserDisease.findOne({
      where: {
        id: userDiseaseId,
        user_id: userId
      }
    });
    if (!userDisease) {
      return null;
    }
    await userDisease.update({
      disease_catalog_id: payload.disease_catalog_id,
      notes: payload.notes || null,
      diagnosed_at: payload.diagnosed_at || null
    });
    return userDisease;
  }

  // Crea plan + versión inicial + horarios en una sola transacción.
  async createMedication(userId, payload, externalTransaction = null) {
    const runner = async (transaction) => {
      const plan = await MedicationPlan.create(
        {
          user_id: userId,
          status: 'active',
          title: payload.title || payload.name
        },
        { transaction }
      );

      const version = await MedicationVersion.create(
        {
          medication_plan_id: plan.id,
          version: 1,
          name: payload.name,
          dose: payload.dose,
          unit: payload.unit,
          frequency: payload.frequency,
          observations: payload.observations || null,
          valid_from: new Date(),
          is_current: true
        },
        { transaction }
      );

      const schedulesData = payload.schedules.map((schedule) => ({
        medication_version_id: version.id,
        time_of_day: schedule.time_of_day,
        notes: schedule.notes || null
      }));

      await MedicationSchedule.bulkCreate(schedulesData, { transaction });

      return this.getMedicationPlanForUser(userId, plan.id, transaction);
    };

    if (externalTransaction) {
      return runner(externalTransaction);
    }
    return sequelize.transaction(runner);
  }

  // Registro masivo atómico: todo se confirma o todo se revierte.
  async createMedicationBulk(userId, medications) {
    return sequelize.transaction(async (transaction) => {
      const createdPlans = [];
      for (const medication of medications) {
        const created = await this.createMedication(userId, medication, transaction);
        createdPlans.push(created);
      }
      return createdPlans;
    });
  }

  // Mantiene histórico cerrando la versión actual antes de crear la nueva.
  async updateMedicationVersion(userId, planId, payload) {
    return sequelize.transaction(async (transaction) => {
      const plan = await MedicationPlan.findOne({
        where: {
          id: planId,
          user_id: userId
        },
        transaction
      });

      if (!plan) {
        return null;
      }

      const currentVersion = await MedicationVersion.findOne({
        where: {
          medication_plan_id: plan.id,
          is_current: true
        },
        order: [['version', 'DESC']],
        transaction
      });

      if (!currentVersion) {
        throw new Error('Current medication version not found');
      }

      await currentVersion.update(
        {
          is_current: false,
          valid_to: new Date()
        },
        { transaction }
      );

      const newVersionNumber = currentVersion.version + 1;

      const newVersion = await MedicationVersion.create(
        {
          medication_plan_id: plan.id,
          version: newVersionNumber,
          name: payload.name,
          dose: payload.dose,
          unit: payload.unit,
          frequency: payload.frequency,
          observations: payload.observations || null,
          valid_from: new Date(),
          valid_to: null,
          is_current: true
        },
        { transaction }
      );

      await MedicationSchedule.bulkCreate(
        payload.schedules.map((schedule) => ({
          medication_version_id: newVersion.id,
          time_of_day: schedule.time_of_day,
          notes: schedule.notes || null
        })),
        { transaction }
      );

      return this.getMedicationPlanForUser(userId, plan.id, transaction);
    });
  }

  async getMedicationPlanForUser(userId, planId, transaction = null) {
    const plan = await MedicationPlan.findOne({
      where: {
        id: planId,
        user_id: userId
      },
      include: [
        {
          model: MedicationVersion,
          as: 'versions',
          include: [
            {
              model: MedicationSchedule,
              as: 'schedules'
            }
          ]
        }
      ],
      transaction
    });
    return MedicalService.normalizeMedicationPlan(plan);
  }

  async getMedications(userId) {
    const plans = await MedicationPlan.findAll({
      where: {
        user_id: userId
      },
      include: [
        {
          model: MedicationVersion,
          as: 'versions',
          include: [
            {
              model: MedicationSchedule,
              as: 'schedules'
            }
          ]
        }
      ],
      order: [['created_at', 'DESC']]
    });
    return plans.map((plan) => MedicalService.normalizeMedicationPlan(plan));
  }

  // Historial append-only de consumo; no se sobrescriben eventos previos.
  async registerConsumption(userId, payload) {
    const plan = await MedicationPlan.findOne({
      where: {
        id: payload.medication_plan_id,
        user_id: userId,
        status: 'active'
      }
    });

    if (!plan) {
      return null;
    }

    const currentVersion = await MedicationVersion.findOne({
      where: {
        medication_plan_id: plan.id,
        is_current: true
      }
    });

    if (!currentVersion) {
      throw new Error('Current medication version not found');
    }

    return MedicationConsumptionHistory.create({
      medication_plan_id: plan.id,
      medication_version_id: currentVersion.id,
      scheduled_time: payload.scheduled_time || null,
      consumed_at: payload.consumed_at || new Date(),
      status: payload.status || 'consumed',
      observations: payload.observations || null
    });
  }

  // Filtros de historial orientados a reportes por estado y rango temporal.
  async getConsumptions(userId, filters) {
    const where = {};
    if (filters.status) {
      where.status = filters.status;
    }
    if (filters.from || filters.to) {
      where.consumed_at = {};
      if (filters.from) {
        where.consumed_at[Op.gte] = new Date(filters.from);
      }
      if (filters.to) {
        where.consumed_at[Op.lte] = new Date(filters.to);
      }
    }

    return MedicationConsumptionHistory.findAll({
      where,
      include: [
        {
          model: MedicationPlan,
          as: 'plan',
          where: {
            user_id: userId
          },
          attributes: ['id', 'title', 'status']
        },
        {
          model: MedicationVersion,
          as: 'version',
          attributes: ['id', 'name', 'dose', 'unit', 'frequency', 'version']
        }
      ],
      order: [['consumed_at', 'DESC']]
    });
  }

  // Calcula pendientes del día: horarios actuales menos consumos marcados como consumed.
  async getPendingMedicationsToday(userId, dateInput = null) {
    const now = new Date();
    const localDate = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
    const targetDate = dateInput || localDate;
    const startOfDay = new Date(`${targetDate}T00:00:00`);
    const endOfDay = new Date(`${targetDate}T23:59:59.999`);

    const plans = await MedicationPlan.findAll({
      where: {
        user_id: userId,
        status: 'active'
      },
      include: [
        {
          model: MedicationVersion,
          as: 'versions',
          where: { is_current: true },
          required: true,
          include: [
            {
              model: MedicationSchedule,
              as: 'schedules'
            }
          ]
        }
      ]
    });

    const consumptions = await MedicationConsumptionHistory.findAll({
      where: {
        consumed_at: {
          [Op.gte]: startOfDay,
          [Op.lte]: endOfDay
        },
        status: 'consumed'
      },
      include: [
        {
          model: MedicationPlan,
          as: 'plan',
          where: { user_id: userId },
          attributes: ['id']
        }
      ]
    });

    const consumedMap = new Set(
      consumptions
        .filter((item) => item.scheduled_time)
        .map((item) => `${item.medication_plan_id}::${item.scheduled_time}`)
    );

    const pending = [];
    for (const plan of plans) {
      const currentVersion = plan.versions[0];
      for (const schedule of currentVersion.schedules) {
        const key = `${plan.id}::${schedule.time_of_day}`;
        if (!consumedMap.has(key)) {
          pending.push({
            medication_plan_id: plan.id,
            medication_name: currentVersion.name,
            dose: currentVersion.dose,
            unit: currentVersion.unit,
            frequency: currentVersion.frequency,
            scheduled_time: schedule.time_of_day,
            schedule_notes: schedule.notes
          });
        }
      }
    }

    return {
      date: targetDate,
      total_pending: pending.length,
      pending
    };
  }
}

module.exports = MedicalService;
