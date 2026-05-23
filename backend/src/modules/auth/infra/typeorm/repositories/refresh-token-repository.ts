import { Repository } from "typeorm"
import appDataSource from "@db/typeorm/data-source"
import { IRefreshToken } from "@modules/auth/domain/entities/refresh-token/refresh-token"
import { IRefreshTokenRepository } from "@modules/auth/domain/repositories/refresh-token/i-refresh-token-repository"
import { UpsertRefreshTokenData } from "@modules/auth/domain/repositories/refresh-token/i-refresh-token-write-repository"
import { RefreshToken } from "../entities/refresh-token"
import { AppError } from "@shared/errors/app-error"

class RefreshTokenRepository implements IRefreshTokenRepository {
  private repository: Repository<RefreshToken>

  constructor() {
    this.repository = appDataSource.getRepository(RefreshToken)
  }

  async findByToken(token: string): Promise<IRefreshToken | null> {
    try {
      return await this.repository.findOne({ where: { token } })
    } catch (error) {
      throw new AppError('Failed to fetch refresh token', 500)
    }
  }

  async findByUserId(userId: string): Promise<IRefreshToken[]> {
    try {
      return await this.repository.find({ where: { userId } })
    } catch (error) {
      throw new AppError('Failed to fetch refresh tokens', 500)
    }
  }

  async upsert(data: UpsertRefreshTokenData): Promise<IRefreshToken> {
    try {
      const existing = await this.repository.findOne({ where: { userId: data.userId } })

      if (existing) {
        await this.repository.update(existing.id, {
          token: data.token,
          expiresAt: data.expiresAt,
          revokedAt: null,
        })
        return (await this.repository.findOne({ where: { userId: data.userId } }))!
      }

      const refreshToken = this.repository.create(data)
      return await this.repository.save(refreshToken)
    } catch (error) {
      throw new AppError('Failed to upsert refresh token', 500)
    }
  }

  async revoke(userId: string): Promise<void> {
    try {
      await this.repository.update(
        { userId },
        { revokedAt: new Date() }
      )
    } catch (error) {
      throw new AppError('Failed to revoke refresh token', 500)
    }
  }
}

export { RefreshTokenRepository }
