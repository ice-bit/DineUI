//
//  MockDataManager.swift
//  Dine
//
//  Created by doss-zstch1212 on 16/07/24.
//

import UIKit

struct MockDataManager {
    let mockMenuCategories: [MenuCategory] = [
        MenuCategory(id: UUID(uuidString: "B732B319-A50C-4FB8-86BD-3E64C2A6AF74")!, categoryName: "Appetizer"),
        MenuCategory(id: UUID(uuidString: "E31D93A0-A206-4B14-B8E6-B3C8D42ED254")!, categoryName: "Main Course"),
        MenuCategory(id: UUID(uuidString: "B451D401-3FEB-4C92-A49C-A1585CE76F9F")!, categoryName: "Dessert"),
        MenuCategory(id: UUID(uuidString: "DFDA0639-48A7-4A51-AD5C-A319548636F4")!, categoryName: "Beverage")
    ]
    
    let mockRestaurantTables = [
        RestaurantTable(tableId: UUID(uuidString: "AE8F49F0-1DB1-406C-A7B7-D015772BA607")!, tableStatus: .free, maxCapacity: 4, locationIdentifier: 1),
        RestaurantTable(tableId: UUID(uuidString: "CFB08AD0-3D2F-462B-9847-064668FB171A")!, tableStatus: .free, maxCapacity: 6, locationIdentifier: 2),
        RestaurantTable(tableId: UUID(uuidString: "CE423B1C-2400-4CF3-9BE5-6312061F3073")!, tableStatus: .free, maxCapacity: 2, locationIdentifier: 3),
        RestaurantTable(tableId: UUID(uuidString: "408B99E6-07A5-4D03-B622-13581416FA07")!, tableStatus: .free, maxCapacity: 8, locationIdentifier: 4),
        RestaurantTable(tableId: UUID(uuidString: "50D7CD39-2E23-477E-BB46-70DA262A4EF3")!, tableStatus: .free, maxCapacity: 5, locationIdentifier: 5)
    ]
    
