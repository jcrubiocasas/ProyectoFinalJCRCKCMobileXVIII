import SwiftUI

struct AcknowledgementsView: View {
    @State private var randomBackground = "Fondo 1"
    private let message = """
    Gracias a mi compañera en la vida, Marta, quien además de su amor y amistad, me ha regalado mi bien más preciado: nuestra familia.
    """

    var body: some View {
        ZStack {
            Image(randomBackground)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()
                Text("Agradecimientos")
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 4)
                
                Image(systemName: "heart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.pink)
                    .padding(.top)

                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(10)
                    .padding(.horizontal, 32)
                    .foregroundColor(.white)

                Spacer()
            }
            .padding()
        }
        .onAppear {
            randomBackground = "playa\(Int.random(in: 1...6))"
        }
    }
}

#Preview {
    AcknowledgementsView()
}
