function sr_convert(fname, fname_out)

% convert a 2-channel sound file with arbitrary sample rate to 16 kHz
% single channel.
[dat,raw_sr] = audioread(fname);
dat = (dat(:, 1)+dat(:, 2))/2;
[P,Q] = rat(16000/raw_sr);
dat = resample(dat, P, Q);
audiowrite(fname_out, dat, 16000);

end