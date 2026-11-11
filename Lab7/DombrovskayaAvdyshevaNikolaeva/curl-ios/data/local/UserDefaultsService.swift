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
        static let hairPorosity = "Средне-пористые"
        static let hairThickness = "Тонкие"
        static let hairColoring = "Неокрашенные"
    }
    
    enum Options {
        static let porosity = ["Низко-пористые", "Средне-пористые", "Высоко-пористые"]
        static let thickness = ["Тонкие", "Средние", "Толстые"]
        static let coloring = ["Неокрашенные", "Окрашенные", "Осветлённые"]
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
