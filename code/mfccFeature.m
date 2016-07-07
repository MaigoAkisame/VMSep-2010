function mfcc = mfccFeature(config, x)
%MFCCFEATURE    MFCC feature extraction.
%   Format: mfcc = mfccFeature(config, x)
%   Inputs:
%       config: Configuration for MFCC features.
%       x:      Input signal.
%   Output:
%       mfcc:   MFCC features, one column per frame.

    X = abs(spectrogram(config, x));
    frames = size(X,2);
    mfcc = zeros(config.totalDims, frames);

    mfcc(1:config.coefs, :) = config.D * log(config.M * X);
    if (config.energy == true)
        energy = zeros(1,frames);
        for f = 1:frames
            start = (f-1) * config.frameShift + 1;
            finish = start - 1 + config.frameLen;
            frame = x(start:finish) .* config.window;
            energy(f) = sum(frame.^2);
        end
        mfcc(config.staticDims, :) = log(energy);
    end

    % Cepstral mean subtraction or normalization
    switch upper(config.normalization)
        case 'CMS'
            for u = 1:config.staticDims
                mfcc(u,:) = (mfcc(u,:) - mean(mfcc(u,:)));
            end
        case 'CMN'
            for u = 1:config.staticDims
                mfcc(u,:) = (mfcc(u,:) - mean(mfcc(u,:))) / std(mfcc(u,:));
            end
    end

    % Differentials
    zeroCol = zeros(config.staticDims, 1);
    diff = mfcc(1:config.staticDims, :);
    for d = 1:config.diffs
        diff = [diff(:, 2:end), zeroCol] - [zeroCol, diff(:, 1:end-1)];
        mfcc(d * config.staticDims + 1 : (d+1) * config.staticDims, :) = diff;
    end
end
