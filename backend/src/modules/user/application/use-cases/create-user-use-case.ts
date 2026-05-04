import { inject, injectable } from "tsyringe"
import bcrypt from "bcryptjs"
import { IUserRepository } from "@modules/user/domain/repositories/user/i-user-repository"
import { IUser } from "@modules/user/domain/entities/user/user"
import { ICreateUserDTO } from "../dto/i-user-dto"
import { conflictError, created, HttpResponse, serverError } from "@shared/helpers"

@injectable()
class CreateUserUseCase {
  constructor(
    @inject('UserRepository')
    private userRepository: IUserRepository
  ) {}

  async execute({ name, email, password, profileImageUrl }: ICreateUserDTO): Promise<HttpResponse> {
    try {

      const userExists = await this.userRepository.findByEmail(email)

      if(userExists) {
        return conflictError('Usuário já cadastrado')
      }

      const hashedPassword = await bcrypt.hash(password, 10)

      const user = await this.userRepository.create({
        name,
        email,
        password: hashedPassword,
        profileImageUrl,
      })

      return created(user)

    } catch(error) {
      return serverError(error as Error)
    }
  }
}

export { CreateUserUseCase }