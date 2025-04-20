//
//  MailService.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 18/4/25.
//

import Vapor

struct MailService: Sendable {
    let mailerURL: String
    let from: String
    let xMailer: String
    let apiTokenGenerator: @Sendable (String) -> String

    func sendActivationEmail(to email: String, withToken token: String, on req: Request) async throws {
        // Cabecera
        let X_API_Token = req.application.securityTokenService.generateActivationToken(datosAdicionales: "")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-API-Token": X_API_Token //apiTokenGenerator(email)
        ]
        // Body
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
        
        // Comunicacion POST HTTP
        let response = try await req.client.post(URI(string: mailerURL), headers: headers) { request in
            try request.content.encode(body)
        }
        
        //req.logger.info("📧 --- INICIO LOG RESPUESTA ---")
        //req.logger.info("📧 Estatus: \(response.status)")
        //req.logger.info("📧 Cabeceras: \(response.headers)")
        //req.logger.info("📧 Descripcion: \(response.description)")
        req.logger.info("✅ Enviado correo de activación a \(email)")
    }
}
