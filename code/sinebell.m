function w = sinebell(n)
%SINEBELL   Sine bell window.
%   Format: w = sinebell(n)
%   Input:
%       n:  Window length.
%   Output:
%       w:  Sine bell window, as a column vector.

    w = sin(pi / n * (0.5 : n-0.5)');
end
