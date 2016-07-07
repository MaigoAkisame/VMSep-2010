function x = resynth(config, X)
%RESYNTH    Resynthesis of time-domain signal from spectrogram.
%   Format: x = resynth(config, X)
%   Inputs:
%       config: Configuration for separation step.
%       X:      Spectrogram.
%   Output:
%       x:      Resynthesized time-domain signal.

    [bins frames] = size(X);
    x = zeros(config.frameLen + config.frameShift * (frames-1), 1);
    for f = 1:frames
        start = (f-1) * config.frameShift + 1;
        finish = start - 1 + config.frameLen;
        Y = X(:,f);
        Y = [Y; conj(Y(end-1:-1:2))];
        x(start:finish) = x(start:finish) + real(ifft(Y)) .* config.windowResynth;
    end
end
