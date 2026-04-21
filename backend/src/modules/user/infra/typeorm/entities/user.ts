import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from "typeorm"

const decimalTransformer = {
  to: (value?: number) => value,
  from: (value?: string | null) => (value === null || value === undefined ? value : parseFloat(value)),
}

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string

  @Column({ type: 'varchar', length: 255 })
  name: string

  @Column({ type: 'varchar', length: 255, unique: true })
  email: string

  @Column({ type: 'varchar', length: 255 })
  password: string

  @Column({ name: 'profile_image_url', type: 'text', nullable: true })
  profileImageUrl: string | null

  @Column({
    name: 'total_distance',
    type: 'decimal',
    precision: 10,
    scale: 2,
    default: 0,
    transformer: decimalTransformer,
  })
  totalDistance: number

  @Column({ name: 'total_activities', type: 'integer', default: 0 })
  totalActivities: number

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt: Date
}
