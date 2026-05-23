import { inject, injectable } from "tsyringe"
import { IRefreshTokenRepository } from "@modules/auth/domain/repositories/refresh-token/i-refresh-token-repository"
import { HttpResponse, noContent, serverError } from "@shared/helpers"

@injectable()
class LogoutUseCase {
  constructor(
    @inject('RefreshTokenRepository')
    private refreshTokenRepository: IRefreshTokenRepository
  ) {}

  async execute(userId: string): Promise<HttpResponse> {
    try {
      await this.refreshTokenRepository.revoke(userId)

      return noContent()
    } catch (error) {
      return serverError(error as Error)
    }
  }
}

export { LogoutUseCase }
