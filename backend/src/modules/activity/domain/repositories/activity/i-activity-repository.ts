import { IActivityReadRepository } from "./i-activity-read-repository"
import { IActivityWriteRepository } from "./i-activity-write-repository"

export interface IActivityRepository extends IActivityReadRepository, IActivityWriteRepository {}
