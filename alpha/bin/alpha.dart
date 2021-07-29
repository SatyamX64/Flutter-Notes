import 'dart:async';

import 'dart:math';

/// Exposes a stream that continuously generates random numbers
class RandomStream {
  /// The maximum random number to be generated
  final int maxValue;
  static final _random = Random();
  Timer _timer;
  int _currentCount;
  StreamController<int> _controller;

  /// Handles a stream that continuously generates random numbers. Use
  /// [maxValue] to set the maximum random value to be generated.
  RandomStream({this.maxValue = 100}) {
    _currentCount = 0;
    _controller = StreamController<int>(
        onListen: _startStream,
        onResume: _startStream,
        onPause: _stopTimer,
        onCancel: _stopTimer);

    // Timer.Periodic() // will be wrong, since stream will start emitting as soon as it is made, even when no one is listening
    // So we don't call it in constructor
  }

  /// A reference to the random number stream
  Stream<int> get stream => _controller.stream;

  void _startStream() {
    _timer = Timer.periodic(const Duration(seconds: 1), _runStream);
    _currentCount = 0;
  }

  void _stopTimer() {
    _timer?.cancel();
    _controller.close();
  }

  void _runStream(Timer timer) {
    _currentCount++;
    _controller.add(_random.nextInt(maxValue));
    if (_currentCount == maxValue) {
      _stopTimer();
    }
  }
}

void main() async {
  final stream = RandomStream().stream;
  await Future.delayed(const Duration(seconds: 2));

  // The timer inside our 'RandomStream' is started
  final subscription = stream.listen((int random) {
    print(random);
  });

  await Future.delayed(const Duration(milliseconds: 3200));
  await subscription.cancel();
}
