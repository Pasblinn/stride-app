import { IUser } from "../../entities/user/user"


interface IUserReadRepository {
  get(id: string): Promise<IUser | null>
  findByEmail(email: string): Promise<IUser | null>
}

export { IUserReadRepository }