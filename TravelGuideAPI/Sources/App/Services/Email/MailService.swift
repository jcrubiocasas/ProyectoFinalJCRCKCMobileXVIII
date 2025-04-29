import Vapor

struct MailService: Sendable {
    let mailerURL: String
    let from: String
    let xMailer: String
    let apiTokenGenerator: @Sendable (String) -> String

    func sendActivationEmail(to email: String, withToken token: String, on req: Request) async throws {
        let X_API_Token = req.application.securityTokenService.generateActivationToken(datosAdicionales: "")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-API-Token": X_API_Token
        ]
        
        let activationLink = "http://dev.equinsaparking.com:10605/auth/activate?token=\(token)"
        
        let body: [String: String] = [
            "from": "GPTravel<jcrubio@equinsa.es>",
            "subject": "Activa tu cuenta en GPTravel ✨",
            "to": "\(email)",
            "body": """
                ¡Hola!

                Gracias por registrarte en GPTravel. Para activar tu cuenta, haz clic en el siguiente enlace 🔗:

                \(activationLink)

                Si no reconoces este correo, ignóralo.
            """,
            "x-mailer": xMailer
        ]
        
        let _ = try await req.client.post(URI(string: mailerURL), headers: headers) { request in
            try request.content.encode(body)
        }
        
        req.logger.info("✅ Enviado correo de activación a \(email)")
    }

    func sendEmergencyEmail(to email: String, subject: String, body: String, on req: Request) async throws {
        let X_API_Token = req.application.securityTokenService.generateActivationToken(datosAdicionales: "")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-API-Token": X_API_Token
        ]
        
        let requestBody: [String: String] = [
            "from": "GPTravel Emergencias<jcrubio@equinsa.es>",
            "subject": subject,
            "to": "\(email)",
            "body": body,
            "x-mailer": xMailer
        ]
        
        let _ = try await req.client.post(URI(string: mailerURL), headers: headers) { request in
            try request.content.encode(requestBody)
        }
        
        req.logger.info("✅ Enviado correo de emergencia a \(email)")
    }
}
