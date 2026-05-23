import { IRefreshToken } from "../../entities/refresh-token/refresh-token"

interface IRefreshTokenReadRepository {
  findByToken(token: string): Promise<IRefreshToken | null>
  findByUserId(userId: string): Promise<IRefreshToken[]>
}

export { IRefreshTokenReadRepository }
