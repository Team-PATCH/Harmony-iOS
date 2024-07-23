//
//  RoutineManagementView.swift
//  Harmony
//
//  Created by 조다은 on 7/23/24.
//

import SwiftUI

struct RoutineManagementView: View {
    @ObservedObject var viewModel: RoutineViewModel
    @State private var showingAddRoutineView = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.routines) { routine in
                        HStack {
                            Image(systemName: "rectangle")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .background(Color.gray)
                                .cornerRadius(8)
                                .padding(.trailing, 8)
                            VStack(alignment: .leading) {
                                Text(routine.title)
                                    .font(.headline)
                                Text("\(viewModel.daysAsString(for: routine)) / \(routine.time, style: .time)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: {
                                deleteRoutine(routine)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())

                Spacer()

                // Add Button
                Button(action: {
                    showingAddRoutineView.toggle()
                }) {
                    Text("+ 추가하기")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                        .padding()
                }
                .sheet(isPresented: $showingAddRoutineView) {
                    RoutineAddView(viewModel: viewModel)
                }
            }
            .navigationBarTitle("일과 관리", displayMode: .inline)
        }
    }

    func deleteRoutine(_ routine: Routine) {
        if let index = viewModel.routines.firstIndex(where: { $0.id == routine.id }) {
            viewModel.routines.remove(at: index)
            viewModel.generateDailyRoutines()
        }
    }
}

#Preview {
    RoutineManagementView(viewModel: RoutineViewModel())
}
