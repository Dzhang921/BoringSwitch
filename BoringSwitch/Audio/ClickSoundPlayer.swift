import AVFoundation
import UIKit

/// Plays the pre-rendered click sound for the current style/material and
/// fires a matching haptic. Sounds live in Resources/Sounds as
/// "<style>_<material>_<on|off>.wav".
final class ClickSoundPlayer {
    static let shared = ClickSoundPlayer()

    private var dataCache: [String: Data] = [:]
    private var activePlayers: [AVAudioPlayer] = []

    private let rigidHaptic = UIImpactFeedbackGenerator(style: .rigid)
    private let softHaptic = UIImpactFeedbackGenerator(style: .soft)
    private let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    private let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)

    private init() {
        // Ambient: respects the silent switch and mixes with the user's music.
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func play(style: SwitchStyle, material: SwitchMaterial, isOn: Bool) {
        haptic(for: style).impactOccurred()

        let name = "\(style.rawValue)_\(material.rawValue)_\(isOn ? "on" : "off")"
        guard let data = soundData(named: name) else { return }

        activePlayers.removeAll { !$0.isPlaying }
        if let player = try? AVAudioPlayer(data: data) {
            player.volume = 0.9
            player.play()
            activePlayers.append(player)
        }
    }

    private func soundData(named name: String) -> Data? {
        if let cached = dataCache[name] { return cached }
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav"),
              let data = try? Data(contentsOf: url) else { return nil }
        dataCache[name] = data
        return data
    }

    private func haptic(for style: SwitchStyle) -> UIImpactFeedbackGenerator {
        switch style {
        case .toggle: return rigidHaptic
        case .rocker: return softHaptic
        case .push: return mediumHaptic
        case .knife: return heavyHaptic
        case .chain: return lightHaptic
        }
    }
}