    lazy var mockMenuItems: [MenuItem] = {
        return [
            MenuItem(itemId: UUID(uuidString: "ABAFD14A-A845-40EA-9648-D502B4DBA500")!, name: "Margherita Pizza", price: 9.99, category: mockMenuCategories[1], description: "Classic pizza with tomatoes, mozzarella cheese, fresh basil, salt, and extra-virgin olive oil.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "1C7A74A8-86D6-477A-A664-6C2EEE13B233")!, name: "Caesar Salad", price: 5.99, category: mockMenuCategories[0], description: "Crisp romaine lettuce with Caesar dressing, croutons, and grated Parmesan cheese.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "3DA0EB94-018C-4F65-A992-1A41716812F2")!, name: "Chocolate Cake", price: 4.99, category: mockMenuCategories[2], description: "Rich and moist chocolate cake with a creamy chocolate frosting.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "1BCF6B5B-689E-4000-80EB-182CDE4E1956")!, name: "Lemonade", price: 2.99, category: mockMenuCategories[3], description: "Refreshing lemonade made with freshly squeezed lemons, water, and sugar.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "709E3589-C199-47F7-9277-D42719C7008A")!, name: "Spaghetti Carbonara", price: 12.99, category: mockMenuCategories[1], description: "Spaghetti pasta with a creamy sauce made from eggs, Parmesan cheese, pancetta, and black pepper.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "9801B0F8-427F-4FAA-AA14-6276F3A39022")!, name: "French Fries", price: 3.49, category: mockMenuCategories[0], description: "Crispy and golden French fries served with a side of ketchup.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "BF9C4EB7-60D8-4F1A-A70F-27F02217B966")!, name: "Chicken Wings", price: 7.99, category: mockMenuCategories[0], description: "Spicy buffalo wings served with blue cheese dipping sauce.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "3863401E-A89E-40A5-A125-64A3C9C73721")!, name: "Garden Salad", price: 4.99, category: mockMenuCategories[3], description: "Fresh mixed greens with cucumbers, tomatoes, and a light vinaigrette.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "7F98A61C-3113-4714-BD3E-27D6083C6C6C")!, name: "Tomato Soup", price: 3.99, category: mockMenuCategories[3], description: "Creamy tomato soup served with a side of croutons.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "38FDC572-C8B0-4DDC-8B8D-4D1D06E66D7C")!, name: "Beef Burger", price: 10.99, category: mockMenuCategories[1], description: "Juicy beef burger with lettuce, tomato, onion, and pickles on a toasted bun.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "345F93BD-6DCC-4ABB-92D4-FB71C8B56558")!, name: "Grilled Chicken Sandwich", price: 8.99, category: mockMenuCategories[1], description: "Grilled chicken breast sandwich with lettuce, tomato, and mayo.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "E2715EF9-AEED-4FF8-B30D-DDD418714EDF")!, name: "Mango Smoothie", price: 3.49, category: mockMenuCategories[3], description: "Fresh mango smoothie made with ripe mangoes, yogurt, and a touch of honey.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "884C97E2-6548-4E95-AAA5-EA250E4CD2F2")!, name: "Cheesecake", price: 5.49, category: mockMenuCategories[2], description: "Creamy cheesecake with a graham cracker crust and a strawberry topping.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "BC728CC5-DAC5-4535-8EB1-610B5EBFE4F8")!, name: "Stuffed Mushrooms", price: 6.99, category: mockMenuCategories[0], description: "Mushrooms stuffed with a blend of cheeses, herbs, and breadcrumbs.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "EF1A52C1-6FC9-4700-B1CF-63E8469C3874")!, name: "Pasta Primavera", price: 11.99, category: mockMenuCategories[1], description: "Pasta with fresh vegetables and a light garlic and olive oil sauce.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "51A2B7F0-61DF-4A18-8B4B-46EBEB13E7F9")!, name: "Garlic Bread", price: 2.99, category: mockMenuCategories[0], description: "Toasted garlic bread with a side of marinara sauce.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "AF91592C-8B04-4ED5-BB17-F5AA5454819E")!, name: "BBQ Ribs", price: 14.99, category: mockMenuCategories[1], description: "Tender BBQ ribs served with coleslaw and fries.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "6F9BCEBC-D5AB-425A-B3FA-29772C4465C9")!, name: "Greek Salad", price: 6.49, category: mockMenuCategories[2], description: "Salad with feta cheese, olives, cucumbers, tomatoes, and red onions.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "B5724CA4-D105-478B-B0FC-1E4D581A8AE2")!, name: "Minestrone Soup", price: 4.49, category: mockMenuCategories[2], description: "Hearty vegetable soup with pasta and beans.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "C86D3E3B-9A6B-41F4-BE22-E205E04D3E0C")!, name: "Tiramisu", price: 5.99, category: mockMenuCategories[2], description: "Classic Italian dessert with layers of coffee-soaked ladyfingers and mascarpone cheese.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "AB04537C-0790-4F83-A0FC-9E4ED021CD27")!, name: "Iced Coffee", price: 2.49, category: mockMenuCategories[3], description: "Chilled coffee served over ice with a splash of milk.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "A12A4995-1810-42EB-BFDC-40D5DA36E5E4")!, name: "Buffalo Chicken Wrap", price: 7.49, category: mockMenuCategories[1], description: "Spicy buffalo chicken wrap with lettuce, tomato, and ranch dressing.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "CE77E0BD-2414-4ACD-8F37-D682E0664A78")!, name: "Onion Rings", price: 3.99, category: mockMenuCategories[0], description: "Crispy onion rings served with a side of dipping sauce.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "A854B01A-B01D-44EC-9B9D-9E94BA842734")!, name: "Veggie Pizza", price: 8.99, category: mockMenuCategories[1], description: "Pizza topped with fresh vegetables and mozzarella cheese.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "44CEEA60-16E9-49F8-BECB-61000359DE02")!, name: "Shrimp Cocktail", price: 9.49, category: mockMenuCategories[0], description: "Chilled shrimp served with cocktail sauce.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "B8E2CEE4-BCCF-4D2B-90FD-9FFF6A0F419D")!, name: "Beef Tacos", price: 7.99, category: mockMenuCategories[1], description: "Three beef tacos with lettuce, cheese, and salsa.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "AE4CE28C-644E-49B1-BA0B-048088EA0D66")!, name: "Apple Pie", price: 4.49, category: mockMenuCategories[2], description: "Classic apple pie with a flaky crust and a hint of cinnamon.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "1725CF1C-0ACC-408E-926A-E71E56AFC3B7")!, name: "Hot Chocolate", price: 2.49, category: mockMenuCategories[3], description: "Rich and creamy hot chocolate topped with whipped cream.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "ACE9799B-46F2-4DB6-91CB-B0895AD10EAE")!, name: "Clam Chowder", price: 4.99, category: mockMenuCategories[1], description: "Creamy clam chowder with potatoes and clams.", image: UIImage(named: "burger")!),
            MenuItem(itemId: UUID(uuidString: "8AEA471D-3B81-4BFA-8806-7B7E14D0694E")!, name: "Fried Calamari", price: 8.99, category: mockMenuCategories[0], description: "Crispy fried calamari served with marinara sauce.", image: UIImage(named: "burger")!)
            ]
    }()
    
    mutating func generateData() {
        generateMockMenuCategories()
        generateMockTables()
        generateMockMenuItems()
    }
    
    mutating func deleteGeneratedData() {
        deleteMockMenuCategories()
        deleteMockTables()
        deleteMockMenuItems()
    }
    
    func generateMockMenuCategories() {
        do {
            let menuCategoryService = try CategoryServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            for cat in mockMenuCategories {
                try menuCategoryService.add(cat)
            }
        } catch {
            print("🔨 \(#fileID):\(#line): Failed to append mock Category data: \(error)")
        }
    }
    
    func deleteMockMenuCategories() {
        do {
            let menuCategoryService = try CategoryServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            for cat in mockMenuCategories {
                try menuCategoryService.delete(cat)
            }
        } catch {
            print("🔨 \(#fileID):\(#line): Failed to delete mock Category data: \(error)")
        }
    }
    
    private func generateMockTables() {
        do {
            let tableService = try TableServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            for table in mockRestaurantTables {
                try tableService.add(table)
            }
        } catch {
            print("🔨 \(#fileID):\(#line): Failed to append mock table data: \(error)")
        }
    }
    
    private func deleteMockTables() {
        do {
            let tableService = try TableServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            for table in mockRestaurantTables {
                try tableService.delete(table)
            }
        } catch {
            print("🔨 \(#fileID):\(#line): Failed to delete mock table data: \(error)")
        }
    }
    
    private mutating func generateMockMenuItems() {
        do {
            let menuService = try MenuServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            for item in mockMenuItems {
                try menuService.add(item)
            }
        } catch {
            print("🔨 \(#fileID):\(#line): Failed to append mock table data: \(error)")
        }
    }
    
    private mutating func deleteMockMenuItems() {
        do {
            let menuService = try MenuServiceImpl(databaseAccess: SQLiteDataAccess.openDatabase())
            for item in mockMenuItems {
                try menuService.delete(item)
            }
        } catch {
            print("🔨 \(#fileID):\(#line): Failed to delete mock table data: \(error)")
        }
    }
}

