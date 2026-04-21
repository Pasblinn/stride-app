import { IUserReadRepository } from "./i-user-read-repository";
import { IUserWriteRepository } from "./i-user-write-repository";


export interface IUserRepository extends IUserReadRepository, IUserWriteRepository {}