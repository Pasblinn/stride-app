import { inject, injectable } from "tsyringe"
import bcrypt from "bcryptjs"
import jwt from "jsonwebtoken"
import { IUserRepository } from "@modules/user/domain/repositories/user/i-user-repository"
import { IRefreshTokenRepository } from "@modules/auth/domain/repositories/refresh-token/i-refresh-token-repository"
import { ILoginDTO } from "../dto/i-auth-dto"
import { HttpResponse, ok, serverError, unauthorized } from "@shared/helpers"
import authConfig from "config/auth.config"

@injectable()
class LoginUseCase {
  constructor(
    @inject('UserRepository')
    private userRepository: IUserRepository,

    @inject('RefreshTokenRepository')
    private refreshTokenRepository: IRefreshTokenRepository
  ) {}

  async execute({ email, password }: ILoginDTO): Promise<HttpResponse> {
    try {
      const user = await this.userRepository.findByEmail(email)

      if (!user) {
        return unauthorized()
      }

      const passwordMatch = await bcrypt.compare(password, user.password)

      if (!passwordMatch) {
        return unauthorized()
      }

      const token = jwt.sign(
        { userId: user.id },
        authConfig.secret,
        { expiresIn: authConfig.secret_expires_in as any }
      )

      const refreshToken = jwt.sign(
        { userId: user.id },
        authConfig.refresh_secret,
        { expiresIn: authConfig.refresh_secret_expires_in as any }
      )

      const decoded = jwt.decode(refreshToken) as { exp: number }
      const expiresAt = new Date(decoded.exp * 1000)

      await this.refreshTokenRepository.upsert({
        userId: user.id,
        token: refreshToken,
        expiresAt,
      })

      const { password: _, ...userWithoutPassword } = user

      return ok({ user: userWithoutPassword, token, refreshToken })
    } catch (error) {
      return serverError(error as Error)
    }
  }
}

export { LoginUseCase }
