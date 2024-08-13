//
//  HomeView.swift
//  Harmony
//
//  Created by 조다은 on 7/23/24.
//


import SwiftUI

/*
struct HomeView: View {
    @StateObject private var routineViewModel = RoutineViewModel()
    @StateObject private var memoryCardViewModel = MemoryCardViewModel()
    @State private var isShowingMemoryCardCreate = false
    @State private var isShowingMemoryCardView = false
    @State private var selectedDailyRoutine: DailyRoutine?
    @State private var isShowingRoutineAdd = false
    @State private var isShowingMemoryCardRecord = false
    @State private var hasSharedMemoryCard = false // 추억카드 공유 상태를 추적하는 새로운 상태 변수
    
    @State private var selectedMemoryCard: MemoryCard?
    
    @Binding var isAuth: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    if UserDefaultsManager.shared.isMember() {
                        if hasSharedMemoryCard {
                            // 추억카드가 공유된 후의 뷰
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
                            .padding()
                            .background(Color.gray1)
                        } else {
                            // 추억카드를 아직 공유하지 않았을 때의 뷰
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
                            .padding()
                            .background(Color.gray1)
                        }
                    } else {
                        // VIP일 때 (추억카드가 있을 때)
                        VStack(alignment: .center, spacing: 20) {
                            Image("letter-image2")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
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
                            Button(action: {
                                isShowingMemoryCardRecord = true
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
                        .padding()
                        .background(Color.gray1)
                    }
                    
                    // 일과 섹션
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
                        
                        VStack(alignment: .leading) {
                            Text("나머지도 힘내서 달성해 봐요!")
                                .foregroundColor(.gray)
                            HStack {
                                Text("\(Int(routineViewModel.completionRate * 100))% 완료")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.green)
                                Spacer()
                            }
                            CustomProgressView(value: routineViewModel.completionRate)
                        }
                        .padding(.vertical)
                        
                        if routineViewModel.dailyRoutines.isEmpty {
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
        .onAppear {
            UINavigationBar.appearance().backgroundColor = .white
            if #available(iOS 15.0, *) {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .white
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
        }
        .sheet(isPresented: $isShowingMemoryCardRecord) {
            MemoryCardRecordView(memoryCardId: 41, groupId: 1, previousChatHistory: [])
        }
        .fullScreenCover(item: $selectedDailyRoutine) { dailyRoutine in
            RoutineDetailView(dailyRoutine: dailyRoutine, viewModel: routineViewModel)
        }
        .fullScreenCover(isPresented: $isShowingRoutineAdd) {
            RoutineAddView(viewModel: routineViewModel)
        }
        .fullScreenCover(isPresented: $isShowingMemoryCardCreate) {
            MemoryCardCreateView(isPresented: $isShowingMemoryCardCreate, onMemoryCardCreated: {
                // 추억카드 생성 후 상태 변경
                hasSharedMemoryCard = true
            })
        }
        .onAppear {
            Task {
                await routineViewModel.fetchRoutines()
                await routineViewModel.fetchDailyRoutines()
            }
        }
    }
    
    func currentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: Date())
    }
}
*/

struct CustomProgressView: View {
    var value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray2)
                    .frame(height: 17)
                Rectangle()
                    .fill(Color.mainGreen)
                    .frame(width: CGFloat(value) * geometry.size.width, height: 17)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(height: 17)
    }
}

//#Preview {
//    HomeView()
//}


import SwiftUI

struct HomeView: View {
    @StateObject private var routineViewModel = RoutineViewModel()
//    @StateObject private var memoryCardViewModel = MemoryCardViewModel()
    @EnvironmentObject var memoryCardViewModel: MemoryCardViewModel
    @State private var isShowingMemoryCardCreate = false
    @State private var isShowingMemoryCardView = false
    @State private var selectedDailyRoutine: DailyRoutine?
    @State private var isShowingRoutineAdd = false
    @State private var isShowingMemoryCardRecord = false
    @State private var hasSharedMemoryCard = false
    @State private var selectedMemoryCard: MemoryCard?
    
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
        .onAppear(perform: setupNavigationBar)
        
// MARK: - 1차 동작
//        .sheet(isPresented: $isShowingMemoryCardRecord, onDismiss: {
//            // 뷰가 닫힐 때 상태 리셋
//            isShowingMemoryCardRecord = false
//            selectedMemoryCardId = nil
//        }) {
//            if let cardId = selectedMemoryCardId {
//                MemoryCardRecordView(memoryCardId: cardId, groupId: UserDefaultsManager.shared.getGroupId() ?? 1, previousChatHistory: [])
//                    .environmentObject(memoryCardViewModel)
//                    .id(UUID()) // 강제로 새로운 ID를 할당해 리렌더링을 트리거
//            }
//        }
        
