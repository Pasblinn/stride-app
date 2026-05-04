import { CreateUserUseCase } from "@modules/user/application/use-cases/create-user-use-case";
import { HttpResponse } from "@shared/helpers";
import { Request, Response } from "express";
import { container } from "tsyringe";


class UsersController {
  async create(request: Request, response: Response): Promise<Response>{
    const { name, email, password, profileImageUrl } = request.body

    const createUserUseCase = container.resolve(CreateUserUseCase)

    const result = await createUserUseCase.execute({ name, email, password, profileImageUrl })

    return response.status(result.statusCode).json(result)
  }

}

export { UsersController }