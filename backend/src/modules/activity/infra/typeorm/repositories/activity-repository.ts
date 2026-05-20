import { Repository } from "typeorm"
import appDataSource from "@db/typeorm/data-source"
import { IActivity } from "@modules/activity/domain/entities/activity/activity"
import { IActivityRepository } from "@modules/activity/domain/repositories/activity/i-activity-repository"
import { CreateActivityData, UpdateActivityData } from "@modules/activity/domain/repositories/activity/i-activity-write-repository"
import { Activity } from "../entities/activity"
import { AppError } from "@shared/errors/app-error"

class ActivityRepository implements IActivityRepository {
  private repository: Repository<Activity>

  constructor() {
    this.repository = appDataSource.getRepository(Activity)
  }

  async findById(id: string): Promise<IActivity | null> {
    try {
      return await this.repository.findOne({ where: { id } })
    } catch (error) {
      throw new AppError('Failed to fetch activity', 500)
    }
  }

  async findByUserId(userId: string): Promise<IActivity[]> {
    try {
      return await this.repository.find({
        where: { userId },
        order: { date: 'DESC' },
      })
    } catch (error) {
      throw new AppError('Failed to fetch activities', 500)
    }
  }

  async create(data: CreateActivityData): Promise<IActivity> {
    try {
      const activity = this.repository.create(data)
      return await this.repository.save(activity)
    } catch (error) {
      throw new AppError('Failed to create activity', 500)
    }
  }

  async update(id: string, data: UpdateActivityData): Promise<IActivity | null> {
    try {
      await this.repository.update(id, data)
      return await this.repository.findOne({ where: { id } })
    } catch (error) {
      throw new AppError('Database error on update activity', 500)
    }
  }

  async delete(id: string): Promise<boolean> {
    try {
      const result = await this.repository.delete(id)
      return result.affected !== 0
    } catch (error) {
      throw new AppError('Database error on delete activity', 500)
    }
  }
}

export { ActivityRepository }
