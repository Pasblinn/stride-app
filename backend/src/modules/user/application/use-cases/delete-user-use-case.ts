import { inject, injectable } from "tsyringe"
import { IUserRepository } from "@modules/user/domain/repositories/user/i-user-repository"
import { HttpResponse, noContent, notFound, serverError } from "@shared/helpers"

@injectable()
class DeleteUserUseCase {
  constructor(
    @inject('UserRepository')
    private userRepository: IUserRepository
  ) {}

  async execute(id: string): Promise<HttpResponse> {
    try {
      const userExists = await this.userRepository.get(id)

      if (!userExists) {
        return notFound('Usuário não encontrado')
      }

      await this.userRepository.delete(id)

      return noContent()
    } catch (error) {
      return serverError(error as Error)
    }
  }
}

export { DeleteUserUseCase }
