import { IUserRepository } from "@modules/user/domain/repositories/user/i-user-repository"
import { UserRepository } from "@modules/user/infra/typeorm/repositories/user-repository"
import { container } from "tsyringe"

container.registerSingleton<IUserRepository>('UserRepository', UserRepository)