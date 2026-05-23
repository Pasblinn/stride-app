import { Router } from "express"
import { AuthMiddleware } from "@app/http/middlewares/auth.middleware"
import { UsersController } from "@modules/user/infra/controllers/user-controller"

const userRoutes = Router()
const usersController = new UsersController()

// Rota pública — cadastro não exige autenticação
userRoutes.post('/', (req, res) => usersController.create(req, res))

// Rotas protegidas
userRoutes.use(AuthMiddleware.authenticateUser())

userRoutes.get('/:id', (req, res) => usersController.get(req, res))
userRoutes.put('/:id', (req, res) => usersController.update(req, res))
userRoutes.delete('/:id', (req, res) => usersController.delete(req, res))

export { userRoutes }
