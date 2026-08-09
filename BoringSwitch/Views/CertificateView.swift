import SwiftUI

/// The shareable "Certificate of Dedication" — rendered to an image with
/// ImageRenderer and shared via ShareLink.
struct CertificateView: View {
    let clicks: Int
    let since: Date?

    private var sinceText: String {
        guard let since else { return "recently" }
        return since.formatted(date: .long, time: .omitted)
    }

    var body: some View {
        VStack(spacing: 22) {
            Text("CERTIFICATE OF DEDICATION")
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .kerning(3)

            Rectangle()
                .frame(width: 180, height: 1)
                .opacity(0.4)

            Text("This certifies that the bearer has flipped\na light switch")
                .font(.system(size: 15, design: .serif))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("\(clicks)")
                .font(.system(size: 64, weight: .light, design: .serif))
                .monospacedDigit()

            Text(clicks == 1 ? "time" : "times")
                .font(.system(size: 15, design: .serif))

            Text("Nothing was accomplished.")
                .font(.system(size: 13, design: .serif))
                .italic()
                .opacity(0.7)

            Rectangle()
                .frame(width: 180, height: 1)
                .opacity(0.4)

            VStack(spacing: 4) {
                Text("Clicking faithfully since \(sinceText)")
                Text("Boring Switch · Official Record")
            }
            .font(.system(size: 11, design: .serif))
            .opacity(0.6)

            // Seal
            ZStack {
                Circle()
                    .strokeBorder(Color(red: 0.55, green: 0.35, blue: 0.2), lineWidth: 2)
                    .frame(width: 56, height: 56)
                Circle()
                    .strokeBorder(Color(red: 0.55, green: 0.35, blue: 0.2), lineWidth: 1)
                    .frame(width: 46, height: 46)
                Image(systemName: "lightswitch.on")
                    .font(.system(size: 20))
                    .foregroundStyle(Color(red: 0.55, green: 0.35, blue: 0.2))
            }
        }
        .foregroundStyle(Color(red: 0.2, green: 0.17, blue: 0.13))
        .padding(44)
        .frame(width: 480)
        .background(Color(red: 0.96, green: 0.93, blue: 0.85))
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .strokeBorder(Color(red: 0.55, green: 0.45, blue: 0.3), lineWidth: 3)
                .padding(10)
        )
    }

    /// Renders the certificate to a shareable image at 3x scale.
    @MainActor
    static func renderImage(clicks: Int, since: Date?) -> Image {
        let renderer = ImageRenderer(content: CertificateView(clicks: clicks, since: since))
        renderer.scale = 3
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "lightswitch.on")
    }
}
