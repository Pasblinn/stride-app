import { serverError, unauthorized } from "@shared/helpers"
import authConfig from "config/auth.config"
import { NextFunction, Request, Response } from "express"
import jwt from "jsonwebtoken"

export interface DecodedToken {
  userId: string
}

class AuthMiddleware {
  static authenticateUser() {
    return (request: Request, response: Response, next: NextFunction) => {
      const authHeader = request.headers.authorization

      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return response.status(401).json(unauthorized())
      }

      const token = authHeader.split(' ')[1]

      try {
        const decodedToken = jwt.verify(token, authConfig.secret) as DecodedToken
        request.userId = decodedToken.userId
        next()
      } catch (error) {
        return response.status(401).json(unauthorized())
      }
    }
  }

  static refreshTokenValidation() {
    return (request: Request, response: Response, next: NextFunction) => {
      const { refreshToken } = request.body

      if (!refreshToken) {
        return response.status(401).json(unauthorized())
      }

      try {
        const decodedToken = jwt.verify(refreshToken, authConfig.refresh_secret) as DecodedToken
        request.userId = decodedToken.userId
        next()
      } catch (error) {
        return response.status(401).json(unauthorized())
      }
    }
  }
}

export { AuthMiddleware }