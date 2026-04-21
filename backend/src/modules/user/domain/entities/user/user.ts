export interface IUser {
  id: string
  name: string
  email: string
  password: string
  profileImageUrl: string | null
  totalDistance: number
  totalActivities: number
  createdAt: Date
  updatedAt: Date
}
