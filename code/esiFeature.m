function esi = esiFeature(config, x)
%ESIFEATURE     ESI feature extraction.
%   Format: esi = esiFeature(config, x)
%   Inputs:
%       config: Configuration for ESI features.
%       x:      Input waveform or salience map.
%   Output:
%       esi:    ESI features, one column per frame.

    if (any(size(x) == 1)) x = salience(config, x); end
    esi = config.G * x;
    for f = 1:size(esi,2)
        esi(:,f) = esi(:,f) / sum(esi(:,f));
    end
end
