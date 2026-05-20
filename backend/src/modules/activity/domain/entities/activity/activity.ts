export type ActivityType = 'running' | 'cycling' | 'walking' | 'hiking' | 'swimming'

export interface IActivity {
  id: string
  userId: string
  title: string
  description: string | null
  type: ActivityType
  distance: number
  durationSeconds: number
  date: Date
  averagePace: number | null
  calories: number | null
  createdAt: Date
  updatedAt: Date
}
