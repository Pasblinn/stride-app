import { Request, Response } from "express"
import { container } from "tsyringe"
import { CreateActivityUseCase } from "@modules/activity/application/use-cases/create-activity-use-case"
import { ListActivitiesUseCase } from "@modules/activity/application/use-cases/list-activities-use-case"
import { GetActivityUseCase } from "@modules/activity/application/use-cases/get-activity-use-case"
import { UpdateActivityUseCase } from "@modules/activity/application/use-cases/update-activity-use-case"
import { DeleteActivityUseCase } from "@modules/activity/application/use-cases/delete-activity-use-case"

class ActivityController {
  async create(request: Request, response: Response): Promise<Response> {
    const userId = request.userId as string
    const { title, description, type, distance, durationSeconds, date, averagePace, calories } = request.body

    const createActivityUseCase = container.resolve(CreateActivityUseCase)

    const result = await createActivityUseCase.execute({
      userId,
      title,
      description,
      type,
      distance,
      durationSeconds,
      date: new Date(date),
      averagePace,
      calories,
    })

    return response.status(result.statusCode).json(result)
  }

  async list(request: Request, response: Response): Promise<Response> {
    const userId = request.userId as string

    const listActivitiesUseCase = container.resolve(ListActivitiesUseCase)

    const result = await listActivitiesUseCase.execute(userId)

    return response.status(result.statusCode).json(result)
  }

  async get(request: Request, response: Response): Promise<Response> {
    const { id } = request.params
    const userId = request.userId as string

    const getActivityUseCase = container.resolve(GetActivityUseCase)

    const result = await getActivityUseCase.execute(id as string, userId)

    return response.status(result.statusCode).json(result)
  }

  async update(request: Request, response: Response): Promise<Response> {
    const { id } = request.params
    const userId = request.userId as string
    const { title, description, type, distance, durationSeconds, date, averagePace, calories } = request.body

    const updateActivityUseCase = container.resolve(UpdateActivityUseCase)

    const result = await updateActivityUseCase.execute({
      id: id as string,
      title,
      description,
      type,
      distance,
      durationSeconds,
      date: date ? new Date(date) : undefined,
      averagePace,
      calories,
    }, userId)

    return response.status(result.statusCode).json(result)
  }

  async delete(request: Request, response: Response): Promise<Response> {
    const { id } = request.params
    const userId = request.userId as string

    const deleteActivityUseCase = container.resolve(DeleteActivityUseCase)

    const result = await deleteActivityUseCase.execute(id as string, userId)

    return response.status(result.statusCode).json(result)
  }
}

export { ActivityController }
