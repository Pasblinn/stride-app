import { Router } from "express"
import { AuthMiddleware } from "@app/http/middlewares/auth.middleware"
import { ActivityController } from "../../../modules/activity/infra/controllers/activity-controller"

const activityRoutes = Router()
const activityController = new ActivityController()

activityRoutes.use(AuthMiddleware.authenticateUser())

activityRoutes.get('/', (req, res) => activityController.list(req, res))
activityRoutes.get('/:id', (req, res) => activityController.get(req, res))
activityRoutes.post('/', (req, res) => activityController.create(req, res))
activityRoutes.put('/:id', (req, res) => activityController.update(req, res))
activityRoutes.delete('/:id', (req, res) => activityController.delete(req, res))

export { activityRoutes }
