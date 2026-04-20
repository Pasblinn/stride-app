import { DataSource } from 'typeorm'
import { getConfig } from './config'

const appDataSource = new DataSource(getConfig())
appDataSource.initialize().then(() => {
  console.log('Data Source has been initialized!')
  console.log('Registered Entities:')
  console.log('-------------------')
  console.log(appDataSource.entityMetadatas.map((entity) => entity.name))
  console.log('-------------------')
})
export default appDataSource