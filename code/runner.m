raw_sr = 44100;
input = audioread('mono.wav');
[P,Q] = rat(16000/raw_sr);
input = resample(input, P, Q);
audio