        .sheet(item: $selectedMemoryCardId) { cardId in
            MemoryCardRecordView(memoryCardId: cardId, groupId: UserDefaultsManager.shared.getGroupId() ?? 1, previousChatHistory: [])
                .environmentObject(memoryCardViewModel)
        }

        
//        .onChange(of: memoryCardViewModel.newMemoryCard) { newCard in
//            if let card = newCard {
//                print("추억카드 로드 완료: \(card)")
//                selectedMemoryCardId = card.id
//                // 자동으로 isShowingMemoryCardRecord를 true로 설정하지 않음
////                isShowingMemoryCardRecord = true
//            } else {
//                print("newMemoryCard가 nil입니다.")
//            }
//        }
        
//        .onChange(of: memoryCardViewModel.newMemoryCard) { newCard in
//            if let card = newCard {
//                print("추억카드 로드 완료: \(card)")
//                selectedMemoryCardId = card.id
//
//                // isShowingMemoryCardRecord를 자동으로 설정하지 않음
//                // 상태를 강제로 업데이트할 필요가 있을 때만 사용
//            } else {
//                print("newMemoryCard가 nil입니다.")
//            }
//        }
        
        
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
        .environmentObject(memoryCardViewModel)  // 이 줄을 추가합니다.
        .onAppear {
            // 상태를 명확하게 초기화
            isShowingMemoryCardRecord = false
            selectedMemoryCardId = nil
            
            // 필요한 경우 데이터 로드
            memoryCardViewModel.loadLatestMemoryCard()
            Task {
                await routineViewModel.fetchRoutines()
                await routineViewModel.fetchDailyRoutines()
            }
        }
        .onDisappear {
            // 뷰가 사라질 때 상태를 초기화
            isShowingMemoryCardRecord = false
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
                MemoryCardView(card: card, viewModel: memoryCardViewModel)
                    .frame(height: 200)
                    .onTapGesture {
//                        selectedMemoryCard = card
                        selectedMemoryCardId = card.id
                        isShowingMemoryCardRecord = true
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
            Button(action: {
                // MARK: - 앱을 처음 켜고 뷰 처음 진입 시 정상 동작 버전 코드
//                print("추억카드 확인하기 버튼 클릭")
//                
//                // 기존에 선택된 메모리 카드를 확인
//                if let card = memoryCardViewModel.newMemoryCard {
//                    print("선택된 카드: \(card)")
//                    selectedMemoryCardId = card.id
//                    isShowingMemoryCardRecord = true
//                } else {
//                    // 필요시 새로 로드
//                    print("newMemoryCard가 nil입니다. 다시 로드 시도.")
//                    memoryCardViewModel.loadLatestMemoryCard()
//                }
                
//                print("추억카드 확인하기 버튼 클릭")
//                
//                // 카드가 이미 로드된 상태인지 확인
//                if let card = memoryCardViewModel.newMemoryCard {
//                    print("선택된 카드: \(card)")
//                    selectedMemoryCardId = card.id
//                    isShowingMemoryCardRecord = true
//                } else {
//                    // 필요시 새로 로드
//                    print("newMemoryCard가 nil입니다. 다시 로드 시도.")
//                    memoryCardViewModel.loadLatestMemoryCard()
//                }
                
                print("추억카드 확인하기 버튼 클릭")
                
                if let card = memoryCardViewModel.newMemoryCard {
                    print("선택된 카드: \(card)")
                    selectedMemoryCardId = card.id
                    
                    // 상태를 강제로 리셋 후 업데이트
                    isShowingMemoryCardRecord = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isShowingMemoryCardRecord = true
                    }
                } else {
                    print("newMemoryCard가 nil입니다. 다시 로드 시도.")
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
        .padding()
        .background(Color.gray1)
        .onAppear {
            memoryCardViewModel.loadLatestMemoryCard()
            print("VIP 뷰 나타남, newMemoryCard: \(String(describing: memoryCardViewModel.newMemoryCard))")
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
            
            VStack(alignment: .leading) {
                Text("나머지도 힘내서 달성해 봐요!")
                    .foregroundColor(.gray)
                HStack {
                    Text("\(Int(routineViewModel.completionRate * 100))% 완료")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.green)
                    Spacer()
                }
                CustomProgressView(value: routineViewModel.completionRate)
            }
            .padding(.vertical)
            
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
