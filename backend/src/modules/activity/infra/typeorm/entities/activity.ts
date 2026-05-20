import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from "typeorm"
import { ActivityType } from "@modules/activity/domain/entities/activity/activity"

const decimalTransformer = {
  to: (value?: number | null) => value,
  from: (value?: string | null) => (value === null || value === undefined ? value : parseFloat(value)),
}

@Entity('activities')
export class Activity {
  @PrimaryGeneratedColumn('uuid')
  id: string

  @Column({ name: 'user_id', type: 'uuid' })
  userId: string

  @Column({ type: 'varchar', length: 255 })
  title: string

  @Column({ type: 'text', nullable: true })
  description: string | null

  @Column({
    type: 'enum',
    enum: ['running', 'cycling', 'walking', 'hiking', 'swimming'],
    enumName: 'activity_type_enum',
  })
  type: ActivityType

  @Column({
    type: 'decimal',
    precision: 10,
    scale: 2,
    transformer: decimalTransformer,
  })
  distance: number

  @Column({ name: 'duration_seconds', type: 'integer' })
  durationSeconds: number

  @Column({ type: 'timestamptz' })
  date: Date

  @Column({
    name: 'average_pace',
    type: 'decimal',
    precision: 6,
    scale: 2,
    nullable: true,
    transformer: decimalTransformer,
  })
  averagePace: number | null

  @Column({
    type: 'decimal',
    precision: 8,
    scale: 2,
    nullable: true,
    transformer: decimalTransformer,
  })
  calories: number | null

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt: Date
}
