import express from 'express'
import 'reflect-metadata'
import 'dotenv/config'
import cors from 'cors'
import { router } from './http/routes/index.routes'
import '@shared/container'
import cookieParser from 'cookie-parser'

const app = express()

app.use(cookieParser())

const options: cors.CorsOptions = {
  origin: "http://localhost:4200", 
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
  credentials: true,
}

app.use(cors(options))

// Aplica json parser apenas quando NÃO for multipart/form-data
app.use((req, res, next) => {
  const contentType = req.headers['content-type'] || ''
  if (contentType.includes('multipart/form-data')) {
    return next()
  }
  express.json({ limit: '5mb' })(req, res, next)
})

app.use(router)

export { app }