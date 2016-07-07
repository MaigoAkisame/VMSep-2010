function midi = extractPitch(configMfcc, configEsi, x, mfccHmm, esiHmm)
%EXTRACTPITCH   Function for A/U/V decision and pitch tracking.
%   Format: midi = extractPitch(configMfcc, configEsi, x, mfccHmm, esiHmm
%   Inputs:
%       configMfcc: Configuration for MFCC features.
%       configEsi:  Configuration for ESI features.
%       x:          Input signal.
%       mfccHmm:    HMM for MFCC features.
%       esiHmm:     HMM for ESI features.
%   Output:
%       midi:       Row vector containing the exxtracted pitch contour, in 
%                   midi number scale, one number per frame. 0 stands for
%                   accompaniment, and -1 stands for unvoiced regions.

    mfcc = mfccFeature(configMfcc, x);
    sal = salience(configEsi, x);
    esi = esiFeature(configEsi, sal);

    midi = viterbi(mfcc, mfccHmm);
    segs = findSegs(midi == 3); % find voiced segs
    midi(midi == 1) = 0;        % accom
    midi(midi == 2) = -1;       % unvoiced
    for s = 1:size(segs,1)
        ind = segs(s,1) : segs(s,2);
        midi(ind) = refinePitch(configEsi, viterbi(esi(:,ind), esiHmm), sal(:,ind));
    end
end

function midi = refinePitch(config, state, sal)
% Refine pitch contour by picking the peaks in the salience map around the
%   coarse pitch contour.
    frames = length(state);
    midi = config.midisCoarse(state);
    for f = 1:frames
        ind = find((config.midisFine >= midi(f) - 0.5) & (config.midisFine <= midi(f) + 0.5));
        midis = config.midisFine(ind);
        [temp ind] = max(sal(ind, f));
        midi(f) = midis(ind);
    end
end

function segs = findSegs(bool)
% Find continuous segments of 1 in bool.
    bool = bool(:);
    start = bool & ~[0; bool(1:end-1)];
    finish = bool & ~[bool(2:end); 0];
    segs = [find(start), find(finish)];
end
