import { badRequest, serverError } from "@shared/helpers"
import { NextFunction, Request, Response } from "express"
import { ZodError, ZodType } from "zod"

class ValidationMiddleware {
    static validateBody(schema: ZodType) {
        return (request: Request, response: Response, next: NextFunction) => {
            try {
                schema.parse(request.body)
                next()
            } catch (error) {
                if (error instanceof ZodError) {
                    const formattedErrors: Record<string, string[]> = {}

                    error.issues.forEach((err) => {
                        const field = err.path.join(".")
                        
                        if (!formattedErrors[field]) {
                            formattedErrors[field] = []
                        }
                        formattedErrors[field].push(err.message)
                    })

                    return badRequest()
                }

                console.error('Error validation middleware', error)
                return serverError(error as Error)
            }
        }
    }
}

export { ValidationMiddleware }