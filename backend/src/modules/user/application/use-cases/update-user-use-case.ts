import { inject, injectable } from "tsyringe"
import bcrypt from "bcryptjs"
import { IUserRepository } from "@modules/user/domain/repositories/user/i-user-repository"
import { IUpdateUserDTO } from "../dto/i-user-dto"
import { HttpResponse, notFound, ok, serverError } from "@shared/helpers"

@injectable()
class UpdateUserUseCase {
  constructor(
    @inject('UserRepository')
    private userRepository: IUserRepository
  ) {}

  async execute({ id, name, email, password, profileImageUrl }: IUpdateUserDTO): Promise<HttpResponse> {
    try {
      const userExists = await this.userRepository.get(id)

      if (!userExists) {
        return notFound('Usuário não encontrado')
      }

      const hashedPassword = password ? await bcrypt.hash(password, 10) : undefined

      const user = await this.userRepository.update(id, {
        name,
        email,
        password: hashedPassword,
        profileImageUrl,
      })

      return ok(user)
    } catch (error) {
      return serverError(error as Error)
    }
  }
}

export { UpdateUserUseCase }
