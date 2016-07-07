function config = configSep
%CONFIGSEP  Configuration for separation step.

    % Basic parameters
    config.fs           = 16000;
    config.frameLen     = 640;      % 40ms @ 16kHz
    config.frameShift   = 320;      % 20ms @ 16kHz
    config.fftSize      = 640;      % = frameLen for resynthesis
    config.window       = sinebell(config.fftSize); % window for analysis
    config.windowResynth= sinebell(config.fftSize); % window for resynthesis
    
    % Matrix parameters
    config.midis        = 38.5:0.1:74.5;
    config.Nf           = length(config.midis);
    config.Nk1          = 30;
    config.Nk2          = 9;
    config.Nr           = 20;

    % Dictionaries
    config.Bf           = glott(config, midi2hertz(config.midis));
    config.Ck           = genCk(config.fftSize, config.Nk1);

    % Iteration parameters
    config.iters        = 50;
end

function G = glott(config, f0)
    G = zeros(config.fftSize / 2 + 1, length(f0));
    Ot = 0.25;
    t = [0:config.fftSize-1]' / config.fs;
    for u = 1:length(f0)
        f = f0(u);
        k = [1 : floor(config.fs / 2 / f)];
        temp = j * 2 * pi * k * Ot;
        amp = (exp(-temp) + (2 * (1 + 2 * exp(-temp)) ./ temp) - (6 * (1 - exp(-temp)) ./ temp.^2));
        x = real(exp(2 * j * pi * f * t * k) * amp.');
        X = abs(fft(x .* config.window));
        G(:,u) = X(1:config.fftSize/2+1) .^ 2;
    end
end

function Ck = genCk(fftSize, N)
    x = linspace(0, 1, fftSize / 2 + 1)';
    halfWidth = 1 / (N-1);
    Ck = zeros(fftSize / 2 + 1, N);
    for k = 1:N
        center = (k-1) / (N-1);
        Ck(:,k) = (abs(x - center) < halfWidth) .* (1 + cos((x - center) / halfWidth * pi));
    end
end
