
import { serverError, unauthorized } from "@shared/helpers"
import authConfig from "config/auth.config"
import { NextFunction, Request, Response } from "express"
import jwt from "jsonwebtoken"


export interface DecodedToken {
  userId: string
}

class AuthMiddleware {
  static authenticateUser() {
    return(request: Request, response: Response, next: NextFunction) => {
      const token = request.cookies.token ?? null
      if(!token || token === 'undefined') { 
        return response.status(401).json(unauthorized())
      }

      try {
        const decodedToken = jwt.verify(token, authConfig.secret) as DecodedToken
        (request as any).userId = decodedToken.userId
        next()

      } catch(error) {
        console.log('Error authenticate user - auth middleware ', error)
        return response.status(401).json(serverError(error as Error))
      }
    }
  }

  static refreshTokenValidation() {
    return(request: Request, response: Response, next: NextFunction) => {
      const refreshToken = request.cookies.refreshToken
      if(!refreshToken) {
        return response.status(401).json(unauthorized())
      }

      try {
        const decodedToken = jwt.verify(refreshToken, authConfig.refresh_secret) as { userId: number }
        (request as any).userId = decodedToken.userId
        next()

      } catch(error) {
        console.log('Error refresh token - auth middleware ', error)
        return response.status(401).json(serverError(error as Error))
      }
    }
  }
}

export { AuthMiddleware }