/*
 [
     MenuItem(itemId: UUID(uuidString: "ABAFD14A-A845-40EA-9648-D502B4DBA500")!, name: "Margherita Pizza", price: 9.99, category: mockMenuCategories[1], description: "Classic pizza with tomatoes, mozzarella cheese, fresh basil, salt, and extra-virgin olive oil.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "1C7A74A8-86D6-477A-A664-6C2EEE13B233")!, name: "Caesar Salad", price: 5.99, category: mockMenuCategories[0], description: "Crisp romaine lettuce with Caesar dressing, croutons, and grated Parmesan cheese.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "3DA0EB94-018C-4F65-A992-1A41716812F2")!, name: "Chocolate Cake", price: 4.99, category: mockMenuCategories[2], description: "Rich and moist chocolate cake with a creamy chocolate frosting.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "1BCF6B5B-689E-4000-80EB-182CDE4E1956")!, name: "Lemonade", price: 2.99, category: mockMenuCategories[3], description: "Refreshing lemonade made with freshly squeezed lemons, water, and sugar.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "709E3589-C199-47F7-9277-D42719C7008A")!, name: "Spaghetti Carbonara", price: 12.99, category: mockMenuCategories[1], description: "Spaghetti pasta with a creamy sauce made from eggs, Parmesan cheese, pancetta, and black pepper.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "9801B0F8-427F-4FAA-AA14-6276F3A39022")!, name: "French Fries", price: 3.49, category: mockMenuCategories[0], description: "Crispy and golden French fries served with a side of ketchup.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "BF9C4EB7-60D8-4F1A-A70F-27F02217B966")!, name: "Chicken Wings", price: 7.99, category: mockMenuCategories[0], description: "Spicy buffalo wings served with blue cheese dipping sauce.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "3863401E-A89E-40A5-A125-64A3C9C73721")!, name: "Garden Salad", price: 4.99, category: mockMenuCategories[4], description: "Fresh mixed greens with cucumbers, tomatoes, and a light vinaigrette.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "7F98A61C-3113-4714-BD3E-27D6083C6C6C")!, name: "Tomato Soup", price: 3.99, category: mockMenuCategories[5], description: "Creamy tomato soup served with a side of croutons.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "38FDC572-C8B0-4DDC-8B8D-4D1D06E66D7C")!, name: "Beef Burger", price: 10.99, category: mockMenuCategories[1], description: "Juicy beef burger with lettuce, tomato, onion, and pickles on a toasted bun.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "345F93BD-6DCC-4ABB-92D4-FB71C8B56558")!, name: "Grilled Chicken Sandwich", price: 8.99, category: mockMenuCategories[1], description: "Grilled chicken breast sandwich with lettuce, tomato, and mayo.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "E2715EF9-AEED-4FF8-B30D-DDD418714EDF")!, name: "Mango Smoothie", price: 3.49, category: mockMenuCategories[3], description: "Fresh mango smoothie made with ripe mangoes, yogurt, and a touch of honey.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "884C97E2-6548-4E95-AAA5-EA250E4CD2F2")!, name: "Cheesecake", price: 5.49, category: mockMenuCategories[2], description: "Creamy cheesecake with a graham cracker crust and a strawberry topping.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "BC728CC5-DAC5-4535-8EB1-610B5EBFE4F8")!, name: "Stuffed Mushrooms", price: 6.99, category: mockMenuCategories[0], description: "Mushrooms stuffed with a blend of cheeses, herbs, and breadcrumbs.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "EF1A52C1-6FC9-4700-B1CF-63E8469C3874")!, name: "Pasta Primavera", price: 11.99, category: mockMenuCategories[1], description: "Pasta with fresh vegetables and a light garlic and olive oil sauce.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "51A2B7F0-61DF-4A18-8B4B-46EBEB13E7F9")!, name: "Garlic Bread", price: 2.99, category: mockMenuCategories[0], description: "Toasted garlic bread with a side of marinara sauce.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "AF91592C-8B04-4ED5-BB17-F5AA5454819E")!, name: "BBQ Ribs", price: 14.99, category: mockMenuCategories[1], description: "Tender BBQ ribs served with coleslaw and fries.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "6F9BCEBC-D5AB-425A-B3FA-29772C4465C9")!, name: "Greek Salad", price: 6.49, category: mockMenuCategories[4], description: "Salad with feta cheese, olives, cucumbers, tomatoes, and red onions.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "B5724CA4-D105-478B-B0FC-1E4D581A8AE2")!, name: "Minestrone Soup", price: 4.49, category: mockMenuCategories[5], description: "Hearty vegetable soup with pasta and beans.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "C86D3E3B-9A6B-41F4-BE22-E205E04D3E0C")!, name: "Tiramisu", price: 5.99, category: mockMenuCategories[2], description: "Classic Italian dessert with layers of coffee-soaked ladyfingers and mascarpone cheese.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "AB04537C-0790-4F83-A0FC-9E4ED021CD27")!, name: "Iced Coffee", price: 2.49, category: mockMenuCategories[3], description: "Chilled coffee served over ice with a splash of milk.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "A12A4995-1810-42EB-BFDC-40D5DA36E5E4")!, name: "Buffalo Chicken Wrap", price: 7.49, category: mockMenuCategories[1], description: "Spicy buffalo chicken wrap with lettuce, tomato, and ranch dressing.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "CE77E0BD-2414-4ACD-8F37-D682E0664A78")!, name: "Onion Rings", price: 3.99, category: mockMenuCategories[0], description: "Crispy onion rings served with a side of dipping sauce.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "A854B01A-B01D-44EC-9B9D-9E94BA842734")!, name: "Veggie Pizza", price: 8.99, category: mockMenuCategories[1], description: "Pizza topped with fresh vegetables and mozzarella cheese.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "44CEEA60-16E9-49F8-BECB-61000359DE02")!, name: "Shrimp Cocktail", price: 9.49, category: mockMenuCategories[0], description: "Chilled shrimp served with cocktail sauce.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "B8E2CEE4-BCCF-4D2B-90FD-9FFF6A0F419D")!, name: "Beef Tacos", price: 7.99, category: mockMenuCategories[1], description: "Three beef tacos with lettuce, cheese, and salsa.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "AE4CE28C-644E-49B1-BA0B-048088EA0D66")!, name: "Apple Pie", price: 4.49, category: mockMenuCategories[2], description: "Classic apple pie with a flaky crust and a hint of cinnamon.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "1725CF1C-0ACC-408E-926A-E71E56AFC3B7")!, name: "Hot Chocolate", price: 2.49, category: mockMenuCategories[3], description: "Rich and creamy hot chocolate topped with whipped cream.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "ACE9799B-46F2-4DB6-91CB-B0895AD10EAE")!, name: "Clam Chowder", price: 4.99, category: mockMenuCategories[5], description: "Creamy clam chowder with potatoes and clams.", image: UIImage(named: "burger")!),
     MenuItem(itemId: UUID(uuidString: "8AEA471D-3B81-4BFA-8806-7B7E14D0694E")!, name: "Fried Calamari", price: 8.99, category: mockMenuCategories[0], description: "Crispy fried calamari served with marinara sauce.", image: UIImage(named: "burger")!)
 ]
 */
