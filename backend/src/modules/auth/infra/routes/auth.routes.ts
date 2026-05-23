import { Router } from "express"
import { AuthMiddleware } from "@app/http/middlewares/auth.middleware"
import { AuthController } from "../controllers/auth-controller"

const authRoutes = Router()
const authController = new AuthController()

authRoutes.post('/login', (req, res) => authController.login(req, res))
authRoutes.post('/refresh', AuthMiddleware.refreshTokenValidation(), (req, res) => authController.refresh(req, res))
authRoutes.post('/logout', AuthMiddleware.authenticateUser(), (req, res) => authController.logout(req, res))

export { authRoutes }
