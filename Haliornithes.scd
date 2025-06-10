// Haliornithes.scd

Server.default.options.device = "ASIO : ASIO4ALL v2";

s.waitForBoot {
    // Grain SynthDef with filters, envelope control, and movement
    SynthDef(\xenacloudGrain, {
        |freq=400, amp=0.2, pan=0, dur=0.1, glissDur=0.3, wave=0, atk=0.005, rel=0.1, rq=0.3, filtType=0|
        var sig, env, glideFreq, noiseMod, selectWave, filtered, filterFreq;

        glideFreq = Line.ar(freq, freq * ExpRand(0.8, 1.2), glissDur);
        noiseMod = LFNoise2.kr(4).range(-5, 5);

        selectWave = Select.ar(wave, [
            SinOsc.ar(glideFreq + noiseMod),
            Blip.ar(glideFreq, LFNoise1.kr(2).range(2, 12)),
            Formant.ar(glideFreq, glideFreq*1.2, glideFreq*0.5),
            Saw.ar(glideFreq + noiseMod),
            Pulse.ar(glideFreq, 0.5)
        ]);

        // Envelope with custom attack/release
        env = EnvGen.kr(Env.perc(atk, rel), doneAction: 2);
        sig = selectWave * amp * env;

        // Filter types: 0 = BPF, 1 = RLPF
        filterFreq = glideFreq * LFNoise1.kr(0.3).range(0.8, 1.2);
        filtered = Select.ar(filtType, [
            BPF.ar(sig, filterFreq, rq),
            RLPF.ar(sig, filterFreq, rq)
        ]);

        // Spatial LFO modulation
        sig = Pan2.ar(filtered, pan + LFNoise1.kr(0.1).range(-1.0, 1.0));
        Out.ar(0, sig);
    }).add;

    // FX chain with reverb, delay and mild saturation
    SynthDef(\xenaFX, {
        var in, verb, delay, lfo, wet, sat;
        in = In.ar(0, 2);
        lfo = LFNoise1.kr(0.1).range(0.4, 0.7);
        verb = FreeVerb2.ar(in[0], in[1], mix: lfo, room: 0.9, damp: 0.6);

        // Feedback delay + soft saturation
        delay = CombC.ar(verb, 0.4, LFNoise1.kr(0.05).range(0.02, 0.2), 2);
        sat = tanh(delay * 2);  // Mild soft clipping

        ReplaceOut.ar(0, sat);
    }).add;

    s.sync;
    Synth(\xenaFX);

    // Play layers with more parameters
    Pdef(\xenaClouds, Ppar([
        Pbind(
            \instrument, \xenacloudGrain,
            \freq, Pexprand(100, 500, inf),
            \dur, Pwhite(0.05, 0.2, inf),
            \amp, Pwhite(0.05, 0.2, inf),
            \wave, Pwhite(0, 4, inf),
            \glissDur, Pwhite(0.05, 0.3, inf),
            \atk, Pwhite(0.001, 0.01, inf),
            \rel, Pwhite(0.05, 0.3, inf),
            \rq, Pwhite(0.1, 0.5, inf),
            \filtType, Pwrand([0, 1], [0.6, 0.4], inf),
            \pan, Pbrown(-1, 1, 0.1, inf)
        ),
        Pbind(
            \instrument, \xenacloudGrain,
            \freq, Pexprand(400, 1200, inf),
            \dur, Pwhite(0.02, 0.1, inf),
            \amp, Pwhite(0.02, 0.15, inf),
            \wave, Pwhite(0, 4, inf),
            \glissDur, Pwhite(0.02, 0.2, inf),
            \atk, Pwhite(0.001, 0.01, inf),
            \rel, Pwhite(0.03, 0.15, inf),
            \rq, Pwhite(0.2, 0.6, inf),
            \filtType, Pwrand([0, 1], [0.4, 0.6], inf),
            \pan, Pbrown(-1, 1, 0.05, inf)
        ),
        Pbind(
            \instrument, \xenacloudGrain,
            \freq, Pexprand(1000, 5000, inf),
            \dur, Pwhite(0.01, 0.05, inf),
            \amp, Pwhite(0.01, 0.1, inf),
            \wave, Pwhite(0, 4, inf),
            \glissDur, Pwhite(0.01, 0.1, inf),
            \atk, Pwhite(0.001, 0.008, inf),
            \rel, Pwhite(0.01, 0.07, inf),
            \rq, Pwhite(0.1, 0.3, inf),
            \filtType, Pwrand([0, 1], [0.5, 0.5], inf),
            \pan, Pbrown(-1, 1, 0.02, inf)
        )
    ])).play;
};
