import SwiftUI

// MARK: - Enums for Filters
enum EventType: String, CaseIterable, Identifiable {
    case sport = "Sport"
    case flight = "Flight"
    case walk = "Walk"
    case party = "Party"
    case club = "Club"
    case coworking = "Coworking"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .sport: return "figure.run"
        case .flight: return "airplane"
        case .walk: return "figure.walk"
        case .party: return "party.popper.fill"
        case .club: return "music.mic"
        case .coworking: return "laptopcomputer"
        }
    }
}

enum Gender: String, CaseIterable, Identifiable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
    
    var id: String { self.rawValue }
}


// MARK: - Filter Button
struct FilterButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.subheadline)
            Text(title)
                .fontWeight(.medium)
                .font(.subheadline)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            if isSelected {
                Color.purple.opacity(0.2)
            } else {
                Rectangle().fill(.regularMaterial)
            }
        }
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Age Slider View
struct AgeSliderView: View {
    @Binding var minAge: Double
    @Binding var maxAge: Double
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Select Age Range")
                    .font(.headline)
                    .padding(.top)
                
                Text("\(Int(minAge)) - \(Int(maxAge)) years old")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.purple)
                
                VStack {
                    VStack(alignment: .leading) {
                        Text("Minimum Age: \(Int(minAge))")
                        Slider(value: $minAge, in: 0...100, step: 1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Maximum Age: \(Int(maxAge))")
                        Slider(value: $maxAge, in: 0...100, step: 1)
                    }
                }
                .onChange(of: minAge) { _, newValue in
                    if newValue > maxAge {
                        maxAge = newValue
                    }
                }
                .onChange(of: maxAge) { _, newValue in
                    if newValue < minAge {
                        minAge = newValue
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}


// MARK: - Gender Selection View
struct GenderSelectionView: View {
    @Binding var selectedGenders: Set<Gender>
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List(Gender.allCases) { gender in
                Button(action: {
                    toggleSelection(for: gender)
                }) {
                    HStack {
                        Text(gender.rawValue)
                        Spacer()
                        if selectedGenders.contains(gender) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.purple)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Select Gender")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func toggleSelection(for gender: Gender) {
        if selectedGenders.contains(gender) {
            selectedGenders.remove(gender)
        } else {
            selectedGenders.insert(gender)
        }
    }
}
