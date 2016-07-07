function X = spectrogram(config, x)
%SPECTROGRAM    Spectrogram.
%   Format: X = spectrogram(config, x)
%   Inputs:
%       config: Configuration.
%       x:      Input signal.
%   Output:
%       X:      Spectrogram.

    bins = config.fftSize / 2 + 1;
    frames = floor((length(x) - config.frameLen) / config.frameShift) + 1;
    X = zeros(bins, frames);
    for f = 1:frames
        start = (f-1) * config.frameShift + 1;
        finish = start - 1 + config.frameLen;
        frame = x(start:finish) .* config.window;
        tmp = fft(frame, config.fftSize);
        X(:,f) = tmp(1:bins);
    end
end
