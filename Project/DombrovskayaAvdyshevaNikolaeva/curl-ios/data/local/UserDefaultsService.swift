import Foundation
import Combine

final class UserDefaultsService: ObservableObject {
    static let shared = UserDefaultsService()
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let name = "user_profile_name"
        static let email = "user_profile_email"
        static let avatar = "user_profile_avatar"
        static let hairPorosity = "user_profile_hair_porosity"
        static let hairThickness = "user_profile_hair_thickness"
        static let hairColoring = "user_profile_hair_coloring"
    }
    
    enum Defaults {
        static let name = "Вика"
        static let email = "vik@mail.ru"
        static let avatar = "person.crop.circle"
        static let hairPorosity = "Не определено"
        static let hairThickness = "Не определено"
        static let hairColoring = "Не определено"
    }
    
    enum Options {
        static let porosity = [PorosityOptions.low, PorosityOptions.medium, PorosityOptions.high]
        static let thickness = [ThicknessOptions.thick, ThicknessOptions.thin, ThicknessOptions.medium]
        static let coloring = [ColoringOptions.colored, ColoringOptions.notColored]
    }
    
    enum PorosityOptions {
        static let low = "Низкопористые"
        static let medium = "Среднепористые"
        static let high = "Высокопористые"
    }
    
    enum PorosityDbOptions {
        static let low = "LOW"
        static let medium = "MEDIUM"
        static let high = "HIGH"
    }
    
    enum ThicknessDbOptions {
        static let thin = "THIN"
        static let medium = "MEDIUM"
        static let thick = "THICK"
    }
    
    enum ThicknessOptions {
        static let thin = "Тонкие"
        static let medium = "Средние"
        static let thick = "Толстые"
    }
    
    enum ColoringOptions {
        static let notColored = "Неокрашенные"
        static let colored = "Окрашенные"
    }
    
    enum Avatars {
        static let person1 = "person.crop.circle"
        static let person2 = "person.crop.circle.fill"
        static let hare = "hare.fill"
        static let cat = "cat.fill"
        static let ant = "ant.fill"
        static let ladybug = "ladybug.fill"
    }
    
    static let avatarOptions: [String] = [
            Avatars.person1,
            Avatars.person2,
            Avatars.hare,
            Avatars.cat,
            Avatars.ant,
            Avatars.ladybug
        ]
    
    var name: String {
        get { defaults.string(forKey: Keys.name) ?? Defaults.name }
        set {
            objectWillChange.send()
            defaults.set(newValue, forKey: Keys.name)
        }
    }
    
    var email: String {
        get { defaults.string(forKey: Keys.email) ?? Defaults.email }
        set {
            objectWillChange.send()
            defaults.set(newValue, forKey: Keys.email)
        }
    }
    
    var avatar: String {
        get { defaults.string(forKey: Keys.avatar) ?? Defaults.avatar }
        set {
            objectWillChange.send()
            defaults.set(newValue, forKey: Keys.avatar)
        }
    }
    
    var hairPorosity: String {
        get { defaults.string(forKey: Keys.hairPorosity) ?? Defaults.hairPorosity }
        set {
            objectWillChange.send()
            defaults.set(newValue, forKey: Keys.hairPorosity)
        }
    }
    
    var hairThickness: String {
        get { defaults.string(forKey: Keys.hairThickness) ?? Defaults.hairThickness }
        set {
            objectWillChange.send()
            defaults.set(newValue, forKey: Keys.hairThickness)
        }
    }
    
    var hairColoring: String {
        get { defaults.string(forKey: Keys.hairColoring) ?? Defaults.hairColoring }
        set {
            objectWillChange.send()
            defaults.set(newValue, forKey: Keys.hairColoring)
        }
    }
    
    func porosityFromDbCode(dbCode: String?) -> String {
        return switch dbCode {
        case PorosityDbOptions.high: PorosityOptions.high
        case PorosityDbOptions.medium: PorosityOptions.medium
        case PorosityDbOptions.low: PorosityOptions.low
        default: "Не определено"
        }
    }

    func thicknessFromDbCode(dbCode: String?) -> String {
        return switch dbCode {
        case ThicknessDbOptions.thin: ThicknessOptions.thin
        case ThicknessDbOptions.thick: ThicknessOptions.thin
        case ThicknessDbOptions.medium: ThicknessOptions.medium
        default: "Не определено"
        }
    }

    func coloredFromDbCode(dbCode: Bool?) -> String {
        return switch dbCode {
        case true: ColoringOptions.colored
        case false: ColoringOptions.notColored
        default: "Не определено"
        }
    }
    
    func reset() {
        objectWillChange.send()
        defaults.removeObject(forKey: Keys.name)
        defaults.removeObject(forKey: Keys.email)
        defaults.removeObject(forKey: Keys.avatar)
        defaults.removeObject(forKey: Keys.hairPorosity)
        defaults.removeObject(forKey: Keys.hairThickness)
        defaults.removeObject(forKey: Keys.hairColoring)
    }
}
