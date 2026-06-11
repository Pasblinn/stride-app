import { inject, injectable } from "tsyringe"
import { IActivityRepository } from "@modules/activity/domain/repositories/activity/i-activity-repository"
import { ICreateActivityDTO } from "../dto/i-activity-dto"
import { created, HttpResponse, serverError } from "@shared/helpers"

@injectable()
class CreateActivityUseCase {
  constructor(
    @inject('ActivityRepository')
    private activityRepository: IActivityRepository
  ) {}

  async execute({ userId, title, description, type, distance, durationSeconds, date, averagePace, calories, route }: ICreateActivityDTO): Promise<HttpResponse> {
    try {
      const activity = await this.activityRepository.create({
        userId,
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

      return created(activity)
    } catch (error) {
      return serverError(error as Error)
    }
  }
}

export { CreateActivityUseCase }
