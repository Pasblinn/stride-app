import { Router } from "express"
import { authRoutes } from "@modules/auth/infra/routes/auth.routes"
import { userRoutes } from "./user.routes"
import { activityRoutes } from "@app/http/routes/activity.routes"

const router = Router()

router.use('/auth', authRoutes)
router.use('/users', userRoutes)
router.use('/activities', activityRoutes)

export { router }