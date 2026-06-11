import { ActivityType, RoutePoint } from "@modules/activity/domain/entities/activity/activity"

export interface ICreateActivityDTO {
  userId: string
  title: string
  description?: string | null
  type: ActivityType
  distance: number
  durationSeconds: number
  date: Date
  averagePace?: number | null
  calories?: number | null
  route?: RoutePoint[] | null
}

export interface IUpdateActivityDTO {
  id: string
  title?: string
  description?: string | null
  type?: ActivityType
  distance?: number
  durationSeconds?: number
  date?: Date
  averagePace?: number | null
  calories?: number | null
  route?: RoutePoint[] | null
}
