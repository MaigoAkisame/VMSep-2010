function [voice accom] = separate(config, x, midi)
%SEPARATE   Separation step by soft masking.
%   Format: [voice accom] = separate(config, x, midi)
%   Inputs:
%       config: Struct of configurations.
%       x:      Mixed signal.
%       midi:   Pitch contour, in midi number scale, one number per frame.
%   Outputs:
%       voice:  Separated voice signal.
%       accom:  Separated accompaniment signal.

    X = spectrogram(config, x);
    S = abs(X) .^ 2;
    
    frames = size(X,2);
    if (length(midi) < frames)
        midi(length(midi)+1 : frames) = 0;
    else
        midi = midi(1:frames);
    end
    Af = initAf(config, midi);
    [Af Bk Ak Bm Am] = estimate(config, S, Af);
    
    Dv = (config.Bf * Af) .* (config.Ck * Bk * Ak);
    Dm = Bm * Am;
    D = Dv + Dm;
    
    G = Dv ./ D;
    voice = resynth(config, X .* G);
    accom = resynth(config, X .* (1-G));
end

function Af = initAf(config, midi)
% Initialize matrix Af with pitch contour.
    Af = zeros(length(config.midis), length(midi));
    for f = find(midi > 0)
        Af(:,f) = abs(config.midis - midi(f)) < 0.15;
    end
    Af = sparse(Af);
end

function [Af Bk Ak Bm Am] = estimate(config, S, Af)
% Solve the source-filter model by iteration.
    bands = config.fftSize / 2 + 1;
    frames = size(Af, 2);
    voicedInd = any(Af > 0);
    
    Bf = config.Bf;
    Ck = config.Ck;
    Bk = rand(config.Nk1, config.Nk2);
    Ak = rand(config.Nk2, frames);
    Bm = rand(bands, config.Nr);
    Am = rand(config.Nr, frames);
    
    Df = Bf * Af; Dk = Ck * Bk * Ak; Dm = Bm * Am;
    for u = 1:config.iters
        % Update Bk
        D = Df .* Dk + Dm;
        Pk = S .* Df ./ (D.^2);
        Qk = Df ./ D;
        Bk = Bk .* (Ck' * Pk * Ak') ./ (Ck' * Qk * Ak');

        nor = sum(Bk, 1);
        Bk = bsxfun(@rdivide, Bk, nor);
        Ak = bsxfun(@times, Ak, nor');

        Dk = Ck * Bk * Ak;

        % Update Ak
        D = Df .* Dk + Dm;
        Qk = Df(:,voicedInd) ./ D(:,voicedInd);
        Pk = Qk .* S(:,voicedInd) ./ D(:,voicedInd);
        Ak(:,voicedInd) = Ak(:,voicedInd) .* ((Ck * Bk)' * Pk) ./ ((Ck * Bk)' * Qk);
        
        nor = sum(Ak, 1);
        Ak = bsxfun(@rdivide, Ak, nor);
        Af = bsxfun(@times, Af, nor);

        Df = Bf * Af; Dk = Ck * Bk * Ak;
        
        % Update Af
        D = Df .* Dk + Dm;
        Qf = Dk ./ D;
        Pf = Qf .* S ./ D;
        % calculate Af = Af .* (Bf' * Pf) ./ (Bf' * Qf) in a more efficient way
        [row col value] = find(Af);
        for v = 1:length(row)
            value(v) = value(v) * (Bf(:,row(v))' * Pf(:,col(v))) ./ (Bf(:,row(v))' * Qf(:,col(v)));
        end
        Af = sparse(row, col, value, size(Af,1), size(Af,2));
        
        Df = Bf * Af;

        % Update Bm
        D = Df .* Dk + Dm;
        Bm = Bm .* ((S ./ (D.^2)) * Am') ./ ((1 ./ D) * Am');

        nor = sum(Bm, 1);
        Bm = bsxfun(@rdivide, Bm, nor);
        Am = bsxfun(@times, Am, nor');

        Dm = Bm * Am;
        
        % Update Am
        D = Df .* Dk + Dm;
        Am = Am .* (Bm' * (S ./ (D.^2))) ./ (Bm' * (1 ./ D));

        Dm = Bm * Am;
    end
end

