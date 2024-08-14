//
//  HomeView.swift
//  Harmony
//
//  Created by 조다은 on 7/23/24.
//

import SwiftUI


struct HomeView: View {
    @StateObject private var routineViewModel = RoutineViewModel()
    @EnvironmentObject var memoryCardViewModel: MemoryCardViewModel
    @State private var isShowingMemoryCardCreate = false
    @State private var isShowingMemoryCardView = false
    @State private var selectedDailyRoutine: DailyRoutine?
    @State private var isShowingRoutineAdd = false
    @State private var hasSharedMemoryCard = false
    @State private var selectedMemoryCardId: Int?
    
    @Binding var isAuth: Bool
    
    init(isAuth: Binding<Bool>) {
        self._isAuth = isAuth
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    if UserDefaultsManager.shared.isMember() {
                        memberView
                    } else {
                        vipView
                    }
                    
                    routineSection
                }
            }
            .background(Color.gray1.edgesIgnoringSafeArea(.all))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("harmony-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                        .foregroundColor(.black)
                        .onTapGesture {
                            isAuth = false
                        }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(item: $selectedDailyRoutine) { dailyRoutine in
            RoutineDetailView(dailyRoutine: dailyRoutine, viewModel: routineViewModel)
        }
        .fullScreenCover(isPresented: $isShowingRoutineAdd) {
            RoutineAddView(viewModel: routineViewModel)
        }
        .fullScreenCover(isPresented: $isShowingMemoryCardCreate) {
            MemoryCardCreateView(isPresented: $isShowingMemoryCardCreate, onMemoryCardCreated: {
                hasSharedMemoryCard = true
            })
        }
        .environmentObject(memoryCardViewModel)
        .onAppear {
            memoryCardViewModel.loadLatestMemoryCard()
            Task {
                await routineViewModel.fetchRoutines()
                await routineViewModel.fetchDailyRoutines()
            }
        }
        .onDisappear {
            selectedMemoryCardId = nil
        }
    }
    
    private var memberView: some View {
        Group {
            if hasSharedMemoryCard {
                VStack(alignment: .center, spacing: 20) {
                    Text("오늘의 ")
                        .font(.pretendardBold(size: 24)) +
                    Text("추억카드")
                        .font(.pretendardBold(size: 24))
                        .foregroundColor(.mainGreen) +
                    Text("가 공유됐어요!")
                        .font(.pretendardBold(size: 24))
                    Text("할머니가 확인 후 추억카드가 완성돼요")
                        .font(.pretendardMedium(size: 18))
                        .foregroundColor(.gray4)
                    sharedMemoryCardView
                }
                .padding()
                .background(Color.gray1)
            } else {
                VStack(alignment: .center, spacing: 20) {
                    Text("할머니의 ")
                        .font(.pretendardBold(size: 24)) +
                    Text("추억을 ")
                        .font(.pretendardBold(size: 24))
                        .foregroundColor(.mainGreen) +
                    Text("들어볼까요?")
                        .font(.pretendardBold(size: 24))
                    Text("아래를 클릭해 카드를 보내드려요.")
                        .font(.pretendardMedium(size: 18))
                        .foregroundColor(.gray4)
                    createMemoryCardButton
                }
                .padding()
                .background(Color.gray1)
            }
        }
    }
    
    private var vipView: some View {
        VStack(alignment: .center, spacing: 20) {
            if isShowingMemoryCardView, let card = memoryCardViewModel.newMemoryCard {
                NavigationLink(destination: MemoryCardDetailView(memoryCardId: card.id, groupId: UserDefaultsManager.shared.getGroupId() ?? 1)) {
                    MemoryCardView(card: card, viewModel: memoryCardViewModel)
                        .frame(height: 200)
                }
            } else {
                Image("letter-image2")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .onTapGesture {
                        memoryCardViewModel.loadLatestMemoryCard()
                        withAnimation {
                            isShowingMemoryCardView = true
                        }
                    }
            }
            Text("오늘의 ")
                .font(.pretendardBold(size: 24)) +
            Text("추억카드가 ")
                .font(.pretendardBold(size: 24))
                .foregroundColor(.mainGreen) +
            Text("도착했어요!")
                .font(.pretendardBold(size: 24))
            Text("어떤 추억인지 확인해 볼까요?")
                .font(.pretendardMedium(size: 18))
                .foregroundColor(.gray4)
            
            // Fix: Ensuring selectedMemoryCardId is properly set and used
            if let selectedMemoryCardId = selectedMemoryCardId {
                NavigationLink(destination: MemoryCardDetailView(memoryCardId: selectedMemoryCardId, groupId: UserDefaultsManager.shared.getGroupId() ?? 1)) {
                    Text("추억카드 확인하기")
                        .font(.pretendardSemiBold(size: 20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mainGreen)
                        .cornerRadius(10)
                }
            } else {
                Button(action: {
                    if let card = memoryCardViewModel.newMemoryCard {
                        selectedMemoryCardId = card.id
                    } else {
                        memoryCardViewModel.loadLatestMemoryCard()
                    }
                }) {
                    Text("추억카드 확인하기")
                        .font(.pretendardSemiBold(size: 20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mainGreen)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.gray1)
        .onAppear {
            memoryCardViewModel.loadLatestMemoryCard()
        }
    }
    
    private var sharedMemoryCardView: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .frame(height: 210)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .foregroundColor(Color.gray1)
            
            Image("letter-image2")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
        }
        .onTapGesture {
            isShowingMemoryCardView = true
        }
    }
    
    private var createMemoryCardButton: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray1)
                .frame(height: 200)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundColor(Color.gray3)
                )
            
            Image(systemName: "plus")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray3)
        }
        .onTapGesture {
            isShowingMemoryCardCreate = true
        }
    }
    
    private var routineSection: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack {
                Text(currentDate())
                    .font(.pretendardMedium(size: 22))
                    .foregroundColor(Color.mainGreen)
                Text("의 일과")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            
            
            if routineViewModel.dailyRoutines.isEmpty {
                emptyRoutineView
            } else {
                ForEach(routineViewModel.dailyRoutines.prefix(4)) { dailyRoutine in
                    DailyRoutineRow(
                        dailyRoutine: dailyRoutine,
                        routine: routineViewModel.routines.first(where: { $0.id == dailyRoutine.routineId })
                    )
                    .onTapGesture {
                        selectedDailyRoutine = dailyRoutine
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
    
    private var emptyRoutineView: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("아직 일과가 없어요.")
                .font(.pretendardMedium(size: 18))
                .foregroundColor(.gray4)
            Text("새로운 일과를 만들어 볼까요?")
                .font(.pretendardMedium(size: 18))
                .foregroundColor(.gray4)
            Button(action: {
                isShowingRoutineAdd = true
            }) {
                Text("일과 만들러 가기")
                    .font(.pretendardSemiBold(size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.mainGreen)
                    .cornerRadius(999)
            }
        }
        .padding()
    }
    
    private func setupNavigationBar() {
        UINavigationBar.appearance().backgroundColor = .white
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    private func currentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: Date())
    }
}


