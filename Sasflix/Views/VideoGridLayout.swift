import SwiftUI

enum VideoGridLayout {
    static let spacing: CGFloat = 12
    
    static func columns(
        contentWidth: CGFloat,
        horizontalSizeClass: UserInterfaceSizeClass?,
        verticalSizeClass: UserInterfaceSizeClass?
    ) -> [GridItem] {
        if verticalSizeClass == .compact {
            return fixedColumns(count: 2)
        }
        
        if horizontalSizeClass == .regular {
            return fixedColumns(count: contentWidth >= 1_000 ? 4 : 3)
        }
        
        return fixedColumns(count: 1)
    }
    
    private static func fixedColumns(count: Int) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: count)
    }
}
