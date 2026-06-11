import { MigrationInterface, QueryRunner, TableColumn } from "typeorm"

export class AddRouteToActivity1781200000000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.addColumn(
      'activities',
      new TableColumn({
        name: 'route',
        type: 'jsonb',
        isNullable: true,
      })
    )
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropColumn('activities', 'route')
  }
}
