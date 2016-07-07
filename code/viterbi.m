function state = viterbi(feature, hmm)
%VITERBI    Viterbi decoding of HMM.
%   Format: state = viterbi(feature, hmm)
%   Inputs:
%       feature:    Feature matrix, where each column stands for a time
%                   step.
%       HMM:        HMM model.
%   Output:
%       state:      Decoded state sequence.

    frames = size(feature, 2);
    states = length(hmm.init);
    decision = zeros(frames, states);

    emit = -inf(frames, states);
    for u = 1:states
        if (~isempty(hmm.gmm{u}))
            emit(:,u) = log(hmm.gmm{u}.pdf(feature'));
        end
    end

    trans = log(hmm.trans);
    prob = log(hmm.init);
    for f = 1:frames
        newProb = zeros(1, states);
        for u = 1:states
            [newProb(u) decision(f,u)] = max(prob + trans(:,u)');
        end
        prob = newProb + emit(f,:);
    end

    [temp state(frames)] = max(prob);
    for f = frames:-1:2
        state(f-1) = decision(f, state(f));
    end
end
