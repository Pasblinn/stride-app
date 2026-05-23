import { Request, Response } from "express"
import { container } from "tsyringe"
import { LoginUseCase } from "@modules/auth/application/use-cases/login-use-case"
import { RefreshTokenUseCase } from "@modules/auth/application/use-cases/refresh-token-use-case"
import { LogoutUseCase } from "@modules/auth/application/use-cases/logout-use-case"

class AuthController {
  async login(request: Request, response: Response): Promise<Response> {
    const { email, password } = request.body

    const loginUseCase = container.resolve(LoginUseCase)

    const result = await loginUseCase.execute({ email, password })

    return response.status(result.statusCode).json(result)
  }

  async refresh(request: Request, response: Response): Promise<Response> {
    const userId = request.userId as string
    const { refreshToken } = request.body

    const refreshTokenUseCase = container.resolve(RefreshTokenUseCase)

    const result = await refreshTokenUseCase.execute(userId, refreshToken)

    return response.status(result.statusCode).json(result)
  }

  async logout(request: Request, response: Response): Promise<Response> {
    const userId = request.userId as string

    const logoutUseCase = container.resolve(LogoutUseCase)

    const result = await logoutUseCase.execute(userId)

    return response.status(result.statusCode).json(result)
  }
}

export { AuthController }
