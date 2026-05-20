import { inject, injectable } from "tsyringe"
import { IActivityRepository } from "@modules/activity/domain/repositories/activity/i-activity-repository"
import { HttpResponse, ok, serverError } from "@shared/helpers"

@injectable()
class ListActivitiesUseCase {
  constructor(
    @inject('ActivityRepository')
    private activityRepository: IActivityRepository
  ) {}

  async execute(userId: string): Promise<HttpResponse> {
    try {
      const activities = await this.activityRepository.findByUserId(userId)

      return ok(activities)
    } catch (error) {
      return serverError(error as Error)
    }
  }
}

export { ListActivitiesUseCase }
