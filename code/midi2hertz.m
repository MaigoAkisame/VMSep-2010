function hertz = midi2hertz(midi)
%MIDI2HERTZ     Convertion of frequencies from midi number scale to Hertz
%               scale. Non-positive values are left unchanged.
%   Format: hertz = midi2hertz(midi)
%   Input:
%       midi:   Scalar, vector or matrix of frequencies in midi number scale
%   Output:
%       hertz:  Scalar, vector or matrix of frequencies in Hertz scale

    hertz = midi;
    ind = midi > 0;
    hertz(ind) = 440 * 2 .^ ((midi(ind) - 69) / 12);
end
