import { ActivityType, IActivity } from "../../entities/activity/activity"

export interface CreateActivityData {
  userId: string
  title: string
  description?: string | null
  type: ActivityType
  distance: number
  durationSeconds: number
  date: Date
  averagePace?: number | null
  calories?: number | null
}

export interface UpdateActivityData {
  title?: string
  description?: string | null
  type?: ActivityType
  distance?: number
  durationSeconds?: number
  date?: Date
  averagePace?: number | null
  calories?: number | null
}

export interface IActivityWriteRepository {
  create(data: CreateActivityData): Promise<IActivity>
  update(id: string, data: UpdateActivityData): Promise<IActivity | null>
  delete(id: string): Promise<boolean>
}
