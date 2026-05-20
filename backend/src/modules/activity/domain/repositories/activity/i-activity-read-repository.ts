import { IActivity } from "../../entities/activity/activity"

interface IActivityReadRepository {
  findById(id: string): Promise<IActivity | null>
  findByUserId(userId: string): Promise<IActivity[]>
}

export { IActivityReadRepository }
