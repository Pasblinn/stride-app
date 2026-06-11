import { inject, injectable } from "tsyringe"
import { IActivityRepository } from "@modules/activity/domain/repositories/activity/i-activity-repository"
import { IUpdateActivityDTO } from "../dto/i-activity-dto"
import { HttpResponse, notFound, ok, serverError } from "@shared/helpers"

@injectable()
class UpdateActivityUseCase {
  constructor(
    @inject('ActivityRepository')
    private activityRepository: IActivityRepository
  ) {}

  async execute({ id, title, description, type, distance, durationSeconds, date, averagePace, calories, route }: IUpdateActivityDTO, userId: string): Promise<HttpResponse> {
    try {
      const activity = await this.activityRepository.findById(id)

      if (!activity) {
        return notFound('Atividade não encontrada')
      }

      if (activity.userId !== userId) {
        return notFound('Atividade não encontrada')
      }

      const updated = await this.activityRepository.update(id, {
        title,
        description,
        type,
        distance,
        durationSeconds,
        date,
        averagePace,
        calories,
        route,
      })

      return ok(updated)
    } catch (error) {
      return serverError(error as Error)
    }
  }
}

export { UpdateActivityUseCase }
