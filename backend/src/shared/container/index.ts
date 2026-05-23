import { container } from "tsyringe"
import { IUserRepository } from "@modules/user/domain/repositories/user/i-user-repository"
import { UserRepository } from "@modules/user/infra/typeorm/repositories/user-repository"
import { IActivityRepository } from "@modules/activity/domain/repositories/activity/i-activity-repository"
import { ActivityRepository } from "@modules/activity/infra/typeorm/repositories/activity-repository"
import { IRefreshTokenRepository } from "@modules/auth/domain/repositories/refresh-token/i-refresh-token-repository"
import { RefreshTokenRepository } from "@modules/auth/infra/typeorm/repositories/refresh-token-repository"

container.registerSingleton<IUserRepository>('UserRepository', UserRepository)
container.registerSingleton<IActivityRepository>('ActivityRepository', ActivityRepository)
container.registerSingleton<IRefreshTokenRepository>('RefreshTokenRepository', RefreshTokenRepository)