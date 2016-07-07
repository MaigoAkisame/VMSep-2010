function config = configMfcc
%CONFIGMFCC Configuration for MFCC features.

    % Basic parameters
    config.fs           = 16000;
    config.frameLen     = 640;      % 40ms @ 16kHz
    config.frameShift   = 320;      % 20ms @ 16kHz
    config.fftSize      = 1024;     % minimum power of 2 >= frameLen
    config.window       = hamming(config.frameLen);

    % MFCC feature parameters
    config.bands            = 40;       % Bands in Mel filter bank
    config.coefs            = 12;       % How many coefficients to take from the DCT result
    config.energy           = true;     % Whether to add log frame energy as a dimension of feature
    config.normalization    = 'CMN';    % CMS (cepstral mean subtraction) or CMN (CMS + normalization to unit variance) or NONE
    config.diffs            = 2;        % How many orders of differentials
    config.staticDims       = config.coefs + config.energy;
    config.totalDims        = config.staticDims * (1 + config.diffs);
    
    % Matrices for calculating MFCC feature
    config.M       = melfb(config.bands, config.fftSize, config.fs);             % Mel filter bank matrix
    config.D       = dctmtx(config.bands);
    config.D       = config.D(2:config.coefs+1, :);                              % DCT matrix

    % Parameters for training GMM & HMM
    config.maxComponents = 32;
    config.maxIter       = 20;
    config.states        = 3;
    config.label2state   = @label2state;
    
    function state = label2state(label)
        state = label;
        state(label == 0) = 1;  % accom
        state(label <  0) = 2;  % unvoiced
        state(label >  0) = 3;  % voiced
    end
end
