import { MigrationInterface, QueryRunner, Table } from "typeorm";

export class CreateUsers1776692992771 implements MigrationInterface {

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.createTable(
            new Table({
                name: 'users',
                columns: [
                    {
                        name: "id",
                        type: "uuid",
                        isPrimary: true,
                        isGenerated: true,
                        generationStrategy: "uuid",
                        default: "gen_random_uuid()"
                    },
                    {
                        name: "name",
                        type: "varchar",
                        length: "255",
                        isNullable: false,
                    },
                    {
                        name: "email",
                        type: "varchar",
                        length: "255",
                        isNullable: false,
                        isUnique: true
                    },
                    {
                        name: "password",
                        type: "varchar",
                        length: "255",
                        isNullable: false,
                    },
                    {
                        name: 'profile_image_url',
                        type: 'text',
                        isNullable: true
                    },
                    {
                        name: 'total_distance',
                        type: 'decimal',
                        precision: 10,
                        scale: 2,
                        default: 0
                    },
                    {
                        name: 'total_activities',
                        type: 'integer',
                        default: 0
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
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.dropTable('users')
    }

}
