import { CreateUserUseCase } from "@modules/user/application/use-cases/create-user-use-case"
import { GetUserUseCase } from "@modules/user/application/use-cases/get-user-use-case"
import { UpdateUserUseCase } from "@modules/user/application/use-cases/update-user-use-case"
import { DeleteUserUseCase } from "@modules/user/application/use-cases/delete-user-use-case"
import { Request, Response } from "express"
import { container } from "tsyringe"

class UsersController {
  async create(request: Request, response: Response): Promise<Response> {
    const { name, email, password, profileImageUrl } = request.body

    const createUserUseCase = container.resolve(CreateUserUseCase)

    const result = await createUserUseCase.execute({ name, email, password, profileImageUrl })

    return response.status(result.statusCode).json(result)
  }

  async get(request: Request, response: Response): Promise<Response> {
    const { id } = request.params

    const getUserUseCase = container.resolve(GetUserUseCase)

    const result = await getUserUseCase.execute(id as string)

    return response.status(result.statusCode).json(result)
  }

  async update(request: Request, response: Response): Promise<Response> {
    const { id } = request.params
    const { name, email, password, profileImageUrl } = request.body

    const updateUserUseCase = container.resolve(UpdateUserUseCase)

    const result = await updateUserUseCase.execute({ id: id as string, name, email, password, profileImageUrl })

    return response.status(result.statusCode).json(result)
  }

  async delete(request: Request, response: Response): Promise<Response> {
    const { id } = request.params

    const deleteUserUseCase = container.resolve(DeleteUserUseCase)

    const result = await deleteUserUseCase.execute(id as string)

    return response.status(result.statusCode).json(result)
  }
}

export { UsersController }