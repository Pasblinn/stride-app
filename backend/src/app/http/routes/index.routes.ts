import { Router } from "express"
import { userRoutes } from "./user.routes"
import { activityRoutes } from "@app/http/routes/activity.routes"

const router = Router()

router.use('/users', userRoutes)
router.use('/activities', activityRoutes)

export { router }