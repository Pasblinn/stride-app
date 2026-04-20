import { DataSourceOptions } from "typeorm"

export const getConfig = () => {
  return {
    type: "postgres",
    host: "localhost",
    port: Number(process.env.DB_PORT),
    username: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    migrations: ["src/db/typeorm/migrations/**/*.ts"],
    entities: ["src/modules/**/entities/*.ts"],
    invalidWhereValuesBehavior: {
      null: 'sql-null',
      undefined: 'throw'
    }
  } as DataSourceOptions
}