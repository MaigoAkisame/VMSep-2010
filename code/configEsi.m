function config = configEsi
%CONFIGESI  Configuration for ESI features.

    % Basic parameters
    config.fs           = 16000;
    config.frameLen     = 640;      % 40ms @ 16kHz
    config.frameShift   = 320;      % 20ms @ 16kHz
    config.fftSize      = 1024;     % minimum power of 2 >= frameLen
    config.window       = hamming(config.frameLen);

    % ESI feature parameters
    config.bands        = 40;   % Bands in Mel filter bank
    config.midisFine    = 38.5 : 0.1 : 74.5;
    config.midisCoarse  = 39 : 1 : 74;
    config.totalDims    = length(config.midisCoarse);
    
    % Matrices for calculating ESI feature
    config.M        = melfb(config.bands, config.fftSize, config.fs);                   % Mel filter bank matrix
    config.S        = salmtx(midi2hertz(config.midisFine), 0 : (config.fs / config.fftSize) : (config.fs / 2));
    config.G        = triangmtx(config.midisCoarse, config.midisFine, 1);
    config.GS       = config.G * config.S;

    % Parameters for training GMM & HMM
    config.maxComponents = 8;
    config.maxIter       = 20;
    config.states        = length(config.midisCoarse);
    config.label2state   = @label2state;
    
    function state = label2state(label)
        state = zeros(size(label));
        label = round(label);
        ind = (label >= config.midisCoarse(1)) & (label <= config.midisCoarse(end));
        state(ind) = label(ind) - config.midisCoarse(1) + 1;
    end
end

function S = salmtx(freqSal, freqFft)
    M = triangmtx(freqSal, freqFft, 25, 20);  % half band width = 25Hz, sum 20 harmonics
    weight = (freqSal(:) + 27) * (1 ./ (freqFft(:)' + 320));
    S = M .* weight;
end

function A = triangmtx(row, col, hbw, harms)
    if (nargin < 4) harms = 1; end
    row = row(:); col = col(:)';
    C = repmat(col, length(row), 1);
    M = round((1./row) * col);
    A = max(0, hbw - abs(C - diag(row) * M)) / hbw;
    mask = (M >= 1) & (M <= harms);
    A = A .* mask;
end
