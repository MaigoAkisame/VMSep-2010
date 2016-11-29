raw_sr = 44100;
input = audioread('mono_jp.wav');
[P,Q] = rat(16000/raw_sr);
input = resample(input, P, Q);
audiowrite('mono16_jp.wav', input, 16000);