function vmsep(fileMix, fileVoice, fileAccom)
%VMSEP  Main function for voice/accompaniment. To compile into an exe file.
%   Format: vmsep(fileMix, fileVoice, fileAccom)
%   Inputs:
%       fileMix:    Filename of the mixed signal. The extension '.wav' may
%                   be omitted. The file must be mono-channel, sampled at
%                   16 kHz.
%       fileVoice, fileAccom (optional):
%                   Filenames of the separated voice and accompaniment. The
%                   extension '.wav' may be omitted. If these two arguments
%                   are absent, the suffixes '_voice' and '_accom' will be
%                   attached to the main filename of the mixed signal.

    switch nargin
        case 1
            if (endInWav(fileMix)) fileMix = fileMix(1:end-4); end
            fileVoice = [fileMix, '_voice.wav'];
            fileAccom = [fileMix, '_accom.wav'];
            fileMix = [fileMix, '.wav'];
        case 3
            if (~endInWav(fileMix)) fileMix = [fileMix, '.wav']; end
            if (~endInWav(fileVoice)) fileVoice = [fileVoice, '.wav']; end
            if (~endInWav(fileAccom)) fileAccom = [fileAccom, '.wav']; end
        otherwise
            error('Wrong number of input arguments.');
    end

    [x fs] = wavread(fileMix);
    if (size(x,2) ~= 1) error('Input signal must be mono-channel.'); end
    if (fs ~= 16000)
        error('Input signal must be sampled at 16 kHz');
    end
    
    config.configMfcc = configMfcc;
    config.configEsi = configEsi;
    config.configSep = configSep;
    load HMM0
    for u = 1:length(mfccHmm0.gmm)
        mfccHmm0.gmm{u} = gmdistribution(mfccHmm0.gmm{u}.mu, mfccHmm0.gmm{u}.Sigma, mfccHmm0.gmm{u}.PComponents);
    end
    for u = 1:length(esiHmm0.gmm)
        esiHmm0.gmm{u} = gmdistribution(esiHmm0.gmm{u}.mu, esiHmm0.gmm{u}.Sigma, esiHmm0.gmm{u}.PComponents);
    end
    config.mfccHmm = mfccHmm0;
    config.esiHmm = esiHmm0;
    
    % Replace zeros with very small noise to avoid nasty NaN problems
    zeroInd = find(x == 0);
    x(zeroInd) = randn(length(zeroInd), 1) * 1e-10;
    
    midi = extractPitch(config.configMfcc, config.configEsi, x, config.mfccHmm, config.esiHmm);
    [voice accom] = separate(config.configSep, x, midi);
    
    wavwrite(voice, fs, fileVoice);
    wavwrite(accom, fs, fileAccom);
end

function flag = endInWav(s)
    if (length(s) < 4)
        flag = false;
    else
        flag = strcmpi(s(end-3:end), '.wav');
    end
end
