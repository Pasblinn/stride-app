import { IUser } from "../../entities/user/user"

export interface CreateUserData {
  name: string
  email: string
  password: string
  profileImageUrl?: string | null
}

export interface UpdateUserData {
  name?: string
  email?: string
  password?: string
  profileImageUrl?: string | null
  totalDistance?: number
  totalActivities?: number
}

export interface IUserWriteRepository {
  create(data: CreateUserData): Promise<IUser>
  update(id: string, data: UpdateUserData): Promise<IUser | null>
  delete(id: string): Promise<boolean>
}