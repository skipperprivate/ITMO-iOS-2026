//
//  IngredientCategory.swift
//  MenuPlanner
//
//  Created by FergeS on 28/10/2026.
//
import Foundation

enum IngredientCategory: String, Codable, CaseIterable {
    // Овощи, фрукты и зелень
    case vegetables
    case fruits
    case berries
    case herbs
    case mushrooms

    // Молочные продукты и яйца
    case milkAndCream
    case fermentedDairy
    case cheese
    case butter
    case eggs

    // Мясо, рыба и морепродукты
    case meat
    case poultry
    case fish
    case seafood
    case sausagesAndDeliMeats

    // Хлеб, крупы и продукты для выпечки
    case bread
    case bakery
    case grainsAndCereals
    case pasta
    case legumes
    case flourAndStarch
    case bakingIngredients

    // Орехи, масла и добавки
    case nuts
    case seeds
    case driedFruits
    case vegetableOils
    case saucesAndDressings
    case vinegar
    case spicesAndSeasonings
    case sugarAndSweeteners
    case honeyAndPreserves

    // Консервы и замороженные продукты
    case cannedVegetables
    case cannedFish
    case cannedMeat
    case frozenVegetables
    case frozenFruitsAndBerries
    case frozenMeals
    case iceCream

    // Сладости и перекусы
    case sweetsAndChocolate
    case snacks

    // Напитки
    case water
    case juices
    case softDrinks
    case tea
    case coffee
    case cocoa
    case plantBasedDrinks

    // Другие продукты
    case tofuAndMeatAlternatives
    case babyFood
    case other

    var title: String {
        switch self {
        case .vegetables: "Овощи"
        case .fruits: "Фрукты"
        case .berries: "Ягоды"
        case .herbs: "Зелень"
        case .mushrooms: "Грибы"
        case .milkAndCream: "Молоко и сливки"
        case .fermentedDairy: "Кисломолочные продукты"
        case .cheese: "Сыры"
        case .butter: "Сливочное масло"
        case .eggs: "Яйца"
        case .meat: "Мясо"
        case .poultry: "Птица"
        case .fish: "Рыба"
        case .seafood: "Морепродукты"
        case .sausagesAndDeliMeats: "Колбасы и мясные деликатесы"
        case .bread: "Хлеб и хлебцы"
        case .bakery: "Булочки и готовая выпечка"
        case .grainsAndCereals: "Крупы и хлопья"
        case .pasta: "Макароны и лапша"
        case .legumes: "Бобовые"
        case .flourAndStarch: "Мука и крахмал"
        case .bakingIngredients: "Ингредиенты для выпечки"
        case .nuts: "Орехи"
        case .seeds: "Семечки и семена"
        case .driedFruits: "Сухофрукты"
        case .vegetableOils: "Растительные масла"
        case .saucesAndDressings: "Соусы и заправки"
        case .vinegar: "Уксус"
        case .spicesAndSeasonings: "Соль, специи и приправы"
        case .sugarAndSweeteners: "Сахар и подсластители"
        case .honeyAndPreserves: "Мёд, варенье и сиропы"
        case .cannedVegetables: "Овощные консервы"
        case .cannedFish: "Рыбные консервы"
        case .cannedMeat: "Мясные консервы"
        case .frozenVegetables: "Замороженные овощи и смеси"
        case .frozenFruitsAndBerries: "Замороженные фрукты и ягоды"
        case .frozenMeals: "Замороженные полуфабрикаты"
        case .iceCream: "Мороженое"
        case .sweetsAndChocolate: "Сладости и шоколад"
        case .snacks: "Снеки и закуски"
        case .water: "Вода"
        case .juices: "Соки и нектары"
        case .softDrinks: "Газированные и безалкогольные напитки"
        case .tea: "Чай"
        case .coffee: "Кофе"
        case .cocoa: "Какао"
        case .plantBasedDrinks: "Растительные напитки"
        case .tofuAndMeatAlternatives: "Тофу и растительные заменители мяса"
        case .babyFood: "Детское питание"
        case .other: "Другое"
        }
    }
}
