import { Repository } from "typeorm"
import appDataSource from "@db/typeorm/data-source"
import { IUser } from "@modules/user/domain/entities/user/user"
import { IUserRepository } from "@modules/user/domain/repositories/user/i-user-repository"
import { CreateUserData, UpdateUserData } from "@modules/user/domain/repositories/user/i-user-write-repository"
import { User } from "../entities/user"
import { AppError } from "@shared/errors/app-error"

class UserRepository implements IUserRepository {
  private repository: Repository<User>

  constructor() {
    this.repository = appDataSource.getRepository(User)
  }

  async get(id: string): Promise<IUser | null> {
    try {
      return await this.repository.findOne({ where: { id } })
    } catch (error) {
      throw new AppError('Failed to fetch user', 500)
    }
  }

  async create(data: CreateUserData): Promise<IUser> {
    try {
      const user = this.repository.create(data)
      return await this.repository.save(user)
    } catch (error) {
      throw new AppError('Failed to create user', 500)
    }
  }

  async update(id: string, data: UpdateUserData): Promise<IUser | null> {
    try {
      await this.repository.update(id, data)
      return await this.repository.findOne({ where: { id } })
    } catch (error) {
      throw new AppError('Database error on update user', 500)
    }
  }

  async delete(id: string): Promise<boolean> {
    try {
      const result = await this.repository.delete(id)
      return result.affected !== 0
    } catch (error) {
      throw new AppError('Database error on delete user', 500)
    }
  }
}

export { UserRepository }
