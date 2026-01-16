// Audio feedback system for the timer

// Single beep sound
function playBeep(audioContext, frequency, volume, duration) {
    const oscillator = audioContext.createOscillator();
    const gainNode = audioContext.createGain();

    oscillator.connect(gainNode);
    gainNode.connect(audioContext.destination);

    oscillator.frequency.value = frequency;

    const now = audioContext.currentTime;
    gainNode.gain.setValueAtTime(0, now);
    gainNode.gain.linearRampToValueAtTime(volume, now + 0.01);
    gainNode.gain.exponentialRampToValueAtTime(0.01, now + duration);

    oscillator.start(now);
    oscillator.stop(now + duration);
}

// Pleasant ending melody for timer reaching zero
function playAlarm(audioContext) {
    // "Shave and a haircut, two bits!" - a classic ending pattern

    const melody = [
        // Second iteration
        { freq: 1661, time: 0,     duration: 0.214, volume: 0.08 },  // G#6
        { freq: 1319, time: 0.214, duration: 0.214, volume: 0.08 },  // E6
        { freq: 1047, time: 0.428, duration: 0.214, volume: 0.08 },  // C6
        { freq: 1175, time: 0.642, duration: 0.214, volume: 0.08 },  // D6
        { freq: 932,  time: 0.856, duration: 0.214, volume: 0.08 },  // Bb5
        { freq: 554,  time: 1.070, duration: 0.214, volume: 0.08 },  // C#5

        // Demi-semiquaver ascending run (32nd notes at 0.107 seconds each)
        { freq: 784,  time: 1.284, duration: 0.107, volume: 0.08 },  // G5
        { freq: 880,  time: 1.391, duration: 0.107, volume: 0.08 },  // A5
        { freq: 932,  time: 1.498, duration: 0.107, volume: 0.08 },  // Bb5
        { freq: 1047, time: 1.605, duration: 0.107, volume: 0.08 },  // C6

        // Alarm D notes (louder, half speed = 0.428 seconds each)
        { freq: 1175, time: 1.712, duration: 0.390, volume: 0.20 },  // D6
        { freq: 1175, time: 2.140, duration: 0.390, volume: 0.20 },  // D6
        { freq: 1175, time: 2.568, duration: 0.390, volume: 0.20 },  // D6
    ];

    melody.forEach((note) => {
        const oscillator = audioContext.createOscillator();
        const gainNode = audioContext.createGain();

        oscillator.connect(gainNode);
        gainNode.connect(audioContext.destination);

        oscillator.frequency.value = note.freq;
        oscillator.type = 'triangle'; // Smoother, more pleasant sound

        const startTime = audioContext.currentTime + note.time;
        const endTime = startTime + note.duration;

        // Gentle attack and release with volume ramp-up over time
        gainNode.gain.setValueAtTime(0, startTime);
        gainNode.gain.linearRampToValueAtTime(note.volume, startTime + 0.02);
        gainNode.gain.linearRampToValueAtTime(note.volume * 0.7, endTime - 0.03);
        gainNode.gain.linearRampToValueAtTime(0.001, endTime);

        oscillator.start(startTime);
        oscillator.stop(endTime);
    });
}

// Initialize audio system with Elm app
export function initAudio(app) {
    app.ports.playSound.subscribe((soundType) => {
        const audioContext = new (window.AudioContext || window.webkitAudioContext)();

        if (soundType === 'beep') {
            // Single beep for warnings and countdown
            playBeep(audioContext, 880, 0.3, 0.1);
        } else if (soundType === 'alarm') {
            // Attention-grabbing alarm at zero
            playAlarm(audioContext);
        }
    });

    // Expose test functions to window for console testing
    window.testTimerAudio = {
        beep: () => {
            const audioContext = new (window.AudioContext || window.webkitAudioContext)();
            playBeep(audioContext, 880, 0.3, 0.1);
            console.log('🔊 Playing beep sound');
        },
        alarm: () => {
            const audioContext = new (window.AudioContext || window.webkitAudioContext)();
            playAlarm(audioContext);
            console.log('🚨 Playing alarm sound');
        },
        help: () => {
            console.log(`
Timer Audio Test Functions:
---------------------------
testTimerAudio.beep()  - Play the warning/countdown beep
testTimerAudio.alarm() - Play the finish alarm
testTimerAudio.help()  - Show this help message
            `);
        }
    };

    // Show available test functions
    console.log('🎵 Timer audio test functions loaded. Type testTimerAudio.help() for info.');
}
