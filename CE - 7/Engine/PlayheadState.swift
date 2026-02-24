/// Shared state between the real-time render thread and main thread.
/// Uses raw pointers so the render block never touches Swift objects.
final class PlayheadState {
    /// Current render position in samples (owned by render thread)
    let renderPos: UnsafeMutablePointer<Double>
    /// Playback rate: 1.0 = normal, 0.5 = half speed, -1.0 = reverse, 0 = stopped
    let rate: UnsafeMutablePointer<Double>
    /// Target position the render block should converge toward (prevents drift during scrub)
    let target: UnsafeMutablePointer<Double>
    /// Total sample count available
    let sampleCount: UnsafeMutablePointer<Int>

    init() {
        renderPos = .allocate(capacity: 1);   renderPos.initialize(to: 0)
        rate = .allocate(capacity: 1);        rate.initialize(to: 0)
        target = .allocate(capacity: 1);      target.initialize(to: 0)
        sampleCount = .allocate(capacity: 1); sampleCount.initialize(to: 0)
    }

    deinit {
        renderPos.deinitialize(count: 1);   renderPos.deallocate()
        rate.deinitialize(count: 1);        rate.deallocate()
        target.deinitialize(count: 1);      target.deallocate()
        sampleCount.deinitialize(count: 1); sampleCount.deallocate()
    }
}
