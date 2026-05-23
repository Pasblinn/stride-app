import { IRefreshTokenReadRepository } from "./i-refresh-token-read-repository"
import { IRefreshTokenWriteRepository } from "./i-refresh-token-write-repository"

export interface IRefreshTokenRepository extends IRefreshTokenReadRepository, IRefreshTokenWriteRepository {}
