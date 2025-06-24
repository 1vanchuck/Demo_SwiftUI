import SwiftUI

// MARK: - Map Zoom Controls
struct MapZoomControls: View {
    var onZoomIn: () -> Void
    var onZoomOut: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: onZoomIn) {
                Image(systemName: "plus").font(.headline).padding(10)
            }
            Button(action: onZoomOut) {
                Image(systemName: "minus").font(.headline).padding(10)
            }
        }
        .foregroundColor(.primary)
        .background(.regularMaterial)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

// MARK: - Event Tag Button
struct TagButton: View {
    let text: String
    var body: some View {
        Button(action: {}) {
            Text(text)
                .font(.footnote).fontWeight(.semibold)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Color.secondary.opacity(0.15))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Event RSVP Button
struct RSVPButton: View {
    let icon: String
    let text: String
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(text)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.secondary.opacity(0.15))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Profile Info Row
struct InfoRow: View {
    let iconName: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.headline)
                .frame(width: 25, alignment: .center)
                .foregroundColor(.secondary)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    let backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(15)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
