import { inject, injectable } from "tsyringe"
import { IActivityRepository } from "@modules/activity/domain/repositories/activity/i-activity-repository"
import { HttpResponse, noContent, notFound, serverError } from "@shared/helpers"

@injectable()
class DeleteActivityUseCase {
  constructor(
    @inject('ActivityRepository')
    private activityRepository: IActivityRepository
  ) {}

  async execute(id: string, userId: string): Promise<HttpResponse> {
    try {
      const activity = await this.activityRepository.findById(id)

      if (!activity) {
        return notFound('Atividade não encontrada')
      }

      if (activity.userId !== userId) {
        return notFound('Atividade não encontrada')
      }

      await this.activityRepository.delete(id)

      return noContent()
    } catch (error) {
      return serverError(error as Error)
    }
  }
}

export { DeleteActivityUseCase }
