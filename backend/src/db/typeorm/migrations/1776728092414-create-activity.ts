import { MigrationInterface, QueryRunner, Table, TableForeignKey } from "typeorm";

export class CreateActivity1776728092414 implements MigrationInterface {

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.createTable(
            new Table({
                name: 'activities',
                columns: [
                    {
                        name: 'id',
                        type: 'uuid',
                        isPrimary: true,
                        isGenerated: true,
                        generationStrategy: 'uuid',
                        default: 'gen_random_uuid()'
                    },
                    {
                        name: 'user_id',
                        type: 'uuid',
                        isNullable: false
                    },
                    {
                        name: 'title',
                        type: 'varchar',
                        length: '255',
                        isNullable: false
                    },
                    {
                        name: 'description',
                        type: 'text',
                        isNullable: true
                    },
                    {
                        name: 'type',
                        type: 'enum',
                        enum: ['running', 'cycling', 'walking', 'hiking', 'swimming'],
                        enumName: 'activity_type_enum',
                        isNullable: false
                    },
                    {
                        name: 'distance',
                        type: 'decimal',
                        precision: 10,
                        scale: 2,
                        isNullable: false
                    },
                    {
                        name: 'duration_seconds',
                        type: 'integer',
                        isNullable: false
                    },
                    {
                        name: 'date',
                        type: 'timestamptz',
                        isNullable: false
                    },
                    {
                        name: 'average_pace',
                        type: 'decimal',
                        precision: 6,
                        scale: 2,
                        isNullable: true
                    },
                    {
                        name: 'calories',
                        type: 'decimal',
                        precision: 8,
                        scale: 2,
                        isNullable: true
                    },
                    {
                        name: 'created_at',
                        type: 'timestamptz',
                        default: 'now()'
                    },
                    {
                        name: 'updated_at',
                        type: 'timestamptz',
                        default: 'now()'
                    }
                ]
            })
        )

        await queryRunner.createForeignKey(
            'activities',
            new TableForeignKey({
                columnNames: ['user_id'],
                referencedColumnNames: ['id'],
                referencedTableName: 'users',
                onDelete: 'CASCADE'
            })
        )
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.dropTable('activities')
        await queryRunner.query('DROP TYPE IF EXISTS "activity_type_enum"')
    }

}
