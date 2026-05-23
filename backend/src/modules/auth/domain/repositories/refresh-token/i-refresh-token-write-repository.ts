import { IRefreshToken } from "../../entities/refresh-token/refresh-token"

export interface UpsertRefreshTokenData {
  userId: string
  token: string
  expiresAt: Date
}

export interface IRefreshTokenWriteRepository {
  upsert(data: UpsertRefreshTokenData): Promise<IRefreshToken>
  revoke(userId: string): Promise<void>
}
