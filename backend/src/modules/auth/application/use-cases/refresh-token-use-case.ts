import { inject, injectable } from "tsyringe"
import jwt from "jsonwebtoken"
import { IRefreshTokenRepository } from "@modules/auth/domain/repositories/refresh-token/i-refresh-token-repository"
import { HttpResponse, ok, serverError, unauthorized } from "@shared/helpers"
import authConfig from "config/auth.config"

@injectable()
class RefreshTokenUseCase {
  constructor(
    @inject('RefreshTokenRepository')
    private refreshTokenRepository: IRefreshTokenRepository
  ) {}

  async execute(userId: string, oldRefreshToken: string): Promise<HttpResponse> {
    try {
      const stored = await this.refreshTokenRepository.findByToken(oldRefreshToken)

      if (!stored || stored.revokedAt !== null || stored.expiresAt < new Date()) {
        return unauthorized()
      }

      const token = jwt.sign(
        { userId },
        authConfig.secret,
        { expiresIn: authConfig.secret_expires_in as any }
      )

      const newRefreshToken = jwt.sign(
        { userId },
        authConfig.refresh_secret,
        { expiresIn: authConfig.refresh_secret_expires_in as any }
      )

      const decoded = jwt.decode(newRefreshToken) as { exp: number }
      const expiresAt = new Date(decoded.exp * 1000)

      await this.refreshTokenRepository.upsert({ userId, token: newRefreshToken, expiresAt })

      return ok({ token, refreshToken: newRefreshToken })
    } catch (error) {
      return serverError(error as Error)
    }
  }
}

export { RefreshTokenUseCase }
