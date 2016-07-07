function sal = salience(config, x)
%SALIENCE   F0 salience map.
%   Format: sal = salience(config, x)
%   Inputs:
%       config: Configuration for ESI features.
%       x:      Input signal.
%   Output:
%       sal:    Salience map.

    X = abs(spectrogram(config, x));
    E = config.M * X;                   % energy in each band
    W = (config.M' * E.^(-2/3)) .* X;   % whitened spectrogram
    sal = config.S * W;
end
