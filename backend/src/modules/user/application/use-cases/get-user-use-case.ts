import { inject, injectable } from "tsyringe"
import { IUserRepository } from "@modules/user/domain/repositories/user/i-user-repository"
import { HttpResponse, notFound, ok, serverError } from "@shared/helpers"

@injectable()
class GetUserUseCase {
  constructor(
    @inject('UserRepository')
    private userRepository: IUserRepository
  ) {}

  async execute(id: string): Promise<HttpResponse> {
    try {
      const user = await this.userRepository.get(id)

      if (!user) {
        return notFound('Usuário não encontrado')
      }

      return ok(user)
    } catch (error) {
      return serverError(error as Error)
    }
  }
}

export { GetUserUseCase }
