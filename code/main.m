function [voice accom midi] = main(x, config, midi)
%MAIN   Main function for voice/accompaniment separation.
%   Format: [voice accom midi] = main(x, config, midi)
%   Inputs:
%       x:      Mixed signal. Must be mono-channel, sampled at 16 kHz.
%       config (optional):
%               Struct of configurations. If omitted or empty, default
%               settings will be used.
%       midi (optional):
%               Referential pitch contour, in midi number scale, one number
%               per frame (40 ms frame length, 20 ms frame shift). 
%               Non-positive frames will be totally assigned to the
%               accompaniment.
%   Outputs:
%       voice:  Separated voice signal.
%       accom:  Separated accompaniment signal.
%       midi (optional):
%           Extracted or provided pitch contour. Positive numbers are f0's
%           in midi numbers, 0's stand for accompaniment, and -1's stand
%           for unvoiced frames.

    if (nargin < 2 || isempty(config))
        config.configMfcc = configMfcc;
        config.configEsi = configEsi;
        config.configSep = configSep;
        load HMM
        config.mfccHmm = mfccHmm0;
        config.esiHmm = esiHmm0;
    end

    % Replace zeros with very small noise to avoid nasty NaN problems
    zeroInd = find(x == 0);
    x(zeroInd) = randn(length(zeroInd), 1) * 1e-10;
    
    if (nargin < 3)
        midi = extractPitch(config.configMfcc, config.configEsi, x, config.mfccHmm, config.esiHmm);
    end
    [voice accom] = separate(config.configSep, x, midi);
end
