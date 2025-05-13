// CategoryListView.swift
import SwiftUI

struct CategoryListView: View {
    @EnvironmentObject var categoriesViewModel: CategoriesViewModel
    var onCategorySelected: (Category) -> Void
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                ForEach(categoriesViewModel.categories) { category in
                    CategoryCardView(
                        category: category,
                        stats: categoriesViewModel.getStatsFor(categoryId: category.id)
                    )
                    .onTapGesture {
                        onCategorySelected(category)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
    }
}

struct CategoryListView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryListView(onCategorySelected: { _ in })
            .environmentObject(CategoriesViewModel())
    }
}
