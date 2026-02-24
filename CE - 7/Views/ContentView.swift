import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var engine = TapeEngine()
    @Namespace private var transitionNamespace
    
    private var displayDayText: String {
        guard engine.state == .playback, let activeDate = engine.activeRecordingDate else {
            return "Today"
        }
        return dayLabel(for: activeDate)
    }
    
    private var displayRecordingNumber: Int {
        if engine.state == .playback, let activeNumber = engine.activeRecordingNumberOfDay {
            return activeNumber
        }
        return engine.nextRecordingNumberForToday
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MetalBackground()
                
                VStack {
                    HStack {
                        Spacer()
                        NavigationLink {
                            RecordingsListView()
                                .environmentObject(engine)
                                .navigationTransition(.zoom(sourceID: "display-recordings", in: transitionNamespace))
                        } label: {
                            Display(
                                timeText: engine.formattedTime,
                                dayText: displayDayText,
                                recordingNumber: displayRecordingNumber,
                                animatedTimeValue: engine.currentTime
                            )
                            .fixedSize()
                                .matchedTransitionSource(id: "display-recordings", in: transitionNamespace)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 50)
                        .padding(.trailing, 20)
                    }
                    .padding(.top, 32)
                    
                    Spacer()
                    
                    TapeReel(engine: engine)
                        .padding(.horizontal)
                    
                    
                    HStack {
                        Light(state: engine.state)
                        Spacer()
                    }
                    .padding(.bottom, 32)
                    
                    GeometryReader { geo in
                        HStack(spacing: 0) {
                            ButtonPanel(
                                state: engine.state,
                                isPaused: engine.isPaused,
                                onPrime: engine.prime,
                                onPlay: engine.play,
                                onStop: engine.stop
                            )
                                .frame(width: geo.size.width * 0.75)
                            
                            BarPanel(
                                leftLevel: engine.normalisedLevelL,
                                rightLevel: engine.normalisedLevelR
                            )
                                .frame(width: geo.size.width * 0.25)
                        }
                    }
                    .frame(height: 200)
                }
            }
            .ignoresSafeArea()
            .onAppear {
                engine.configureStorage(modelContext: modelContext)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sensoryFeedback(.error, trigger: engine.scrubBoundaryHit)
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(for: RecordingItem.self, inMemory: true)
            .previewDevice("iPhone Air")
            .previewDisplayName("iPhone 11")
    }
}
