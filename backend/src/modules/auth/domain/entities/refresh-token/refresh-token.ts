export interface IRefreshToken {
  id: string
  userId: string
  token: string
  expiresAt: Date
  revokedAt: Date | null
  createdAt: Date
}
