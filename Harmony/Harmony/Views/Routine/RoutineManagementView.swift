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
    @State private var showingEditRoutineView = false
    @State private var selectedRoutine: Routine?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            if viewModel.routines.isEmpty {
                VStack {
                    Text("아직 일과가 없습니다.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                }
                .background(Color.gray1)
            } else {
                List {
                    ForEach(viewModel.routines) { routine in
                        RoutineRow(routine: routine, selectedRoutine: $selectedRoutine, showingEditRoutineView: $showingEditRoutineView, viewModel: viewModel)
                            .contentShape(Rectangle())
                    }
                    .listRowBackground(Color.gray1)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                }
                .listStyle(PlainListStyle())
            }
        }
        .background(Color.gray1)
        .navigationBarTitle("일과 관리", displayMode: .inline)
        .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("back-icon")
                })
        .sheet(item: $selectedRoutine) { routine in
            RoutineEditView(viewModel: viewModel, routine: routine)
        }
        .onAppear {
            Task {
                await viewModel.fetchRoutines()
            }
        }
    }
    
    func deleteRoutine(_ routine: Routine) async {
        do {
            try await viewModel.deleteRoutine(routine)
        } catch {
            print("Error deleting routine: \(error)")
        }
    }
}

struct RoutineRow: View {
    let routine: Routine
    @Binding var selectedRoutine: Routine?
    @Binding var showingEditRoutineView: Bool
    let viewModel: RoutineViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(viewModel.daysAsString(for: routine)) / \(routine.time.formattedTime)")
                    .font(.pretendardMedium(size: 16))
                    .foregroundColor(Color.gray4)
                Text(routine.title)
                    .font(.pretendardSemiBold(size: 24))
                    .foregroundColor(.black)
                    .lineSpacing(20 * 0.2)
                    .frame(width: 157, height: 68, alignment: .topLeading)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            Menu {
                Button(action: {
                    selectedRoutine = routine
                    showingEditRoutineView = true
                }) {
                    Text("일과 수정")
                }
                Button(action: {
                    Task {
                        do {
                            try await viewModel.deleteRoutine(routine)
                        } catch {
                            print("Error deleting routine: \(error)")
                        }
                    }
                }) {
                    Text("일과 삭제")
                        .foregroundColor(.red)
                }
            } label: {
                VStack {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .padding(.top)
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 15)
        .padding(.leading, 25)
        .padding(.trailing, 15)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray2, lineWidth: 1)
        )
    }
}

#Preview {
    RoutineManagementView(viewModel: RoutineViewModel())
}
