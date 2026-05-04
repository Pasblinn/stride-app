export interface ICreateUserDTO {
  name: string
  email: string
  password: string
  profileImageUrl?: string | null
}

export interface IUpdateUserDTO {
  id: string
  name?: string
  email?: string
  password?: string
  profileImageUrl?: string | null
}